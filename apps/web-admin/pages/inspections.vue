<template>
  <div class="inspections-page">
    <header class="page-header">
      <div>
        <h1>Inspections</h1>
        <p class="subtitle">Gestione y supervise todas las inspecciones técnicas</p>
      </div>
      <button class="btn-primary">+ Nueva Inspección</button>
    </header>

    <!-- Filters -->
    <div class="filters-bar">
      <button
        v-for="f in filters"
        :key="f.value"
        class="filter-btn"
        :class="{ active: activeFilter === f.value }"
        @click="activeFilter = f.value"
      >
        {{ f.label }}
        <span class="filter-count">{{ getCount(f.value) }}</span>
      </button>
    </div>

    <!-- Empty state -->
    <div v-if="filtered.length === 0" class="empty-state">
      <p>No se encontraron inspecciones para este filtro.</p>
    </div>

    <!-- Table -->
    <div v-else class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Propiedad / Unidad</th>
            <th>Cliente</th>
            <th>Fecha Programada</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="insp in filtered" :key="insp.id" class="table-row">
            <td>
              <div class="cell-primary">{{ insp.unit }}</div>
              <div class="cell-secondary">{{ insp.project }}</div>
            </td>
            <td>{{ insp.client }}</td>
            <td>{{ insp.scheduledDate }}</td>
            <td>
              <span class="status-badge" :class="`status-${insp.status.toLowerCase()}`">
                {{ insp.status }}
              </span>
            </td>
            <td>
              <NuxtLink :to="`/inspections/${insp.id}`" class="btn-ghost">Ver Detalle →</NuxtLink>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
const activeFilter = ref('ALL')

const filters = [
  { label: 'Todas',        value: 'ALL'        },
  { label: 'Programadas',  value: 'SCHEDULED'  },
  { label: 'En Progreso',  value: 'IN_PROGRESS' },
  { label: 'Completadas',  value: 'COMPLETED'  },
  { label: 'Borrador',     value: 'DRAFT'      },
]

const fallbackData = [
  { id: '55555555-0000-0000-0000-000000000001', unit: 'Unidad 201', project: 'Condominio Los Cedros - Torre A', client: 'Carlos Mendoza', scheduledDate: '01 oct 2026, 09:00', status: 'COMPLETED' },
  { id: '55555555-0000-0000-0000-000000000002', unit: 'Unidad 305', project: 'Condominio Los Cedros - Torre B', client: 'María Torres', scheduledDate: '08 oct 2026, 10:00', status: 'IN_PROGRESS' },
  { id: '55555555-0000-0000-0000-000000000003', unit: 'Unidad 1102', project: 'Edificio Miramar - Torre Única', client: 'Jorge Ramírez', scheduledDate: '12 oct 2026, 14:00', status: 'SCHEDULED' },
  { id: '55555555-0000-0000-0000-000000000004', unit: 'Unidad 201', project: 'Condominio Los Cedros - Torre A', client: 'Carlos Mendoza', scheduledDate: '—', status: 'DRAFT' }
]

const inspections = ref(fallbackData)

const filtered = computed(() => {
  if (activeFilter.value === 'ALL') return inspections.value
  return inspections.value.filter(i => i.status === activeFilter.value)
})

const getCount = (status: string) => {
  if (status === 'ALL') return inspections.value.length
  return inspections.value.filter(i => i.status === status).length
}
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
}
.page-header h1 {
  font-size: 2rem;
  margin: 0 0 6px 0;
}
.subtitle {
  color: var(--text-secondary);
  margin: 0;
}
.filters-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}
.filter-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 20px;
  border: 1px solid var(--border-color);
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  transition: var(--transition);
  font-size: 0.9rem;
}
.filter-btn.active, .filter-btn:hover {
  background: rgba(26, 115, 232, 0.1);
  border-color: var(--primary);
  color: var(--primary);
}
.filter-count {
  background: rgba(255,255,255,0.1);
  border-radius: 10px;
  padding: 1px 7px;
  font-size: 0.75rem;
}
.table-wrapper {
  background: var(--surface-dark);
  border-radius: 16px;
  border: 1px solid var(--border-color);
  overflow: hidden;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
}
.data-table th {
  text-align: left;
  padding: 16px 20px;
  color: var(--text-secondary);
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  border-bottom: 1px solid var(--border-color);
}
.table-row {
  transition: var(--transition);
}
.table-row:hover {
  background: rgba(255, 255, 255, 0.03);
}
.data-table td {
  padding: 16px 20px;
  border-bottom: 1px solid rgba(255,255,255,0.04);
  font-size: 0.95rem;
}
.cell-primary {
  font-weight: 600;
}
.cell-secondary {
  color: var(--text-secondary);
  font-size: 0.82rem;
  margin-top: 2px;
}
.status-badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.78rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.status-completed  { background: rgba(3, 218, 198, 0.15); color: #03dac6; }
.status-in_progress { background: rgba(26,115,232, 0.15); color: #4d9eff; }
.status-scheduled  { background: rgba(255,193,7, 0.15); color: #ffc107; }
.status-draft      { background: rgba(160,160,160, 0.1); color: #888; }
.status-cancelled  { background: rgba(207,102,121, 0.15); color: var(--error); }
.btn-ghost {
  background: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
  padding: 6px 14px;
  border-radius: 6px;
  text-decoration: none;
  display: inline-block;
  transition: var(--transition);
  font-size: 0.85rem;
}
.btn-ghost:hover {
  border-color: var(--primary);
  color: var(--primary);
}
.empty-state {
  text-align: center;
  padding: 60px;
  color: var(--text-secondary);
}
</style>
