# POSTMORTEM Y AUDITORÍA DE IDONEIDAD DEL PROYECTO
**Plataforma de Inspección Técnica Inmobiliaria**  
**Fecha de Evaluación:** 23 de Octubre de 2026  
**Rama:** `main` | **Repositorio:** [github.com/lucyb11j/InspectorApp](https://github.com/lucyb11j/InspectorApp)

---

## 1. Resumen Ejecutivo y Diagnóstico de Avance Real

El proyecto se estructuró originalmente sobre un plan de **10 fases** (Fase 0 a Fase 9). A la fecha se ha completado la base arquitectónica y funcional de las primeras 4 fases, alcanzando un estado operativo en modo local y web-admin, pero con una complejidad inicial que requiere ajuste estratégico para su adopción real en obra.

### Matriz de Avance por Fase

| Fase | Título | Estado Actual | Componentes Implementados |
| :--- | :--- | :---: | :--- |
| **Fase 0** | Definición y Análisis | **100% Completa** | Gap Analysis con OpenInspection, matrices de requisitos, modelo de datos y diseño UI/UX. |
| **Fase 1** | Foundation & Core Backend | **100% Completa** | Supabase Postgres (esquemas multi-tenant, RLS, tablas core), Auth, `pnpm` monorepo, `shared-types` en TypeScript, seed data y migraciones SQL. |
| **Fase 2** | Inspector Offline-First | **90% Completa** | Drift/SQLite local en Flutter con 6 tablas, servicio de cámara con SHA-256 binario, marcación táctil sobre planos (`property_plans` y `observation_plan_markers`), catálogo de no-conformidades y simulador interactivo en Nuxt. |
| **Fase 3** | Sync Engine | **85% Completa** | Modelo Outbox transaccional (`LOCAL → OUTBOX → SYNCED`), pipeline Evidence-First (la imagen se sube antes de la observación), `RetryPolicy` con exponential backoff + jitter, `ConflictResolver` (Last-Write-Wins), tabla de auditoría `sync_operations` y monitor de sincronización en vivo. |
| **Fase 4** | Informes Técnicos (Reports) | **40% (Foundation)** | Migración SQL (`report_templates`, `report_jobs`, `report_signatures`), contratos Dart (`InspectionReportData`, `GeneratedReport`), endpoints y modelos listos para renderizado. |
| **Fase 5** | Portal del Cliente | **0%** | Planificado. |
| **Fase 6** | Postventa y Reinspección | **0%** | Planificado. |
| **Fase 7** | Hardening & Criptografía | **15%** | Hashing SHA-256 y RLS implementados; pendientes firmas HSM y hash-chains avanzadas. |
| **Fase 8** | Asistente IA | **0%** | Planificado (redacción de defectos asistida). |
| **Fase 9** | Auditoría Contractual & DQI | **0%** | Planificado. |

---

## 2. Evaluación de Idoneidad: Planificación vs. Necesidad en Obra

### El Problema de la Planificación Original
El plan de 10 fases fue diseñado como una suite corporativa SaaS enterprise con un grado de sobreingeniería previo a la validación de campo:
1. **Fricción Operativa para el Ingeniero/Arquitecto:** El flujo original contemplaba agendamientos multi-rol, reglas complejas de disponibilidad, estados de pago previos y múltiples pasos antes de iniciar la inspección. En la realidad de la obra o entrega de departamento, el profesional necesita abrir la app, seleccionar o crear la unidad, fotografiar la falla, ubicarla en el plano y terminar.
2. **Dependencia de Infraestructura Pesada en Desarrollo:** El acoplamiento inicial estricto con GoTrue y Realtime causó bloqueos de visualización cuando Docker no estaba conectado o cuando las credenciales no coincidían exactamente.
3. **Foco Difuso:** Se dedicó esfuerzo a planificar módulos periféricos (pagos de citas, DQI estadístico, portal de cliente final) antes de cerrar el **entregable fundamental**: el **Acta / Informe Técnico de Visita**.

### La Necesidad Real (Core de Negocio)
El valor inmediato que esperan los profesionales técnicos y las constructoras se resume en:
> **"Llegar al inmueble, registrar rápidamente las observaciones con foto y plano (incluso sin internet), presionar 'Generar Acta' y obtener un documento técnico formal listo para firma y entrega."**

---

## 3. Postmortem Técnico de Incidentes Recientes

### Incidente A: Bloqueo de Credenciales y HTTP 400/401
* **Causa Raíz:** En `supabase/migrations/20261008000000_core_schema.sql` el campo `role` tenía la restricción `CHECK (role IN ('OWNER', 'ADMIN', 'INSPECTOR', 'CLIENT'))` en mayúsculas, mientras que en `seed.sql` se insertaba `'admin'` en minúscula. Al ejecutar el seed, la inserción del usuario fallaba silenciosamente en Postgres, dejando a GoTrue sin usuario y al frontend devolviendo `400 Bad Request / Invalid login credentials`.
* **Impacto en Frontend:** Las llamadas posteriores a `/rest/v1/inspections` fallaban con `401 Unauthorized`.
* **Solución Aplicada:** Se corrigió el rol a `'ADMIN'` en el seed, se sincronizó Postgres con GoTrue y se agregaron capas de fallback en el frontend para evitar que la falta de sesión bloquee la interfaz visual.

### Incidente B: Advertencia de Node.js Deprecado (v20 vs v22)
* **Causa Raíz:** Supabase SDK v2.117+ emite una advertencia de deprecación en Node 20. El entorno contaba con Node v20 y v22, pero el shell predeterminado apuntaba a v20.
* **Solución Aplicada:** Se forzó `PATH` hacia Node v22.23.0 en `.bashrc` y en los scripts de ejecución, garantizando builds de Nuxt y Nitro limpios.

### Incidente C: Atributos de Formularios y Accesibilidad
* **Causa Raíz:** Ausencia de `autocomplete="username"` y `autocomplete="current-password"` en el formulario de login.
* **Solución Aplicada:** Adición de atributos estándar en `login.vue`.

---

## 4. Estrategia de Simplificación: "Modo Visita Técnica Rápida"

Para garantizar que ingenieros, arquitectos y técnicos adopten la herramienta de inmediato sin sacrificar la futura escalabilidad a SaaS, se propone el siguiente flujo ágil:

1. **Unificación del Flujo de Observación (3 Clics Máximo):**
   - **Clic 1:** Tomar fotografía (la app captura tamaño, timestamp y genera SHA-256 en segundo plano).
   - **Clic 2:** Tocar el plano interactivo para colocar el pin de ubicación de la falla.
   - **Clic 3:** Seleccionar el defecto del catálogo rápido (ej. "Fisura en muro", "Bisagra desalineada", "Falta silicona") o dictar por voz la descripción.

2. **Generador Directo de Acta / Informe Técnico (Fase 4 Simplificada):**
   - Proveer una plantilla HTML/PDF limpia que compile automáticamente:
     - **Carátula:** Datos del proyecto, unidad inmobiliaria, cliente, inspector técnico y fecha/hora.
     - **Resumen cuantitativo:** Total de observaciones agrupadas por severidad (Menor, Moderada, Mayor, Crítica).
     - **Detalle gráfico:** Fotografía de cada defecto acompañada de la miniatura del plano con su pin exacto de ubicación.
     - **Cuadro de firmas:** Espacio digital o impreso para la firma del inspector y del propietario/residente.

3. **Arquitectura Preparada para Futura Expansión:**
   - La base de datos actual **NO necesita reducirse**; las tablas de multi-tenancy (`organizations`), citas y contratos ya están creadas y operativas.
   - Simplemente se prioriza el **cuaderno de campo técnico** en la interfaz para que el técnico no se pierda entre configuraciones administrativas.

---

## 5. Plan de Acción Inmediato (Roadmap Ajustado)

1. **Paso Inmediato (Fase 4 Core):**
   - Crear la vista `/reports/[inspectionId]` en Nuxt que renderice el documento técnico formal listo para `window.print()` / exportación directa a PDF.
   - Incluir la cuadrícula de evidencias fotográficas con sus coordenadas sobre el plano del inmueble.
2. **Paso Siguiente (Firma y Cierre de Visita):**
   - Componente de captura de firma digital sobre pantalla (canvas táctil).
   - Cierre de la inspección con cambio de estado a `COMPLETED`.
3. **Futuro (SaaS Expandible):**
   - Reactivar los módulos de Postventa (Fase 6), Portal de Clientes (Fase 5) y Asistente IA (Fase 8) sobre esta base validada en obra.

