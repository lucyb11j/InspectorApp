<template>
  <div class="inspection-detail">

    <!-- Back button + Header -->
    <div class="detail-header">
      <NuxtLink to="/inspections" class="btn-back">← Back to Inspections</NuxtLink>
      <div class="header-row">
        <div>
          <h1>Unit {{ inspection?.properties?.unit_number }} — {{ inspection?.properties?.projects?.name }}</h1>
          <p class="meta">
            Floor {{ inspection?.properties?.floor_number }} · {{ inspection?.properties?.building }}
          </p>
        </div>
        <span class="status-badge large" :class="`status-${inspection?.status?.toLowerCase()}`">
          {{ inspection?.status }}
        </span>
      </div>
    </div>

    <!-- Loading / Error -->
    <div v-if="pending" class="state-msg">Loading inspection...</div>
    <div v-else-if="!inspection" class="state-msg error">Inspection not found.</div>

    <template v-else>

      <!-- Info Cards -->
      <div class="info-grid">
        <div class="info-card">
          <h4>Client</h4>
          <p>{{ inspection.clients?.name ?? '—' }}</p>
        </div>
        <div class="info-card">
          <h4>Inspector</h4>
          <p>{{ inspection.users?.email ?? '—' }}</p>
        </div>
        <div class="info-card">
          <h4>Scheduled</h4>
          <p>{{ formatDate(inspection.scheduled_at) }}</p>
        </div>
        <div class="info-card">
          <h4>Created</h4>
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
          {{ tab }}
          <span v-if="tab === 'Observations'" class="tab-count">{{ observations?.length ?? 0 }}</span>
        </button>
      </div>

      <!-- Tab: Areas -->
      <div v-if="activeTab === 'Areas'" class="tab-content">
        <div v-if="!areas?.length" class="empty-tab">No areas recorded yet.</div>
        <div v-else class="areas-grid">
          <div v-for="area in areas" :key="area.id" class="area-card">
            <div class="area-name">{{ area.name }}</div>
            <div class="area-obs-count">
              {{ obsCountByArea(area.id) }} observation{{ obsCountByArea(area.id) !== 1 ? 's' : '' }}
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Observations -->
      <div v-if="activeTab === 'Observations'" class="tab-content">
        <div v-if="!observations?.length" class="empty-tab">No observations recorded yet.</div>
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

// Fetch main inspection with joins
const { data: inspection, pending } = await useAsyncData(`inspection-${route.params.id}`, async () => {
  const { data } = await supabase
    .from('inspections')
    .select(`
      id, status, scheduled_at, created_at,
      clients(name),
      users(email),
      properties(unit_number, floor_number, building, projects(name))
    `)
    .eq('id', route.params.id as string)
    .single()
  return data
})

// Fetch areas
const { data: areas } = await useAsyncData(`areas-${route.params.id}`, async () => {
  const { data } = await supabase
    .from('inspection_areas')
    .select('id, name')
    .eq('inspection_id', route.params.id as string)
  return data ?? []
})

// Fetch observations
const { data: observations } = await useAsyncData(`obs-${route.params.id}`, async () => {
  const { data } = await supabase
    .from('observations')
    .select('id, area_id, title, description, severity, status')
    .eq('inspection_id', route.params.id as string)
    .order('severity')
  return data ?? []
})

const obsCountByArea = (areaId: string) =>
  (observations.value ?? []).filter(o => o.area_id === areaId).length

const areaName = (areaId: string) =>
  areas.value?.find(a => a.id === areaId)?.name ?? '—'

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
