<template>
  <div class="app-layout">
    <aside class="sidebar">
      <div class="brand">
        <h2>Inspector Platform</h2>
      </div>
      <nav class="nav-links">
        <NuxtLink to="/dashboard" class="nav-item">Dashboard</NuxtLink>
        <NuxtLink to="/inspections" class="nav-item">Inspections</NuxtLink>
        <NuxtLink to="/plans" class="nav-item">Planos & Arquitectura</NuxtLink>
        <NuxtLink to="/sync-monitor" class="nav-item nav-sync">⚡ Motor de Sincronización</NuxtLink>
        <NuxtLink to="/mobile-preview" class="nav-item nav-highlight">📱 Inspector App (Móvil)</NuxtLink>
        <NuxtLink to="/properties" class="nav-item">Properties</NuxtLink>
        <NuxtLink to="/clients" class="nav-item">Clients</NuxtLink>
        <button @click="logout" class="nav-item logout-btn">Logout</button>
      </nav>
    </aside>
    <main class="main-content">
      <slot />
    </main>
  </div>
</template>

<script setup>
const supabase = useSupabaseClient()
const router = useRouter()

const logout = async () => {
  await supabase.auth.signOut()
  router.push('/login')
}
</script>

<style scoped>
.brand {
  margin-bottom: 40px;
  text-align: center;
}
.brand h2 {
  font-size: 1.2rem;
  background: linear-gradient(90deg, #fff, #a0a0a0);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.nav-links {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.nav-item {
  text-decoration: none;
  color: var(--text-secondary);
  padding: 12px 16px;
  border-radius: var(--border-radius);
  transition: var(--transition);
  font-weight: 500;
}
.nav-item:hover, .router-link-active {
  background: rgba(255, 255, 255, 0.05);
  color: var(--text-primary);
}
.nav-highlight {
  color: #03dac6;
  border: 1px solid rgba(3, 218, 198, 0.2);
  background: rgba(3, 218, 198, 0.05);
}
.nav-sync {
  color: #4d9eff;
  border: 1px solid rgba(26, 115, 232, 0.2);
  background: rgba(26, 115, 232, 0.05);
}
.logout-btn {
  background: none;
  border: none;
  text-align: left;
  cursor: pointer;
  margin-top: auto;
}
</style>
