export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/supabase'],
  supabase: {
    redirect: false, // Desactiva el redireccionamiento estricto obligatorio en desarrollo
    clientOptions: {
      realtime: {
        worker: false,
        timeout: 20000,
      }
    }
  },
  css: ['~/assets/css/main.css']
})
