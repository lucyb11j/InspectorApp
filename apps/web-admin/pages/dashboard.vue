<template>
  <div class="dashboard-page">
    <header class="header">
      <div>
        <h1>Dashboard</h1>
        <p class="subtitle">Bienvenido al Panel de Inspección Técnica. Hoy es {{ today }}.</p>
      </div>
      <div class="quick-status">
        <span class="badge-role">ORGANIZACIÓN: INSPECOS</span>
      </div>
    </header>

    <!-- KPI Cards -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">📋</div>
        <h3>Total Inspecciones</h3>
        <p class="value">{{ stats.total }}</p>
        <span class="trend">Histórico de proyectos</span>
      </div>
      <div class="stat-card accent-orange">
        <div class="stat-icon">🔄</div>
        <h3>En Progreso</h3>
        <p class="value">{{ stats.in_progress }}</p>
        <span class="trend">Activas en campo</span>
      </div>
      <div class="stat-card accent-green">
        <div class="stat-icon">✅</div>
        <h3>Completadas</h3>
        <p class="value">{{ stats.completed }}</p>
        <span class="trend">Listas para informe</span>
      </div>
      <div class="stat-card accent-red">
        <div class="stat-icon">⚠️</div>
        <h3>Observaciones Abiertas</h3>
        <p class="value">{{ stats.open_obs }}</p>
        <span class="trend">Pendientes de subsanación</span>
      </div>
    </div>

    <!-- Quick Navigation Banner -->
    <div class="banner-quick-links">
      <NuxtLink to="/mobile-preview" class="quick-link-box">
        <span class="q-icon">📱</span>
        <div>
          <h4>Inspector de Campo</h4>
          <p>Herramienta técnica de marcación sobre planos y catálogo de defectos</p>
        </div>
        <span class="q-arrow">→</span>
      </NuxtLink>
      <NuxtLink to="/plans" class="quick-link-box">
        <span class="q-icon">📐</span>
        <div>
          <h4>Gestor de Planos de Propiedad</h4>
          <p>Cargue planimetría y visualice pines de no-conformidades</p>
        </div>
        <span class="q-arrow">→</span>
      </NuxtLink>
      <NuxtLink to="/sync-monitor" class="quick-link-box">
        <span class="q-icon">⚡</span>
        <div>
          <h4>Supervisión de Sincronización</h4>
          <p>Monitoree la cola Outbox y la integridad de hashes SHA-256</p>
        </div>
        <span class="q-arrow">→</span>
      </NuxtLink>
    </div>

    <!-- Recent inspections -->
    <section class="recent-section">
      <div class="section-head">
        <h2>Inspecciones Recientes</h2>
        <NuxtLink to="/inspections" class="view-all-link">Ver todas las inspecciones →</NuxtLink>
      </div>
      <div class="recent-list">
        <NuxtLink
          v-for="insp in recentList"
          :key="insp.id"
          :to="`/inspections/${insp.id}`"
          class="recent-item"
        >
          <div class="recent-info">
            <span class="recent-unit">{{ insp.unit }}</span>
            <span class="recent-project">{{ insp.project }} · Cliente: {{ insp.client }}</span>
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

// Datos base locales para asegurar visualización inmediata incluso si Docker local aún no está corriendo
const fallbackInspections = [
  { id: '55555555-0000-0000-0000-000000000001', unit: 'Unidad 201', project: 'Condominio Los Cedros - Torre A', client: 'Carlos Mendoza', status: 'COMPLETED' },
  { id: '55555555-0000-0000-0000-000000000002', unit: 'Unidad 305', project: 'Condominio Los Cedros - Torre B', client: 'María Torres', status: 'IN_PROGRESS' },
  { id: '55555555-0000-0000-0000-000000000003', unit: 'Unidad 1102', project: 'Edificio Miramar - Torre Única', client: 'Jorge Ramírez', status: 'SCHEDULED' },
  { id: '55555555-0000-0000-0000-000000000004', unit: 'Unidad 201', project: 'Condominio Los Cedros - Torre A', client: 'Carlos Mendoza', status: 'DRAFT' },
]

const recentList = ref(fallbackInspections)

const stats = ref({
  total: 4,
  in_progress: 1,
  completed: 1,
  open_obs: 4,
})

// Intento opcional en vivo si Supabase está activo
onMounted(async () => {
  try {
    const { data } = await supabase
      .from('inspections')
      .select('id, status, clients(name), properties(unit_number, projects(name))')
      .limit(5)

    if (data && data.length > 0) {
      recentList.value = data.map((d: any) => ({
        id: d.id,
        unit: `Unidad ${d.properties?.unit_number ?? '—'}`,
        project: d.properties?.projects?.name ?? 'Proyecto General',
        client: d.clients?.name ?? 'Cliente',
        status: d.status
      }))
    }
  } catch (e) {
    // Modo de previsualización activa
  }
})
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
}
.header h1 { font-size: 2.2rem; margin: 0 0 6px 0; }
.subtitle { color: var(--text-secondary); font-size: 1rem; margin: 0; }
.badge-role {
  background: rgba(26, 115, 232, 0.15);
  color: #4d9eff;
  font-size: 0.75rem;
  font-weight: bold;
  padding: 6px 12px;
  border-radius: 20px;
  border: 1px solid rgba(26, 115, 232, 0.3);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 36px;
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

/* Quick links */
.banner-quick-links {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  margin-bottom: 40px;
}
.quick-link-box {
  background: #181818;
  border: 1px solid var(--border-color);
  border-radius: 14px;
  padding: 16px 20px;
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 14px;
  transition: all 0.2s ease;
}
.quick-link-box:hover {
  border-color: var(--primary);
  transform: translateY(-2px);
  background: #1d1d1d;
}
.q-icon { font-size: 1.8rem; }
.quick-link-box h4 { margin: 0 0 4px 0; color: #fff; font-size: 0.95rem; }
.quick-link-box p { margin: 0; color: var(--text-secondary); font-size: 0.78rem; }
.q-arrow { margin-left: auto; color: var(--primary); font-size: 1.2rem; }

/* Recent */
.section-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.recent-section h2 { font-size: 1.4rem; margin: 0; }
.view-all-link {
  color: var(--primary);
  text-decoration: none;
  font-size: 0.85rem;
}
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
</style>
