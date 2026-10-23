<template>
  <div class="app-layout" :class="{ 'sidebar-collapsed': isCollapsed }">
    <!-- Barra Lateral Colapsable -->
    <aside class="sidebar">
      <div class="brand">
        <div class="brand-header">
          <span class="brand-icon">🏢</span>
          <h2 v-if="!isCollapsed">InspectorHub</h2>
          <button 
            type="button" 
            class="toggle-sidebar-btn" 
            :title="isCollapsed ? 'Expandir menú lateral' : 'Colapsar menú lateral'"
            @click="toggleSidebar"
          >
            {{ isCollapsed ? '❯' : '❮' }}
          </button>
        </div>
        <p v-if="!isCollapsed" class="role-badge">
          ROL: {{ currentRole }}
        </p>
      </div>

      <!-- Navegación con Filtrado Inteligente por Rol -->
      <nav class="nav-links">
        <template v-for="item in visibleNavItems" :key="item.path">
          <NuxtLink 
            :to="item.path" 
            class="nav-item"
            :class="item.customClass"
            :title="isCollapsed ? item.label : undefined"
          >
            <span class="nav-icon">{{ item.icon }}</span>
            <span v-if="!isCollapsed" class="nav-text">{{ item.label }}</span>
          </NuxtLink>
        </template>

        <!-- Selector Rápido de Rol en Barra Lateral -->
        <div v-if="!isCollapsed" class="role-switcher">
          <span class="role-switcher-title">Vista según Rol:</span>
          <div class="role-chips">
            <button 
              type="button"
              class="role-chip" 
              :class="{ active: currentRole === 'ADMIN' }"
              @click="setRole('ADMIN')"
            >
              Admin
            </button>
            <button 
              type="button"
              class="role-chip" 
              :class="{ active: currentRole === 'INSPECTOR' }"
              @click="setRole('INSPECTOR')"
            >
              Técnico/Arq
            </button>
            <button 
              type="button"
              class="role-chip" 
              :class="{ active: currentRole === 'CLIENT' }"
              @click="setRole('CLIENT')"
            >
              Cliente
            </button>
          </div>
        </div>

        <button 
          @click="logout" 
          class="nav-item logout-btn"
          :title="isCollapsed ? 'Cerrar sesión' : undefined"
        >
          <span class="nav-icon">🚪</span>
          <span v-if="!isCollapsed" class="nav-text">Cerrar Sesión</span>
        </button>
      </nav>
    </aside>

    <!-- Contenido Principal -->
    <main class="main-content">
      <slot />
    </main>
  </div>
</template>

<script setup lang="ts">
const supabase = useSupabaseClient()
const router = useRouter()

// Estado de colapso de la barra lateral (recordado en memoria/local)
const isCollapsed = ref(false)

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

// Control de Permisos y Rol Actual (ADMIN, INSPECTOR, CLIENT)
const currentRole = ref<'ADMIN' | 'INSPECTOR' | 'CLIENT'>('ADMIN')

const setRole = (role: 'ADMIN' | 'INSPECTOR' | 'CLIENT') => {
  currentRole.value = role
}

// Configuración de rutas y permisos RBAC
interface NavItem {
  label: string
  path: string
  icon: string
  roles: Array<'ADMIN' | 'INSPECTOR' | 'CLIENT'>
  customClass?: string
}

const allNavItems: NavItem[] = [
  {
    label: 'Dashboard General',
    path: '/dashboard',
    icon: '📊',
    roles: ['ADMIN']
  },
  {
    label: 'Inspector App (Campo)',
    path: '/mobile-preview',
    icon: '📱',
    roles: ['ADMIN', 'INSPECTOR'],
    customClass: 'nav-highlight'
  },
  {
    label: 'Inspecciones Técnicas',
    path: '/inspections',
    icon: '📋',
    roles: ['ADMIN', 'INSPECTOR', 'CLIENT']
  },
  {
    label: 'Actas & Informes PDF',
    path: '/reports',
    icon: '📄',
    roles: ['ADMIN', 'INSPECTOR', 'CLIENT']
  },
  {
    label: 'Planos & Arquitectura',
    path: '/plans',
    icon: '📐',
    roles: ['ADMIN', 'INSPECTOR']
  },
  {
    label: 'Motor de Sincronización',
    path: '/sync-monitor',
    icon: '⚡',
    roles: ['ADMIN'],
    customClass: 'nav-sync'
  },
  {
    label: 'Propiedades & Inmuebles',
    path: '/properties',
    icon: '🏢',
    roles: ['ADMIN']
  },
  {
    label: 'Directorio de Clientes',
    path: '/clients',
    icon: '👥',
    roles: ['ADMIN']
  }
]

// Filtrar ítems visibles según el rol del usuario conectado
const visibleNavItems = computed(() => {
  return allNavItems.filter(item => item.roles.includes(currentRole.value))
})

const logout = async () => {
  await supabase.auth.signOut()
  router.push('/login')
}
</script>

<style scoped>
.brand {
  margin-bottom: 24px;
}
.brand-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}
.brand-icon {
  font-size: 1.4rem;
}
.brand h2 {
  font-size: 1.15rem;
  margin: 0;
  background: linear-gradient(90deg, #fff, #a0a0a0);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  white-space: nowrap;
}
.toggle-sidebar-btn {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid var(--border-color);
  color: var(--text-secondary);
  width: 28px;
  height: 28px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: var(--transition);
  font-size: 0.75rem;
  flex-shrink: 0;
}
.toggle-sidebar-btn:hover {
  background: rgba(255, 255, 255, 0.12);
  color: #fff;
  border-color: var(--primary);
}
.role-badge {
  font-size: 0.68rem;
  color: #03dac6;
  margin: 6px 0 0 0;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.nav-links {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
}
.nav-item {
  text-decoration: none;
  color: var(--text-secondary);
  padding: 10px 14px;
  border-radius: var(--border-radius);
  transition: var(--transition);
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 12px;
  white-space: nowrap;
  font-size: 0.9rem;
}
.nav-icon {
  font-size: 1.1rem;
  flex-shrink: 0;
}
.nav-item:hover, .router-link-active {
  background: rgba(255, 255, 255, 0.06);
  color: var(--text-primary);
}
.nav-highlight {
  color: #03dac6;
  border: 1px solid rgba(3, 218, 198, 0.25);
  background: rgba(3, 218, 198, 0.06);
}
.nav-highlight:hover, .nav-highlight.router-link-active {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
}
.nav-sync {
  color: #4d9eff;
  border: 1px solid rgba(26, 115, 232, 0.25);
  background: rgba(26, 115, 232, 0.05);
}
.logout-btn {
  background: none;
  border: none;
  cursor: pointer;
  margin-top: auto;
  width: 100%;
}

/* Selector de Rol */
.role-switcher {
  margin-top: 18px;
  padding: 12px;
  background: rgba(0,0,0,0.3);
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.05);
}
.role-switcher-title {
  display: block;
  font-size: 0.7rem;
  color: #888;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.role-chips {
  display: flex;
  gap: 4px;
}
.role-chip {
  flex: 1;
  background: rgba(255,255,255,0.04);
  border: 1px solid #333;
  color: #aaa;
  padding: 5px 0;
  border-radius: 6px;
  font-size: 0.68rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.role-chip.active {
  background: var(--primary);
  border-color: var(--primary);
  color: #fff;
}

/* Estado Colapsado */
.sidebar-collapsed .sidebar {
  width: 72px;
  padding: 20px 10px;
}
.sidebar-collapsed .brand-header {
  justify-content: center;
}
.sidebar-collapsed .nav-item {
  justify-content: center;
  padding: 10px 0;
}
.sidebar-collapsed .nav-icon {
  margin: 0;
}
</style>
