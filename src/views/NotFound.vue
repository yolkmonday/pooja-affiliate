<template>
  <div class="flex flex-col items-center justify-center h-screen">
    <h1 class="text-6xl font-bold text-red-500">404</h1>
    <p class="text-xl mt-4">Page Not Found</p>
    <router-link to="/" class="btn btn-primary mt-6"
      >Go to Dashboard</router-link
    >
  </div>
</template>

<script>
export default {
  name: "NotFound",
};
</script>

<style scoped>
/* No additional styles needed as DaisyUI handles the styling */
</style>
