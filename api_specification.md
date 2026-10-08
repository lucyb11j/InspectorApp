# API Specification

**Proyecto:** Inspection Platform  
**Versión:** 1.0.0  
**Estado:** Diseño técnico  
**Backend:** Supabase / PostgreSQL  
**Clientes:** Flutter Inspector App + Nuxt Admin/Client Portal  
**Autenticación:** Supabase Auth / JWT  
**Formato:** JSON  
**Transporte:** HTTPS  
**Zona horaria:** UTC en backend; conversión a hora local en frontend

---

# 1. Objetivo

Definir la interfaz HTTP de la plataforma de inspección de departamentos para permitir:

- autenticación y autorización;
- gestión de organizaciones y usuarios;
- gestión de proyectos y departamentos;
- configuración de servicios;
- programación de inspecciones;
- registro manual de pagos;
- ejecución de inspecciones;
- trabajo offline y sincronización;
- gestión de observaciones;
- carga y consulta de evidencias;
- ubicación de observaciones sobre planos;
- generación y publicación de reportes;
- seguimiento de correcciones;
- reinspecciones;
- portal del cliente;
- auditoría;
- funciones futuras de IA.

La API debe permitir que el aplicativo móvil funcione sin conexión y que posteriormente sincronice la información con el servidor.

---

# 2. Principios

## 2.1 Offline First

El aplicativo Flutter no debe depender de Internet para ejecutar una inspección.

Flujo:

```text
Flutter
   ↓
SQLite / Drift
   ↓
Sync Queue
   ↓
API
   ↓
PostgreSQL
```

La API debe aceptar operaciones idempotentes para evitar duplicaciones durante reintentos.

---

## 2.2 Multi-tenant

Todas las entidades pertenecientes a una organización deben estar aisladas mediante:

```text
organization_id
```

La autorización debe impedir que un usuario de una organización consulte o modifique información de otra.

---

## 2.3 Seguridad por defecto

Todos los endpoints privados requieren:

```http
Authorization: Bearer <JWT>
```

La autorización se determina mediante:

1. usuario autenticado;
2. organización;
3. rol;
4. permisos sobre el recurso;
5. estado del recurso.

Nunca se debe confiar en `organization_id` enviado por el cliente para determinar la organización autorizada.

---

# 3. Base URL

## Desarrollo

```text
http://localhost:8000/api/v1
```

## Test

```text
https://api-test.example.com/api/v1
```

## Producción

```text
https://api.example.com/api/v1
```

El dominio real se definirá durante el despliegue.

---

# 4. Headers

## Solicitud autenticada

```http
Authorization: Bearer <JWT>
Content-Type: application/json
Accept: application/json
```

## Idempotencia

Para operaciones críticas:

```http
Idempotency-Key: <UUID>
```

Ejemplo:

```http
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
```

Debe utilizarse especialmente para:

- creación de inspecciones;
- creación de observaciones;
- creación de citas;
- sincronización;
- publicación de reportes;
- registro de pagos.

---

# 5. Autenticación

La autenticación será gestionada inicialmente mediante **Supabase Auth**.

## 5.1 Login

```http
POST /auth/login
```

### Request

```json
{
  "email": "usuario@example.com",
  "password": "********"
}
```

### Response

```json
{
  "data": {
    "access_token": "...",
    "refresh_token": "...",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "email": "usuario@example.com"
    }
  }
}
```

---

## 5.2 Refresh

```http
POST /auth/refresh
```

### Request

```json
{
  "refresh_token": "..."
}
```

---

## 5.3 Logout

```http
POST /auth/logout
```

**Autenticación:** requerida.

---

## 5.4 Usuario actual

```http
GET /auth/me
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "email": "usuario@example.com",
    "name": "Inspector",
    "role": "INSPECTOR",
    "organization_id": "uuid"
  }
}
```

---

# 6. Roles

Los roles iniciales son:

| Rol | Descripción |
|---|---|
| `OWNER` | Propietario de la organización |
| `ADMIN` | Administrador |
| `INSPECTOR` | Realiza inspecciones |
| `CLIENT` | Cliente final |

---

# 7. Matriz de autorización

| Recurso | OWNER | ADMIN | INSPECTOR | CLIENT |
|---|---:|---:|---:|---:|
| Organización | CRUD | R/U | R | - |
| Usuarios | CRUD | CRUD | - | - |
| Proyectos | CRUD | CRUD | R/U | R |
| Departamentos | CRUD | CRUD | R/U | R |
| Citas | CRUD | CRUD | R | R/C |
| Pagos | CRUD | CRUD | R | R |
| Inspecciones | CRUD | CRUD | CRUD | R |
| Observaciones | CRUD | CRUD | CRUD | R |
| Evidencias | CRUD | CRUD | CRUD | R |
| Planos | CRUD | CRUD | CRUD | R |
| Reportes | CRUD | CRUD | R/C | R |
| Reinspecciones | CRUD | CRUD | CRUD | R |
| Acciones | CRUD | CRUD | CRUD | R/U |
| Auditoría | R | R | - | - |

`C` = Create  
`R` = Read  
`U` = Update  
`D` = Delete

La autorización real debe reforzarse mediante RLS en PostgreSQL.

---

# 8. Convenciones de respuesta

## Éxito

```json
{
  "data": {},
  "meta": {}
}
```

## Error

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Los datos enviados no son válidos.",
    "details": {}
  }
}
```

---

# 9. Códigos HTTP

| Código | Uso |
|---:|---|
| 200 | Operación exitosa |
| 201 | Recurso creado |
| 204 | Operación exitosa sin contenido |
| 400 | Solicitud inválida |
| 401 | No autenticado |
| 403 | No autorizado |
| 404 | Recurso inexistente |
| 409 | Conflicto |
| 422 | Error de validación |
| 429 | Demasiadas solicitudes |
| 500 | Error interno |

---

# 10. Organizaciones

## Obtener organización

```http
GET /organization
```

**Roles:** OWNER, ADMIN

### Response

```json
{
  "data": {
    "id": "uuid",
    "name": "Inspection Engineering SAC",
    "legal_name": "Inspection Engineering SAC",
    "status": "ACTIVE"
  }
}
```

---

## Actualizar organización

```http
PATCH /organization
```

**Roles:** OWNER, ADMIN

### Request

```json
{
  "name": "Inspection Engineering SAC",
  "phone": "+51...",
  "email": "contacto@example.com"
}
```

---

# 11. Usuarios

## Listar usuarios

```http
GET /users
```

**Roles:** OWNER, ADMIN

### Parámetros

```text
page
limit
role
status
search
```

Ejemplo:

```http
GET /users?page=1&limit=20&role=INSPECTOR
```

---

## Crear usuario

```http
POST /users
```

**Roles:** OWNER, ADMIN

### Request

```json
{
  "email": "inspector@example.com",
  "name": "Juan Pérez",
  "role": "INSPECTOR"
}
```

---

## Actualizar usuario

```http
PATCH /users/{user_id}
```

---

## Desactivar usuario

```http
DELETE /users/{user_id}
```

Se recomienda soft delete/desactivación.

---

# 12. Clientes

## Crear cliente

```http
POST /clients
```

### Request

```json
{
  "name": "María López",
  "email": "maria@example.com",
  "phone": "+51999999999"
}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "name": "María López",
    "email": "maria@example.com",
    "phone": "+51999999999"
  }
}
```

---

## Listar clientes

```http
GET /clients
```

### Parámetros

```text
page
limit
search
```

---

## Obtener cliente

```http
GET /clients/{client_id}
```

---

## Actualizar cliente

```http
PATCH /clients/{client_id}
```

---

# 13. Proyectos

## Crear proyecto

```http
POST /projects
```

### Request

```json
{
  "name": "Residencial Los Cedros",
  "developer": "Constructora ABC",
  "address": "Lima",
  "description": "Proyecto residencial"
}
```

---

## Listar proyectos

```http
GET /projects
```

### Parámetros

```text
page
limit
status
search
```

---

## Obtener proyecto

```http
GET /projects/{project_id}
```

---

## Actualizar proyecto

```http
PATCH /projects/{project_id}
```

---

# 14. Edificios, pisos y departamentos

## Crear edificio

```http
POST /projects/{project_id}/buildings
```

## Listar edificios

```http
GET /projects/{project_id}/buildings
```

## Crear piso

```http
POST /buildings/{building_id}/floors
```

## Crear departamento

```http
POST /floors/{floor_id}/properties
```

### Request

```json
{
  "unit_code": "1204",
  "area_m2": 78.5,
  "bedrooms": 3,
  "bathrooms": 2
}
```

---

## Obtener departamento

```http
GET /properties/{property_id}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "unit_code": "1204",
    "area_m2": 78.5,
    "floor": 12,
    "building": "Torre A",
    "project": "Residencial Los Cedros"
  }
}
```

---

# 15. Servicios

Los servicios disponibles deben estar definidos en:

```text
service_types
```

Ejemplo:

```json
{
  "code": "INTEGRAL",
  "name": "Plan Integral",
  "price": 549,
  "currency": "PEN",
  "active": true
}
```

---

## Listar servicios

```http
GET /service-types
```

**Público:** Sí.

---

## Obtener servicio

```http
GET /service-types/{service_type_id}
```

---

# 16. Disponibilidad

No se utilizará inicialmente integración con Google Calendar, Outlook u otros calendarios.

La disponibilidad se determina mediante:

```text
availability_rules
+
appointments
```

---

## Consultar disponibilidad

```http
GET /availability
```

### Parámetros

```text
service_type_id
date
duration_minutes
```

Ejemplo:

```http
GET /availability?service_type_id=uuid&date=2026-10-15&duration_minutes=120
```

### Response

```json
{
  "data": {
    "date": "2026-10-15",
    "slots": [
      {
        "start": "09:00",
        "end": "11:00",
        "available": true
      },
      {
        "start": "11:00",
        "end": "13:00",
        "available": false
      },
      {
        "start": "14:00",
        "end": "16:00",
        "available": true
      }
    ]
  }
}
```

---

# 17. Citas / programación

## Crear solicitud de cita

```http
POST /appointments
```

**Roles:** CLIENT, ADMIN, OWNER.

### Request

```json
{
  "service_type_id": "uuid",
  "property_id": "uuid",
  "requested_start": "2026-10-15T09:00:00-05:00",
  "duration_minutes": 120,
  "notes": "Entrega programada por la constructora."
}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "status": "REQUESTED",
    "payment_status": "UNPAID",
    "requested_start": "2026-10-15T09:00:00-05:00",
    "duration_minutes": 120
  }
}
```

---

## Listar citas

```http
GET /appointments
```

### Parámetros

```text
status
payment_status
from
to
inspector_id
client_id
property_id
```

---

## Obtener cita

```http
GET /appointments/{appointment_id}
```

---

## Confirmar cita

```http
POST /appointments/{appointment_id}/confirm
```

**Roles:** OWNER, ADMIN.

El backend debe volver a verificar disponibilidad antes de confirmar.

---

## Solicitar reprogramación

```http
POST /appointments/{appointment_id}/reschedule
```

### Request

```json
{
  "requested_start": "2026-10-16T14:00:00-05:00",
  "reason": "El cliente solicita cambio de horario."
}
```

---

## Cancelar cita

```http
POST /appointments/{appointment_id}/cancel
```

### Request

```json
{
  "reason": "Cliente solicita cancelación."
}
```

---

## Completar cita

```http
POST /appointments/{appointment_id}/complete
```

**Roles:** ADMIN, INSPECTOR.

---

# 18. Pagos

El MVP no utilizará pasarela de pago.

El pago se registra manualmente.

## Registrar pago

```http
POST /appointments/{appointment_id}/payments
```

**Roles:** OWNER, ADMIN.

### Request

```json
{
  "amount": 549,
  "currency": "PEN",
  "method": "TRANSFER",
  "reference": "OP-123456",
  "paid_at": "2026-10-10T18:30:00Z",
  "notes": "Transferencia bancaria."
}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "amount": 549,
    "currency": "PEN",
    "status": "PAID"
  }
}
```

---

## Listar pagos

```http
GET /appointments/{appointment_id}/payments
```

---

# 19. Plantillas de inspección

## Listar plantillas

```http
GET /inspection-templates
```

### Parámetros

```text
type
active
```

Tipos iniciales:

```text
DEPARTAMENTO_NUEVO
DEPARTAMENTO_RECEPCION
PRE_ENTREGA
POSTVENTA
REINSPECCION
```

---

## Obtener plantilla

```http
GET /inspection-templates/{template_id}
```

La respuesta debe incluir:

```text
areas
items
orden
categorías
```

---

# 20. Crear inspección

```http
POST /inspections
```

**Roles:** ADMIN, INSPECTOR.

### Request

```json
{
  "appointment_id": "uuid",
  "property_id": "uuid",
  "template_id": "uuid",
  "scheduled_at": "2026-10-15T09:00:00Z"
}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "status": "SCHEDULED",
    "property_id": "uuid",
    "template_id": "uuid"
  }
}
```

---

# 21. Obtener inspección

```http
GET /inspections/{inspection_id}
```

La respuesta debe incluir:

```text
inspection
property
client
areas
items
observations
evidence
plan
actions
```

---

# 22. Iniciar inspección

```http
POST /inspections/{inspection_id}/start
```

**Roles:** INSPECTOR, ADMIN.

---

# 23. Finalizar inspección

```http
POST /inspections/{inspection_id}/complete
```

Antes de completar se deben validar las condiciones mínimas configuradas por la organización.

Ejemplo:

```text
Todos los ambientes registrados
Observaciones guardadas
Evidencias sincronizadas
Checklist completado
```

---

# 24. Áreas

## Crear área

```http
POST /inspections/{inspection_id}/areas
```

### Request

```json
{
  "name": "Dormitorio principal",
  "area_type": "BEDROOM",
  "order": 3
}
```

---

## Listar áreas

```http
GET /inspections/{inspection_id}/areas
```

---

## Actualizar área

```http
PATCH /inspection-areas/{area_id}
```

---

# 25. Checklist

## Obtener checklist

```http
GET /inspection-areas/{area_id}/items
```

---

## Registrar resultado

```http
PATCH /inspection-items/{item_id}
```

### Request

```json
{
  "result": "OBSERVED",
  "notes": "Se detecta desprendimiento."
}
```

Resultados:

```text
PENDING
PASS
OBSERVED
NOT_APPLICABLE
NOT_VERIFIED
```

---

# 26. Observaciones

## Crear observación

```http
POST /inspections/{inspection_id}/observations
```

### Request

```json
{
  "area_id": "uuid",
  "category": "ACABADOS",
  "element": "Pared",
  "title": "Fisura superficial",
  "description": "Se observa fisura vertical superficial.",
  "severity": "MENOR",
  "recommendation": "Solicitar reparación y acabado.",
  "status": "PENDIENTE"
}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "local_id": "uuid",
    "severity": "MENOR",
    "status": "PENDIENTE",
    "created_at": "2026-10-15T14:35:00Z"
  }
}
```

---

# 27. Actualizar observación

```http
PATCH /observations/{observation_id}
```

---

# 28. Eliminar observación

```http
DELETE /observations/{observation_id}
```

Durante una inspección activa se recomienda utilizar eliminación lógica.

---

# 29. Biblioteca de observaciones

La biblioteca permite reutilizar descripciones frecuentes.

## Buscar

```http
GET /observation-library
```

### Parámetros

```text
category
area
element
search
severity
```

---

## Crear comentario predefinido

```http
POST /observation-library
```

**Roles:** OWNER, ADMIN.

---

# 30. Planos

## Subir plano

```http
POST /properties/{property_id}/plans
```

El archivo se carga mediante Storage.

### Metadata

```json
{
  "name": "plano_departamento_1204.pdf",
  "mime_type": "application/pdf"
}
```

---

## Listar planos

```http
GET /properties/{property_id}/plans
```

---

## Obtener plano

```http
GET /plans/{plan_id}
```

---

# 31. Marcadores sobre plano

Cada observación puede tener una posición relativa sobre el plano.

Las coordenadas se normalizan:

```text
x ∈ [0,1]
y ∈ [0,1]
```

## Crear marcador

```http
POST /observations/{observation_id}/plan-marker
```

### Request

```json
{
  "plan_id": "uuid",
  "x": 0.635,
  "y": 0.421
}
```

---

## Obtener marcadores

```http
GET /plans/{plan_id}/markers
```

---

# 32. Mediciones

## Registrar medición

```http
POST /observations/{observation_id}/measurements
```

### Request

```json
{
  "type": "LENGTH",
  "value": 2.45,
  "unit": "m",
  "description": "Ancho de vano."
}
```

Tipos:

```text
LENGTH
WIDTH
HEIGHT
AREA
SLOPE
MOISTURE
VOLTAGE
OTHER
```

---

# 33. Evidencias / fotografías

La fotografía debe seguir el flujo:

```text
Captura
  ↓
Archivo local
  ↓
SQLite metadata
  ↓
Sync Queue
  ↓
Upload
  ↓
Storage
  ↓
Verificación SHA-256
  ↓
Evidence
```

---

## Solicitar URL de subida

```http
POST /evidence/upload-url
```

### Request

```json
{
  "inspection_id": "uuid",
  "filename": "foto_001.jpg",
  "mime_type": "image/jpeg",
  "size": 2456789,
  "sha256": "..."
}
```

### Response

```json
{
  "data": {
    "upload_url": "...",
    "file_path": "org/uuid/inspection/uuid/evidence/uuid.jpg",
    "expires_in": 900
  }
}
```

---

## Registrar evidencia

```http
POST /evidence
```

### Request

```json
{
  "inspection_id": "uuid",
  "observation_id": "uuid",
  "file_path": "...",
  "mime_type": "image/jpeg",
  "size": 2456789,
  "sha256": "...",
  "captured_at": "2026-10-15T14:32:10Z",
  "device_id": "uuid",
  "sequence": 1
}
```

---

## Listar evidencias

```http
GET /inspections/{inspection_id}/evidence
```

Parámetros:

```text
observation_id
area_id
page
limit
```

---

# 34. Sincronización offline

Este es uno de los endpoints más importantes del sistema.

## Sincronizar operaciones

```http
POST /sync
```

### Request

```json
{
  "device_id": "uuid",
  "operations": [
    {
      "operation_id": "uuid",
      "entity": "observation",
      "action": "CREATE",
      "local_id": "uuid",
      "payload": {},
      "client_version": 1,
      "created_at": "2026-10-15T14:35:00Z"
    }
  ]
}
```

---

## Response

```json
{
  "data": {
    "processed": 1,
    "successful": 1,
    "failed": 0,
    "operations": [
      {
        "operation_id": "uuid",
        "status": "SYNCED",
        "server_id": "uuid",
        "server_version": 1
      }
    ]
  }
}
```

---

# 35. Estados de sincronización

```text
PENDING
UPLOADING
SYNCED
FAILED
CONFLICT
```

---

# 36. Idempotencia de sincronización

Si el dispositivo envía nuevamente:

```text
operation_id = X
```

el servidor debe reconocer la operación existente.

No debe crear un segundo registro.

Ejemplo:

```text
Primer envío:
operation X → CREATE observation 123

Reintento:
operation X → ya procesada

Resultado:
SYNCED / observation 123
```

---

# 37. Conflictos

En MVP no se implementará colaboración simultánea.

Modelo:

```text
Inspector = editor principal
```

Se utilizará:

```text
version
updated_at
```

Si el servidor detecta una versión incompatible:

```http
409 Conflict
```

### Response

```json
{
  "error": {
    "code": "VERSION_CONFLICT",
    "message": "El registro fue modificado previamente.",
    "server_version": 3,
    "client_version": 2
  }
}
```

El conflicto debe registrarse para resolución.

---

# 38. Acciones / correcciones

Una observación puede generar una acción.

## Crear acción

```http
POST /observations/{observation_id}/actions
```

### Request

```json
{
  "description": "Reparar acabado de pared.",
  "assigned_to": "uuid",
  "due_date": "2026-10-25"
}
```

Estados:

```text
PENDIENTE
EN_CORRECCIÓN
CORREGIDO
RECHAZADO
VERIFICADO
CERRADO
```

---

## Actualizar acción

```http
PATCH /actions/{action_id}
```

---

# 39. Reinspecciones

## Crear reinspección

```http
POST /inspections/{inspection_id}/reinspections
```

### Request

```json
{
  "scheduled_at": "2026-10-30T15:00:00Z",
  "reason": "Verificación de correcciones."
}
```

---

## Obtener reinspección

```http
GET /reinspections/{reinspection_id}
```

---

## Registrar resultado

```http
POST /reinspections/{reinspection_id}/observations/{observation_id}
```

### Request

```json
{
  "result": "VERIFIED",
  "notes": "La observación fue corregida.",
  "evidence_ids": [
    "uuid"
  ]
}
```

---

# 40. Reportes

## Generar reporte

```http
POST /inspections/{inspection_id}/reports
```

### Request

```json
{
  "template_id": "uuid",
  "format": "PDF"
}
```

### Response

```json
{
  "data": {
    "id": "uuid",
    "status": "GENERATING"
  }
}
```

---

## Consultar estado

```http
GET /reports/{report_id}
```

Estados:

```text
DRAFT
GENERATING
READY
PUBLISHED
ARCHIVED
```

---

## Publicar reporte

```http
POST /reports/{report_id}/publish
```

**Roles:** OWNER, ADMIN, INSPECTOR.

Al publicar:

- se congela el contenido;
- se registra hash SHA-256;
- se registra usuario;
- se registra fecha;
- se genera evento de auditoría.

---

## Descargar reporte

```http
GET /reports/{report_id}/download
```

La API debe devolver una URL temporal firmada.

---

# 41. Portal del cliente

El cliente solamente debe acceder a recursos explícitamente asociados con su cuenta.

## Mis propiedades

```http
GET /client/properties
```

---

## Mis inspecciones

```http
GET /client/inspections
```

---

## Detalle de inspección

```http
GET /client/inspections/{inspection_id}
```

---

## Observaciones

```http
GET /client/inspections/{inspection_id}/observations
```

---

## Evidencias

```http
GET /client/observations/{observation_id}/evidence
```

---

## Plano

```http
GET /client/properties/{property_id}/plans
```

---

## Reporte

```http
GET /client/reports/{report_id}/download
```

---

# 42. Auditoría

Los eventos importantes deben registrarse automáticamente.

## Consultar auditoría

```http
GET /audit-logs
```

**Roles:** OWNER, ADMIN.

### Parámetros

```text
user_id
action
entity_type
entity_id
from
to
page
limit
```

Eventos mínimos:

```text
LOGIN
LOGOUT
CREATE_INSPECTION
UPDATE_INSPECTION
CREATE_OBSERVATION
UPDATE_OBSERVATION
UPLOAD_EVIDENCE
PUBLISH_REPORT
SIGN_REPORT
DOWNLOAD_REPORT
CREATE_REINSPECTION
CHANGE_STATUS
DELETE
REGISTER_PAYMENT
CONFIRM_APPOINTMENT
```

---

# 43. IA

La IA no será necesaria para ejecutar una inspección básica.

Se utilizará posteriormente mediante una abstracción:

```text
AIProvider
    ├── OllamaProvider
    └── ExternalProvider
```

## Crear tarea de IA

```http
POST /ai/tasks
```

### Request

```json
{
  "type": "DRAFT_OBSERVATION",
  "observation_id": "uuid"
}
```

Tipos iniciales:

```text
DRAFT_OBSERVATION
NORMALIZE_DESCRIPTION
SUGGEST_SEVERITY
GENERATE_SUMMARY
PHOTO_ASSISTANCE
```

---

## Consultar tarea

```http
GET /ai/tasks/{task_id}
```

La IA nunca debe publicar automáticamente una observación técnica ni determinar cumplimiento normativo sin revisión humana.

---

# 44. Contract-to-Delivery Audit

Funcionalidad posterior al MVP.

## Subir documento

```http
POST /properties/{property_id}/documents
```

---

## Crear requisito

```http
POST /documents/{document_id}/requirements
```

---

## Registrar resultado de cumplimiento

```http
POST /requirements/{requirement_id}/compliance
```

Resultados:

```text
COMPLIANT
PARTIAL
NON_COMPLIANT
NOT_VERIFIED
```

---

# 45. Paginación

Los endpoints de listado utilizarán:

```text
page
limit
```

Ejemplo:

```http
GET /inspections?page=1&limit=20
```

Respuesta:

```json
{
  "data": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 87,
    "total_pages": 5
  }
}
```

---

# 46. Filtros

Los filtros deben utilizar parámetros URL.

Ejemplo:

```http
GET /observations?
inspection_id=uuid
&severity=MAYOR
&status=PENDIENTE
&area_id=uuid
```

---

# 47. Ordenamiento

Formato:

```text
sort=created_at
order=desc
```

Ejemplo:

```http
GET /observations?sort=severity&order=desc
```

---

# 48. Validación

Todos los endpoints deben validar:

- UUID;
- tipos;
- longitud;
- valores permitidos;
- fechas;
- tamaños;
- MIME types;
- ownership;
- permisos;
- relaciones entre entidades.

No confiar en validación exclusiva del frontend.

---

# 49. Rate limiting

Aplicar límites especialmente a:

```text
/auth/*
/sync
/evidence/*
/ai/*
/reports/*
```

Ejemplo conceptual:

```text
Login:
5 intentos / minuto / IP

API general:
100 requests / minuto / usuario

Upload:
20 operaciones / minuto / usuario

AI:
10 tareas / minuto / usuario
```

Los valores definitivos se calibrarán durante pruebas.

---

# 50. Seguridad de archivos

La API nunca debe confiar únicamente en:

```text
filename
extension
mime_type enviado por cliente
```

Debe validar:

- MIME real;
- tamaño;
- extensión;
- hash;
- propietario;
- organización;
- relación con inspección;
- ruta de Storage.

Los buckets de evidencias y reportes serán privados.

El acceso se realizará mediante URLs firmadas de duración limitada.

---

# 51. Reglas de autorización críticas

Nunca permitir:

```http
GET /observations/{id}
```

simplemente porque el UUID sea válido.

La API debe verificar:

```text
observation
    ↓
inspection
    ↓
property
    ↓
organization
    ↓
current_user
```

De esta manera se evita:

```text
Usuario A
    ↓
UUID de observación de organización B
    ↓
Acceso indebido
```

---

# 52. RLS

La seguridad del backend debe tener una segunda capa mediante PostgreSQL Row Level Security.

Conceptualmente:

```sql
organization_id = current_user_organization_id()
```

Para clientes:

```text
client_id = current_user_client_id()
```

Nunca utilizar únicamente controles del frontend.

---

# 53. Flujo completo de una inspección

```text
CLIENTE
   │
   ├── Consulta servicios
   │
   ├── Selecciona fecha/hora
   │
   └── Solicita cita
           │
           ▼
      APPOINTMENT
           │
           ├── Admin verifica
           ├── Registra pago
           └── Confirma
                  │
                  ▼
              INSPECCIÓN
                  │
                  ▼
            APP FLUTTER
                  │
                  ├── Descarga datos
                  │
                  ├── Guarda en SQLite
                  │
                  ├── Abre plano
                  │
                  ├── Selecciona área
                  │
                  ├── Checklist
                  │
                  ├── Observación
                  │
                  ├── Fotografía
                  │
                  └── Medición
                  │
                  ▼
              SYNC QUEUE
                  │
                  ▼
                 API
                  │
                  ▼
             POSTGRESQL
                  │
                  ▼
              EVIDENCIAS
                  │
                  ▼
               REPORTE
                  │
                  ▼
             PORTAL CLIENTE
                  │
                  ▼
             CORRECCIONES
                  │
                  ▼
             REINSPECCIÓN
```

---

# 54. Flujo de una cita sin calendario externo

El sistema NO necesita Google Calendar ni Outlook para el MVP.

```text
Cliente
   ↓
GET /availability
   ↓
Selecciona horario
   ↓
POST /appointments
   ↓
REQUESTED
   ↓
Admin revisa
   ↓
Pago manual
   ↓
POST /appointments/{id}/payments
   ↓
PAID
   ↓
POST /appointments/{id}/confirm
   ↓
CONFIRMED
```

La base de datos debe impedir que dos citas confirmadas ocupen el mismo intervalo para el mismo inspector/recurso.

---

# 55. Flujo offline

```text
Inspector
   ↓
Crear observación
   ↓
local_id
   ↓
SQLite
   ↓
sync_status = PENDING
   ↓
Internet disponible
   ↓
POST /sync
   ↓
Servidor procesa
   ↓
server_id
   ↓
ACK
   ↓
SQLite:
SYNCED
```

---

# 56. Contrato de datos compartido

Para evitar discrepancias entre Flutter, Nuxt y backend, los objetos principales deben mantener contratos consistentes.

Entidades principales:

```text
User
Organization
Client
Project
Building
Floor
Property
ServiceType
Appointment
Payment
Inspection
InspectionArea
InspectionItem
Observation
Evidence
Measurement
PropertyPlan
PlanMarker
Action
Reinspection
Report
AuditLog
SyncOperation
```

Los esquemas de validación pueden mantenerse en:

```text
packages/schemas/
```

---

# 57. Estructura recomendada del backend

```text
backend/
├── api/
│   └── v1/
│       ├── auth/
│       ├── users/
│       ├── organizations/
│       ├── clients/
│       ├── projects/
│       ├── properties/
│       ├── service-types/
│       ├── availability/
│       ├── appointments/
│       ├── payments/
│       ├── inspections/
│       ├── observations/
│       ├── evidence/
│       ├── plans/
│       ├── sync/
│       ├── actions/
│       ├── reinspections/
│       ├── reports/
│       ├── audit/
│       └── ai/
├── services/
├── repositories/
├── validators/
├── authorization/
└── middleware/
```

---

# 58. Estados importantes

## Appointment

```text
REQUESTED
PENDING_CONFIRMATION
CONFIRMED
RESCHEDULE_REQUESTED
RESCHEDULED
CANCELLED
COMPLETED
NO_SHOW
```

## Payment

```text
UNPAID
PAYMENT_PENDING
PAID
REFUNDED
NOT_REQUIRED
```

## Inspection

```text
DRAFT
SCHEDULED
IN_PROGRESS
COMPLETED
REPORT_GENERATING
REPORT_READY
PUBLISHED
CANCELLED
```

## Observation

```text
ABIERTO
EN_CORRECCIÓN
CORREGIDO
RECHAZADO
VERIFICADO
CERRADO
```

## Severity

```text
INFO
MENOR
MODERADA
MAYOR
CRÍTICA
```

La severidad es una clasificación interna de la plataforma y **no constituye una certificación normativa**.

---

# 59. Versionado

La API utilizará versionado explícito:

```text
/api/v1
```

Los cambios incompatibles deberán introducir:

```text
/api/v2
```

No modificar silenciosamente el contrato de `v1`.

---

# 60. Observabilidad

Cada request debe poder rastrearse mediante:

```http
X-Request-ID: <UUID>
```

Los logs deben registrar:

```text
request_id
user_id
organization_id
method
path
status_code
duration_ms
timestamp
```

Nunca registrar:

```text
password
JWT
refresh_token
service_role_key
secret keys
```

---

# 61. Endpoints MVP

La primera versión no necesita implementar toda la especificación.

Prioridad:

### P0 — indispensable

```text
POST /auth/login
POST /auth/refresh
GET  /auth/me

GET  /service-types
GET  /availability

POST /appointments
GET  /appointments/{id}
POST /appointments/{id}/confirm
POST /appointments/{id}/cancel

POST /appointments/{id}/payments

POST /inspections
GET  /inspections/{id}
POST /inspections/{id}/start
POST /inspections/{id}/complete

GET  /inspections/{id}/areas
POST /inspections/{id}/areas

GET  /inspection-areas/{id}/items
PATCH /inspection-items/{id}

POST /inspections/{id}/observations
PATCH /observations/{id}

POST /evidence/upload-url
POST /evidence
GET  /inspections/{id}/evidence

GET  /properties/{id}/plans
POST /properties/{id}/plans

POST /observations/{id}/plan-marker
GET  /plans/{id}/markers

POST /sync

POST /inspections/{id}/reports
GET  /reports/{id}
GET  /reports/{id}/download
```

---

# 62. P1 — segunda etapa

```text
POST /observations/{id}/actions
PATCH /actions/{id}

POST /inspections/{id}/reinspections
GET  /reinspections/{id}

GET /client/inspections
GET /client/observations/{id}/evidence
GET /client/reports/{id}/download

GET /audit-logs
```

---

# 63. P2 — funcionalidades posteriores

```text
POST /ai/tasks
GET  /ai/tasks/{id}

POST /properties/{id}/documents
POST /documents/{id}/requirements
POST /requirements/{id}/compliance
```

---

# 64. Fuera del MVP

No implementar inicialmente:

```text
Google Calendar
Microsoft Calendar
Online payment gateway
CRM completo
SMS
Marketplace
QuickBooks
Facturación automática compleja
Yjs
CRDT
Colaboración simultánea
Spectora import
Cloudflare Workers
D1
R2
KV
Durable Objects
Multi-provider AI avanzado
ML predictivo
```

Estas funcionalidades pueden incorporarse posteriormente sin romper el núcleo si se mantienen los contratos de dominio.

---

# 65. Pruebas obligatorias

La API debe contar como mínimo con:

## Auth

```text
Usuario válido
Usuario inválido
Token expirado
Token inexistente
```

## Authorization

```text
OWNER → organización propia
CLIENT → solamente sus propiedades
INSPECTOR → inspecciones asignadas
Usuario A → no puede acceder a organización B
```

## Appointments

```text
Horario disponible
Horario ocupado
Doble confirmación simultánea
Cancelación
Reprogramación
Pago
```

## Offline

```text
Create offline
Reconnect
Retry
Duplicate operation
Conflict
Lost connection during upload
```

## Evidence

```text
Archivo válido
Archivo demasiado grande
MIME inválido
Hash incorrecto
Usuario sin autorización
```

## Reports

```text
Generación
Publicación
Hash
Acceso privado
Descarga autorizada
```

---

# 66. Criterio de aceptación de la API MVP

La API se considera lista cuando:

- [ ] Flutter puede autenticarse.
- [ ] Cliente puede solicitar una cita.
- [ ] El sistema puede detectar horarios ocupados.
- [ ] Admin puede confirmar una cita.
- [ ] Admin puede registrar pago manual.
- [ ] Inspector puede descargar una inspección.
- [ ] Inspector puede trabajar sin Internet.
- [ ] Inspector puede crear observaciones offline.
- [ ] Inspector puede tomar fotografías offline.
- [ ] Las fotografías se sincronizan correctamente.
- [ ] Las operaciones repetidas no generan duplicados.
- [ ] Los conflictos son detectados.
- [ ] Las observaciones pueden ubicarse en el plano.
- [ ] El reporte PDF puede generarse.
- [ ] El cliente puede consultar sus observaciones.
- [ ] El cliente puede descargar el reporte.
- [ ] La información entre organizaciones está aislada.
- [ ] Todas las operaciones críticas quedan auditadas.

---

# 67. Regla arquitectónica final

La API debe considerarse el **contrato estable entre el dominio de negocio y las aplicaciones**.

La implementación concreta puede cambiar:

```text
Supabase
        ↓
otro PostgreSQL
        ↓
otro backend
```

o:

```text
Ollama
        ↓
otro proveedor de IA
```

sin modificar el dominio principal:

```text
Appointment
Inspection
Observation
Evidence
Plan
Report
Reinspection
```

La arquitectura debe priorizar:

```text
OFFLINE FIRST
+
EVIDENCE FIRST
+
SECURITY BY DESIGN
+
MULTI-TENANT
+
IDEMPOTENT SYNC
+
HUMAN IN THE LOOP
+
LOW COST
+
MODULARITY
```

El objetivo del MVP no es tener una API grande, sino una API pequeña que permita ejecutar de principio a fin una inspección real y entregar un reporte profesional.