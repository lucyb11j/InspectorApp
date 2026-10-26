-- Migration: Add measurement fields to observations
ALTER TABLE public.observations 
ADD COLUMN IF NOT EXISTS has_measurements BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS measured_value TEXT,
ADD COLUMN IF NOT EXISTS measurement_unit TEXT,
ADD COLUMN IF NOT EXISTS instrument_used TEXT;

COMMENT ON COLUMN public.observations.has_measurements IS 'Indica si la observación técnica incluye medición cuantitativa instrumental';
COMMENT ON COLUMN public.observations.measured_value IS 'Valor numérico medido (ej: 0.4, 2.5, 224)';
COMMENT ON COLUMN public.observations.measurement_unit IS 'Unidad de medida (ej: mm, cm, V, Ω, %, lux)';
COMMENT ON COLUMN public.observations.instrument_used IS 'Instrumento técnico empleado (ej: Fisurometro / Ictiómetro, Nivel láser, Multímetro digital, Calibrador vernier)';

