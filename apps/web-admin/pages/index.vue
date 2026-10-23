<template>
  <div class="redirecting">Cargando plataforma...</div>
</template>

<script setup>
const router = useRouter()
onMounted(() => {
  router.push('/dashboard')
})
</script>

<style scoped>
.redirecting {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
  color: var(--text-secondary);
}
</style>
