-- Migration: Property Plans and Observation Plan Markers (Phase 2 Architectural Floorplans)

CREATE TABLE IF NOT EXISTS public.property_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    mime_type TEXT NOT NULL DEFAULT 'image/png',
    file_size BIGINT DEFAULT 0,
    sha256 TEXT,
    page_number INTEGER DEFAULT 1,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.observation_plan_markers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id UUID NOT NULL REFERENCES public.observations(id) ON DELETE CASCADE,
    property_plan_id UUID NOT NULL REFERENCES public.property_plans(id) ON DELETE CASCADE,
    x NUMERIC(10,8) NOT NULL, -- Coordenada normalizada entre 0.0 y 1.0
    y NUMERIC(10,8) NOT NULL, -- Coordenada normalizada entre 0.0 y 1.0
    label TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    CHECK (x >= 0 AND x <= 1),
    CHECK (y >= 0 AND y <= 1)
);

-- RLS
ALTER TABLE public.property_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.observation_plan_markers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant Isolation for property_plans" ON public.property_plans
    FOR ALL USING (organization_id = current_user_org_id());

CREATE POLICY "Tenant Isolation for observation_plan_markers" ON public.observation_plan_markers
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.property_plans p
            WHERE p.id = observation_plan_markers.property_plan_id
            AND p.organization_id = current_user_org_id()
        )
    );
