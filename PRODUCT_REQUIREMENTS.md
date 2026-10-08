# PRODUCT_REQUIREMENTS.md

# Plataforma de Inspección Técnica de Departamentos

**Versión:** 1.0  
**Estado:** Product Requirements Document  
**Producto:** Plataforma de Inspección Técnica de Departamentos  
**Modelo:** Service First → SaaS Second  
**Mercado inicial:** Perú  
**Arquitectura:** Offline First + Evidence First + Security by Design

---

# 1. Product Overview

La plataforma permitirá gestionar el proceso completo de inspección técnica de departamentos, desde la solicitud y programación de una inspección hasta la ejecución en campo, generación del informe, entrega al cliente y seguimiento de observaciones.

El producto será utilizado inicialmente por una empresa de inspección técnica como herramienta interna para prestar el servicio.

Posteriormente, la misma plataforma podrá evolucionar hacia un producto SaaS para otras empresas de inspección.

## 1.1 Propósito

El sistema debe permitir:

```text
Solicitud
    ↓
Agendamiento
    ↓
Inspección
    ↓
Evidencia
    ↓
Informe
    ↓
Entrega al cliente
    ↓
Corrección
    ↓
Reinspección
    ↓
Cierre
```

El sistema debe reducir el trabajo administrativo y aumentar la calidad, trazabilidad y consistencia de las inspecciones.

---

# 2. Product Vision

## 2.1 Visión

Crear una plataforma especializada en inspección de departamentos que combine:

- ingeniería;
- evidencia fotográfica;
- inspección estructurada;
- planos;
- mediciones;
- reportes profesionales;
- seguimiento de observaciones;
- funcionamiento offline;
- automatización;
- inteligencia artificial asistida.

## 2.2 Posicionamiento

La propuesta de valor del servicio será:

> **Ingeniería + Tecnología + Evidencia**

Promesa comercial:

> **Inspecciona. Documenta. Verifica. Protege.**

La plataforma no debe presentarse como una herramienta que "garantiza" que un departamento está libre de defectos.

El alcance debe estar definido como inspección visual, funcional y no destructiva, complementada por mediciones y evidencia según el plan contratado.

---

# 3. Target Users

## 3.1 Cliente final

Persona que compra o recibe un departamento y quiere verificar las condiciones de entrega.

Necesita:

- saber qué le están entregando;
- detectar observaciones;
- tener evidencia;
- entender la importancia de cada observación;
- recibir un informe;
- verificar posteriormente las correcciones.

## 3.2 Inspector

Profesional encargado de realizar la inspección.

Necesita:

- conocer sus inspecciones;
- trabajar sin Internet;
- utilizar una lista estructurada;
- tomar fotografías;
- registrar observaciones;
- realizar mediciones;
- ubicar observaciones en planos;
- generar evidencia;
- completar la inspección rápidamente.

## 3.3 Administrador

Gestiona la operación de la empresa.

Necesita:

- registrar clientes;
- gestionar departamentos;
- gestionar citas;
- asignar inspectores;
- administrar servicios;
- registrar pagos;
- controlar inspecciones;
- revisar informes;
- gestionar reinspecciones;
- consultar métricas.

## 3.4 Futuro: Empresa cliente

En fases posteriores, constructoras, inmobiliarias o empresas de postventa podrán utilizar la plataforma para gestionar múltiples departamentos y observaciones.

---

# 4. Product Scope

El producto comprende:

1. Gestión de clientes.
2. Gestión de proyectos.
3. Gestión de edificios.
4. Gestión de departamentos.
5. Gestión de planos.
6. Agendamiento.
7. Gestión de inspecciones.
8. Checklists.
9. Observaciones.
10. Evidencia fotográfica.
11. Mediciones.
12. Ubicación de observaciones en planos.
13. Clasificación técnica.
14. Generación de informes.
15. Portal del cliente.
16. Seguimiento de correcciones.
17. Reinspecciones.
18. Auditoría.
19. Funcionamiento offline.
20. Sincronización.
21. IA asistida.
22. Analítica futura.

---

# 5. Service Plans

La plataforma debe soportar diferentes niveles de servicio.

## 5.1 Plan Esencial — Verificación

### Posicionamiento

> **Detecta antes de recibir.**

### Precio inicial de referencia

**Desde S/349**

El precio debe ser configurable por la organización y no estar codificado directamente en la aplicación.

### Incluye

- inspección visual general;
- revisión básica de acabados;
- revisión funcional básica;
- checklist;
- observaciones;
- fotografías;
- evidencia;
- clasificación básica;
- informe PDF;
- recomendaciones básicas.

### No incluye inicialmente

- portal avanzado del cliente;
- seguimiento de correcciones;
- reinspección;
- clasificación técnica avanzada;
- análisis especializado;
- diagnóstico destructivo.

---

# 5.2 Plan Integral — Inspección Técnica

### Posicionamiento

> **Conoce realmente cómo te entregan tu departamento.**

### Precio inicial de referencia

**Desde S/549**

### Incluye todo lo del Plan Esencial más:

- revisión ampliada de acabados;
- mediciones;
- nivelación;
- pendientes cuando corresponda;
- medición de humedad;
- pruebas funcionales ampliadas;
- clasificación técnica;
- interacción con plano;
- ubicación de observaciones;
- evidencia fotográfica organizada;
- informe técnico ampliado;
- portal del cliente.

Este será el:

> **PLAN RECOMENDADO**

---

# 5.3 Plan Protección — Inspección + Seguimiento

### Posicionamiento

> **No solo encontramos las observaciones. Verificamos que las corrijan.**

### Precio inicial de referencia

**Desde S/799**

### Incluye:

- todo el Plan Integral;
- seguimiento de observaciones;
- estado de corrección;
- evidencia antes/después;
- segunda visita;
- reinspección;
- verificación de correcciones;
- informe de cierre;
- historial de observaciones;
- portal del cliente.

---

# 5.4 Servicios adicionales

El sistema debe permitir servicios adicionales configurables:

| Servicio | Precio inicial de referencia |
|---|---:|
| Reinspección | S/199–299 |
| Inspección postventa | S/399–599 |
| Revisión de áreas comunes | Desde S/699 |
| Revisión documental | Desde S/199 |
| Contrato vs. entrega | Desde S/299 |
| Inspecciones especializadas | Cotización |

Los precios deben ser configurables.

---

# 6. Appointment Request

## 6.1 Objetivo

El cliente podrá proponer una fecha y hora para la inspección.

El sistema NO será un calendario externo.

No se integrará inicialmente con:

- Google Calendar;
- Outlook;
- Apple Calendar;
- Calendly;
- plataformas externas de booking.

La propia plataforma será la fuente de verdad de disponibilidad.

## 6.2 Flujo

```text
Cliente
   ↓
Selecciona servicio
   ↓
Selecciona fecha
   ↓
Selecciona hora
   ↓
Sistema verifica disponibilidad
   ↓
Cliente solicita cita
   ↓
Administrador revisa
   ↓
Confirma / cambia / rechaza
   ↓
Cita confirmada
   ↓
Registro de pago
   ↓
Inspección
```

## 6.3 Payment Status

El MVP no tendrá pagos online.

El sistema solamente registrará:

```text
UNPAID
PAYMENT_PENDING
PAID
REFUNDED
NOT_REQUIRED
```

El administrador podrá marcar manualmente una cita como pagada.

### Regla importante

```text
Appointment Status != Payment Status
```

Una cita puede estar:

```text
CONFIRMED + UNPAID
```

o:

```text
CONFIRMED + PAID
```

## 6.4 Disponibilidad

El cliente solamente debe ver:

```text
Disponible
No disponible
```

Nunca debe ver información de otros clientes.

Ejemplo:

```text
10:00–12:00
NO DISPONIBLE
```

No:

```text
10:00–12:00
Juan Pérez
PAGADO
```

---

# 7. Client Account

El cliente podrá:

- crear una cuenta;
- iniciar sesión;
- consultar sus solicitudes;
- consultar sus citas;
- consultar su estado de pago;
- consultar sus inspecciones;
- visualizar observaciones;
- visualizar fotografías;
- consultar planos;
- descargar informes;
- consultar correcciones;
- consultar reinspecciones.

El acceso debe estar restringido a sus propios datos.

---

# 8. Property Management

La plataforma debe manejar la jerarquía:

```text
Organization
    ↓
Project
    ↓
Building
    ↓
Floor
    ↓
Property / Department
```

Ejemplo:

```text
Condominio Los Cedros
    ├── Torre A
    │     ├── Piso 1
    │     │     ├── Dpto. 101
    │     │     └── Dpto. 102
    │     └── Piso 2
    │           ├── Dpto. 201
    │           └── Dpto. 202
    │
    └── Torre B
```

---

# 9. Property Plan

El cliente o administrador podrá cargar el plano del departamento.

Formatos iniciales:

- PDF;
- JPG;
- PNG.

El sistema debe permitir:

1. cargar plano;
2. visualizar plano;
3. crear áreas;
4. asociar áreas;
5. colocar marcadores;
6. asociar observaciones;
7. visualizar fotografías relacionadas.

## 9.1 Plan interaction

```text
Plano
   ↓
Área
   ↓
Elemento
   ↓
Observación
   ↓
Fotografía
```

## 9.2 Observation marker

Las coordenadas del marcador deben almacenarse normalizadas:

```text
x = 0.00–1.00
y = 0.00–1.00
```

Esto permite adaptar el marcador a diferentes tamaños de pantalla.

---

# 10. Inspection Templates

Las inspecciones utilizarán plantillas.

Plantillas iniciales:

```text
departamento_nuevo
departamento_recepcion
pre_entrega
postventa
reinspeccion
```

Cada plantilla deberá definir:

- áreas;
- categorías;
- elementos;
- preguntas;
- tipos de respuesta;
- requerimiento de fotografía;
- requerimiento de medición;
- recomendaciones;
- reglas de completitud.

La arquitectura toma como referencia el enfoque de OpenInspection de utilizar plantillas y bibliotecas de comentarios para acelerar la inspección, pero la estructura se implementará de forma propia para el dominio de departamentos nuevos.

---

# 11. Inspection Areas

Áreas iniciales de ejemplo:

```text
Ingreso
Sala
Comedor
Cocina
Lavandería
Dormitorio principal
Dormitorio secundario
Baño principal
Baño secundario
Terraza
Balcón
Pasadizos
Closets
Estacionamiento
Depósito
```

La lista debe ser configurable.

---

# 12. Inspection Checklist

Cada elemento debe permitir registrar diferentes tipos de respuesta.

Ejemplos:

```text
OK
OBSERVATION
NOT_APPLICABLE
NOT_VERIFIED
```

También podrá utilizar:

```text
Boolean
Number
Text
Date
Select
Multi-select
Photo
Measurement
```

---

# 13. Observation Management

Una observación deberá contener:

```text
id
inspection_id
area_id
item_id
title
description
severity
status
recommendation
created_at
updated_at
```

## 13.1 Severity

Escala propia:

```text
INFO
MENOR
MODERADA
MAYOR
CRÍTICA
```

Esta clasificación es una herramienta interna del servicio.

No debe presentarse como:

- certificación normativa;
- clasificación oficial;
- diagnóstico estructural;
- garantía de seguridad.

---

# 14. Observation Library

La plataforma tendrá una biblioteca reutilizable.

Ejemplo:

```text
OBS-001

Categoría:
Acabados

Área:
Baño

Elemento:
Cerámico

Título:
Junta irregular

Descripción:
Se observa junta con ancho no uniforme.

Recomendación:
Revisar y corregir acabado.
```

Campos:

```text
code
category
area
element
title
description
recommendation
default_severity
version
active
```

Esto permitirá acelerar inspecciones y mantener consistencia.

OpenInspection utiliza una biblioteca de comentarios y elementos de reparación para acelerar la captura en campo; esta idea se adopta conceptualmente, pero con contenido propio.

---

# 15. Evidence Management

La evidencia es un componente central del producto.

Tipos:

```text
PHOTO
VIDEO
DOCUMENT
MEASUREMENT
```

El MVP priorizará fotografías.

Cada fotografía deberá mantener metadatos:

```text
id
inspection_id
observation_id
file_path
mime_type
size
sha256
captured_at
uploaded_at
device_id
sequence
metadata
```

## 15.1 Evidence chain

```text
Inspection
   ↓
Area
   ↓
Observation
   ↓
Evidence
```

La evidencia no debe quedar sin contexto.

---

# 16. Photo Workflow

El flujo offline será:

```text
Tomar fotografía
       ↓
Guardar archivo local
       ↓
Guardar metadata en SQLite
       ↓
Crear sync operation
       ↓
PENDING
       ↓
UPLOAD
       ↓
SERVER
       ↓
VERIFY HASH
       ↓
UPLOADED
```

La pérdida de conexión no debe provocar pérdida de fotografías.

---

# 17. Measurements

El sistema permitirá registrar mediciones.

Inicialmente:

- longitud;
- ancho;
- altura;
- pendiente;
- nivel;
- humedad;
- temperatura cuando corresponda;
- otros valores configurables.

Formato:

```text
value
unit
type
location
notes
```

Ejemplo:

```text
Humedad:
12.4 %

Ubicación:
Muro de dormitorio principal
```

---

# 18. Inspector Mobile Application

La aplicación móvil será:

> **Offline First**

Tecnología:

```text
Flutter
Dart
SQLite
Drift
```

El inspector debe poder realizar una inspección completa sin conexión después de haber sincronizado los datos necesarios.

---

# 19. Offline Requirements

Sin Internet el inspector debe poder:

- iniciar sesión previamente autenticado;
- consultar inspecciones descargadas;
- consultar planos;
- consultar áreas;
- consultar checklist;
- registrar observaciones;
- tomar fotografías;
- registrar mediciones;
- colocar observaciones en planos;
- modificar información;
- cerrar la inspección.

No debe requerir Internet para guardar datos de campo.

---

# 20. Synchronization

El sistema utilizará:

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

La sincronización debe ser:

- automática;
- reintentable;
- idempotente;
- segura;
- tolerante a pérdida de conexión.

---

# 21. Conflict Resolution

El MVP no utilizará:

- Yjs;
- CRDT;
- colaboración simultánea.

El inspector será el principal editor durante una inspección.

Cada entidad deberá tener:

```text
local_id
server_id
version
sync_status
created_at
updated_at
```

Los conflictos no deben sobrescribirse silenciosamente.

---

# 22. Inspection Workflow

Flujo principal:

```text
Appointment
    ↓
Inspection
    ↓
Property
    ↓
Plan
    ↓
Areas
    ↓
Checklist
    ↓
Observations
    ↓
Evidence
    ↓
Measurements
    ↓
Review
    ↓
Close Inspection
```

Estados:

```text
DRAFT
SCHEDULED
IN_PROGRESS
PAUSED
COMPLETED
REVIEW
PUBLISHED
CANCELLED
```

---

# 23. Report Generation

El sistema generará un informe profesional.

Formato inicial:

```text
HTML + CSS
       ↓
PDF
```

El informe debe contener:

1. portada;
2. información del cliente;
3. información del inmueble;
4. fecha;
5. inspector;
6. alcance;
7. metodología;
8. resumen ejecutivo;
9. observaciones;
10. clasificación;
11. fotografías;
12. mediciones;
13. planos;
14. marcadores;
15. recomendaciones;
16. conclusiones;
17. limitaciones;
18. información de trazabilidad.

---

# 24. Report Status

Los informes tendrán estados:

```text
DRAFT
GENERATED
REVIEWED
PUBLISHED
SUPERSEDED
```

Una vez publicado un informe, su contenido debe considerarse una versión histórica.

Las modificaciones posteriores deberán generar una nueva versión.

---

# 25. Report Evidence Integrity

El sistema deberá generar:

```text
SHA-256
```

del informe publicado.

Registrar:

```text
report_hash
published_at
published_by
version
```

Una futura versión podrá incorporar:

- firma criptográfica;
- hash chain;
- verificador público;
- QR de verificación.

OpenInspection utiliza mecanismos más avanzados de firma y verificación de documentos; para este proyecto se adopta inicialmente una estrategia más simple y progresiva.

---

# 26. Client Portal

El cliente podrá consultar:

```text
Mis departamentos
      ↓
Mis inspecciones
      ↓
Plano
      ↓
Observaciones
      ↓
Fotografías
      ↓
Estado de corrección
      ↓
Informe PDF
```

El portal será desarrollado con:

```text
Nuxt + Vue + TypeScript
```

---

# 27. Correction Tracking

Cada observación podrá convertirse en una acción.

Estados:

```text
PENDIENTE
EN_CORRECCIÓN
CORREGIDO
RECHAZADO
VERIFICADO
CERRADO
```

Flujo:

```text
Observación
    ↓
Acción
    ↓
Corrección
    ↓
Evidencia de corrección
    ↓
Reinspección
    ↓
Verificación
    ↓
Cierre
```

---

# 28. Reinspection

La reinspección será principalmente una funcionalidad del Plan Protección.

El sistema debe permitir:

- seleccionar observaciones pendientes;
- programar reinspección;
- registrar nueva visita;
- tomar evidencia;
- comparar antes/después;
- aceptar/rechazar corrección;
- cerrar observación.

---

# 29. Contract-to-Delivery Audit

Funcionalidad futura.

Permitirá cargar:

- contrato;
- especificaciones;
- memoria;
- planos;
- anexos;
- acabados contratados.

Y comparar:

```text
CONTRATADO
     ↓
ESPERADO
     ↓
ENTREGADO
     ↓
RESULTADO
```

Resultados:

```text
COMPLIANT
PARTIAL
NON_COMPLIANT
NOT_VERIFIED
```

Esta funcionalidad no es necesaria para el MVP operativo.

---

# 30. AI Assistance

La IA será asistente y no autoridad técnica.

Arquitectura:

```text
AIProvider
    ├── OllamaProvider
    └── FutureExternalProvider
```

## 30.1 Usos iniciales

La IA podrá ayudar a:

- redactar observaciones;
- normalizar textos;
- sugerir títulos;
- sugerir clasificación;
- generar recomendaciones;
- resumir inspecciones;
- organizar información;
- asistir en análisis preliminar de fotografías.

## 30.2 Human in the Loop

Toda salida de IA deberá ser revisada por una persona antes de publicarse.

La IA no podrá:

- declarar automáticamente incumplimiento normativo;
- emitir diagnóstico estructural;
- aprobar una inspección;
- modificar evidencia;
- publicar informes automáticamente.

---

# 31. Construction Defect Intelligence

El sistema deberá estructurar los datos de observaciones para construir progresivamente una base de conocimiento.

Cada observación podrá alimentar:

```text
Defect
Category
Area
Element
Severity
Cause
Recommendation
Correction
Resolution time
Evidence
```

Esto permitirá posteriormente desarrollar:

- estadísticas;
- patrones;
- indicadores;
- modelos predictivos;
- recomendaciones;
- análisis por proyecto;
- análisis por constructor;
- análisis por tipo de acabado.

---

# 32. Department Quality Index

Funcionalidad futura.

Se podrá calcular un indicador interno:

> **Department Quality Index — DQI**

El DQI no será una certificación normativa.

Podrá considerar:

- cantidad de observaciones;
- severidad;
- áreas afectadas;
- observaciones repetidas;
- correcciones;
- pendientes;
- resultado de reinspección.

Ejemplo conceptual:

```text
DQI
100 ─ Excelente
 80 ─ Bueno
 60 ─ Atención
 40 ─ Deficiente
  0 ─ Crítico
```

La fórmula será definida después de contar con datos reales.

---

# 33. Roles and Permissions

Roles iniciales:

```text
OWNER
ADMIN
INSPECTOR
CLIENT
```

## OWNER

Acceso total de la organización.

## ADMIN

Gestiona:

- clientes;
- citas;
- inspecciones;
- inspectores;
- informes;
- pagos registrados.

## INSPECTOR

Puede:

- ver inspecciones asignadas;
- ejecutar inspecciones;
- registrar observaciones;
- cargar evidencia;
- generar borradores.

## CLIENT

Puede acceder únicamente a:

- sus propiedades;
- sus citas;
- sus inspecciones;
- sus observaciones;
- sus informes.

---

# 34. Multi-Tenancy

La plataforma debe diseñarse desde el inicio para múltiples organizaciones.

Las entidades principales tendrán:

```text
organization_id
```

La seguridad utilizará:

```text
PostgreSQL
+
Row Level Security
+
organization_id
```

Una organización nunca podrá acceder a datos de otra organización.

---

# 35. Audit Log

El sistema registrará acciones relevantes:

```text
LOGIN
LOGOUT
CREATE_APPOINTMENT
UPDATE_APPOINTMENT
CONFIRM_APPOINTMENT
MARK_PAYMENT_PAID
CREATE_INSPECTION
UPDATE_INSPECTION
CREATE_OBSERVATION
UPLOAD_EVIDENCE
PUBLISH_REPORT
DOWNLOAD_REPORT
CREATE_REINSPECTION
CHANGE_STATUS
DELETE
```

Campos mínimos:

```text
id
organization_id
user_id
action
entity_type
entity_id
metadata
created_at
```

---

# 36. Notifications

MVP inicial (mensajes internos y emails básicos):

- Notificaciones internas dentro de la aplicación/portal web (ej. "Nueva cita asignada").
- Confirmación de solicitud de cita por email (básico, sin plantilla avanzada).
- Actualizaciones de estado de cita por email.

No se requiere inicialmente:

- Integración con WhatsApp API.
- Integración con SMS.
- Servicio de email transaccional avanzado (ej. plantillas dinámicas, marketing).
- Push notifications.

La arquitectura deberá permitir agregar estas funcionalidades posteriormente, con proveedores desacoplados.

---

# 37. Public Website

La web pública tendrá:

```text
Inicio
Servicios
Planes
Cómo funciona
Preguntas frecuentes
Solicitar inspección
Contacto
```

Tecnología:

```text
Astro
```

El objetivo será:

- bajo consumo;
- SEO;
- velocidad;
- contenido estático;
- pocas dependencias JavaScript.

---

# 38. Admin Web Application

La aplicación administrativa será desarrollada con:

```text
Nuxt + Vue + TypeScript
```

Módulos:

```text
Dashboard
Clientes
Proyectos
Departamentos
Agenda
Inspecciones
Observaciones
Informes
Reinspecciones
Usuarios
Configuración
Auditoría
```

---

# 39. Inspector Application

La aplicación móvil será desarrollada con:

```text
Flutter
Dart
SQLite
Drift
```

Módulos:

```text
Login
My Inspections
Inspection
Plan
Areas
Checklist
Observations
Evidence
Measurements
Sync
Profile
```

---

# 40. Functional Requirements

## FR-001 Authentication

The system shall allow authorized users to authenticate securely.

## FR-002 Organization Isolation

The system shall isolate organization data.

## FR-003 Client Registration

The administrator shall be able to create clients.

## FR-004 Property Registration

The administrator shall be able to create properties/departments.

## FR-005 Plan Upload

The administrator shall be able to upload a property plan.

## FR-006 Appointment Request

The client shall be able to propose a date and time.

## FR-007 Availability

The system shall verify whether the requested interval conflicts with an active appointment.

## FR-008 Appointment Confirmation

The administrator shall be able to confirm or modify an appointment.

## FR-009 Payment Recording

The administrator shall be able to mark an appointment as paid.

## FR-010 Inspection Creation

A confirmed appointment shall be convertible into an inspection.

## FR-011 Inspection Execution

The inspector shall be able to execute an inspection.

## FR-012 Offline Operation

The inspector shall be able to perform field work without Internet connectivity.

## FR-013 Observation Creation

The inspector shall be able to create observations.

## FR-014 Evidence

The inspector shall be able to capture and associate photographs.

## FR-015 Measurements

The inspector shall be able to record measurements.

## FR-016 Plan Markers

The inspector shall be able to locate observations on the property plan.

## FR-017 Synchronization

The system shall synchronize offline data when connectivity returns.

## FR-018 Report

The system shall generate a PDF report.

## FR-019 Client Portal

The client shall be able to view the inspection and report.

## FR-020 Corrections

The system shall support correction tracking.

## FR-021 Reinspection

The system shall support reinspections.

## FR-022 Audit

The system shall record important system actions.

---

# 41. Non-Functional Requirements

## NFR-001 Offline Reliability

Field inspection data must not depend on continuous Internet connectivity.

## NFR-002 Security

Authentication, authorization, RLS and storage access controls must be implemented before production.

## NFR-003 Performance

The application should remain responsive on mid-range Android tablets and phones.

## NFR-004 Data Integrity

Evidence and inspection information must not be silently lost during synchronization.

## NFR-005 Idempotency

Repeated synchronization operations must not create duplicate records.

## NFR-006 Traceability

Published reports must be traceable to their inspection and evidence.

## NFR-007 Scalability

The architecture must support future multi-organization SaaS operation.

## NFR-008 Maintainability

Business logic should remain independent of infrastructure providers.

---

# 42. MVP Definition

The MVP is considered complete when an inspector can execute the following flow:

```text
Login
  ↓
View assigned inspection
  ↓
Open department
  ↓
View plan
  ↓
View areas
  ↓
Open checklist
  ↓
Record observation
  ↓
Take photograph
  ↓
Record measurement
  ↓
Place observation on plan
  ↓
Continue offline
  ↓
Complete inspection
  ↓
Reconnect
  ↓
Synchronize
  ↓
Generate report
  ↓
Client accesses report
  ↓
Client downloads PDF
```

---

# 43. MVP Scheduling Definition

The scheduling MVP is complete when:

```text
Client
  ↓
Selects service
  ↓
Proposes date/time
  ↓
System checks availability
  ↓
Request created
  ↓
Admin confirms
  ↓
Admin records payment manually
  ↓
Appointment linked to inspection
```

No external calendar or payment gateway is required.

---

# 44. MVP Exclusions

The following are explicitly outside MVP:

- Google Calendar integration;
- Outlook Calendar;
- Apple Calendar;
- online payment gateway;
- WhatsApp API;
- SMS;
- CRM;
- marketplace;
- external inspector network;
- automatic pricing;
- advanced dispatch;
- geographic optimization;
- collaborative inspection editing;
- Yjs;
- CRDT;
- real-time simultaneous editing;
- automatic normative compliance;
- automatic structural diagnosis;
- advanced computer vision;
- predictive ML;
- DQI production algorithm;
- contract audit;
- complex billing;
- subscriptions;
- multi-provider AI;
- external accounting systems.

---

# 45. OpenInspection Reference

OpenInspection is used as a technical/product reference, not as a dependency.

The project provides useful concepts around:

- public booking;
- inspection templates;
- canned comments;
- inspection editor;
- offline field operation;
- reports;
- client portal;
- reinspections;
- audit;
- AI assistance;
- multi-tenant isolation;
- security;
- testing.

Its current architecture is based on React Router, React, Hono, Drizzle, Cloudflare Workers, D1, R2, KV and Durable Objects. It also includes a public booking widget and an inspection workflow designed for field use.

Our architecture intentionally differs:

| OpenInspection | This project |
|---|---|
| React Router | Nuxt |
| React | Vue |
| Cloudflare Workers | Supabase/backend services |
| D1 | PostgreSQL |
| R2 | Supabase Storage |
| PWA offline | Native Flutter offline app |
| IndexedDB | SQLite/Drift |
| Yjs/CRDT | Simple sync MVP |
| External calendar support | No calendar integration MVP |
| Payment integrations | Manual payment status MVP |
| Generic home inspection | Apartment handover inspection |
| Multiple inspection domains | New department delivery focus |

---

# 46. Licensing and Legal Boundary

OpenInspection is licensed under:

> GNU Affero General Public License v3.0 (AGPL-3.0)

Therefore this project must not copy OpenInspection source code into a proprietary implementation without appropriate legal review.

The project may study:

- architectural concepts;
- domain concepts;
- UX patterns;
- workflows;
- security concepts;
- testing strategies;
- data modeling ideas.

Implementation should be independently developed.

Maintain:

```text
docs/THIRD_PARTY_LICENSES.md
```

for external dependencies and references.

---

# 47. Product Principles

## Evidence First

Every important observation should have evidence whenever practical.

## Offline First

Field inspection must continue without Internet.

## Human in the Loop

AI assists professionals but does not replace technical judgment.

## Security by Design

Security is part of architecture, not a final feature.

## Low Cost First

Avoid unnecessary infrastructure costs before product validation.

## Simple First

Do not build complex SaaS features before validating the inspection workflow.

## Service First, SaaS Second

The company will first use the platform internally.

The platform should solve the company's operational problems before becoming a commercial SaaS.

## Data as an Asset

Every inspection should improve the structured defect database.

## Modular AI

AI providers must remain replaceable.

## No Overengineering

The system should solve the current business problem with the smallest reliable architecture.

---

# 48. Product Roadmap

## Phase 0 — Definition

- Project Charter
- Product Requirements
- Architecture
- Database design
- Security design
- UX flows

## Phase 1 — Foundation + Security Baseline

- Repository (monorepo, GitHub, CI/CD base)
- Flutter project setup
- Nuxt project setup
- Astro project setup
- Supabase setup (PostgreSQL, Auth, Storage, RLS base)
- PostgreSQL migrations base
- Authentication (users, roles, RBAC, MFA basic)
- Multi-tenancy (organization_id, ownership validation)
- API base (error handling, logging, rate limiting basic)
- Environment configuration and secrets management
- Testing base (unit, database, RLS, API tests)
- Database seed (initial data)
- Development documentation

- Core Domain Model:
  - organization
  - user
  - client
  - project
  - building
  - floor
  - property
  - inspection
  - service_types
  - availability_rules
  - appointments
  - appointment_status_history
  - payment_records
  - HTTPS
  - private storage
  - signed URLs
  - input validation
  - MIME validation
  - file size validation
  - audit básico

## Phase 2 — Inspector Offline

- Flutter widget tests
- SQLite/Drift setup for local data
- Local domain model (inspection, inspection_area, inspection_item, observation, measurement, evidence, property_plan, observation_plan_marker, action)
- Local files storage (photo, evidence, temporary documents)
- Offline states (LOCAL, OUTBOX, PENDING, SYNCED, FAILED, CONFLICT)
- Offline-first functionality (take inspection, photos, observations without internet)
- SQLite/Drift tests
- Offline tests

## Phase 3 — Sync Engine

- Outbox (LOCAL → OUTBOX)
- Upload (OUTBOX → UPLOAD → SERVER)
- Retry mechanism
- Idempotency
- Conflict resolution (FAILED → RETRY → CONFLICT)
- ACK (SERVER → VERIFY → ACK → SYNCED)
- Sync tests
- Retry tests
- Idempotency tests
- Conflict tests
- Evidence integrity tests

## Phase 4 — Reports

- HTML/CSS based PDF generation
- Report components (Photos, Plan, Observation summary, Severity summary, Checklist summary, Evidence index, Inspection metadata, SHA-256)
- Report lifecycle (DRAFT, GENERATING, GENERATED, REVIEW, PUBLISHED, LOCKED)
- Versioning (new version for changes after publish, no silent edits)
- PDF tests
- Report snapshot tests

## Phase 5 — Client Portal

- Inspection view
- Interactive plan
- Observations (with photos and status)
- Reports (access and download)
- Appointment status (view)
- Portal E2E tests

## Phase 6 — Postventa + Reinspection

- Observation action tracking (OBSERVACIÓN → ACCIÓN → RESPONSABLE → FECHA LÍMITE)
- Correction workflow (CORRECCIÓN → EVIDENCIA → REINSPECCIÓN → VERIFICADO → CERRADO)
- Evidence before/after
- Reinspection scheduling
- Verification of corrections

## Phase 7 — Production Hardening

- MFA generalizado (for high-privilege users)
- Security headers avanzados
- CSP endurecido
- Penetration testing
- Audit log inmutable
- Hash chains
- Evidence packs
- Firmas criptográficas
- Security audit
- Threat modeling avanzado
- Security tests (RLS penetration scenarios, file upload attacks, authorization tests)

## Phase 8 — AI Assistant

- AIProvider (OllamaProvider, ExternalProvider)
- Decoupled AI architecture (AI = OFF for MVP, AI = ON later without main domain modification)
- Text assistance (redacción, classification, recommendations, summaries)
- Image analysis assistance (preliminary, human-reviewed)

## Phase 9 — Contract Audit + DQI

- Document upload (contract, plans, specifications, memory, finishing sheet)
- Comparison (CONTRATADO → ENTREGADO → COMPARACIÓN)
- Compliance results (COMPLIANT, PARTIAL, NON_COMPLIANT, NOT_VERIFIED)
- Department Quality Index (DQI as internal quality metric, not normative certification)
- Data sufficiency for DQI

## Phase 10 — SaaS Commercialization

- Plans and Billing
- Usage and Metering
- Onboarding
- Tenant administration
- Analytics (subscriptions, organizations, MRR, churn)
- Subscription lifecycle

---

**Transversal Activities (across all phases):**

- **Security:** HTTPS, Auth, RBAC, RLS, organization_id, private storage, signed URLs, input validation, secrets, environment variables, rate limiting básico, audit básico, ownership validation, MIME validation, file size validation
- **Testing:** Unit, Database, RLS, API, Flutter widget, SQLite/Drift, Offline, Sync, Retry, Idempotency, Conflict, Evidence integrity, PDF, Report snapshot, Portal E2E, Security, Authorization
- **CI/CD:** GitHub Actions (configured for tasks)
- **Observability:** Monitoring, logging, backups
- **Documentation:** Development documentation, technical specifications

---

# 49. Success Metrics

## Business

- inspections completed;
- average revenue per inspection;
- conversion rate;
- reinspection rate;
- customer satisfaction;
- repeat customers.

## Operational

- inspection duration;
- report generation time;
- observations per inspection;
- synchronization failures;
- evidence upload failures;
- percentage of inspections completed offline.

## Product

- appointment request completion rate;
- appointment confirmation rate;
- client portal usage;
- report download rate;
- correction closure rate.

---

# 50. Final Product Flow

The complete product vision is:

```text
                    PUBLIC WEBSITE
                         │
                         ▼
                REQUEST INSPECTION
                         │
                         ▼
                   AVAILABILITY
                         │
                         ▼
                    APPOINTMENT
                         │
                  ┌──────┴──────┐
                  │             │
               PAYMENT       SCHEDULE
               MANUAL           │
                  │             │
                  └──────┬──────┘
                         ▼
                     INSPECTION
                         │
                         ▼
              ┌─────────────────────┐
              │     FLUTTER APP     │
              │                     │
              │ Plan                │
              │ Areas               │
              │ Checklist           │
              │ Observations        │
              │ Photos              │
              │ Measurements        │
              │ Offline             │
              └──────────┬──────────┘
                         │
                       SYNC
                         │
                         ▼
                   POSTGRESQL
                         │
            ┌────────────┼─────────────┐
            ▼            ▼             ▼
        REPORT       PORTAL       POST-SALE
            │            │             │
            ▼            ▼             ▼
          CLIENT      CLIENT       REINSPECTION
                                      │
                                      ▼
                                    CLOSURE
```

---

# 51. Product North Star

The product should make it possible for one inspector to perform a complete department inspection with minimal administrative overhead while preserving a reliable evidence trail.

The core experience must remain:

> **Agenda → Inspecciona → Documenta → Sincroniza → Reporta → Verifica**

Everything else is secondary.