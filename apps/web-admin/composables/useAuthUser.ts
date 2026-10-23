export const useAuthUser = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const profileRole = useState<'ADMIN' | 'INSPECTOR' | 'CLIENT'>('auth_user_role', () => 'ADMIN')
  const profileName = useState<string>('auth_user_name', () => 'Usuario')

  const fetchProfile = async () => {
    if (!user.value) {
      // Check stored preference or default
      return
    }

    try {
      const { data, error } = await supabase
        .from('users')
        .select('role, first_name, last_name')
        .eq('id', user.value.id)
        .maybeSingle()

      if (data && !error) {
        if (data.role) {
          profileRole.value = data.role as 'ADMIN' | 'INSPECTOR' | 'CLIENT'
        }
        if (data.first_name || data.last_name) {
          profileName.value = `${data.first_name || ''} ${data.last_name || ''}`.trim()
        }
      }
    } catch (e) {
      console.warn('Error fetching user profile:', e)
    }
  }

  const setRole = (role: 'ADMIN' | 'INSPECTOR' | 'CLIENT') => {
    profileRole.value = role
  }

  return {
    user,
    role: profileRole,
    name: profileName,
    fetchProfile,
    setRole
  }
}
