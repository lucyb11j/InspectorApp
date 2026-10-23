<template>
  <div class="properties-page">
    <header class="page-header">
      <div>
        <h1>Properties & Projects</h1>
        <p class="subtitle">Residential units, commercial offices and buildings</p>
      </div>
      <button class="btn-primary">+ Add Property</button>
    </header>

    <div v-if="pending" class="state-message">Loading properties...</div>
    <div v-else-if="error" class="state-message error">Error loading properties.</div>
    <div v-else-if="!properties?.length" class="empty-state">
      <p>No properties registered yet.</p>
    </div>

    <div v-else class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Unit / Dept</th>
            <th>Project</th>
            <th>Building / Tower</th>
            <th>Floor</th>
            <th>Client / Owner</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in properties" :key="p.id" class="table-row">
            <td class="cell-primary">Unit {{ p.unit_number }}</td>
            <td>{{ p.projects?.name ?? '—' }}</td>
            <td>{{ p.building || '—' }}</td>
            <td>{{ p.floor_number || '—' }}</td>
            <td>{{ p.clients?.name ?? '—' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()

const { data: properties, pending, error } = await useAsyncData('properties-list', async () => {
  const { data, error } = await supabase
    .from('properties')
    .select(`
      id,
      unit_number,
      floor_number,
      building,
      projects (name),
      clients (name)
    `)
    .order('created_at', { ascending: false })
  if (error) throw error
  return data ?? []
})
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
.state-message, .empty-state {
  text-align: center;
  padding: 50px;
  color: var(--text-secondary);
}
.state-message.error {
  color: var(--error);
}
</style>
