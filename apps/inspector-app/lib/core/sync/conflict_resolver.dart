import 'package:inspector_app/core/sync/sync_states.dart';

/// Estrategias de resolución de conflictos.
enum ConflictStrategy {
  /// El registro con mayor `updated_at` gana.
  lastWriteWins,

  /// El servidor siempre gana (ignora cambios del cliente).
  serverWins,

  /// El cliente siempre gana (sobrescribe al servidor).
  clientWins,

  /// Requiere intervención manual del operador.
  manual,
}

/// Representa un conflicto detectado entre la versión del cliente y del servidor.
class SyncConflict<T> {
  final String entityType;
  final String entityId;
  final T clientVersion;
  final T serverVersion;
  final DateTime clientUpdatedAt;
  final DateTime serverUpdatedAt;
  final String? conflictReason;

  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.clientVersion,
    required this.serverVersion,
    required this.clientUpdatedAt,
    required this.serverUpdatedAt,
    this.conflictReason,
  });
}

/// Resultado de la resolución de un conflicto.
class ConflictResolution<T> {
  final T resolvedEntity;
  final ConflictStrategy strategyUsed;
  final String description;
  final bool requiresManualReview;

  const ConflictResolution({
    required this.resolvedEntity,
    required this.strategyUsed,
    required this.description,
    this.requiresManualReview = false,
  });
}

/// Resuelve conflictos de sincronización entre versiones cliente y servidor.
///
/// Implementa múltiples estrategias según el tipo de entidad y el contexto.
/// La estrategia por defecto es [ConflictStrategy.lastWriteWins].
class ConflictResolver {
  final ConflictStrategy defaultStrategy;

  /// Mapa de estrategias por tipo de entidad.
  /// Si no se especifica para un tipo, se usa [defaultStrategy].
  final Map<String, ConflictStrategy> entityStrategies;

  const ConflictResolver({
    this.defaultStrategy = ConflictStrategy.lastWriteWins,
    this.entityStrategies = const {},
  });

  /// Fábrica: configuración recomendada para inspecciones técnicas.
  ///
  /// - Evidencias: server wins (la evidencia ya subida al servidor es canónica)
  /// - Observaciones: last write wins (el inspector tiene la última palabra en campo)
  /// - Otros: last write wins
  factory ConflictResolver.forInspections() {
    return const ConflictResolver(
      defaultStrategy: ConflictStrategy.lastWriteWins,
      entityStrategies: {
        'evidence': ConflictStrategy.serverWins,
        'inspection': ConflictStrategy.lastWriteWins,
        'observation': ConflictStrategy.lastWriteWins,
        'area': ConflictStrategy.lastWriteWins,
        'marker': ConflictStrategy.lastWriteWins,
      },
    );
  }

  /// Resuelve un conflicto retornando la versión ganadora.
  ///
  /// [toMap] y [fromMap] permiten la serialización genérica de la entidad.
  ConflictResolution<T> resolve<T>({
    required SyncConflict<T> conflict,
    Map<String, dynamic> Function(T entity)? toMap,
    T Function(Map<String, dynamic> map)? fromMap,
  }) {
    final strategy = entityStrategies[conflict.entityType] ?? defaultStrategy;

    switch (strategy) {
      case ConflictStrategy.lastWriteWins:
        return _resolveLastWriteWins(conflict);

      case ConflictStrategy.serverWins:
        return ConflictResolution(
          resolvedEntity: conflict.serverVersion,
          strategyUsed: strategy,
          description: 'Servidor gana: versión del servidor preservada para '
              '${conflict.entityType}#${conflict.entityId}',
        );

      case ConflictStrategy.clientWins:
        return ConflictResolution(
          resolvedEntity: conflict.clientVersion,
          strategyUsed: strategy,
          description: 'Cliente gana: cambios del inspector aplicados para '
              '${conflict.entityType}#${conflict.entityId}',
        );

      case ConflictStrategy.manual:
        // En modo manual, se elige server por defecto pero marca para revisión.
        return ConflictResolution(
          resolvedEntity: conflict.serverVersion,
          strategyUsed: strategy,
          description: 'Conflicto en ${conflict.entityType}#${conflict.entityId} '
              'requiere resolución manual por el administrador.',
          requiresManualReview: true,
        );
    }
  }

  ConflictResolution<T> _resolveLastWriteWins<T>(SyncConflict<T> conflict) {
    final clientWins =
        conflict.clientUpdatedAt.isAfter(conflict.serverUpdatedAt);

    return ConflictResolution(
      resolvedEntity:
          clientWins ? conflict.clientVersion : conflict.serverVersion,
      strategyUsed: ConflictStrategy.lastWriteWins,
      description: clientWins
          ? 'LWW: cliente gana (${conflict.clientUpdatedAt.toIso8601String()} '
              '> ${conflict.serverUpdatedAt.toIso8601String()})'
          : 'LWW: servidor gana (${conflict.serverUpdatedAt.toIso8601String()} '
              '>= ${conflict.clientUpdatedAt.toIso8601String()})',
    );
  }

  /// Detecta si hay un conflicto entre versiones cliente y servidor.
  ///
  /// Retorna true si los `updated_at` difieren Y el servidor fue modificado
  /// DESPUÉS del último sync conocido del cliente.
  bool hasConflict({
    required DateTime clientUpdatedAt,
    required DateTime serverUpdatedAt,
    required DateTime? lastSyncedAt,
  }) {
    if (lastSyncedAt == null) return false;

    // Conflicto si el servidor fue modificado después del último sync del cliente
    // Y el cliente también tiene cambios posteriores al último sync.
    final serverModifiedAfterSync = serverUpdatedAt.isAfter(lastSyncedAt);
    final clientModifiedAfterSync = clientUpdatedAt.isAfter(lastSyncedAt);

    return serverModifiedAfterSync && clientModifiedAfterSync &&
        clientUpdatedAt != serverUpdatedAt;
  }
}
