-- Migration: Add category, subcategory and location_details to observations
ALTER TABLE public.observations 
ADD COLUMN IF NOT EXISTS category TEXT,
ADD COLUMN IF NOT EXISTS subcategory TEXT,
ADD COLUMN IF NOT EXISTS location_details TEXT;

COMMENT ON COLUMN public.observations.category IS 'Especialidad principal técnica del checklist (ej: Arquitectura y acabados)';
COMMENT ON COLUMN public.observations.subcategory IS 'Componente o subcategoría técnica evaluada (ej: Paredes y muros, Pintura)';
COMMENT ON COLUMN public.observations.location_details IS 'Descripción adicional de la ubicación física en el ambiente';
