export default defineNuxtPlugin(() => {
  if (typeof window === 'undefined') return

  // Limpiar cookies de sesión de Supabase si apuntan al contenedor local inactivo
  // para evitar que GoTrueClient intente renovar un token inexistente contra localhost:54321
  const cookies = document.cookie.split(';')
  cookies.forEach(cookie => {
    const trimmed = cookie.trim()
    if (trimmed.startsWith('sb-') && trimmed.includes('-auth-token')) {
      const eqPos = trimmed.indexOf('=')
      const name = eqPos > -1 ? trimmed.substring(0, eqPos) : trimmed
      document.cookie = `${name}=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT; SameSite=Lax;`
    }
  })
})
