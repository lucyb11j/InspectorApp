# API_SPECIFICATION.md

# Especificación de API - Plataforma de Inspección Técnica

**Versión:** 1.0
**Fecha:** 2026-10-07
**Estado:** Borrador inicial

Este documento describe la especificación de la API para la Plataforma de Inspección Técnica, basándose en los requisitos de producto (`PRODUCT_REQUIREMENTS.md`) y el diseño de base de datos (`database.md`). La API será el principal punto de comunicación entre la aplicación móvil del inspector, las aplicaciones web (administrativa y portal del cliente) y el backend (`Supabase`/servicios de backend).

---

## 1. Principios Generales de la API

*   **RESTful:** Utilizar principios REST para recursos y acciones.
*   **JSON:** Todas las peticiones y respuestas utilizarán JSON.
*   **Autenticación:** JWT (JSON Web Tokens) gestionados por Supabase Auth.
*   **Autorización:** Basada en roles (`user_role` ENUM) y políticas de `Row Level Security (RLS)` de PostgreSQL.
*   **Multi-tenancy:** Todas las operaciones a nivel de datos estarán restringidas por `organization_id`.
*   **Idempotencia:** Las operaciones de creación y actualización (especialmente para sincronización offline) deben ser idempotentes.
*   **Validación:** Validación robusta de entrada de datos en el servidor.
*   **Errores:** Respuestas de error claras con códigos de estado HTTP apropiados y mensajes descriptivos.
*   **Versión:** Incluir `X-API-Version` header en las peticiones si se implementan versiones de API.

---

## 2. Base URL

Se asumirá que la API se expone a través de la URL de Supabase generada para el proyecto, o a través de un proxy/servicio de backend que la encapsule.

Ejemplo: `https://[SUPABASE_PROJECT_REF].supabase.co/rest/v1/`

---

## 3. Autenticación y Autorización

*   **Autenticación:** Utilizar tokens JWT obtenidos de Supabase Auth. El token se enviará en el header `Authorization: Bearer <token>`.
*   **Autorización:**
    *   **RLS:** Las políticas de RLS de PostgreSQL aplicarán filtros a nivel de fila basados en el `organization_id` del usuario autenticado y su `role`.
    *   **Backend Services:** Para operaciones más complejas o que requieran lógica de negocio adicional (ej. generación de informes PDF, lógica de sincronización avanzada, integración con IA), los servicios de backend implementarán una lógica de autorización más fina.
    *   **Roles:** Los roles (`OWNER`, `ADMIN`, `INSPECTOR`, `CLIENT`) definidos en `database.md` determinarán los permisos de acceso a los endpoints y recursos.

---

## 4. Endpoints de la API (MVP Operativo)

Esta sección describe los endpoints principales necesarios para el MVP, agrupados por recurso.

### 4.1. Recursos de la Organización

*   **GET /organizations/{id}**
    *   **Descripción:** Obtiene detalles de una organización.
    *   **Permisos:** OWNER, ADMIN de la organización.
    *   **Respuesta:** Objeto `Organization`.

*   **GET /organization_settings**
    *   **Descripción:** Obtiene la configuración de la organización del usuario.
    *   **Permisos:** Cualquier usuario autenticado de la organización.
    *   **Respuesta:** Objeto `OrganizationSettings`.

*   **PATCH /organization_settings**
    *   **Descripción:** Actualiza la configuración de la organización.
    *   **Permisos:** OWNER, ADMIN de la organización.
    *   **Cuerpo:** Objeto `OrganizationSettings` parcial con los campos a actualizar.

### 4.2. Recursos de Usuarios y Clientes

*   **GET /users**
    *   **Descripción:** Lista usuarios de la organización.
    *   **Permisos:** OWNER, ADMIN. INSPECTOR puede ver una lista limitada (ej. otros inspectores).
    *   **Parámetros:** `role` (filtro), `active` (filtro), `offset`, `limit`.
    *   **Respuesta:** Array de objetos `User`.

*   **GET /users/{id}**
    *   **Descripción:** Obtiene detalles de un usuario.
    *   **Permisos:** OWNER, ADMIN. Usuario puede ver su propio perfil.
    *   **Respuesta:** Objeto `User`.

*   **PATCH /users/{id}**
    *   **Descripción:** Actualiza detalles de un usuario.
    *   **Permisos:** OWNER, ADMIN. Usuario puede actualizar su propio perfil (limitado).
    *   **Cuerpo:** Objeto `User` parcial.

*   **GET /clients**
    *   **Descripción:** Lista clientes de la organización.
    *   **Permisos:** OWNER, ADMIN.
    *   **Parámetros:** `search` (por nombre, email, documento), `offset`, `limit`.
    *   **Respuesta:** Array de objetos `Client`.

*   **GET /clients/{id}**
    *   **Descripción:** Obtiene detalles de un cliente.
    *   **Permisos:** OWNER, ADMIN. CLIENT puede ver su propio registro.
    *   **Respuesta:** Objeto `Client`.

*   **POST /clients**
    *   **Descripción:** Crea un nuevo cliente.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `Client`.
    *   **Respuesta:** Objeto `Client` creado.

*   **PATCH /clients/{id}**
    *   **Descripción:** Actualiza detalles de un cliente.
    *   **Permisos:** OWNER, ADMIN. CLIENT puede actualizar su propio registro (limitado).
    *   **Cuerpo:** Objeto `Client` parcial.

### 4.3. Recursos de Proyectos e Inmuebles

*   **GET /projects**
    *   **Descripción:** Lista proyectos de la organización.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (proyectos asignados).
    *   **Respuesta:** Array de objetos `Project`.

*   **GET /projects/{id}/properties**
    *   **Descripción:** Lista propiedades de un proyecto.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (propiedades en sus proyectos).
    *   **Respuesta:** Array de objetos `Property`.

*   **GET /properties/{id}**
    *   **Descripción:** Obtiene detalles de una propiedad.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (propiedades asignadas), CLIENT (sus propiedades).
    *   **Respuesta:** Objeto `Property`.

*   **POST /properties/{id}/plans**
    *   **Descripción:** Carga un plano para una propiedad.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** `multipart/form-data` con el archivo del plano y `name`, `page_number` (opcional), `width` (opcional), `height` (opcional).
    *   **Respuesta:** Objeto `PropertyPlan` creado.

*   **GET /properties/{id}/plans**
    *   **Descripción:** Lista planos de una propiedad.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR, CLIENT (sus propiedades).
    *   **Respuesta:** Array de objetos `PropertyPlan`.

*   **GET /property_plans/{id}/download**
    *   **Descripción:** Descarga un plano específico (retorna una URL firmada).
    *   **Permisos:** OWNER, ADMIN, INSPECTOR, CLIENT (con permisos).
    *   **Respuesta:** Objeto `{ "signed_url": "..." }`.

### 4.4. Recursos de Servicios y Citas

*   **GET /service_types**
    *   **Descripción:** Lista los tipos de servicio/planes configurados.
    *   **Permisos:** Todos los usuarios autenticados, o público para la web de booking.
    *   **Respuesta:** Array de objetos `ServiceType` (incluye precio y duración).

*   **GET /appointments/availability**
    *   **Descripción:** Consulta la disponibilidad para un inspector o para la organización en un rango de fechas.
    *   **Permisos:** Todos los usuarios autenticados (para simulación), público (para solicitud de cita).
    *   **Parámetros:** `start_date`, `end_date`, `duration_minutes`, `inspector_id` (opcional).
    *   **Respuesta:** Array de objetos `{ date: "YYYY-MM-DD", time_slots: ["HH:MM", ...] }`.

*   **POST /appointments**
    *   **Descripción:** Un cliente solicita una nueva cita.
    *   **Permisos:** Público (si se permite booking abierto) o CLIENT (si requiere login).
    *   **Cuerpo:** Objeto `Appointment` parcial (campos `client_id`, `property_id`, `service_type_id`, `requested_start`, `requested_end`, `client_notes`).
    *   **Respuesta:** Objeto `Appointment` creado (con status `REQUESTED`).

*   **GET /appointments/{id}**
    *   **Descripción:** Obtiene detalles de una cita.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus citas), CLIENT (sus citas).
    *   **Respuesta:** Objeto `Appointment` completo.

*   **PATCH /appointments/{id}/confirm**
    *   **Descripción:** Confirma una cita (actualiza `status` a `CONFIRMED`, `confirmed_start`, `confirmed_end`).
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `{ "confirmed_start": "...", "confirmed_end": "...", "inspector_id": "..." }`.

*   **PATCH /appointments/{id}/cancel**
    *   **Descripción:** Cancela una cita.
    *   **Permisos:** OWNER, ADMIN. CLIENT puede cancelar su propia cita (con restricciones).
    *   **Cuerpo:** Objeto `{ "reason": "..." }`.

*   **PATCH /appointments/{id}/payment_status**
    *   **Descripción:** Actualiza el estado de pago de una cita (manual).
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `{ "payment_status": "PAID" | "UNPAID" | ... }`, `payment_method`, `payment_reference`, `paid_at`.

### 4.5. Recursos de Plantillas y Checklists

*   **GET /inspection_templates**
    *   **Descripción:** Lista plantillas de inspección.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR.
    *   **Respuesta:** Array de objetos `InspectionTemplate`.

*   **GET /inspection_templates/{id}**
    *   **Descripción:** Obtiene detalles de una plantilla con sus áreas e ítems.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR.
    *   **Respuesta:** Objeto `InspectionTemplate` anidado con `TemplateArea` y `TemplateItem`.

*   **GET /observation_library**
    *   **Descripción:** Lista la biblioteca de observaciones.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR.
    *   **Respuesta:** Array de objetos `ObservationLibrary`.

*   **POST /observation_library**
    *   **Descripción:** Crea una nueva entrada en la biblioteca de observaciones.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `ObservationLibrary`.
    *   **Respuesta:** Objeto `ObservationLibrary` creado.

*   **PATCH /observation_library/{id}**
    *   **Descripción:** Actualiza una entrada de la biblioteca de observaciones.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `ObservationLibrary` parcial.

### 4.6. Recursos de Inspecciones (Core MVP)

*   **GET /inspections**
    *   **Descripción:** Lista inspecciones de la organización.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones), CLIENT (sus inspecciones).
    *   **Parámetros:** `status`, `inspector_id`, `client_id`, `property_id`, `offset`, `limit`.
    *   **Respuesta:** Array de objetos `Inspection` (resumen).

*   **GET /inspections/{id}**
    *   **Descripción:** Obtiene una inspección completa con todas sus entidades anidadas (áreas, ítems, observaciones, mediciones, evidencia, plan markers). **Este es el endpoint clave para la sincronización y la visualización detallada.**
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones), CLIENT (sus inspecciones).
    *   **Respuesta:** Objeto `Inspection` completo (puede ser grande).

*   **POST /inspections**
    *   **Descripción:** Crea una nueva inspección a partir de una cita o manualmente.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `Inspection` (campos `appointment_id`, `property_id`, `template_id`, `inspector_id`, etc.).
    *   **Respuesta:** Objeto `Inspection` creado.

*   **PATCH /inspections/{id}/status**
    *   **Descripción:** Actualiza el estado de una inspección (ej. `IN_PROGRESS`, `COMPLETED`, `REVIEW`).
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** `{ "status": "IN_PROGRESS" | "COMPLETED" | ... }`.

*   **POST /inspections/{id}/areas**
    *   **Descripción:** Añade un área a una inspección.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** Objeto `InspectionArea`.
    *   **Respuesta:** Objeto `InspectionArea` creado.

*   **POST /inspections/{id}/items**
    *   **Descripción:** Añade un ítem (punto de checklist) a una inspección.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** Objeto `InspectionItem`.
    *   **Respuesta:** Objeto `InspectionItem` creado.

*   **POST /inspections/{id}/observations**
    *   **Descripción:** Crea una nueva observación dentro de una inspección.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** Objeto `Observation`.
    *   **Respuesta:** Objeto `Observation` creado.

*   **PATCH /observations/{id}**
    *   **Descripción:** Actualiza una observación.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** Objeto `Observation` parcial.

*   **POST /observations/{id}/markers**
    *   **Descripción:** Asocia un marcador a una observación en un plano.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** Objeto `ObservationPlanMarker`.
    *   **Respuesta:** Objeto `ObservationPlanMarker` creado.

*   **POST /observations/{id}/measurements**
    *   **Descripción:** Registra una medición asociada a una observación.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** Objeto `Measurement`.
    *   **Respuesta:** Objeto `Measurement` creado.

*   **POST /observations/{id}/evidence**
    *   **Descripción:** Sube una pieza de evidencia (ej. foto) para una observación.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus inspecciones).
    *   **Cuerpo:** `multipart/form-data` con el archivo y metadatos (`mime_type`, `file_size`, `sha256`, `captured_at`, `device_id`, `sequence`).
    *   **Respuesta:** Objeto `Evidence` creado.

*   **GET /evidence/{id}/download**
    *   **Descripción:** Descarga una pieza de evidencia (retorna una URL firmada).
    *   **Permisos:** OWNER, ADMIN, INSPECTOR, CLIENT (con permisos).
    *   **Respuesta:** Objeto `{ "signed_url": "..." }`.

### 4.7. Recursos de Sincronización (Offline)

*   **POST /sync/operations**
    *   **Descripción:** Endpoint de entrada para operaciones offline (crear/actualizar/eliminar entidades). Este endpoint deberá ser idempotente.
    *   **Permisos:** INSPECTOR.
    *   **Cuerpo:** Array de objetos `SyncOperation` (con `device_id`, `operation_id`, `entity_type`, `entity_id`, `operation_type`, `payload`).
    *   **Respuesta:** Objeto `{ "status": "success", "processed_operations": [...] }` o `{ "status": "conflict", "conflicts": [...] }`.

*   **GET /sync/pending/{device_id}**
    *   **Descripción:** Obtiene las operaciones pendientes de sincronizar por el dispositivo (ACKs, conflictos resueltos, nuevas operaciones del servidor).
    *   **Permisos:** INSPECTOR.
    *   **Respuesta:** Array de objetos `SyncOperation` (del servidor).

### 4.8. Recursos de Informes

*   **POST /inspections/{id}/reports/generate** (Servicio de Backend)
    *   **Descripción:** Genera un nuevo informe PDF para una inspección.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Opcional `{ "template_id": "...", "include_photos": true, ... }`.
    *   **Respuesta:** Objeto `Report` (con `status: GENERATED`).

*   **GET /reports/{id}**
    *   **Descripción:** Obtiene detalles de un informe.
    *   **Permisos:** OWNER, ADMIN, CLIENT (sus informes).
    *   **Respuesta:** Objeto `Report`.

*   **GET /reports/{id}/download**
    *   **Descripción:** Descarga un informe PDF (retorna una URL firmada).
    *   **Permisos:** OWNER, ADMIN, CLIENT (sus informes).
    *   **Respuesta:** Objeto `{ "signed_url": "..." }`.

*   **PATCH /reports/{id}/publish**
    *   **Descripción:** Marca un informe como publicado y calcula su hash SHA-256.
    *   **Permisos:** OWNER, ADMIN.
    *   **Respuesta:** Objeto `Report` actualizado.

### 4.9. Recursos de Seguimiento y Reinspecciones

*   **POST /observations/{id}/actions**
    *   **Descripción:** Crea una acción de corrección para una observación.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `Action`.
    *   **Respuesta:** Objeto `Action` creado.

*   **PATCH /actions/{id}**
    *   **Descripción:** Actualiza una acción (ej. `status`, `due_date`, `correction_description`).
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (acciones asignadas).
    *   **Cuerpo:** Objeto `Action` parcial.

*   **POST /inspections/{id}/reinspections**
    *   **Descripción:** Programa una reinspección para una inspección original.
    *   **Permisos:** OWNER, ADMIN.
    *   **Cuerpo:** Objeto `Reinspection` (con `inspector_id`, `scheduled_start`, etc.).
    *   **Respuesta:** Objeto `Reinspection` creado.

*   **PATCH /reinspections/{id}/observations**
    *   **Descripción:** Actualiza el estado de las observaciones durante una reinspección.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (asignado a reinspección).
    *   **Cuerpo:** Array de objetos `{ "observation_id": "...", "result": "VERIFIED" | "REJECTED", "notes": "..." }`.

### 4.10. Recursos de Auditoría

*   **GET /audit_logs**
    *   **Descripción:** Lista los registros de auditoría.
    *   **Permisos:** OWNER, ADMIN.
    *   **Parámetros:** `user_id`, `action`, `entity_type`, `entity_id`, `start_date`, `end_date`, `offset`, `limit`.
    *   **Respuesta:** Array de objetos `AuditLog`.

### 4.11. Recursos de IA (Asistente)

*   **POST /ai/tasks/draft_observation**
    *   **Descripción:** Solicita a la IA que redacte una observación basada en una entrada de texto.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR.
    *   **Cuerpo:** `{ "text_input": "fisura muro sala cerca ventana" }`.
    *   **Respuesta:** Objeto `AiResult` (con `status: PENDING` o `COMPLETED` si es sincrono).

*   **POST /ai/tasks/suggest_severity**
    *   **Descripción:** Solicita a la IA que sugiera la severidad de una observación.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR.
    *   **Cuerpo:** `{ "observation_text": "...", "category": "...", "element": "..." }`.
    *   **Respuesta:** Objeto `AiResult`.

*   **GET /ai/results/{id}**
    *   **Descripción:** Obtiene el resultado de una tarea de IA.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR (sus tareas).
    *   **Respuesta:** Objeto `AiResult`.

*   **PATCH /ai/results/{id}/accept**
    *   **Descripción:** El usuario acepta el resultado de la IA, aplicándolo al recurso correspondiente.
    *   **Permisos:** OWNER, ADMIN, INSPECTOR.
    *   **Respuesta:** Objeto `AiResult` actualizado con `accepted: true`.

---

## 5. Modelos de Datos (Referencia a `database.md`)

Los modelos de datos detallados (estructuras de tablas, tipos de datos, relaciones) se encuentran definidos en el documento `database.md`. Los objetos JSON de la API (`Organization`, `User`, `Client`, `Property`, `Inspection`, `Observation`, `Evidence`, etc.) se corresponderán directamente con las columnas de las tablas SQL, utilizando `camelCase` para los nombres de las propiedades en JSON si la API de Supabase lo gestiona automáticamente, o `snake_case` si se mantiene la convención SQL.

Los ENUM de SQL se representarán como cadenas de texto.

---

## 6. Manejo de Errores

Las respuestas de error seguirán un formato estándar:

```json
{
  "code": "string",       // Código de error interno (ej. "APPOINTMENT_CONFLICT")
  "message": "string",    // Descripción del error para el desarrollador
  "details": "object"     // Detalles adicionales (ej. campos de validación)
}
```

Códigos de estado HTTP comunes:

*   `200 OK`: Petición exitosa (GET, PATCH).
*   `201 Created`: Recurso creado exitosamente (POST).
*   `204 No Content`: Petición exitosa sin contenido a devolver (DELETE, algunas PATCH).
*   `400 Bad Request`: Error en la petición del cliente (ej. validación, formato incorrecto).
*   `401 Unauthorized`: Autenticación fallida o token inválido/ausente.
*   `403 Forbidden`: Autenticado, pero sin permisos para la acción/recurso.
*   `404 Not Found`: Recurso no encontrado.
*   `409 Conflict`: Conflicto de negocio (ej. doble reserva, conflicto de sincronización).
*   `500 Internal Server Error`: Error inesperado en el servidor.

---

## 7. Versionado de la API

Inicialmente, la API no tendrá un versionado explícito en la URL (`/v1/`). Se utilizará un enfoque de "Evolución Aditiva" donde los cambios no disruptivos se añadirán a la API existente. Si se requieren cambios disruptivos, se considerará el uso de un header `X-API-Version` o una nueva URL base (`/v2/`).

---

## 8. Consideraciones de Rendimiento y Escalabilidad

*   **Paginación:** Todos los endpoints de listado (`GET /resources`) deben soportar parámetros de paginación (`offset`, `limit`).
*   **Filtros y Búsqueda:** Soportar filtros comunes (por `status`, `user_id`, `date_range`) y búsqueda por texto (`search` parameter).
*   **Optimizaciones de Supabase:** Aprovechar las vistas (`views`), funciones (`functions`) y procedimientos almacenados (`stored procedures`) de PostgreSQL para encapsular lógica compleja y optimizar el acceso a datos.
*   **N+1 Queries:** Evitar problemas de N+1 queries mediante `joins` en el backend o utilizando las capacidades de "embedding" de Supabase si se expone directamente.

---

## 9. Sincronización Offline - Consideraciones Específicas

El endpoint `POST /sync/operations` es crítico.

*   **Idempotencia:** El servidor debe ser capaz de procesar la misma operación (`device_id`, `operation_id`) múltiples veces sin efectos secundarios no deseados (ej. duplicar registros).
*   **Orden:** Aunque las operaciones se envían en lotes, es deseable que el servidor pueda manejar un cierto grado de desorden, o que el cliente envíe operaciones en el orden correcto (utilizando `created_at` o `sequence` de la operación).
*   **Conflictos:** Cuando una operación offline intenta modificar un recurso que ha sido modificado en el servidor por otro cliente (y la `version` no coincide), el servidor debe retornar un `409 Conflict` y la versión actual del recurso en el `payload` de la respuesta, para que el cliente pueda resolver el conflicto.
*   **ACKs:** El servidor debe confirmar las operaciones procesadas, permitiendo al cliente marcar esas operaciones como `SYNCED` localmente.

---
