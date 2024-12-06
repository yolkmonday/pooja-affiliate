<template>
  <div class="modal modal-open">
    <div class="modal-box">
      <h3 class="font-bold text-lg">Confirm Delete</h3>
      <p class="py-4">Are you sure you want to delete {{ product.name }}?</p>
      <div class="modal-action">
        <button
          @click="$emit('confirmDelete')"
          class="btn btn-danger"
          :disabled="deleting"
        >
          <span v-if="deleting" class="loading loading-spinner"></span>
          <span v-else>Delete</span>
        </button>
        <button
          @click="$emit('closeDeleteModal')"
          class="btn"
          :disabled="deleting"
        >
          Cancel
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps } from "vue";

const props = defineProps({
  product: Object,
  deleting: Boolean,
});
</script>
