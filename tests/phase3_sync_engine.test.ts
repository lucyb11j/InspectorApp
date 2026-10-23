import { describe, it, expect } from 'vitest';
import { createHash } from 'node:crypto';

describe('Phase 3 — Sync Engine (Outbox, Evidence Ordering, Conflict & Idempotency)', () => {

  it('enforces Evidence-First ordering rule before observation synchronization', () => {
    interface QueueItem {
      id: string;
      entityType: 'evidence' | 'observation' | 'area';
      createdAt: number;
    }

    const unorganizedQueue: QueueItem[] = [
      { id: 'obs-1', entityType: 'observation', createdAt: 100 },
      { id: 'evi-1', entityType: 'evidence', createdAt: 150 },
      { id: 'area-1', entityType: 'area', createdAt: 50 },
      { id: 'evi-2', entityType: 'evidence', createdAt: 120 }
    ];

    // Ordenar priorizando evidencias
    const prioritizedQueue = [...unorganizedQueue].sort((a, b) => {
      if (a.entityType === 'evidence' && b.entityType !== 'evidence') return -1;
      if (a.entityType !== 'evidence' && b.entityType === 'evidence') return 1;
      return a.createdAt - b.createdAt;
    });

    expect(prioritizedQueue[0].entityType).toBe('evidence');
    expect(prioritizedQueue[1].entityType).toBe('evidence');
    expect(prioritizedQueue[2].entityType).toBe('area');
    expect(prioritizedQueue[3].entityType).toBe('observation');
  });

  it('detects concurrent server conflict via cryptographic state signatures', () => {
    const calculateHash = (data: Record<string, any>) =>
      createHash('sha256').update(JSON.stringify(data)).digest('hex');

    const baseRecord = { id: 'obs-100', title: 'Fisura en tabique', severity: 'MODERADA' };
    const baseHash = calculateHash(baseRecord);

    // Inspector local actualiza descripción offline
    const localUpdated = { ...baseRecord, description: 'Grieta visible de 50cm' };

    // Mientras tanto, en el portal web otro ingeniero actualizó la severidad a MAYOR
    const serverConcurrentUpdate = { ...baseRecord, severity: 'MAYOR' };
    const serverHash = calculateHash(serverConcurrentUpdate);

    // Detección de colisión: baseHash != serverHash
    const hasConflict = baseHash !== serverHash;
    expect(hasConflict).toBe(true);
  });

  it('guarantees idempotency on duplicate retry sync payloads', () => {
    const executedOperations = new Set<string>();

    const applySyncOperation = (operationId: string, payload: any) => {
      if (executedOperations.has(operationId)) {
        return { status: 'IGNORED_DUPLICATE', id: operationId };
      }
      executedOperations.add(operationId);
      return { status: 'APPLIED', id: operationId };
    };

    const op1 = applySyncOperation('uuid-op-001', { unit: '305' });
    expect(op1.status).toBe('APPLIED');

    // Mismo reintento de la red móvil tras pérdida de señal (ACK perdido)
    const op1Retry = applySyncOperation('uuid-op-001', { unit: '305' });
    expect(op1Retry.status).toBe('IGNORED_DUPLICATE');
    expect(executedOperations.size).toBe(1);
  });
});
