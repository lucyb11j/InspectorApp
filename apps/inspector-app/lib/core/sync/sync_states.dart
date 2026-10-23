enum SyncState {
  local,
  outbox,
  pending,
  synced,
  failed,
  conflict;

  String toDbValue() {
    switch (this) {
      case SyncState.local:
        return 'LOCAL';
      case SyncState.outbox:
        return 'OUTBOX';
      case SyncState.pending:
        return 'PENDING';
      case SyncState.synced:
        return 'SYNCED';
      case SyncState.failed:
        return 'FAILED';
      case SyncState.conflict:
        return 'CONFLICT';
    }
  }

  static SyncState fromDbValue(String value) {
    switch (value.toUpperCase()) {
      case 'LOCAL':
        return SyncState.local;
      case 'OUTBOX':
        return SyncState.outbox;
      case 'PENDING':
        return SyncState.pending;
      case 'SYNCED':
        return SyncState.synced;
      case 'FAILED':
        return SyncState.failed;
      case 'CONFLICT':
        return SyncState.conflict;
      default:
        return SyncState.local;
    }
  }
}
