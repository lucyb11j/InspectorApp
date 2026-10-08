# PROJECT CHARTER
## Inspection Platform — Plataforma de Inspección Técnica, Evidencia y Postventa

**Versión:** 0.2  
**Fecha:** 2026-10-07  
**Estado:** Inicio / Fase 0  
**Producto inicial:** Inspección técnica de entrega de departamentos  
**Modelo futuro:** SaaS multiempresa para inspecciones, QA/QC, postventa y control de calidad

---

# 1. Resumen ejecutivo

El proyecto consiste en desarrollar una plataforma digital **offline-first** para ejecutar inspecciones técnicas de entrega de departamentos desde una tablet, almacenar evidencias y observaciones sin depender de Internet, sincronizar la información cuando exista conectividad, generar informes técnicos con fotografías y ofrecer al cliente un portal web para consultar el estado de su inmueble, revisar observaciones, visualizar evidencias y descargar su informe final.

La plataforma será diseñada desde el inicio como un producto **multiempresa (multi-tenant)**.

La primera empresa usuaria será la propia empresa de inspección. Sin embargo, la arquitectura permitirá posteriormente comercializar el software como SaaS para:

- inspectores independientes;
- empresas de inspección;
- inmobiliarias;
- constructoras;
- empresas de postventa;
- QA/QC;
- facility management;
- mantenimiento;
- supervisión;
- auditorías.

La Inteligencia Artificial será una capa desacoplada del sistema. Inicialmente se priorizará el uso de **IA local mediante Ollama**, evitando una suscripción mensual obligatoria.

La IA será utilizada como asistente para:

- redactar observaciones;
- clasificar defectos;
- sugerir severidad;
- generar recomendaciones;
- analizar fotografías como evidencia auxiliar;
- generar resúmenes;
- ayudar a producir informes.

La IA **no reemplazará el criterio profesional del inspector**.

El principal activo de largo plazo será la base de datos estructurada de:

> inmuebles + áreas + elementos + defectos + fotografías + mediciones + correcciones + reinspecciones + resultados.

Cuando exista suficiente información, podrán desarrollarse modelos estadísticos y Machine Learning para detectar patrones y predecir probabilidad de defectos.

---

# 2. Visión

Construir una plataforma que combine:

```text
INGENIERÍA
     +
EVIDENCIA
     +
TECNOLOGÍA
     +
IA
     +
ANALÍTICA
```

para transformar una inspección tradicional en un proceso:

```text
INSPECCIONAR
      ↓
DOCUMENTAR
      ↓
EVIDENCIAR
      ↓
INFORMAR
      ↓
CORREGIR
      ↓
VERIFICAR
      ↓
ANALIZAR
      ↓
PREDECIR
```

---

# 3. Objetivo estratégico

El proyecto debe permitir dos escenarios simultáneamente.

## Escenario A — Empresa de inspección

La plataforma se utiliza internamente para prestar el servicio.

```text
CLIENTE
   ↓
RESERVA
   ↓
INSPECCIÓN
   ↓
INFORME
   ↓
SEGUIMIENTO
   ↓
REINSPECCIÓN
```

## Escenario B — Producto SaaS

La plataforma puede ser utilizada por terceros.

```text
EMPRESA A
   ↓
sus usuarios
   ↓
sus proyectos
   ↓
sus clientes


EMPRESA B
   ↓
sus usuarios
   ↓
sus proyectos
   ↓
sus clientes
```

Los datos de cada organización estarán aislados.

---

# 4. Problema que se quiere resolver

Las inspecciones tradicionales presentan:

1. Checklist en papel.
2. Excel desconectado de las fotografías.
3. Fotografías almacenadas en galerías o WhatsApp.
4. Informes manuales.
5. Mucho tiempo de redacción.
6. Falta de ubicación exacta del defecto.
7. Poca trazabilidad.
8. Dificultad para hacer reinspecciones.
9. Falta de histórico.
10. Dependencia de Internet en algunas soluciones.
11. Poca explotación de datos.
12. Dificultad para identificar defectos recurrentes.

---

# 5. Solución

La solución será una plataforma compuesta por cuatro grandes productos.

```text
┌──────────────────────────────────────────┐
│             INSPECTION PLATFORM          │
├──────────────────────────────────────────┤
│                                          │
│  1. APP INSPECTOR                        │
│     Tablet / celular                     │
│                                          │
│  2. WEB ADMINISTRATIVA                   │
│     Empresa                              │
│                                          │
│  3. PORTAL CLIENTE                       │
│     Celular / tablet / PC                │
│                                          │
│  4. BACKEND + IA + REPORTES              │
│                                          │
└──────────────────────────────────────────┘
```

---

# 6. Usuarios

## 6.1 Inspector

Utiliza tablet o celular.

Funciones:

- descargar inspecciones;
- trabajar offline;
- visualizar plano;
- crear áreas;
- seleccionar ambientes;
- ejecutar checklist;
- registrar observaciones;
- tomar fotografías;
- registrar mediciones;
- guardar notas;
- sincronizar.

---

## 6.2 Administrador

Funciones:

- proyectos;
- edificios;
- departamentos;
- clientes;
- inspectores;
- plantillas;
- inspecciones;
- informes;
- observaciones;
- reinspecciones;
- dashboard.

---

## 6.3 Cliente

El cliente tendrá acceso desde:

- celular;
- tablet;
- computadora.

Podrá:

- visualizar su inmueble;
- consultar el plano;
- tocar un ambiente;
- consultar observaciones;
- ver fotografías;
- ver estado de correcciones;
- consultar reinspecciones;
- descargar el informe PDF.

---

# 7. Aplicación del inspector

## Requisito fundamental

La aplicación **NO debe depender de Internet durante la inspección**.

Debe ser:

> **Offline First**

El inspector podrá trabajar completamente sin conexión.

---

# 8. Funcionamiento offline

Antes de iniciar la inspección:

```text
INTERNET
   ↓
Sincronizar inspección
   ↓
Tablet
```

Se descargan:

- proyecto;
- departamento;
- cliente;
- plano;
- checklist;
- áreas existentes;
- configuración;
- plantilla;
- información necesaria.

Después:

```text
SIN INTERNET
     ↓
INSPECCIÓN
     ↓
DATOS LOCALES
```

El inspector podrá:

- navegar;
- tomar fotografías;
- crear áreas;
- registrar observaciones;
- registrar medidas;
- marcar OK;
- marcar OBS;
- marcar N/A;
- agregar notas.

---

# 9. Almacenamiento local

La aplicación utilizará:

### Base local

```text
SQLite
```

para:

- inspecciones;
- áreas;
- elementos;
- observaciones;
- estados;
- configuraciones;
- cola de sincronización.

### Almacenamiento local

Para:

- fotografías;
- evidencias;
- documentos temporales.

---

# 10. Sincronización

Cuando la tablet vuelva a tener Internet:

```text
TABLET
   │
   ├── datos
   ├── fotografías
   └── cambios
         │
         ▼
   SYNC ENGINE
         │
         ▼
      BACKEND
         │
     ┌───┴────┐
     ▼        ▼
DATABASE   STORAGE
```

La sincronización debe ser:

- automática;
- reanudable;
- segura;
- idempotente;
- tolerante a fallos;
- con control de conflictos.

Si Internet desaparece durante la sincronización:

> los datos locales no se deben perder.

---

# 11. Plano del departamento

Esta será una característica diferencial.

El cliente proporcionará un plano, que podrá ser:

- PDF;
- JPG;
- PNG;
- imagen exportada;
- croquis.

El sistema permitirá cargarlo como plano de referencia.

---

# 12. Creación de áreas

El inspector podrá abrir el plano:

```text
┌──────────────────────────────────┐
│             PLANO                │
│                                  │
│   ┌────────────┐ ┌───────────┐  │
│   │    SALA    │ │  COCINA   │  │
│   └────────────┘ └───────────┘  │
│                                  │
│   ┌────────────┐ ┌───────────┐  │
│   │ DORM. 01   │ │ DORM. 02  │  │
│   └────────────┘ └───────────┘  │
│                                  │
│   ┌────────────┐ ┌───────────┐  │
│   │    BAÑO    │ │ LAVANDERÍA│  │
│   └────────────┘ └───────────┘  │
└──────────────────────────────────┘
```

El inspector podrá definir las áreas.

Ejemplo:

```text
A01 = Sala
A02 = Cocina
A03 = Dormitorio principal
A04 = Dormitorio 2
A05 = Baño principal
A06 = Lavandería
```

---

# 13. Ubicación de observaciones en el plano

Una observación deberá poder asociarse a:

```text
Proyecto
   ↓
Inmueble
   ↓
Inspección
   ↓
Área
   ↓
Elemento
   ↓
Observación
   ↓
Fotografía
```

Ejemplo:

```text
Dormitorio principal
       ↓
Muro
       ↓
OBS-023
       ↓
IMG-034
IMG-035
```

---

# 14. Interacción del inspector

En tablet:

```text
PLANO
 ↓
Tocar DORMITORIO
 ↓
Elementos
 ↓
Muro
 ↓
OBS
 ↓
Tomar fotografía
 ↓
Registrar observación
```

Esto evita que el inspector tenga que recordar posteriormente dónde estaba cada fotografía.

---

# 15. Interacción del cliente

El cliente podrá hacer:

```text
Portal
 ↓
Plano
 ↓
Tocar ambiente
 ↓
Ver observaciones
 ↓
Tocar OBS-023
 ↓
Ver fotografía
 ↓
Ver descripción
 ↓
Ver estado
```

Por ejemplo:

```text
DORMITORIO PRINCIPAL

⚠ 3 observaciones

OBS-023
Fisura superficial en muro
[2 fotografías]

Estado:
PENDIENTE
```

---

# 16. Checklist

Cada punto tendrá:

```text
Zona
Elemento
Punto de inspección
Estado
Observación
Severidad
Recomendación
Fotografía
Responsable
Fecha límite
Estado de corrección
Verificación
```

Estados:

```text
OK
OBS
N/A
PENDIENTE
CORREGIDO
VERIFICADO
```

---

# 17. Evidencia fotográfica

Cada observación puede tener varias fotografías.

```text
OBS-023
│
├── IMG-001
├── IMG-002
└── IMG-003
```

Cada evidencia debe almacenar:

- ID;
- inspección;
- área;
- observación;
- usuario;
- fecha/hora;
- orden;
- archivo original;
- versión optimizada;
- hash/checksum cuando corresponda.

---

# 18. Equipamiento inicial

No comprar equipos innecesarios.

## Kit inicial

- Tablet.
- Smartphone de respaldo.
- Wincha profesional.
- Nivel de burbuja.
- Multímetro.
- Probador de tomacorrientes.
- Detector de tensión.
- Medidor de humedad.
- Linterna.
- Espejo telescópico.
- EPP básico.

## No comprar inicialmente

- Cámara térmica.
- Distanciómetro láser.
- Nivel láser.
- Esclerómetro.
- Ultrasonido.
- Equipos destructivos.
- Equipos especializados.

La medición de distancias se realizará manualmente inicialmente.

---

# 19. Compra posterior

Solo cuando exista demanda:

```text
30–50 inspecciones
        ↓
Analizar uso real
        ↓
Identificar necesidades
        ↓
Comprar equipo
```

Prioridades futuras:

1. Cámara térmica.
2. Endoscopio.
3. Detector de materiales.
4. Pinza amperimétrica.
5. Nivel láser.
6. Distanciómetro.

---

# 20. Tecnología y Stack Recomendado

## Stack definitivo recomendado

| Capa | Tecnología |
|---|---|
| App inspector | **Flutter** |
| Lenguaje app | **Dart** |
| BD offline | **SQLite** |
| ORM SQLite | **Drift** |
| Web | **Nuxt** |
| UI web | **Vue** |
| Lenguaje web | **TypeScript** |
| Web Pública | **Astro** |
| Backend inicial | **Supabase** |
| BD central | **PostgreSQL** |
| Auth | **Supabase Auth** |
| Archivos | **Supabase Storage** |
| API | **Supabase API / server-side Nuxt cuando corresponda** |
| IA | **Ollama** |
| PDF | **HTML + CSS → PDF** |
| Seguridad BD | **PostgreSQL RLS** |
| Seguridad web | **Nuxt Security + OWASP** |
| Control de versiones | **Git + GitHub** |
| CI/CD | **GitHub Actions** |
| Contenedores | **Docker** |
| Testing | Flutter tests + Vitest/Playwright |
| Documentación | Markdown |

## Decisiones Arquitectónicas Clave

*   **No usar Flutter Web para el portal del cliente:** Flutter es ideal para la app del inspector (Android/iOS), pero para el portal del cliente y la web administrativa, Nuxt + Vue ofrece ventajas en SEO, accesibilidad, navegación y mantenimiento.
*   **Principio central:** **Offline First + Security by Design + Evidence First + Human in the Loop + Multi-tenant desde el inicio.**

---

# 21. Arquitectura general

```text
                          ┌─────────────────┐
                          │    TABLET       │
                          │    FLUTTER      │
                          └────────┬────────┘
                                   │
                             OFFLINE FIRST
                                   │
                                   ▼
                          ┌─────────────────┐
                          │     SQLITE      │
                          │ LOCAL STORAGE   │
                          └────────┬────────┘
                                   │
                               INTERNET
                                   │
                                   ▼
                          ┌─────────────────┐
                          │    SUPABASE     │
        ├── app/
        ├── components/
        ├── modules/
        └── tests/
                          │ PostgreSQL      │
                          │ Auth            │
                          │ Storage         │
                          └────────┬────────┘
                                   │
                     ┌─────────────┼─────────────┐
                     │             │             │
                     ▼             ▼             ▼
WEB         CLIENTE          AI
                  Nuxt/Vue       Portal         Service
                                   │             │
                                   │          Ollama
                                   │             │
                                   └──────┬──────┘
                                          ▼
                                       REPORT
                                          │
                                          ▼
                                         PDF
```

---

# 22. Arquitectura multiempresa

Desde el inicio:

```text
organizations
```

Cada organización tendrá:

```text
organization_id
```

Ejemplo:

```text
EMPRESA A
│
├── usuarios
├── proyectos
├── clientes
├── inspecciones
└── informes

EMPRESA B
│
├── usuarios
├── proyectos
├── clientes
├── inspecciones
└── informes
```

Los datos nunca deben mezclarse.

---

# 23. Modelo de datos inicial

Entidades:

```text
organizations
users
roles
projects
buildings
floors
properties
clients
inspections
inspection_areas
inspection_items
defects
observations
evidence
measurements
actions
reinspections
reports
report_templates
documents
ai_tasks
ai_results
equipment
audit_logs
subscriptions
```

---

# 24. Seguridad

La seguridad se diseñará desde el comienzo.

## Autenticación

- sesiones seguras;
- recuperación de contraseña;
- expiración de sesiones;
- MFA futuro.

## Autorización

Roles:

```text
OWNER
ADMIN
INSPECTOR
REVIEWER
CLIENT
```

## Row Level Security (RLS) Obligatorio

El backend debe comprobar que el usuario tiene autorización para acceder al recurso. No depender solamente de la interfaz. PostgreSQL tiene RLS de forma nativa. Cuando RLS está activado sin una política que permita una operación, se aplica un comportamiento de denegación por defecto. Supabase recomienda probar explícitamente las políticas de `SELECT`, `INSERT`, `UPDATE` y `DELETE`.

**Nota Importante sobre RLS en PostgreSQL:** PostgreSQL ha tenido vulnerabilidades de RLS recientemente corregidas en sus ramas soportadas. En producción, debemos fijar una **versión soportada y con sus últimos parches de seguridad**. Por ejemplo, el aviso de agosto de 2026 corrigió un problema de caché de políticas RLS en varias ramas.

**Regla muy importante:** Nunca pondremos la `SERVICE_ROLE_KEY` (o cualquier clave administrativa que pueda saltarse RLS) dentro de Flutter, Nuxt frontend, ni JavaScript del navegador. Las claves administrativas deben permanecer exclusivamente en backend/servidores, tal como Supabase lo especifica expresamente. El cliente utilizará solamente la clave pública/publishable correspondiente y autenticación.

---

# 25. Protección de fotografías y documentos

No almacenaremos las fotos directamente como grandes blobs dentro de PostgreSQL.

Usaremos:

```text
Supabase Storage
       │
       ├── evidence/
       ├── plans/
       ├── reports/
       └── documents/
```

Pero también tendrán políticas de acceso.

Por ejemplo:

```text
organizations/
   org_001/
      inspecciones/
         inspection_001/
            evidence/
               photo_001.jpg
               photo_002.jpg
```

Y el usuario **no podrá simplemente modificar una URL para obtener otra fotografía**.

El acceso deberá estar autorizado por:

```text
Auth
 +
RLS / Storage Policies
 +
organization_id
 +
inspection permissions
```

---

# 26. Protección de la aplicación y web

Implementar progresivamente:

- HTTPS;
- CSP;
- secure headers;
- protección XSS;
- validación de inputs;
- queries parametrizadas;
- protección CSRF cuando corresponda;
- rate limiting;
- límites de tamaño;
- validación de MIME;
- protección de secretos;
- actualización de dependencias;
- backups;
- logs;
- auditoría;
- monitoreo.

Nunca guardar:

```text
API_KEYS
PASSWORDS
SECRET_KEYS
```

dentro del código de la aplicación.

---

# 27. Auditoría

Registrar:

```text
usuario
acción
fecha/hora
recurso
cambio realizado
```

Ejemplo:

```text
Inspector 023

OBS-045

MEDIA → ALTA

2026-10-07 15:20
```

Esto es importante tanto para seguridad como para trazabilidad profesional.

---

# 28. IA

La IA será asistente.

Flujo:

```text
EVIDENCIA
    ↓
IA
    ↓
PROPUESTA
    ↓
INSPECTOR
    ↓
VALIDACIÓN
    ↓
INFORME
```

---

# 29. Funciones iniciales de IA

## Redacción

Entrada:

> "fisura muro sala cerca ventana"

Salida:

> Se observa una fisura localizada en el muro próximo al vano de ventana.

---

## Clasificación

```text
ACABADOS
SANITARIO
ELÉCTRICO
CARPINTERÍA
VIDRIOS
HUMEDAD
DIMENSIONAMIENTO
FUNCIONALIDAD
EQUIPAMIENTO
OTROS
```

---

## Severidad

```text
BAJA
MEDIA
ALTA
CRÍTICA
```

Siempre como sugerencia.

---

## Recomendación

La IA genera una recomendación preliminar.

El inspector puede:

```text
ACEPTAR
EDITAR
RECHAZAR
```

---

# 30. IA de fotografías

La IA podrá analizar fotografías como apoyo.

Ejemplo:

```text
FOTOGRAFÍA
    ↓
MODELO DE VISIÓN
    ↓
POSIBLE DEFECTO
    ↓
DESCRIPCIÓN SUGERIDA
    ↓
REVISIÓN HUMANA
```

No se utilizará para emitir automáticamente diagnósticos estructurales.

---

# 31. Generación automática del informe

Flujo:

```text
INSPECCIÓN
    ↓
DATOS
    ↓
FOTOGRAFÍAS
    ↓
OBSERVACIONES
    ↓
IA
    ↓
REVISIÓN
    ↓
PLANTILLA
    ↓
PDF
```

---

# 32. Estructura del informe

1. Portada.
2. Datos del proyecto.
3. Datos del inmueble.
4. Cliente.
5. Inspector.
6. Fecha.
7. Alcance.
8. Metodología.
9. Limitaciones.
10. Resumen.
11. Plano.
12. Áreas.
13. Checklist.
14. Observaciones.
15. Fotografías.
16. Recomendaciones.
17. Estado de correcciones.
18. Reinspecciones.
19. Conclusiones.
20. Anexos.

---

# 33. Portal cliente

El cliente podrá consultar:

```text
RESUMEN
PLANO
OBSERVACIONES
FOTOGRAFÍAS
CORRECCIONES
REINSPECCIONES
DOCUMENTOS
INFORME PDF
```

---

# 34. Seguimiento de postventa

Cada observación tendrá ciclo:

```text
DETECTADA
    ↓
PENDIENTE
    ↓
CORREGIDA
    ↓
REINSPECCIONADA
    ↓
VERIFICADA
```

Esto permitirá vender posteriormente:

> Gestión de postventa y cierre de observaciones.

---

# 35. Contract-to-Delivery Audit

Módulo futuro.

El cliente podrá cargar:

- contrato;
- planos;
- especificaciones;
- memoria;
- ficha de acabados;
- documentos.

La plataforma comparará:

```text
CONTRATADO
     ↓
ENTREGADO
     ↓
COMPARACIÓN
```

Ejemplo:

```text
REQUERIDO:
Porcelanato 60x60

ENTREGADO:
Porcelanato 60x60

RESULTADO:
CONFORME
```

O:

```text
REQUERIDO:
Cuarzo

ENTREGADO:
Granito

RESULTADO:
REVISAR
```

---

# 36. DQI — Department Quality Index

Futuro indicador interno.

Categorías:

```text
Acabados
Sanitario
Eléctrico
Carpintería
Vidrios
Humedad
Dimensiones
Funcionalidad
Documentación
```

Debe aclararse que:

> DQI es un indicador interno de la plataforma y no constituye una certificación normativa.

---

# 37. Base de datos como activo estratégico

Cada inspección generará datos estructurados:

```text
Proyecto
Inmueble
Área
Elemento
Defecto
Categoría
Severidad
Fotografía
Medición
Recomendación
Corrección
Tiempo de cierre
Reinspección
Resultado
```

Esto permitirá construir posteriormente:

> **Construction Defect Intelligence**

---

# 38. Analítica futura

Después de suficiente volumen:

```text
DATABASE
    ↓
DATA MODEL
    ↓
ANALYTICS
```

KPIs:

- observaciones por inspección;
- observaciones por ambiente;
- observaciones por categoría;
- defectos recurrentes;
- tiempo de cierre;
- reincidencia;
- porcentaje verificado;
- severidad;
- defectos por proyecto.

---

# 39. Machine Learning futuro

No implementar ML durante el MVP.

Primero:

```text
DATOS
 ↓
CALIDAD
 ↓
NORMALIZACIÓN
 ↓
DATASET
 ↓
ML
```

Posibles modelos:

### Predicción de defectos

```text
Proyecto
+
materiales
+
ambiente
+
histórico
      ↓
P(defecto)
```

### Predicción de severidad

```text
Defecto
+
contexto
      ↓
Severidad probable
```

### Tiempo de corrección

```text
Defecto
+
histórico
      ↓
Tiempo estimado
```

### Priorización

El sistema podrá recomendar qué elementos deberían recibir mayor atención durante una inspección.

---

# 40. Equipamiento vs tecnología

La estrategia es:

```text
CAPITAL
 ↓
INSPECCIÓN
 ↓
DATOS
 ↓
PLATAFORMA
 ↓
IA
 ↓
ANALYTICS
```

No:

```text
COMPRAR EQUIPOS CAROS
 ↓
esperar clientes
```

---

# 41. Servicios y Planes Comerciales

Los planes comerciales (`planes.md`) permiten al cliente elegir el nivel de profundidad de la inspección según sus necesidades, presupuesto y nivel de acompañamiento requerido. Estos planes se estructuran en tres niveles principales:

*   **Plan Esencial — Verificación:** Enfocado en la detección de problemas visibles y funcionales. Incluye revisión de ambientes, acabados, puertas y ventanas, instalaciones básicas, y un informe digital en PDF.
*   **Plan Integral — Inspección Técnica completa:** El plan recomendado, que añade mediciones, pruebas funcionales ampliadas, revisión técnica detallada, clasificación técnica de observaciones, ubicación de observaciones en plano interactivo y acceso al portal del cliente.
*   **Plan Protección — Inspección + Seguimiento:** La solución más completa, que incluye todo lo del Plan Integral más seguimiento de observaciones con estados de corrección, evidencia antes/después, una segunda visita de verificación y un informe final de cierre.

Para una descripción detallada de cada plan, precios referenciales y servicios adicionales, consultar el documento `planes.md`.

---

# 42. Estrategia comercial

No competir únicamente como:

> "Checklist barato."

Posicionamiento:

> **Ingeniería + Tecnología + Evidencia**

Concepto:

> **Inspecciona. Documenta. Verifica. Protege.**

---

# 43. Marketing inicial

No invertir inicialmente en:

- agencia;
- publicidad masiva;
- oficina;
- influencers;
- CRM caro.

Priorizar:

### Contenido

TikTok / Instagram:

- defectos frecuentes;
- errores al recibir departamento;
- casos reales;
- fotografías antes/después;
- recomendaciones.

### SEO

Landing pages:

```text
inspección de departamentos
inspección de departamento nuevo
entrega de departamento
inspección de acabados
inspección técnica
```

### Alianzas

- arquitectos;
- ingenieros;
- abogados;
- agentes inmobiliarios;
- corredores;
- administradores;
- postventa.

### WhatsApp

Utilizarlo inicialmente como canal comercial.

---

# 44. Estructura del Repositorio

La estructura del repositorio recomendada es la siguiente:

```text
inspection-platform/
│
├── apps/
│   │
│   ├── inspector/  (Aplicación Flutter para inspectores)
│   │   ├── lib/
│   │   ├── test/
│   │   └── android/
│   │
│   └── web/        (Aplicación Nuxt/Vue para administración y portal del cliente)
│       
│       
│       
│       
│
├── backend/        (Configuración de Supabase y funciones de backend)
│   │
│   ├── database/
│   ├── migrations/
│   ├── functions/
│   └── policies/
│
├── packages/       (Código compartido y modelos de dominio)
│   ├── domain/
│   ├── schemas/
│   └── shared/
│
├── ai/             (Configuración y scripts para integración de IA)
│   ├── providers/
│   ├── prompts/
│   └── report_generation/
│
├── reports/        (Plantillas y assets para la generación de informes PDF)
│   ├── templates/
│   └── css/
│
├── docs/           (Documentación del proyecto)
│   ├── PROJECT_CHARTER.md
│   ├── PRODUCT_REQUIREMENTS.md
│   ├── ARCHITECTURE.md       (Este documento)
│   ├── DATABASE.md
│   ├── OFFLINE_SYNC.md
│   ├── SECURITY.md
│   ├── DEPLOYMENT.md
│   ├── MARKETING.md
│   ├── ROADMAP.md
│   └── THIRD_PARTY_LICENSES.md
│
├── tests/          (Tests de integración y E2E)
│
├── scripts/        (Scripts de utilidad para el proyecto)
│
├── .env.example
├── docker-compose.yml
└── README.md
```
---

# 45. Fases del proyecto

## FASE 0 — Charter y arquitectura

Objetivo:

- definir producto;
- modelo de datos;
- arquitectura;
- UX;
- seguridad;
- checklist;
- estrategia offline;
- estrategia IA.

**No comprar infraestructura avanzada.**

---

## FASE 1 — MVP operativo

```text
Tablet
 ↓
Login
 ↓
Proyecto
 ↓
Inmueble
 ↓
Plano
 ↓
Áreas
 ↓
Checklist
 ↓
Fotos
 ↓
Observaciones
 ↓
Offline
 ↓
Sync
 ↓
PDF
```

Objetivo:

> realizar una inspección real de principio a fin.

---

## FASE 2 — Portal cliente

Agregar:

- dashboard;
- plano interactivo;
- observaciones;
- fotografías;
- informe;
- descarga.

---

## FASE 3 — IA

Agregar:

- redacción;
- clasificación;
- recomendaciones;
- resumen;
- análisis fotográfico asistido.

---

## FASE 4 — Postventa

Agregar:

- responsables;
- fechas;
- correcciones;
- reinspecciones;
- antes/después;
- cierre.

---

## FASE 5 — Contract-to-Delivery

Agregar:

- documentos;
- especificaciones;
- planos;
- comparación;
- discrepancias.

---

## FASE 6 — SaaS

Agregar:

- multiempresa completo;
- planes;
- límites;
- suscripciones;
- branding;
- administración de organizaciones.

---

## FASE 7 — Analytics

Agregar:

- data warehouse;
- KPIs;
- dashboards;
- benchmarking;
- defect intelligence.

---

## FASE 8 — Machine Learning

Agregar cuando exista suficiente dataset:

- predicción de defectos;
- severidad;
- tiempos;
- priorización;
- recomendaciones.

---

# 46. Presupuesto inicial

## Software

Objetivo:

La infraestructura gratuita debe utilizarse mientras sea suficiente para validar el producto.

```text
Flutter             S/0
Next.js             S/0
Supabase            S/0 inicial
PostgreSQL          S/0 inicial
Ollama              S/0
Git                 S/0
Docker              S/0
PDF                 S/0
```
---

# 47. Equipamiento

Comprar únicamente el kit necesario.

No comprar inicialmente:

```text
cámara térmica
distanciómetro
esclerómetro
ultrasonido
equipos especializados
```

La compra de equipos debe responder a:

```text
DEMANDA
+
FRECUENCIA DE USO
+
VALOR GENERADO
+
RETORNO DE INVERSIÓN
```

---

# 48. Validación comercial

Primero realizar:

> **20–30 inspecciones reales.**

Medir:

- tiempo;
- precio;
- cantidad de observaciones;
- tipo de defectos;
- utilidad del checklist;
- utilidad del informe;
- interés del cliente;
- necesidad de reinspección;
- necesidad de IA;
- equipos realmente utilizados.

Después decidir inversiones.

---

# 49. Modelo SaaS futuro

## FREE / TRIAL

- pocas inspecciones;
- proyecto limitado.

## PRO

- inspecciones;
- PDF;
- fotografías;
- portal.

## BUSINESS

- múltiples inspectores;
- proyectos;
- dashboard;
- branding.

## ENTERPRISE

- API;
- SSO;
- integraciones;
- administración avanzada;
- soporte empresarial.

El sistema de billing se implementará **solo cuando exista demanda real**.

---

# 50. Métricas

## Operación

- inspecciones/mes;
- tiempo/inspección;
- observaciones/inspección;
- fotografías/inspección;
- tiempo de informe.

## Negocio

- leads;
- conversión;
- ticket promedio;
- margen;
- reinspecciones;
- recompra.

## Producto

- errores de sincronización;
- tiempo de sincronización;
- uso del portal;
- descargas;
- uso de IA.

## SaaS

- usuarios activos;
- organizaciones;
- MRR;
- churn;
- inspecciones/organización;
- costo por inspección.

---

# 51. Criterios de éxito del MVP

El MVP será considerado funcional cuando pueda:

1. Crear una inspección.
2. Descargarla en tablet.
3. Trabajar completamente offline.
4. Abrir el plano.
5. Crear áreas.
6. Identificar correctamente cada ambiente.
7. Ejecutar checklist.
8. Tomar fotografías.
9. Registrar observaciones.
10. Guardar datos localmente.
11. Cerrar y volver a abrir la aplicación sin perder información.
12. Sincronizar al recuperar Internet.
13. Subir fotografías.
14. Generar PDF.
15. Mostrar el informe al cliente.
16. Mostrar plano interactivo.
17. Permitir seleccionar un área.
18. Mostrar observaciones del área.
19. Mostrar fotografías.
20. Permitir descargar el informe.
21. Aislar los datos por organización.
22. Registrar acciones relevantes.
23. Funcionar sin IA de pago.
24. Permitir posteriormente conectar diferentes proveedores de IA.
25. Mantener trazabilidad de evidencia.

---

# 52. Principios técnicos

## 52.1 Offline First

La falta de Internet no debe impedir inspeccionar.

## 52.2 Evidence First

La evidencia original tiene prioridad sobre la IA.

## 52.3 Human in the Loop

La IA propone; el profesional decide.

## 52.4 Security by Design

La seguridad comienza en la arquitectura.

## 52.5 Multi-tenant by Design

La plataforma debe poder convertirse en SaaS.

## 52.6 Low Cost First

No pagar por infraestructura antes de necesitarla.

## 52.7 Modular AI

Cambiar de modelo sin reconstruir la aplicación.

## 52.8 Data as an Asset

Los datos estructurados son un activo estratégico.

## 52.9 No Overengineering

Construir únicamente lo necesario.

## 52.10 Service First, SaaS Second

Primero utilizar la plataforma en el propio negocio; después venderla como software.

---

# 53. Evolución del producto

La evolución prevista es:

```text
                     FASE 1
              SERVICIO DE INSPECCIÓN
                       │
                       ▼
               PLATAFORMA INTERNA
                       │
                       ▼
                     IA
                       │
                       ▼
                  POSTVENTA
                       │
                       ▼
                    SaaS
                       │
                       ▼
                  ANALYTICS
                       │
                       ▼
                DEFECT INTELLIGENCE
                       │
                       ▼
                       ML / PREDICCIÓN
```

---

# 54. Producto final conceptual

El proyecto no debe considerarse simplemente:

> "una aplicación para inspectores".

Es una plataforma completa:

```text
                         INSPECTION PLATFORM
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
          ▼                       ▼                       ▼
      INSPECTOR               EMPRESA                 CLIENTE
       TABLET                   WEB                     WEB
          │                       │                       │
          └───────────────────────┼───────────────────────┘
                                  │
                            DATA PLATFORM
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
                    ▼             ▼             ▼
                   IA          REPORTS       STORAGE
                    │             │
                    └──────┬──────┘
                           ▼
                       ANALYTICS
                           │
                           ▼
                          ML
```

---

# 55. Decisión estratégica final

La plataforma debe permitir que la empresa tenga **dos activos independientes pero conectados**:

### Activo 1 — Negocio de inspecciones

Genera ingresos mediante:

- inspecciones;
- informes;
- reinspecciones;
- postventa;
- servicios especializados.

### Activo 2 — Software

Puede generar ingresos mediante:

- SaaS;
- suscripciones;
- licencias;
- cuentas empresariales;
- personalización;
- integraciones.

Por lo tanto:

> **Si el negocio de inspecciones crece, la plataforma lo hace más eficiente. Si el negocio de inspecciones no alcanza la escala esperada, la plataforma puede convertirse en un producto independiente para terceros.**

Esta es la razón principal para construir desde el comienzo una arquitectura **multiempresa, offline-first, segura, modular y orientada a datos**, pero mantener el MVP pequeño y de bajo costo.

---

# 56. Primera prioridad de desarrollo

El orden concreto recomendado es:

```text
1. PROJECT_CHARTER.md
             ↓
2. PRODUCT_REQUIREMENTS.md
             ↓
3. ARCHITECTURE.md
             ↓
4. DATABASE.md
             ↓
5. OFFLINE_SYNC.md
             ↓
6. SECURITY.md
             ↓
7. Diseño UX/UI
             ↓
8. Flutter MVP
             ↓
9. Backend
             ↓
10. Sincronización
             ↓
11. Fotografías
             ↓
12. PDF
             ↓
13. Portal cliente
             ↓
14. IA
             ↓
15. Postventa
             ↓
16. SaaS
             ↓
17. Analytics
             ↓
18. ML
```

**No empezaría por la IA, el Machine Learning, la cámara térmica ni el SaaS.** Primero hay que conseguir que una persona pueda tomar una tablet, entrar a un departamento sin Internet, inspeccionarlo completamente, tomar evidencia, volver a conectarse, sincronizar todo y entregar al cliente un informe profesional con el plano y las observaciones correctamente ubicadas.

Ese flujo constituye el **núcleo del producto**. Todo lo demás debe construirse alrededor de él.

Antes de que el app y la web se desplieguen no usar supabese u otros externos que se usan en despliegue final, pruebas inciales en desktop.

## Appointment Request & Scheduling

### 1. Objective

The platform shall provide a simple internal appointment scheduling mechanism for inspection services.

The MVP shall NOT integrate with Google Calendar, Outlook Calendar, Apple Calendar, payment gateways, or external booking platforms.

The purpose of the module is to allow a client to:

1. Select an inspection service.
2. Propose a preferred date.
3. Propose a preferred time.
4. Enter the property and contact information.
5. Submit an appointment request.
6. See whether the requested time is available.
7. Receive the current appointment status.

The company administrator shall be able to review, confirm, reschedule, cancel, and mark appointments as paid.

---

### 2. Core Concept

The scheduling system is based on **appointment requests**, not external calendar synchronization.

The platform itself is the source of truth for appointment availability.

```text
Client
   │
   │ proposes date/time
   ▼
Appointment Request
   │
   ├── AVAILABLE
   │
   ├── PENDING
   │
   ├── CONFIRMED
   │
   ├── PAID
   │
   ├── CANCELLED
   │
   └── COMPLETED
```

The platform must not depend on an external calendar provider.

---

### 3. Appointment vs Inspection

An appointment and an inspection are separate domain entities.

```text
Appointment
     │
     │ confirmed
     ▼
Inspection
```

An appointment may exist before an inspection is created.

Example:

```text
APT-00125
15/10/2026
10:00–12:00
Plan Integral
Status: CONFIRMED
Payment: PENDING
```

After confirmation:

```text
APT-00125
      │
      ▼
INS-00125
```

This separation allows the business to manage requests, cancellations, payments, and rescheduling without corrupting inspection records.

---

### 4. Appointment Status

Appointment status shall be independent from payment status.

#### Appointment status

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

#### Payment status

The MVP does not process payments online.

The system shall only record the payment state.

```text
UNPAID
PAYMENT_PENDING
PAID
REFUNDED
NOT_REQUIRED
```

Payment status is manually managed by an authorized administrator.

The system must never interpret `CONFIRMED` as equivalent to `PAID`.

---

### 5. Availability Logic

The platform shall determine availability using its own appointment database.

A requested time is considered unavailable when another active appointment overlaps the requested time.

Example:

```text
Existing appointment:

10:00 ───────── 12:00
          OCCUPIED
```

A client requesting:

```text
11:00 ───── 13:00
```

must receive:

```text
NOT AVAILABLE
```

A request for:

```text
14:00 ───── 16:00
```

may be accepted if no conflicting appointment exists.

The system shall check overlapping intervals rather than only comparing exact start times.

---

### 6. Appointment Lifecycle

The recommended MVP lifecycle is:

```text
CLIENT
   │
   │ submits proposed date/time
   ▼
REQUESTED
   │
   ├── unavailable → RESCHEDULE_REQUESTED
   │
   └── available
          │
          ▼
   PENDING_CONFIRMATION
          │
          ▼
      CONFIRMED
          │
          ├── payment pending
          │
          ▼
         PAID
          │
          ▼
      INSPECTION
          │
          ▼
      COMPLETED
```

The client does not directly block a definitive appointment slot merely by submitting a request.

The system may temporarily mark a request as `PENDING_CONFIRMATION`, but the definitive slot reservation occurs only when an administrator confirms the appointment.

---

### 7. Payment and Slot Reservation

Because the MVP does not include an online payment gateway, payment shall be recorded manually.

Recommended business rule:

```text
REQUESTED
    ↓
PENDING_CONFIRMATION
    ↓
CONFIRMED
    ↓
PAID
```

The appointment may remain `CONFIRMED` while payment is pending, depending on the company's business policy.

However, the system shall support a configuration such as:

```text
payment_required_before_confirmation = true
```

If enabled:

```text
REQUESTED
    ↓
PENDING_CONFIRMATION
    ↓
PAYMENT_PENDING
    ↓
PAID
    ↓
CONFIRMED
```

This configuration must not require an online payment integration.

---

### 8. Client Experience

The public booking interface shall remain intentionally simple.

Example:

```text
SOLICITA TU INSPECCIÓN

Servicio:
[ Inspección Integral ▼ ]

Fecha propuesta:
[ 15/10/2026 ]

Hora propuesta:
[ 10:00 ]

Duración estimada:
[ 2 horas ]

Nombre:
[________________]

Teléfono:
[________________]

Correo:
[________________]

Dirección / Proyecto:
[________________]

Departamento:
[________________]

[ VERIFICAR DISPONIBILIDAD ]

Available:
✓ Este horario está disponible

[ SOLICITAR CITA ]
```

If unavailable:

```text
Este horario no está disponible.

Horarios cercanos:
09:00–11:00
14:00–16:00
16:00–18:00

[ ELEGIR OTRO HORARIO ]
```

The system should not expose private information about another client's appointment.

Do not display:

```text
10:00 - 12:00 → Juan Pérez → PAID
```

Instead display:

```text
10:00 - 12:00 → NO DISPONIBLE
```

---

### 9. Appointment Data Model

The initial appointment entity shall contain:

```text
appointments

id
organization_id

client_id
property_id
service_type_id
inspector_id

requested_date
requested_start_time
requested_end_time

confirmed_date
confirmed_start_time
confirmed_end_time

status
payment_status

client_notes
admin_notes

inspection_id

created_at
updated_at
confirmed_at
cancelled_at
completed_at
```

The distinction between `requested_*` and `confirmed_*` is intentional.

A client may request:

```text
15/10/2026 10:00
```

while the administrator confirms:

```text
15/10/2026 14:00
```

without losing the original request.

---

### 10. Service Types

Inspection services shall be configurable.

Example:

```text
service_types

id
organization_id
name
description
duration_minutes
price
active
requires_payment
```

Example records:

```text
ESENCIAL
duration: 90 min
price: S/ 349

INTEGRAL
duration: 120 min
price: S/ 549

PROTECCIÓN
duration: 180 min
price: S/ 799
```

The price is stored as service information only.

No online payment processing is required in the MVP.

---

### 11. Availability Rules

The MVP shall support basic company/inspector availability.

Example:

```text
availability_rules

id
organization_id
inspector_id
day_of_week
start_time
end_time
active
```

Example:

```text
Monday    09:00–17:00
Tuesday   09:00–17:00
Wednesday 09:00–17:00
Thursday  09:00–17:00
Friday    09:00–17:00
```

Future versions may support holidays, vacations, blocked periods, multiple inspectors, and geographic travel time.

These features are not required for MVP.

---

### 12. Conflict Prevention

The backend shall perform the final availability check.

The frontend availability check is informational only.

The server must re-check availability immediately before confirming an appointment.

This prevents two clients from booking the same time simultaneously.

Conceptually:

```text
Client A                    Client B
   │                           │
   │ request 10:00             │
   │                           │ request 10:00
   ▼                           ▼
        Backend
           │
           ├── Check availability
           │
           ├── Confirm A
           │
           └── Reject B
```

The database transaction must prevent double booking.

---

### 13. Recommended MVP Rule

For simplicity, the MVP shall use the following rule:

> A time slot is considered occupied when there is an active confirmed appointment whose time interval overlaps the requested interval.

Cancelled appointments do not block availability.

Completed appointments remain historical records but do not block future availability.

Pending requests should not permanently block the schedule.

A temporary hold mechanism may be implemented later if required.

---

### 14. Administrator Interface

The administrator shall have an internal agenda view.

The MVP does not require a sophisticated calendar integration.

A simple list/table view is sufficient:

```text
DATE        TIME       CLIENT       SERVICE       STATUS       PAYMENT

15/10/26    10:00      Client A     Integral      CONFIRMED    PAID
15/10/26    14:00      Client B     Esencial      CONFIRMED    PENDING
16/10/26    09:00      Client C     Integral      REQUESTED    UNPAID
```

The administrator shall be able to:

- approve request;
- change date/time;
- assign inspector;
- mark payment as paid;
- cancel appointment;
- create appointment manually;
- convert appointment into inspection;
- view appointment history.

---

### 15. Client Portal

The client shall be able to see:

```text
My Appointments

15 Oct 2026
10:00–12:00

Inspección Integral

Status:
CONFIRMED

Payment:
PAID
```

For unpaid appointments:

```text
Payment:
PENDING
```

The client must not see internal administrative notes or other clients' information.

---

### 16. Security

Appointment data is tenant-scoped.

Every appointment shall contain:

```text
organization_id
```

Row Level Security shall ensure that:

- clients can only access their own appointments;
- inspectors can access appointments assigned to them;
- administrators can access appointments belonging to their organization;
- one organization cannot access another organization's appointments.

The public booking form must not expose internal appointment IDs, client information, payment details, or administrative information.

---

### 17. Notifications

Notifications are intentionally minimal in MVP.

The system may initially provide:

- confirmation page;
- client portal status;
- administrator notification.

Email, WhatsApp, SMS and push notifications are optional future features.

The appointment workflow must work without them.

---

### 18. Offline Considerations

Scheduling is primarily an online operation because appointment availability must be consistent across clients.

The inspector mobile application may cache confirmed appointments locally for offline viewing.

Example:

```text
SERVER
   │
   │ sync
   ▼
SQLite
   │
   ▼
Inspector sees today's schedule offline
```

The inspector should not create or confirm public appointments while offline.

Offline inspection execution remains independent:

```text
Appointment
     ↓
Inspection
     ↓
Offline inspection
     ↓
SQLite
     ↓
Sync
```

---

### 19. Future Extensions

The architecture should allow future implementation of:

- online payments;
- WhatsApp notifications;
- email confirmations;
- SMS;
- Google Calendar integration;
- Outlook integration;
- automatic reminders;
- temporary booking holds;
- multiple inspectors;
- travel-time calculation;
- geographic assignment;
- recurring availability;
- holidays and blocked dates;
- automatic inspector assignment.

These features are explicitly outside the MVP.

---

### 20. MVP Principle

The scheduling module follows the same principle as the rest of the platform:

> **Simple first, reliable first, extensible later.**

The MVP does not attempt to become a calendar application.

It provides only the functionality necessary for the inspection business:

```text
REQUEST
   ↓
CHECK AVAILABILITY
   ↓
CONFIRM
   ↓
RECORD PAYMENT
   ↓
CREATE INSPECTION
   ↓
PERFORM INSPECTION
   ↓
GENERATE REPORT
```

The platform itself is the source of truth for inspection availability.