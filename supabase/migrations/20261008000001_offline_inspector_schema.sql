-- FASE 2: Inspector Offline-first Schema & Sync Fields

-- Areas
CREATE TABLE public.inspection_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    inspection_id UUID NOT NULL REFERENCES public.inspections(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
    -- Sync fields ready from day 1
    sync_status TEXT NOT NULL DEFAULT 'SYNCED',
    hash TEXT
);

-- Observations
CREATE TABLE public.observations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    inspection_id UUID NOT NULL REFERENCES public.inspections(id) ON DELETE CASCADE,
    area_id UUID NOT NULL REFERENCES public.inspection_areas(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    severity TEXT NOT NULL DEFAULT 'INFO',
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
    -- Sync fields
    sync_status TEXT NOT NULL DEFAULT 'SYNCED',
    hash TEXT
);

-- Evidence (Photos, etc.)
CREATE TABLE public.evidence (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    inspection_id UUID NOT NULL REFERENCES public.inspections(id) ON DELETE CASCADE,
    observation_id UUID REFERENCES public.observations(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    mime_type TEXT,
    size BIGINT,
    sha256 TEXT, -- Validation of exact file
    sequence INTEGER DEFAULT 0,
    captured_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
    -- Sync fields
    sync_status TEXT NOT NULL DEFAULT 'SYNCED',
    hash TEXT
);

-- Enable RLS
ALTER TABLE public.inspection_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.observations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence ENABLE ROW LEVEL SECURITY;

-- Policies for organization isolation
CREATE POLICY "Users can manage areas in same org" ON public.inspection_areas FOR ALL USING (organization_id = current_user_org_id());
CREATE POLICY "Users can manage observations in same org" ON public.observations FOR ALL USING (organization_id = current_user_org_id());
CREATE POLICY "Users can manage evidence in same org" ON public.evidence FOR ALL USING (organization_id = current_user_org_id());

