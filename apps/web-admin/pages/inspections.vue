<template>
  <div class="inspections-page">
    <header class="page-header">
      <div>
        <h1>Inspecciones Técnicas</h1>
        <p class="subtitle">Gestione, programe y supervise las visitas y actas de recepción</p>
      </div>
      <button v-if="role !== 'CLIENT'" class="btn-primary" @click="showNewModal = true">
        + Nueva Inspección
      </button>
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

    <!-- Modal para Crear Nueva Inspección -->
    <div v-if="showNewModal" class="modal-overlay" @click.self="showNewModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h3>Nueva Inspección Técnica</h3>
            <p class="modal-sub">Defina cliente, propiedad y ambientes a inspeccionar</p>
          </div>
          <button type="button" class="btn-close" @click="showNewModal = false">✕</button>
        </div>

        <form @submit.prevent="createInspection" class="modal-form">
          <div class="form-group">
            <label>Proyecto / Inmueble:</label>
            <select v-model="form.project" class="modal-input" required>
              <option value="Condominio Los Cedros">Condominio Los Cedros</option>
              <option value="Edificio Miramar">Edificio Miramar</option>
              <option value="Torres del Sol">Torres del Sol</option>
            </select>
          </div>

          <div class="form-row">
            <div class="form-group col">
              <label>Número de Unidad / Dpto:</label>
              <input v-model="form.unit" type="text" class="modal-input" placeholder="Ej: Unidad 402" required />
            </div>
            <div class="form-group col">
              <label>Torre / Bloque:</label>
              <input v-model="form.tower" type="text" class="modal-input" placeholder="Ej: Torre B" />
            </div>
          </div>

          <div class="form-group">
            <label>Cliente / Propietario:</label>
            <input v-model="form.client" type="text" class="modal-input" placeholder="Nombre completo del cliente" required />
          </div>

          <div class="form-row">
            <div class="form-group col">
              <label>Fecha y Hora:</label>
              <input v-model="form.scheduledDate" type="datetime-local" class="modal-input" required />
            </div>
            <div class="form-group col">
              <label>Estado Inicial:</label>
              <select v-model="form.status" class="modal-input">
                <option value="SCHEDULED">SCHEDULED (Programada)</option>
                <option value="IN_PROGRESS">IN_PROGRESS (En Curso)</option>
                <option value="DRAFT">DRAFT (Borrador)</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label>Áreas / Ambientes Iniciales de Inspección:</label>
            <div class="areas-chips-box">
              <span v-for="area in form.areas" :key="area" class="area-chip-badge">
                {{ area }}
              </span>
            </div>
            <small class="hint-text">Se configurará plano táctil predeterminado con estas zonas.</small>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn-cancel" @click="showNewModal = false">Cancelar</button>
            <button type="submit" class="btn-primary">Crear Inspección</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const { role } = useAuthUser()
const activeFilter = ref('ALL')
const showNewModal = ref(false)

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

const form = ref({
  project: 'Condominio Los Cedros',
  unit: '',
  tower: 'Torre A',
  client: '',
  scheduledDate: '2026-10-25T10:00',
  status: 'SCHEDULED',
  areas: ['Sala / Comedor', 'Cocina', 'Dormitorio Principal', 'Baño Principal', 'Balcón']
})

const filtered = computed(() => {
  if (activeFilter.value === 'ALL') return inspections.value
  return inspections.value.filter(i => i.status === activeFilter.value)
})

const getCount = (status: string) => {
  if (status === 'ALL') return inspections.value.length
  return inspections.value.filter(i => i.status === status).length
}

const createInspection = () => {
  if (!form.value.unit || !form.value.client) return

  const formattedDate = form.value.scheduledDate.replace('T', ', ')
  const newId = `55555555-0000-0000-${Date.now().toString().slice(-12)}`

  inspections.value.unshift({
    id: newId,
    unit: form.value.unit,
    project: `${form.value.project} - ${form.value.tower}`,
    client: form.value.client,
    scheduledDate: formattedDate,
    status: form.value.status
  })

  // Reset form
  form.value.unit = ''
  form.value.client = ''
  showNewModal.value = false
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
  border-bottom: 1px solid var(--border-color);
  transition: var(--transition);
}
.table-row:last-child {
  border-bottom: none;
}
.table-row:hover {
  background: rgba(255, 255, 255, 0.02);
}
.data-table td {
  padding: 16px 20px;
  font-size: 0.95rem;
}
.cell-primary {
  font-weight: 500;
  color: var(--text-primary);
}
.cell-secondary {
  font-size: 0.8rem;
  color: var(--text-secondary);
}
.status-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.5px;
}
.status-completed   { background: rgba(3, 218, 198, 0.1);  color: var(--secondary); }
.status-in_progress { background: rgba(26, 115, 232, 0.1); color: var(--primary);   }
.status-scheduled   { background: rgba(255, 171, 0, 0.1);  color: #ffab00;          }
.status-draft       { background: rgba(255, 255, 255, 0.05); color: var(--text-secondary); }

.empty-state {
  text-align: center;
  padding: 48px;
  color: var(--text-secondary);
  background: var(--surface-dark);
  border-radius: 16px;
  border: 1px solid var(--border-color);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 200;
  padding: 16px;
}
.modal-card {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 16px;
  width: 100%;
  max-width: 540px;
  box-shadow: 0 20px 45px rgba(0, 0, 0, 0.6);
  overflow: hidden;
}
.modal-header {
  padding: 16px 20px;
  border-bottom: 1px solid #30363d;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.modal-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: #fff;
}
.modal-sub {
  margin: 4px 0 0 0;
  font-size: 0.8rem;
  color: #8b949e;
}
.btn-close {
  background: transparent;
  border: none;
  color: #8b949e;
  font-size: 1.2rem;
  cursor: pointer;
}
.modal-form {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.form-group label {
  font-size: 0.8rem;
  font-weight: 600;
  color: #8b949e;
}
.modal-input {
  background: #0d1117;
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 10px 12px;
  color: #fff;
  font-size: 0.9rem;
}
.modal-input:focus {
  outline: none;
  border-color: var(--primary);
}
.form-row {
  display: flex;
  gap: 12px;
}
.form-group.col {
  flex: 1;
}
.areas-chips-box {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 2px;
}
.area-chip-badge {
  background: rgba(26, 115, 232, 0.15);
  border: 1px solid rgba(26, 115, 232, 0.3);
  color: #58a6ff;
  font-size: 0.75rem;
  padding: 3px 8px;
  border-radius: 6px;
}
.hint-text {
  font-size: 0.72rem;
  color: #8b949e;
}
.modal-footer {
  margin-top: 10px;
  padding-top: 14px;
  border-top: 1px solid #30363d;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
.btn-cancel {
  background: transparent;
  border: 1px solid #30363d;
  color: #ccc;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
}
</style>
