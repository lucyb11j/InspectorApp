<template>
  <div class="workspace-viewport">
    <!-- Header de Campo Nativo -->
    <header class="workspace-header">
      <div class="header-left">
        <!-- Botón Menú Flotante para Administradores / Menú Rápido -->
        <button 
          type="button" 
          class="btn-menu-drawer" 
          @click="showDrawer = true" 
          title="Abrir menú de navegación y módulos"
        >
          <span class="menu-icon">☰</span>
          <span class="menu-label">Menú</span>
        </button>

        <div class="inspection-title-block">
          <h2>{{ currentUnit.name }} — {{ currentUnit.project }}</h2>
          <div class="title-meta">
            <span class="meta-tag">Área: <strong>{{ activeArea }}</strong></span>
            <span class="badge-offline">⚡ SQLite Local (Offline)</span>
          </div>
        </div>
      </div>

      <div class="header-right">
        <!-- Switch de Vistas: Pantalla Dividida o Pantalla Completa según dispositivo -->
        <div class="view-toggles">
          <button 
            type="button" 
            class="view-btn" 
            :class="{ active: viewMode === 'split' }"
            @click="viewMode = 'split'"
            title="Ver Plano y Observaciones simultáneos (Recomendado para Tablet/PC)"
          >
            💻 Dividido
          </button>
          <button 
            type="button" 
            class="view-btn" 
            :class="{ active: viewMode === 'plan-only' }"
            @click="viewMode = 'plan-only'"
            title="Maximizar Plano de Inspección"
          >
            📐 Solo Plano
          </button>
          <button 
            type="button" 
            class="view-btn" 
            :class="{ active: viewMode === 'list-only' }"
            @click="viewMode = 'list-only'"
            title="Maximizar Lista de Defectos"
          >
            📋 Solo Defectos
          </button>
        </div>

        <button type="button" class="btn-primary-action" @click="showNewObsModal = true">
          + Nuevo Defecto
        </button>
      </div>
    </header>

    <!-- Espacio de Trabajo Nativo (Abarca el 100% de la pantalla sin marcos simulados) -->
    <div class="workspace-body" :class="`view-${viewMode}`">
      
      <!-- Panel de Plano Táctil Interactivo -->
      <section v-show="viewMode === 'split' || viewMode === 'plan-only'" class="plan-section">
        <div class="plan-toolbar">
          <div class="plan-legend">
            <span class="legend-dot"></span>
            <span>Haga clic o toque en cualquier zona del plano para situar una no-conformidad</span>
          </div>
          <div class="plan-stats">
            <span>Pins fijados: <strong>{{ markers.length }}</strong></span>
          </div>
        </div>

        <div class="plan-canvas-area" @click="handlePlanClick">
          <div class="blueprint-lines"></div>
          
          <!-- Plano base estilizado con zonas arquitectónicas -->
          <div class="architectural-blueprint">
            <div class="room-box room-living">
              <span>SALA / COMEDOR</span>
            </div>
            <div class="room-box room-kitchen">
              <span>COCINA</span>
            </div>
            <div class="room-box room-bed-main">
              <span>DORMITORIO PPAL</span>
            </div>
            <div class="room-box room-bath-main">
              <span>BAÑO PPAL</span>
            </div>
            <div class="room-box room-balcony">
              <span>BALCÓN</span>
            </div>
          </div>

          <!-- Marcadores / Pines Interactivos -->
          <div
            v-for="(marker, idx) in markers"
            :key="idx"
            class="interactive-pin"
            :style="{ left: `${marker.x}%`, top: `${marker.y}%` }"
            :class="`pin-${marker.severity.toLowerCase()}`"
            @click.stop="selectMarker(marker)"
          >
            <div class="pin-marker-head">
              <span class="pin-icon">📍</span>
              <span class="pin-number">{{ idx + 1 }}</span>
            </div>
            <div class="pin-callout">
              <strong>#{{ idx + 1 }} {{ marker.title }}</strong>
              <small>{{ marker.area }} · {{ marker.severity }}</small>
            </div>
          </div>
        </div>
      </section>

      <!-- Panel de Zonas y Registro de Observaciones -->
      <section v-show="viewMode === 'split' || viewMode === 'list-only'" class="observations-section">
        <!-- Selector Horizontal de Ambientes / Áreas -->
        <div class="area-navigation-bar">
          <button
            v-for="area in areas"
            :key="area"
            type="button"
            class="area-tab"
            :class="{ active: activeArea === area }"
            @click="activeArea = area"
          >
            {{ area }}
            <span class="area-badge-count">{{ countByArea(area) }}</span>
          </button>
        </div>

        <!-- Lista de No Conformidades en el Área Seleccionada -->
        <div class="observations-scroll-pane">
          <div class="pane-header-actions">
            <div>
              <h3>Defectos en {{ activeArea }}</h3>
              <p class="section-hint">Registros locales con verificación fotográfica SHA-256</p>
            </div>
            <button type="button" class="btn-ghost-sm" @click="showNewObsModal = true">
              + Catálogo Rápido
            </button>
          </div>

          <div v-if="filteredObservations.length === 0" class="empty-observations">
            <span class="empty-icon">✅</span>
            <h4>No hay observaciones registradas en esta zona</h4>
            <p>Haga clic en el plano o use el catálogo rápido para añadir no-conformidades.</p>
            <button type="button" class="btn-preset-primary" @click="showNewObsModal = true">
              + Añadir Defecto
            </button>
          </div>

          <div v-else class="observations-grid">
            <div 
              v-for="obs in filteredObservations" 
              :key="obs.id" 
              class="observation-card"
              :class="{ 'obs-selected': selectedObsId === obs.id }"
              @click="selectedObsId = obs.id"
            >
              <div class="obs-card-top">
                <div class="obs-tags">
                  <span class="tag-severity" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                  <span class="tag-status">{{ obs.status }}</span>
                </div>
                <span class="tag-storage">Drift SQLite</span>
              </div>

              <h4 class="obs-title">{{ obs.title }}</h4>
              <p class="obs-description">{{ obs.description }}</p>

              <div class="obs-evidence-box">
                <div class="evidence-thumb">
                  <span>📸</span>
                </div>
                <div class="evidence-meta">
                  <span class="evidence-file">EVIDENCIA-FOTO-{{ obs.id.substring(0, 6) }}.JPG</span>
                  <code class="evidence-hash">SHA-256: {{ obs.sha256.substring(0, 16) }}...</code>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer de Acción: Generar Informe Técnico -->
        <div class="section-footer">
          <NuxtLink to="/inspections/55555555-0000-0000-0000-000000000001" class="btn-generate-report">
            📄 Finalizar Visita y Generar Acta Técnica →
          </NuxtLink>
        </div>
      </section>

    </div>

    <!-- Menú Lateral Drawer (Oculto en Botón para no quitar espacio) -->
    <div v-if="showDrawer" class="drawer-overlay" @click.self="showDrawer = false">
      <aside class="drawer-content">
        <div class="drawer-header">
          <div class="drawer-brand">
            <span class="brand-logo">🏢</span>
            <h3>InspectorHub</h3>
          </div>
          <button type="button" class="btn-close-drawer" @click="showDrawer = false">✕</button>
        </div>

        <nav class="drawer-nav">
          <NuxtLink to="/dashboard" class="drawer-item" @click="showDrawer = false">
            <span class="d-icon">📊</span>
            <span>Dashboard Administrativo</span>
          </NuxtLink>
          <NuxtLink to="/inspections" class="drawer-item" @click="showDrawer = false">
            <span class="d-icon">📋</span>
            <span>Inspecciones Técnicas</span>
          </NuxtLink>
          <NuxtLink to="/plans" class="drawer-item" @click="showDrawer = false">
            <span class="d-icon">📐</span>
            <span>Gestor de Planos</span>
          </NuxtLink>
          <NuxtLink to="/sync-monitor" class="drawer-item" @click="showDrawer = false">
            <span class="d-icon">⚡</span>
            <span>Motor de Sincronización</span>
          </NuxtLink>
          <NuxtLink to="/properties" class="drawer-item" @click="showDrawer = false">
            <span class="d-icon">🏢</span>
            <span>Propiedades & Inmuebles</span>
          </NuxtLink>
          <NuxtLink to="/clients" class="drawer-item" @click="showDrawer = false">
            <span class="d-icon">👥</span>
            <span>Clientes & Propietarios</span>
          </NuxtLink>
        </nav>

        <div class="drawer-footer">
          <p class="drawer-user">Sesión: <strong>admin@inspector.com</strong></p>
          <NuxtLink to="/login" class="drawer-logout">Cerrar Sesión</NuxtLink>
        </div>
      </aside>
    </div>

    <!-- Modal para Agregar Observación con Foto y Ubicación -->
    <div v-if="showNewObsModal" class="modal-overlay" @click.self="showNewObsModal = false">
      <div class="modal-dialog">
        <div class="modal-dialog-header">
          <h3>Registrar Defecto en {{ activeArea }}</h3>
          <button type="button" class="btn-close-modal" @click="showNewObsModal = false">✕</button>
        </div>

        <div class="modal-dialog-body">
          <p class="modal-hint">Seleccione un elemento del catálogo estándar o complete la descripción:</p>
          
          <div class="preset-pills">
            <button
              v-for="preset in presets"
              :key="preset.id"
              type="button"
              class="preset-pill"
              @click="applyPreset(preset)"
            >
              {{ preset.title }}
            </button>
          </div>

          <div class="form-group">
            <label>Título de la Observación:</label>
            <input v-model="newObsForm.title" type="text" class="input-field" placeholder="Ej: Fisura capilar en muro" />
          </div>

          <div class="form-group">
            <label>Descripción Técnica Detallada:</label>
            <textarea v-model="newObsForm.description" rows="3" class="input-field" placeholder="Describa el defecto observado..."></textarea>
          </div>

          <div class="form-row">
            <div class="form-group col">
              <label>Severidad:</label>
              <select v-model="newObsForm.severity" class="input-field">
                <option value="MENOR">MENOR</option>
                <option value="MODERADA">MODERADA</option>
                <option value="MAYOR">MAYOR</option>
                <option value="CRÍTICA">CRÍTICA</option>
              </select>
            </div>
            <div class="form-group col">
              <label>Evidencia Fotográfica:</label>
              <div class="fake-camera-btn">
                <span>📷 Foto tomada (Hash SHA-256 generado)</span>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-dialog-footer">
          <button type="button" class="btn-cancel" @click="showNewObsModal = false">Cancelar</button>
          <button type="button" class="btn-save" @click="saveNewObservation">Guardar Observación</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false // Desactiva el layout general con sidebar exterior: esta es la app nativa a pantalla completa
})

// Modo de visualización nativo en toda la ventana
const viewMode = ref<'split' | 'plan-only' | 'list-only'>('split')
const showDrawer = ref(false)
const showNewObsModal = ref(false)
const selectedObsId = ref<string | null>(null)

const currentUnit = {
  name: 'Departamento 305',
  project: 'Condominio Los Cedros - Torre B'
}

const areas = ['Sala / Comedor', 'Cocina', 'Dormitorio Principal', 'Baño Principal', 'Balcón']
const activeArea = ref('Sala / Comedor')

interface ObservationItem {
  id: string
  area: string
  title: string
  description: string
  severity: 'MENOR' | 'MODERADA' | 'MAYOR' | 'CRÍTICA'
  status: string
  sha256: string
}

const observations = ref<ObservationItem[]>([
  {
    id: 'obs-01',
    area: 'Sala / Comedor',
    title: 'Fisura capilar en muro norte',
    description: 'Fisura diagonal de 0.4mm sobre enlucido contiguo a ventana principal.',
    severity: 'MENOR',
    status: 'PENDIENTE',
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  },
  {
    id: 'obs-02',
    area: 'Cocina',
    title: 'Junta de cerámico desalineada o con holgura',
    description: 'Separación mayor a 3mm en piso cerámico frente al mesón de granito.',
    severity: 'MODERADA',
    status: 'PENDIENTE',
    sha256: 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'
  },
  {
    id: 'obs-03',
    area: 'Baño Principal',
    title: 'Falta sellado de silicona sanitaria',
    description: 'Ausencia de cordón perimetral antihongos entre lavamanos y pared.',
    severity: 'MODERADA',
    status: 'PENDIENTE',
    sha256: '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a'
  }
])

interface PlanMarkerItem {
  x: number
  y: number
  title: string
  area: string
  severity: string
}

const markers = ref<PlanMarkerItem[]>([
  { x: 28, y: 38, title: 'Fisura en muro norte', area: 'Sala / Comedor', severity: 'MENOR' },
  { x: 55, y: 24, title: 'Junta de cerámico desalineada', area: 'Cocina', severity: 'MODERADA' },
  { x: 75, y: 62, title: 'Falta sellado de silicona', area: 'Baño Principal', severity: 'MODERADA' }
])

const filteredObservations = computed(() => {
  return observations.value.filter(o => o.area === activeArea.value)
})

const countByArea = (area: string) => {
  return observations.value.filter(o => o.area === area).length
}

// Catálogo de Defectos Frecuentes
const presets = [
  { id: '1', title: 'Fisura en muro', desc: 'Fisura capilar por retracción en empaste o revoque.', severity: 'MENOR' as const },
  { id: '2', title: 'Descuadre en marco de puerta', desc: 'Holgura asimétrica o fricción en pestillo.', severity: 'MODERADA' as const },
  { id: '3', title: 'Pieza cerámica hueca', desc: 'Falta de adherencia en baldosa cerámica.', severity: 'MODERADA' as const },
  { id: '4', title: 'Falta silicona antihongos', desc: 'Sellado ausente en artefactos sanitarios.', severity: 'MENOR' as const },
  { id: '5', title: 'Mancha en pintura', desc: 'Variación de tono o retoque visible.', severity: 'MENOR' as const },
  { id: '6', title: 'Goteo en grifería', desc: 'Filtración en flexible o conexión de agua.', severity: 'MAYOR' as const }
]

const newObsForm = ref({
  title: '',
  description: '',
  severity: 'MENOR' as 'MENOR' | 'MODERADA' | 'MAYOR' | 'CRÍTICA'
})

const applyPreset = (preset: typeof presets[0]) => {
  newObsForm.value.title = preset.title
  newObsForm.value.description = preset.desc
  newObsForm.value.severity = preset.severity
}

const handlePlanClick = (event: MouseEvent) => {
  const rect = (event.currentTarget as HTMLElement).getBoundingClientRect()
  const x = Math.round(((event.clientX - rect.left) / rect.width) * 1000) / 10
  const y = Math.round(((event.clientY - rect.top) / rect.height) * 1000) / 10

  markers.value.push({
    x,
    y,
    title: `Punto de inspección`,
    area: activeArea.value,
    severity: 'MENOR'
  })
}

const selectMarker = (marker: PlanMarkerItem) => {
  activeArea.value = marker.area
}

const saveNewObservation = () => {
  if (!newObsForm.value.title) return

  const newId = `obs-${Date.now()}`
  observations.value.unshift({
    id: newId,
    area: activeArea.value,
    title: newObsForm.value.title,
    description: newObsForm.value.description,
    severity: newObsForm.value.severity,
    status: 'PENDIENTE',
    sha256: Array.from({ length: 64 }, () => Math.floor(Math.random() * 16).toString(16)).join('')
  })

  // Agregar pin automático cerca del centro del área si no existe
  markers.value.push({
    x: 40 + Math.random() * 20,
    y: 35 + Math.random() * 25,
    title: newObsForm.value.title,
    area: activeArea.value,
    severity: newObsForm.value.severity
  })

  newObsForm.value.title = ''
  newObsForm.value.description = ''
  showNewObsModal.value = false
}
</script>

<style scoped>
.workspace-viewport {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  background: #0d0d0d;
  color: #fff;
  overflow: hidden;
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  z-index: 50;
}

/* Header Nativo de Campo */
.workspace-header {
  height: 64px;
  background: #161616;
  border-bottom: 1px solid #262626;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}
.btn-menu-drawer {
  background: #222;
  border: 1px solid #333;
  color: #fff;
  padding: 8px 14px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 0.88rem;
  font-weight: 600;
  transition: all 0.2s ease;
}
.btn-menu-drawer:hover {
  background: #2a2a2a;
  border-color: var(--primary);
}
.menu-icon {
  font-size: 1.1rem;
}
.inspection-title-block h2 {
  font-size: 1.15rem;
  margin: 0;
  color: #fff;
}
.title-meta {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 3px;
}
.meta-tag {
  font-size: 0.8rem;
  color: #aaa;
}
.badge-offline {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  font-size: 0.72rem;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: bold;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 14px;
}
.view-toggles {
  display: flex;
  background: #222;
  border-radius: 8px;
  padding: 3px;
  gap: 2px;
}
.view-btn {
  background: transparent;
  border: none;
  color: #888;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.view-btn.active {
  background: var(--primary);
  color: #fff;
}
.btn-primary-action {
  background: var(--primary);
  color: #fff;
  border: none;
  padding: 9px 18px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: bold;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(26,115,232,0.35);
}

/* Cuerpo de la Aplicación (Plano + Observaciones) */
.workspace-body {
  flex: 1;
  display: flex;
  overflow: hidden;
}

/* Modo Dividido */
.workspace-body.view-split .plan-section {
  flex: 6;
  border-right: 1.5px solid #222;
}
.workspace-body.view-split .observations-section {
  flex: 4;
}

/* Modos de Pantalla Completa */
.workspace-body.view-plan-only .plan-section {
  flex: 1;
}
.workspace-body.view-list-only .observations-section {
  flex: 1;
}

/* Sección de Plano Táctil */
.plan-section {
  display: flex;
  flex-direction: column;
  background: #111;
  position: relative;
}
.plan-toolbar {
  padding: 8px 16px;
  background: #181818;
  border-bottom: 1px solid #222;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.8rem;
  color: #aaa;
}
.plan-legend {
  display: flex;
  align-items: center;
  gap: 8px;
}
.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #cf6679;
}
.plan-stats {
  font-size: 0.8rem;
  color: #888;
}
.plan-canvas-area {
  flex: 1;
  position: relative;
  background: #101010;
  overflow: hidden;
  cursor: crosshair;
  display: flex;
  align-items: center;
  justify-content: center;
}
.blueprint-lines {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-image: linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px);
  background-size: 28px 28px;
}

/* Plano Arquitectónico Estilizado */
.architectural-blueprint {
  width: 86%;
  height: 84%;
  border: 2px dashed rgba(255,255,255,0.15);
  border-radius: 12px;
  position: relative;
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  grid-template-rows: 2fr 1.5fr;
  gap: 8px;
  padding: 10px;
  box-sizing: border-box;
}
.room-box {
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(255,255,255,0.02);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.78rem;
  font-weight: 700;
  color: rgba(255,255,255,0.3);
  letter-spacing: 1px;
}
.room-living { grid-column: 1 / 2; grid-row: 1 / 3; }
.room-kitchen { grid-column: 2 / 4; grid-row: 1 / 2; }
.room-bed-main { grid-column: 2 / 3; grid-row: 2 / 3; }
.room-bath-main { grid-column: 3 / 4; grid-row: 2 / 3; }

/* Pines Táctiles */
.interactive-pin {
  position: absolute;
  transform: translate(-50%, -100%);
  cursor: pointer;
  z-index: 10;
  transition: transform 0.15s ease;
}
.interactive-pin:hover {
  transform: translate(-50%, -115%) scale(1.15);
}
.pin-marker-head {
  display: flex;
  align-items: center;
  gap: 2px;
  font-size: 1.4rem;
}
.pin-number {
  background: #cf6679;
  color: #fff;
  font-size: 0.65rem;
  padding: 1px 5px;
  border-radius: 4px;
  font-weight: bold;
}
.pin-callout {
  display: none;
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: #1e1e1e;
  border: 1px solid #444;
  padding: 6px 10px;
  border-radius: 6px;
  white-space: nowrap;
  font-size: 0.72rem;
  box-shadow: 0 4px 16px rgba(0,0,0,0.6);
}
.interactive-pin:hover .pin-callout {
  display: flex;
  flex-direction: column;
}

/* Sección de Observaciones */
.observations-section {
  display: flex;
  flex-direction: column;
  background: #141414;
}
.area-navigation-bar {
  display: flex;
  background: #181818;
  border-bottom: 1px solid #262626;
  overflow-x: auto;
  padding: 0 10px;
}
.area-tab {
  background: transparent;
  border: none;
  color: #888;
  padding: 12px 14px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 6px;
}
.area-tab.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
}
.area-badge-count {
  background: rgba(255,255,255,0.08);
  font-size: 0.68rem;
  padding: 1px 6px;
  border-radius: 10px;
}
.area-tab.active .area-badge-count {
  background: rgba(26,115,232,0.25);
  color: #fff;
}

.observations-scroll-pane {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}
.pane-header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.pane-header-actions h3 {
  margin: 0;
  font-size: 1.05rem;
}
.section-hint {
  font-size: 0.75rem;
  color: #888;
  margin: 2px 0 0 0;
}
.btn-ghost-sm {
  background: #222;
  border: 1px solid #333;
  color: #fff;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
}

/* Tarjetas de Observación */
.observations-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.observation-card {
  background: #1b1b1b;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  padding: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.observation-card:hover, .observation-card.obs-selected {
  border-color: var(--primary);
  background: #222;
}
.obs-card-top {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
}
.obs-tags {
  display: flex;
  gap: 6px;
}
.tag-severity {
  font-size: 0.68rem;
  font-weight: 700;
  padding: 2px 7px;
  border-radius: 4px;
}
.sev-menor { background: rgba(255,193,7,0.15); color: #ffc107; }
.sev-moderada { background: rgba(26,115,232,0.15); color: #4d9eff; }
.sev-mayor { background: rgba(255,138,0,0.15); color: #ff8a00; }
.sev-crítica { background: rgba(207,102,121,0.15); color: var(--error); }
.tag-status {
  font-size: 0.65rem;
  background: rgba(255,255,255,0.06);
  padding: 2px 6px;
  border-radius: 4px;
  color: #aaa;
}
.tag-storage {
  font-size: 0.65rem;
  color: #777;
}
.obs-title {
  margin: 0 0 4px 0;
  font-size: 0.95rem;
}
.obs-description {
  margin: 0 0 10px 0;
  font-size: 0.82rem;
  color: #aaa;
  line-height: 1.4;
}
.obs-evidence-box {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #141414;
  padding: 8px 10px;
  border-radius: 6px;
  border: 1px solid #262626;
}
.evidence-thumb {
  font-size: 1.1rem;
}
.evidence-meta {
  display: flex;
  flex-direction: column;
}
.evidence-file {
  font-size: 0.72rem;
  font-weight: 600;
  color: #ddd;
}
.evidence-hash {
  font-size: 0.65rem;
  color: #03dac6;
}

/* Empty State */
.empty-observations {
  text-align: center;
  padding: 40px 10px;
  color: #888;
}
.empty-icon {
  font-size: 2.2rem;
  display: block;
  margin-bottom: 8px;
}
.btn-preset-primary {
  background: var(--primary);
  color: #fff;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: bold;
  margin-top: 12px;
  cursor: pointer;
}

/* Footer de Sección */
.section-footer {
  padding: 12px 16px;
  background: #181818;
  border-top: 1px solid #262626;
}
.btn-generate-report {
  display: block;
  text-align: center;
  background: linear-gradient(135deg, var(--primary), var(--primary-hover));
  color: #fff;
  padding: 10px;
  border-radius: 8px;
  text-decoration: none;
  font-size: 0.88rem;
  font-weight: bold;
}

/* Drawer Lateral (Oculto en Botón para no molestar en pantalla) */
.drawer-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.65);
  backdrop-filter: blur(4px);
  z-index: 100;
}
.drawer-content {
  width: 280px;
  height: 100%;
  background: #181818;
  border-right: 1px solid #2a2a2a;
  display: flex;
  flex-direction: column;
  padding: 20px;
  box-sizing: border-box;
}
.drawer-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.drawer-brand {
  display: flex;
  align-items: center;
  gap: 10px;
}
.drawer-brand h3 {
  margin: 0;
  font-size: 1.15rem;
}
.btn-close-drawer {
  background: none;
  border: none;
  color: #aaa;
  font-size: 1.3rem;
  cursor: pointer;
}
.drawer-nav {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
}
.drawer-item {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #ccc;
  text-decoration: none;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 0.88rem;
  font-weight: 500;
  transition: all 0.2s ease;
}
.drawer-item:hover {
  background: rgba(255,255,255,0.06);
  color: #fff;
}
.drawer-footer {
  border-top: 1px solid #262626;
  padding-top: 14px;
  font-size: 0.8rem;
  color: #888;
}
.drawer-logout {
  color: var(--error);
  text-decoration: none;
  display: inline-block;
  margin-top: 6px;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 110;
}
.modal-dialog {
  background: #1e1e1e;
  border: 1px solid #333;
  border-radius: 14px;
  width: 90%;
  max-width: 520px;
  padding: 22px;
}
.modal-dialog-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.modal-dialog-header h3 {
  margin: 0;
  font-size: 1.15rem;
}
.btn-close-modal {
  background: none;
  border: none;
  color: #aaa;
  font-size: 1.2rem;
  cursor: pointer;
}
.modal-hint {
  font-size: 0.8rem;
  color: #888;
  margin: 0 0 12px 0;
}
.preset-pills {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 16px;
}
.preset-pill {
  background: #2a2a2a;
  border: 1px solid #3a3a3a;
  color: #ddd;
  padding: 5px 10px;
  border-radius: 14px;
  font-size: 0.72rem;
  cursor: pointer;
}
.preset-pill:hover {
  border-color: var(--primary);
  background: #333;
}
.form-group {
  margin-bottom: 12px;
}
.form-group label {
  display: block;
  font-size: 0.78rem;
  color: #aaa;
  margin-bottom: 4px;
}
.input-field {
  width: 100%;
  background: #141414;
  border: 1px solid #333;
  color: #fff;
  padding: 8px 12px;
  border-radius: 8px;
  box-sizing: border-box;
  font-size: 0.88rem;
}
.input-field:focus {
  outline: none;
  border-color: var(--primary);
}
.form-row {
  display: flex;
  gap: 12px;
}
.form-row .col {
  flex: 1;
}
.fake-camera-btn {
  background: #141414;
  border: 1px dashed #444;
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 0.78rem;
  color: #03dac6;
  text-align: center;
}
.modal-dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 18px;
}
.btn-cancel {
  background: transparent;
  border: 1px solid #444;
  color: #ccc;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
}
.btn-save {
  background: var(--primary);
  border: none;
  color: #fff;
  padding: 8px 18px;
  border-radius: 6px;
  font-weight: bold;
  cursor: pointer;
}
</style>
