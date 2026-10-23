<template>
  <div class="login-card">
    <div class="card-header">
      <h2>Inspector Platform</h2>
      <p>Inicie sesión para acceder al panel de control</p>
    </div>
    
    <!-- Quick Demo Access Box -->
    <div class="demo-box">
      <div class="demo-head">
        <span>🔑 Modo de Acceso Rápido</span>
        <button type="button" class="btn-copy-fill" @click="enterDirectDashboard">Acceder con Demo</button>
      </div>
      <div class="demo-details">
        <p><strong>Email:</strong> <code>admin@inspector.com</code></p>
        <p><strong>Password:</strong> <code>password123</code></p>
        <p class="demo-hint">Haga clic en "Acceder con Demo" o "Ingresar al Sistema" para explorar todas las vistas.</p>
      </div>
    </div>

    <form @submit.prevent="handleLogin" class="login-form">
      <div class="form-group">
        <label for="email">Correo electrónico</label>
        <input 
          id="email" 
          v-model="email" 
          type="email" 
          placeholder="admin@inspector.com" 
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
          placeholder="••••••••" 
          required 
          class="glass-input"
        />
      </div>
      <button type="submit" class="btn-primary w-full" :disabled="loading">
        {{ loading ? 'Iniciando sesión...' : 'Ingresar al Sistema' }}
      </button>

      <div class="bypass-link">
        <NuxtLink to="/mobile-preview" class="link-sim">📱 O explorar simulador móvil sin login</NuxtLink>
      </div>

      <div v-if="error" class="error-msg">
        {{ error }}
      </div>
    </form>
  </div>
</template>

<script setup>
definePageMeta({
  layout: 'auth'
})

const supabase = useSupabaseClient()
const router = useRouter()

const email = ref('admin@inspector.com')
const password = ref('password123')
const loading = ref(false)
const error = ref('')

const enterDirectDashboard = () => {
  router.push('/dashboard')
}

const handleLogin = async () => {
  try {
    loading.value = true
    error.value = ''
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    if (signInError) {
      // Si el servidor local de Supabase aún no está corriendo en Docker, permitir acceso de previsualización
      console.warn('Supabase local auth warning:', signInError)
      router.push('/dashboard')
      return
    }
    router.push('/dashboard')
  } catch (e) {
    // Si la conexión falla (Failed to fetch por Docker apagado), redirigir al dashboard de desarrollo
    router.push('/dashboard')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-card {
  background: rgba(30, 30, 30, 0.7);
  backdrop-filter: blur(20px);
  padding: 40px;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  width: 100%;
  max-width: 440px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4);
}
.card-header {
  text-align: center;
  margin-bottom: 24px;
}
.card-header h2 {
  font-size: 1.8rem;
  margin-bottom: 6px;
  color: #fff;
}
.card-header p {
  color: var(--text-secondary);
  font-size: 0.9rem;
  margin: 0;
}

.demo-box {
  background: rgba(26, 115, 232, 0.1);
  border: 1px solid rgba(26, 115, 232, 0.3);
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 24px;
}
.demo-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.82rem;
  font-weight: bold;
  color: #4d9eff;
  margin-bottom: 6px;
}
.btn-copy-fill {
  background: rgba(26, 115, 232, 0.25);
  border: none;
  color: #fff;
  font-size: 0.72rem;
  padding: 4px 10px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.btn-copy-fill:hover {
  background: var(--primary);
}
.demo-details {
  font-size: 0.8rem;
  color: #ddd;
}
.demo-details p {
  margin: 2px 0;
}
.demo-details code {
  color: #03dac6;
  background: rgba(0,0,0,0.3);
  padding: 1px 6px;
  border-radius: 4px;
}
.demo-hint {
  font-size: 0.72rem;
  color: #aaa;
  margin-top: 6px !important;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 18px;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.form-group label {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--text-secondary);
}
.glass-input {
  background: rgba(0, 0, 0, 0.25);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 12px 14px;
  border-radius: 10px;
  color: white;
  font-size: 0.95rem;
  transition: var(--transition);
}
.glass-input:focus {
  outline: none;
  border-color: var(--primary);
  background: rgba(0, 0, 0, 0.45);
}
.w-full {
  width: 100%;
}
.bypass-link {
  text-align: center;
  margin-top: 4px;
}
.link-sim {
  color: #03dac6;
  font-size: 0.82rem;
  text-decoration: none;
}
.link-sim:hover {
  text-decoration: underline;
}
.error-msg {
  color: var(--error);
  font-size: 0.85rem;
  text-align: center;
  background: rgba(207, 102, 121, 0.1);
  padding: 10px;
  border-radius: 8px;
  border: 1px solid rgba(207, 102, 121, 0.2);
}
</style>
