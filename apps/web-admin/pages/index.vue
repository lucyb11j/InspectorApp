<template>
  <div>Redirecting...</div>
</template>

<script setup>
const user = useSupabaseUser()
const router = useRouter()

onMounted(() => {
  if (user.value) {
    router.push('/dashboard')
  } else {
    router.push('/login')
  }
})
</script>
