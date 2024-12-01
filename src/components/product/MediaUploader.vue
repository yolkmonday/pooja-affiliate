<template>
  <div>
    <label class="block text-sm font-medium text-gray-700 mb-2">
      Product Media (Images & Videos)
    </label>
    <div 
      class="border-2 border-dashed rounded-lg p-6 text-center"
      :class="isDragging ? 'border-primary bg-primary/5' : 'border-gray-300'"
      @dragenter.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @dragover.prevent
      @drop.prevent="handleDrop"
    >
      <input
        type="file"
        ref="fileInput"
        multiple
        accept="image/*,video/*"
        class="hidden"
        @change="handleFileSelect"
      />
      
      <!-- Upload Area -->
      <div v-if="!modelValue.length" class="space-y-2">
        <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
        </svg>
        <div class="text-gray-600">
          <button type="button" class="text-primary hover:text-primary-focus" @click="$refs.fileInput.click()">
            Upload files
          </button>
          or drag and drop
        </div>
        <p class="text-xs text-gray-500">
          Images (PNG, JPG) and Videos (MP4) up to 10MB each
        </p>
      </div>

      <!-- Media Preview -->
      <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
        <div 
          v-for="(file, index) in modelValue" 
          :key="index"
          class="relative group aspect-square rounded-lg overflow-hidden bg-gray-100"
        >
          <!-- Image Preview -->
          <img 
            v-if="file.type.startsWith('image/')"
            :src="file.preview"
            class="w-full h-full object-cover"
          />
          
          <!-- Video Preview -->
          <video 
            v-else-if="file.type.startsWith('video/')"
            :src="file.preview"
            class="w-full h-full object-cover"
            preload="metadata"
          />

          <!-- Remove Button -->
          <button 
            type="button"
            class="absolute top-2 right-2 p-1 rounded-full bg-error text-white opacity-0 group-hover:opacity-100 transition-opacity"
            @click="removeMedia(index)"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Add More Button -->
        <button
          type="button"
          class="flex items-center justify-center aspect-square rounded-lg border-2 border-dashed border-gray-300 hover:border-primary"
          @click="$refs.fileInput.click()"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-gray-400" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
        </button>
      </div>
    </div>
    
    <!-- Upload Progress -->
    <div v-if="uploadProgress > 0 && uploadProgress < 100" class="mt-2">
      <div class="w-full bg-gray-200 rounded-full h-2.5">
        <div 
          class="bg-primary h-2.5 rounded-full transition-all duration-300"
          :style="{ width: `${uploadProgress}%` }"
        ></div>
      </div>
      <p class="text-sm text-gray-600 mt-1">Uploading... {{ uploadProgress }}%</p>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-error">
      {{ error }}
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  modelValue: {
    type: Array,
    required: true
  },
  uploadProgress: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['update:modelValue', 'error'])

const isDragging = ref(false)
const error = ref('')

function handleFileSelect(event) {
  const files = event.target.files
  if (!files.length) return
  addFiles(files)
}

function handleDrop(event) {
  isDragging.value = false
  const files = event.dataTransfer.files
  if (!files.length) return
  addFiles(files)
}

function addFiles(files) {
  Array.from(files).forEach(file => {
    if (!file.type.match(/^(image|video)\//)) {
      error.value = 'Only images and videos are allowed'
      emit('error', 'Only images and videos are allowed')
      return
    }

    if (file.size > 10 * 1024 * 1024) {
      error.value = 'Files must be less than 10MB'
      emit('error', 'Files must be less than 10MB')
      return
    }

    const reader = new FileReader()
    reader.onload = e => {
      const newFiles = [...props.modelValue]
      newFiles.push({
        file,
        preview: e.target.result,
        type: file.type
      })
      emit('update:modelValue', newFiles)
    }
    reader.readAsDataURL(file)
  })
}

function removeMedia(index) {
  const newFiles = [...props.modelValue]
  newFiles.splice(index, 1)
  emit('update:modelValue', newFiles)
}
</script>
