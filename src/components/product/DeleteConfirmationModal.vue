<template>
  <dialog ref="modal" class="modal">
    <div class="modal-box">
      <h3 class="font-bold text-lg">Delete Product</h3>
      <p class="py-4">Are you sure you want to delete this product? This action cannot be undone.</p>
      <div class="modal-action">
        <button class="btn" @click="close" :disabled="deleting">Cancel</button>
        <button 
          class="btn btn-error" 
          :disabled="deleting"
          @click="handleConfirm"
        >
          {{ deleting ? 'Deleting...' : 'Delete' }}
        </button>
      </div>
    </div>
    <form method="dialog" class="modal-backdrop">
      <button>close</button>
    </form>
  </dialog>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  deleting: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['confirm', 'close'])

const modal = ref(null)

function show() {
  modal.value?.showModal()
}

function close() {
  modal.value?.close()
  emit('close')
}

function handleConfirm() {
  emit('confirm')
}

defineExpose({
  show,
  close
})
</script>
