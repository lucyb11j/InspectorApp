<template>
  <div class="simulator-page">
    <header class="page-header">
      <div>
        <h1>Simulador de Campo (Inspector App - Fase 2)</h1>
        <p class="subtitle">Herramienta táctil para arquitectos e ingenieros en obra · Teléfono y Tablet</p>
      </div>
      <div class="header-controls">
        <!-- Switch de Dispositivo: Móvil vs Tablet -->
        <div class="device-switcher">
          <button
            class="switch-btn"
            :class="{ active: deviceMode === 'mobile' }"
            @click="deviceMode = 'mobile'"
          >
            📱 Móvil (375px)
          </button>
          <button
            class="switch-btn"
            :class="{ active: deviceMode === 'tablet' }"
            @click="deviceMode = 'tablet'"
          >
            💻 Tablet (820px Split-View)
          </button>
        </div>
        <span class="badge-offline">⚡ SQLite Offline-First Activo</span>
      </div>
    </header>

    <div class="simulator-container" :class="`mode-${deviceMode}`">
      <!-- Marco de Dispositivo Adaptable -->
      <div class="device-frame" :class="deviceMode">
        <div v-if="deviceMode === 'mobile'" class="phone-notch"></div>
        <div class="device-screen">
          <!-- Top Bar -->
          <div class="device-top-bar">
            <span>09:41 · {{ deviceMode === 'tablet' ? 'iPad Pro 11"' : 'iPhone 15' }}</span>
            <div class="status-icons">
              <span class="badge-tag">{{ deviceMode === 'tablet' ? 'MODO TABLET' : 'MODO MÓVIL' }}</span>
              <span>📶 Offline</span>
              <span>🔋 100%</span>
            </div>
          </div>

          <div class="mobile-header">
            <div class="mobile-title-block">
              <h3>Dpto 305 - Condominio Los Cedros</h3>
              <p class="area-indicator">Zona activa: {{ activeArea }}</p>
            </div>
            <span class="badge-sync">SQLITE LOCAL</span>
          </div>

          <!-- MODO TELÉFONO: Selector de ambientes + Tabs -->
          <template v-if="deviceMode === 'mobile'">
            <!-- Selector de Ambientes / Áreas -->
            <div class="areas-scroller">
              <button
                v-for="area in areas"
                :key="area"
                class="area-chip"
                :class="{ active: activeArea === area }"
                @click="activeArea = area"
              >
                {{ area }}
              </button>
            </div>

            <!-- Tabs Móvil: Lista de Defectos vs Plano Interactivo -->
            <div class="mobile-tabs">
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'defects' }"
                @click="activeTab = 'defects'"
              >
                📋 Defectos ({{ filteredObservations.length }})
              </button>
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'plan' }"
                @click="activeTab = 'plan'"
              >
                📐 Plano Táctil ({{ planMarkers.length }})
              </button>
            </div>

            <!-- Vista Tab 1 Móvil: Defectos -->
            <div v-if="activeTab === 'defects'" class="tab-pane defects-pane">
              <div v-if="filteredObservations.length === 0" class="empty-defects">
                <span class="icon-camera">📷</span>
                <p>Sin observaciones en {{ activeArea }}</p>
                <button class="btn-preset" @click="showModal = true">+ Agregar con Catálogo</button>
              </div>

              <div v-else class="defects-list">
                <div v-for="obs in filteredObservations" :key="obs.id" class="defect-card">
                  <div class="card-head">
                    <span class="badge-sev" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                    <span class="badge-db">Drift Local</span>
                  </div>
                  <h4>{{ obs.title }}</h4>
                  <p class="desc">{{ obs.description }}</p>
                  <div class="evidence-meta">
                    <span>📸 SHA-256: <code>{{ obs.sha256.substring(0, 12) }}...</code></span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Vista Tab 2 Móvil: Plano Táctil -->
            <div v-else class="tab-pane plan-pane" @click="addMarker">
              <div class="plan-canvas">
                <div class="blueprint-grid"></div>
                <p class="plan-hint">Toque en cualquier zona del plano para fijar el pin</p>
                <div
                  v-for="(marker, idx) in planMarkers"
                  :key="idx"
                  class="plan-pin"
                  :style="{ left: `${marker.x}%`, top: `${marker.y}%` }"
                >
                  📍
                </div>
              </div>
            </div>
          </template>

          <!-- MODO TABLET: SPLIT-VIEW (Plano interactivo 60% + Lista de Defectos 40%) -->
          <template v-else>
            <div class="tablet-split-layout">
              <!-- Panel Izquierdo: Plano Panorámico Grande -->
              <div class="tablet-plan-side" @click="addMarker">
                <div class="plan-canvas">
                  <div class="blueprint-grid"></div>
                  <div class="tablet-plan-overlay">
                    <span class="plan-badge">PLANO ARQUITECTÓNICO DPTO 305</span>
                    <p class="plan-hint">Haga clic en cualquier punto del plano para ubicar la no-conformidad</p>
                  </div>
                  <div
                    v-for="(marker, idx) in planMarkers"
                    :key="idx"
                    class="plan-pin tablet-pin"
                    :style="{ left: `${marker.x}%`, top: `${marker.y}%` }"
                  >
                    📍 <span class="pin-tag">#{{ idx + 1 }}</span>
                  </div>
                </div>
              </div>

              <!-- Panel Derecho: Selector de Áreas + Lista de Defectos -->
              <div class="tablet-list-side">
                <div class="areas-scroller">
                  <button
                    v-for="area in areas"
                    :key="area"
                    class="area-chip"
                    :class="{ active: activeArea === area }"
                    @click="activeArea = area"
                  >
                    {{ area }}
                  </button>
                </div>

                <div class="defects-pane">
                  <div class="pane-subhead">
                    <span>Observaciones en {{ activeArea }} ({{ filteredObservations.length }})</span>
                    <button class="btn-preset-mini" @click="showModal = true">+ Catálogo</button>
                  </div>

                  <div v-if="filteredObservations.length === 0" class="empty-defects">
                    <span class="icon-camera">📷</span>
                    <p>No hay fallas reportadas en {{ activeArea }}</p>
                  </div>

                  <div v-else class="defects-list">
                    <div v-for="obs in filteredObservations" :key="obs.id" class="defect-card">
                      <div class="card-head">
                        <span class="badge-sev" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                        <span class="badge-db">Verificado</span>
                      </div>
                      <h4>{{ obs.title }}</h4>
                      <p class="desc">{{ obs.description }}</p>
                      <div class="evidence-meta">
                        <span>📸 Evidencia Hash: <code>{{ obs.sha256.substring(0, 12) }}...</code></span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>

          <!-- Floating Button Agregar Defecto -->
          <button class="btn-fab" @click="showModal = true">
            + Defecto Rápido
          </button>
        </div>
      </div>

      <!-- Panel Lateral de Especificaciones Técnicas Fase 2 -->
      <div class="specs-panel">
        <h3>Arquitectura Multi-Formato (Mobile & Tablet)</h3>
        <p class="specs-desc">
          El motor de campo ha sido diseñado para maximizar la productividad de ingenieros y arquitectos en obra:
        </p>

        <div class="spec-item">
          <h4>📱 Formato Smartphone (375px)</h4>
          <p>Operación ágil con una mano para recorridos rápidos, captura inmediata con cámara y navegación por pestañas.</p>
        </div>

        <div class="spec-item highlight">
          <h4>💻 Formato Tablet Split-View (720px - 1024px)</h4>
          <p>Doble panel panorámico simultáneo: plano arquitectónico a la izquierda para marcación táctil de alta precisión y lista de defectos a la derecha.</p>
        </div>

        <div class="spec-item">
          <h4>🗄️ SQLite Offline-First (Drift)</h4>
          <p>Toda información, foto y coordenada se almacena localmente de inmediato con hashes SHA-256 inmutables para sincronización transparente.</p>
        </div>

        <div class="quick-actions">
          <NuxtLink to="/inspections/55555555-0000-0000-0000-000000000001" class="btn-secondary">
            Ver Detalle de Inspección →
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- Modal Catálogo Rápido de No-Conformidades -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <h3>Catálogo Rápido de Defectos Frecuentes</h3>
          <button class="btn-close" @click="showModal = false">✕</button>
        </div>
        <p class="modal-sub">Seleccione un defecto predefinido para agregarlo en 1 solo toque a SQLite:</p>
        <div class="preset-list">
          <div
            v-for="preset in presetDefects"
            :key="preset.id"
            class="preset-item"
            @click="addPresetObservation(preset)"
          >
            <div class="preset-info">
              <span class="badge-sev" :class="`sev-${preset.severity.toLowerCase()}`">{{ preset.severity }}</span>
              <h4>{{ preset.title }}</h4>
              <p>{{ preset.desc }}</p>
            </div>
            <button class="btn-select">+</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const deviceMode = ref<'mobile' | 'tablet'>('tablet')
const activeArea = ref('Sala / Comedor')
const activeTab = ref<'defects' | 'plan'>('defects')
const showModal = ref(false)

const areas = ['Sala / Comedor', 'Cocina', 'Dormitorio Principal', 'Baño Principal', 'Balcón']

interface MockObs {
  id: string
  area: string
  title: string
  description: string
  severity: string
  sha256: string
}

const observations = ref<MockObs[]>([
  {
    id: '1',
    area: 'Sala / Comedor',
    title: 'Fisura capilar en enlucido de muro norte',
    description: 'Fisura superficial de 0.4mm sobre tabique contiguo a ventana.',
    severity: 'MENOR',
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  },
  {
    id: '2',
    area: 'Cocina',
    title: 'Junta de cerámico desalineada o hueca',
    description: 'Junta supera 3mm en piso frente al lavadero de granito.',
    severity: 'MODERADA',
    sha256: 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'
  },
  {
    id: '3',
    area: 'Baño Principal',
    title: 'Sellado deficiente de silicona en lavamanos',
    description: 'Falta cordón antihongos perimetral entre zócalo y mesada.',
    severity: 'MODERADA',
    sha256: '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a'
  }
])

const filteredObservations = computed(() => {
  return observations.value.filter(o => o.area === activeArea.value)
})

interface PlanMarker {
  x: number
  y: number
}

const planMarkers = ref<PlanMarker[]>([
  { x: 35.5, y: 42.0 },
  { x: 62.0, y: 28.5 },
  { x: 78.0, y: 65.0 }
])

const addMarker = (event: MouseEvent) => {
  const rect = (event.currentTarget as HTMLElement).getBoundingClientRect()
  const x = Math.round(((event.clientX - rect.left) / rect.width) * 1000) / 10
  const y = Math.round(((event.clientY - rect.top) / rect.height) * 1000) / 10
  planMarkers.value.push({ x, y })
}

const presetDefects = [
  { id: 'p1', title: 'Fisura en muro o cielo raso', desc: 'Fisura superficial por retracción o empaste.', severity: 'MENOR' },
  { id: 'p2', title: 'Descuadre en marco de puerta', desc: 'Holgura excesiva o roce en pestillo.', severity: 'MODERADA' },
  { id: 'p3', title: 'Pieza cerámica despicada o hueca', desc: 'Acabado dañado o falta de adherencia.', severity: 'MODERADA' },
  { id: 'p4', title: 'Sellado ausente de silicona', desc: 'Ausencia de sello sanitario en mesada o ducha.', severity: 'MENOR' },
  { id: 'p5', title: 'Variación de tonalidad en pintura', desc: 'Empalmes visibles o manchas en superficie.', severity: 'MENOR' },
  { id: 'p6', title: 'Filtro o fuga en grifería', desc: 'Goteo en llave de paso o flexible sanitario.', severity: 'MAYOR' }
]

const addPresetObservation = (preset: typeof presetDefects[0]) => {
  observations.value.unshift({
    id: Date.now().toString(),
    area: activeArea.value,
    title: preset.title,
    description: preset.desc,
    severity: preset.severity,
    sha256: Array.from({ length: 64 }, () => Math.floor(Math.random() * 16).toString(16)).join('')
  })
  showModal.value = false
}
</script>

<style scoped>
.simulator-page {
  padding-bottom: 40px;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 2rem;
  margin: 0 0 6px 0;
}
.subtitle {
  color: var(--text-secondary);
  margin: 0;
}
.header-controls {
  display: flex;
  align-items: center;
  gap: 14px;
}
.device-switcher {
  display: flex;
  background: var(--surface-dark);
  padding: 4px;
  border-radius: 12px;
  border: 1px solid var(--border-color);
  gap: 4px;
}
.switch-btn {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
}
.switch-btn.active {
  background: var(--primary);
  color: #fff;
}
.badge-offline {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
}

/* Container */
.simulator-container {
  display: flex;
  gap: 32px;
  align-items: flex-start;
  transition: all 0.3s ease;
}

/* Device Frame */
.device-frame {
  background: #000;
  border-radius: 40px;
  border: 4px solid #333;
  box-shadow: 0 25px 60px rgba(0, 0, 0, 0.6);
  padding: 12px;
  position: relative;
  flex-shrink: 0;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}
.device-frame.mobile {
  width: 375px;
  height: 720px;
}
.device-frame.tablet {
  width: 820px;
  height: 600px;
  border-radius: 28px;
}
.phone-notch {
  width: 140px;
  height: 20px;
  background: #111;
  position: absolute;
  top: 12px;
  left: 50%;
  transform: translateX(-50%);
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
  z-index: 10;
}
.device-screen {
  background: #121212;
  width: 100%;
  height: 100%;
  border-radius: 30px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  position: relative;
}
.device-frame.tablet .device-screen {
  border-radius: 20px;
}

/* Top bar */
.device-top-bar {
  display: flex;
  justify-content: space-between;
  padding: 10px 16px;
  font-size: 0.72rem;
  color: #888;
  border-bottom: 1px solid #1f1f1f;
}
.badge-tag {
  background: rgba(26, 115, 232, 0.2);
  color: var(--primary);
  padding: 1px 6px;
  border-radius: 4px;
  font-size: 0.65rem;
  font-weight: bold;
}
.status-icons {
  display: flex;
  gap: 8px;
  align-items: center;
}

/* Header */
.mobile-header {
  padding: 12px 16px;
  background: #1a1a1a;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #262626;
}
.mobile-title-block h3 {
  font-size: 0.88rem;
  margin: 0;
  color: #fff;
}
.area-indicator {
  font-size: 0.72rem;
  color: #aaa;
  margin: 2px 0 0 0;
}
.badge-sync {
  font-size: 0.65rem;
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: bold;
}

/* Scroller de Áreas */
.areas-scroller {
  display: flex;
  gap: 6px;
  padding: 8px 12px;
  overflow-x: auto;
  background: #161616;
  border-bottom: 1px solid #222;
}
.area-chip {
  background: #242424;
  border: 1px solid #333;
  color: #aaa;
  padding: 4px 10px;
  border-radius: 14px;
  font-size: 0.72rem;
  white-space: nowrap;
  cursor: pointer;
  transition: all 0.2s ease;
}
.area-chip.active {
  background: var(--primary);
  color: #fff;
  border-color: var(--primary);
}

/* Tabs Móvil */
.mobile-tabs {
  display: flex;
  background: #1a1a1a;
  border-bottom: 1px solid #262626;
}
.mobile-tabs .tab-btn {
  flex: 1;
  padding: 8px 0;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  color: #888;
  font-size: 0.75rem;
  cursor: pointer;
}
.mobile-tabs .tab-btn.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
  font-weight: bold;
}

/* Panes */
.tab-pane {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  position: relative;
}
.empty-defects {
  text-align: center;
  padding: 40px 10px;
  color: #777;
}
.icon-camera {
  font-size: 2rem;
  display: block;
  margin-bottom: 8px;
}
.btn-preset {
  background: var(--primary);
  border: none;
  color: #fff;
  padding: 6px 14px;
  border-radius: 8px;
  font-size: 0.75rem;
  margin-top: 10px;
  cursor: pointer;
}

.defect-card {
  background: #1e1e1e;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  padding: 10px;
  margin-bottom: 8px;
}
.card-head {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}
.badge-sev {
  font-size: 0.65rem;
  font-weight: bold;
  padding: 2px 6px;
  border-radius: 6px;
}
.sev-menor { background: rgba(255,193,7,0.15); color: #ffc107; }
.sev-moderada { background: rgba(26,115,232,0.15); color: #4d9eff; }
.sev-mayor { background: rgba(255,138,0,0.15); color: #ff8a00; }
.sev-crítica { background: rgba(207,102,121,0.15); color: var(--error); }
.badge-db {
  font-size: 0.6rem;
  color: #777;
}
.defect-card h4 {
  font-size: 0.82rem;
  margin: 0 0 4px 0;
  color: #fff;
}
.defect-card .desc {
  font-size: 0.72rem;
  color: #aaa;
  margin: 0 0 6px 0;
}
.evidence-meta {
  font-size: 0.65rem;
  color: #03dac6;
}

/* Tablet Split Layout */
.tablet-split-layout {
  display: flex;
  flex: 1;
  overflow: hidden;
}
.tablet-plan-side {
  flex: 6;
  border-right: 1.5px solid #2a2a2a;
  position: relative;
  cursor: crosshair;
}
.tablet-list-side {
  flex: 4;
  display: flex;
  flex-direction: column;
  background: #141414;
}
.tablet-list-side .defects-pane {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
}
.pane-subhead {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.75rem;
  color: #aaa;
  margin-bottom: 10px;
}
.btn-preset-mini {
  background: var(--primary);
  border: none;
  color: #fff;
  padding: 3px 8px;
  border-radius: 6px;
  font-size: 0.7rem;
  cursor: pointer;
}

/* Plan Canvas */
.plan-pane {
  padding: 0;
  cursor: crosshair;
}
.plan-canvas {
  width: 100%;
  height: 100%;
  background: #101010;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}
.blueprint-grid {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-image: linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px);
  background-size: 24px 24px;
}
.tablet-plan-overlay {
  position: absolute;
  top: 14px;
  left: 14px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  pointer-events: none;
}
.plan-badge {
  background: rgba(255,255,255,0.08);
  color: #ddd;
  font-size: 0.7rem;
  padding: 3px 8px;
  border-radius: 4px;
  font-weight: 600;
  width: fit-content;
}
.plan-hint {
  font-size: 0.72rem;
  color: #777;
  margin: 0;
  pointer-events: none;
}
.plan-pin {
  position: absolute;
  transform: translate(-50%, -100%);
  font-size: 1.3rem;
  animation: drop 0.2s ease;
}
.tablet-pin {
  font-size: 1.5rem;
}
.pin-tag {
  background: #cf6679;
  color: #fff;
  font-size: 0.6rem;
  padding: 1px 4px;
  border-radius: 4px;
  font-weight: bold;
  vertical-align: middle;
}

@keyframes drop {
  from { transform: translate(-50%, -150%); opacity: 0; }
  to { transform: translate(-50%, -100%); opacity: 1; }
}

.btn-fab {
  position: absolute;
  bottom: 20px;
  right: 20px;
  background: var(--primary);
  color: #fff;
  border: none;
  padding: 9px 18px;
  border-radius: 20px;
  font-size: 0.78rem;
  font-weight: bold;
  box-shadow: 0 4px 14px rgba(26,115,232,0.45);
  cursor: pointer;
  z-index: 20;
}

/* Specs Panel */
.specs-panel {
  flex: 1;
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 20px;
  padding: 24px;
}
.specs-panel h3 {
  font-size: 1.3rem;
  margin-top: 0;
}
.specs-desc {
  color: var(--text-secondary);
  line-height: 1.6;
}
.spec-item {
  margin-top: 16px;
  background: #141414;
  padding: 14px 16px;
  border-radius: 12px;
  border-left: 3px solid #444;
}
.spec-item.highlight {
  border-left-color: #03dac6;
  background: rgba(3, 218, 198, 0.04);
}
.spec-item h4 {
  margin: 0 0 6px 0;
  font-size: 0.95rem;
}
.spec-item p {
  color: var(--text-secondary);
  margin: 0;
  font-size: 0.85rem;
  line-height: 1.5;
}
.quick-actions {
  margin-top: 24px;
}
.btn-secondary {
  display: inline-block;
  background: rgba(255,255,255,0.06);
  border: 1px solid var(--border-color);
  color: #fff;
  padding: 8px 16px;
  border-radius: 8px;
  text-decoration: none;
  font-size: 0.85rem;
  transition: var(--transition);
}
.btn-secondary:hover {
  background: rgba(255,255,255,0.12);
  border-color: var(--primary);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.7);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
}
.modal-card {
  background: #1e1e1e;
  border: 1px solid #333;
  width: 90%;
  max-width: 520px;
  border-radius: 16px;
  padding: 22px;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.modal-header h3 {
  margin: 0;
  font-size: 1.15rem;
}
.btn-close {
  background: none;
  border: none;
  color: #aaa;
  font-size: 1.3rem;
  cursor: pointer;
}
.modal-sub {
  color: #777;
  font-size: 0.85rem;
  margin: 4px 0 16px 0;
}
.preset-list {
  max-height: 380px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.preset-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #252525;
  padding: 12px 14px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.preset-item:hover {
  background: #2c2c2c;
  transform: translateX(4px);
}
.preset-info h4 {
  font-size: 0.88rem;
  margin: 4px 0 3px 0;
}
.preset-info p {
  font-size: 0.75rem;
  color: #aaa;
  margin: 0;
}
.btn-select {
  background: var(--primary);
  color: #fff;
  border: none;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  font-size: 1.1rem;
  cursor: pointer;
}
</style>
