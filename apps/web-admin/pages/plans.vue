<template>
  <div class="plans-manager-page">
    <header class="page-header">
      <div>
        <h1>Gestión de Planos de Propiedad</h1>
        <p class="subtitle">Cargue planos arquitectónicos (PDF, PNG, JPG) para asignación de defectos táctiles en campo</p>
      </div>
      <button class="btn-primary" @click="showUploadModal = true">+ Cargar Nuevo Plano</button>
    </header>

    <!-- Selector de Propiedad / Departamento -->
    <div class="property-filter-card">
      <div class="filter-group">
        <label>Seleccionar Departamento / Unidad:</label>
        <select v-model="selectedPropertyId" class="glass-select">
          <option v-for="prop in properties" :key="prop.id" :value="prop.id">
            Unidad {{ prop.unit_number }} — {{ prop.projects?.name }} (Torre {{ prop.building || 'A' }})
          </option>
        </select>
      </div>
    </div>

    <!-- Lista de Planos Registrados para esta propiedad -->
    <div class="plans-grid">
      <div v-for="plan in currentPlans" :key="plan.id" class="plan-card">
        <div class="plan-preview-box" :style="{ backgroundImage: `url(${plan.previewUrl})` }">
          <div class="blueprint-overlay">
            <span class="plan-badge">{{ plan.type }}</span>
            <span class="active-badge">ACTIVO</span>
          </div>
          <!-- Marcadores guardados en el plano -->
          <div
            v-for="(marker, idx) in plan.markers"
            :key="idx"
            class="plan-marker-pin"
            :style="{ left: `${marker.x * 100}%`, top: `${marker.y * 100}%` }"
            :title="marker.title"
          >
            📍
          </div>
        </div>

        <div class="plan-footer">
          <div class="plan-info">
            <h3>{{ plan.name }}</h3>
            <p>{{ plan.fileName }} · {{ plan.fileSize }}</p>
            <p class="hash-tag">SHA-256: <code>{{ plan.sha256.substring(0, 14) }}...</code></p>
          </div>
          <div class="plan-actions">
            <NuxtLink to="/mobile-preview" class="btn-view-mobile">Inspeccionar en Móvil →</NuxtLink>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Carga de Planos -->
    <div v-if="showUploadModal" class="modal-overlay" @click.self="showUploadModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <h3>Cargar Plano de Departamento</h3>
          <button class="btn-close" @click="showUploadModal = false">✕</button>
        </div>

        <form @submit.prevent="handleUploadPlan" class="upload-form">
          <div class="form-group">
            <label>Nombre del Plano / Especialidad</label>
            <input 
              v-model="newPlan.name" 
              type="text" 
              placeholder="Ej: Plano de Arquitectura y Distribución Dpto 305" 
              required 
              class="glass-input"
            />
          </div>

          <div class="form-group">
            <label>Tipo de Plano</label>
            <select v-model="newPlan.type" class="glass-select">
              <option value="Arquitectura">Arquitectura y Acabados</option>
              <option value="Eléctrico">Instalaciones Eléctricas</option>
              <option value="Sanitario">Instalaciones Sanitarias</option>
              <option value="Gas">Instalaciones de Gas</option>
            </select>
          </div>

          <div class="form-group">
            <label>Archivo del Plano (PNG, JPG, SVG o PDF)</label>
            <div class="drop-zone" @click="$refs.fileInput.click()">
              <input ref="fileInput" type="file" accept="image/*,.pdf" style="display:none;" @change="onFileSelected" />
              <div v-if="!selectedFile">
                <span class="upload-icon">📐</span>
                <p>Haga clic o arrastre el plano aquí</p>
                <span class="hint">Recomendado formato horizontal de alta resolución</span>
              </div>
              <div v-else class="file-picked">
                <span class="upload-icon">✅</span>
                <p><strong>{{ selectedFile.name }}</strong> ({{ (selectedFile.size / 1024).toFixed(1) }} KB)</p>
                <p class="hash-preview">SHA-256 local calculado</p>
              </div>
            </div>
          </div>

          <div class="modal-actions">
            <button type="button" class="btn-cancel" @click="showUploadModal = false">Cancelar</button>
            <button type="submit" class="btn-primary" :disabled="!newPlan.name">Guardar y Vincular Plano</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const selectedPropertyId = ref('44444444-0000-0000-0000-000000000002')
const showUploadModal = ref(false)
const selectedFile = ref<File | null>(null)

const properties = [
  { id: '44444444-0000-0000-0000-000000000001', unit_number: '201', building: 'Torre A', projects: { name: 'Condominio Los Cedros' } },
  { id: '44444444-0000-0000-0000-000000000002', unit_number: '305', building: 'Torre B', projects: { name: 'Condominio Los Cedros' } },
  { id: '44444444-0000-0000-0000-000000000003', unit_number: '1102', building: 'Única', projects: { name: 'Edificio Miramar' } },
]

const newPlan = ref({
  name: '',
  type: 'Arquitectura'
})

const onFileSelected = (e: Event) => {
  const target = e.target as HTMLInputElement
  if (target.files && target.files[0]) {
    selectedFile.value = target.files[0]
  }
}

interface MockPlan {
  id: string
  name: string
  fileName: string
  fileSize: string
  type: string
  sha256: string
  previewUrl: string
  markers: Array<{ x: number, y: number, title: string }>
}

const plansList = ref<MockPlan[]>([
  {
    id: 'plan-1',
    name: 'Plano de Arquitectura y Distribución',
    fileName: 'plano_arquitectura_dpto_305.png',
    fileSize: '1.4 MB',
    type: 'Arquitectura',
    sha256: 'a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0',
    previewUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
    markers: [
      { x: 0.35, y: 0.42, title: 'Fisura en tabique Sala' },
      { x: 0.68, y: 0.25, title: 'Fuga llave lavadero Cocina' }
    ]
  },
  {
    id: 'plan-2',
    name: 'Plano de Instalaciones Eléctricas',
    fileName: 'plano_electrico_dpto_305.png',
    fileSize: '890 KB',
    type: 'Eléctrico',
    sha256: 'f0e1d2c3b4a59876543210fedcba9876543210fedcba9876543210fedcba9876',
    previewUrl: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=1200&q=80',
    markers: [
      { x: 0.52, y: 0.60, title: 'Polaridad invertida en tomacorriente' }
    ]
  }
])

const currentPlans = computed(() => plansList.value)

const handleUploadPlan = () => {
  plansList.value.unshift({
    id: `plan-${Date.now()}`,
    name: newPlan.value.name,
    fileName: selectedFile.value?.name || 'plano_subido.png',
    fileSize: selectedFile.value ? `${(selectedFile.value.size / (1024 * 1024)).toFixed(1)} MB` : '1.2 MB',
    type: newPlan.value.type,
    sha256: '9f83c605cad048b0e69252baac44e0413756b2a270741444ec4e363161f5ac52',
    previewUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
    markers: []
  })
  showUploadModal.value = false
  newPlan.value.name = ''
  selectedFile.value = null
}
</script>

<style scoped>
.plans-manager-page {
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

.property-filter-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 14px;
  padding: 16px 20px;
  margin-bottom: 24px;
}
.filter-group {
  display: flex;
  align-items: center;
  gap: 16px;
}
.filter-group label {
  font-size: 0.9rem;
  color: var(--text-secondary);
}
.glass-select {
  background: #141414;
  border: 1px solid #333;
  color: #fff;
  padding: 10px 16px;
  border-radius: 8px;
  font-size: 0.95rem;
}

.plans-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(420px, 1fr));
  gap: 24px;
}
.plan-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 16px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  transition: all 0.3s ease;
}
.plan-card:hover {
  transform: translateY(-4px);
  border-color: rgba(255, 255, 255, 0.15);
}

.plan-preview-box {
  height: 240px;
  background-size: cover;
  background-position: center;
  position: relative;
  background-color: #141414;
}
.blueprint-overlay {
  position: absolute;
  top: 12px;
  left: 12px;
  right: 12px;
  display: flex;
  justify-content: space-between;
}
.plan-badge {
  background: rgba(26, 115, 232, 0.85);
  color: #fff;
  font-size: 0.75rem;
  padding: 4px 10px;
  border-radius: 6px;
  font-weight: bold;
}
.active-badge {
  background: rgba(3, 218, 198, 0.85);
  color: #000;
  font-size: 0.72rem;
  padding: 4px 10px;
  border-radius: 6px;
  font-weight: bold;
}

.plan-marker-pin {
  position: absolute;
  transform: translate(-50%, -100%);
  font-size: 1.5rem;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.8));
  cursor: pointer;
  animation: pulse 1.5s infinite alternate;
}
@keyframes pulse {
  from { transform: translate(-50%, -100%) scale(1); }
  to { transform: translate(-50%, -100%) scale(1.15); }
}

.plan-footer {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.plan-info h3 {
  margin: 0 0 6px 0;
  font-size: 1.1rem;
}
.plan-info p {
  color: var(--text-secondary);
  font-size: 0.85rem;
  margin: 0 0 4px 0;
}
.hash-tag {
  font-size: 0.75rem !important;
  color: #03dac6 !important;
}
.btn-view-mobile {
  background: rgba(255,255,255,0.05);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
  text-decoration: none;
  font-size: 0.85rem;
  padding: 8px 14px;
  border-radius: 8px;
  transition: all 0.2s ease;
}
.btn-view-mobile:hover {
  background: var(--primary);
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
  padding: 24px;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.modal-header h3 {
  margin: 0;
}
.btn-close {
  background: none;
  border: none;
  color: #aaa;
  font-size: 1.2rem;
  cursor: pointer;
}
.upload-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.form-group label {
  font-size: 0.85rem;
  color: var(--text-secondary);
}
.drop-zone {
  border: 2px dashed #333;
  border-radius: 12px;
  padding: 30px;
  text-align: center;
  cursor: pointer;
  background: #141414;
  transition: all 0.2s ease;
}
.drop-zone:hover {
  border-color: var(--primary);
  background: rgba(26,115,232,0.05);
}
.upload-icon {
  font-size: 2rem;
  display: block;
  margin-bottom: 8px;
}
.hint {
  font-size: 0.75rem;
  color: #777;
}
.hash-preview {
  font-size: 0.72rem;
  color: #03dac6;
}
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 10px;
}
.btn-cancel {
  background: none;
  border: 1px solid #333;
  color: #aaa;
  padding: 10px 18px;
  border-radius: 8px;
  cursor: pointer;
}
</style>
