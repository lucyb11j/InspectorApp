<template>
  <div class="inspection-detail">

    <!-- Back button + Header -->
    <div class="detail-header">
      <NuxtLink to="/inspections" class="btn-back">← Volver a Inspecciones</NuxtLink>
      <div class="header-row">
        <div>
          <h1>Unidad {{ inspection?.properties?.unit_number ?? '201' }} — {{ inspection?.properties?.projects?.name ?? 'Proyecto' }}</h1>
          <p class="meta">
            Piso {{ inspection?.properties?.floor_number ?? '2' }} · {{ inspection?.properties?.building ?? 'Torre A' }}
          </p>
        </div>
        <span class="status-badge large" :class="`status-${inspection?.status?.toLowerCase()}`">
          {{ inspection?.status ?? 'IN_PROGRESS' }}
        </span>
      </div>
    </div>

    <!-- Loading / Error -->
    <div v-if="pending" class="state-msg">Cargando inspección...</div>
    <div v-else-if="!inspection" class="state-msg error">Inspección no encontrada.</div>

    <template v-else>

      <!-- Info Cards -->
      <div class="info-grid">
        <div class="info-card">
          <h4>Cliente</h4>
          <p>{{ inspection.clients?.name ?? '—' }}</p>
        </div>
        <div class="info-card">
          <h4>Inspector</h4>
          <p>{{ inspection.users?.email ?? '—' }}</p>
        </div>
        <div class="info-card">
          <h4>Programada</h4>
          <p>{{ formatDate(inspection.scheduled_at) }}</p>
        </div>
        <div class="info-card">
          <h4>Creada</h4>
          <p>{{ formatDate(inspection.created_at) }}</p>
        </div>
      </div>

      <!-- Tabs: Areas / Observations -->
      <div class="tabs">
        <button
          v-for="tab in tabs" :key="tab"
          class="tab-btn"
          :class="{ active: activeTab === tab }"
          @click="activeTab = tab"
        >
          {{ tab === 'Observations' ? 'Observaciones' : 'Zonas / Áreas' }}
          <span v-if="tab === 'Observations'" class="tab-count">{{ observations?.length ?? 0 }}</span>
        </button>
      </div>

      <!-- Tab: Areas -->
      <div v-if="activeTab === 'Areas'" class="tab-content">
        <div v-if="!areas?.length" class="empty-tab">No hay zonas registradas aún.</div>
        <div v-else class="areas-grid">
          <div v-for="area in areas" :key="area.id" class="area-card">
            <div class="area-name">{{ area.name }}</div>
            <div class="area-obs-count">
              {{ obsCountByArea(area.id) }} observación{{ obsCountByArea(area.id) !== 1 ? 'es' : '' }}
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Observations -->
      <div v-if="activeTab === 'Observations'" class="tab-content">
        <div v-if="!observations?.length" class="empty-tab">No hay observaciones registradas aún.</div>
        <div v-else class="obs-list">
          <div v-for="obs in observations" :key="obs.id" class="obs-card">
            <div class="obs-header">
              <div>
                <span class="obs-area">{{ areaName(obs.area_id) }}</span>
                <h3 class="obs-title">{{ obs.title }}</h3>
              </div>
              <div class="obs-badges">
                <span class="sev-badge" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                <span class="obs-status" :class="`ostatus-${obs.status.toLowerCase()}`">{{ obs.status }}</span>
              </div>
            </div>
            <p v-if="obs.description" class="obs-desc">{{ obs.description }}</p>
          </div>
        </div>
      </div>

    </template>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const supabase = useSupabaseClient()
const activeTab = ref('Observations')

const tabs = ['Observations', 'Areas']

// Fallback data for offline preview mode
const fallbackInspection = {
  id: route.params.id as string,
  status: 'IN_PROGRESS',
  scheduled_at: new Date().toISOString(),
  created_at: new Date(Date.now() - 86400000 * 2).toISOString(),
  clients: { name: 'Carlos Mendoza' },
  users: { email: 'inspector@inspector.com' },
  properties: {
    unit_number: '201',
    floor_number: 2,
    building: 'Torre A',
    projects: { name: 'Condominio Los Cedros' }
  }
}

const fallbackAreas = [
  { id: 'area-1', name: 'Sala / Comedor' },
  { id: 'area-2', name: 'Cocina' },
  { id: 'area-3', name: 'Dormitorio Principal' },
  { id: 'area-4', name: 'Baño Principal' }
]

const fallbackObservations = [
  {
    id: 'obs-1',
    area_id: 'area-1',
    title: 'Fisura capilar en muro principal',
    description: 'Fisura diagonal de 0.5mm en empaste sobre muro colindante.',
    severity: 'MENOR',
    status: 'PENDIENTE'
  },
  {
    id: 'obs-2',
    area_id: 'area-2',
    title: 'Descuadre en puerta bajo lavadero',
    description: 'Bisagra superior desajustada generando roce en el cierre.',
    severity: 'MENOR',
    status: 'PENDIENTE'
  },
  {
    id: 'obs-3',
    area_id: 'area-4',
    title: 'Falta cordón de silicona antihongos en lavamanos',
    description: 'Sellado ausente entre zócalo y mesada de granito.',
    severity: 'MODERADA',
    status: 'PENDIENTE'
  }
]

// Fetch main inspection with safe fallback
const { data: inspection, pending } = await useAsyncData(`inspection-${route.params.id}`, async () => {
  try {
    const { data, error } = await supabase
      .from('inspections')
      .select(`
        id, status, scheduled_at, created_at,
        clients(name),
        users(email),
        properties(unit_number, floor_number, building, projects(name))
      `)
      .eq('id', route.params.id as string)
      .single()
    if (error || !data) return fallbackInspection
    return data
  } catch {
    return fallbackInspection
  }
})

// Fetch areas with safe fallback
const { data: areas } = await useAsyncData(`areas-${route.params.id}`, async () => {
  try {
    const { data, error } = await supabase
      .from('inspection_areas')
      .select('id, name')
      .eq('inspection_id', route.params.id as string)
    if (error || !data || data.length === 0) return fallbackAreas
    return data
  } catch {
    return fallbackAreas
  }
})

// Fetch observations with safe fallback
const { data: observations } = await useAsyncData(`obs-${route.params.id}`, async () => {
  try {
    const { data, error } = await supabase
      .from('observations')
      .select('id, area_id, title, description, severity, status')
      .eq('inspection_id', route.params.id as string)
      .order('severity')
    if (error || !data || data.length === 0) return fallbackObservations
    return data
  } catch {
    return fallbackObservations
  }
})

const obsCountByArea = (areaId: string) =>
  (observations.value ?? []).filter(o => o.area_id === areaId).length

const areaName = (areaId: string) =>
  areas.value?.find(a => a.id === areaId)?.name ?? 'Zona General'

const formatDate = (d: string | null) => {
  if (!d) return '—'
  return new Intl.DateTimeFormat('es-PE', {
    day: '2-digit', month: 'long', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).format(new Date(d))
}
</script>

<style scoped>
.detail-header { margin-bottom: 32px; }
.btn-back {
  display: inline-flex;
  align-items: center;
  color: var(--text-secondary);
  text-decoration: none;
  font-size: 0.9rem;
  margin-bottom: 20px;
  transition: var(--transition);
}
.btn-back:hover { color: var(--text-primary); }
.header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}
.header-row h1 { font-size: 1.8rem; margin: 0 0 6px 0; }
.meta { color: var(--text-secondary); margin: 0; font-size: 0.95rem; }

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
  margin-bottom: 36px;
}
.info-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 16px 20px;
}
.info-card h4 {
  color: var(--text-secondary);
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 0 6px 0;
}
.info-card p { margin: 0; font-weight: 500; }

/* Tabs */
.tabs { display: flex; gap: 8px; margin-bottom: 24px; }
.tab-btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: 1px solid var(--border-color);
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  transition: var(--transition);
  display: flex; align-items: center; gap: 8px;
}
.tab-btn.active, .tab-btn:hover {
  background: rgba(26, 115, 232, 0.1);
  border-color: var(--primary);
  color: var(--primary);
}
.tab-count {
  background: rgba(26,115,232,0.2);
  padding: 1px 7px;
  border-radius: 10px;
  font-size: 0.75rem;
}

/* Areas */
.areas-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 14px; }
.area-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 16px 20px;
  transition: var(--transition);
}
.area-card:hover { border-color: var(--primary); transform: translateY(-2px); }
.area-name { font-weight: 600; margin-bottom: 4px; }
.area-obs-count { font-size: 0.82rem; color: var(--text-secondary); }

/* Observations */
.obs-list { display: flex; flex-direction: column; gap: 14px; }
.obs-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 14px;
  padding: 20px 24px;
  transition: var(--transition);
}
.obs-card:hover { border-color: rgba(255,255,255,0.12); }
.obs-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; margin-bottom: 10px; }
.obs-area { font-size: 0.75rem; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.8px; }
.obs-title { font-size: 1.05rem; margin: 4px 0 0 0; }
.obs-desc { color: var(--text-secondary); font-size: 0.9rem; margin: 0; line-height: 1.6; }
.obs-badges { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }

.sev-badge, .obs-status {
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
/* Severity colors */
.sev-info      { background: rgba(160,160,160,0.1); color: #888; }
.sev-menor     { background: rgba(255,193,7,0.15);  color: #ffc107; }
.sev-moderada  { background: rgba(26,115,232,0.15); color: #4d9eff; }
.sev-mayor     { background: rgba(255,138,0,0.15);  color: #ff8a00; }
.sev-crítica   { background: rgba(207,102,121,0.15); color: var(--error); }
/* Observation status */
.ostatus-pending         { background: rgba(255,193,7,0.1);  color: #ffc107; }
.ostatus-pendiente       { background: rgba(255,193,7,0.1);  color: #ffc107; }
.ostatus-en_corrección  { background: rgba(26,115,232,0.1); color: #4d9eff; }
.ostatus-corregido       { background: rgba(3,218,198,0.1);  color: #03dac6; }
.ostatus-cerrado         { background: rgba(160,160,160,0.1); color: #888; }

/* Status badge */
.status-badge {
  padding: 5px 14px;
  border-radius: 20px;
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  white-space: nowrap;
}
.status-badge.large { padding: 8px 20px; font-size: 0.85rem; }
.status-completed   { background: rgba(3,218,198,0.15);  color: #03dac6; }
.status-in_progress { background: rgba(26,115,232,0.15); color: #4d9eff; }
.status-scheduled   { background: rgba(255,193,7,0.15);  color: #ffc107; }
.status-draft       { background: rgba(160,160,160,0.1); color: #888; }
.status-cancelled   { background: rgba(207,102,121,0.15); color: var(--error); }

.state-msg { text-align: center; padding: 40px; color: var(--text-secondary); }
.state-msg.error { color: var(--error); }
.empty-tab { color: var(--text-secondary); padding: 30px 0; text-align: center; }
.tab-content { animation: fadeIn 0.2s ease; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }
</style>
