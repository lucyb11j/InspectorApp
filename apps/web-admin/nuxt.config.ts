export default defineNuxtConfig({
  app: {
    head: {
      title: 'InspecOS — Plataforma de Inspección Técnica de Inmuebles',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'InspecOS: Sistema integral de software y aplicaciones móviles para inspección técnica inmobiliaria y entrega de departamentos.' }
      ]
    }
  },
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/supabase'],
  supabase: {
    redirect: false, // Desactiva el redireccionamiento estricto obligatorio en desarrollo
    useSsrCookies: false, // Evita intentos automáticos de refresh_token en SSR cuando se opera offline/local sin contenedor activo
    clientOptions: {
      auth: {
        autoRefreshToken: false,
        persistSession: true,
        detectSessionInUrl: false
      },
      realtime: {
        worker: false,
        timeout: 20000,
      }
    }
  },
  css: ['~/assets/css/main.css']
})
