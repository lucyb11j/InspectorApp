<template>
  <div class="app-layout" :class="{ 'sidebar-collapsed': isCollapsed }">
    <!-- Barra Superior Móvil/Tablet con botón hamburguesa expandible -->
    <header class="mobile-top-nav">
      <div class="mobile-top-left">
        <button 
          type="button" 
          class="btn-menu-drawer" 
          @click="toggleMobileMenu"
          aria-label="Alternar menú de navegación"
        >
          <span class="hamburger-icon">{{ isMobileMenuOpen ? '✕' : '☰' }}</span>
        </button>
        <div class="mobile-brand">
          <span class="brand-icon">🏢</span>
          <span class="brand-title">InspecOS</span>
        </div>
      </div>
      <div class="mobile-top-right">
        <span class="role-badge-pill" :class="'role-' + currentRole.toLowerCase()">{{ currentRole }}</span>
      </div>
    </header>

    <!-- Overlay oscuro en móvil al abrir menú -->
    <div 
      v-if="isMobileMenuOpen" 
      class="mobile-backdrop" 
      @click="isMobileMenuOpen = false"
    ></div>

    <!-- Barra Lateral Colapsable / Drawer en Móvil/Tablet -->
    <aside class="sidebar" :class="{ 'mobile-drawer-open': isMobileMenuOpen }">
      <div class="brand">
        <div class="brand-header">
          <span class="brand-icon">🏢</span>
          <h2 v-if="!isCollapsed">InspecOS</h2>
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
            @click="isMobileMenuOpen = false"
          >
            <span class="nav-icon">{{ item.icon }}</span>
            <span v-if="!isCollapsed" class="nav-text">{{ item.label }}</span>
          </NuxtLink>
        </template>

        <!-- Perfil de Usuario y Rol -->
        <div v-if="!isCollapsed" class="user-profile-info">
          <span class="user-profile-label">Conectado como:</span>
          <span class="user-profile-name">{{ currentUserName }}</span>
          <span class="user-profile-role-tag" :class="'role-' + currentRole.toLowerCase()">{{ currentRole }}</span>
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
const { role: currentRole, name: currentUserName, setRole, fetchProfile } = useAuthUser()

// Inicializar perfil si el usuario ya está conectado
onMounted(() => {
  fetchProfile()
})

// Estado de colapso de la barra lateral (en PC)
const isCollapsed = ref(false)
// Estado de menú móvil / tablet desplegable
const isMobileMenuOpen = ref(false)

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

const toggleMobileMenu = () => {
  isMobileMenuOpen.value = !isMobileMenuOpen.value
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
    label: 'Usuarios & Permisos',
    path: '/users',
    icon: '👥',
    roles: ['ADMIN']
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
    icon: '👤',
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
/* Topbar para Mobile y Tablet */
.mobile-top-nav {
  display: none;
}
.btn-menu-drawer {
  background: #1e1e1e;
  border: 1px solid var(--border-color);
  color: #fff;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  cursor: pointer;
}
.mobile-brand {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
  font-size: 1.1rem;
}
.role-badge-pill {
  font-size: 0.72rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 20px;
  text-transform: uppercase;
}
.mobile-backdrop {
  display: none;
}

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

/* Información de Perfil de Usuario */
.user-profile-info {
  margin-top: 18px;
  padding: 12px;
  background: rgba(0, 0, 0, 0.35);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.06);
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.user-profile-label {
  font-size: 0.68rem;
  color: #8b949e;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.user-profile-name {
  font-size: 0.84rem;
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.user-profile-role-tag {
  display: inline-block;
  align-self: flex-start;
  font-size: 0.65rem;
  font-weight: 700;
  padding: 2px 7px;
  border-radius: 4px;
  text-transform: uppercase;
}
.role-admin { background: rgba(26, 115, 232, 0.2); color: #58a6ff; border: 1px solid rgba(26, 115, 232, 0.4); }
.role-inspector { background: rgba(3, 218, 198, 0.2); color: #03dac6; border: 1px solid rgba(3, 218, 198, 0.4); }
.role-client { background: rgba(255, 171, 0, 0.2); color: #ffab00; border: 1px solid rgba(255, 171, 0, 0.4); }

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

/* Responsividad para Tablet y Móvil */
@media (max-width: 900px) {
  .mobile-top-nav {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 18px;
    background: #161616;
    border-bottom: 1px solid var(--border-color);
    position: sticky;
    top: 0;
    z-index: 100;
  }
  .mobile-top-left {
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .mobile-backdrop {
    display: block;
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.65);
    backdrop-filter: blur(2px);
    z-index: 150;
  }
  .sidebar {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    width: 280px !important;
    background: #181818;
    z-index: 200;
    transform: translateX(-100%);
    transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
    box-shadow: 4px 0 24px rgba(0, 0, 0, 0.7);
    display: flex !important;
  }
  .sidebar.mobile-drawer-open {
    transform: translateX(0);
  }
}
</style>
