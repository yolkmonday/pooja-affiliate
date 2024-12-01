<template>
  <div class="container mx-auto p-6">
    <div class="flex justify-between items-center mb-6">
      <div>
        <h1 class="text-2xl font-bold">{{ isEditing ? 'Edit Product' : 'Add New Product' }}</h1>
        <p class="text-gray-600">{{ isEditing ? 'Update your product details' : 'Create a new product' }}</p>
      </div>
      <button class="btn btn-ghost" @click="router.back()">
        <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M10 19l-7-7m0 0l7-7m-7 7h18" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
        </svg>
        Back
      </button>
    </div>

    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
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
                  :disabled="saving"
                  class="input input-bordered"
                  required
                  type="text"
                />
              </div>

              <div class="form-control col-span-2">
                <label class="label">
                  <span class="label-text">Description</span>
                </label>
                <textarea
                  v-model="form.description"
                  :disabled="saving"
                  class="textarea textarea-bordered h-24"
                  required
                ></textarea>
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Category</span>
                </label>
                <input
                  v-model="form.category"
                  :disabled="saving"
                  class="input input-bordered"
                  required
                  type="text"
                />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Tags</span>
                </label>
                <input
                  v-model="form.tags"
                  :disabled="saving"
                  class="input input-bordered"
                  placeholder="Separate with commas"
                  type="text"
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
                  :disabled="saving"
                  class="input input-bordered"
                  required
                  type="number"
                />
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Sale Price (Optional)</span>
                </label>
                <input
                  v-model="form.sale_price"
                  :disabled="saving"
                  class="input input-bordered"
                  type="number"
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
                    :disabled="saving"
                    class="input input-bordered"
                    required
                    type="text"
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Stock Quantity</span>
                  </label>
                  <input
                    v-model="form.quantity"
                    :disabled="saving"
                    class="input input-bordered"
                    required
                    type="number"
                  />
                </div>
              </template>

              <div class="form-control">
                <label class="label">
                  <span class="label-text">Low Stock Alert</span>
                </label>
                <input
                  v-model="form.low_stock_alert"
                  :disabled="saving"
                  class="input input-bordered"
                  required
                  type="number"
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
            <svg class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" />
            </svg>
            <span>{{ error }}</span>
          </div>

          <!-- Form Actions -->
          <div class="mt-6 flex justify-end gap-4">
            <button
              :disabled="saving"
              class="btn"
              type="button"
              @click="router.back()"
            >
              Cancel
            </button>
            <button
              :disabled="saving"
              class="btn btn-primary"
              type="submit"
            >
              {{ saving ? 'Saving...' : (isEditing ? 'Update Product' : 'Create Product') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import {computed, onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {supabase, uploadProductMedia} from '../lib/supabaseClient'
import {useToast} from '../composables/useToast'
import MediaUploader from '../components/product/MediaUploader.vue'
import VariationsManager from '../components/product/VariationsManager.vue'

const router = useRouter()
const route = useRoute()
const toast = useToast()

// State
const saving = ref(false)
const error = ref('')
const uploadProgress = ref(0)
const storeId = ref(null)

const isEditing = computed(() => !!route.params.id)

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
async function fetchStoreId() {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Not authenticated')

    const { data: store, error: storeError } = await supabase
      .from('stores')
      .select('id')
      .eq('seller_id', user.id)
      .single()

    if (storeError) throw storeError
    if (!store) throw new Error('Store not found')

    storeId.value = store.id
    return store.id
  } catch (err) {
    console.error('Error fetching store ID:', err)
    throw err
  }
}

async function loadProduct() {
  try {
    saving.value = true

    // Get product
    const { data: productData, error: productError } = await supabase
      .from('products')
      .select('*')
      .eq('id', route.params.id)
      .single()

    if (productError) throw productError

    // Get inventory
    const { data: inventoryData } = await supabase
      .from('inventory')
      .select('*')
      .eq('product_id', route.params.id)
      .is('variation_id', null)
      .single()

    // Get variation types
    const { data: typesData } = await supabase
      .from('variation_types')
      .select('*')
      .eq('product_id', route.params.id)

    // Get variation options if we have types
    let optionsData = []
    if (typesData?.length) {
      const optionsPromises = typesData.map(type =>
        supabase
          .from('variation_options')
          .select('*')
          .eq('variation_type_id', type.id)
      )
      const optionsResults = await Promise.all(optionsPromises)
      optionsData = optionsResults.map(result => result.data)
    }

    // Get variations
    const { data: variationsData } = await supabase
      .from('product_variations')
      .select('*')
      .eq('product_id', route.params.id)

    // Get variation inventory if we have variations
    let variationInventoryData = []
    if (variationsData?.length) {
      const inventoryPromises = variationsData.map(variation =>
        supabase
          .from('inventory')
          .select('*')
          .eq('variation_id', variation.id)
          .single()
      )
      const inventoryResults = await Promise.all(inventoryPromises)
      variationInventoryData = inventoryResults.map(result => result.data)
    }

    // Set form data
    form.value = {
      name: productData.name,
      description: productData.description,
      category: productData.category,
      tags: productData.tags?.join(', ') || '',
      base_price: productData.base_price,
      sale_price: productData.sale_price || '',
      sku: inventoryData?.sku,
      quantity: inventoryData?.quantity,
      low_stock_alert: inventoryData?.low_stock_alert,
      media: productData.images?.map(url => ({
        preview: url,
        type: url.toLowerCase().endsWith('.mp4') ? 'video/mp4' : 'image/jpeg',
        existing: true
      })) || [],
      variations: {
        types: typesData?.map((type, index) => ({
          id: type.id,
          name: type.name,
          position: type.position,
          options: optionsData[index] || []
        })) || [],
        combinations: variationsData?.map((variation, index) => ({
          options: [
            variation.option1_id,
            variation.option2_id
          ].filter(Boolean),
          sku: variation.sku,
          price_adjustment: variation.price_adjustment,
          stock: variationInventoryData[index]?.quantity || 0
        })) || []
      }
    }
  } catch (err) {
    console.error('Error loading product:', err)
    toast.error('Failed to load product')
    router.push('/products')
  } finally {
    saving.value = false
  }
}

async function handleSubmit() {
  try {
    saving.value = true

    // Ensure we have a store ID
    const currentStoreId = storeId.value || await fetchStoreId()
    if (!currentStoreId) throw new Error('Store ID not found')

    // Upload media files first
    const mediaUrls = []
    if (form.value.media.length) {
      const newFiles = form.value.media.filter(f => !f.existing)
      if (newFiles.length) {
        const files = newFiles.map(f => f.file)
        const uploadedMedia = await uploadProductMedia(currentStoreId, files)
        mediaUrls.push(...uploadedMedia.map(m => m.url))
      }
      // Add existing files
      mediaUrls.push(...form.value.media.filter(f => f.existing).map(f => f.preview))
    }

    const productData = {
      store_id: currentStoreId,
      name: form.value.name,
      slug: form.value.name.toLowerCase().replace(/[^\w ]+/g, '').replace(/ +/g, '-'),
      description: form.value.description,
      category: form.value.category,
      tags: form.value.tags.split(',').map(tag => tag.trim()).filter(Boolean),
      base_price: parseFloat(form.value.base_price),
      sale_price: form.value.sale_price ? parseFloat(form.value.sale_price) : null,
      images: mediaUrls,
      is_active: true
    }

    let productId

    if (isEditing.value) {
      // Update existing product
      const { data: product, error: productError } = await supabase
        .from('products')
        .update(productData)
        .eq('id', route.params.id)
        .select()
        .single()

      if (productError) throw productError
      productId = route.params.id

      // Delete existing variations
      const { error: deleteTypesError } = await supabase
        .from('variation_types')
        .delete()
        .eq('product_id', productId)

      if (deleteTypesError) throw deleteTypesError
    } else {
      // Create new product
      const { data: product, error: productError } = await supabase
        .from('products')
        .insert(productData)
        .select()
        .single()

      if (productError) throw productError
      productId = product.id
    }

    // Handle variations if any
    if (form.value.variations.types.length > 0) {
      // Create variation types
      const variationTypesData = form.value.variations.types.map(type => ({
        product_id: productId,
        name: type.name,
        position: type.position
      }))

      const { data: createdTypes, error: typesError } = await supabase
        .from('variation_types')
        .insert(variationTypesData)
        .select()

      if (typesError) throw typesError

      // Create variation options and build ID mapping
      const optionsMap = new Map() // Map temporary IDs to real IDs
      const optionsData = []

      form.value.variations.types.forEach((type, typeIndex) => {
        const createdType = createdTypes[typeIndex]
        type.options.forEach(option => {
          optionsData.push({
            variation_type_id: createdType.id,
            name: option.name
          })
        })
      })

      const { data: createdOptions, error: optionsError } = await supabase
        .from('variation_options')
        .insert(optionsData)
        .select()

      if (optionsError) throw optionsError

      // Build mapping of temporary IDs to created option IDs
      let optionIndex = 0
      form.value.variations.types.forEach(type => {
        type.options.forEach(option => {
          optionsMap.set(option.id, createdOptions[optionIndex].id)
          optionIndex++
        })
      })

      // Create product variations using the ID mapping
      const variationsData = form.value.variations.combinations.map(combo => ({
        product_id: productId,
        option1_id: optionsMap.get(combo.options[0]),
        option2_id: combo.options[1] ? optionsMap.get(combo.options[1]) : null,
        sku: combo.sku,
        price_adjustment: parseFloat(combo.price_adjustment)
      }))

      const { data: createdVariations, error: variationsError } = await supabase
        .from('product_variations')
        .insert(variationsData)
        .select()

      if (variationsError) throw variationsError

      // Create inventory entries for each variation
      const inventoryData = form.value.variations.combinations.map((combo, index) => ({
        product_id: productId,
        variation_id: createdVariations[index].id,
        sku: combo.sku,
        quantity: parseInt(combo.stock),
        low_stock_alert: parseInt(form.value.low_stock_alert),
        status: getStockStatus(combo.stock, form.value.low_stock_alert)
      }))

      const { error: inventoryError } = await supabase
        .from('inventory')
        .insert(inventoryData)

      if (inventoryError) throw inventoryError
    } else {
      // No variations, create single inventory entry
      const inventoryData = {
        product_id: productId,
        variation_id: null,
        sku: form.value.sku,
        quantity: parseInt(form.value.quantity),
        low_stock_alert: parseInt(form.value.low_stock_alert),
        status: getStockStatus(form.value.quantity, form.value.low_stock_alert)
      }

      if (isEditing.value) {
        const { error: inventoryError } = await supabase
          .from('inventory')
          .update(inventoryData)
          .eq('product_id', productId)
          .is('variation_id', null)

        if (inventoryError) throw inventoryError
      } else {
        const { error: inventoryError } = await supabase
          .from('inventory')
          .insert(inventoryData)

        if (inventoryError) throw inventoryError
      }
    }

    toast.success(`Product ${isEditing.value ? 'updated' : 'created'} successfully`)
    router.push('/products')
  } catch (err) {
    console.error('Error saving product:', err)
    error.value = 'Failed to save product'
  } finally {
    saving.value = false
  }
}

function getStockStatus(quantity, lowStockAlert) {
  if (quantity <= 0) return 'out_of_stock'
  if (quantity <= lowStockAlert) return 'low_stock'
  return 'in_stock'
}

// Initialize
onMounted(async () => {
  try {
    await fetchStoreId()
    if (isEditing.value) {
      await loadProduct()
    }
  } catch (err) {
    console.error('Error initializing:', err)
    toast.error('Failed to initialize')
    router.push('/products')
  }
})
</script>