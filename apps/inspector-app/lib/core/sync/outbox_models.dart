enum OutboxStatus {
  local,
  outbox,
  uploading,
  serverAck,
  synced,
  retry,
  conflict,
  failed,
}

enum OutboxEntityType {
  inspection,
  area,
  item,
  observation,
  evidence,
  planMarker,
}

class OutboxQueueItem {
  final String id; // UUID de la operación en cola
  final String organizationId;
  final OutboxEntityType entityType;
  final String entityId;
  final String operation; // INSERT, UPDATE, DELETE
  final Map<String, dynamic> payload;
  final String stateHash; // SHA-256 del registro para detección de conflictos
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  OutboxQueueItem({
    required this.id,
    required this.organizationId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.stateHash,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
}
