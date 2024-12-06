<template>
  <div class="flex justify-between items-center mt-4">
    <button
      @click="$emit('prevPage')"
      :disabled="currentPage === 1"
      class="btn btn-secondary"
    >
      Previous
    </button>
    <span>Page {{ currentPage }} of {{ totalPages }}</span>
    <button
      @click="$emit('nextPage')"
      :disabled="currentPage === totalPages"
      class="btn btn-secondary"
    >
      Next
    </button>
  </div>
</template>

<script setup>
import { defineProps } from "vue";

const props = defineProps({
  currentPage: Number,
  totalPages: Number,
});
</script>
