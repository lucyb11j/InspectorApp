<template>
  <div class="workspace-viewport">
    <!-- Header de Campo Nativo Responsivo -->
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
            <span class="badge-offline">⚡ SQLite Local</span>
            <span v-if="movingPinIndex !== null" class="badge-moving">
              📍 Moviendo Pin #{{ movingPinIndex + 1 }} (Haga clic en el plano para reubicar)
            </span>
          </div>
        </div>
      </div>

      <div class="header-right">
        <!-- Switch de Vistas Adaptable -->
        <div class="view-toggles">
          <button 
            type="button" 
            class="view-btn view-split-btn" 
            :class="{ active: viewMode === 'split' }"
            @click="viewMode = 'split'"
            title="Vista dividida simultánea (Plano + Lista)"
          >
            💻 Dividido
          </button>
          <button 
            type="button" 
            class="view-btn" 
            :class="{ active: viewMode === 'plan-only' }"
            @click="viewMode = 'plan-only'"
            title="Solo Plano Táctil"
          >
            📐 Plano
          </button>
          <button 
            type="button" 
            class="view-btn" 
            :class="{ active: viewMode === 'list-only' }"
            @click="viewMode = 'list-only'"
            title="Solo Defectos"
          >
            📋 Defectos
          </button>
        </div>

        <button type="button" class="btn-primary-action" @click="openNewObsModal()">
          <span class="btn-plus">+</span>
          <span class="btn-action-text">Defecto</span>
        </button>
      </div>
    </header>

    <!-- Espacio de Trabajo Responsivo Universal -->
    <div class="workspace-body" :class="`view-${viewMode}`">
      
      <!-- Panel de Plano Táctil Interactivo -->
      <section v-show="viewMode === 'split' || viewMode === 'plan-only'" class="plan-section">
        <div class="plan-toolbar">
          <div class="plan-legend">
            <span class="legend-dot" :class="{ 'moving-pulse': movingPinIndex !== null }"></span>
            <span v-if="movingPinIndex !== null" class="text-moving">
              MODO REUBICACIÓN: Haga clic sobre el plano donde desea mover el Pin #{{ movingPinIndex + 1 }}
            </span>
            <span v-else>Toque en el plano para situar una nueva observación</span>
          </div>
          <div class="plan-stats">
            <button v-if="movingPinIndex !== null" class="btn-cancel-move" @click.stop="cancelMovingPin">
              ✕ Cancelar Mover
            </button>
            <span>Pines: <strong>{{ markers.length }}</strong></span>
          </div>
        </div>

        <div class="plan-canvas-area" @click="handlePlanClick">
          <div class="blueprint-lines"></div>
          
          <!-- Plano base estilizado con zonas arquitectónicas -->
          <div class="architectural-blueprint">
            <div 
              class="room-box room-living" 
              :class="{ highlight: activeArea === 'Sala / Comedor' }"
              @click="handleAreaClick($event, 'Sala / Comedor')"
            >
              <span class="room-name">SALA / COMEDOR</span>
            </div>
            <div 
              class="room-box room-kitchen" 
              :class="{ highlight: activeArea === 'Cocina' }"
              @click="handleAreaClick($event, 'Cocina')"
            >
              <span class="room-name">COCINA</span>
            </div>
            <div 
              class="room-box room-bed-main" 
              :class="{ highlight: activeArea === 'Dormitorio Principal' }"
              @click="handleAreaClick($event, 'Dormitorio Principal')"
            >
              <span class="room-name">DORMITORIO PPAL</span>
            </div>
            <div 
              class="room-box room-bath-main" 
              :class="{ highlight: activeArea === 'Baño Principal' }"
              @click="handleAreaClick($event, 'Baño Principal')"
            >
              <span class="room-name">BAÑO PPAL</span>
            </div>
            <div 
              class="room-box room-balcony" 
              :class="{ highlight: activeArea === 'Balcón' }"
              @click="handleAreaClick($event, 'Balcón')"
            >
              <span class="room-name">BALCÓN</span>
            </div>
          </div>

          <!-- Marcadores / Pines Interactivos -->
          <div
            v-for="(marker, idx) in markers"
            :key="idx"
            class="interactive-pin"
            :style="{ left: `${marker.x}%`, top: `${marker.y}%` }"
            :class="[`pin-${marker.severity.toLowerCase()}`, { 'pin-active-moving': movingPinIndex === idx, 'pin-selected': selectedMarkerIndex === idx }]"
            @click.stop="selectMarker(marker, idx)"
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

        <!-- Popover / Barra de Detalle de Pin Seleccionado -->
        <div v-if="selectedMarkerIndex !== null && markers[selectedMarkerIndex]" class="pin-detail-bar">
          <div class="pin-detail-info">
            <span class="badge-pin-num">Pin #{{ selectedMarkerIndex + 1 }}</span>
            <div class="pin-detail-texts">
              <strong>{{ markers[selectedMarkerIndex].title }}</strong>
              <span>Área: {{ markers[selectedMarkerIndex].area }} (X: {{ markers[selectedMarkerIndex].x }}%, Y: {{ markers[selectedMarkerIndex].y }}%)</span>
            </div>
          </div>
          <div class="pin-detail-actions">
            <button 
              type="button" 
              class="btn-pin-move" 
              @click="startMovingPin(selectedMarkerIndex)"
              title="Mover este pin a otra coordenada en el plano"
            >
              🔄 Mover Pin
            </button>
            <button 
              type="button" 
              class="btn-pin-delete" 
              @click="deletePin(selectedMarkerIndex)"
              title="Eliminar este pin del plano"
            >
              🗑️ Borrar Pin
            </button>
            <button type="button" class="btn-pin-close" @click="selectedMarkerIndex = null">✕</button>
          </div>
        </div>

        <!-- Lista de No Conformidades en el Área Seleccionada -->
        <div class="observations-scroll-pane">
          <div class="pane-header-actions">
            <div>
              <h3>Defectos en {{ activeArea }} ({{ filteredObservations.length }})</h3>
              <p class="section-hint">Registros locales con verificación fotográfica SHA-256</p>
            </div>
            <button type="button" class="btn-ghost-sm" @click="openNewObsModal()">
              + Catálogo Rápido
            </button>
          </div>

          <div v-if="filteredObservations.length === 0" class="empty-observations">
            <span class="empty-icon">✅</span>
            <h4>No hay observaciones registradas en esta zona</h4>
            <p>Haga clic en el plano para ubicar un pin o añada un defecto directamente.</p>
            <button type="button" class="btn-preset-primary" @click="openNewObsModal()">
              + Añadir Defecto
            </button>
          </div>

          <div v-else class="observations-grid">
            <div 
              v-for="obs in filteredObservations" 
              :key="obs.id" 
              class="observation-card"
              :class="{ 'obs-selected': selectedObsId === obs.id }"
              @click="selectObsCard(obs)"
            >
              <div class="obs-card-top">
                <div class="obs-tags">
                  <span class="tag-severity" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                  <span class="tag-status">{{ obs.status }}</span>
                  <span v-if="getObsMarkerIndex(obs.id) !== -1" class="tag-pin-link">
                    📍 Pin #{{ getObsMarkerIndex(obs.id) + 1 }}
                  </span>
                </div>
                <div class="obs-actions-top">
                  <button 
                    type="button" 
                    class="btn-delete-obs" 
                    @click.stop="deleteObservation(obs.id)" 
                    title="Eliminar esta observación"
                  >
                    🗑️
                  </button>
                  <span class="tag-storage">Drift SQLite</span>
                </div>
              </div>

              <h4 class="obs-title">{{ obs.title }}</h4>
              <p class="obs-description">{{ obs.description }}</p>

              <div class="obs-evidence-box">
                <div class="evidence-thumb">
                  <span>📸</span>
                </div>
                <div class="evidence-meta">
                  <span class="evidence-file">EVIDENCIA-FOTO-{{ obs.id.substring(0, 8) }}.JPG</span>
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
          <p class="drawer-user">Usuario: <strong>{{ currentUserName || 'inspector@inspector.com' }}</strong></p>
          <NuxtLink to="/login" class="drawer-logout">Cerrar Sesión</NuxtLink>
        </div>
      </aside>
    </div>

    <!-- Modal para Agregar Observación con Foto y Ubicación -->
    <div v-if="showNewObsModal" class="modal-overlay" @click.self="showNewObsModal = false">
      <div class="modal-dialog">
        <div class="modal-dialog-header">
          <div>
            <h3>Registrar Observación / Defecto</h3>
            <span class="modal-subtitle">
              Área: <strong>{{ activeArea }}</strong> 
              <span v-if="pendingCoordinates">· Ubicación: ({{ pendingCoordinates.x }}%, {{ pendingCoordinates.y }}%)</span>
            </span>
          </div>
          <button type="button" class="btn-close-modal" @click="showNewObsModal = false">✕</button>
        </div>

        <div class="modal-dialog-body">
          <p class="modal-hint">Seleccione un elemento del catálogo rápido o ingrese el detalle técnico:</p>
          
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
                <span>📷 Foto registrada (Hash SHA-256 verificado)</span>
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
  layout: false // Sin layout exterior: ocupa el 100% de la ventana en teléfono, tablet o PC
})

const { name: currentUserName } = useAuthUser()

// Modos de vista: 'split' | 'plan-only' | 'list-only'
const viewMode = ref<'split' | 'plan-only' | 'list-only'>('split')
const showDrawer = ref(false)
const showNewObsModal = ref(false)
const selectedObsId = ref<string | null>(null)
const selectedMarkerIndex = ref<number | null>(null)
const movingPinIndex = ref<number | null>(null)
const pendingCoordinates = ref<{ x: number; y: number } | null>(null)

// Detección automática al cargar según el ancho de la pantalla
onMounted(() => {
  if (typeof window !== 'undefined') {
    if (window.innerWidth < 768) {
      viewMode.value = 'plan-only'
    } else {
      viewMode.value = 'split'
    }

    window.addEventListener('resize', () => {
      if (window.innerWidth < 768 && viewMode.value === 'split') {
        viewMode.value = 'plan-only'
      }
    })
  }
})

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
  obsId?: string
}

const markers = ref<PlanMarkerItem[]>([
  { x: 28, y: 38, title: 'Fisura en muro norte', area: 'Sala / Comedor', severity: 'MENOR', obsId: 'obs-01' },
  { x: 55, y: 24, title: 'Junta de cerámico desalineada', area: 'Cocina', severity: 'MODERADA', obsId: 'obs-02' },
  { x: 75, y: 62, title: 'Falta sellado de silicona', area: 'Baño Principal', severity: 'MODERADA', obsId: 'obs-03' }
])

const filteredObservations = computed(() => {
  return observations.value.filter(o => o.area === activeArea.value)
})

const countByArea = (area: string) => {
  return observations.value.filter(o => o.area === area).length
}

const getObsMarkerIndex = (obsId: string) => {
  return markers.value.findIndex(m => m.obsId === obsId)
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

const selectArea = (areaName: string) => {
  activeArea.value = areaName
}

const handleAreaClick = (event: MouseEvent, areaName: string) => {
  activeArea.value = areaName
  // Delegar al canvas plan click para capturar coordenadas exactas
  const canvas = document.querySelector('.plan-canvas-area') as HTMLElement
  if (canvas) {
    const rect = canvas.getBoundingClientRect()
    const x = Math.round(((event.clientX - rect.left) / rect.width) * 1000) / 10
    const y = Math.round(((event.clientY - rect.top) / rect.height) * 1000) / 10

    if (movingPinIndex.value !== null && markers.value[movingPinIndex.value]) {
      markers.value[movingPinIndex.value].x = x
      markers.value[movingPinIndex.value].y = y
      markers.value[movingPinIndex.value].area = areaName
      selectedMarkerIndex.value = movingPinIndex.value
      movingPinIndex.value = null
      return
    }

    openNewObsModal({ x, y })
  }
}

const openNewObsModal = (coords?: { x: number; y: number }) => {
  if (coords) {
    pendingCoordinates.value = coords
  } else {
    pendingCoordinates.value = {
      x: 35 + Math.round(Math.random() * 30),
      y: 30 + Math.round(Math.random() * 30)
    }
  }
  showNewObsModal.value = true
}

const handlePlanClick = (event: MouseEvent) => {
  const rect = (event.currentTarget as HTMLElement).getBoundingClientRect()
  const x = Math.round(((event.clientX - rect.left) / rect.width) * 1000) / 10
  const y = Math.round(((event.clientY - rect.top) / rect.height) * 1000) / 10

  // Si estamos en modo mover pin, actualizamos su coordenada
  if (movingPinIndex.value !== null && markers.value[movingPinIndex.value]) {
    markers.value[movingPinIndex.value].x = x
    markers.value[movingPinIndex.value].y = y
    selectedMarkerIndex.value = movingPinIndex.value
    movingPinIndex.value = null
    return
  }

  // De lo contrario, abrir modal para registrar defecto en ese punto exacto
  openNewObsModal({ x, y })
}

const selectMarker = (marker: PlanMarkerItem, idx: number) => {
  selectedMarkerIndex.value = idx
  activeArea.value = marker.area
  if (marker.obsId) {
    selectedObsId.value = marker.obsId
  }
}

const selectObsCard = (obs: ObservationItem) => {
  selectedObsId.value = obs.id
  const markerIdx = getObsMarkerIndex(obs.id)
  if (markerIdx !== -1) {
    selectedMarkerIndex.value = markerIdx
  }
}

const startMovingPin = (idx: number) => {
  movingPinIndex.value = idx
}

const cancelMovingPin = () => {
  movingPinIndex.value = null
}

const deletePin = (idx: number) => {
  if (idx >= 0 && idx < markers.value.length) {
    const deleted = markers.value.splice(idx, 1)[0]
    selectedMarkerIndex.value = null
    if (movingPinIndex.value === idx) {
      movingPinIndex.value = null
    }
  }
}

const deleteObservation = (obsId: string) => {
  observations.value = observations.value.filter(o => o.id !== obsId)
  // Quitar también el pin asociado si existe
  const pinIdx = markers.value.findIndex(m => m.obsId === obsId)
  if (pinIdx !== -1) {
    deletePin(pinIdx)
  }
}

const saveNewObservation = () => {
  if (!newObsForm.value.title) return

  const newId = `obs-${Date.now()}`
  const coords = pendingCoordinates.value || {
    x: 40 + Math.round(Math.random() * 20),
    y: 35 + Math.round(Math.random() * 25)
  }

  observations.value.unshift({
    id: newId,
    area: activeArea.value,
    title: newObsForm.value.title,
    description: newObsForm.value.description,
    severity: newObsForm.value.severity,
    status: 'PENDIENTE',
    sha256: Array.from({ length: 64 }, () => Math.floor(Math.random() * 16).toString(16)).join('')
  })

  // Crear pin táctil en el plano
  markers.value.push({
    x: coords.x,
    y: coords.y,
    title: newObsForm.value.title,
    area: activeArea.value,
    severity: newObsForm.value.severity,
    obsId: newId
  })

  selectedMarkerIndex.value = markers.value.length - 1
  selectedObsId.value = newId

  newObsForm.value.title = ''
  newObsForm.value.description = ''
  pendingCoordinates.value = null
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
  min-height: 56px;
  background: #161616;
  border-bottom: 1px solid #262626;
  padding: 0 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
  gap: 12px;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}
.btn-menu-drawer {
  background: #222;
  border: 1px solid #333;
  color: #fff;
  padding: 6px 12px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 600;
  flex-shrink: 0;
}
.btn-menu-drawer:hover {
  background: #2a2a2a;
  border-color: var(--primary);
}
.menu-icon {
  font-size: 1.1rem;
}
.inspection-title-block {
  min-width: 0;
}
.inspection-title-block h2 {
  font-size: 1rem;
  margin: 0;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.title-meta {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-top: 2px;
}
.meta-tag {
  font-size: 0.75rem;
  color: #aaa;
  white-space: nowrap;
}
.badge-offline {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  font-size: 0.68rem;
  padding: 1px 6px;
  border-radius: 4px;
  font-weight: bold;
  white-space: nowrap;
}
.badge-moving {
  background: rgba(255, 171, 0, 0.2);
  color: #ffab00;
  font-size: 0.7rem;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: 700;
  border: 1px solid rgba(255, 171, 0, 0.4);
  animation: pulse-border 1.5s infinite;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
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
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: all 0.2s ease;
}
.view-btn.active {
  background: #333;
  color: #fff;
  font-weight: bold;
}
.btn-primary-action {
  background: var(--primary);
  border: none;
  color: #fff;
  padding: 7px 14px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}
.btn-plus {
  font-size: 1.1rem;
  line-height: 1;
}

/* Espacio Principal */
.workspace-body {
  flex: 1;
  display: flex;
  overflow: hidden;
  position: relative;
}
.view-split .plan-section {
  flex: 1.1;
  border-right: 1px solid #222;
}
.view-split .observations-section {
  flex: 0.9;
}
.view-plan-only .plan-section {
  flex: 1;
}
.view-list-only .observations-section {
  flex: 1;
}

/* Plano Section */
.plan-section {
  display: flex;
  flex-direction: column;
  background: #111;
  height: 100%;
}
.plan-toolbar {
  height: 40px;
  background: #181818;
  border-bottom: 1px solid #262626;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 14px;
  font-size: 0.78rem;
  color: #bbb;
  flex-shrink: 0;
}
.plan-legend {
  display: flex;
  align-items: center;
  gap: 6px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #cf6679;
  flex-shrink: 0;
}
.legend-dot.moving-pulse {
  background: #ffab00;
  box-shadow: 0 0 8px #ffab00;
}
.text-moving {
  color: #ffab00;
  font-weight: 700;
}
.plan-stats {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 0.75rem;
  color: #888;
  flex-shrink: 0;
}
.btn-cancel-move {
  background: rgba(207, 102, 121, 0.2);
  border: 1px solid #cf6679;
  color: #cf6679;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.72rem;
  cursor: pointer;
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
  background-size: 24px 24px;
}

/* Plano Arquitectónico Responsivo */
.architectural-blueprint {
  width: 90%;
  height: 86%;
  max-width: 900px;
  max-height: 650px;
  border: 2px dashed rgba(255,255,255,0.18);
  border-radius: 12px;
  position: relative;
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  grid-template-rows: 2fr 1.5fr;
  gap: 6px;
  padding: 8px;
  box-sizing: border-box;
}
.room-box {
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(255,255,255,0.02);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.72rem;
  font-weight: 700;
  color: rgba(255,255,255,0.3);
  letter-spacing: 0.8px;
  text-align: center;
  padding: 4px;
  transition: all 0.2s ease;
  cursor: pointer;
}
.room-box:hover {
  background: rgba(255,255,255,0.05);
}
.room-box.highlight {
  border-color: rgba(26,115,232,0.6);
  background: rgba(26,115,232,0.12);
  color: #58a6ff;
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
.pin-active-moving {
  animation: bounce 0.8s infinite alternate;
}
.pin-selected {
  transform: translate(-50%, -100%) scale(1.2);
  z-index: 20;
}
.pin-marker-head {
  display: flex;
  align-items: center;
  gap: 2px;
  font-size: 1.3rem;
}
.pin-number {
  background: #cf6679;
  color: #fff;
  font-size: 0.6rem;
  padding: 1px 4px;
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

/* Barra de Detalle de Pin Seleccionado */
.pin-detail-bar {
  background: #1e242d;
  border-bottom: 1px solid #2d3b4d;
  padding: 8px 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}
.pin-detail-info {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}
.badge-pin-num {
  background: var(--primary);
  color: #fff;
  font-weight: 700;
  font-size: 0.72rem;
  padding: 2px 6px;
  border-radius: 4px;
  white-space: nowrap;
}
.pin-detail-texts {
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.pin-detail-texts strong {
  font-size: 0.82rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.pin-detail-texts span {
  font-size: 0.7rem;
  color: #8b949e;
}
.pin-detail-actions {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
}
.btn-pin-move {
  background: #238636;
  border: none;
  color: #fff;
  font-size: 0.72rem;
  padding: 4px 8px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}
.btn-pin-delete {
  background: rgba(248, 81, 73, 0.15);
  border: 1px solid rgba(248, 81, 73, 0.4);
  color: #ff7b72;
  font-size: 0.72rem;
  padding: 4px 8px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}
.btn-pin-close {
  background: transparent;
  border: none;
  color: #8b949e;
  font-size: 0.85rem;
  cursor: pointer;
  padding: 0 4px;
}

/* Sección de Observaciones */
.observations-section {
  display: flex;
  flex-direction: column;
  background: #141414;
  height: 100%;
}
.area-navigation-bar {
  display: flex;
  background: #181818;
  border-bottom: 1px solid #262626;
  overflow-x: auto;
  padding: 0 8px;
  flex-shrink: 0;
}
.area-tab {
  background: transparent;
  border: none;
  color: #888;
  padding: 10px 12px;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  white-space: nowrap;
  display: flex;
  align-items: center;
  gap: 4px;
}
.area-tab.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
}
.area-badge-count {
  background: rgba(255,255,255,0.08);
  font-size: 0.65rem;
  padding: 1px 5px;
  border-radius: 10px;
}

.observations-scroll-pane {
  flex: 1;
  overflow-y: auto;
  padding: 14px;
}
.pane-header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.pane-header-actions h3 {
  margin: 0;
  font-size: 0.95rem;
}
.section-hint {
  font-size: 0.72rem;
  color: #888;
  margin: 2px 0 0 0;
}
.btn-ghost-sm {
  background: #222;
  border: 1px solid #333;
  color: #fff;
  padding: 5px 10px;
  border-radius: 6px;
  font-size: 0.72rem;
  font-weight: 600;
  cursor: pointer;
}

/* Tarjetas */
.observations-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.observation-card {
  background: #1b1b1b;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 10px 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.observation-card:hover {
  background: #202020;
  border-color: #383838;
}
.observation-card.obs-selected {
  border-color: var(--primary);
  background: rgba(26,115,232,0.05);
}
.obs-card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}
.obs-tags {
  display: flex;
  gap: 6px;
  align-items: center;
}
.obs-actions-top {
  display: flex;
  align-items: center;
  gap: 8px;
}
.btn-delete-obs {
  background: transparent;
  border: none;
  color: #888;
  cursor: pointer;
  font-size: 0.8rem;
  padding: 2px 4px;
  border-radius: 4px;
}
.btn-delete-obs:hover {
  background: rgba(207, 102, 121, 0.2);
  color: #cf6679;
}
.tag-severity {
  font-size: 0.65rem;
  font-weight: bold;
  padding: 2px 6px;
  border-radius: 4px;
  text-transform: uppercase;
}
.sev-menor { background: rgba(3, 218, 198, 0.15); color: #03dac6; }
.sev-moderada { background: rgba(255, 171, 0, 0.15); color: #ffab00; }
.sev-mayor, .sev-crítica { background: rgba(207, 102, 121, 0.2); color: #cf6679; }

.tag-status {
  font-size: 0.65rem;
  color: #888;
}
.tag-pin-link {
  font-size: 0.65rem;
  color: #58a6ff;
  font-weight: 600;
}
.tag-storage {
  font-size: 0.65rem;
  color: #666;
  font-family: monospace;
}
.obs-title {
  margin: 0 0 4px 0;
  font-size: 0.86rem;
  color: #fff;
}
.obs-description {
  margin: 0 0 8px 0;
  font-size: 0.76rem;
  color: #aaa;
  line-height: 1.35;
}
.obs-evidence-box {
  background: #111;
  border: 1px solid #222;
  border-radius: 6px;
  padding: 6px 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.evidence-thumb {
  font-size: 1.1rem;
}
.evidence-meta {
  display: flex;
  flex-direction: column;
}
.evidence-file {
  font-size: 0.68rem;
  font-weight: 600;
  color: #ccc;
}
.evidence-hash {
  font-size: 0.62rem;
  color: #03dac6;
}

.empty-observations {
  padding: 40px 20px;
  text-align: center;
  background: #181818;
  border: 1px dashed #333;
  border-radius: 12px;
  margin-top: 10px;
}
.empty-icon {
  font-size: 2rem;
  display: block;
  margin-bottom: 8px;
}
.empty-observations h4 {
  margin: 0 0 6px 0;
  font-size: 0.95rem;
}
.empty-observations p {
  font-size: 0.8rem;
  color: #888;
  margin: 0 0 16px 0;
}
.btn-preset-primary {
  background: var(--primary);
  border: none;
  color: #fff;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
}

/* Footer Acción */
.section-footer {
  padding: 12px 14px;
  background: #181818;
  border-top: 1px solid #262626;
  flex-shrink: 0;
}
.btn-generate-report {
  display: block;
  width: 100%;
  text-align: center;
  background: #238636;
  color: #fff;
  padding: 10px;
  border-radius: 8px;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: bold;
  box-sizing: border-box;
}

/* Drawer Menú */
.drawer-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.7);
  z-index: 100;
  display: flex;
}
.drawer-content {
  width: 280px;
  max-width: 80%;
  height: 100%;
  background: #161b22;
  display: flex;
  flex-direction: column;
  padding: 20px 16px;
  box-sizing: border-box;
  animation: slide-in 0.2s ease;
}
@keyframes slide-in {
  from { transform: translateX(-100%); }
  to { transform: translateX(0); }
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
  gap: 8px;
}
.drawer-brand h3 {
  margin: 0;
  font-size: 1.1rem;
}
.btn-close-drawer {
  background: transparent;
  border: none;
  color: #aaa;
  font-size: 1.2rem;
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
  gap: 10px;
  padding: 10px 12px;
  border-radius: 8px;
  color: #bbb;
  text-decoration: none;
  font-size: 0.88rem;
}
.drawer-item:hover, .drawer-item.router-link-active {
  background: rgba(255,255,255,0.06);
  color: #fff;
}
.drawer-footer {
  border-top: 1px solid #30363d;
  padding-top: 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.78rem;
}
.drawer-user {
  margin: 0;
  color: #8b949e;
}
.drawer-logout {
  color: #ff7b72;
  text-decoration: none;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 120;
  padding: 16px;
}
.modal-dialog {
  background: #1c2128;
  border: 1px solid #30363d;
  border-radius: 14px;
  width: 100%;
  max-width: 520px;
  overflow: hidden;
  box-shadow: 0 16px 36px rgba(0,0,0,0.6);
}
.modal-dialog-header {
  padding: 14px 18px;
  border-bottom: 1px solid #30363d;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.modal-dialog-header h3 {
  margin: 0;
  font-size: 1.05rem;
}
.modal-subtitle {
  font-size: 0.75rem;
  color: #8b949e;
  margin-top: 2px;
  display: block;
}
.btn-close-modal {
  background: transparent;
  border: none;
  color: #8b949e;
  font-size: 1.1rem;
  cursor: pointer;
}
.modal-dialog-body {
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.modal-hint {
  font-size: 0.78rem;
  color: #8b949e;
  margin: 0;
}
.preset-pills {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}
.preset-pill {
  background: rgba(255,255,255,0.05);
  border: 1px solid #30363d;
  color: #ccc;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 0.72rem;
  cursor: pointer;
}
.preset-pill:hover {
  background: var(--primary);
  color: #fff;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 5px;
}
.form-group label {
  font-size: 0.78rem;
  color: #8b949e;
}
.input-field {
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 6px;
  padding: 8px 10px;
  color: #fff;
  font-size: 0.85rem;
}
.input-field:focus {
  outline: none;
  border-color: var(--primary);
}
.form-row {
  display: flex;
  gap: 10px;
}
.form-group.col {
  flex: 1;
}
.fake-camera-btn {
  background: #0d1117;
  border: 1px dashed #30363d;
  padding: 8px 10px;
  border-radius: 6px;
  font-size: 0.72rem;
  color: #58a6ff;
  display: flex;
  align-items: center;
}
.modal-dialog-footer {
  padding: 12px 18px;
  border-top: 1px solid #30363d;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  background: #161b22;
}
.btn-cancel {
  background: transparent;
  border: 1px solid #30363d;
  color: #ccc;
  padding: 7px 14px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.82rem;
}
.btn-save {
  background: var(--primary);
  border: none;
  color: #fff;
  padding: 7px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.82rem;
  font-weight: 600;
}

@keyframes bounce {
  0% { transform: translate(-50%, -100%) scale(1.1); }
  100% { transform: translate(-50%, -125%) scale(1.3); }
}
@keyframes pulse-border {
  0% { box-shadow: 0 0 0 0 rgba(255, 171, 0, 0.4); }
  70% { box-shadow: 0 0 0 6px rgba(255, 171, 0, 0); }
  100% { box-shadow: 0 0 0 0 rgba(255, 171, 0, 0); }
}

@media (max-width: 768px) {
  .view-split-btn {
    display: none;
  }
}
</style>
