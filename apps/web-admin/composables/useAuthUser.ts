export const useAuthUser = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const profileRole = useState<'ADMIN' | 'INSPECTOR' | 'CLIENT'>('auth_user_role', () => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('inspector_app_active_role') as 'ADMIN' | 'INSPECTOR' | 'CLIENT' | null
      if (saved) return saved
    }
    return 'ADMIN'
  })

  const profileName = useState<string>('auth_user_name', () => {
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('inspector_app_user_name')
      if (saved) return saved
    }
    return 'Usuario'
  })

  const fetchProfile = async () => {
    // 1. Si no hay sesión o no hay usuario autenticado, chequear si hay datos guardados
    if (!user.value) {
      try {
        const { data: sessionData, error: sessionErr } = await supabase.auth.getSession()
        if (sessionErr) {
          return
        }
        if (sessionData?.session?.user) {
          user.value = sessionData.session.user
        } else {
          return
        }
      } catch {
        // En modo offline o si supabase local no está levantado, continuar con datos locales
        return
      }
    }

    try {
      const currentUserId = user.value.id
      const currentUserEmail = user.value.email || ''

      const { data, error } = await supabase
        .from('users')
        .select('role, first_name, last_name, email')
        .eq('id', currentUserId)
        .maybeSingle()

      if (data && !error) {
        if (data.role) {
          profileRole.value = data.role as 'ADMIN' | 'INSPECTOR' | 'CLIENT'
        }
        const fullName = `${data.first_name || ''} ${data.last_name || ''}`.trim()
        if (fullName) {
          profileName.value = fullName
        } else if (currentUserEmail) {
          profileName.value = currentUserEmail.split('@')[0]
        }
      } else {
        // Fallback inteligente según el email
        if (currentUserEmail.includes('inspector')) {
          profileRole.value = 'INSPECTOR'
          profileName.value = 'Arq. Roberto Silva'
        } else if (currentUserEmail.includes('cliente')) {
          profileRole.value = 'CLIENT'
          profileName.value = 'Inmobiliaria Panorama / Cliente'
        } else if (currentUserEmail.includes('admin')) {
          profileRole.value = 'ADMIN'
          profileName.value = 'Administrador General'
        }
      }

      // Sincronizar en localStorage
      if (typeof window !== 'undefined') {
        localStorage.setItem('inspector_app_active_role', profileRole.value)
        localStorage.setItem('inspector_app_user_name', profileName.value)
      }
    } catch (e) {
      console.warn('Error fetching user profile:', e)
    }
  }

  const setRole = (role: 'ADMIN' | 'INSPECTOR' | 'CLIENT') => {
    profileRole.value = role
    if (typeof window !== 'undefined') {
      localStorage.setItem('inspector_app_active_role', role)
    }
  }

  const setName = (nameStr: string) => {
    profileName.value = nameStr
    if (typeof window !== 'undefined') {
      localStorage.setItem('inspector_app_user_name', nameStr)
    }
  }

  return {
    user,
    role: profileRole,
    name: profileName,
    fetchProfile,
    setRole,
    setName
  }
}
