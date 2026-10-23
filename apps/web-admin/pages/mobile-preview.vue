<template>
  <div class="simulator-page">
    <header class="page-header">
      <div>
        <h1>Simulador Móvil (Inspector App - Fase 2)</h1>
        <p class="subtitle">Inspección de departamentos, catálogo de defectos y planos táctiles interactivos</p>
      </div>
      <div class="header-badges">
        <span class="badge-offline">⚡ SQLite Offline-First Activo</span>
      </div>
    </header>

    <div class="simulator-container">
      <!-- Marco de Dispositivo Móvil -->
      <div class="phone-frame">
        <div class="phone-notch"></div>
        <div class="phone-screen">
          <!-- Top Bar Móvil -->
          <div class="mobile-top-bar">
            <span>09:41</span>
            <div class="status-icons">
              <span>📶</span>
              <span>🔋 100%</span>
            </div>
          </div>

          <div class="mobile-header">
            <div class="mobile-title-block">
              <h3>Dpto 305 - Condominio Los Cedros</h3>
              <p class="area-indicator">Área activa: {{ activeArea }}</p>
            </div>
            <span class="badge-sync">OFFLINE</span>
          </div>

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

          <!-- Vista Tab 1: Defectos Registrados en SQLite -->
          <div v-if="activeTab === 'defects'" class="tab-pane defects-pane">
            <div v-if="filteredObservations.length === 0" class="empty-defects">
              <span class="icon-camera">📷</span>
              <p>Sin observaciones en {{ activeArea }}</p>
              <button class="btn-preset" @click="showModal = true">+ Agregar con Plantilla</button>
            </div>

            <div v-else class="defects-list">
              <div v-for="obs in filteredObservations" :key="obs.id" class="defect-card">
                <div class="card-head">
                  <span class="badge-sev" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                  <span class="badge-db">SQLite Local</span>
                </div>
                <h4>{{ obs.title }}</h4>
                <p class="desc">{{ obs.description }}</p>
                <div class="evidence-meta">
                  <span>📸 SHA-256: <code>{{ obs.sha256.substring(0, 10) }}...</code></span>
                </div>
              </div>
            </div>
          </div>

          <!-- Vista Tab 2: Plano Táctil con fijación de pines -->
          <div v-else class="tab-pane plan-pane" @click="addMarker">
            <div class="plan-canvas">
              <div class="blueprint-grid"></div>
              <p class="plan-hint">Toque en cualquier zona del plano para ubicar un defecto</p>
              <!-- Marcadores colocados -->
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

          <!-- Floating Button Agregar Defecto -->
          <button class="btn-fab" @click="showModal = true">
            + Defecto
          </button>
        </div>
      </div>

      <!-- Panel Lateral de Especificaciones Técnicas Fase 2 -->
      <div class="specs-panel">
        <h3>Motor Offline Implementado</h3>
        <p class="specs-desc">
          Esta vista simula en tiempo real la experiencia del inspector en campo mediante la arquitectura
          desarrollada en Flutter / SQLite / Drift.
        </p>

        <div class="spec-item">
          <h4>🗄️ Drift SQLite Local</h4>
          <p>Tablas <code>InspectionsTable</code>, <code>AreasTable</code>, <code>ObservationsTable</code>, <code>EvidenceTable</code> y <code>PropertyPlansTable</code> estructuradas en memoria persistente.</p>
        </div>

        <div class="spec-item">
          <h4>🔐 Integridad Criptográfica Inmutable</h4>
          <p>Toda evidencia fotográfica calcula inmediatamente su firma SHA-256 local y los datos del dispositivo antes de preparar la cola de sincronización (Outbox).</p>
        </div>

        <div class="spec-item">
          <h4>📍 Marcadores Táctiles Normalizados</h4>
          <p>Las ubicaciones en planos se guardan en porcentajes (0.0% a 100.0%), permitiendo renderizado exacto en tablets, teléfonos y reportes PDF finales.</p>
        </div>
      </div>
    </div>

    <!-- Modal Catálogo de Defectos Típicos -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <h3>Biblioteca de Defectos Típicos</h3>
          <button class="btn-close" @click="showModal = false">✕</button>
        </div>
        <p class="modal-sub">Plantillas predefinidas según normas técnicas de acabados</p>
        <div class="preset-list">
          <div
            v-for="preset in presets"
            :key="preset.title"
            class="preset-item"
            @click="selectPreset(preset)"
          >
            <div class="preset-info">
              <h4>{{ preset.title }}</h4>
              <p>{{ preset.category }} · Severidad recomendada: <strong>{{ preset.severity }}</strong></p>
            </div>
            <button class="btn-select">+</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
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
    title: 'Pintura irregular o con variación de tonalidad',
    description: 'Se aprecian desniveles de textura en enlucido de muro norte.',
    severity: 'MENOR',
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  },
  {
    id: '2',
    area: 'Cocina',
    title: 'Junta de cerámico desalineada o hueca',
    description: 'Junta supera 3mm en piso frente al lavadero.',
    severity: 'MODERADA',
    sha256: 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'
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
  { x: 68.2, y: 25.4 }
])

const addMarker = (event: MouseEvent) => {
  const target = event.currentTarget as HTMLElement
  const rect = target.getBoundingClientRect()
  const x = ((event.clientX - rect.left) / rect.width) * 100
  const y = ((event.clientY - rect.top) / rect.height) * 100

  planMarkers.value.push({
    x: Number(x.toFixed(1)),
    y: Number(y.toFixed(1))
  })
}

const presets = [
  {
    title: 'Pintura irregular o con variación de tonalidad',
    severity: 'MENOR',
    category: 'Acabados y Muros',
    description: 'Variación visual evidente de tonalidad sobre la superficie tratada.'
  },
  {
    title: 'Fisura superficial tipo tela de araña',
    severity: 'MENOR',
    category: 'Muros y Tabiquería',
    description: 'Fisura capilar superficial en enlucido sin compromiso estructural.'
  },
  {
    title: 'Junta de porcelanato desalineada o hueca',
    severity: 'MODERADA',
    category: 'Pisos y Revestimientos',
    description: 'Junta excede la tolerancia permitida o presenta sonido hueco.'
  },
  {
    title: 'Ausencia de sellador de silicona en encuentro sanitario',
    severity: 'MODERADA',
    category: 'Instalaciones Sanitarias',
    description: 'Falta cordón fungicida en encuentro entre tina y muro azulejado.'
  },
  {
    title: 'Tomacorriente sin polaridad adecuada o neutro invertido',
    severity: 'MAYOR',
    category: 'Instalaciones Eléctricas',
    description: 'Ausencia de línea a tierra o polaridad invertida en tomacorriente.'
  },
  {
    title: 'Fuga o filtración activa en llave de paso / trampa',
    severity: 'CRÍTICA',
    category: 'Instalaciones Sanitarias',
    description: 'Goteo continuo visible con presión normal de suministro.'
  }
]

const selectPreset = (p: typeof presets[0]) => {
  observations.value.unshift({
    id: Date.now().toString(),
    area: activeArea.value,
    title: p.title,
    description: p.description,
    severity: p.severity,
    sha256: '9f83c605cad048b0e69252baac44e0413756b2a270741444ec4e363161f5ac52'
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
  align-items: flex-start;
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
.badge-offline {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: bold;
}
.simulator-container {
  display: flex;
  gap: 40px;
  align-items: flex-start;
}

/* Phone Frame Mockup */
.phone-frame {
  width: 375px;
  height: 720px;
  background: #000;
  border-radius: 40px;
  border: 4px solid #333;
  box-shadow: 0 25px 60px rgba(0, 0, 0, 0.6);
  padding: 12px;
  position: relative;
  flex-shrink: 0;
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
.phone-screen {
  background: #121212;
  width: 100%;
  height: 100%;
  border-radius: 30px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  position: relative;
}

/* Screen Header */
.mobile-top-bar {
  display: flex;
  justify-content: space-between;
  padding: 10px 18px 4px 18px;
  font-size: 0.75rem;
  color: #aaa;
  font-weight: bold;
}
.mobile-header {
  padding: 10px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #222;
}
.mobile-title-block h3 {
  font-size: 0.85rem;
  margin: 0;
  color: #fff;
}
.area-indicator {
  font-size: 0.7rem;
  color: var(--primary);
  margin: 2px 0 0 0;
}
.badge-sync {
  background: rgba(3, 218, 198, 0.2);
  color: #03dac6;
  font-size: 0.65rem;
  padding: 2px 6px;
  border-radius: 6px;
  font-weight: bold;
}

/* Areas */
.areas-scroller {
  display: flex;
  gap: 6px;
  padding: 8px 12px;
  overflow-x: auto;
  background: #181818;
}
.area-chip {
  background: #252525;
  border: none;
  color: #aaa;
  padding: 4px 10px;
  border-radius: 14px;
  font-size: 0.72rem;
  cursor: pointer;
  white-space: nowrap;
}
.area-chip.active {
  background: var(--primary);
  color: #fff;
  font-weight: bold;
}

/* Mobile Tabs */
.mobile-tabs {
  display: flex;
  border-bottom: 1px solid #222;
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
  padding: 50px 10px;
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

/* Plan */
.plan-pane {
  padding: 0;
  cursor: crosshair;
}
.plan-canvas {
  width: 100%;
  height: 100%;
  background: #141414;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}
.blueprint-grid {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-image: linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
  background-size: 20px 20px;
}
.plan-hint {
  position: absolute;
  top: 12px;
  font-size: 0.68rem;
  color: #777;
  pointer-events: none;
}
.plan-pin {
  position: absolute;
  transform: translate(-50%, -100%);
  font-size: 1.2rem;
  animation: drop 0.2s ease;
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
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(26,115,232,0.4);
  cursor: pointer;
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
  margin-top: 20px;
  background: #141414;
  padding: 16px;
  border-radius: 12px;
  border-left: 3px solid var(--primary);
}
.spec-item h4 {
  margin: 0 0 6px 0;
}
.spec-item p {
  color: var(--text-secondary);
  margin: 0;
  font-size: 0.9rem;
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
  max-width: 500px;
  border-radius: 16px;
  padding: 20px;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.modal-header h3 {
  margin: 0;
  font-size: 1.1rem;
}
.btn-close {
  background: none;
  border: none;
  color: #aaa;
  font-size: 1.2rem;
  cursor: pointer;
}
.modal-sub {
  color: #777;
  font-size: 0.85rem;
  margin: 4px 0 16px 0;
}
.preset-list {
  max-height: 360px;
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
  padding: 10px 14px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.preset-item:hover {
  background: #2c2c2c;
  transform: translateX(4px);
}
.preset-info h4 {
  font-size: 0.85rem;
  margin: 0 0 3px 0;
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
  width: 28px;
  height: 28px;
  border-radius: 50%;
  cursor: pointer;
}
</style>
