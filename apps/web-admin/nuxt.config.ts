export default defineNuxtConfig({
  compatibilityDate: '2024-04-03',
  devtools: { enabled: false },
  modules: ['@nuxtjs/supabase'],
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      include: undefined,
      exclude: ['/', '/login', '/signup', '/confirm', '/public/*'],
      cookieRedirect: false,
    }
  },
  css: ['~/assets/css/main.css']
})
