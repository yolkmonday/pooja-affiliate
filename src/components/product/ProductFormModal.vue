<template>
  <dialog ref="modal" class="modal">
    <div class="modal-box max-w-4xl">
      <h3 class="font-bold text-lg mb-4">
        {{ isEditing ? 'Edit Product' : 'Add New Product' }}
      </h3>

      <form @submit.prevent="handleSubmit">
        <!-- Media Upload -->
        <div class="mb-6">
          <MediaUploader
            v-model="form.media"
            :upload-progress="uploadProgress"
            @error="error = $event"
          />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Basic Info -->
          <div class="space-y-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Product Name</span>
              </label>
              <input 
                v-model="form.name"
                type="text"
                class="input input-bordered"
                required
                :disabled="saving"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Description</span>
              </label>
              <textarea 
                v-model="form.description"
                class="textarea textarea-bordered h-24"
                required
                :disabled="saving"
              ></textarea>
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Category</span>
              </label>
              <input 
                v-model="form.category"
                type="text"
                class="input input-bordered"
                required
                :disabled="saving"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Tags</span>
              </label>
              <input 
                v-model="form.tags"
                type="text"
                class="input input-bordered"
                placeholder="Separate with commas"
                :disabled="saving"
              />
            </div>
          </div>

          <!-- Pricing and Inventory -->
          <div class="space-y-4">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Base Price</span>
              </label>
              <input 
                v-model="form.base_price"
                type="number"
                class="input input-bordered"
                required
                :disabled="saving"
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Sale Price (Optional)</span>
              </label>
              <input 
                v-model="form.sale_price"
                type="number"
                class="input input-bordered"
                :disabled="saving"
              />
            </div>

            <!-- Only show these fields if no variations -->
            <template v-if="!form.variations.types.length">
              <div class="form-control">
                <label class="label">
                  <span class="label-text">SKU</span>
                </label>
                <input 
                  v-model="form.sku"
                  type="text"
                  class="input input-bordered"
                  required
                  :disabled="saving"
                />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Stock Quantity</span>
                </label>
                <input 
                  v-model="form.quantity"
                  type="number"
                  class="input input-bordered"
                  required
                  :disabled="saving"
                />
              </div>
            </template>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Low Stock Alert</span>
              </label>
              <input 
                v-model="form.low_stock_alert"
                type="number"
                class="input input-bordered"
                required
                :disabled="saving"
              />
            </div>
          </div>
        </div>

        <!-- Variations Manager -->
        <div class="mt-6 border-t pt-6">
          <VariationsManager v-model="form.variations" />
        </div>

        <!-- Error Alert -->
        <div v-if="error" class="alert alert-error mt-6">
          <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{{ error }}</span>
        </div>

        <!-- Form Actions -->
        <div class="modal-action">
          <button type="button" class="btn" @click="close" :disabled="saving">Cancel</button>
          <button 
            type="submit" 
            class="btn btn-primary"
            :disabled="saving"
          >
            {{ saving ? 'Saving...' : (isEditing ? 'Update Product' : 'Create Product') }}
          </button>
        </div>
      </form>
    </div>
    <form method="dialog" class="modal-backdrop">
      <button>close</button>
    </form>
  </dialog>
</template>

<script setup>
import { ref, computed } from 'vue'
import MediaUploader from './MediaUploader.vue'
import VariationsManager from './VariationsManager.vue'

const props = defineProps({
  product: {
    type: Object,
    default: null
  },
  saving: {
    type: Boolean,
    default: false
  },
  uploadProgress: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['submit', 'close'])

const modal = ref(null)
const error = ref('')

const isEditing = computed(() => !!props.product)

// Form state
const form = ref({
  name: '',
  description: '',
  category: '',
  tags: '',
  base_price: '',
  sale_price: '',
  sku: '',
  quantity: '',
  low_stock_alert: 5,
  media: [],
  variations: {
    types: [],
    combinations: []
  }
})

// Methods
function resetForm() {
  form.value = {
    name: '',
    description: '',
    category: '',
    tags: '',
    base_price: '',
    sale_price: '',
    sku: '',
    quantity: '',
    low_stock_alert: 5,
    media: [],
    variations: {
      types: [],
      combinations: []
    }
  }
  error.value = ''
}

function loadProduct(product) {
  // First, create a map of variation types and their options
  const variationTypesMap = new Map()
  
  product.variation_types?.forEach(type => {
    // Ensure each option has an ID and is properly structured
    const options = (type.variation_options || []).map(opt => ({
      id: opt.id,
      name: opt.name
    }))
    
    variationTypesMap.set(type.id, {
      id: type.id,
      name: type.name,
      position: type.position,
      options
    })
  })

  // Then map variations using the types map
  const variations = product.product_variations?.map(variation => {
    const options = []
    
    // Only add option IDs if they exist and correspond to actual options
    if (variation.option1_id) {
      const type1 = product.variation_types?.find(t => 
        t.variation_options?.some(o => o.id === variation.option1_id)
      )
      if (type1) options.push(variation.option1_id)
    }
    
    if (variation.option2_id) {
      const type2 = product.variation_types?.find(t => 
        t.variation_options?.some(o => o.id === variation.option2_id)
      )
      if (type2) options.push(variation.option2_id)
    }

    return {
      options,
      sku: variation.sku || '',
      price_adjustment: variation.price_adjustment || 0,
      stock: variation.inventory?.quantity || 0
    }
  }) || []

  form.value = {
    name: product.name || '',
    description: product.description || '',
    category: product.category || '',
    tags: product.tags?.join(', ') || '',
    base_price: product.base_price || '',
    sale_price: product.sale_price || '',
    sku: product.inventory?.sku || '',
    quantity: product.inventory?.quantity || '',
    low_stock_alert: product.inventory?.low_stock_alert || 5,
    media: product.images?.map(url => ({
      preview: url,
      type: url.toLowerCase().endsWith('.mp4') ? 'video/mp4' : 'image/jpeg',
      existing: true
    })) || [],
    variations: {
      types: Array.from(variationTypesMap.values()),
      combinations: variations
    }
  }
}

function handleSubmit() {
  emit('submit', {
    ...form.value,
    tags: form.value.tags.split(',').map(tag => tag.trim()).filter(Boolean)
  })
}

function show() {
  if (props.product) {
    loadProduct(props.product)
  } else {
    resetForm()
  }
  modal.value?.showModal()
}

function close() {
  modal.value?.close()
  emit('close')
}

// Expose methods to parent
defineExpose({
  show,
  close
})
</script>
