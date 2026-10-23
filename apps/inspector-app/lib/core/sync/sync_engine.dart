import 'dart:async';
import 'package:crypto/crypto.dart';
import 'outbox_models.dart';

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
  final int maxRetries;

  SyncEngine({
    required this.remoteDataSource,
    this.maxRetries = 3,
  });

  /// Regla de Integridad de Evidencias (Fase 3):
  /// Las fotografías y planos deben cargarse y verificarse primero por SHA-256 en Storage
  /// antes de sincronizar la observación padre, evitando observaciones huérfanas sin fotos.
  Future<bool> processEvidenceItem(OutboxQueueItem evidenceItem) async {
    final localFilePath = evidenceItem.payload['local_file_path'] as String;
    final expectedSha256 = evidenceItem.payload['sha256'] as String;

    try {
      final storagePath = await remoteDataSource.uploadEvidenceBinary(localFilePath, expectedSha256);
      if (storagePath.isNotEmpty) {
        final serverPayload = Map<String, dynamic>.from(evidenceItem.payload);
        serverPayload['storage_path'] = storagePath;
        serverPayload['sync_status'] = 'SYNCED';
        return await remoteDataSource.upsertServerRecord(OutboxEntityType.evidence, serverPayload);
      }
      return false;
    } catch (e) {
      return false;
    }
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
          final success = await processEvidenceItem(item);
          if (success) {
            synced++;
          } else {
            failed++;
            errors.add('Failed to upload evidence binary for id: ${item.entityId}');
          }
          continue;
        }

        // 1. Obtener estado en el servidor para verificar colisiones concurrentes
        final serverRecord = await remoteDataSource.fetchServerRecord(item.entityType, item.entityId);

        if (serverRecord != null) {
          final serverHash = serverRecord['hash'] as String?;
          final localBaseHash = item.stateHash;

          // Conflicto: el registro cambió en el servidor mientras el inspector estaba offline
          if (serverHash != null && serverHash != localBaseHash) {
            conflicts++;
            errors.add('Conflict detected on ${item.entityType.name} id: ${item.entityId}. Server modified independently.');
            continue;
          }
        }

        // 2. Aplicar idempotencia y persistir en servidor
        final success = await remoteDataSource.upsertServerRecord(item.entityType, item.payload);
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
