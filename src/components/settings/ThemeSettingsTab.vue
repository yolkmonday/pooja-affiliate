<template>
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <!-- Theme Controls -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">Theme Customization</h2>
        
        <form @submit.prevent="save" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Primary Color</span>
            </label>
            <input 
              v-model="form.primary_color"
              type="color" 
              class="input input-bordered h-12"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Secondary Color</span>
            </label>
            <input 
              v-model="form.secondary_color"
              type="color" 
              class="input input-bordered h-12"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Accent Color</span>
            </label>
            <input 
              v-model="form.accent_color"
              type="color" 
              class="input input-bordered h-12"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Neutral Color</span>
            </label>
            <input 
              v-model="form.neutral_color"
              type="color" 
              class="input input-bordered h-12"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Font Family</span>
            </label>
            <select 
              v-model="form.font_family"
              class="select select-bordered"
            >
              <option value="Inter, sans-serif">Inter</option>
              <option value="Roboto, sans-serif">Roboto</option>
              <option value="Poppins, sans-serif">Poppins</option>
              <option value="Montserrat, sans-serif">Montserrat</option>
            </select>
          </div>

          <div class="flex justify-end gap-2">
            <button 
              type="button" 
              class="btn" 
              @click="$emit('reset')"
            >
              Reset
            </button>
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="saving"
            >
              {{ saving ? 'Saving...' : 'Save Changes' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Theme Preview -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">Live Preview</h2>
        
        <div 
          class="rounded-lg overflow-hidden border preview-container"
          :style="{
            fontFamily: form.font_family
          }"
        >
          <!-- Preview Header -->
          <div 
            class="p-4"
            :style="{
              backgroundColor: form.primary_color,
              color: getContrastColor(form.primary_color)
            }"
          >
            <div class="flex items-center gap-4">
              <div class="avatar">
                <div class="w-12 rounded">
                  <img :src="storeLogo || '/placeholder-logo.png'" alt="Store logo" />
                </div>
              </div>
              <div>
                <h3 class="font-bold">{{ storeName }}</h3>
                <p class="text-sm opacity-80">{{ storeDescription }}</p>
              </div>
            </div>
          </div>

          <!-- Preview Content -->
          <div class="p-4 space-y-4">
            <!-- Sample Product Card -->
            <div class="card card-compact bg-base-100 shadow-sm">
              <figure class="aspect-[4/3] bg-base-200"></figure>
              <div class="card-body">
                <h4 class="card-title text-sm">Sample Product</h4>
                <p :style="{ color: form.primary_color }" class="font-bold">
                  Rp 100.000
                </p>
                <div class="card-actions justify-end">
                  <button 
                    class="btn btn-sm"
                    :style="{
                      backgroundColor: form.primary_color,
                      color: getContrastColor(form.primary_color),
                      borderColor: form.primary_color
                    }"
                  >
                    Buy Now
                  </button>
                </div>
              </div>
            </div>

            <!-- Sample Buttons -->
            <div class="flex flex-wrap gap-2">
              <button 
                class="btn"
                :style="{
                  backgroundColor: form.primary_color,
                  color: getContrastColor(form.primary_color),
                  borderColor: form.primary_color
                }"
              >
                Primary
              </button>
              <button 
                class="btn"
                :style="{
                  backgroundColor: form.secondary_color,
                  color: getContrastColor(form.secondary_color),
                  borderColor: form.secondary_color
                }"
              >
                Secondary
              </button>
              <button 
                class="btn"
                :style="{
                  backgroundColor: form.accent_color,
                  color: getContrastColor(form.accent_color),
                  borderColor: form.accent_color
                }"
              >
                Accent
              </button>
              <button 
                class="btn"
                :style="{
                  backgroundColor: form.neutral_color,
                  color: getContrastColor(form.neutral_color),
                  borderColor: form.neutral_color
                }"
              >
                Neutral
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { supabase } from '../../lib/supabaseClient'
import { useToast } from '../../composables/useToast'

const toast = useToast()

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },
  storeId: {
    type: String,
    required: true
  },
  storeName: {
    type: String,
    default: 'Sample Store'
  },
  storeDescription: {
    type: String,
    default: 'Your store description'
  },
  storeLogo: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'reset'])

const saving = ref(false)
const form = ref({ ...props.modelValue })

// Watch for external changes
watch(() => props.modelValue, (newVal) => {
  form.value = { ...newVal }
}, { deep: true })

// Watch for form changes
watch(form, (newVal) => {
  emit('update:modelValue', { ...newVal })
}, { deep: true })

// Helper function to determine text color based on background
function getContrastColor(hexcolor) {
  // Remove the # if present
  hexcolor = hexcolor.replace('#', '')
  
  // Convert to RGB
  const r = parseInt(hexcolor.substr(0, 2), 16)
  const g = parseInt(hexcolor.substr(2, 2), 16)
  const b = parseInt(hexcolor.substr(4, 2), 16)
  
  // Calculate luminance
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  
  // Return black or white based on luminance
  return luminance > 0.5 ? '#000000' : '#FFFFFF'
}

async function save() {
  try {
    saving.value = true

    const { error } = await supabase
      .from('stores')
      .update({
        theme: form.value
      })
      .eq('id', props.storeId)

    if (error) throw error

    toast.success('Theme settings saved successfully')
  } catch (error) {
    console.error('Error saving theme settings:', error)
    toast.error('Failed to save theme settings')
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.preview-container {
  transition: all 0.3s ease;
}

/* Import fonts */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Roboto:wght@400;500;700&family=Poppins:wght@400;500;600;700&family=Montserrat:wght@400;500;600;700&display=swap');
</style>
