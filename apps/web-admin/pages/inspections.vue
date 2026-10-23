<template>
  <div class="inspections-page">
    <header class="page-header">
      <div>
        <h1>Inspecciones Técnicas</h1>
        <p class="subtitle">Gestione, programe y supervise las visitas y actas de recepción</p>
      </div>
      <button v-if="role !== 'CLIENT'" class="btn-primary" @click="openCreateModal">
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
            <th>Cliente / Propietario</th>
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
            <td>
              <div class="cell-primary">{{ insp.client }}</div>
              <div v-if="insp.clientEmail" class="cell-secondary">{{ insp.clientEmail }}</div>
            </td>
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

    <!-- Modal para Crear Nueva Inspección Integral -->
    <div v-if="showNewModal" class="modal-overlay" @click.self="showNewModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h3>Nueva Inspección Técnica</h3>
            <p class="modal-sub">Defina cliente, condominio/proyecto, propiedad y plano asociado</p>
          </div>
          <button type="button" class="btn-close" @click="showNewModal = false">✕</button>
        </div>

        <form @submit.prevent="createInspection" class="modal-form">
          
          <!-- Sección 1: Condominio / Proyecto -->
          <div class="form-section-title">
            <span class="sec-icon">🏢</span>
            <span>1. Condominio / Proyecto Inmobiliario</span>
          </div>
          <div class="form-row">
            <div class="form-group col-2">
              <label>Condominio / Proyecto (projects.name):</label>
              <select v-model="form.projectId" class="modal-input" @change="onProjectChange" required>
                <option v-for="proj in projectsList" :key="proj.id" :value="proj.id">
                  {{ proj.name }} ({{ proj.address }})
                </option>
              </select>
            </div>
          </div>

          <!-- Sección 2: Datos de la Propiedad -->
          <div class="form-section-title">
            <span class="sec-icon">🏠</span>
            <span>2. Datos de la Propiedad (properties)</span>
          </div>
          <div class="form-row">
            <div class="form-group col">
              <label>Número de Unidad (unit_number):</label>
              <input v-model="form.unitNumber" type="text" class="modal-input" placeholder="Ej: 305, 402, B-12" required />
            </div>
            <div class="form-group col">
              <label>Edificio / Torre (building):</label>
              <input v-model="form.building" type="text" class="modal-input" placeholder="Ej: Torre A, Bloque 2" required />
            </div>
            <div class="form-group col">
              <label>Piso (floor_number):</label>
              <input v-model="form.floorNumber" type="text" class="modal-input" placeholder="Ej: 3, 4" />
            </div>
          </div>

          <!-- Sección 3: Datos del Cliente -->
          <div class="form-section-title">
            <span class="sec-icon">👤</span>
            <span>3. Datos del Cliente / Propietario (clients)</span>
          </div>
          <div class="form-row">
            <div class="form-group col-2">
              <label>Nombre Completo (clients.name):</label>
              <input v-model="form.clientName" type="text" class="modal-input" placeholder="Nombre completo del cliente" required />
            </div>
            <div class="form-group col">
              <label>Teléfono (clients.phone):</label>
              <input v-model="form.clientPhone" type="text" class="modal-input" placeholder="+51 987 654 321" />
            </div>
          </div>
          <div class="form-group">
            <label>Correo Electrónico (clients.email):</label>
            <input v-model="form.clientEmail" type="email" class="modal-input" placeholder="propietario@email.com" />
          </div>

          <!-- Sección 4: Plano Arquitectónico y Zonas -->
          <div class="form-section-title">
            <span class="sec-icon">📐</span>
            <span>4. Plano Arquitectónico y Ambientes (property_plans & inspection_areas)</span>
          </div>
          <div class="form-row">
            <div class="form-group col-2">
              <label>Plano Arquitectónico Asignado:</label>
              <select v-model="form.planTemplate" class="modal-input">
                <option value="standard-apartment">Plano Típico Departamento (Sala, Cocina, Dormitorio, Baño, Balcón)</option>
                <option value="studio-loft">Plano Loft / Studio (Ambiente Integrado, Baño, Balcón)</option>
                <option value="penthouse-duplex">Plano Dúplex / Penthouse (Planta Baja y Terraza)</option>
              </select>
            </div>
            <div class="form-group col">
              <label>Subir Archivo de Plano (Opcional):</label>
              <div class="file-upload-box">
                <span>📎 Plano-Arq-{{ form.unitNumber || 'Unidad' }}.pdf</span>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label>Ambientes a Inspeccionar en el Plano:</label>
            <div class="areas-chips-box">
              <span v-for="area in form.areas" :key="area" class="area-chip-badge">
                {{ area }}
              </span>
            </div>
          </div>

          <!-- Sección 5: Programación de Visita -->
          <div class="form-section-title">
            <span class="sec-icon">📅</span>
            <span>5. Programación de la Visita (inspections)</span>
          </div>
          <div class="form-row">
            <div class="form-group col">
              <label>Fecha y Hora Programada (scheduled_at):</label>
              <input v-model="form.scheduledDate" type="datetime-local" class="modal-input" required />
            </div>
            <div class="form-group col">
              <label>Estado Inicial (status):</label>
              <select v-model="form.status" class="modal-input">
                <option value="SCHEDULED">SCHEDULED (Programada)</option>
                <option value="IN_PROGRESS">IN_PROGRESS (En Curso)</option>
                <option value="DRAFT">DRAFT (Borrador)</option>
              </select>
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn-cancel" @click="showNewModal = false">Cancelar</button>
            <button type="submit" class="btn-primary" :disabled="saving">
              {{ saving ? 'Guardando...' : 'Crear Inspección y Configurar Plano' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const { role } = useAuthUser()
const activeFilter = ref('ALL')
const showNewModal = ref(false)
const saving = ref(false)

const filters = [
  { label: 'Todas',        value: 'ALL'        },
  { label: 'Programadas',  value: 'SCHEDULED'  },
  { label: 'En Progreso',  value: 'IN_PROGRESS' },
  { label: 'Completadas',  value: 'COMPLETED'  },
  { label: 'Borrador',     value: 'DRAFT'      },
]

const projectsList = ref([
  { id: '22222222-0000-0000-0000-000000000001', name: 'Condominio Los Cedros', address: 'Av. Javier Prado Este 1234, San Isidro' },
  { id: '22222222-0000-0000-0000-000000000002', name: 'Edificio Miramar', address: 'Malecón de la Reserva 456, Miraflores' },
  { id: '22222222-0000-0000-0000-000000000003', name: 'Torres del Sol', address: 'Av. La Marina 789, San Miguel' }
])

interface InspectionDisplay {
  id: string
  unit: string
  project: string
  client: string
  clientEmail?: string
  scheduledDate: string
  status: string
}

const inspections = ref<InspectionDisplay[]>([
  { id: '55555555-0000-0000-0000-000000000001', unit: 'Unidad 201', project: 'Condominio Los Cedros - Torre A', client: 'Carlos Mendoza', clientEmail: 'carlos.mendoza@email.com', scheduledDate: '01 oct 2026, 09:00', status: 'COMPLETED' },
  { id: '55555555-0000-0000-0000-000000000002', unit: 'Unidad 305', project: 'Condominio Los Cedros - Torre B', client: 'María Torres', clientEmail: 'maria.torres@email.com', scheduledDate: '08 oct 2026, 10:00', status: 'IN_PROGRESS' },
  { id: '55555555-0000-0000-0000-000000000003', unit: 'Unidad 1102', project: 'Edificio Miramar - Torre Única', client: 'Jorge Ramírez', clientEmail: 'jorge.ramirez@email.com', scheduledDate: '12 oct 2026, 14:00', status: 'SCHEDULED' },
  { id: '55555555-0000-0000-0000-000000000004', unit: 'Unidad 201', project: 'Condominio Los Cedros - Torre A', client: 'Carlos Mendoza', clientEmail: 'carlos.mendoza@email.com', scheduledDate: '—', status: 'DRAFT' }
])

const form = ref({
  projectId: '22222222-0000-0000-0000-000000000001',
  unitNumber: '',
  building: 'Torre A',
  floorNumber: '3',
  clientName: '',
  clientPhone: '',
  clientEmail: '',
  planTemplate: 'standard-apartment',
  scheduledDate: '2026-10-25T10:00',
  status: 'SCHEDULED',
  areas: ['Sala / Comedor', 'Cocina', 'Dormitorio Principal', 'Baño Principal', 'Balcón']
})

const onProjectChange = () => {
  if (form.value.planTemplate === 'standard-apartment') {
    form.value.areas = ['Sala / Comedor', 'Cocina', 'Dormitorio Principal', 'Baño Principal', 'Balcón']
  }
}

const openCreateModal = () => {
  showNewModal.value = true
}

const filtered = computed(() => {
  if (activeFilter.value === 'ALL') return inspections.value
  return inspections.value.filter(i => i.status === activeFilter.value)
})

const getCount = (status: string) => {
  if (status === 'ALL') return inspections.value.length
  return inspections.value.filter(i => i.status === status).length
}

const createInspection = async () => {
  if (!form.value.unitNumber || !form.value.clientName) return

  saving.value = true
  try {
    const selectedProj = projectsList.value.find(p => p.id === form.value.projectId)
    const projName = selectedProj ? selectedProj.name : 'Condominio'
    const fullProjectName = `${projName} - ${form.value.building}`
    const unitLabel = `Unidad ${form.value.unitNumber}`
    const formattedDate = form.value.scheduledDate.replace('T', ', ')
    const newId = `55555555-0000-0000-${Date.now().toString().slice(-12)}`

    // Intentar persistir en Supabase si está disponible
    try {
      // 1. Cliente
      const { data: newClient } = await supabase
        .from('clients')
        .insert({
          organization_id: '11111111-0000-0000-0000-000000000001',
          name: form.value.clientName,
          email: form.value.clientEmail || null,
          phone: form.value.clientPhone || null
        })
        .select('id')
        .maybeSingle()

      const clientId = newClient?.id || '33333333-0000-0000-0000-000000000001'

      // 2. Propiedad
      const { data: newProp } = await supabase
        .from('properties')
        .insert({
          organization_id: '11111111-0000-0000-0000-000000000001',
          project_id: form.value.projectId,
          client_id: clientId,
          unit_number: form.value.unitNumber,
          building: form.value.building,
          floor_number: form.value.floorNumber
        })
        .select('id')
        .maybeSingle()

      const propertyId = newProp?.id || '44444444-0000-0000-0000-000000000001'

      // 3. Inspección
      await supabase
        .from('inspections')
        .insert({
          organization_id: '11111111-0000-0000-0000-000000000001',
          property_id: propertyId,
          client_id: clientId,
          status: form.value.status,
          scheduled_at: new Date(form.value.scheduledDate).toISOString()
        })

      // 4. Plano de Propiedad
      await supabase
        .from('property_plans')
        .insert({
          organization_id: '11111111-0000-0000-0000-000000000001',
          property_id: propertyId,
          name: `Plano Arquitectónico ${unitLabel}`,
          file_path: `/plans/${form.value.planTemplate}.png`,
          mime_type: 'image/png'
        })
    } catch (dbError) {
      console.warn('Database insert notice (using reactive list fallback):', dbError)
    }

    inspections.value.unshift({
      id: newId,
      unit: unitLabel,
      project: fullProjectName,
      client: form.value.clientName,
      clientEmail: form.value.clientEmail,
      scheduledDate: formattedDate,
      status: form.value.status
    })

    // Limpiar formulario y cerrar
    form.value.unitNumber = ''
    form.value.clientName = ''
    form.value.clientPhone = ''
    form.value.clientEmail = ''
    showNewModal.value = false
  } catch (err) {
    console.error('Error creating inspection:', err)
  } finally {
    saving.value = false
  }
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
  background: rgba(0, 0, 0, 0.8);
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
  max-width: 680px;
  max-height: 90vh;
  box-shadow: 0 20px 45px rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.modal-header {
  padding: 16px 20px;
  border-bottom: 1px solid #30363d;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-shrink: 0;
}
.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: #fff;
}
.modal-sub {
  margin: 4px 0 0 0;
  font-size: 0.82rem;
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
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.form-section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.88rem;
  font-weight: 700;
  color: #58a6ff;
  border-bottom: 1px solid #21262d;
  padding-bottom: 6px;
  margin-top: 4px;
}
.sec-icon {
  font-size: 1rem;
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
  padding: 9px 12px;
  color: #fff;
  font-size: 0.88rem;
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
.form-group.col-2 {
  flex: 2;
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
  padding: 4px 8px;
  border-radius: 6px;
}
.file-upload-box {
  background: #0d1117;
  border: 1px dashed #30363d;
  border-radius: 8px;
  padding: 9px 12px;
  color: #8b949e;
  font-size: 0.82rem;
  display: flex;
  align-items: center;
}
.modal-footer {
  margin-top: 10px;
  padding-top: 14px;
  border-top: 1px solid #30363d;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  flex-shrink: 0;
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
