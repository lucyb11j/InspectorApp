<template>
  <div class="dashboard-page">
    <header class="header">
      <div>
        <h1>Dashboard</h1>
        <p class="subtitle">Welcome back. Today is {{ today }}.</p>
      </div>
    </header>

    <!-- KPI Cards -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">📋</div>
        <h3>Total Inspections</h3>
        <p class="value">{{ stats.total }}</p>
        <span class="trend">All time</span>
      </div>
      <div class="stat-card accent-orange">
        <div class="stat-icon">🔄</div>
        <h3>In Progress</h3>
        <p class="value">{{ stats.in_progress }}</p>
        <span class="trend">Active today</span>
      </div>
      <div class="stat-card accent-green">
        <div class="stat-icon">✅</div>
        <h3>Completed</h3>
        <p class="value">{{ stats.completed }}</p>
        <span class="trend">Awaiting report</span>
      </div>
      <div class="stat-card accent-red">
        <div class="stat-icon">⚠️</div>
        <h3>Open Observations</h3>
        <p class="value">{{ stats.open_obs }}</p>
        <span class="trend">Pending correction</span>
      </div>
    </div>

    <!-- Recent inspections -->
    <section class="recent-section">
      <h2>Recent Inspections</h2>
      <div v-if="pending" class="loading">Loading...</div>
      <div v-else class="recent-list">
        <NuxtLink
          v-for="insp in recent"
          :key="insp.id"
          to="/inspections"
          class="recent-item"
        >
          <div class="recent-info">
            <span class="recent-unit">Unit {{ insp.properties?.unit_number }}</span>
            <span class="recent-project">{{ insp.properties?.projects?.name }}</span>
          </div>
          <span class="status-badge" :class="`status-${insp.status.toLowerCase()}`">
            {{ insp.status }}
          </span>
        </NuxtLink>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const today = new Intl.DateTimeFormat('es-PE', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }).format(new Date())

const { data: inspections, pending } = await useAsyncData('dashboard-inspections', async () => {
  const { data } = await supabase
    .from('inspections')
    .select(`
      id, status, scheduled_at,
      clients(name),
      properties(unit_number, projects(name))
    `)
    .order('created_at', { ascending: false })
  return data ?? []
})

const { data: obsCount } = await useAsyncData('dashboard-obs', async () => {
  const { count } = await supabase
    .from('observations')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'PENDING')
  return count ?? 0
})

const stats = computed(() => ({
  total:       inspections.value?.length ?? 0,
  in_progress: inspections.value?.filter(i => i.status === 'IN_PROGRESS').length ?? 0,
  completed:   inspections.value?.filter(i => i.status === 'COMPLETED').length ?? 0,
  open_obs:    obsCount.value ?? 0,
}))

const recent = computed(() => (inspections.value ?? []).slice(0, 5))
</script>

<style scoped>
.header { margin-bottom: 40px; }
.header h1 { font-size: 2.2rem; margin: 0 0 8px 0; }
.subtitle { color: var(--text-secondary); font-size: 1rem; margin: 0; }

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 48px;
}
.stat-card {
  background: var(--surface-dark);
  padding: 24px;
  border-radius: 16px;
  border: 1px solid var(--border-color);
  border-left: 4px solid var(--primary);
  transition: var(--transition);
  position: relative;
  overflow: hidden;
}
.stat-card::before {
  content: '';
  position: absolute;
  top: 0; right: 0;
  width: 80px; height: 80px;
  background: radial-gradient(circle, rgba(26,115,232,0.08), transparent);
  border-radius: 50%;
}
.stat-card.accent-orange { border-left-color: #ffc107; }
.stat-card.accent-green  { border-left-color: #03dac6; }
.stat-card.accent-red    { border-left-color: var(--error); }
.stat-card:hover { transform: translateY(-4px); box-shadow: 0 12px 30px rgba(0,0,0,0.3); }
.stat-icon { font-size: 1.5rem; margin-bottom: 12px; }
.stat-card h3 {
  color: var(--text-secondary);
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 0 8px 0;
}
.value {
  font-size: 2.8rem;
  font-weight: 700;
  margin: 0 0 8px 0;
  line-height: 1;
}
.trend { font-size: 0.78rem; color: var(--text-secondary); }

.recent-section h2 { font-size: 1.4rem; margin-bottom: 16px; }
.recent-list { display: flex; flex-direction: column; gap: 10px; }
.recent-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--surface-dark);
  padding: 16px 20px;
  border-radius: 12px;
  border: 1px solid var(--border-color);
  text-decoration: none;
  transition: var(--transition);
}
.recent-item:hover { border-color: rgba(255,255,255,0.12); transform: translateX(4px); }
.recent-info { display: flex; flex-direction: column; gap: 3px; }
.recent-unit { font-weight: 600; color: #fff; }
.recent-project { font-size: 0.82rem; color: var(--text-secondary); }
.status-badge {
  padding: 4px 12px; border-radius: 20px;
  font-size: 0.75rem; font-weight: 600; text-transform: uppercase;
}
.status-completed   { background: rgba(3,218,198,0.15);  color: #03dac6; }
.status-in_progress { background: rgba(26,115,232,0.15); color: #4d9eff; }
.status-scheduled   { background: rgba(255,193,7,0.15);  color: #ffc107; }
.status-draft       { background: rgba(160,160,160,0.1); color: #888; }
.loading { color: var(--text-secondary); padding: 20px; }
</style>
