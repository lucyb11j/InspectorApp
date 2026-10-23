enum SyncStatus {
  synced,
  pendingSync,
  syncing,
  conflict,
  failed,
}

enum SyncOperation {
  insert,
  update,
  delete,
}

class SyncQueueItem {
  final String id;
  final String tableName;
  final String recordId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final String sha256Hash;
  final int retryCount;
  final DateTime createdAt;

  SyncQueueItem({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.operation,
    required this.payload,
    required this.sha256Hash,
    this.retryCount = 0,
    required this.createdAt,
  });
}

class SyncConflict {
  final String tableName;
  final String recordId;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> serverData;
  final DateTime detectedAt;

  SyncConflict({
    required this.tableName,
    required this.recordId,
    required this.clientData,
    required this.serverData,
    required this.detectedAt,
  });
}
