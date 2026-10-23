import 'dart:async';
import 'package:crypto/crypto.dart';

import 'conflict_resolver.dart';
import 'outbox_models.dart';
import 'retry_policy.dart';
import 'sync_states.dart';

class SyncResult {
  final int processedCount;
  final int syncedCount;
  final int conflictCount;
  final int failedCount;
  final List<String> errors;

  SyncResult({
    required this.processedCount,
    required this.syncedCount,
    required this.conflictCount,
    required this.failedCount,
    required this.errors,
  });
}

abstract class RemoteSyncDataSource {
  Future<Map<String, dynamic>?> fetchServerRecord(OutboxEntityType entityType, String entityId);
  Future<String> uploadEvidenceBinary(String filePath, String expectedSha256);
  Future<bool> upsertServerRecord(OutboxEntityType entityType, Map<String, dynamic> payload);
}

class SyncEngine {
  final RemoteSyncDataSource remoteDataSource;
  final RetryPolicy retryPolicy;
  final ConflictResolver conflictResolver;
  final int maxRetries;

  SyncEngine({
    required this.remoteDataSource,
    RetryPolicy? retryPolicy,
    ConflictResolver? conflictResolver,
    this.maxRetries = 3,
  })  : retryPolicy = retryPolicy ?? RetryPolicy(),
        conflictResolver = conflictResolver ?? ConflictResolver.forInspections();

  /// Regla de Integridad de Evidencias (Fase 3):
  /// Las fotografías y planos deben cargarse y verificarse primero por SHA-256 en Storage
  /// antes de sincronizar la observación padre, evitando observaciones huérfanas sin fotos.
  Future<bool> processEvidenceItem(OutboxQueueItem evidenceItem) async {
    final localFilePath = evidenceItem.payload['local_file_path'] as String?;
    final expectedSha256 = evidenceItem.payload['sha256'] as String?;

    if (localFilePath == null || expectedSha256 == null) {
      return false;
    }

    try {
      final storagePath = await remoteDataSource.uploadEvidenceBinary(localFilePath, expectedSha256);
      if (storagePath.isNotEmpty) {
        final serverPayload = Map<String, dynamic>.from(evidenceItem.payload);
        serverPayload['storage_path'] = storagePath;
        serverPayload['sync_status'] = SyncState.synced.toDbValue();
        return await remoteDataSource.upsertServerRecord(OutboxEntityType.evidence, serverPayload);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  SyncErrorType _classifyError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('socket') || msg.contains('network') || msg.contains('connection')) {
      return SyncErrorType.network;
    }
    if (msg.contains('429') || msg.contains('rate')) {
      return SyncErrorType.rateLimited;
    }
    if (msg.contains('401') || msg.contains('403') || msg.contains('auth')) {
      return SyncErrorType.authError;
    }
    if (msg.contains('sha') || msg.contains('integrity')) {
      return SyncErrorType.integrityConflict;
    }
    if (msg.contains('500') || msg.contains('502') || msg.contains('503') || msg.contains('504')) {
      return SyncErrorType.serverError;
    }
    if (msg.contains('400') || msg.contains('404') || msg.contains('422')) {
      return SyncErrorType.clientError;
    }
    return SyncErrorType.unknown;
  }

  /// Procesa un lote de la cola Outbox con detección estricta de conflictos (sin sobrescritura silenciosa)
  Future<SyncResult> processQueue(List<OutboxQueueItem> queue) async {
    int synced = 0;
    int conflicts = 0;
    int failed = 0;
    final List<String> errors = [];

    // Priorizar evidencias primero para garantizar integridad relacional
    final sortedQueue = List<OutboxQueueItem>.from(queue)
      ..sort((a, b) {
        if (a.entityType == OutboxEntityType.evidence && b.entityType != OutboxEntityType.evidence) return -1;
        if (a.entityType != OutboxEntityType.evidence && b.entityType == OutboxEntityType.evidence) return 1;
        return a.createdAt.compareTo(b.createdAt);
      });

    for (final item in sortedQueue) {
      try {
        if (item.entityType == OutboxEntityType.evidence) {
          final success = await RetryExecutor(policy: retryPolicy).run(
            () => processEvidenceItem(item),
            classifyError: _classifyError,
          );
          if (success) {
            synced++;
          } else {
            failed++;
            errors.add('Failed to upload evidence binary for id: ${item.entityId}');
          }
          continue;
        }

        // 1. Obtener estado en el servidor para verificar colisiones concurrentes
        final serverRecord = await RetryExecutor(policy: retryPolicy).run(
          () => remoteDataSource.fetchServerRecord(item.entityType, item.entityId),
          classifyError: _classifyError,
        );

        if (serverRecord != null) {
          final serverHash = serverRecord['hash'] as String?;
          final localBaseHash = item.stateHash;
          final serverUpdatedAt = DateTime.tryParse(serverRecord['updated_at']?.toString() ?? '');
          final clientUpdatedAt = DateTime.tryParse(item.payload['updated_at']?.toString() ?? '') ?? item.updatedAt;
          final lastSyncedAt = DateTime.tryParse(item.payload['last_synced_at']?.toString() ?? '');

          // Conflicto: el registro cambió en el servidor mientras el inspector estaba offline
          if (serverHash != null && serverHash != localBaseHash) {
            // Intentar resolver con ConflictResolver si hay timestamps
            if (serverUpdatedAt != null) {
              final conflict = SyncConflict<Map<String, dynamic>>(
                entityType: item.entityType.name,
                entityId: item.entityId,
                clientVersion: item.payload,
                serverVersion: serverRecord,
                clientUpdatedAt: clientUpdatedAt,
                serverUpdatedAt: serverUpdatedAt,
                conflictReason: 'Hash mismatch: server modified independently',
              );
              if (conflictResolver.hasConflict(
                clientUpdatedAt: clientUpdatedAt,
                serverUpdatedAt: serverUpdatedAt,
                lastSyncedAt: lastSyncedAt,
              )) {
                conflictResolver.resolve(conflict: conflict);
                conflicts++;
                errors.add('Conflict resolved by ${conflictResolver.defaultStrategy.name} on ${item.entityType.name} id: ${item.entityId}.');
                // Aplicar resolución según estrategia (por defecto LWW aplica automáticamente)
                final resolution = conflictResolver.resolve(conflict: conflict);
                if (resolution.requiresManualReview) {
                  conflicts++;
                  errors.add('Manual review required for ${item.entityType.name} id: ${item.entityId}.');
                  continue;
                }
                // Para serverWins/clientWins/LWW ya resuelto arriba conceptualmente; aplicar payload resuelto
                final resolvedPayload = resolution.resolvedEntity;
                final success = await RetryExecutor(policy: retryPolicy).run(
                  () => remoteDataSource.upsertServerRecord(item.entityType, resolvedPayload),
                  classifyError: _classifyError,
                );
                if (success) {
                  synced++;
                } else {
                  failed++;
                }
                continue;
              }
            }
            conflicts++;
            errors.add('Conflict detected on ${item.entityType.name} id: ${item.entityId}. Server modified independently.');
            continue;
          }
        }

        // 2. Aplicar idempotencia y persistir en servidor
        final success = await RetryExecutor(policy: retryPolicy).run(
          () => remoteDataSource.upsertServerRecord(item.entityType, item.payload),
          classifyError: _classifyError,
        );
        if (success) {
          synced++;
        } else {
          failed++;
        }
      } catch (e) {
        failed++;
        errors.add('Sync error on ${item.entityId}: $e');
      }
    }

    return SyncResult(
      processedCount: queue.length,
      syncedCount: synced,
      conflictCount: conflicts,
      failedCount: failed,
      errors: errors,
    );
  }
}
