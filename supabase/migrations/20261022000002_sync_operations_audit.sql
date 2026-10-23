-- ============================================================
-- Fase 3 — Sync Engine: Audit log de operaciones de sincronización
-- ============================================================

-- Tabla de operaciones de sincronización (lado servidor)
CREATE TABLE IF NOT EXISTS sync_operations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  device_id       TEXT NOT NULL,
  entity_type     TEXT NOT NULL CHECK (entity_type IN ('inspection','area','observation','evidence','marker')),
  entity_id       UUID NOT NULL,
  operation       TEXT NOT NULL CHECK (operation IN ('INSERT','UPDATE','UPSERT','DELETE')),
  idempotency_key TEXT NOT NULL,
  payload_hash    TEXT,            -- SHA-256 del payload JSON recibido
  status          TEXT NOT NULL DEFAULT 'RECEIVED'
                   CHECK (status IN ('RECEIVED','PROCESSING','ACCEPTED','REJECTED','CONFLICT')),
  conflict_reason TEXT,
  server_version  INTEGER,
  client_version  INTEGER,
  processed_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice único para garantizar idempotencia: mismo idempotency_key nunca se procesa dos veces
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_ops_idempotency
  ON sync_operations (organization_id, idempotency_key);

-- Índice para consultas por entidad
CREATE INDEX IF NOT EXISTS idx_sync_ops_entity
  ON sync_operations (organization_id, entity_type, entity_id);

-- Índice para el monitor de sync en tiempo real
CREATE INDEX IF NOT EXISTS idx_sync_ops_status_created
  ON sync_operations (organization_id, status, created_at DESC);

-- ----------------------------------------
-- Tabla de conflictos de sincronización
-- ----------------------------------------
CREATE TABLE IF NOT EXISTS sync_conflicts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  sync_op_id      UUID NOT NULL REFERENCES sync_operations(id),
  entity_type     TEXT NOT NULL,
  entity_id       UUID NOT NULL,
  strategy        TEXT NOT NULL CHECK (strategy IN ('LAST_WRITE_WINS','MANUAL','SERVER_WINS','CLIENT_WINS')),
  client_payload  JSONB,
  server_payload  JSONB,
  resolution      TEXT CHECK (resolution IN ('PENDING','RESOLVED_CLIENT','RESOLVED_SERVER','RESOLVED_MERGE')),
  resolved_by     UUID REFERENCES auth.users(id),
  resolved_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sync_conflicts_entity
  ON sync_conflicts (organization_id, entity_type, entity_id);

CREATE INDEX IF NOT EXISTS idx_sync_conflicts_unresolved
  ON sync_conflicts (organization_id, resolution)
  WHERE resolution = 'PENDING';

-- ----------------------------------------
-- RLS
-- ----------------------------------------
ALTER TABLE sync_operations ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_conflicts  ENABLE ROW LEVEL SECURITY;

-- Solo el miembro de la misma organización puede ver sus sync_ops
CREATE POLICY "org_sync_ops_isolation"
  ON sync_operations FOR ALL
  USING (organization_id = current_user_org_id());

CREATE POLICY "org_sync_conflicts_isolation"
  ON sync_conflicts FOR ALL
  USING (organization_id = current_user_org_id());

-- ----------------------------------------
-- Función helper: registrar operación sync (idempotente)
-- ----------------------------------------
CREATE OR REPLACE FUNCTION register_sync_operation(
  p_org_id         UUID,
  p_device_id      TEXT,
  p_entity_type    TEXT,
  p_entity_id      UUID,
  p_operation      TEXT,
  p_idempotency_key TEXT,
  p_payload_hash   TEXT DEFAULT NULL,
  p_client_version INTEGER DEFAULT NULL
)
RETURNS TABLE(op_id UUID, was_duplicate BOOLEAN)
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_id UUID;
  v_dup BOOLEAN := FALSE;
BEGIN
  INSERT INTO sync_operations(
    organization_id, device_id, entity_type, entity_id,
    operation, idempotency_key, payload_hash, status, client_version
  )
  VALUES (
    p_org_id, p_device_id, p_entity_type, p_entity_id,
    p_operation, p_idempotency_key, p_payload_hash, 'RECEIVED', p_client_version
  )
  ON CONFLICT (organization_id, idempotency_key) DO NOTHING
  RETURNING id INTO v_id;

  IF v_id IS NULL THEN
    -- Ya existía — retornar el existente
    SELECT id INTO v_id FROM sync_operations
     WHERE organization_id = p_org_id AND idempotency_key = p_idempotency_key;
    v_dup := TRUE;
  END IF;

  RETURN QUERY SELECT v_id, v_dup;
END;
$$;

COMMENT ON TABLE sync_operations IS 'Audit log de todas las operaciones de sincronización recibidas del cliente móvil.';
COMMENT ON TABLE sync_conflicts  IS 'Registro de conflictos detectados durante la sincronización con su estrategia de resolución.';
