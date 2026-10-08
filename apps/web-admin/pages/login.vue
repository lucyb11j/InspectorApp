<template>
  <div class="login-card">
    <div class="card-header">
      <h2>Sign In</h2>
      <p>Log in to access your dashboard</p>
    </div>
    
    <form @submit.prevent="handleLogin" class="login-form">
      <div class="form-group">
        <label for="email">Email</label>
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
        <label for="password">Password</label>
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
        {{ loading ? 'Signing in...' : 'Sign In' }}
      </button>
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

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  try {
    loading.value = true
    error.value = ''
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    if (signInError) throw signInError
    router.push('/dashboard')
  } catch (e) {
    error.value = e.message
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
  max-width: 420px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4);
}
.card-header {
  text-align: center;
  margin-bottom: 30px;
}
.card-header h2 {
  font-size: 2rem;
  margin-bottom: 8px;
  color: #fff;
}
.card-header p {
  color: var(--text-secondary);
}
.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.form-group label {
  font-size: 0.9rem;
  font-weight: 500;
  color: var(--text-secondary);
}
.glass-input {
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 14px;
  border-radius: 10px;
  color: white;
  font-size: 1rem;
  transition: var(--transition);
}
.glass-input:focus {
  outline: none;
  border-color: var(--primary);
  background: rgba(0, 0, 0, 0.4);
}
.w-full {
  width: 100%;
}
.error-msg {
  color: var(--error);
  font-size: 0.9rem;
  text-align: center;
  margin-top: 10px;
}
</style>
