# OPENINSPECTION_GAP_ANALYSIS.md

Este documento presenta un análisis de brechas entre la plataforma OpenInspection y nuestra plataforma de Inspección Técnica de Entrega de Departamentos, según lo definido en `incio.md`. El objetivo es identificar qué conceptos, patrones y funcionalidades de OpenInspection pueden ser reutilizados o adaptados, y qué debe ser implementado de forma propia.

---

## 1. Propósito y Enfoque

**OpenInspection:** Plataforma open source de inspección residencial completa.
**Nuestra Plataforma:** Plataforma propia para inspección técnica de entrega de departamentos, evidencia, seguimiento postventa, portal del cliente y reportes técnicos.

El enfoque es reutilizar conceptos, patrones, estudiar implementaciones y adaptar componentes compatibles de OpenInspection, reemplazando aquello que no encaje con nuestro dominio específico, siempre bajo estricta revisión de licencia.

---

## 2. Referencia Principal y Estado

**Repositorio:** `https://github.com/InspectorHub/OpenInspection`
**Estado:** Proyecto público, TypeScript, 761 commits, release actual v2.2.0 (septiembre 2026). Documentación de arquitectura, PWA/offline, inspecciones, plantillas, fotografías, reportes, portal, reinspecciones, autenticación, RBAC, auditoría, IA, seguridad, tests, Cloudflare deployment. Utiliza React Router, React, Hono, Drizzle, Cloudflare D1/R2/KV y Durable Objects.

---

## 3. Advertencia de Licencia: GNU Affero General Public License v3.0 (AGPL-3.0)

**Implicación:** No se debe asumir la copia directa de código para un SaaS propietario cerrado sin una revisión de licencia.
**Estrategia por defecto:** Estudiar arquitectura, patrones, modelos, pruebas y seguridad. El código solo se reutilizará después de confirmar compatibilidad legal.
**Regla:** Preferir reimplementar conceptos y patrones antes que copiar componentes AGPL directamente si no hay decisión legal explícita.
**Gestión:** Mantener `docs/THIRD_PARTY_LICENSES.md` con detalles de proyectos, versiones, licencias, componentes utilizados, archivos derivados, modificaciones y obligaciones.

---

## 4. Decisión Arquitectónica (Brecha Tecnológica)

**Arquitectura OpenInspection:**
*   React, React Router
*   Hono
*   Drizzle
*   Cloudflare Workers, D1, R2, KV, Durable Objects

**Nuestra Arquitectura Inicial:**
*   **APP INSPECTOR:** Flutter + Dart, SQLite + Drift
*   **WEB:** Nuxt + Vue + TypeScript
*   **BACKEND:** Supabase (PostgreSQL)
*   **STORAGE:** Supabase Storage
*   **AUTH:** Supabase Auth
*   **AI:** Ollama / proveedor abstracto
*   **PDF:** HTML + CSS → PDF

**Brecha:** Decisión explícita de NO copiar automáticamente la arquitectura de OpenInspection. Nuestra plataforma utilizará una pila tecnológica diferente para conservar flexibilidad y adaptarse a un dominio distinto.

---

## 5. Reutilización Conceptual (Qué NO desarrollar desde cero)

OpenInspection proporciona soluciones y referencias valiosas para:

1.  Autenticación
2.  Sesiones
3.  RBAC
4.  Multi-tenant
5.  Inspecciones
6.  Plantillas
7.  Comentarios reutilizables
8.  Observaciones
9.  Fotografías
10. Reportes
11. Reinspecciones
12. Portal cliente
13. Firmas
14. Auditoría
15. Evidencias
16. Offline
17. Sincronización
18. IA desacoplada
19. Rate limiting
20. Validación
21. Seguridad
22. Testing
23. CI/CD
24. Deployment

**Brecha:** Conceptos maduros en OpenInspection que debemos estudiar y adaptar, no reinventar.

---

## 6. Implementación Propia (Nuestro Dominio Específico)

**Nuestra plataforma implementará:**

*   **Estructura de Dominio:** Proyecto Inmobiliario → Edificio → Piso → Departamento (con Cliente, Plano, Inspecciones, Observaciones, Evidencias, Postventa).
*   **Núcleo del Producto (Inspección):** Áreas, Elementos, Checklist, Observaciones, Evidencias, Mediciones, Ubicación en plano, Severidad, Recomendación, Estado, Seguimiento.

**Brecha:** Aunque se reutilizan conceptos de inspección, la estructura y detalle del dominio inmobiliario es específica nuestra.

---

## 7. Reutilización/Adaptación Detallada de Funcionalidades

### 7.1 Autenticación
*   **OpenInspection:** Referencia técnica en `server/`, `docs/develop/`, `docs/operate/`. Buscar autenticación, sesiones, JWT, password hashing, 2FA, reset tokens, tenant scope.
*   **Nuestra Implementación:** Utilizar `Supabase Auth` con email/password, recuperación, sesiones, MFA para administradores, expiración/refresh, revocación, roles, organización.
*   **Brecha:** Adaptación del concepto de autenticación, pero reemplazo de la implementación subyacente por Supabase Auth.

---

## 8. Multi-tenant
*   **OpenInspection:** Aislamiento de datos por tenant.
*   **Nuestra Implementación:** Estructura `organizations` con entidades vinculadas a `organization_id`. Implementar seguridad con PostgreSQL + RLS + RBAC + `organization_id`.
*   **Brecha:** El concepto es el mismo, la implementación se adapta a PostgreSQL/Supabase.

---

## 9. Inspecciones
*   **OpenInspection:** `Inspection`, `Inspection template`, `Inspection editor`, `Inspection results`, `Inspection publishing`, `Reports`, `Reinspection`.
*   **Nuestra Adaptación:** Crear `projects`, `buildings`, `floors`, `properties`, `inspections`, `inspection_areas`, `inspection_items`, `observations`, `measurements`, `evidence`, `actions`, `reinspections`.
*   **Brecha:** Concepto reutilizado, pero con una adaptación del modelo de datos para reflejar nuestra jerarquía inmobiliaria.

---

## 10. Plantillas
*   **OpenInspection:** Plantillas de inspección.
*   **Nuestra Necesidad:** Plantillas para `departamento_nuevo`, `departamento_recepcion`, `pre_entrega`, `postventa`, `reinspeccion`. Una plantilla contendrá `Área` → `Elemento` → `Checklist` → `criterios`.
*   **Brecha:** Concepto de plantillas reutilizado, con una estructura interna adaptada a nuestro dominio.

---

## 11. Biblioteca de Observaciones
*   **OpenInspection:** "Canned comments".
*   **Nuestra Implementación:** `observation_library` con campos como `id`, `code`, `category`, `area`, `element`, `title`, `description`, `recommendation`, `severity_default`, `active`, `version`.
*   **Brecha:** El concepto de biblioteca de comentarios reutilizables es directamente aplicable, se adaptarán los campos.

---

## 12. Severidad
*   **OpenInspection:** Ratings de home inspection.
*   **Nuestra Implementación:** Sistema propio de `severity`: `INFO`, `MENOR`, `MODERADA`, `MAYOR`, `CRÍTICA`. Definición clara de cada nivel como clasificación interna para priorización y seguimiento.
*   **Brecha:** Reemplazo de los ratings por un sistema de severidad propio, no basado en estándares de inspección residencial.

---

## 13. Evidencias Fotográficas
*   **OpenInspection:** Sistema de fotos.
*   **Nuestra Ampliación:** Cada evidencia tendrá `id`, `inspection_id`, `observation_id`, `file_path`, `mime_type`, `size`, `sha256`, `captured_at`, `uploaded_at`, `device_id`, `sequence`, `metadata`.
*   **Seguridad:** Validar MIME, extensión, tamaño, hash, usuario, organization_id, inspection_id.
*   **Brecha:** El concepto es el mismo, pero se amplían los metadatos y se refuerzan las validaciones de seguridad.

---

## 14. Fotografías Offline
*   **OpenInspection:** Soporte offline, pero con carga binaria de fotos/videos que requiere conexión.
*   **Nuestro Flujo:** Fotografías almacenadas localmente, pendientes de sincronización. Flujo offline: `foto` → `archivo local` → `SQLite metadata` → `sync_queue` → `estado = PENDING`. Flujo con internet: `PENDING` → `UPLOAD` → `SERVER` → `VERIFY HASH` → `uploaded` → `delete local cuando corresponda`.
*   **Brecha:** Diferencia importante. Se reimplementa el flujo de fotos offline para permitir el almacenamiento local y sincronización posterior.

---

## 15. Offline First
*   **Nuestra App Flutter:** `SQLite` + `Drift` + `local file storage` + `sync queue`.
*   **Entidades Offline:** `inspection`, `area`, `item`, `observation`, `measurement`, `evidence`, `action`, `sync_operation`.
*   **Campos de Registro:** `local_id`, `server_id`, `sync_status`, `created_at`, `updated_at`, `version`.
*   **Brecha:** Reimplementación completa del sistema offline para el stack Flutter/SQLite.

---

## 16. Sincronización
*   **OpenInspection:** Estrategia con IndexedDB, merge, offline document, reconexión, edición colaborativa (Yjs CRDT) y Durable Objects.
*   **Nuestra MVP:** `LOCAL` → `OUTBOX` → `SYNC` → `SERVER` → `ACK`. Estados: `PENDING`, `UPLOADING`, `SYNCED`, `FAILED`, `CONFLICT`. No se copiará Yjs/CRDT ni colaboración simultánea en MVP.
*   **Brecha:** Estudiar la estrategia de OpenInspection, pero reimplementar para un MVP sin colaboración simultánea.

---

## 17. Conflictos
*   **MVP:** Inspector como principal editor.
*   **Regla:** `last_modified` + `version`. Si hay conflicto: `CONFLICT` → no sobrescribir silenciosamente → registrar → resolver.
*   **Brecha:** La gestión de conflictos se simplifica para el MVP, posponiendo la colaboración multiusuario.

---

## 18. Planos
*   **Funcionalidad Propia:** No explícitamente cubierta como núcleo en OpenInspection.
*   **Nuestra Implementación:** Tabla `property_plans` (`id`, `property_id`, `file_path`, `page`, `width`, `height`, `scale`, `version`). Y `observation_plan_markers` (`id`, `observation_id`, `plan_id`, `x`, `y` normalizados).
*   **Brecha:** Funcionalidad propia y crítica para nuestro dominio.

---

## 19. Interfaz del Plano
*   **Inspector:** Abrir plano → seleccionar área → crear observación → colocar marcador → tomar fotografía → guardar.
*   **Cliente:** Abrir plano → ver marcadores → seleccionar observación → ver fotografías → ver estado.
*   **Brecha:** Interfaz y flujo específicos para la interacción con planos.

---

## 20. Reportes
*   **OpenInspection:** Arquitectura avanzada de reportes (generación, plantillas, PDF, HTML, signature, evidence pack).
*   **Nuestra Salida:** HTML → CSS → PDF. Contenido: Portada, Datos del inmueble, Datos del inspector, Resumen ejecutivo, Plano, Resumen de observaciones, Detalle de observaciones, Fotografías, Mediciones, Recomendaciones, Estado, Firma, Anexos.
*   **Brecha:** Estudiar la arquitectura de OpenInspection, adaptar conceptos de generación, pero con contenido y formato específicos para nuestro tipo de reporte.

---

## 21. Reporte con Fotografías
*   **OpenInspection:** Referencia para `report rendering`, `pagination`, `images`, `print styles`, `PDF generation`.
*   **Brecha:** Reutilizar conceptos, no crear sistema PDF desde cero.

---

## 22. Firma y Trazabilidad
*   **OpenInspection:** Sistema de Ed25519, hash chain, audit, evidence pack, verification.
*   **Nuestra Primera Versión:** `report` → `SHA-256` → `signed_at` → `signed_by` → `audit_log`.
*   **Fase Posterior:** `hash chain` + `firma criptográfica` + `verificador público`.
*   **Brecha:** Concepto avanzado de OpenInspection se implementará en fases, con un MVP más simple inicialmente.

---

## 23. Audit Log
*   **Nuestra Implementación:** `audit_logs` con campos como `id`, `organization_id`, `user_id`, `action`, `entity_type`, `entity_id`, `metadata`, `ip_hash`, `user_agent`, `created_at`.
*   **Registrar Mínimo:** LOGIN, LOGOUT, CREATE_INSPECTION, UPDATE_INSPECTION, CREATE_OBSERVATION, UPLOAD_EVIDENCE, PUBLISH_REPORT, SIGN_REPORT, DOWNLOAD_REPORT, CREATE_REINSPECTION, CHANGE_STATUS, DELETE.
*   **Seguridad:** No permitir eliminación/modificación arbitraria por usuarios normales.
*   **Brecha:** Implementación desde cero, pero con base conceptual en la importancia del audit log de OpenInspection.

---

## 24. Portal del Cliente
*   **OpenInspection:** Portal cliente.
*   **Nuestra Referencia:** Autenticación, navegación, reportes, documentos, estado.
*   **Nuestro Portal:** CLIENTE → Mis departamentos, Inspecciones, Plano, Observaciones, Evidencias, Reporte PDF, Estado de correcciones, Reinspección.
*   **Brecha:** Adaptación del concepto de portal, con funcionalidades específicas para nuestro cliente.

---

## 25. Seguimiento Postventa
*   **Funcionalidad Propia:** No es un núcleo en OpenInspection.
*   **Nuestro Modelo:** `observation` → `action` → `assigned_to` → `due_date` → `correction_evidence` → `reinspection`.
*   **Estados:** PENDIENTE, EN_CORRECCIÓN, CORREGIDO, RECHAZADO, VERIFICADO, CERRADO.
*   **Brecha:** Funcionalidad propia, esencial para nuestro dominio.

---

## 26. Contract-to-Delivery Audit
*   **Funcionalidad Propia:** No existe como núcleo en OpenInspection.
*   **Nuestros Módulos:** `documents`, `requirements`, `contract_items`, `delivery_items`, `compliance_results`.
*   **Resultado:** COMPLIANT, PARTIAL, NON_COMPLIANT, NOT_VERIFIED.
*   **Brecha:** Ventaja propia, fundamental para el dominio de entrega de departamentos.

---

## 27. DQI (Department Quality Index)
*   **Funcionalidad Propia:** Se creará posteriormente.
*   **Objetivo:** Indicador interno basado en cantidad/severidad de observaciones, áreas afectadas, observaciones críticas y correcciones pendientes. No certificación normativa.
*   **Brecha:** Funcionalidad propia, para una fase posterior al MVP.

---

## 28. IA
*   **OpenInspection:** Integración con proveedores de IA.
*   **Nuestra Arquitectura:** `AIProvider` → `OllamaProvider` / `ExternalProvider`. La aplicación no dependerá directamente de Ollama.
*   **Brecha:** Adaptación del concepto de IA desacoplada, con proveedores específicos.

---

## 29. IA en MVP
*   **NO usar IA para:** Decidir automáticamente si una vivienda cumple una norma.
*   **SÍ puede ayudar con:** Redacción, clasificación sugerida, resumen, normalización, sugerencias, detección preliminar.
*   **Flujo:** IA → SUGERENCIA → INSPECTOR → APROBACIÓN.
*   **Brecha:** Se priorizan usos de apoyo y sugerencia para el MVP, evitando decisiones automáticas.

---

## 30. Seguridad
*   **OpenInspection:** Base importante (`SECURITY.md`, `docs/develop/architecture.md`, auth, RBAC, tenant isolation, rate limiting, security headers, CSP, input validation, audit, 2FA, session management). Version 2.2.0 incluye correcciones de seguridad.
*   **Brecha:** Estudiar las implementaciones de seguridad de OpenInspection como referencia sólida.

---

## 31. Nuestra Seguridad Obligatoria
*   **Frontend:** HTTPS, CSP, Security Headers, XSS protection, Input validation, Output encoding.
*   **API:** Authentication, Authorization, RBAC, Rate limiting, Request validation, Idempotency, Audit.
*   **Database:** PostgreSQL, RLS, organization_id, Foreign Keys, Constraints, Least privilege.
*   **Storage:** Private buckets, Signed URLs, MIME validation, Size limits, Ownership checks.
*   **Cuenta:** Password hashing gestionado por Auth, Session expiry, Refresh token protection, MFA, Recovery protection, Rate limiting.
*   **Brecha:** Implementación de seguridad integral adaptada a nuestro stack, pero inspirada en las buenas prácticas de OpenInspection.

---

## 32. No Exponer Secretos
*   **Regla:** Nunca colocar `SERVICE_ROLE_KEY`, `DATABASE_PASSWORD`, `PRIVATE_KEY`, `AI_SECRET` en Flutter, Nuxt client, Git, GitHub, APK.
*   **Utilizar:** Environment variables, secret manager, CI/CD secrets.
*   **Brecha:** Principio de seguridad fundamental, aplicable a ambos proyectos.

---

## 33. Testing
*   **OpenInspection:** Infraestructura de testing importante (`tests/`, `playwright.config.ts`, `vitest.config.ts`, `vitest.api.config.ts`, `vitest.contract.config.ts`).
*   **Nuestra Estrategia:** Unit tests, Integration tests, API tests, Database/RLS tests, Offline tests, Sync tests, Security tests, E2E.
*   **Brecha:** Estudiar la infraestructura de testing de OpenInspection para inspirar nuestra propia estrategia, sin copiar archivos directamente.

---

## 34. Tests Críticos
*   **Ejemplos:**
    *   Cliente A no puede ver inspección de Cliente B.
    *   Inspector A no puede acceder a Organization B.
    *   Foto offline + reconexión = Foto no perdida.
    *   Sync repetido = No duplicar observación.
    *   Reporte publicado = Evidencia inmutable.
*   **Brecha:** Definición de tests críticos específicos para asegurar la integridad de nuestro sistema, inspirados en los desafíos de una aplicación multi-tenant y offline.

---

## 35. Archivos de OpenInspection a Estudiar Primero
*   **Orden recomendado:** `README.md`, `LICENSE`, `SECURITY.md`, luego `docs/README.md`, `docs/develop/architecture.md`, `docs/operate/deploy.md`, `docs/operate/upgrade.md`, y finalmente `server/`, `app/`, `workers/`, `packages/`, `migrations/`, `tests/`.
*   **Brecha:** Guía para el estudio de OpenInspection, fundamental para la fase de auditoría.

---

## 36. Archivos que NO debemos Copiar Inicialmente
*   `package.json`, `wrangler.jsonc`, `react-router.config.ts`, `vite.config.ts`, `worker-configuration.d.ts`, `drizzle.config.ts` (pertenecen a su arquitectura).
*   `workers/` (si se mantiene Supabase).
*   **Brecha:** Identificación clara de componentes no compatibles con nuestra pila tecnológica.

---

## 37. Componentes a Estudiar y Reimplementar

| Componente | Referencia OpenInspection | Resultado Nuestra Plataforma | Brecha/Decisión |
|---|---|---|---|
| **Auth** | `server/` | `Supabase Auth` | Reimplementar |
| **Database** | `migrations/`, `server/` | `supabase/migrations/` | Reimplementar |
| **API** | `server/` | `Supabase API` + `Nuxt server routes` | Reimplementar |
| **UI** | `app/`, `packages/shared-ui/` | `apps/web/` con `Nuxt`, `Vue`, `TypeScript` | Reimplementar |
| **Mobile** | `PWA`, `IndexedDB` | `Flutter`, `SQLite`, `Drift` | Reimplementar |

---

## 38. Nueva Estructura del Repositorio (Nuestra Plataforma)

```text
inspection-platform/
│
├── apps/
│   ├── inspector/  (Flutter)
│   └── web/        (Nuxt/Vue)
│
├── supabase/       (Backend)
│
├── packages/       (Shared code)
│
├── ai/             (AI integration)
│
├── reports/        (Report templates/assets)
│
├── docs/           (Documentation, incluyendo este análisis)
│   ├── THIRD_PARTY_LICENSES.md
│   └── OPENINSPECTION_GAP_ANALYSIS.md
│
├── tests/
├── scripts/
└── README.md
```
**Brecha:** Estructura de repositorio completamente nueva para nuestro proyecto.

---

## 39. Matriz de Reutilización

| Módulo | OpenInspection | Nuestra decisión | Brecha/Análisis |
|---|---|---|---|
| Auth | Sí | Adaptar concepto | Reemplazo de implementación. |
| RBAC | Sí | Implementar | Reimplementación con nuestra pila. |
| Multi-tenant | Sí | Implementar | Reimplementación con nuestra pila. |
| Inspection | Sí | Adaptar | Adaptación a nuestro modelo de dominio. |
| Templates | Sí | Adaptar | Adaptación a nuestro modelo de dominio. |
| Comments | Sí | Adaptar | Adaptación a nuestro modelo de dominio. |
| Ratings | Sí | Reemplazar por severidad | Sustitución por concepto propio. |
| Photos | Sí | Adaptar + offline | Ampliación de funcionalidad offline. |
| Offline | Sí | Reimplementar para Flutter | Reimplementación completa. |
| Sync | Sí | Reimplementar | Reimplementación con enfoque MVP. |
| PDF | Sí | Estudiar/adaptar | Adaptación de conceptos. |
| E-signature | Sí | Fase posterior | Postergado para MVP. |
| Audit | Sí | Implementar | Reimplementación con nuestra pila. |
| Portal | Sí | Adaptar | Adaptación a nuestro dominio. |
| Reinspection | Sí | Implementar | Reimplementación con nuestra pila. |
| AI | Sí | Adaptar | Adaptación a nuestros proveedores. |
| Booking | Sí | NO MVP | Eliminado del MVP. |
| Agent CRM | Sí | NO MVP | Eliminado del MVP. |
| Referral | Sí | NO MVP | Eliminado del MVP. |
| QuickBooks | Sí | NO MVP | Eliminado del MVP. |
| Calendar integrations | Sí | NO MVP | Eliminado del MVP. |
| Spectora import | Sí | NO MVP | Eliminado del MVP. |
| Collaborative editing | Sí | NO MVP | Eliminado del MVP. |
| Yjs/CRDT | Sí | NO MVP | Eliminado del MVP. |
| Cloudflare Workers | Sí | NO inicialmente | Sustitución de stack. |
| D1 | Sí | Reemplazar por PostgreSQL | Sustitución de stack. |
| R2 | Sí | Reemplazar por Supabase Storage | Sustitución de stack. |
| KV | Sí | Reemplazar según necesidad | Sustitución de stack. |
| Durable Objects | Sí | NO MVP | Eliminado del MVP. |

**Brecha:** Esta matriz resume las decisiones clave de reutilización, adaptación o reemplazo, destacando las principales brechas tecnológicas y de funcionalidad.

---

## 40. Funcionalidades a ELIMINAR del MVP (para ahorrar meses de desarrollo)

*   CRM de agentes, referral tracking, booking avanzado, QuickBooks, calendarios externos, SMS, marketplace, colaboración simultánea (Yjs, CRDT), Spectora import, múltiples proveedores de IA, traducción automática, funciones comerciales complejas, facturación SaaS, billing por seats.

**Objetivo:** Enfocarse en "Inspeccionar un departamento offline y generar un informe profesional verificable."

---

## 41. MVP REAL (Funcionalidades)

1.  Login
2.  Crear proyecto
3.  Crear edificio
4.  Crear departamento
5.  Cargar plano
6.  Crear áreas
7.  Crear inspección
8.  Abrir checklist
9.  Registrar observación
10. Tomar fotografía
11. Registrar medición
12. Ubicar observación en plano
13. Trabajar sin Internet
14. Cerrar inspección
15. Reconectar
16. Sincronizar
17. Generar PDF
18. Cliente accede al informe
19. Ver fotografías
20. Descargar PDF

---

## 42. Fases del Proyecto

1.  **Fase 0 — Auditoría:** Análisis de OpenInspection (arquitectura, seguridad, licencia, modelos, offline, reportes). Entregable: `OPENINSPECTION_GAP_ANALYSIS.md`.
2.  **Fase 1 — Foundation:** Nuxt, Supabase, PostgreSQL, Auth, RLS, Storage.
3.  **Fase 2 — Inspector:** Flutter, SQLite, Drift, Inspection, Checklist, Observation, Evidence, Offline.
4.  **Fase 3 — Sync:** Outbox, Upload, Retry, Idempotency, Conflict.
5.  **Fase 4 — Report:** HTML, CSS, PDF, Photos, Plan, Observations.
6.  **Fase 5 — Portal:** Cliente, Inspección, Observaciones, Fotos, PDF.
7.  **Fase 6 — Protección:** Postventa, Correcciones, Reinspección, Estado.
8.  **Fase 7 — Seguridad avanzada:** MFA, Audit, Hash, Evidence pack, Signed report.
9.  **Fase 8 — IA:** Ollama, Classification, Summary, Drafting, Photo assistance.
10. **Fase 9 — Contract Audit:** Contrato, Especificaciones, Planos, Entregado, Comparación.
11. **Fase 10 — SaaS:** Organizations, Plans, Billing, Usage, Admin, Analytics.

---

## 43. Qué NO hacer (Errores a evitar)

No empezar con IA, SaaS, Billing, CRM, Marketplace, ni intentar implementar Flutter, Nuxt, Supabase, Ollama, Docker, Cloudflare, Kubernetes todo al mismo tiempo.

---

## 44. Orden Correcto (Priorización)

1.  OpenInspection Audit
2.  Domain Model
3.  Database + RLS
4.  Nuxt foundation
5.  Flutter foundation
6.  Offline inspection
7.  Sync
8.  Evidence
9.  Reports
10. Client Portal
11. Post-sale
12. Security hardening
13. AI
14. Contract Audit
15. SaaS

---

## 45. Principio de Reutilización

Si OpenInspection ya resolvió un problema:
*   NO: Diseñar desde cero.
*   SÍ: Estudiar implementación.
    *   Si encaja con nuestro dominio: Adaptar.
    *   Si NO encaja: Reimplementar.

---

## 46. Regla contra el Sobreingeniería

No incorporar una tecnología únicamente porque OpenInspection la utiliza si no resuelve un problema existente en nuestro proyecto. Ejemplo: Durable Objects de OpenInspection no implica su necesidad en nuestro proyecto sin un problema específico a resolver.

---

## 47. Qué Aprovechamos Realmente de OpenInspection

*   **Diseño Conceptual:** Inspection, template, editor, report, portal, reinspection, audit, security, offline.
*   **Investigación:** Cómo una plataforma profesional organiza datos, workflow, reportes, evidencias, usuarios, seguridad.
*   **Patrones Técnicos:** Authentication, authorization, tenant isolation, offline, sync, reporting, audit, testing.
