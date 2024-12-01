<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-2xl font-bold">Products</h1>
        <p class="text-gray-600">Manage your store products</p>
      </div>
      <button @click="router.push('/products/new')" class="btn btn-primary">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Add Product
      </button>
    </div>

    <!-- Product List -->
    <ProductList
      :products="products"
      @add="router.push('/products/new')"
      @edit="handleEdit"
      @delete="openDeleteModal"
    />

    <!-- Delete Confirmation Modal -->
    <DeleteConfirmationModal
      ref="deleteModal"
      :deleting="deleting"
      @confirm="handleDeleteProduct"
      @close="closeDeleteModal"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase, STORAGE_BUCKETS } from '../lib/supabaseClient'
import { useToast } from '../composables/useToast'
import ProductList from '../components/product/ProductList.vue'
import DeleteConfirmationModal from '../components/product/DeleteConfirmationModal.vue'

const router = useRouter()
const toast = useToast()

// State
const products = ref([])
const productToDelete = ref(null)
const deleting = ref(false)
const storeId = ref(null)

// Component refs
const deleteModal = ref(null)

// Modal handlers
function handleEdit(product) {
  router.push(`/products/${product.id}/edit`)
}

function openDeleteModal(product) {
  productToDelete.value = product
  deleteModal.value?.show()
}

function closeDeleteModal() {
  productToDelete.value = null
  deleteModal.value?.close()
}

// Fetch store ID first
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

// Fetch products with variations and inventory
async function fetchProducts() {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .select('id')
      .eq('seller_id', user.id)
      .single()

    if (storeError) throw storeError
    
    storeId.value = store.id

    // Get basic products
    const { data: productsData, error: productsError } = await supabase
      .from('products')
      .select('*')
      .eq('store_id', store.id)
      .order('created_at', { ascending: false })

    if (productsError) throw productsError

    // Get data for each product
    const productsWithData = await Promise.all(productsData.map(async (product) => {
      // Get inventory
      const { data: inventory } = await supabase
        .from('inventory')
        .select('*')
        .eq('product_id', product.id)
        .is('variation_id', null)
        .single()

      // Get variation types
      const { data: types } = await supabase
        .from('variation_types')
        .select('*')
        .eq('product_id', product.id)

      // Get variation options if we have types
      let options = []
      if (types?.length) {
        const optionsPromises = types.map(type => 
          supabase
            .from('variation_options')
            .select('*')
            .eq('variation_type_id', type.id)
        )
        const optionsResults = await Promise.all(optionsPromises)
        options = optionsResults.map(result => result.data)
      }

      // Get variations
      const { data: variations } = await supabase
        .from('product_variations')
        .select('*')
        .eq('product_id', product.id)

      // Get variation inventory if we have variations
      let variationInventory = []
      if (variations?.length) {
        const inventoryPromises = variations.map(variation =>
          supabase
            .from('inventory')
            .select('*')
            .eq('variation_id', variation.id)
            .single()
        )
        const inventoryResults = await Promise.all(inventoryPromises)
        variationInventory = inventoryResults.map(result => result.data)
      }

      return {
        ...product,
        inventory,
        variation_types: types?.map((type, index) => ({
          ...type,
          variation_options: options[index] || []
        })) || [],
        product_variations: variations?.map((variation, index) => ({
          ...variation,
          inventory: variationInventory[index]
        })) || []
      }
    }))

    products.value = productsWithData
  } catch (error) {
    console.error('Error fetching products:', error)
    toast.error('Failed to load products')
  }
}

// Delete product
async function handleDeleteProduct() {
  if (!productToDelete.value) return

  try {
    deleting.value = true

    // Delete media files
    if (productToDelete.value.images?.length) {
      const filePaths = productToDelete.value.images.map(url => {
        const path = new URL(url).pathname
        return path.split('/').slice(-2).join('/')
      })
      
      await Promise.all(filePaths.map(path => 
        supabase.storage
          .from(STORAGE_BUCKETS.PRODUCT_MEDIA)
          .remove([path])
      ))
    }

    // Delete inventory first due to foreign key constraint
    const { error: inventoryError } = await supabase
      .from('inventory')
      .delete()
      .eq('product_id', productToDelete.value.id)

    if (inventoryError) throw inventoryError

    // Then delete the product
    const { error: productError } = await supabase
      .from('products')
      .delete()
      .eq('id', productToDelete.value.id)

    if (productError) throw productError

    await fetchProducts()
    deleteModal.value?.close()
    toast.success('Product deleted successfully')
  } catch (err) {
    console.error('Error deleting product:', err)
    toast.error('Failed to delete product')
  } finally {
    deleting.value = false
  }
}

// Initialize
onMounted(async () => {
  try {
    await fetchStoreId() // Fetch store ID first
    await fetchProducts() // Then fetch products
  } catch (err) {
    console.error('Error initializing:', err)
    toast.error('Failed to initialize. Please try refreshing the page.')
  }
})
</script>
