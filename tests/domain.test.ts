import { describe, it, expect } from 'vitest';
import type { Inspection, Observation, ServiceType } from '@inspector/shared-types';

describe('Domain Models & Contracts Integrity', () => {
  it('validates inspection structure conforming to database schema', () => {
    const inspection: Inspection = {
      id: '55555555-0000-0000-0000-000000000001',
      organization_id: '11111111-0000-0000-0000-000000000001',
      property_id: '44444444-0000-0000-0000-000000000001',
      status: 'IN_PROGRESS',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    expect(inspection.status).toBe('IN_PROGRESS');
    expect(inspection.organization_id).toBeDefined();
  });

  it('validates observation offline synchronization fields', () => {
    const obs: Observation = {
      id: '77777777-0000-0000-0000-000000000001',
      organization_id: '11111111-0000-0000-0000-000000000001',
      inspection_id: '55555555-0000-0000-0000-000000000001',
      title: 'Fisura en tabique',
      severity: 'MODERADA',
      status: 'PENDING',
      sync_status: 'SYNCED',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    expect(obs.sync_status).toBe('SYNCED');
    expect(obs.severity).toBe('MODERADA');
  });

  it('validates service_type pricing and duration', () => {
    const service: ServiceType = {
      id: '99999999-0000-0000-0000-000000000001',
      organization_id: '11111111-0000-0000-0000-000000000001',
      name: 'Inspección Entrega Departamento',
      base_price: 350.00,
      duration_minutes: 120,
      active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    expect(service.base_price).toBeGreaterThan(0);
    expect(service.duration_minutes).toBe(120);
  });
});
