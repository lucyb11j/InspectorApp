<template>
  <div class="login-card">
    <div class="card-header">
      <div class="brand-badge">
        <span class="brand-icon">🏢</span>
        <span>InspecOS</span>
      </div>
      <h2>Iniciar Sesión</h2>
      <p>Seleccione un perfil o ingrese sus credenciales de acceso</p>
    </div>

    <!-- Acceso Rápido por Perfil -->
    <div class="quick-profiles-section">
      <label class="profiles-label">Acceso Directo por Rol:</label>
      <div class="profiles-grid">
        <button 
          type="button" 
          class="role-select-btn" 
          :class="{ active: email === 'admin@inspector.com' }"
          @click="selectRole('ADMIN')"
        >
          <span class="role-icon">🛡️</span>
          <div class="role-info">
            <span class="role-name">Admin</span>
            <small class="role-desc">Control total</small>
          </div>
        </button>

        <button 
          type="button" 
          class="role-select-btn" 
          :class="{ active: email === 'inspector@inspector.com' }"
          @click="selectRole('INSPECTOR')"
        >
          <span class="role-icon">📐</span>
          <div class="role-info">
            <span class="role-name">Inspector / Arq</span>
            <small class="role-desc">Plano y campo</small>
          </div>
        </button>

        <button 
          type="button" 
          class="role-select-btn" 
          :class="{ active: email === 'cliente@inspector.com' }"
          @click="selectRole('CLIENT')"
        >
          <span class="role-icon">👤</span>
          <div class="role-info">
            <span class="role-name">Cliente</span>
            <small class="role-desc">Actas e informes</small>
          </div>
        </button>
      </div>
    </div>

    <form @submit.prevent="handleLogin" class="login-form">
      <div class="form-group">
        <label for="email">Correo Electrónico</label>
        <input 
          id="email" 
          v-model="email" 
          type="email" 
          autocomplete="username"
          placeholder="usuario@inspector.com" 
          required 
          class="glass-input"
        />
      </div>
      <div class="form-group">
        <label for="password">Contraseña</label>
        <input 
          id="password" 
          v-model="password" 
          type="password" 
          autocomplete="current-password"
          placeholder="••••••••" 
          required 
          class="glass-input"
        />
      </div>

      <button type="submit" class="btn-primary w-full" :disabled="loading">
        {{ loading ? 'Autenticando...' : 'Ingresar a la Plataforma' }}
      </button>

      <div class="field-direct-link">
        <NuxtLink to="/mobile-preview" class="link-field">
          📱 Ir directamente a la App de Campo (Inspector)
        </NuxtLink>
      </div>

      <div v-if="error" class="error-msg">
        {{ error }}
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'auth'
})

const supabase = useSupabaseClient()
const router = useRouter()
const { role, name, fetchProfile, setRole, setName } = useAuthUser()

const email = ref('admin@inspector.com')
const password = ref('password123')
const loading = ref(false)
const error = ref('')

const selectRole = (targetRole: 'ADMIN' | 'INSPECTOR' | 'CLIENT') => {
  if (targetRole === 'ADMIN') {
    email.value = 'admin@inspector.com'
    password.value = 'password123'
    setRole('ADMIN')
    setName('Administrador General')
  } else if (targetRole === 'INSPECTOR') {
    email.value = 'inspector@inspector.com'
    password.value = 'password123'
    setRole('INSPECTOR')
    setName('Arq. Roberto Silva')
  } else if (targetRole === 'CLIENT') {
    email.value = 'cliente@inspector.com'
    password.value = 'password123'
    setRole('CLIENT')
    setName('Inmobiliaria Panorama / Cliente')
  }
}

const handleLogin = async () => {
  try {
    loading.value = true
    error.value = ''

    // Asignar rol esperado antes de la llamada
    if (email.value.includes('inspector')) {
      setRole('INSPECTOR')
      setName('Arq. Roberto Silva')
    } else if (email.value.includes('cliente')) {
      setRole('CLIENT')
      setName('Inmobiliaria Panorama / Cliente')
    } else {
      setRole('ADMIN')
      setName('Administrador General')
    }

    const { data, error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })

    if (signInError) {
      console.warn('Supabase auth warning:', signInError)
      fallbackRoleRoute()
      return
    }

    if (data?.user) {
      await fetchProfile()
      redirectByRole(role.value)
    } else {
      fallbackRoleRoute()
    }
  } catch (e: any) {
    console.warn('Auth error caught:', e)
    fallbackRoleRoute()
  } finally {
    loading.value = false
  }
}

const fallbackRoleRoute = () => {
  if (email.value.includes('inspector')) {
    setRole('INSPECTOR')
    router.push('/mobile-preview')
  } else if (email.value.includes('cliente')) {
    setRole('CLIENT')
    router.push('/inspections')
  } else {
    setRole('ADMIN')
    router.push('/dashboard')
  }
}

const redirectByRole = (currentRole: string) => {
  if (currentRole === 'INSPECTOR') {
    router.push('/mobile-preview')
  } else if (currentRole === 'CLIENT') {
    router.push('/inspections')
  } else {
    router.push('/dashboard')
  }
}
</script>

<style scoped>
.login-card {
  background: rgba(22, 27, 34, 0.85);
  backdrop-filter: blur(24px);
  padding: 36px;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  width: 100%;
  max-width: 460px;
  box-shadow: 0 20px 45px rgba(0, 0, 0, 0.5);
}

.card-header {
  text-align: center;
  margin-bottom: 24px;
}

.brand-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(26, 115, 232, 0.12);
  border: 1px solid rgba(26, 115, 232, 0.25);
  padding: 6px 14px;
  border-radius: 20px;
  color: #58a6ff;
  font-weight: 600;
  font-size: 0.85rem;
  margin-bottom: 12px;
}

.card-header h2 {
  font-size: 1.6rem;
  font-weight: 700;
  margin: 0 0 6px 0;
  color: #fff;
}

.card-header p {
  color: var(--text-secondary);
  font-size: 0.86rem;
  margin: 0;
}

.quick-profiles-section {
  margin-bottom: 20px;
}

.profiles-label {
  display: block;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-secondary);
  margin-bottom: 8px;
  font-weight: 600;
}

.profiles-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
}

.role-select-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 10px 6px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 10px;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s ease;
}

.role-select-btn:hover {
  background: rgba(26, 115, 232, 0.1);
  border-color: rgba(26, 115, 232, 0.4);
}

.role-select-btn.active {
  background: rgba(26, 115, 232, 0.2);
  border-color: var(--primary);
  box-shadow: 0 0 12px rgba(26, 115, 232, 0.3);
}

.role-icon {
  font-size: 1.25rem;
  margin-bottom: 4px;
}

.role-info .role-name {
  display: block;
  font-size: 0.8rem;
  font-weight: 600;
}

.role-info .role-desc {
  display: block;
  font-size: 0.68rem;
  color: var(--text-secondary);
}

.login-form {
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
  font-weight: 500;
  color: var(--text-secondary);
}

.glass-input {
  background: rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 11px 14px;
  border-radius: 10px;
  color: white;
  font-size: 0.92rem;
  transition: var(--transition);
}

.glass-input:focus {
  outline: none;
  border-color: var(--primary);
  background: rgba(0, 0, 0, 0.5);
}

.w-full {
  width: 100%;
  padding: 12px;
  font-weight: 600;
  font-size: 0.95rem;
}

.field-direct-link {
  text-align: center;
  margin-top: 4px;
}

.link-field {
  color: #58a6ff;
  font-size: 0.82rem;
  text-decoration: none;
}

.link-field:hover {
  text-decoration: underline;
}

.error-msg {
  color: #ff7b72;
  font-size: 0.82rem;
  text-align: center;
  background: rgba(248, 81, 73, 0.1);
  padding: 8px;
  border-radius: 8px;
  border: 1px solid rgba(248, 81, 73, 0.2);
}
</style>
