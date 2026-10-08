# UI/UX DESIGN - Plataforma de Inspección Técnica, Evidencia y Postventa

**Versión:** 0.1
**Fecha:** 2026-10-07
**Estado:** Borrador inicial

Este documento describe las directrices generales de interfaz de usuario (UI) y experiencia de usuario (UX) para la aplicación del inspector y los portales web (administrativo y de cliente). Se busca un diseño que facilite la eficiencia en campo para los ingenieros y genere confianza y claridad para los clientes y administradores, tomando como referencia conceptual los flujos de OpenInspection y adaptándolos a nuestra pila tecnológica y planes.

---

## 1. Principios Generales de Diseño

Para asegurar coherencia y eficacia en todas las plataformas:

*   **Claridad y Simplicidad:** Interfaces limpias, con elementos esenciales y una jerarquía visual clara.
*   **Eficiencia:** Minimizar clics y pasos, especialmente para tareas repetitivas.
*   **Confiabilidad:** Usar un estilo visual profesional, colores sobrios y una tipografía legible que inspire seriedad y profesionalismo.
*   **Respuesta Rápida:** Las interfaces deben reaccionar ágilmente a las interacciones del usuario.
*   **Coherencia:** Mantener patrones de interacción, componentes y estilos visuales uniformes.
*   **Accesibilidad:** Considerar tamaños de fuente, contrastes de color y navegación para usuarios diversos.
*   **Mobile-First (Web):** El portal del cliente y la web administrativa deben ser completamente responsivos.
*   **Offline-First (App Inspector):** La UI debe comunicar claramente el estado de conectividad y sincronización.

---

## 2. Paleta de Colores y Tipografía (Sugerencia)

Para transmitir un estilo "limpio, pulcro y que genere confianza":

*   **Colores Primarios:**
    *   Azul marino (`#003366`): Profesionalismo, confianza.
    *   Verde teal o esmeralda (`#008080` o `#00A36C`): Crecimiento, sostenibilidad, modernidad.
*   **Colores Neutros:**
    *   Gris claro (`#F0F0F0`): Fondos, separadores.
    *   Gris medio (`#666666`): Texto secundario, iconos.
    *   Blanco (`#FFFFFF`): Fondos principales, tarjetas.
    *   Negro (`#000000`): Texto principal.
*   **Colores de Estado:**
    *   Rojo (`#CC0000`): Errores, críticas.
    *   Naranja (`#FF8C00`): Advertencias, pendientes.
    *   Verde (`#008000`): Éxito, conforme.
    *   Azul (`#007BFF`): Informativo.
*   **Tipografía:**
    *   **Encabezados:** Una fuente Sans-serif moderna y legible como 'Inter', 'Roboto' o 'Montserrat' (Bold/Semi-bold).
    *   **Cuerpo de Texto:** La misma fuente Sans-serif, pero en versiones Regular/Light para máxima legibilidad.

---

## 3. Aplicación del Inspector (Flutter)

**Objetivo UX:** Máxima eficiencia para la captura de datos en campo, incluso sin conexión. Interfaz robusta y fácil de usar para ingenieros.

### 3.1. Flujos Clave y Wireframes (Descripción Textual)

#### A. Login / Sincronización Inicial
*   **Pantalla:** Campo de email, campo de contraseña, botón "Iniciar Sesión".
*   **UX:** Tras login exitoso, pantalla de "Sincronizando Proyectos" con barra de progreso y lista de elementos descargándose (proyectos, departamentos, plantillas, checklist). Indicador visual claro de estado (online/offline).
*   **Consideración Offline:** Si no hay internet en el login inicial, mensaje claro de que no se puede descargar contenido, pero si ya hay contenido, se permite acceso a la lista de inspecciones locales.

#### B. Lista de Inspecciones
*   **Pantalla:** Título "Mis Inspecciones". Lista de tarjetas de inspecciones (Proyectos/Departamentos).
    *   Cada tarjeta muestra: Nombre del proyecto/departamento, Cliente, Fecha, % de avance, Estado (Pendiente, En Progreso, Cerrada), Icono de estado de sincronización (✅ Sincronizado, 🔄 Pendiente, ⚠️ Conflicto, ❌ Error).
*   **UX:** Botón flotante para "Nueva Inspección". Filtros rápidos (Por Cliente, Por Estado, Pendientes de Sincronizar).
*   **Interacción:** Tap en tarjeta para ir a detalle de inspección. Swipe para acciones rápidas (ej. forzar sincronización, si hay internet).

#### C. Detalle de Inspección / Navegación por Plano
*   **Pantalla Principal (Pestañas):** "Resumen", "Plano", "Checklist", "Observaciones".
    *   **Resumen:** Datos generales del departamento, cliente, inspector.
    *   **Plano (Diferenciador):**
        *   Imagen del plano cargado (PDF/JPG/PNG).
        *   Áreas pre-definidas o creadas por el inspector (ej. "SALA", "COCINA").
        *   Marcadores de Observaciones (pequeños iconos o números) ubicados sobre el plano.
        *   **Interacción:** Zoom y pan. Tap en un área para filtrar el checklist y observaciones por esa área. Tap en un marcador para ver/editar la observación asociada.
    *   **Checklist:** Lista de ítems de inspección organizados por Áreas y Elementos.
        *   Cada ítem: `[Área] [Elemento] [Punto de inspección]`. Botones de estado rápido: `OK`, `OBS`, `N/A`.
        *   Si se selecciona `OBS`, abre rápidamente un modal/pantalla para registrar la observación.
    *   **Observaciones:** Lista detallada de todas las observaciones, con filtros por área, elemento, estado, severidad.

#### D. Creación / Edición de Observación
*   **Pantalla/Modal:**
    *   **Campo "Descripción" (grande, editable, con sugerencias IA):** "Fisura en muro sala" -> IA sugiere "Se observa una fisura localizada en el muro próximo al vano de ventana."
    *   **Campos de selección (Dropdowns/Radio buttons):** Categoría (Acabados, Sanitario), Elemento (Muro, Piso), Severidad (INFO, MENOR, MODERADA, MAYOR, CRÍTICA).
    *   **Sección de Fotografías:** Botón "Tomar Foto", previsualizaciones de fotos tomadas (Miniaturas con botón de eliminar).
        *   **UX Toma de Fotos:** Interfaz de cámara simple, botón grande de captura, opción de usar galería (limitado). Fotos guardadas localmente y asociadas inmediatamente a la observación.
    *   **Campo "Recomendación" (editable, con sugerencias IA).**
    *   **Botón "Ubicar en Plano":** Abre el plano, permite mover un marcador (draggable) y guardar la posición (X,Y normalizadas).
    *   **Botones:** "Guardar" (guarda localmente), "Cancelar".
*   **UX para Ingenieros:** Campos de texto auto-sugeridos por IA, selección rápida con pocos toques, acceso inmediato a la cámara.

#### E. Estado de Sincronización Global
*   **Elemento UI:** Barra de estado persistente (header/footer) o icono en barra de navegación que muestre `ONLINE`, `OFFLINE`, `SINCRONIZANDO...`, `PENDIENTES (X)`.
*   **UX:** Al tocar el icono, se muestra un resumen de elementos pendientes de sincronizar o con conflictos.

---

## 4. Web Administrativa (Nuxt/Vue)

**Objetivo UX:** Gestión centralizada eficiente, claridad en la información y herramientas robustas para administradores. Estilo limpio y profesional.

### 4.1. Flujos Clave y Wireframes (Descripción Textual)

#### A. Login / Dashboard
*   **Pantalla de Login:** Logo de la empresa, campos de email/contraseña, "Olvidé mi contraseña", botón "Iniciar Sesión". Estilo limpio, con un fondo profesional y branding sutil.
*   **Dashboard:** Visión general con tarjetas de KPIs (ej. "Inspecciones en curso", "Observaciones pendientes", "Ingresos del mes"). Gráficos simples (ej. observaciones por categoría, avance de proyectos). Acceso rápido a las secciones principales (Proyectos, Usuarios, Informes).
*   **Navegación:** Barra lateral izquierda con menú (Proyectos, Edificios, Departamentos, Clientes, Inspectores, Plantillas, Reportes, Usuarios, Configuración, Biblioteca de Observaciones).

#### B. Gestión de Proyectos / Edificios / Departamentos
*   **Pantalla (ej. "Proyectos"):**
    *   Tabla con lista de proyectos: Nombre, Cliente, Estado, Cant. Edificios/Departamentos, Acciones (Editar, Ver).
    *   Filtros y buscador arriba de la tabla. Botón "Nuevo Proyecto".
*   **Detalle de Proyecto:** Información general, pestañas para "Edificios", "Departamentos", "Inspecciones".
    *   Cada pestaña contiene una tabla similar a la principal.
*   **Creación/Edición:** Formularios modales o en páginas separadas, con campos claros, validación en tiempo real.

#### C. Gestión de Usuarios
*   **Pantalla:** Tabla con lista de usuarios: Nombre, Email, Rol (OWNER, ADMIN, INSPECTOR, CLIENT), Organización, Estado, Acciones (Editar, Restablecer Contraseña, Desactivar).
*   **Creación/Edición:** Formulario para asignar roles, organizar por empresa (`organization_id`).

#### D. Biblioteca de Observaciones
*   **Pantalla:** Tabla de observaciones predefinidas: Código, Categoría, Área, Elemento, Descripción, Recomendación, Severidad por defecto.
*   **UX:** Botón "Nueva Observación". Edición inline o modal para modificar entradas existentes. Importar/Exportar (CSV).

#### E. Generación de Reportes
*   **Pantalla:** Lista de inspecciones completadas. Botón "Generar Reporte" para cada una.
*   **Modal de Configuración de Reporte:** Opciones para incluir/excluir secciones (ej. fotos, plano), seleccionar plantilla. Botón "Generar PDF".
*   **Lista de Reportes Generados:** Con opción de "Descargar PDF".

---

## 5. Portal del Cliente (Nuxt/Vue)

**Objetivo UX:** Transmitir confianza, transparencia y facilitar el acceso a la información de su propiedad de manera clara y profesional.

### 5.1. Flujos Clave y Wireframes (Descripción Textual)

#### A. Login / Lista de Propiedades
*   **Pantalla de Login:** Similar a la administrativa, pero con branding centrado en el cliente.
*   **Lista de Propiedades:** Tarjetas para cada departamento del cliente (si tiene varios). Muestra: Dirección, Nombre del Proyecto, Fecha de Última Inspección, Estado General (ej. "3 Observaciones Pendientes").
*   **Interacción:** Tap en una tarjeta para ver el detalle de la propiedad.

#### B. Detalle de Propiedad (Central: Plano Interactivo)
*   **Pantalla Principal (Pestañas):** "Resumen", "Plano", "Observaciones", "Reportes", "Postventa" (si el plan lo incluye).
    *   **Resumen:** Datos de la propiedad, resumen ejecutivo de la inspección.
    *   **Plano Interactivo (Diferenciador):**
        *   Imagen del plano.
        *   Marcadores de observaciones visibles.
        *   **Interacción:** Zoom y pan. Al hacer hover/tap en un marcador, muestra un tooltip con la descripción corta de la observación y su estado. Al hacer clic en el marcador o área, se filtra la sección de "Observaciones" para mostrar solo las relevantes.
    *   **Observaciones:** Tabla/Lista con: Código, Descripción, Severidad, Estado (Pendiente, Corregida, Verificada), Responsable, Fecha Límite.
        *   **Interacción:** Tap en una observación para ver su detalle.
    *   **Reportes:** Lista de informes PDF generados, con botón "Descargar".
    *   **Postventa (Plan Protección):** Tabla de acciones de corrección, con estado, responsable, fechas, y evidencia del "antes/después" (si aplica).

#### C. Detalle de Observación (con Evidencia Fotográfica)
*   **Pantalla:**
    *   Título de la observación (ej. "Fisura en muro próximo a ventana").
    *   Descripción detallada.
    *   Categoría, Elemento, Severidad.
    *   **Galería de Fotos:** Miniaturas de todas las fotografías de la observación.
        *   **Interacción:** Tap en miniatura para ver imagen en pantalla completa (visor de imágenes con navegación).
    *   **Ubicación en Plano (Opcional):** Un pequeño mapa del plano con el marcador de la observación resaltado.
    *   **Sección de Seguimiento (si aplica):** Historial de acciones, comentarios, evidencia de corrección.
    *   **Estado de Corrección:** Claramente visible (ej. badge grande "PENDIENTE", "CORREGIDA").

#### D. Visor de Reportes PDF
*   **Funcionalidad:** Un visor de PDF integrado en el navegador para que el cliente pueda ver el informe directamente antes de descargarlo.

---

## 6. Consideraciones de Usabilidad y Accesibilidad

*   **Navegación:** Consistente en todas las pantallas. Iconos intuitivos.
*   **Entrada de Datos:** Teclados optimizados para números, texto, fechas. Auto-completado y sugerencias.
*   **Feedback Visual:** Animaciones sutiles, estados de carga, mensajes de éxito/error claros.
*   **Mobile Responsiveness:** Todas las interfaces web deben adaptarse a diferentes tamaños de pantalla.
*   **Contraste:** Colores y texto con suficiente contraste para legibilidad.
*   **Tamaño de Tocar:** Botones y elementos interactivos suficientemente grandes para ser tocados fácilmente en dispositivos móviles.

---

## 7. Directrices Adicionales

*   **Microinteracciones:** Pequeñas animaciones o feedback visual para mejorar la experiencia (ej. spinner en sincronización, checkmark al guardar).
*   **Estado Vacío:** Diseños para cuando las listas o tablas están vacías (ej. "No hay inspecciones aún. Crea una nueva.").
*   **Manejo de Errores:** Mensajes de error amigables y sugerencias para resolver el problema.

Este documento sirve como punto de partida para los diseños de UI/UX. La implementación detallada requerirá la creación de wireframes de baja fidelidad, luego mockups de alta fidelidad y prototipos interactivos, seguido de iteraciones basadas en feedback de usuarios.

---

## 6. Web Pública (Astro)

**Objetivo UX:** Atraer clientes potenciales, comunicar la propuesta de valor y facilitar la solicitud de servicios. Transmitir profesionalismo y confiabilidad.

### 6.1. Flujos Clave y Wireframes (Descripción Textual)

#### A. Página de Inicio
*   **Elementos:** Hero section con eslogan ("Inspecciona. Documenta. Verifica. Protege."), llamada a la acción ("Solicitar Inspección"), beneficios clave, testimonios (futuro), secciones de "Cómo Funciona" (visión general del proceso).
*   **Diseño:** Limpio, moderno, con uso de imágenes o ilustraciones profesionales. Navegación clara en el header (Inicio, Servicios, Planes, Contacto).

#### B. Página de Servicios
*   **Elementos:** Descripción detallada de los servicios ofrecidos, con enfoque en el valor para el cliente. Posiblemente, iconos o gráficos para cada servicio.

#### C. Página de Planes
*   **Elementos:** Presentación de los planes comerciales (Esencial, Integral, Protección) como se detalla en `planes.md`.
    *   Cada plan con su eslogan, lista de inclusiones clave (✅), precio "desde", y botón "Solicitar".
    *   Tabla comparativa de planes (`planes.md` - Sección 5) para una visión rápida de las diferencias.
*   **Diseño:** Tarjetas claras para cada plan, resaltando el "PLAN RECOMENDADO".

#### D. Página de "Solicitar Inspección"
*   **Elementos:** Formulario simple para recopilar información inicial: Tipo de Servicio, Fecha/Hora preferida (usando la API de disponibilidad de citas), Datos de contacto del cliente (Nombre, Email, Teléfono), Notas opcionales.
*   **UX:** Proceso guiado, validación en el lado del cliente, mensajes de éxito claros tras la solicitud.

#### E. Página de Contacto / Preguntas Frecuentes
*   **Elementos:** Formulario de contacto, información de la empresa, enlaces a redes sociales. Sección de FAQ con preguntas y respuestas comunes.

---

## 7. Consideraciones de Usabilidad y Accesibilidad (Actualización)

*   **Navegación:** Consistente en todas las pantallas. Iconos intuitivos.
*   **Entrada de Datos:** Teclados optimizados para números, texto, fechas. Auto-completado y sugerencias.
*   **Feedback Visual:** Animaciones sutiles, estados de carga, mensajes de éxito/error claros.
*   **Mobile Responsiveness:** Todas las interfaces web deben adaptarse a diferentes tamaños de pantalla.
*   **Contraste:** Colores y texto con suficiente contraste para legibilidad.
*   **Tamaño de Tocar:** Botones y elementos interactivos suficientemente grandes para ser tocados fácilmente en dispositivos móviles.
*   **Visualización de Permisos:** Elementos de UI (botones, secciones, campos) se deshabilitarán o se ocultarán si el rol del usuario no otorga los permisos necesarios, reforzando la seguridad. Mensajes claros (ej. "No tiene permisos para esta acción") cuando sea apropiado.
*   **Manejo de Errores en UI:**
    *   **Errores de Formulario:** Mensajes de validación inline, claros y concisos.
    *   **Errores de API (No críticos):** Toast notifications o alertas discretas en la parte superior de la pantalla.
    *   **Errores Críticos (Ej. 500, sesión expirada):** Página de error dedicada con opciones para reintentar o contactar soporte, o redirección al login.

---

## 8. Directrices Adicionales (Actualización)

*   **Microinteracciones:** Pequeñas animaciones o feedback visual para mejorar la experiencia (ej. spinner en sincronización, checkmark al guardar).
*   **Estado Vacío:** Diseños para cuando las listas o tablas están vacías (ej. "No hay inspecciones aún. Crea una nueva.").
*   **Manejo de Errores:** Mensajes de error amigables y sugerencias para resolver el problema.
