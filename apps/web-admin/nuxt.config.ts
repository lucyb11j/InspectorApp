export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/supabase'],
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      include: undefined,
      exclude: ['/', '/login', '/signup', '/confirm', '/public/*', '/mobile-preview'],
      cookieRedirect: false,
    },
    clientOptions: {
      realtime: {
        worker: false,
        timeout: 20000,
      }
    }
  },
  css: ['~/assets/css/main.css']
})
