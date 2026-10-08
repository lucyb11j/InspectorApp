# IMPLEMENTATION PLAN - Plataforma de Inspección Técnica

**Versión:** 1.0
**Fecha:** 2026-10-07
**Estado:** Borrador inicial

Este documento describe el plan de implementación detallado para la Plataforma de Inspección Técnica, basándose en el `PROJECT_CHARTER.md`, `PRODUCT_REQUIREMENTS.md`, `ARCHITECTURE.md`, `DATABASE.md`, `API_SPECIFICATION.md`, `UI_UX_DESIGN.md`, `framework.md` y `planes.md`. El plan se estructura en fases, cada una con entregables, tareas clave y consideraciones específicas.

---

## 1. Principios del Plan de Implementación

*   **Enfoque Iterativo:** Desarrollo en ciclos cortos, priorizando la entrega de valor funcional.
*   **MVP-First:** Concentración en el Minimum Viable Product para validación temprana.
*   **Seguridad y Escabilidad por Diseño:** Integrar la seguridad y la preparación para el crecimiento en cada fase.
*   **Referencia Continua a la Documentación:** Todas las tareas deben rastrear los requisitos, diseños y decisiones documentadas.
*   **Feedback Constante:** Integrar ciclos de revisión y feedback en cada etapa.

---

## 2. Herramientas y Entorno de Desarrollo

*   **Control de Versiones:** Git + GitHub
*   **Monorepo Tool:** pnpm workspaces (priorizando la simplicidad para el MVP y la compartición de dependencias, contratos y tipos).
*   **Backend:** Supabase (PostgreSQL, Auth, Storage)
*   **App Inspector:** Flutter + Dart + SQLite (Drift)
*   **Web Admin/Client Portal:** Nuxt + Vue + TypeScript
*   **Web Pública:** Astro
*   **CI/CD:** GitHub Actions
*   **Contenedores:** Docker (para entornos de desarrollo local y futuro despliegue si se desacopla Supabase)
*   **Gestión de Tareas:** GitHub Issues / Jira / Trello
*   **Comunicación:** Discord / Slack

---

## 3. Fases del Proyecto (Roadmap Detallado y Optimizado)

El plan ha sido optimizado y reestructurado siguiendo la estrategia de reutilización y análisis definida en `incio.md` y `OPENINSPECTION_GAP_ANALYSIS.md`. Se integrarán conceptos arquitectónicos, de seguridad y de sincronización de `github.com/InspectorHub/OpenInspection` donde sean compatibles, adaptándolos a nuestro dominio inmobiliario específico y nuestra decisión arquitectónica propia, donde Nuxt + Vue + TypeScript ha sido elegido para el Portal Administrativo y Portal del Cliente como framework web, basándonos en sus ventajas inherentes y no en la tecnología de OpenInspection. OpenInspection se utiliza únicamente como referencia de patrones de arquitectura, seguridad, inspecciones, sincronización, testing y operación.

---

### FASE 0 — Definición y Auditoría (Completada)

**Objetivo:** Establecer una base conceptual y técnica sólida analizando soluciones existentes (OpenInspection) y definiendo nuestra arquitectura propietaria.

**Entregables Clave:**
* Documentación centralizada y verificada (`PROJECT_CHARTER`, `PRODUCT_REQUIREMENTS`, `ARCHITECTURE`, `DATABASE`, `API_SPECIFICATION`, `UI_UX_DESIGN`).
* `incio.md` y `OPENINSPECTION_GAP_ANALYSIS.md`: Decisiones de diseño y reutilización de OpenInspection (Auth, RBAC, Multi-tenant, Sincronización offline, Testing, Seguridad) y adaptación a nuestra tecnología.
* `THIRD_PARTY_LICENSES.md` para resguardar las implicaciones de la licencia AGPL-3.0 de OpenInspection.

---

### FASE 1 — Foundation (Infraestructura Core)

**Objetivo:** Establecer los cimientos del sistema. Nuxt, Supabase, PostgreSQL, Auth, RLS, Storage.

**Tareas Detalladas:**
* **Configuración del Repositorio:** Inicializar monorepo (pnpm workspaces), Git, GitHub, y la base de CI/CD.
* **Configuración de Proyectos:**
    * Flutter project (App Inspector).
    * Nuxt project (Web Admin/Client Portal).
    * Astro project (Web Pública).
* **Configuración de Supabase:** Inicializar PostgreSQL, Auth, Storage, y la base de RLS.
* **Migraciones de PostgreSQL:** Implementar migraciones para el esquema de la base de datos.
* **Autenticación y Autorización (Infraestructura SaaS Base):**
    * Gestión de usuarios, roles (RBAC) y multi-tenancy.
    * Configuración básica de MFA.
    * Implementación estricta de RLS con `organization_id` y validación de propiedad para garantizar el aislamiento de tenants (base fundamental del futuro SaaS).
* **Gestión de Almacenamiento:** Configurar almacenamiento privado con URL firmadas, validación de MIME y tamaño de archivo.
* **Base de la API:** Definición de la estructura base de la API, manejo de errores, logging y rate limiting básico.
* **Configuración del Entorno y Secretos:** Implementar la gestión de variables de entorno y secretos.
* **Base de Testing:** Configuración de pruebas unitarias, de base de datos, RLS y API.
* **Sembrado de Base de Datos:** Crear datos iniciales para desarrollo y pruebas.
* **Documentación de Desarrollo:** Establecer la base para la documentación técnica.
* **Definición del Modelo de Dominio Base:**
    * `organization`, `user`, `client`, `project`, `building`, `floor`, `property`, `inspection`.
    * `service_types`, `availability_rules`, `appointments`, `appointment_status_history`, `payment_records`.
* **Seguridad desde la Fase 1:**
    * HTTPS, private storage, signed URLs.
    * Input validation, MIME validation, file size validation.
    * Auditoría básica y manejo de secretos.

---

### FASE 2 — Inspector (Motor Core Offline y Frontend Flutter)

**Objetivo:** Flujo base para que el inspector realice su trabajo sin necesidad de red (Offline-first). Flutter, SQLite, Drift.

**Tareas Detalladas:**
* **Arquitectura Offline-first:**
*       Implementación de la base de datos local SQLite/Drift para `inspection`, `inspection_area`, `inspection_item`, `observation`, `measurement`, `evidence`, `property_plan`, `observation_plan_marker`, `action`.
*       La Fase 2 debe implementar desde el inicio todos los campos y contratos necesarios para que la Fase 3 pueda sincronizar las entidades sin rediseñar el modelo local.
    * Las entidades locales deben crearse con los campos de sincronización preparados desde el primer día (ej. `sync_status`, `updated_at`, `hash`).
    * Gestión de archivos locales para fotografías y documentos temporales.
    * Definición de estados de sincronización: `LOCAL`, `OUTBOX`, `PENDING`, `SYNCED`, `FAILED`, `CONFLICT`.
* **Funcionalidad de Inspector Offline:**
    * Permitir al inspector realizar inspecciones completas sin conexión a Internet (tomar fotos, registrar observaciones, etc.).
    * Descarga de configuraciones, plantillas (`templates`) e información del proyecto preasignado.
    * Captura de elementos defectuosos (observaciones) asociadas a una pre-configuración o `observation_library`.
*     Integración con cámara: al tomar una fotografía, se debe guardar el archivo localmente y capturar inmediatamente metadatos críticos como `sha256`, `mime_type`, `size`, `captured_at`, `device_id` y `sequence`, almacenándolos en SQLite como parte de la metadata de la evidencia.
    * Posicionamiento táctil en planos del inmueble (`property_plans`).
* **Testing Específico de Offline:**
    * Flutter widget tests, SQLite/Drift tests, y pruebas de escenarios offline.

---

### FASE 3 — Sync Engine

**Objetivo:** Flujo seguro para la comunicación de datos creados de manera offline (Outbox, Upload, Retry, Idempotency, Conflict).

**Tareas Detalladas:**
* **Flujo de Sincronización:** Implementación del patrón Outbox para la cola de sincronización (`LOCAL → OUTBOX → UPLOAD → SERVER → VERIFY → ACK → SYNCED`).
* **Manejo de Errores y Reintentos:** Implementación de mecanismos de reintento (`RETRY`) para operaciones fallidas y manejo de conflictos (`CONFLICT`) sin sobrescritura silenciosa.
* **Idempotencia:** Asegurar que las operaciones de sincronización sean idempotentes para evitar duplicación de datos.
*   **Integridad y Orden de Evidencia:** Implementar un flujo que garantice que las evidencias (fotografías, planos) se carguen y verifiquen con SHA-256 en Storage (obteniendo un `evidence_server_id`) antes de que la observación referencial se marque como sincronizada, evitando así observaciones que apunten a evidencias inexistentes.
* **Pruebas de Sincronización:** Desarrollo de pruebas unitarias y de integración para el motor de sincronización, incluyendo escenarios de reintento, idempotencia y resolución de conflictos.

---

### FASE 4 — Reports

**Objetivo:** Convertir el trabajo del inspector en entregables de valor, asegurando la trazabilidad y la inmutabilidad.

**Tareas Detalladas:**
* **Generación de Informes PDF:** Implementación de la generación de informes en formato PDF a partir de plantillas HTML/CSS.
* **Componentes del Informe:** Inclusión de fotografías, planos, resúmenes de observaciones, clasificación por severidad, índices de evidencia y metadatos de la inspección, SHA-256.
* **Ciclo de Vida del Informe:** Definición y gestión de los estados del informe (`DRAFT`, `GENERATING`, `GENERATED`, `REVIEW`, `PUBLISHED`, `LOCKED`).
* **Control de Versiones:** Implementación de un sistema de versionado que permita generar nuevas versiones del informe sin modificar silenciosamente las publicadas.
* **Pruebas de Informes:** Desarrollo de pruebas para la generación de PDF y pruebas de snapshot de informes.

---

### FASE 5 — Client Portal

**Objetivo:** Interfaz principal del cliente/propietario para consultar el informe técnico, sus observaciones y su evolución.

**Tareas Detalladas:**
* **Visualización de Inspecciones:** Desarrollo de la interfaz para que el cliente pueda ver sus inspecciones asignadas.
* **Plano Interactivo:** Implementación de un componente de plano interactivo que muestre las ubicaciones de las observaciones.
* **Detalle de Observaciones:** Visualización de observaciones con sus fotografías y estado de corrección.
* **Acceso a Informes:** Funcionalidad para que el cliente acceda y descargue los informes PDF.
* **Estado de Citas:** Visualización del estado de sus citas y sus pagos.
* **Pruebas E2E del Portal:** Desarrollo de pruebas End-to-End para el portal del cliente.

---

### FASE 6 — Postventa + Reinspection

**Objetivo:** Gestión completa del flujo de vida de un defecto constructivo, desde su detección hasta su verificación y cierre.

**Tareas Detalladas:**
* **Seguimiento de Acciones:** Implementación de la creación y seguimiento de acciones vinculadas a las observaciones (`OBSERVACIÓN → ACCIÓN → RESPONSABLE → FECHA LÍMITE`).
* **Flujo de Corrección:** Desarrollo del flujo de corrección (`CORRECCIÓN → EVIDENCIA → REINSPECCIÓN → VERIFICADO → CERRADO`).
* **Evidencia Antes/Después:** Carga y visualización de evidencia de corrección para comparar el estado antes y después.
* **Programación de Reinspecciones:** Funcionalidad para programar nuevas visitas de reinspección basadas en observaciones pendientes.
* **Verificación de Correcciones:** Herramientas para verificar y aceptar/rechazar las correcciones realizadas.

---

### FASE 7 — Production Hardening

**Objetivo:** Hardening avanzado de la plataforma, asegurando la inmutabilidad legal y resguardando contra ataques sofisticados.

**Tareas Detalladas:**
* **MFA generalizado:** Implementación de Multi-Factor Authentication para todos los usuarios con privilegios elevados.
* **Security Headers Avanzados:** Configuración de cabeceras de seguridad web (`security headers`) avanzadas.
* **CSP Endurecido:** Implementación de una Content Security Policy (CSP) estricta.
* **Penetration Testing:** Realización de pruebas de penetración y auditorías de seguridad.
* **Audit Log Inmutable:** Implantación de un registro de auditoría (`audit log`) secuencial e inmutable para todas las tablas críticas.
* **Hash Chains y Evidence Packs:** Soporte para firma criptográfica, hash chains y empaquetado inmutable de evidencia.
* **Firmas Criptográficas:** Implementación de firmas criptográficas para informes y documentos clave.
* **Auditoría de Seguridad y Threat Modeling:** Realización de auditorías de seguridad periódicas y threat modeling avanzado.

---

### FASE 8 — AI Assistant

**Objetivo:** Automatizar labores repetitivas y optimizar el proceso de documentación utilizando IA, manteniendo siempre la revisión humana.

**Tareas Detalladas:**
* **Arquitectura de Proveedores de IA:** Implementación de un `AIProvider` desacoplado, con un `OllamaProvider` inicial y la capacidad de integrar `ExternalProvider` en el futuro.
* **Asistencia de Redacción:** Funcionalidad de IA para asistir en la redacción de observaciones, normalización de textos y sugerencia de títulos.
* **Clasificación y Recomendación:** Asistencia en la clasificación de defectos por categoría y sugerencia de recomendaciones y severidad.
* **Resúmenes Automáticos:** Generación de resúmenes de inspecciones asistida por IA.
* **Análisis Preliminar de Imágenes:** Implementación de asistencia preliminar para el análisis de fotografías (siempre con revisión humana).
* **Modo OFF/ON de IA:** Asegurar que la aplicación funcione perfectamente con la IA desactivada, y que pueda activarse sin modificar el dominio principal.

---

### FASE 9 — Contract Audit + DQI

**Objetivo:** Medir el cumplimiento contractual y la calidad de los departamentos entregados mediante auditorías y un índice de calidad interno.

**Tareas Detalladas:**
* **Módulo Contract-to-Delivery Audit:** Implementación de la funcionalidad para cargar documentos (contrato, planos, especificaciones, memoria, ficha de acabados).
* **Comparación Contratado vs. Entregado:** Desarrollo del sistema para comparar lo contratado con lo entregado (`CONTRATADO → ESPERADO → ENTREGADO → RESULTADO`).
* **Resultados de Cumplimiento:** Definición y visualización de los resultados de cumplimiento (`COMPLIANT`, `PARTIAL`, `NON_COMPLIANT`, `NOT_VERIFIED`).
* **Department Quality Index (DQI):** Implementación del indicador interno de calidad (`DQI`) basado en la cantidad y severidad de defectos.
* **Datos Suficientes para DQI:** Asegurar la acumulación de datos suficiente para el cálculo robusto del DQI como métrica interna.

---

### FASE 10 — SaaS Commercialization

**Objetivo:** Habilitar la comercialización completa de la plataforma como producto SaaS multiempresa.

**Tareas Detalladas:**
* **Planes y Facturación:** Implementación de la gestión de planes de suscripción y el sistema de facturación.
* **Uso y Medición:** Desarrollo de funcionalidades para el seguimiento del uso y la medición de transacciones.
* **Onboarding de Clientes:** Configuración de procesos de onboarding y administración de inquilinos (`tenant administration`).
* **Analíticas de Suscripción:** Dashboards y analíticas para `subscriptions`, `organizations`, `MRR` y `churn`.
* **Ciclo de Vida de la Suscripción:** Gestión completa del ciclo de vida de las suscripciones.

---
---

**Actividades Transversales (a lo largo de todas las fases):**

*   **Seguridad:** HTTPS, Auth, RBAC, RLS, `organization_id`, private storage, signed URLs, validación de inputs, secretos, variables de entorno, rate limiting básico, auditoría básica, validación de propiedad, validación de MIME y tamaño de archivo.
*   **Testing:** Pruebas unitarias, de base de datos, RLS, API, Flutter widget, SQLite/Drift, offline, sync, retry, idempotencia, conflictos, integridad de evidencia, PDF, snapshot de informes, E2E del portal, seguridad y autorización.
*   **CI/CD:** Configuración y automatización de GitHub Actions para despliegue y pruebas.
*   **Observabilidad:** Implementación de monitoreo, logging y backups.
*   **Documentación:** Creación y mantenimiento de documentación de desarrollo y especificaciones técnicas.

---

## 4. Próximos Pasos Inmediatos

Tras la aprobación de la **Fase 0 (Auditoría GAP y Definición)** de los modelos de OpenInspection cruzados con nuestras necesidades particulares, el equipo proceditará de inmediato a la la ejecución de la **FASE 1 — Foundation** y sucesivamente **FASE 2 — Inspector**.
El estricto respeto por la modularidad y el control de licencias open-source es imperativo. Todo lo demás se construirá de forma incremental.
