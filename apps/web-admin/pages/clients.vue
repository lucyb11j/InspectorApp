<template>
  <div class="clients-page">
    <header class="page-header">
      <div>
        <h1>Clients</h1>
        <p class="subtitle">Directory of owners, buyers and real estate contacts</p>
      </div>
      <button class="btn-primary" @click="showModal = true">+ New Client</button>
    </header>

    <div v-if="pending" class="state-message">Loading clients...</div>
    <div v-else-if="error" class="state-message error">Error loading clients.</div>
    <div v-else-if="!clients?.length" class="empty-state">
      <p>No clients registered yet.</p>
    </div>

    <div v-else class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Registered</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in clients" :key="c.id" class="table-row">
            <td class="cell-primary">{{ c.name }}</td>
            <td>{{ c.email || '—' }}</td>
            <td>{{ c.phone || '—' }}</td>
            <td>{{ formatDate(c.created_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const showModal = ref(false)

const { data: clients, pending, error } = await useAsyncData('clients-list', async () => {
  const { data, error } = await supabase
    .from('clients')
    .select('id, name, email, phone, created_at')
    .order('created_at', { ascending: false })
  if (error) throw error
  return data ?? []
})

const formatDate = (dateStr: string | null) => {
  if (!dateStr) return '—'
  return new Intl.DateTimeFormat('es-PE', {
    day: '2-digit', month: 'short', year: 'numeric'
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
