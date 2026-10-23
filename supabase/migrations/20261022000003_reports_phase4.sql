-- ============================================================
-- Fase 4 — Reports: plantillas, generación y exportación
-- ============================================================

-- Plantillas de informe reutilizables por organización
CREATE TABLE IF NOT EXISTS report_templates (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id   UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  description       TEXT,
  template_type     TEXT NOT NULL CHECK (template_type IN ('INSPECTION','AREA','CONSOLIDATED','CUSTOM')),
  config            JSONB NOT NULL DEFAULT '{}', -- secciones, encabezados, firmas, logo, etc.
  is_default        BOOLEAN NOT NULL DEFAULT FALSE,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_by        UUID REFERENCES auth.users(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trabajos de generación/exportación de informes
CREATE TABLE IF NOT EXISTS report_jobs (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id   UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  inspection_id     UUID REFERENCES inspections(id) ON DELETE SET NULL,
  template_id       UUID REFERENCES report_templates(id) ON DELETE SET NULL,
  requested_by      UUID REFERENCES auth.users(id),
  status            TEXT NOT NULL DEFAULT 'QUEUED'
                    CHECK (status IN ('QUEUED','PROCESSING','COMPLETED','FAILED','CANCELLED')),
  format            TEXT NOT NULL CHECK (format IN ('PDF','DOCX','HTML','CSV','JSON')),
  file_path         TEXT,
  file_size_bytes   BIGINT,
  sha256            TEXT,
  error_message     TEXT,
  metadata          JSONB DEFAULT '{}',
  started_at        TIMESTAMPTZ,
  completed_at      TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Firmas/actas asociadas a un informe
CREATE TABLE IF NOT EXISTS report_signatures (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_job_id     UUID NOT NULL REFERENCES report_jobs(id) ON DELETE CASCADE,
  signer_user_id    UUID REFERENCES auth.users(id),
  signer_name       TEXT NOT NULL,
  signer_role       TEXT,
  signature_data    TEXT, -- base64 PNG/SVG
  signed_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip_address        INET,
  geo_lat           DOUBLE PRECISION,
  geo_lng           DOUBLE PRECISION
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_report_templates_org ON report_templates(organization_id, is_active);
CREATE INDEX IF NOT EXISTS idx_report_jobs_org_status ON report_jobs(organization_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_report_jobs_inspection ON report_jobs(inspection_id);
CREATE INDEX IF NOT EXISTS idx_report_signatures_job ON report_signatures(report_job_id);

-- RLS
ALTER TABLE report_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_signatures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "org_report_templates_isolation"
  ON report_templates FOR ALL
  USING (organization_id = current_user_org_id());

CREATE POLICY "org_report_jobs_isolation"
  ON report_jobs FOR ALL
  USING (organization_id = current_user_org_id());

CREATE POLICY "org_report_signatures_isolation"
  ON report_signatures FOR ALL
  USING (EXISTS (
    SELECT 1 FROM report_jobs j
    WHERE j.id = report_signatures.report_job_id
      AND j.organization_id = current_user_org_id()
  ));

-- Trigger updated_at
CREATE OR REPLACE FUNCTION update_report_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_report_templates_updated_at
  BEFORE UPDATE ON report_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_report_templates_updated_at();

COMMENT ON TABLE report_templates IS 'Plantillas configurables para generación de informes por organización.';
COMMENT ON TABLE report_jobs IS 'Cola de trabajos de exportación/generación de informes (PDF/DOCX).';
COMMENT ON TABLE report_signatures IS 'Firmas digitales/actas asociadas a informes generados.';
