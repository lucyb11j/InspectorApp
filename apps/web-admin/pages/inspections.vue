<template>
  <div class="inspections-page">
    <header class="page-header">
      <div>
        <h1>Inspections</h1>
        <p class="subtitle">Manage all technical inspections</p>
      </div>
      <button class="btn-primary">+ New Inspection</button>
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

    <!-- Loading -->
    <div v-if="pending" class="state-message">Loading inspections...</div>
    <div v-else-if="error" class="state-message error">Error loading inspections.</div>

    <!-- Empty state -->
    <div v-else-if="filtered.length === 0" class="empty-state">
      <p>No inspections found for this filter.</p>
    </div>

    <!-- Table -->
    <div v-else class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Property</th>
            <th>Client</th>
            <th>Scheduled</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="insp in filtered" :key="insp.id" class="table-row">
            <td>
              <div class="cell-primary">Unit {{ insp.properties?.unit_number }}</div>
              <div class="cell-secondary">{{ insp.properties?.projects?.name }}</div>
            </td>
            <td>{{ insp.clients?.name ?? '—' }}</td>
            <td>{{ formatDate(insp.scheduled_at) }}</td>
            <td>
              <span class="status-badge" :class="`status-${insp.status.toLowerCase()}`">
                {{ insp.status }}
              </span>
            </td>
            <td>
              <button class="btn-ghost">View</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const activeFilter = ref('ALL')

const filters = [
  { label: 'All',         value: 'ALL'        },
  { label: 'Scheduled',   value: 'SCHEDULED'  },
  { label: 'In Progress', value: 'IN_PROGRESS' },
  { label: 'Completed',   value: 'COMPLETED'  },
  { label: 'Draft',       value: 'DRAFT'      },
]

// Fetch with joined data (properties -> projects, clients)
const { data: inspections, pending, error } = await useAsyncData('inspections', async () => {
  const { data, error } = await supabase
    .from('inspections')
    .select(`
      id,
      status,
      scheduled_at,
      clients (name),
      properties (
        unit_number,
        floor_number,
        building,
        projects (name)
      )
    `)
    .order('created_at', { ascending: false })

  if (error) throw error
  return data ?? []
})

const filtered = computed(() => {
  if (!inspections.value) return []
  if (activeFilter.value === 'ALL') return inspections.value
  return inspections.value.filter(i => i.status === activeFilter.value)
})

const getCount = (status: string) => {
  if (!inspections.value) return 0
  if (status === 'ALL') return inspections.value.length
  return inspections.value.filter(i => i.status === status).length
}

const formatDate = (dateStr: string | null) => {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('es-PE', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).format(new Date(dateStr))
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
  cursor: pointer;
  transition: var(--transition);
  font-size: 0.85rem;
}
.btn-ghost:hover {
  border-color: var(--primary);
  color: var(--primary);
}
.state-message {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
}
.state-message.error { color: var(--error); }
.empty-state {
  text-align: center;
  padding: 60px;
  color: var(--text-secondary);
}
</style>
