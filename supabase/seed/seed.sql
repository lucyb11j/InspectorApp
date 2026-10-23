-- ========================================
-- SEED DATA — Plataforma de Inspección Técnica
-- Solo para desarrollo local. NO usar en producción.
-- ========================================

-- 1. Organization
INSERT INTO
    public.organizations (id, name)
VALUES (
        '11111111-0000-0000-0000-000000000001',
        'InspectorHub Demo'
    ),
    (
        '11111111-0000-0000-0000-000000000002',
        'Inmobiliaria Lima Test'
    )
ON CONFLICT (id) DO NOTHING;

-- 2. Projects
INSERT INTO
    public.projects (
        id,
        organization_id,
        name,
        address
    )
VALUES (
        '22222222-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        'Condominio Los Cedros',
        'Av. Javier Prado Este 1234, San Isidro'
    ),
    (
        '22222222-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        'Edificio Miramar',
        'Malecón de la Reserva 456, Miraflores'
    ),
    (
        '22222222-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000002',
        'Torres del Sol',
        'Av. La Marina 789, San Miguel'
    )
ON CONFLICT (id) DO NOTHING;

-- 3. Clients
INSERT INTO
    public.clients (
        id,
        organization_id,
        name,
        email,
        phone
    )
VALUES (
        '33333333-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        'Carlos Mendoza',
        'carlos.mendoza@email.com',
        '+51 987 654 321'
    ),
    (
        '33333333-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        'María Torres',
        'maria.torres@email.com',
        '+51 912 345 678'
    ),
    (
        '33333333-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000001',
        'Jorge Ramírez',
        'jorge.ramirez@email.com',
        '+51 965 432 109'
    )
ON CONFLICT (id) DO NOTHING;

-- 4. Properties (Departments)
INSERT INTO
    public.properties (
        id,
        organization_id,
        project_id,
        client_id,
        unit_number,
        floor_number,
        building
    )
VALUES (
        '44444444-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        '22222222-0000-0000-0000-000000000001',
        '33333333-0000-0000-0000-000000000001',
        '201',
        '2',
        'Torre A'
    ),
    (
        '44444444-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        '22222222-0000-0000-0000-000000000001',
        '33333333-0000-0000-0000-000000000002',
        '305',
        '3',
        'Torre B'
    ),
    (
        '44444444-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000001',
        '22222222-0000-0000-0000-000000000002',
        '33333333-0000-0000-0000-000000000003',
        '1102',
        '11',
        'Único'
    )
ON CONFLICT (id) DO NOTHING;

-- 5. Inspections (varios estados para dashboard realista)
INSERT INTO
    public.inspections (
        id,
        organization_id,
        property_id,
        client_id,
        status,
        scheduled_at
    )
VALUES (
        '55555555-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        '44444444-0000-0000-0000-000000000001',
        '33333333-0000-0000-0000-000000000001',
        'COMPLETED',
        '2026-10-01 09:00:00+00'
    ),
    (
        '55555555-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        '44444444-0000-0000-0000-000000000002',
        '33333333-0000-0000-0000-000000000002',
        'IN_PROGRESS',
        '2026-10-08 10:00:00+00'
    ),
    (
        '55555555-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000001',
        '44444444-0000-0000-0000-000000000003',
        '33333333-0000-0000-0000-000000000003',
        'SCHEDULED',
        '2026-10-12 14:00:00+00'
    ),
    (
        '55555555-0000-0000-0000-000000000004',
        '11111111-0000-0000-0000-000000000001',
        '44444444-0000-0000-0000-000000000001',
        '33333333-0000-0000-0000-000000000001',
        'DRAFT',
        NULL
    )
ON CONFLICT (id) DO NOTHING;

-- 6. Inspection Areas (for completed inspection)
INSERT INTO
    public.inspection_areas (
        id,
        organization_id,
        inspection_id,
        name,
        sync_status
    )
VALUES (
        '66666666-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        'Sala',
        'SYNCED'
    ),
    (
        '66666666-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        'Cocina',
        'SYNCED'
    ),
    (
        '66666666-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        'Dormitorio Principal',
        'SYNCED'
    ),
    (
        '66666666-0000-0000-0000-000000000004',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        'Baño Principal',
        'SYNCED'
    )
ON CONFLICT (id) DO NOTHING;

-- 7. Observations (defects found)
INSERT INTO
    public.observations (
        id,
        organization_id,
        inspection_id,
        area_id,
        title,
        description,
        severity,
        status,
        sync_status
    )
VALUES (
        '77777777-0000-0000-0000-000000000001',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        '66666666-0000-0000-0000-000000000001',
        'Pintura irregular en muro lateral',
        'Se observa variación de tonalidad en muro sur.',
        'MENOR',
        'PENDING',
        'SYNCED'
    ),
    (
        '77777777-0000-0000-0000-000000000002',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        '66666666-0000-0000-0000-000000000002',
        'Junta irregular en cerámico del piso',
        'Junta mayor a 3mm detectada.',
        'MODERADA',
        'EN_CORRECCIÓN',
        'SYNCED'
    ),
    (
        '77777777-0000-0000-0000-000000000003',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        '66666666-0000-0000-0000-000000000003',
        'Puerta de closet con juego excesivo',
        'Holgura superior a tolerancia en puerta de madera.',
        'MENOR',
        'PENDING',
        'SYNCED'
    ),
    (
        '77777777-0000-0000-0000-000000000004',
        '11111111-0000-0000-0000-000000000001',
        '55555555-0000-0000-0000-000000000001',
        '66666666-0000-0000-0000-000000000004',
        'Silicona faltante en encuentro tina-azulejo',
        'Ausencia de sellador en unión baño-tina.',
        'MAYOR',
        'PENDING',
        'SYNCED'
    )
ON CONFLICT (id) DO NOTHING;
-- 0. Auth Users (Para iniciar sesión en desarrollo local)
-- Usuario de prueba:
-- Email: admin@inspector.com
-- Password: password123
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'authenticated',
  'authenticated',
  'admin@inspector.com',
  crypt('password123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Administrador Demo"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Usuario en tabla public.users vinculado a la organización demo
INSERT INTO public.users (id, organization_id, email, role) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'admin@inspector.com', 'ADMIN')
ON CONFLICT (id) DO NOTHING;
