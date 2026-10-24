<template>
  <div class="users-page">
    <header class="page-header">
      <div>
        <h1>Gestión de Usuarios y Permisos</h1>
        <p class="subtitle">Administre el acceso, perfiles y permisos de inspectores técnicos, administradores y clientes</p>
      </div>
      <button class="btn-primary" @click="openCreateUserModal">
        + Nuevo Usuario
      </button>
    </header>

    <!-- Barra de Filtros por Rol -->
    <div class="filters-bar">
      <button 
        v-for="r in roleFilters" 
        :key="r.value" 
        class="filter-btn" 
        :class="{ active: selectedRoleFilter === r.value }"
        @click="selectedRoleFilter = r.value"
      >
        {{ r.label }}
        <span class="filter-count">{{ countByRole(r.value) }}</span>
      </button>
    </div>

    <!-- Feedback banner -->
    <div v-if="successMsg" class="alert-success">
      ✓ {{ successMsg }}
    </div>
    <div v-if="errorMsg" class="alert-error">
      ⚠️ {{ errorMsg }}
    </div>

    <!-- Tabla de Usuarios -->
    <div class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Nombre y Apellido</th>
            <th>Correo Electrónico</th>
            <th>Rol / Permisos</th>
            <th>Acceso a Módulos</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="u in filteredUsers" :key="u.id" class="table-row">
            <td>
              <div class="cell-primary font-bold">
                {{ u.first_name ? `${u.first_name} ${u.last_name || ''}` : 'Sin nombre asignado' }}
              </div>
              <div class="cell-secondary">ID: {{ u.id.substring(0, 8) }}...</div>
            </td>
            <td>
              <span class="email-text">{{ u.email }}</span>
            </td>
            <td>
              <span class="role-badge-tag" :class="'role-' + u.role.toLowerCase()">
                {{ u.role }}
              </span>
            </td>
            <td>
              <div class="modules-permission-chips">
                <span v-for="m in getModulesForRole(u.role)" :key="m" class="module-chip">
                  {{ m }}
                </span>
              </div>
            </td>
            <td>
              <div class="row-actions">
                <button type="button" class="btn-edit-role" @click="editUserRole(u)">
                  ✏️ Cambiar Rol
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Modal Editar / Asignar Rol y Permisos -->
    <div v-if="showEditModal && editingUser" class="modal-overlay" @click.self="showEditModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h3>Modificar Permisos de Usuario</h3>
            <p class="modal-sub">{{ editingUser.email }}</p>
          </div>
          <button type="button" class="btn-close" @click="showEditModal = false">✕</button>
        </div>

        <form @submit.prevent="saveUserRole" class="modal-form">
          <div class="form-group">
            <label>Nombres y Apellidos:</label>
            <div class="name-inputs-row">
              <input v-model="editingUser.first_name" type="text" class="modal-input" placeholder="Nombre" />
              <input v-model="editingUser.last_name" type="text" class="modal-input" placeholder="Apellido" />
            </div>
          </div>

          <div class="form-group">
            <label>Rol y Nivel de Autorización:</label>
            <select v-model="editingUser.role" class="modal-input role-select-input">
              <option value="ADMIN">ADMIN — Acceso total, gestión de usuarios, asignación y creación</option>
              <option value="INSPECTOR">INSPECTOR — Modo campo, planos interactivos, checklist técnico y captura offline</option>
              <option value="CLIENT">CLIENTE — Solo lectura de sus inspecciones y descarga de informes PDF</option>
            </select>
          </div>

          <div class="permissions-preview-box">
            <h4>Permisos que tendrá este usuario:</h4>
            <ul class="perm-list">
              <li v-if="editingUser.role === 'ADMIN'">
                ✓ Crear, reprogramar y asignar inspectores a visitas técnicas
              </li>
              <li v-if="editingUser.role === 'ADMIN'">
                ✓ Acceso completo al Dashboard global, clientes, propiedades y planos
              </li>
              <li v-if="editingUser.role === 'ADMIN' || editingUser.role === 'INSPECTOR'">
                ✓ Acceso a App de Campo (Tablet / Móvil), marcado de pines en planos y toma de fotografías
              </li>
              <li v-if="editingUser.role === 'ADMIN' || editingUser.role === 'INSPECTOR'">
                ✓ Registro y evaluación de checklist por ambientes
              </li>
              <li v-if="editingUser.role === 'CLIENT'">
                ✓ Consulta restringida únicamente a sus departamentos inspeccionados
              </li>
              <li>
                ✓ Generación y visualización de Actas e Informes PDF oficiales
              </li>
            </ul>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn-cancel" @click="showEditModal = false">Cancelar</button>
            <button type="submit" class="btn-primary" :disabled="saving">
              {{ saving ? 'Guardando...' : 'Guardar Permisos' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nuevo Usuario -->
    <div v-if="showCreateModal" class="modal-overlay" @click.self="showCreateModal = false">
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h3>Registrar Nuevo Usuario Técnico</h3>
            <p class="modal-sub">Asigne credenciales y perfil de acceso inicial</p>
          </div>
          <button type="button" class="btn-close" @click="showCreateModal = false">✕</button>
        </div>

        <form @submit.prevent="createNewUser" class="modal-form">
          <div class="form-row">
            <div class="form-group col">
              <label>Nombres:</label>
              <input v-model="newUserForm.first_name" type="text" class="modal-input" placeholder="Ej: Roberto" required />
            </div>
            <div class="form-group col">
              <label>Apellidos:</label>
              <input v-model="newUserForm.last_name" type="text" class="modal-input" placeholder="Ej: Silva" required />
            </div>
          </div>

          <div class="form-group">
            <label>Correo Electrónico:</label>
            <input v-model="newUserForm.email" type="email" class="modal-input" placeholder="usuario@inspector.com" required />
          </div>

          <div class="form-group">
            <label>Rol Inicial:</label>
            <select v-model="newUserForm.role" class="modal-input">
              <option value="INSPECTOR">INSPECTOR (Arquitecto / Ingeniero en Campo)</option>
              <option value="CLIENT">CLIENTE (Propietario / Inmobiliaria)</option>
              <option value="ADMIN">ADMINISTRADOR (Gestión Completa)</option>
            </select>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn-cancel" @click="showCreateModal = false">Cancelar</button>
            <button type="submit" class="btn-primary" :disabled="saving">
              {{ saving ? 'Registrando...' : 'Crear Usuario' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const { role: currentUserRole } = useAuthUser()

interface UserRecord {
  id: string
  organization_id: string
  email: string
  first_name: string | null
  last_name: string | null
  role: 'ADMIN' | 'INSPECTOR' | 'CLIENT' | 'OWNER'
}

const users = ref<UserRecord[]>([])
const selectedRoleFilter = ref('ALL')
const showEditModal = ref(false)
const showCreateModal = ref(false)
const editingUser = ref<UserRecord | null>(null)
const saving = ref(false)
const successMsg = ref('')
const errorMsg = ref('')

const newUserForm = ref({
  first_name: '',
  last_name: '',
  email: '',
  role: 'INSPECTOR' as 'ADMIN' | 'INSPECTOR' | 'CLIENT'
})

const roleFilters = [
  { label: 'Todos los Usuarios', value: 'ALL' },
  { label: 'Inspectores', value: 'INSPECTOR' },
  { label: 'Clientes / Propietarios', value: 'CLIENT' },
  { label: 'Administradores', value: 'ADMIN' }
]

const loadUsers = async () => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('id, organization_id, email, first_name, last_name, role')
      .order('created_at', { ascending: false })
    
    if (error) throw error
    if (data) {
      users.value = data as UserRecord[]
    }
  } catch (err: any) {
    console.error('Error loading users:', err)
  }
}

onMounted(() => {
  loadUsers()
})

const filteredUsers = computed(() => {
  if (selectedRoleFilter.value === 'ALL') return users.value
  return users.value.filter(u => u.role === selectedRoleFilter.value)
})

const countByRole = (r: string) => {
  if (r === 'ALL') return users.value.length
  return users.value.filter(u => u.role === r).length
}

const getModulesForRole = (r: string) => {
  switch (r) {
    case 'ADMIN':
      return ['Dashboard', 'Inspecciones', 'Asignación', 'Usuarios & Permisos', 'Planos', 'Reportes PDF', 'Sync Engine']
    case 'INSPECTOR':
      return ['App de Campo (Tablet/Móvil)', 'Mis Inspecciones Asignadas', 'Planos & Pines', 'Checklist Offline', 'Reportes PDF']
    case 'CLIENT':
      return ['Ver Mis Inspecciones', 'Descarga de Actas PDF']
    default:
      return ['Acceso Básico']
  }
}

const editUserRole = (u: UserRecord) => {
  editingUser.value = { ...u }
  showEditModal.value = true
}

const saveUserRole = async () => {
  if (!editingUser.value) return
  saving.value = true
  successMsg.value = ''
  errorMsg.value = ''
  try {
    const { error } = await supabase
      .from('users')
      .update({
        first_name: editingUser.value.first_name,
        last_name: editingUser.value.last_name,
        role: editingUser.value.role
      })
      .eq('id', editingUser.value.id)

    if (error) throw error

    successMsg.value = `Permisos actualizados con éxito para ${editingUser.value.email}`
    showEditModal.value = false
    await loadUsers()
  } catch (err: any) {
    errorMsg.value = err.message || 'Error al actualizar permisos en la base de datos'
  } finally {
    saving.value = false
  }
}

const openCreateUserModal = () => {
  newUserForm.value = {
    first_name: '',
    last_name: '',
    email: '',
    role: 'INSPECTOR'
  }
  showCreateModal.value = true
}

const createNewUser = async () => {
  saving.value = true
  successMsg.value = ''
  errorMsg.value = ''
  try {
    // Generar un UUID para el usuario si es registro manual administrativo
    const newId = crypto.randomUUID()
    const orgId = users.value[0]?.organization_id || '11111111-0000-0000-0000-000000000001'

    const { error } = await supabase
      .from('users')
      .insert({
        id: newId,
        organization_id: orgId,
        email: newUserForm.value.email,
        first_name: newUserForm.value.first_name,
        last_name: newUserForm.value.last_name,
        role: newUserForm.value.role
      })

    if (error) throw error

    successMsg.value = `Usuario ${newUserForm.value.email} creado correctamente con rol ${newUserForm.value.role}`
    showCreateModal.value = false
    await loadUsers()
  } catch (err: any) {
    errorMsg.value = err.message || 'Error al crear usuario en la base de datos'
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.users-page {
  max-width: 1200px;
  margin: 0 auto;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 1.8rem;
  font-weight: 700;
  margin: 0 0 6px 0;
  background: linear-gradient(90deg, #fff, #a5b4fc);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.subtitle {
  color: #8b949e;
  font-size: 0.95rem;
  margin: 0;
}
.filters-bar {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}
.filter-btn {
  background: #1e1e1e;
  border: 1px solid #333;
  color: #a0a0a0;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.88rem;
  transition: all 0.2s;
}
.filter-btn:hover, .filter-btn.active {
  background: #1a73e8;
  color: white;
  border-color: #1a73e8;
}
.filter-count {
  background: rgba(0, 0, 0, 0.3);
  padding: 2px 7px;
  border-radius: 10px;
  font-size: 0.78rem;
}

.alert-success {
  background: rgba(35, 134, 54, 0.2);
  border: 1px solid #238636;
  color: #3fb950;
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 16px;
  font-weight: 600;
}
.alert-error {
  background: rgba(207, 102, 121, 0.2);
  border: 1px solid #cf6679;
  color: #cf6679;
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 16px;
}

.table-wrapper {
  background: #1e1e1e;
  border-radius: 12px;
  border: 1px solid #333;
  overflow-x: auto;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  text-align: left;
}
.data-table th {
  background: #252525;
  color: #8b949e;
  padding: 14px 18px;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  border-bottom: 1px solid #333;
}
.data-table td {
  padding: 14px 18px;
  border-bottom: 1px solid #292929;
  font-size: 0.9rem;
  vertical-align: middle;
}
.table-row:hover {
  background: rgba(255, 255, 255, 0.02);
}
.cell-primary {
  color: #fff;
}
.cell-secondary {
  color: #8b949e;
  font-size: 0.75rem;
  margin-top: 2px;
}
.email-text {
  color: #58a6ff;
  font-family: monospace;
  font-size: 0.88rem;
}
.role-badge-tag {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.5px;
}
.role-admin {
  background: rgba(26, 115, 232, 0.2);
  color: #58a6ff;
  border: 1px solid rgba(26, 115, 232, 0.4);
}
.role-inspector {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  border: 1px solid rgba(3, 218, 198, 0.4);
}
.role-client {
  background: rgba(255, 171, 0, 0.15);
  color: #ffab00;
  border: 1px solid rgba(255, 171, 0, 0.4);
}
.role-owner {
  background: rgba(163, 113, 247, 0.2);
  color: #d2a8ff;
  border: 1px solid rgba(163, 113, 247, 0.4);
}
.modules-permission-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  max-width: 360px;
}
.module-chip {
  background: #141414;
  border: 1px solid #333;
  color: #ccc;
  font-size: 0.72rem;
  padding: 2px 8px;
  border-radius: 4px;
}
.btn-edit-role {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid #444;
  color: #fff;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: all 0.2s;
}
.btn-edit-role:hover {
  background: rgba(255, 255, 255, 0.12);
  border-color: #58a6ff;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}
.modal-card {
  background: #1e1e1e;
  border: 1px solid #333;
  border-radius: 14px;
  width: 100%;
  max-width: 540px;
  padding: 24px;
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.5);
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}
.modal-header h3 {
  margin: 0 0 4px 0;
  font-size: 1.25rem;
}
.modal-sub {
  color: #8b949e;
  font-size: 0.85rem;
  margin: 0;
}
.btn-close {
  background: none;
  border: none;
  color: #8b949e;
  font-size: 1.2rem;
  cursor: pointer;
}
.modal-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.form-group label {
  font-size: 0.82rem;
  font-weight: 600;
  color: #ccc;
}
.name-inputs-row {
  display: flex;
  gap: 10px;
}
.modal-input {
  background: #141414;
  border: 1px solid #333;
  color: #fff;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 0.9rem;
}
.modal-input:focus {
  outline: none;
  border-color: #1a73e8;
}
.role-select-input {
  padding: 11px;
}
.permissions-preview-box {
  background: #141414;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 14px;
}
.permissions-preview-box h4 {
  margin: 0 0 8px 0;
  font-size: 0.85rem;
  color: #58a6ff;
}
.perm-list {
  margin: 0;
  padding-left: 18px;
  color: #aaa;
  font-size: 0.8rem;
  display: flex;
  flex-direction: column;
  gap: 5px;
}
.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 10px;
}
.btn-cancel {
  background: transparent;
  border: 1px solid #444;
  color: #aaa;
  padding: 10px 18px;
  border-radius: 8px;
  cursor: pointer;
}
.form-row {
  display: flex;
  gap: 12px;
}
.col {
  flex: 1;
}
</style>

