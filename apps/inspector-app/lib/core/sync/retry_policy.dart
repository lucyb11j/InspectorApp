import 'dart:math' as math;

/// Estrategias de reintento disponibles para el motor de sincronización.
enum RetryStrategy {
  /// Espera fija entre reintentos (no recomendado para producción).
  fixed,

  /// Espera que se duplica en cada reintento (exponencial base 2).
  exponential,

  /// Exponencial con jitter aleatorio para evitar thundering herd.
  exponentialWithJitter,
}

/// Resultado de una evaluación de política de reintento.
class RetryDecision {
  final bool shouldRetry;
  final Duration delay;
  final String reason;

  const RetryDecision({
    required this.shouldRetry,
    required this.delay,
    required this.reason,
  });

  @override
  String toString() =>
      'RetryDecision(shouldRetry: $shouldRetry, delay: ${delay.inSeconds}s, reason: $reason)';
}

/// Tipos de error que determinan si vale la pena reintentar.
enum SyncErrorType {
  /// Error de red transitorio — siempre reintentable.
  network,

  /// Error HTTP 5xx del servidor — reintentable.
  serverError,

  /// Error HTTP 4xx del cliente (excepto 429) — NO reintentable (bug en cliente).
  clientError,

  /// Rate limit (HTTP 429) — reintentable con backoff extendido.
  rateLimited,

  /// Conflicto de integridad (SHA-256 mismatch) — NO reintentable, requiere intervención.
  integrityConflict,

  /// Error de autenticación — NO reintentable hasta renovar token.
  authError,

  /// Error desconocido — reintentable con cautela.
  unknown,
}

/// Política de reintento para operaciones de sincronización offline.
///
/// Implementa backoff exponencial con jitter para evitar thundering herd.
class RetryPolicy {
  /// Número máximo de reintentos antes de marcar como FAILED.
  final int maxAttempts;

  /// Espera base para el cálculo de backoff.
  final Duration baseDelay;

  /// Espera máxima entre reintentos (cap).
  final Duration maxDelay;

  /// Estrategia de cálculo del intervalo de espera.
  final RetryStrategy strategy;

  /// Factor multiplicador para backoff exponencial (por defecto 2.0).
  final double backoffMultiplier;

  /// Generador de números aleatorios para el jitter.
  final math.Random _random = math.Random();

  RetryPolicy({
    this.maxAttempts = 5,
    this.baseDelay = const Duration(seconds: 2),
    this.maxDelay = const Duration(minutes: 5),
    this.strategy = RetryStrategy.exponentialWithJitter,
    this.backoffMultiplier = 2.0,
  });

  /// Fábrica para reintentos agresivos (red local confiable).
  factory RetryPolicy.aggressive() => RetryPolicy(
        maxAttempts: 10,
        baseDelay: const Duration(milliseconds: 500),
        maxDelay: const Duration(seconds: 30),
        strategy: RetryStrategy.exponential,
      );

  /// Fábrica para reintentos conservadores (conexión móvil inestable).
  factory RetryPolicy.conservative() => RetryPolicy(
        maxAttempts: 3,
        baseDelay: const Duration(seconds: 10),
        maxDelay: const Duration(minutes: 10),
        strategy: RetryStrategy.exponentialWithJitter,
        backoffMultiplier: 3.0,
      );

  /// Determina si una operación debe reintentarse dado el error y el intento actual.
  ///
  /// [attempt] es el número de intento ACTUAL (base 1). Si es 1, es el primer fallo.
  RetryDecision evaluate({
    required int attempt,
    required SyncErrorType errorType,
    String? errorMessage,
  }) {
    // Errores que NUNCA deben reintentarse
    final nonRetryable = {
      SyncErrorType.clientError,
      SyncErrorType.integrityConflict,
      SyncErrorType.authError,
    };

    if (nonRetryable.contains(errorType)) {
      return RetryDecision(
        shouldRetry: false,
        delay: Duration.zero,
        reason: 'Error tipo ${errorType.name} no es reintentable',
      );
    }

    if (attempt >= maxAttempts) {
      return RetryDecision(
        shouldRetry: false,
        delay: Duration.zero,
        reason: 'Máximo de reintentos alcanzado ($maxAttempts)',
      );
    }

    final delay = _calculateDelay(attempt, errorType);

    return RetryDecision(
      shouldRetry: true,
      delay: delay,
      reason: 'Reintento ${attempt + 1}/$maxAttempts en ${delay.inSeconds}s '
          '(estrategia: ${strategy.name})',
    );
  }

  Duration _calculateDelay(int attempt, SyncErrorType errorType) {
    // Rate limit: usar backoff extendido (mínimo 60s)
    if (errorType == SyncErrorType.rateLimited) {
      final extended = Duration(
        seconds: math.min(60 * math.pow(2, attempt - 1).toInt(),
            maxDelay.inSeconds),
      );
      return extended;
    }

    switch (strategy) {
      case RetryStrategy.fixed:
        return _cap(baseDelay);

      case RetryStrategy.exponential:
        final ms = baseDelay.inMilliseconds *
            math.pow(backoffMultiplier, attempt - 1).toInt();
        return _cap(Duration(milliseconds: ms));

      case RetryStrategy.exponentialWithJitter:
        final base = baseDelay.inMilliseconds *
            math.pow(backoffMultiplier, attempt - 1).toDouble();
        // Full jitter: delay ∈ [0, base]
        final jittered = _random.nextDouble() * base;
        return _cap(Duration(milliseconds: jittered.round()));
    }
  }

  Duration _cap(Duration d) =>
      d > maxDelay ? maxDelay : d;

  @override
  String toString() =>
      'RetryPolicy(maxAttempts: $maxAttempts, strategy: ${strategy.name}, '
      'base: ${baseDelay.inSeconds}s, max: ${maxDelay.inSeconds}s)';
}

/// Ejecutor de operaciones con política de reintento integrada.
///
/// Uso:
/// ```dart
/// final result = await RetryExecutor(policy: RetryPolicy()).run(
///   () => syncEngine.uploadEvidence(evidence),
///   classifyError: (e) => SyncErrorType.network,
/// );
/// ```
class RetryExecutor {
  final RetryPolicy policy;
  final void Function(RetryDecision decision, int attempt)? onRetry;

  const RetryExecutor({
    required this.policy,
    this.onRetry,
  });

  /// Ejecuta [operation] con reintentos según la [policy].
  ///
  /// [classifyError] convierte una excepción en [SyncErrorType].
  Future<T> run<T>(
    Future<T> Function() operation, {
    required SyncErrorType Function(Object error) classifyError,
  }) async {
    int attempt = 1;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        final errorType = classifyError(e);
        final decision = policy.evaluate(
          attempt: attempt,
          errorType: errorType,
          errorMessage: e.toString(),
        );

        if (!decision.shouldRetry) rethrow;

        onRetry?.call(decision, attempt);

        if (decision.delay > Duration.zero) {
          await Future.delayed(decision.delay);
        }

        attempt++;
      }
    }
  }
}
