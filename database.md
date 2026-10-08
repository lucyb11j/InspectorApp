# DATABASE.md

# Diseño Detallado de Base de Datos

**Proyecto:** Inspection Platform  
**Versión:** 1.0  
**Estado:** Diseño técnico  
**Motor:** PostgreSQL 16+  
**Proveedor inicial:** Supabase  
**ORM / acceso:** Supabase API / SQL / servicios backend  
**Mobile local DB:** SQLite + Drift  
**Multi-tenancy:** `organization_id` + PostgreSQL Row Level Security  
**Identificadores:** UUID  
**Zona horaria:** UTC en almacenamiento; conversión a zona local en interfaz

---

# 1. Objetivo

Este documento define el diseño de base de datos de la plataforma de inspección técnica de departamentos.

La base de datos debe soportar:

- organizaciones;
- usuarios;
- roles;
- clientes;
- proyectos;
- edificios;
- pisos;
- departamentos;
- planos;
- agenda;
- servicios y planes;
- inspecciones;
- plantillas;
- áreas;
- checklists;
- observaciones;
- mediciones;
- evidencias;
- acciones de corrección;
- reinspecciones;
- informes;
- portal del cliente;
- auditoría;
- sincronización offline;
- tareas de IA;
- revisión contractual futura.

El diseño debe permitir comenzar con un MVP pequeño y crecer posteriormente hacia un SaaS multiempresa.

---

# 2. Principios de diseño

## 2.1 PostgreSQL como fuente de verdad

La base PostgreSQL representa el estado oficial de la plataforma.

```text
Flutter / SQLite
       │
       │ sync
       ▼
PostgreSQL
       │
       ├── Web Admin
       ├── Client Portal
       └── Reports
```

---

## 2.2 Multi-tenancy

Toda entidad perteneciente a una organización deberá estar relacionada con:

```text
organization_id UUID
```

La separación entre organizaciones se aplicará mediante:

- `organization_id`;
- foreign keys;
- Row Level Security;
- autorización a nivel de aplicación;
- validaciones de ownership.

---

## 2.3 UUID

Las entidades principales utilizarán UUID.

Ventajas:

- generación offline;
- menor dependencia de secuencias;
- sincronización más sencilla;
- menor riesgo de colisiones entre dispositivos;
- identificación distribuida.

---

## 2.4 Timestamps

Las fechas de sistema utilizarán:

```sql
TIMESTAMPTZ
```

Ejemplo:

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT now()
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
```

Las fechas y horas de citas se almacenarán de forma consistente y se convertirán a la zona horaria correspondiente en la interfaz.

---

## 2.5 Soft Delete

Las entidades importantes no deben eliminarse físicamente cuando exista trazabilidad histórica.

Cuando corresponda:

```sql
deleted_at TIMESTAMPTZ
```

El borrado físico estará reservado principalmente para datos temporales o procesos administrativos controlados.

---

# 3. Convenciones de nombres

Tablas:

```text
snake_case
plural
```

Ejemplos:

```text
organizations
projects
inspections
observations
```

Columnas:

```text
snake_case
```

Primary key:

```text
id
```

Foreign key:

```text
<entity>_id
```

Ejemplos:

```text
organization_id
inspection_id
observation_id
```

---

# 4. Arquitectura lógica

```text
ORGANIZATION
     │
     ├── USERS
     ├── CLIENTS
     ├── PROJECTS
     │      │
     │      └── BUILDINGS
     │             │
     │             └── FLOORS
     │                    │
     │                    └── PROPERTIES
     │
     ├── SERVICE_TYPES
     ├── APPOINTMENTS
     │
     ├── INSPECTION_TEMPLATES
     │
     └── INSPECTIONS
              │
              ├── INSPECTION_AREAS
              │
              ├── INSPECTION_ITEMS
              │
              ├── OBSERVATIONS
              │      │
              │      ├── EVIDENCE
              │      ├── MEASUREMENTS
              │      └── ACTIONS
              │             │
              │             └── REINSPECTIONS
              │
              ├── PLANS
              │
              └── REPORTS
```

---

# 5. Entity Relationship Overview

```text
organizations
    │
    ├── users
    ├── clients
    ├── projects
    ├── service_types
    ├── appointments
    ├── inspection_templates
    ├── inspections
    └── audit_logs

projects
    │
    └── buildings
          │
          └── floors
                │
                └── properties
                      │
                      ├── property_plans
                      └── inspections

appointments
    │
    └── inspections

inspections
    │
    ├── inspection_areas
    ├── inspection_items
    ├── observations
    ├── measurements
    ├── evidence
    ├── reports
    └── reinspections

observations
    │
    ├── evidence
    ├── measurements
    └── actions

actions
    │
    └── reinspections
```

---

# 6. ENUM Types

Se recomienda utilizar PostgreSQL ENUM únicamente para estados relativamente estables.

Valores que pueden cambiar por configuración de negocio deberán utilizar tablas de configuración.

---

## 6.1 User Role

```sql
CREATE TYPE user_role AS ENUM (
    'OWNER',
    'ADMIN',
    'INSPECTOR',
    'CLIENT'
);
```

---

## 6.2 Appointment Status

```sql
CREATE TYPE appointment_status AS ENUM (
    'REQUESTED',
    'PENDING_CONFIRMATION',
    'CONFIRMED',
    'RESCHEDULE_REQUESTED',
    'RESCHEDULED',
    'CANCELLED',
    'COMPLETED',
    'NO_SHOW'
);
```

---

## 6.3 Payment Status

```sql
CREATE TYPE payment_status AS ENUM (
    'UNPAID',
    'PAYMENT_PENDING',
    'PAID',
    'REFUNDED',
    'NOT_REQUIRED'
);
```

El MVP no procesa pagos online.

---

## 6.4 Inspection Status

```sql
CREATE TYPE inspection_status AS ENUM (
    'DRAFT',
    'SCHEDULED',
    'IN_PROGRESS',
    'PAUSED',
    'COMPLETED',
    'REVIEW',
    'PUBLISHED',
    'CANCELLED'
);
```

---

## 6.5 Observation Severity

```sql
CREATE TYPE observation_severity AS ENUM (
    'INFO',
    'MENOR',
    'MODERADA',
    'MAYOR',
    'CRITICA'
);
```

Esta escala es propia de la plataforma y no representa una certificación normativa.

---

## 6.6 Observation Status

```sql
CREATE TYPE observation_status AS ENUM (
    'OPEN',
    'IN_CORRECTION',
    'CORRECTED',
    'REJECTED',
    'VERIFIED',
    'CLOSED'
);
```

---

## 6.7 Checklist Result

```sql
CREATE TYPE checklist_result AS ENUM (
    'OK',
    'OBSERVATION',
    'NOT_APPLICABLE',
    'NOT_VERIFIED'
);
```

---

## 6.8 Action Status

```sql
CREATE TYPE action_status AS ENUM (
    'PENDING',
    'IN_CORRECTION',
    'CORRECTED',
    'REJECTED',
    'VERIFIED',
    'CLOSED'
);
```

---

## 6.9 Report Status

```sql
CREATE TYPE report_status AS ENUM (
    'DRAFT',
    'GENERATED',
    'REVIEWED',
    'PUBLISHED',
    'SUPERSEDED'
);
```

---

## 6.10 Sync Status

```sql
CREATE TYPE sync_status AS ENUM (
    'PENDING',
    'UPLOADING',
    'SYNCED',
    'FAILED',
    'CONFLICT'
);
```

---

## 6.11 Evidence Type

```sql
CREATE TYPE evidence_type AS ENUM (
    'PHOTO',
    'VIDEO',
    'DOCUMENT',
    'MEASUREMENT'
);
```

---

# 7. organizations

Representa cada empresa o tenant de la plataforma.

```sql
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name TEXT NOT NULL,
    legal_name TEXT,
    tax_id TEXT,

    email TEXT,
    phone TEXT,

    address TEXT,
    city TEXT,
    country TEXT DEFAULT 'PE',

    timezone TEXT NOT NULL DEFAULT 'America/Lima',

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_organizations_active
ON organizations(active);
```

---

# 8. organization_settings

Configuración específica de cada organización.

```sql
CREATE TABLE organization_settings (
    organization_id UUID PRIMARY KEY
        REFERENCES organizations(id)
        ON DELETE CASCADE,

    default_appointment_duration_minutes INTEGER
        NOT NULL DEFAULT 120,

    payment_required_before_confirmation BOOLEAN
        NOT NULL DEFAULT FALSE,

    currency CHAR(3)
        NOT NULL DEFAULT 'PEN',

    timezone TEXT
        NOT NULL DEFAULT 'America/Lima',

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

# 9. users

Los usuarios autenticados se relacionarán con Supabase Auth mediante `auth_user_id`.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    auth_user_id UUID NOT NULL UNIQUE,

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    role user_role NOT NULL,

    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,

    email TEXT NOT NULL,
    phone TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_users_organization
ON users(organization_id);

CREATE INDEX idx_users_role
ON users(organization_id, role);

CREATE INDEX idx_users_active
ON users(organization_id, active);
```

---

# 10. clients

Representa clientes que contratan o reciben una inspección.

```sql
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    user_id UUID
        REFERENCES users(id),

    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,

    document_type TEXT,
    document_number TEXT,

    email TEXT,
    phone TEXT,

    notes TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_clients_organization
ON clients(organization_id);

CREATE INDEX idx_clients_email
ON clients(organization_id, email);

CREATE INDEX idx_clients_document
ON clients(organization_id, document_number);
```

---

# 11. projects

Representa proyectos inmobiliarios.

```sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    name TEXT NOT NULL,

    developer_name TEXT,
    address TEXT,
    city TEXT,
    district TEXT,

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_projects_organization
ON projects(organization_id);

CREATE INDEX idx_projects_active
ON projects(organization_id, active);
```

---

# 12. buildings

```sql
CREATE TABLE buildings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    project_id UUID NOT NULL
        REFERENCES projects(id)
        ON DELETE CASCADE,

    name TEXT NOT NULL,

    code TEXT,

    number_of_floors INTEGER,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_buildings_project
ON buildings(project_id);

CREATE INDEX idx_buildings_organization
ON buildings(organization_id);
```

---

# 13. floors

```sql
CREATE TABLE floors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    building_id UUID NOT NULL
        REFERENCES buildings(id)
        ON DELETE CASCADE,

    floor_number INTEGER NOT NULL,

    name TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Restricción

```sql
CREATE UNIQUE INDEX uq_floor_building_number
ON floors(building_id, floor_number);
```

---

# 14. properties

Representa el departamento, unidad o inmueble inspeccionado.

```sql
CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    project_id UUID NOT NULL
        REFERENCES projects(id),

    building_id UUID
        REFERENCES buildings(id),

    floor_id UUID
        REFERENCES floors(id),

    client_id UUID
        REFERENCES clients(id),

    unit_code TEXT NOT NULL,

    property_type TEXT
        NOT NULL DEFAULT 'APARTMENT',

    area_m2 NUMERIC(10,2),

    bedrooms INTEGER,
    bathrooms INTEGER,

    parking_code TEXT,
    storage_code TEXT,

    address TEXT,

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_properties_project
ON properties(project_id);

CREATE INDEX idx_properties_building
ON properties(building_id);

CREATE INDEX idx_properties_client
ON properties(client_id);

CREATE INDEX idx_properties_organization
ON properties(organization_id);

CREATE UNIQUE INDEX uq_property_project_unit
ON properties(project_id, unit_code);
```

---

# 15. service_types

Representa los planes comerciales.

```sql
CREATE TABLE service_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    code TEXT NOT NULL,

    name TEXT NOT NULL,

    description TEXT,

    duration_minutes INTEGER NOT NULL,

    price NUMERIC(12,2) NOT NULL DEFAULT 0,

    currency CHAR(3) NOT NULL DEFAULT 'PEN',

    requires_payment BOOLEAN NOT NULL DEFAULT FALSE,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Ejemplos

```text
ESENCIAL
INTEGRAL
PROTECCION
REINSPECCION
POSTVENTA
```

### Índices

```sql
CREATE UNIQUE INDEX uq_service_type_code
ON service_types(organization_id, code);

CREATE INDEX idx_service_types_active
ON service_types(organization_id, active);
```

---

# 16. service_features

Permite controlar qué funcionalidades incluye cada plan.

```sql
CREATE TABLE service_features (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    service_type_id UUID NOT NULL
        REFERENCES service_types(id)
        ON DELETE CASCADE,

    feature_code TEXT NOT NULL,

    enabled BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Ejemplos

```text
BASIC_CHECKLIST
PHOTO_EVIDENCE
PDF_REPORT
MEASUREMENTS
PLAN_MARKERS
TECHNICAL_CLASSIFICATION
CLIENT_PORTAL
CORRECTION_TRACKING
SECOND_VISIT
REINSPECTION
CLOSURE_REPORT
```

### Índices

```sql
CREATE UNIQUE INDEX uq_service_feature
ON service_features(service_type_id, feature_code);
```

---

# 17. availability_rules

Define los horarios disponibles para inspecciones.

```sql
CREATE TABLE availability_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    inspector_id UUID
        REFERENCES users(id),

    day_of_week SMALLINT NOT NULL,

    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Restricciones

```text
day_of_week:
0 = Sunday
1 = Monday
...
6 = Saturday
```

```sql
CHECK (day_of_week BETWEEN 0 AND 6);

CHECK (start_time < end_time);
```

---

# 18. appointments

Representa la solicitud y programación de una inspección.

```sql
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    client_id UUID NOT NULL
        REFERENCES clients(id),

    property_id UUID
        REFERENCES properties(id),

    service_type_id UUID NOT NULL
        REFERENCES service_types(id),

    inspector_id UUID
        REFERENCES users(id),

    requested_start TIMESTAMPTZ NOT NULL,
    requested_end TIMESTAMPTZ NOT NULL,

    confirmed_start TIMESTAMPTZ,
    confirmed_end TIMESTAMPTZ,

    status appointment_status
        NOT NULL DEFAULT 'REQUESTED',

    payment_status payment_status
        NOT NULL DEFAULT 'UNPAID',

    client_notes TEXT,
    admin_notes TEXT,

    confirmed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    deleted_at TIMESTAMPTZ,

    CHECK (requested_start < requested_end),

    CHECK (
        confirmed_start IS NULL
        OR confirmed_end IS NULL
        OR confirmed_start < confirmed_end
    )
);
```

### Índices

```sql
CREATE INDEX idx_appointments_organization
ON appointments(organization_id);

CREATE INDEX idx_appointments_client
ON appointments(client_id);

CREATE INDEX idx_appointments_inspector
ON appointments(inspector_id);

CREATE INDEX idx_appointments_property
ON appointments(property_id);

CREATE INDEX idx_appointments_status
ON appointments(organization_id, status);

CREATE INDEX idx_appointments_schedule
ON appointments(
    organization_id,
    confirmed_start,
    confirmed_end
);
```

---

# 19. Appointment Conflict Prevention

La disponibilidad definitiva debe comprobarse en backend.

Para evitar doble reserva, PostgreSQL puede utilizar una exclusion constraint basada en rangos.

Conceptualmente:

```sql
EXCLUDE USING gist (
    inspector_id WITH =,
    tstzrange(
        confirmed_start,
        confirmed_end,
        '[)'
    ) WITH &&
)
WHERE (
    status IN (
        'CONFIRMED',
        'RESCHEDULED'
    )
);
```

Esta restricción debe implementarse mediante una migración después de habilitar la extensión PostgreSQL necesaria.

El objetivo es impedir que dos citas confirmadas del mismo inspector se superpongan.

---

# 20. appointment_status_history

Mantiene trazabilidad de cambios de cita.

```sql
CREATE TABLE appointment_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    appointment_id UUID NOT NULL
        REFERENCES appointments(id)
        ON DELETE CASCADE,

    previous_status appointment_status,
    new_status appointment_status,

    changed_by UUID
        REFERENCES users(id),

    reason TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_appointment_history
ON appointment_status_history(appointment_id, created_at);
```

---

# 21. payment_records

Aunque el MVP no tendrá pasarela de pago, conviene separar el estado de pago de la cita.

```sql
CREATE TABLE payment_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    appointment_id UUID NOT NULL
        REFERENCES appointments(id),

    amount NUMERIC(12,2) NOT NULL,

    currency CHAR(3) NOT NULL DEFAULT 'PEN',

    payment_method TEXT,

    payment_reference TEXT,

    paid_at TIMESTAMPTZ,

    recorded_by UUID
        REFERENCES users(id),

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Ejemplos de método:

```text
YAPE
PLIN
TRANSFER
CASH
CARD
OTHER
```

No significa que exista integración automática.

---

# 22. inspection_templates

Define una plantilla de inspección.

```sql
CREATE TABLE inspection_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    code TEXT NOT NULL,

    name TEXT NOT NULL,

    description TEXT,

    version INTEGER NOT NULL DEFAULT 1,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Ejemplos

```text
departamento_nuevo
departamento_recepcion
pre_entrega
postventa
reinspeccion
```

---

# 23. template_areas

```sql
CREATE TABLE template_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    template_id UUID NOT NULL
        REFERENCES inspection_templates(id)
        ON DELETE CASCADE,

    code TEXT NOT NULL,

    name TEXT NOT NULL,

    description TEXT,

    display_order INTEGER NOT NULL DEFAULT 0,

    active BOOLEAN NOT NULL DEFAULT TRUE
);
```

### Índices

```sql
CREATE INDEX idx_template_areas_template
ON template_areas(template_id, display_order);
```

---

# 24. template_items

Define los puntos de inspección.

```sql
CREATE TABLE template_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    template_area_id UUID NOT NULL
        REFERENCES template_areas(id)
        ON DELETE CASCADE,

    code TEXT NOT NULL,

    category TEXT,
    element TEXT,

    title TEXT NOT NULL,

    description TEXT,

    response_type TEXT NOT NULL DEFAULT 'CHECKLIST',

    photo_required BOOLEAN NOT NULL DEFAULT FALSE,

    measurement_required BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER NOT NULL DEFAULT 0,

    active BOOLEAN NOT NULL DEFAULT TRUE
);
```

### response_type

Ejemplos:

```text
CHECKLIST
BOOLEAN
TEXT
NUMBER
SELECT
MULTI_SELECT
PHOTO
MEASUREMENT
```

---

# 25. observation_library

Biblioteca de observaciones reutilizables.

```sql
CREATE TABLE observation_library (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    code TEXT NOT NULL,

    category TEXT,
    area TEXT,
    element TEXT,

    title TEXT NOT NULL,

    description TEXT,

    recommendation TEXT,

    default_severity observation_severity,

    version INTEGER NOT NULL DEFAULT 1,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_observation_library_category
ON observation_library(
    organization_id,
    category
);

CREATE INDEX idx_observation_library_area
ON observation_library(
    organization_id,
    area
);

CREATE INDEX idx_observation_library_active
ON observation_library(
    organization_id,
    active
);

CREATE UNIQUE INDEX uq_observation_library_code
ON observation_library(organization_id, code);
```

---

# 26. inspections

Entidad principal de la inspección.

```sql
CREATE TABLE inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    appointment_id UUID
        REFERENCES appointments(id),

    property_id UUID NOT NULL
        REFERENCES properties(id),

    client_id UUID
        REFERENCES clients(id),

    inspector_id UUID
        REFERENCES users(id),

    service_type_id UUID
        REFERENCES service_types(id),

    template_id UUID
        REFERENCES inspection_templates(id),

    status inspection_status
        NOT NULL DEFAULT 'DRAFT',

    scheduled_start TIMESTAMPTZ,
    scheduled_end TIMESTAMPTZ,

    actual_start TIMESTAMPTZ,
    actual_end TIMESTAMPTZ,

    inspection_number TEXT,

    notes TEXT,

    version INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_inspections_organization
ON inspections(organization_id);

CREATE INDEX idx_inspections_property
ON inspections(property_id);

CREATE INDEX idx_inspections_client
ON inspections(client_id);

CREATE INDEX idx_inspections_inspector
ON inspections(inspector_id);

CREATE INDEX idx_inspections_status
ON inspections(organization_id, status);

CREATE INDEX idx_inspections_scheduled
ON inspections(
    organization_id,
    scheduled_start
);

CREATE UNIQUE INDEX uq_inspection_number
ON inspections(organization_id, inspection_number)
WHERE inspection_number IS NOT NULL;
```

---

# 27. inspection_areas

Instancia de las áreas utilizadas en una inspección.

```sql
CREATE TABLE inspection_areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    inspection_id UUID NOT NULL
        REFERENCES inspections(id)
        ON DELETE CASCADE,

    template_area_id UUID
        REFERENCES template_areas(id),

    code TEXT NOT NULL,

    name TEXT NOT NULL,

    display_order INTEGER NOT NULL DEFAULT 0,

    status TEXT,

    local_id UUID,

    version INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_inspection_areas_inspection
ON inspection_areas(inspection_id, display_order);
```

---

# 28. inspection_items

Instancia de cada punto de checklist.

```sql
CREATE TABLE inspection_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    inspection_id UUID NOT NULL
        REFERENCES inspections(id)
        ON DELETE CASCADE,

    inspection_area_id UUID NOT NULL
        REFERENCES inspection_areas(id)
        ON DELETE CASCADE,

    template_item_id UUID
        REFERENCES template_items(id),

    code TEXT NOT NULL,

    category TEXT,
    element TEXT,

    title TEXT NOT NULL,

    result checklist_result,

    response_text TEXT,

    response_number NUMERIC,

    response_json JSONB,

    notes TEXT,

    display_order INTEGER NOT NULL DEFAULT 0,

    local_id UUID,

    version INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_inspection_items_inspection
ON inspection_items(inspection_id);

CREATE INDEX idx_inspection_items_area
ON inspection_items(inspection_area_id);
```

---

# 29. observations

Representa una observación o defecto encontrado.

```sql
CREATE TABLE observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    inspection_id UUID NOT NULL
        REFERENCES inspections(id)
        ON DELETE CASCADE,

    inspection_area_id UUID
        REFERENCES inspection_areas(id),

    inspection_item_id UUID
        REFERENCES inspection_items(id),

    library_item_id UUID
        REFERENCES observation_library(id),

    code TEXT,

    title TEXT NOT NULL,

    description TEXT NOT NULL,

    recommendation TEXT,

    severity observation_severity
        NOT NULL DEFAULT 'INFO',

    status observation_status
        NOT NULL DEFAULT 'OPEN',

    sequence_number INTEGER,

    local_id UUID,

    version INTEGER NOT NULL DEFAULT 1,

    created_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_observations_inspection
ON observations(inspection_id);

CREATE INDEX idx_observations_area
ON observations(inspection_area_id);

CREATE INDEX idx_observations_status
ON observations(
    organization_id,
    status
);

CREATE INDEX idx_observations_severity
ON observations(
    organization_id,
    severity
);

CREATE INDEX idx_observations_inspection_severity
ON observations(
    inspection_id,
    severity
);
```

---

# 30. property_plans

Planos asociados a una propiedad.

```sql
CREATE TABLE property_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    property_id UUID NOT NULL
        REFERENCES properties(id)
        ON DELETE CASCADE,

    name TEXT NOT NULL,

    file_path TEXT NOT NULL,

    mime_type TEXT NOT NULL,

    file_size BIGINT,

    sha256 TEXT,

    page_number INTEGER,

    width NUMERIC,
    height NUMERIC,

    version INTEGER NOT NULL DEFAULT 1,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    uploaded_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_property_plans_property
ON property_plans(property_id);

CREATE INDEX idx_property_plans_active
ON property_plans(property_id, active);
```

---

# 31. observation_plan_markers

Ubica una observación en un plano.

```sql
CREATE TABLE observation_plan_markers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    observation_id UUID NOT NULL
        REFERENCES observations(id)
        ON DELETE CASCADE,

    property_plan_id UUID NOT NULL
        REFERENCES property_plans(id)
        ON DELETE CASCADE,

    x NUMERIC(10,8) NOT NULL,
    y NUMERIC(10,8) NOT NULL,

    label TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CHECK (x >= 0 AND x <= 1),
    CHECK (y >= 0 AND y <= 1)
);
```

### Índices

```sql
CREATE INDEX idx_plan_markers_observation
ON observation_plan_markers(observation_id);

CREATE INDEX idx_plan_markers_plan
ON observation_plan_markers(property_plan_id);
```

---

# 32. measurements

Registra mediciones realizadas durante una inspección.

```sql
CREATE TABLE measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    inspection_id UUID NOT NULL
        REFERENCES inspections(id)
        ON DELETE CASCADE,

    observation_id UUID
        REFERENCES observations(id)
        ON DELETE SET NULL,

    inspection_area_id UUID
        REFERENCES inspection_areas(id),

    measurement_type TEXT NOT NULL,

    value NUMERIC(14,4) NOT NULL,

    unit TEXT NOT NULL,

    secondary_value NUMERIC(14,4),

    secondary_unit TEXT,

    notes TEXT,

    device_type TEXT,
    device_id TEXT,

    local_id UUID,

    version INTEGER NOT NULL DEFAULT 1,

    created_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_measurements_inspection
ON measurements(inspection_id);

CREATE INDEX idx_measurements_observation
ON measurements(observation_id);

CREATE INDEX idx_measurements_type
ON measurements(
    organization_id,
    measurement_type
);
```

---

# 33. evidence

Almacena metadata de fotografías y otros archivos.

Los archivos físicos no se almacenan dentro de PostgreSQL.

Se almacenan en Supabase Storage.

```sql
CREATE TABLE evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    inspection_id UUID NOT NULL
        REFERENCES inspections(id)
        ON DELETE CASCADE,

    observation_id UUID
        REFERENCES observations(id)
        ON DELETE SET NULL,

    measurement_id UUID
        REFERENCES measurements(id)
        ON DELETE SET NULL,

    evidence_type evidence_type NOT NULL,

    file_path TEXT NOT NULL,

    mime_type TEXT NOT NULL,

    file_size BIGINT,

    sha256 TEXT,

    captured_at TIMESTAMPTZ,

    uploaded_at TIMESTAMPTZ,

    device_id TEXT,

    sequence INTEGER,

    metadata JSONB,

    local_id UUID,

    sync_status sync_status
        NOT NULL DEFAULT 'PENDING',

    version INTEGER NOT NULL DEFAULT 1,

    created_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    deleted_at TIMESTAMPTZ
);
```

### Índices

```sql
CREATE INDEX idx_evidence_inspection
ON evidence(inspection_id);

CREATE INDEX idx_evidence_observation
ON evidence(observation_id);

CREATE INDEX idx_evidence_sync
ON evidence(sync_status);

CREATE INDEX idx_evidence_sha256
ON evidence(sha256);
```

---

# 34. actions

Representa una acción de corrección.

```sql
CREATE TABLE actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    observation_id UUID NOT NULL
        REFERENCES observations(id)
        ON DELETE CASCADE,

    assigned_to UUID
        REFERENCES users(id),

    status action_status
        NOT NULL DEFAULT 'PENDING',

    due_date DATE,

    correction_description TEXT,

    correction_notes TEXT,

    corrected_at TIMESTAMPTZ,

    verified_at TIMESTAMPTZ,

    verified_by UUID
        REFERENCES users(id),

    local_id UUID,

    version INTEGER NOT NULL DEFAULT 1,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_actions_observation
ON actions(observation_id);

CREATE INDEX idx_actions_assigned
ON actions(assigned_to);

CREATE INDEX idx_actions_status
ON actions(
    organization_id,
    status
);

CREATE INDEX idx_actions_due_date
ON actions(
    organization_id,
    due_date
);
```

---

# 35. reinspections

Representa una segunda visita o reinspección.

```sql
CREATE TABLE reinspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    original_inspection_id UUID NOT NULL
        REFERENCES inspections(id),

    appointment_id UUID
        REFERENCES appointments(id),

    inspector_id UUID
        REFERENCES users(id),

    scheduled_start TIMESTAMPTZ,
    scheduled_end TIMESTAMPTZ,

    status inspection_status
        NOT NULL DEFAULT 'SCHEDULED',

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_reinspections_original
ON reinspections(original_inspection_id);

CREATE INDEX idx_reinspections_inspector
ON reinspections(inspector_id);

CREATE INDEX idx_reinspections_schedule
ON reinspections(
    organization_id,
    scheduled_start
);
```

---

# 36. reinspection_observations

Relaciona observaciones con una reinspección.

```sql
CREATE TABLE reinspection_observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    reinspection_id UUID NOT NULL
        REFERENCES reinspections(id)
        ON DELETE CASCADE,

    observation_id UUID NOT NULL
        REFERENCES observations(id),

    result observation_status,

    notes TEXT,

    verified_by UUID
        REFERENCES users(id),

    verified_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_reinspection_observations_reinspection
ON reinspection_observations(reinspection_id);

CREATE INDEX idx_reinspection_observations_observation
ON reinspection_observations(observation_id);
```

---

# 37. reports

Representa una versión de informe.

```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    inspection_id UUID NOT NULL
        REFERENCES inspections(id)
        ON DELETE CASCADE,

    version INTEGER NOT NULL,

    report_template_id UUID
        REFERENCES report_templates(id),

    status report_status
        NOT NULL DEFAULT 'DRAFT',

    file_path TEXT,

    sha256 TEXT,

    generated_at TIMESTAMPTZ,

    published_at TIMESTAMPTZ,

    generated_by UUID
        REFERENCES users(id),

    published_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE(inspection_id, version)
);
```

### Índices

```sql
CREATE INDEX idx_reports_inspection
ON reports(inspection_id);

CREATE INDEX idx_reports_status
ON reports(
    organization_id,
    status
);
```

---

# 38. report_templates

Plantillas visuales de informes.

```sql
CREATE TABLE report_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    code TEXT NOT NULL,

    name TEXT NOT NULL,

    version INTEGER NOT NULL DEFAULT 1,

    template_path TEXT,

    css_path TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

# 39. report_template_assignments

Relaciona una plantilla con un servicio.

```sql
CREATE TABLE report_template_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    service_type_id UUID NOT NULL
        REFERENCES service_types(id),

    report_template_id UUID NOT NULL
        REFERENCES report_templates(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE(service_type_id, report_template_id)
);
```

---

# 40. documents

Documentos cargados para futuras funcionalidades.

```sql
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    property_id UUID
        REFERENCES properties(id),

    inspection_id UUID
        REFERENCES inspections(id),

    document_type TEXT NOT NULL,

    name TEXT NOT NULL,

    file_path TEXT NOT NULL,

    mime_type TEXT,

    file_size BIGINT,

    sha256 TEXT,

    metadata JSONB,

    uploaded_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Tipos futuros:

```text
CONTRACT
SPECIFICATION
PLAN
MEMORY
ANNEX
WARRANTY
OTHER
```

---

# 41. Contract Audit

Esta funcionalidad será futura.

## 41.1 requirements

```sql
CREATE TABLE requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    document_id UUID
        REFERENCES documents(id),

    code TEXT,

    category TEXT,

    description TEXT NOT NULL,

    expected_value TEXT,

    unit TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 41.2 contract_items

```sql
CREATE TABLE contract_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    requirement_id UUID NOT NULL
        REFERENCES requirements(id),

    description TEXT,

    quantity NUMERIC(14,4),

    unit TEXT,

    specifications JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 41.3 delivery_items

```sql
CREATE TABLE delivery_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    property_id UUID
        REFERENCES properties(id),

    inspection_id UUID
        REFERENCES inspections(id),

    contract_item_id UUID
        REFERENCES contract_items(id),

    delivered_value TEXT,

    evidence_id UUID
        REFERENCES evidence(id),

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 41.4 compliance_results

```sql
CREATE TABLE compliance_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    requirement_id UUID NOT NULL
        REFERENCES requirements(id),

    delivery_item_id UUID
        REFERENCES delivery_items(id),

    result TEXT NOT NULL,

    explanation TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Valores:

```text
COMPLIANT
PARTIAL
NON_COMPLIANT
NOT_VERIFIED
```

---

# 42. ai_tasks

Registra tareas de IA.

```sql
CREATE TABLE ai_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    inspection_id UUID
        REFERENCES inspections(id),

    observation_id UUID
        REFERENCES observations(id),

    task_type TEXT NOT NULL,

    provider TEXT NOT NULL,

    status TEXT NOT NULL,

    input_reference JSONB,

    output_reference JSONB,

    error_message TEXT,

    created_by UUID
        REFERENCES users(id),

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ
);
```

Ejemplos:

```text
DRAFT_OBSERVATION
NORMALIZE_OBSERVATION
SUGGEST_SEVERITY
GENERATE_SUMMARY
GENERATE_RECOMMENDATION
PHOTO_ASSISTANCE
```

---

# 43. ai_results

Resultado revisable de una tarea de IA.

```sql
CREATE TABLE ai_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    ai_task_id UUID NOT NULL
        REFERENCES ai_tasks(id)
        ON DELETE CASCADE,

    result JSONB NOT NULL,

    confidence NUMERIC(5,4),

    accepted BOOLEAN,

    reviewed_by UUID
        REFERENCES users(id),

    reviewed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

La IA nunca debe modificar directamente una observación publicada sin aprobación humana.

---

# 44. audit_logs

Registro de auditoría.

```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID
        REFERENCES organizations(id),

    user_id UUID
        REFERENCES users(id),

    action TEXT NOT NULL,

    entity_type TEXT,

    entity_id UUID,

    metadata JSONB,

    ip_hash TEXT,

    user_agent TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Índices

```sql
CREATE INDEX idx_audit_logs_organization
ON audit_logs(
    organization_id,
    created_at DESC
);

CREATE INDEX idx_audit_logs_entity
ON audit_logs(
    entity_type,
    entity_id
);

CREATE INDEX idx_audit_logs_user
ON audit_logs(
    user_id,
    created_at DESC
);
```

---

# 45. sync_operations

Registra operaciones provenientes de dispositivos offline.

```sql
CREATE TABLE sync_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    user_id UUID
        REFERENCES users(id),

    device_id TEXT NOT NULL,

    operation_id UUID NOT NULL,

    entity_type TEXT NOT NULL,

    entity_id UUID NOT NULL,

    operation_type TEXT NOT NULL,

    payload JSONB,

    status sync_status
        NOT NULL DEFAULT 'PENDING',

    error_message TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    processed_at TIMESTAMPTZ,

    UNIQUE(device_id, operation_id)
);
```

### operation_type

```text
CREATE
UPDATE
DELETE
UPLOAD
```

### Índices

```sql
CREATE INDEX idx_sync_operations_status
ON sync_operations(
    organization_id,
    status
);

CREATE INDEX idx_sync_operations_device
ON sync_operations(device_id, created_at);

CREATE INDEX idx_sync_operations_entity
ON sync_operations(entity_type, entity_id);
```

---

# 46. Device Registry

Permite identificar dispositivos autorizados.

```sql
CREATE TABLE devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    user_id UUID
        REFERENCES users(id),

    device_identifier TEXT NOT NULL,

    platform TEXT,

    model TEXT,

    app_version TEXT,

    last_sync_at TIMESTAMPTZ,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE(organization_id, device_identifier)
);
```

---

# 47. DQI Future Model

El índice DQI no debe fijarse prematuramente.

La base puede almacenar posteriormente resultados calculados.

```sql
CREATE TABLE quality_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    property_id UUID
        REFERENCES properties(id),

    inspection_id UUID
        REFERENCES inspections(id),

    score NUMERIC(6,2),

    methodology_version TEXT,

    factors JSONB,

    calculated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

El algoritmo se definirá cuando exista suficiente información histórica.

---

# 48. Important Relationships

## Organization → Users

```text
organizations 1 ─── N users
```

## Organization → Clients

```text
organizations 1 ─── N clients
```

## Project → Building

```text
projects 1 ─── N buildings
```

## Building → Floor

```text
buildings 1 ─── N floors
```

## Floor → Property

```text
floors 1 ─── N properties
```

## Client → Property

```text
clients 1 ─── N properties
```

## Client → Appointment

```text
clients 1 ─── N appointments
```

## Appointment → Inspection

```text
appointments 1 ─── 0..1 inspections
```

## Property → Inspection

```text
properties 1 ─── N inspections
```

## Inspection → Area

```text
inspections 1 ─── N inspection_areas
```

## Area → Items

```text
inspection_areas 1 ─── N inspection_items
```

## Inspection → Observation

```text
inspections 1 ─── N observations
```

## Observation → Evidence

```text
observations 1 ─── N evidence
```

## Observation → Action

```text
observations 1 ─── N actions
```

## Action → Reinspection

```text
actions N ─── N reinspections
```

mediante:

```text
reinspection_observations
```

---

# 49. Data Integrity Rules

## Rule 1 — Tenant isolation

Todas las entidades deben pertenecer a una organización.

---

## Rule 2 — Appointment ownership

Un cliente no puede consultar una cita de otra organización.

---

## Rule 3 — Property ownership

Un departamento debe pertenecer a un proyecto de la misma organización.

---

## Rule 4 — Inspection ownership

Una inspección y su propiedad deben pertenecer a la misma organización.

---

## Rule 5 — Evidence ownership

La evidencia debe pertenecer a la misma organización que la inspección.

---

## Rule 6 — Report immutability

Un informe publicado no debe ser sobrescrito.

Se genera una nueva versión.

---

## Rule 7 — Payment separation

El estado de pago no determina automáticamente el estado de inspección.

---

## Rule 8 — Appointment conflict

Dos citas confirmadas del mismo inspector no pueden solaparse.

---

## Rule 9 — Observation history

Una observación publicada no debe perder su historial.

---

## Rule 10 — Sync idempotency

La misma operación offline no puede ejecutarse dos veces.

---

# 50. Row Level Security

Supabase RLS será obligatorio antes de producción.

La regla general será:

```text
authenticated user
        │
        ▼
users.organization_id
        │
        ▼
row.organization_id
```

Conceptualmente:

```sql
organization_id =
current_user_organization_id()
```

La función debe devolver la organización asociada al usuario autenticado.

---

# 51. RLS Policies

## Organizations

Los usuarios solo pueden acceder a su propia organización.

## Users

Un usuario puede consultar usuarios de su propia organización según su rol.

## Clients

Los administradores pueden consultar clientes de su organización.

Los clientes solo pueden consultar su propio registro.

## Properties

Los administradores pueden consultar propiedades de su organización.

Los clientes solo pueden consultar propiedades asociadas a ellos.

## Appointments

Administradores:

```text
organization_id = own organization
```

Clientes:

```text
client_id = current client
```

Inspectores:

```text
inspector_id = current user
```

## Inspections

Administradores:

```text
organization_id = own organization
```

Inspectores:

```text
inspector_id = current user
```

Clientes:

```text
client_id = current client
```

---

# 52. Storage Architecture

PostgreSQL almacenará metadata.

Supabase Storage almacenará archivos.

```text
PostgreSQL
    │
    │ file_path
    ▼
Supabase Storage
```

No se recomienda almacenar fotografías directamente como `BYTEA` en PostgreSQL.

---

# 53. Storage Buckets

Buckets privados:

```text
inspection-evidence
property-plans
reports
documents
```

Nunca se debe utilizar un bucket público para evidencia privada.

El acceso deberá realizarse mediante:

- RLS;
- ownership validation;
- signed URLs;
- expiración.

---

# 54. File Path Convention

Ejemplo:

```text
organizations/
  {organization_id}/
    inspections/
      {inspection_id}/
        evidence/
          {evidence_id}.jpg
```

Planos:

```text
organizations/
  {organization_id}/
    properties/
      {property_id}/
        plans/
          {plan_id}.pdf
```

Reportes:

```text
organizations/
  {organization_id}/
    inspections/
      {inspection_id}/
        reports/
          report-v1.pdf
```

---

# 55. Index Strategy

No se crearán índices indiscriminadamente.

Los índices se concentrarán en:

- foreign keys;
- `organization_id`;
- estados;
- fechas;
- consultas frecuentes;
- búsqueda de disponibilidad;
- sincronización;
- auditoría.

Índices especialmente importantes:

```text
appointments:
organization_id + confirmed_start

inspections:
organization_id + scheduled_start

observations:
inspection_id
inspection_id + severity
organization_id + status

evidence:
inspection_id
observation_id
sync_status

audit_logs:
organization_id + created_at

sync_operations:
device_id + created_at
status
```

---

# 56. Search

Para búsqueda textual inicial se utilizará PostgreSQL.

Campos principales:

```text
clients.name
clients.email
projects.name
properties.unit_code
observations.title
observations.description
observation_library.title
```

No se utilizará Elasticsearch/OpenSearch en MVP.

---

# 57. JSONB Usage

JSONB será utilizado únicamente cuando la estructura pueda evolucionar.

Adecuado para:

```text
metadata
response_json
AI results
AI input
device metadata
```

No utilizar JSONB para reemplazar relaciones estructuradas importantes.

Por ejemplo, NO:

```text
inspection.data = {
   client: ...,
   property: ...,
   observations: [...]
}
```

Las entidades principales deben permanecer normalizadas.

---

# 58. Offline Mapping

Las entidades que pueden ser creadas offline deben soportar:

```text
local_id
version
sync_status
created_at
updated_at
```

Entidades prioritarias:

```text
inspections
inspection_areas
inspection_items
observations
measurements
evidence
actions
```

---

# 59. Offline ID Strategy

El dispositivo generará UUID localmente.

Ejemplo:

```text
local_id:
550e8400-e29b-41d4-a716-446655440000
```

El mismo UUID puede utilizarse como `id` de la entidad cuando se cree offline.

Esto reduce la necesidad de mapear IDs locales y remotos.

`sync_operations.operation_id` seguirá identificando la operación individual.

---

# 60. Sync Strategy

Flujo:

```text
SQLite
   │
   ▼
Local transaction
   │
   ▼
Outbox
   │
   ▼
sync_operations
   │
   ▼
API
   │
   ▼
PostgreSQL
   │
   ▼
ACK
   │
   ▼
SQLite = SYNCED
```

---

# 61. Conflict Strategy

MVP:

```text
last_modified + version
```

Si:

```text
client_version != server_version
```

el servidor debe rechazar silenciosamente la sobrescritura y devolver:

```text
CONFLICT
```

El conflicto deberá registrarse.

No se utilizará CRDT en MVP.

---

# 62. Deletion Strategy

Para entidades críticas:

```text
deleted_at
```

El registro permanece disponible para sincronización e historial.

Ejemplo:

```text
Observation
deleted_at = 2026-10-15T...
```

No debe desaparecer inmediatamente de la base.

---

# 63. Audit Requirements

Como mínimo se auditarán:

```text
LOGIN
LOGOUT

CREATE_APPOINTMENT
UPDATE_APPOINTMENT
CONFIRM_APPOINTMENT
CANCEL_APPOINTMENT
MARK_PAYMENT_PAID

CREATE_INSPECTION
UPDATE_INSPECTION
COMPLETE_INSPECTION

CREATE_OBSERVATION
UPDATE_OBSERVATION

UPLOAD_EVIDENCE

GENERATE_REPORT
PUBLISH_REPORT
DOWNLOAD_REPORT

CREATE_REINSPECTION
CHANGE_STATUS

DELETE
```

---

# 64. Database Migrations

Las modificaciones de esquema deben realizarse mediante migraciones versionadas.

Estructura:

```text
supabase/
├── migrations/
│   ├── 000001_extensions.sql
│   ├── 000002_organizations.sql
│   ├── 000003_users.sql
│   ├── 000004_projects.sql
│   ├── 000005_properties.sql
│   ├── 000006_services.sql
│   ├── 000007_appointments.sql
│   ├── 000008_inspection_templates.sql
│   ├── 000009_inspections.sql
│   ├── 000010_observations.sql
│   ├── 000011_evidence.sql
│   ├── 000012_actions.sql
│   ├── 000013_reports.sql
│   ├── 000014_audit.sql
│   ├── 000015_sync.sql
│   └── ...
│
├── seed.sql
└── config.toml
```

Nunca modificar manualmente una base de producción sin registrar la migración correspondiente.

---

# 65. Seed Data

El entorno local deberá disponer de datos iniciales:

## Service Types

```text
ESENCIAL
INTEGRAL
PROTECCION
REINSPECCION
POSTVENTA
```

## Inspection Templates

```text
DEPARTAMENTO_NUEVO
RECEPCION
PRE_ENTREGA
POSTVENTA
REINSPECCION
```

## Observation Severity

```text
INFO
MENOR
MODERADA
MAYOR
CRITICA
```

---

# 66. Initial MVP Tables

Aunque el modelo completo contempla futuras funciones, el MVP inicial debe comenzar principalmente con:

```text
organizations
organization_settings
users
clients

projects
buildings
floors
properties

service_types
service_features

availability_rules
appointments
appointment_status_history
payment_records

inspection_templates
template_areas
template_items
observation_library

inspections
inspection_areas
inspection_items
observations

property_plans
observation_plan_markers

measurements
evidence

reports
report_templates

audit_logs

devices
sync_operations
```

Las tablas de contrato, IA avanzada, DQI y otras funcionalidades pueden incorporarse mediante migraciones posteriores.

---

# 67. Database Module Dependencies

```text
organizations
    ↓
users / clients
    ↓
projects
    ↓
buildings
    ↓
floors
    ↓
properties
    ↓
service_types
    ↓
appointments
    ↓
inspections
    ↓
inspection_areas
    ↓
inspection_items
    ↓
observations
    ├── evidence
    ├── measurements
    └── actions
            ↓
        reinspections
```

---

# 68. Critical Queries

La arquitectura deberá optimizar especialmente las siguientes consultas.

## 68.1 Available appointment

```text
¿Existe una cita confirmada que se solape con el intervalo solicitado?
```

## 68.2 Inspector agenda

```text
Obtener citas confirmadas de un inspector para una fecha.
```

## 68.3 Client appointments

```text
Obtener citas de un cliente ordenadas por fecha.
```

## 68.4 Inspection dashboard

```text
Inspecciones por estado y fecha.
```

## 68.5 Observation summary

```text
Cantidad de observaciones por severidad.
```

## 68.6 Pending corrections

```text
Acciones pendientes por inspección.
```

## 68.7 Reinspection

```text
Observaciones pendientes asociadas a una reinspección.
```

## 68.8 Offline synchronization

```text
Operaciones pendientes de un dispositivo.
```

---

# 69. Example Inspection Query Model

Una inspección completa debe poder reconstruirse mediante:

```text
inspection
    │
    ├── property
    │      └── property_plan
    │
    ├── client
    │
    ├── inspector
    │
    ├── service_type
    │
    ├── inspection_areas
    │      └── inspection_items
    │
    ├── observations
    │      ├── evidence
    │      ├── measurements
    │      └── plan_marker
    │
    └── reports
```

Esto permite generar el informe sin depender de información externa.

---

# 70. Data Lifecycle

```text
CLIENT
   │
   ▼
APPOINTMENT
   │
   ▼
INSPECTION
   │
   ▼
OBSERVATION
   │
   ├── EVIDENCE
   ├── MEASUREMENT
   └── ACTION
          │
          ▼
      REINSPECTION
          │
          ▼
       VERIFIED
          │
          ▼
        CLOSED
```

---

# 71. Security Requirements

La base debe implementar:

- RLS;
- foreign keys;
- constraints;
- least privilege;
- private storage;
- signed URLs;
- audit logging;
- validación de MIME;
- límites de tamaño;
- ownership validation;
- separación por `organization_id`.

Nunca almacenar:

```text
service_role_key
database_password
private_keys
AI secrets
```

en:

- Flutter;
- APK;
- frontend;
- Git;
- GitHub.

---

# 72. Backup and Recovery

Antes de producción:

- habilitar backups;
- verificar restauración;
- documentar recuperación;
- probar restauración periódicamente.

La estrategia de backup debe cubrir:

```text
PostgreSQL
+
Storage
```

No basta con respaldar únicamente PostgreSQL porque las fotografías y PDFs se encuentran en Storage.

---

# 73. Data Retention

La política de retención deberá definirse comercial y legalmente.

El sistema debe estar preparado para conservar:

- informes;
- fotografías;
- observaciones;
- auditoría;
- historial de correcciones.

La eliminación de información deberá ser una operación controlada y auditada.

---

# 74. Future SaaS Considerations

La base está preparada para:

```text
Organization A
    ├── Users
    ├── Clients
    └── Inspections

Organization B
    ├── Users
    ├── Clients
    └── Inspections

Organization C
    ├── Users
    ├── Clients
    └── Inspections
```

Sin compartir información entre organizaciones.

Futuras funcionalidades SaaS:

- subscriptions;
- plans;
- usage limits;
- billing;
- invoices;
- organization onboarding;
- API keys;
- integrations.

No son parte del MVP.

---

# 75. OpenInspection Reference Boundary

OpenInspection se utilizará únicamente como referencia conceptual.

Se pueden estudiar:

- entidades;
- workflows;
- patrones de inspección;
- evidencia;
- offline;
- sincronización;
- reportes;
- portal;
- reinspecciones;
- auditoría;
- seguridad.

No se copiará directamente su código.

La implementación utilizará el modelo de datos propio definido en este documento.

El proyecto deberá mantener:

```text
docs/THIRD_PARTY_LICENSES.md
```

para documentar dependencias y referencias externas.

---

# 76. Database Implementation Order

La implementación recomendada es:

```text
1. Extensions
      ↓
2. Organizations
      ↓
3. Users / Roles
      ↓
4. Clients
      ↓
5. Projects
      ↓
6. Buildings
      ↓
7. Floors
      ↓
8. Properties
      ↓
9. Service Types
      ↓
10. Scheduling
      ↓
11. Templates
      ↓
12. Inspections
      ↓
13. Observations
      ↓
14. Plans
      ↓
15. Measurements
      ↓
16. Evidence
      ↓
17. Reports
      ↓
18. Actions
      ↓
19. Reinspections
      ↓
20. Audit
      ↓
21. Offline Sync
      ↓
22. RLS
      ↓
23. Storage Policies
      ↓
24. Seed Data
      ↓
25. Integration Tests
```

---

# 77. Definition of Done

El diseño de base de datos se considera listo para comenzar implementación cuando:

- [ ] todas las entidades principales están definidas;
- [ ] todas las foreign keys están definidas;
- [ ] los índices críticos están definidos;
- [ ] los estados están definidos;
- [ ] las reglas de tenant isolation están definidas;
- [ ] RLS está especificado;
- [ ] Storage está separado de PostgreSQL;
- [ ] agenda está separada de inspección;
- [ ] payment status está separado de appointment status;
- [ ] offline IDs están definidos;
- [ ] sync operations están definidas;
- [ ] reportes versionados están definidos;
- [ ] observaciones tienen evidencia;
- [ ] observaciones pueden generar acciones;
- [ ] acciones pueden generar reinspecciones;
- [ ] auditoría está definida;
- [ ] migraciones están versionadas;
- [ ] seed inicial está definido.

---

# 78. Final Domain Model

El modelo central del producto queda:

```text
                    ORGANIZATION
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
      USERS            CLIENTS          PROJECTS
       │                 │                 │
       │                 │              BUILDINGS
       │                 │                 │
       │                 │               FLOORS
       │                 │                 │
       │                 └──────────── PROPERTIES
       │                                   │
       │                              PROPERTY PLANS
       │                                   │
       ├──────────── SERVICE TYPES         │
       │                    │              │
       │                    ▼              │
       │               APPOINTMENTS ◄──────┘
       │                    │
       │                    ▼
       │               INSPECTIONS
       │                    │
       │          ┌─────────┼──────────┐
       │          │         │          │
       │         AREAS     ITEMS    OBSERVATIONS
       │                               │
       │                    ┌──────────┼─────────┐
       │                    │          │         │
       │                 EVIDENCE MEASUREMENTS ACTIONS
       │                                           │
       │                                           ▼
       │                                      REINSPECTIONS
       │
       ├── AUDIT LOGS
       ├── DEVICES
       └── SYNC OPERATIONS
```

---

# 79. Product Data Principle

La base de datos no debe ser solamente un repositorio de formularios.

Cada inspección debe producir datos estructurados que permitan evolucionar posteriormente hacia:

```text
INSPECTIONS
     ↓
STRUCTURED DEFECT DATA
     ↓
ANALYTICS
     ↓
CONSTRUCTION DEFECT INTELLIGENCE
     ↓
PREDICTIVE ANALYTICS
     ↓
AI / ML
```

La primera prioridad, sin embargo, es mantener:

> **Integridad + trazabilidad + evidencia + sincronización confiable.**

No se debe sacrificar la calidad del modelo de datos por incorporar IA o analítica avanzada prematuramente.