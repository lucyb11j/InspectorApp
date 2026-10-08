# 🗄️ Framework y Decisiones Técnicas Clave

Este documento detalla las decisiones técnicas clave, justificaciones y consideraciones específicas para cada componente del stack, complementando la visión arquitectónica general definida en `ARCHITECTURE.md`.

---

### 📱 App del inspector

**Framework: Flutter + Dart**

Será la aplicación que utilizará el inspector en tablet/celular.

**Por qué Flutter:**

- Android e iOS desde una misma base de código.
- Muy adecuado para interfaces de inspección.
- Buen soporte para cámara, archivos, almacenamiento y funcionamiento offline.
- El equipo de Flutter mantiene una política activa de seguridad y recomienda mantener SDK y dependencias actualizadas.

---

### 🌐 Web

**Framework: Nuxt + Vue + TypeScript**

La web tendrá dos grandes partes:

```text
WEB
│
├── Público
│   ├── Inicio
│   ├── Servicios
│   ├── Planes
│   ├── Nosotros
│   └── Contacto
│
└── Plataforma
    ├── /admin
    └── /cliente
```

Nuxt continúa activo en 2026; la versión 4.6 fue publicada el **5 de octubre de 2026**, y el proyecto continúa publicando parches de seguridad.

---

# 🗄️ Backend

Aquí mantendría:

**Supabase + PostgreSQL**

```text
                  ┌───────────────┐
                  │    Nuxt Web   │
                  └───────┬───────┘
                          │
                          │
                  ┌───────▼───────┐
                  │    Supabase   │
                  │               │
                  │ Auth          │
                  │ API           │
                  │ Storage       │
                  │ PostgreSQL    │
                  └───────────────┘
```

Supabase nos da:

- autenticación
- PostgreSQL
- API
- almacenamiento de fotografías
- gestión de usuarios
- políticas RLS
- funciones server-side cuando sean necesarias

Pero **no debemos confiar simplemente en que Supabase sea seguro por defecto**.

La seguridad la diseñaremos nosotros.

Supabase recomienda utilizar **Row Level Security (RLS)** para controlar qué filas puede consultar o modificar cada usuario.

---

# 🔐 Seguridad: requisito fundamental

Para tu plataforma hay un riesgo especialmente importante:

> **Un cliente nunca debe poder acceder a las inspecciones, fotografías o documentos de otro cliente.**

Por eso desde la base de datos tendremos:

```text
organization
      │
      ├── users
      │
      ├── projects
      │
      ├── properties
      │
      ├── inspections
      │
      ├── observations
      │
      ├── evidence
      │
      └── reports
```

Y prácticamente todas las entidades importantes tendrán:

```text
organization_id
```

Ejemplo:

```text
inspection
───────────────
id
organization_id
property_id
inspector_id
client_id
status
created_at
```

Así podremos implementar arquitectura **multi-tenant** desde el principio.

---

# 🔒 RLS obligatorio

Por ejemplo, conceptualmente:

```text
Cliente A
   ↓
solo puede ver
   ↓
sus propiedades
   ↓
sus inspecciones
   ↓
sus fotografías
   ↓
sus reportes
```

Mientras:

```text
Cliente B
   ↓
NO puede acceder
   ↓
a ninguna información de Cliente A
```

PostgreSQL tiene Row-Level Security de forma nativa, y cuando RLS está activado sin una política que permita una operación, se aplica un comportamiento de denegación por defecto.

Además, Supabase recomienda probar explícitamente las políticas de `SELECT`, `INSERT`, `UPDATE` y `DELETE`.

---

# 🚨 Regla muy importante

Nunca pondremos esto:

```text
SERVICE_ROLE_KEY
```

dentro de:

```text
Flutter
```

ni:

```text
Nuxt frontend
```

ni:

```text
JavaScript del navegador
```

Las claves administrativas que pueden saltarse RLS deben permanecer exclusivamente en backend/servidores. Supabase lo especifica expresamente.

El cliente utilizará solamente la clave pública/publishable correspondiente y autenticación.

---

# 📷 Fotografías y documentos

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

# 📱 Offline First

Esta parte es crítica.

La app Flutter funcionará así:

```text
                   INTERNET
                      │
                      ▼
               ┌─────────────┐
               │  SUPABASE   │
               └──────┬──────┘
                      ▲
                      │ SYNC
                      │
               ┌──────┴──────┐
               │    FLUTTER  │
               │             │
               │   SQLite    │
               │    Drift    │
               └─────────────┘
                      │
                      ▼
                   INSPECTOR
```

Si no hay Internet:

```text
❌ Internet

        ↓

✅ inspeccionar
✅ tomar fotos
✅ registrar observaciones
✅ registrar medidas
✅ marcar defectos
✅ trabajar con plano
✅ guardar todo
```

Cuando vuelve Internet:

```text
Internet
   ↓
Sync Engine
   ↓
sube cambios
   ↓
sube fotografías
   ↓
confirma servidor
   ↓
marca registros como sincronizados
```

---

# 🧠 IA

La IA **no será parte crítica de la inspección**.

Eso es importante.

Primero:

```text
Inspector
   ↓
evidencia
   ↓
datos
   ↓
sincronización
   ↓
reporte
```

Después:

```text
                     IA
                      │
           ┌──────────┼──────────┐
           ▼          ▼          ▼
       clasificar   resumir   sugerir
       observación  reporte    texto
```

Podremos usar:

**Ollama**

en un PC/servidor:

```text
Flutter
   ↓
Supabase
   ↓
Backend
   ↓
Ollama
   ↓
resultado IA
```

Nunca dependeremos de IA para determinar automáticamente algo crítico sin revisión humana.

---

# 🛡️ Seguridad de la aplicación web

En Nuxt agregaría una capa de seguridad basada en OWASP.

Existe incluso el módulo **Nuxt Security**, que proporciona mecanismos para headers de seguridad, CSP, rate limiting, validación XSS, CORS y otras protecciones. Está diseñado para Nuxt 3+ / 4.x y tiene licencia MIT.

La arquitectura sería:

```text
Internet
   │
   ▼
HTTPS
   │
   ▼
Nuxt
   │
   ├── CSP
   ├── Security Headers
   ├── Rate Limiting
   ├── CORS
   ├── Input Validation
   ├── Auth
   └── Authorization
           │
           ▼
        Supabase
           │
           ▼
      PostgreSQL + RLS
```

---

# 🔑 Autenticación

Tendríamos inicialmente:

```text
USUARIO
   │
   ├── email + contraseña
   ├── recuperación de contraseña
   └── sesión segura
```

Más adelante:

```text
Google
Microsoft
MFA / 2FA
```

Para administradores y usuarios con privilegios altos, **MFA debería ser obligatorio** cuando pasemos a producción.

---

## Una decisión adicional importante

**No usaría Flutter Web para el portal del cliente.**

Flutter sí puede desplegar aplicaciones web, pero para tu caso prefiero:

```text
📱 Inspector
       ↓
    Flutter
```

y

```text
💻 Cliente / Administrador
       ↓
    Nuxt + Vue
```

Flutter tiene soporte oficial para web, pero la web pública y el portal administrativo se benefician más de una arquitectura web convencional, especialmente para SEO, accesibilidad, navegación y mantenimiento.

---

### En resumen de Principios

**App:** 🟢 **Flutter + Dart + SQLite/Drift**

**Web:** 🟢 **Nuxt + Vue + TypeScript**

**Backend:** 🟢 **Supabase + PostgreSQL**

**Seguridad:** 🔐 **Auth + RLS + Storage Policies + RBAC + CSP + HTTPS + rate limiting + auditoría**

**IA:** 🧠 **Ollama, desacoplada y nunca crítica para la inspección**

**Principio central:**

> **Offline First + Security by Design + Evidence First + Human in the Loop + Multi-tenant desde el inicio.**

Además, como PostgreSQL ha tenido vulnerabilidades de RLS recientemente corregidas en sus ramas soportadas, no conviene simplemente instalar “PostgreSQL 16” o cualquier versión antigua: en producción debemos fijar una **versión soportada y con sus últimos parches de seguridad**. Por ejemplo, el aviso de agosto de 2026 corrigió un problema de caché de políticas RLS en varias ramas.
