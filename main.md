
# ARCHITECTURE.md

# Plataforma de Inspección Técnica de Entrega de Departamentos

**Versión:** 1.0  
**Estado:** Architecture Baseline  
**Fecha:** 2026-10-07  
**Documento relacionado:** `OPENINSPECTION_GAP_ANALYSIS.md`

---

## 1. Propósito

Este documento define la arquitectura técnica oficial de la plataforma de Inspección Técnica de Entrega de Departamentos.

La plataforma permitirá:

- inspeccionar departamentos;
- trabajar completamente offline durante la inspección;
- registrar observaciones;
- tomar fotografías y evidencias;
- registrar mediciones;
- ubicar observaciones sobre planos;
- sincronizar posteriormente;
- generar informes técnicos;
- permitir acceso al cliente;
- realizar seguimiento postventa;
- ejecutar reinspecciones;
- mantener trazabilidad;
- evolucionar posteriormente hacia una plataforma SaaS.

La arquitectura se inspira conceptualmente en soluciones existentes como **OpenInspection**, pero no depende de ella.

---

# 2. Principios Arquitectónicos

La plataforma se desarrollará bajo los siguientes principios.

## 2.1 Offline First

La inspección debe poder realizarse sin conexión a Internet.

El inspector no debe depender de:

- Wi-Fi;
- datos móviles;
- conexión permanente al servidor.

La aplicación debe poder:

```text
LOGIN
  ↓
DESCARGAR DATOS NECESARIOS
  ↓
INSPECCIÓN OFFLINE
  ↓
FOTOS
  ↓
OBSERVACIONES
  ↓
MEDICIONES
  ↓
PLANO
  ↓
CIERRE
  ↓
RECUPERAR INTERNET
  ↓
SINCRONIZAR
```

---

## 2.2 Evidence First

Toda observación importante debe poder estar respaldada por evidencia.

Una observación puede contener:

```text
Observación
├── descripción
├── área
├── elemento
├── severidad
├── estado
├── recomendación
├── mediciones
├── fotografías
├── ubicación en plano
└── fecha/hora
```

---

## 2.3 Security by Design

La seguridad no será incorporada únicamente al final.

Debe existir desde el diseño:

- autenticación;
- autorización;
- RBAC;
- aislamiento por organización;
- RLS;
- validación de entradas;
- almacenamiento privado;
- URLs firmadas;
- protección de sesiones;
- rate limiting;
- audit log;
- control de archivos;
- control de versiones;
- backups.

---

## 2.4 Human in the Loop

La IA no será autoridad técnica.

La IA puede:

- sugerir clasificación;
- ayudar a redactar;
- resumir;
- normalizar observaciones;
- sugerir recomendaciones;
- ayudar con fotografías.

Pero:

```text
IA
 ↓
SUGERENCIA
 ↓
INSPECTOR
 ↓
APROBACIÓN
 ↓
RESULTADO FINAL
```

La IA no decidirá automáticamente cumplimiento normativo.

---

## 2.5 Low Cost First

Durante MVP se utilizarán preferentemente:

- software open source;
- servicios gratuitos;
- free tiers;
- infraestructura administrada de bajo costo.

No se contratarán inicialmente:

- Kubernetes;
- servidores dedicados;
- GPU cloud;
- múltiples proveedores de IA;
- infraestructura enterprise;
- sistemas de alta disponibilidad complejos.

---

# 3. Referencia OpenInspection

OpenInspection será utilizado como **referencia técnica y conceptual**.

Su análisis se encuentra documentado en:

```text
docs/OPENINSPECTION_GAP_ANALYSIS.md
```

Se estudiarán especialmente:

- autenticación;
- RBAC;
- multi-tenancy;
- inspecciones;
- plantillas;
- observaciones;
- evidencias;
- reportes;
- reinspecciones;
- auditoría;
- seguridad;
- testing;
- offline;
- sincronización.

### Regla

Si OpenInspection ya resolvió conceptualmente un problema:

```text
NO diseñar sin investigar.
```

Primero:

```text
OpenInspection
      ↓
Estudiar patrón
      ↓
Evaluar compatibilidad
      ↓
Adaptar
      ↓
Implementar en nuestro stack
```

No se incorporará código AGPL directamente sin revisión legal de compatibilidad.

---

# 4. Arquitectura General

La plataforma tendrá tres aplicaciones principales:

```text
                         INTERNET
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
       WEB PÚBLICA                   WEB APP
          Astro                     Nuxt
              │                    + TypeScript
              │                           │
              │                  ┌────────┴────────┐
              │                  │                 │
              │                ADMIN             CLIENT
              │
              │
              └──────────────┬────────────────────┘
                             │
                             ▼
                       SUPABASE
                             │
             ┌───────────────┼────────────────┐
             │               │                │
             ▼               ▼                ▼
        PostgreSQL        Storage            Auth
             │
             │
             │
             ▲
             │
       SYNC / API
             │
             │
      ┌──────┴───────┐
      │              │
      ▼              │
 Flutter App         │
 Inspector           │
      │              │
 SQLite + Drift      │
      │              │
 Local Files         │
      └──────────────┘
```

---

# 5. Aplicaciones

## 5.1 Inspector App

La aplicación del inspector será:

```text
Flutter
+
Dart
+
SQLite
+
Drift
```

Plataforma inicial:

```text
Android
```

Posteriormente:

```text
iOS
```

### Motivo

Flutter permite mantener una única base de código para la aplicación móvil y es adecuado para una aplicación que necesita:

- cámara;
- archivos;
- almacenamiento local;
- SQLite;
- funcionamiento offline;
- sincronización;
- interfaz táctil;
- tablet;
- teléfono.

---

# 6. Aplicación Web

La web se dividirá en dos partes.

## 6.1 Web pública

Framework:

```text
Astro
```

Uso:

- página principal;
- servicios;
- planes;
- precios;
- información empresarial;
- blog;
- SEO;
- landing pages;
- contacto.

La web pública no necesita ser una aplicación JavaScript pesada.

Se priorizará:

```text
HTML
CSS
mínimo JavaScript
```

---

# 7. Web Application

Framework:

```text
Nuxt
+
TypeScript
```

Será utilizada para:

```text
/admin
/client
```

### Admin

Funciones:

- organizaciones;
- usuarios;
- proyectos;
- edificios;
- departamentos;
- inspectores;
- inspecciones;
- plantillas;
- reportes;
- seguimiento;
- configuración.

### Cliente

Funciones:

- departamentos;
- inspecciones;
- observaciones;
- fotografías;
- planos;
- estado de correcciones;
- reinspecciones;
- reportes;
- descarga de PDF.

---

# 8. ¿Por qué Astro + Nuxt?

No se utilizará Next.js como framework principal.

La separación será:

```text
Astro
→ Web pública

Nuxt
→ Aplicación administrativa
→ Portal cliente
```

Esto evita convertir la página pública en una aplicación pesada cuando no necesita serlo.

Nuxt se utilizará donde sí necesitamos:

- autenticación;
- navegación;
- formularios;
- dashboards;
- interacción;
- estado;
- portal.

TypeScript seguirá utilizándose porque proporciona tipado y reduce errores en un sistema con muchas entidades y reglas de seguridad.

---

# 9. Backend

Backend inicial:

```text
Supabase
```

Componentes:

```text
Supabase Auth
Supabase PostgreSQL
Supabase Storage
Supabase APIs
PostgreSQL RLS
```

No se desarrollará inicialmente un backend independiente complejo.

---

# 10. Base de Datos

Motor:

```text
PostgreSQL
```

La base será multi-tenant.

Estructura conceptual:

```text
organizations
    │
    ├── users
    │
    ├── projects
    │      │
    │      └── buildings
    │             │
    │             └── floors
    │                    │
    │                    └── properties
    │
    └── inspections
```

---

# 11. Modelo de Dominio

Jerarquía principal:

```text
Organización
    │
    └── Proyecto inmobiliario
            │
            └── Edificio
                    │
                    └── Piso
                            │
                            └── Departamento
                                    │
                                    ├── Cliente
                                    ├── Plano
                                    └── Inspecciones
```

---

# 12. Inspección

Una inspección estará compuesta por:

```text
Inspection
│
├── Areas
│
├── Items
│
├── Observations
│
├── Measurements
│
├── Evidence
│
├── Plan markers
│
├── Actions
│
└── Report
```

---

# 13. Plantillas

Las plantillas permitirán reutilizar estructuras de inspección.

Ejemplo:

```text
DEPARTAMENTO_NUEVO
│
├── Sala
│   ├── Pisos
│   ├── Muros
│   ├── Techo
│   ├── Ventanas
│   └── Puertas
│
├── Cocina
│   ├── Muebles
│   ├── Mesón
│   ├── Instalaciones
│   └── Equipamiento
│
├── Dormitorio
│
├── Baño
│
└── Lavandería
```

Cada elemento puede contener:

```text
Checklist
Criterio
Tipo de verificación
Resultado esperado
```

---

# 14. Biblioteca de Observaciones

Se implementará una biblioteca reutilizable.

Ejemplo:

```text
OBS-PISO-001

Categoría:
Pisos

Elemento:
Cerámico

Título:
Pieza con desnivel

Descripción:
Se observa diferencia de nivel entre piezas...

Recomendación:
Verificar y corregir antes de la recepción.

Severidad sugerida:
MENOR
```

El inspector podrá utilizarla para acelerar la generación del informe.

---

# 15. Sistema de Severidad

Se utilizará un sistema propio:

```text
INFO
MENOR
MODERADA
MAYOR
CRÍTICA
```

Este sistema será:

- interno;
- explicable;
- configurable;
- orientado a priorización.

No debe presentarse como certificación normativa.

---

# 16. Evidencia

Cada evidencia tendrá metadatos.

Modelo conceptual:

```text
Evidence
├── id
├── inspection_id
├── observation_id
├── file_path
├── mime_type
├── size
├── sha256
├── captured_at
├── uploaded_at
├── device_id
├── sequence
└── metadata
```

---

# 17. Almacenamiento de Fotografías

En móvil:

```text
Cámara
   ↓
Archivo local
   ↓
SQLite metadata
   ↓
Sync Queue
   ↓
UPLOAD
   ↓
Supabase Storage
```

La aplicación no debe borrar inmediatamente el archivo local.

Debe existir confirmación:

```text
UPLOAD
 ↓
SERVER
 ↓
VERIFY
 ↓
HASH
 ↓
ACK
 ↓
SYNCED
 ↓
eliminar archivo local si corresponde
```

---

# 18. Offline Storage

La aplicación utilizará:

```text
SQLite
+
Drift
+
Local File Storage
```

Entidades offline:

```text
inspection
inspection_area
inspection_item
observation
measurement
evidence
action
sync_operation
```

Campos fundamentales:

```text
local_id
server_id
sync_status
created_at
updated_at
version
```

---

# 19. Sync Engine

El MVP utilizará:

```text
LOCAL
  ↓
OUTBOX
  ↓
SYNC
  ↓
SERVER
  ↓
ACK
```

Estados:

```text
PENDING
UPLOADING
SYNCED
FAILED
CONFLICT
```

Características:

- retry;
- idempotencia;
- operaciones ordenadas;
- detección de conflictos;
- recuperación ante fallos;
- logs de sincronización.

---

# 20. Idempotencia

Una operación no debe ejecutarse dos veces por error.

Ejemplo:

```text
CREATE_OBSERVATION
operation_id = UUID
```

Si el teléfono pierde conexión después de enviar la operación:

```text
RETRY
```

El servidor debe reconocer:

```text
operation_id ya procesado
```

y no crear una segunda observación.

---

# 21. Conflictos

En MVP:

```text
Inspector = principal editor
```

No se implementará inicialmente:

- colaboración simultánea;
- Yjs;
- CRDT;
- edición colaborativa.

Si existe conflicto:

```text
CONFLICT
   ↓
NO sobrescribir silenciosamente
   ↓
registrar
   ↓
resolver
```

---

# 22. Planos

Los planos son una funcionalidad propia del producto.

Modelo:

```text
property_plans
```

Campos:

```text
id
property_id
file_path
page
width
height
scale
version
```

Marcadores:

```text
observation_plan_markers
```

Campos:

```text
id
observation_id
plan_id
x
y
```

Las coordenadas serán normalizadas:

```text
0 ≤ x ≤ 1
0 ≤ y ≤ 1
```

Esto permite mantener la posición aunque cambie el tamaño de visualización.

---

# 23. Flujo de Inspección sobre Plano

Inspector:

```text
Abrir plano
    ↓
Seleccionar área
    ↓
Crear observación
    ↓
Colocar marcador
    ↓
Tomar fotografía
    ↓
Registrar medición
    ↓
Guardar
```

Cliente:

```text
Abrir plano
    ↓
Ver marcador
    ↓
Abrir observación
    ↓
Ver fotografías
    ↓
Ver estado
```

---

# 24. Seguimiento Postventa

Modelo:

```text
Observation
     ↓
Action
     ↓
Assigned To
     ↓
Due Date
     ↓
Correction Evidence
     ↓
Reinspection
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

# 25. Reinspección

La reinspección debe mantener relación con la inspección original.

```text
Inspection 001
     │
     ├── Observation 001
     ├── Observation 002
     └── Observation 003
              │
              ▼
        Reinspection 001
              │
              ├── CORREGIDO
              ├── PENDIENTE
              └── RECHAZADO
```

Debe mantenerse el historial.

---

# 26. Reportes

El reporte será generado mediante:

```text
HTML
+
CSS
↓
PDF
```

Contenido:

1. Portada
2. Datos del inmueble
3. Datos del inspector
4. Resumen ejecutivo
5. Resultado general
6. Plano
7. Resumen de observaciones
8. Detalle de observaciones
9. Fotografías
10. Mediciones
11. Recomendaciones
12. Estado de correcciones
13. Firma
14. Anexos

---

# 27. Integridad del Reporte

Inicialmente:

```text
Report
 ↓
SHA-256
 ↓
signed_at
signed_by
 ↓
Audit Log
```

Posteriormente:

```text
Hash Chain
+
Firma criptográfica
+
Evidence Pack
+
Public Verification
```

La firma criptográfica avanzada no será requisito del MVP.

---

# 28. Audit Log

Eventos mínimos:

```text
LOGIN
LOGOUT

CREATE_INSPECTION
UPDATE_INSPECTION

CREATE_OBSERVATION
UPDATE_OBSERVATION

UPLOAD_EVIDENCE
DELETE_EVIDENCE

PUBLISH_REPORT
DOWNLOAD_REPORT

SIGN_REPORT

CREATE_REINSPECTION
CHANGE_STATUS

DELETE
```

Los logs no deben ser modificables por usuarios normales.

---

# 29. Multi-Tenancy

La plataforma se diseñará desde el inicio como multi-tenant.

Todas las entidades relevantes deberán relacionarse con:

```text
organization_id
```

Ejemplo:

```text
organization
    ↓
project
    ↓
building
    ↓
property
    ↓
inspection
```

---

# 30. Row Level Security

PostgreSQL RLS será una barrera fundamental.

Ejemplo conceptual:

```text
Usuario A
   ↓
Organization A
   ↓
Project A
   ↓
Inspection A
```

No debe poder consultar:

```text
Organization B
Project B
Inspection B
```

aunque intente modificar IDs manualmente.

---

# 31. RBAC

Roles iniciales:

```text
PLATFORM_ADMIN
ORG_ADMIN
INSPECTOR
CLIENT
```

### PLATFORM_ADMIN

Administración global.

### ORG_ADMIN

Administración de su organización.

### INSPECTOR

Puede ejecutar inspecciones asignadas.

### CLIENT

Puede consultar la información autorizada de sus propiedades.

---

# 32. Autenticación

Se utilizará:

```text
Supabase Auth
```

Funciones:

- email/password;
- recuperación;
- sesiones;
- refresh;
- MFA para roles administrativos;
- revocación;
- control de acceso.

Nunca se implementará manualmente el almacenamiento de contraseñas.

---

# 33. Seguridad de Storage

Los archivos deben almacenarse en buckets privados.

Acceso mediante:

```text
Signed URLs
```

Validaciones:

```text
MIME
Extensión
Tamaño
Usuario
Organization
Inspection
Hash
```

Nunca confiar únicamente en la extensión:

```text
foto.jpg
```

debe verificarse realmente como archivo de imagen permitido.

---

# 34. Protección de Secretos

Nunca incluir:

```text
SERVICE_ROLE_KEY
DATABASE_PASSWORD
PRIVATE_KEY
AI_SECRET
```

en:

- Flutter;
- navegador;
- APK;
- Git;
- GitHub;
- variables públicas.

Utilizar:

```text
.env.local
Environment Variables
CI/CD Secrets
Secret Manager
```

---

# 35. API

Inicialmente se priorizarán:

```text
Supabase APIs
```

y operaciones de servidor de Nuxt cuando sean necesarias.

No se desarrollará un microservicio independiente para cada módulo.

Una API propia adicional podrá incorporarse cuando exista una necesidad real.

---

# 36. Arquitectura de Servicios

MVP:

```text
Flutter
     │
     ▼
Supabase
     │
 ┌───┼────┐
 ▼   ▼    ▼
Auth DB Storage
```

Web:

```text
Astro
   │
   └── Public Web

Nuxt
   │
   ├── Admin
   └── Client
        │
        ▼
     Supabase
```

---

# 37. IA

La IA tendrá una abstracción:

```text
AIProvider
```

Implementaciones futuras:

```text
OllamaProvider
ExternalAIProvider
```

La aplicación no dependerá directamente de Ollama.

---

# 38. Ollama

Ollama se ejecutará en:

```text
PC
Servidor
Infraestructura backend controlada
```

No se ejecutará inicialmente dentro de:

```text
Tablet
Teléfono
Flutter App
```

El flujo será:

```text
Inspector
   ↓
Sync
   ↓
Servidor
   ↓
AI Provider
   ↓
Ollama
   ↓
Suggestion
   ↓
Inspector
   ↓
Approve
```

---

# 39. Contract-to-Delivery Audit

Funcionalidad diferenciadora.

Permitirá comparar:

```text
Contrato
Especificaciones
Planos
Anexos
        ↓
REQUISITOS
        ↓
ENTREGADO
        ↓
COMPARACIÓN
```

Resultados:

```text
COMPLIANT
PARTIAL
NON_COMPLIANT
NOT_VERIFIED
```

No será parte del primer MVP.

---

# 40. DQI

Posteriormente:

```text
Department Quality Index
```

Será un indicador interno.

Puede considerar:

- cantidad de observaciones;
- severidad;
- áreas afectadas;
- observaciones críticas;
- pendientes;
- reincidencias.

No será presentado como certificación normativa.

---

# 41. Testing

La estrategia se dividirá en:

```text
Unit
Integration
Database
RLS
Offline
Sync
Security
E2E
```

Tests críticos:

### Multi-tenant

```text
Cliente A ≠ Cliente B
```

### Autorización

```text
Inspector A ≠ Organization B
```

### Offline

```text
Foto offline
+
reconexión
=
foto no perdida
```

### Sync

```text
Retry
=
no duplicación
```

### Reporte

```text
Publicado
=
evidencia trazable
```

---

# 42. Testing Offline

Debe probarse explícitamente:

```text
Internet disponible
Internet perdido
Internet intermitente
Aplicación cerrada durante sync
Teléfono reiniciado
Upload fallido
Upload duplicado
Storage lleno
Foto corrupta
Sync repetido
```

El offline no se considerará terminado hasta superar estos escenarios.

---

# 43. CI/CD

Inicialmente:

```text
Git
GitHub
GitHub Actions
```

Pipeline conceptual:

```text
Commit
 ↓
Lint
 ↓
Unit Tests
 ↓
Integration Tests
 ↓
Security Checks
 ↓
Build
 ↓
Deploy
```

---

# 44. Estructura del Repositorio

```text
inspection-platform/
│
├── apps/
│   ├── inspector/
│   │   ├── lib/
│   │   ├── test/
│   │   └── pubspec.yaml
│   │
│   ├── web-public/
│   │   ├── src/
│   │   └── astro.config.*
│   │
│   └── web-app/
│       ├── src/
│       ├── routes/
│       │   ├── admin/
│       │   └── client/
│       └── svelte.config.*
│
├── supabase/
│   ├── migrations/
│   ├── seed.sql
│   ├── functions/
│   └── config.toml
│
├── packages/
│   ├── domain/
│   ├── schemas/
│   └── shared/
│
├── ai/
│   ├── providers/
│   ├── prompts/
│   └── report_generation/
│
├── reports/
│   ├── templates/
│   ├── css/
│   └── assets/
│
├── docs/
│   ├── PROJECT_CHARTER.md
│   ├── PRODUCT_REQUIREMENTS.md
│   ├── ARCHITECTURE.md
│   ├── DATABASE.md
│   ├── OFFLINE_SYNC.md
│   ├── SECURITY.md
│   ├── OPENINSPECTION_GAP_ANALYSIS.md
│   └── THIRD_PARTY_LICENSES.md
│
├── tests/
│
├── scripts/
│
└── README.md
```

---

# 45. Qué se toma de OpenInspection

OpenInspection será referencia para:

```text
Authentication
RBAC
Multi-tenancy
Inspection model
Templates
Observations
Evidence
Reports
Reinspection
Audit
Security
Testing
Offline
Synchronization
```

Pero serán implementados dentro de nuestra arquitectura.

---

# 46. Qué NO se incorpora

No incorporar inicialmente:

```text
Cloudflare Workers
Cloudflare D1
Cloudflare KV
Durable Objects
Yjs
CRDT
React Router
Drizzle
Arquitectura específica de OpenInspection
CRM
Booking
QuickBooks
Referral
Marketplace
Spectora Import
```

No existe justificación para introducir estas tecnologías únicamente porque OpenInspection las utiliza.

---

# 47. Regla de Licenciamiento

OpenInspection utiliza AGPL-3.0 según el análisis realizado.

Por ello:

```text
Estudiar código
        ↓
Identificar patrón
        ↓
Evaluar licencia
        ↓
Determinar compatibilidad
        ↓
Implementar
```

No copiar código AGPL directamente al producto propietario sin revisión legal.

Mantener:

```text
docs/THIRD_PARTY_LICENSES.md
```

con:

- proyecto;
- URL;
- versión;
- licencia;
- componente;
- uso;
- modificaciones;
- obligaciones.

---

# 48. Qué sí podemos reutilizar conceptualmente

Especialmente:

### 48.1 Modelo de inspección

```text
Inspection
Template
Item
Observation
Evidence
Report
Reinspection
```

### 48.2 Seguridad

```text
RBAC
Tenant isolation
Audit
Rate limiting
Validation
Security headers
```

### 48.3 Offline

```text
Local data
Sync
Retry
Conflict handling
```

### 48.4 Reporting

```text
Templates
Images
Pagination
Print CSS
PDF
Evidence
```

---

# 49. Arquitectura de MVP

El MVP no debe intentar implementar toda la plataforma.

Debe lograr:

```text
LOGIN
 ↓
PROYECTO
 ↓
DEPARTAMENTO
 ↓
PLANO
 ↓
ÁREAS
 ↓
INSPECCIÓN
 ↓
CHECKLIST
 ↓
OBSERVACIÓN
 ↓
FOTOGRAFÍA
 ↓
MEDICIÓN
 ↓
MARCADOR EN PLANO
 ↓
OFFLINE
 ↓
SYNC
 ↓
PDF
 ↓
CLIENTE
```

Si esto funciona correctamente, existe un producto mínimo viable.

---

# 50. Fases

## Fase 0 — Architecture

```text
PROJECT_CHARTER
PRODUCT_REQUIREMENTS
ARCHITECTURE
DATABASE
SECURITY
OFFLINE_SYNC
```

---

## Fase 1 — Foundation

```text
Flutter
Supabase
PostgreSQL
Auth
RLS
Storage
Astro
Nuxt
```

---

## Fase 2 — Inspector

```text
Projects
Buildings
Properties
Plans
Areas
Inspections
Checklist
Observations
Measurements
Evidence
```

---

## Fase 3 — Offline + Sync

```text
SQLite
Drift
Local files
Outbox
Retry
Idempotency
Conflict handling
```

---

## Fase 4 — Reports

```text
HTML
CSS
PDF
Photos
Plans
Observations
Measurements
```

---

## Fase 5 — Client Portal

```text
Client
Inspection
Plan
Observations
Evidence
PDF
```

---

## Fase 6 — Protection

```text
Post-sale
Actions
Correction evidence
Reinspection
Status
```

---

## Fase 7 — Security Hardening

```text
MFA
Audit
Hash
Signed reports
Evidence pack
Security testing
```

---

## Fase 8 — AI

```text
AIProvider
Ollama
Classification
Summary
Drafting
Photo assistance
```

---

## Fase 9 — Contract Audit

```text
Documents
Requirements
Contract items
Delivery items
Compliance
```

---

## Fase 10 — SaaS

```text
Organizations
Plans
Subscriptions
Usage
Billing
Analytics
```

---

# 51. Criterio para agregar tecnología

Una tecnología nueva solamente se incorpora si responde a una necesidad concreta.

Ejemplo:

```text
Problema
   ↓
Requisito
   ↓
Evaluación de alternativas
   ↓
Tecnología
```

No:

```text
Tecnología interesante
   ↓
buscar dónde utilizarla
```

---

# 52. Criterio para agregar servicios cloud

Antes de contratar un servicio:

1. ¿El MVP realmente lo necesita?
2. ¿Existe alternativa open source?
3. ¿Existe free tier?
4. ¿Puede ejecutarse localmente?
5. ¿Genera dependencia innecesaria?
6. ¿Afecta la seguridad?
7. ¿Aumenta considerablemente el costo operativo?

Si no existe una necesidad real:

```text
NO CONTRATAR
```

---

# 53. Seguridad como requisito de salida

No se considera listo un módulo únicamente porque funcione.

Debe cumplir:

```text
Functional
+
Security
+
Data isolation
+
Error handling
+
Auditability
+
Testing
```

---

# 54. Arquitectura Final Objetivo

```text
                         CLIENTES
                            │
             ┌──────────────┴──────────────┐
             │                             │
             ▼                             ▼
        WEB PÚBLICA                    PORTAL WEB
           Astro                        Nuxt
                                            │
                                      ┌─────┴─────┐
                                      │           │
                                    Admin       Client
                                      │           │
                                      └─────┬─────┘
                                            │
                                            ▼
                                      SUPABASE
                                  ┌─────────┼─────────┐
                                  │         │         │
                                Auth       DB       Storage
                                  │         │         │
                                  │     PostgreSQL    │
                                  │        + RLS      │
                                  │         │         │
                                  └─────────┼─────────┘
                                            ▲
                                            │
                                         SYNC
                                            │
                                  ┌─────────┴─────────┐
                                  │                   │
                                  ▼                   │
                            FLUTTER APP              │
                            INSPECTOR                 │
                                  │                   │
                             SQLite/Drift             │
                                  │                   │
                            Local Files               │
                                  │                   │
                              OFFLINE                 │
                                  │                   │
                                  └───────────────────┘
                                           
                                  FUTURO
                                    │
                         ┌──────────┴──────────┐
                         ▼                     ▼
                       AI                  Analytics
                     Ollama                  ML
```

---

# 55. Stack Tecnológico Oficial

| Capa | Tecnología | Uso |
|---|---|---|
| Inspector App | Flutter | Aplicación móvil/tablet |
| Lenguaje móvil | Dart | Desarrollo Flutter |
| Offline DB | SQLite | Persistencia local |
| ORM local | Drift | Acceso tipado a SQLite |
| Public Web | Astro | Marketing/SEO |
| Web App | Nuxt | Admin + Portal |
| Web Language | TypeScript | Tipado y lógica web |
| Backend | Supabase | Backend administrado |
| Database | PostgreSQL | Datos transaccionales |
| Security DB | PostgreSQL RLS | Aislamiento multi-tenant |
| Authentication | Supabase Auth | Identidad/sesiones |
| Storage | Supabase Storage | Fotografías/documentos |
| Reports | HTML + CSS | Plantillas |
| PDF | HTML/CSS → PDF | Informes |
| AI | Ollama / Provider abstraction | IA posterior |
| Version Control | Git | Código |
| Repository | GitHub | Colaboración |
| CI/CD | GitHub Actions | Automatización |
| Containers | Docker | Desarrollo reproducible |

---

# 56. Decisión Arquitectónica Final

La arquitectura oficial queda definida como:

```text
FLUTTER
+
SQLITE / DRIFT
+
ASTRO
+
SVELTEKIT
+
TYPESCRIPT
+
SUPABASE
+
POSTGRESQL
+
RLS
+
SUPABASE STORAGE
+
HTML/CSS → PDF
+
OLLAMA FUTURO
```

OpenInspection será utilizado como:

```text
REFERENCIA
```

y no como:

```text
DEPENDENCIA
```

La prioridad del producto será:

```text
SEGURIDAD
      ↓
OFFLINE
      ↓
EVIDENCIA
      ↓
SINCRONIZACIÓN
      ↓
REPORTE
      ↓
PORTAL
      ↓
POSTVENTA
      ↓
IA
      ↓
SAAS
```

El objetivo técnico del MVP es simple:

> **Un inspector debe poder completar una inspección profesional de un departamento sin Internet, conservar todas las evidencias, sincronizarlas posteriormente y generar un informe técnico verificable.**

Todo componente que no contribuya directamente a ese objetivo deberá posponerse.