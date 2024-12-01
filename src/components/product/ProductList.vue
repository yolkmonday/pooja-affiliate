<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <!-- Search and Filters -->
      <div class="flex flex-col sm:flex-row gap-4 mb-6">
        <div class="flex-1">
          <div class="join w-full max-w-md">
            <input 
              v-model="searchQuery"
              type="text"
              class="input input-bordered join-item flex-1"
              placeholder="Search products..."
            />
            <button class="btn join-item">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
              </svg>
            </button>
          </div>
        </div>
        <select v-model="stockFilter" class="select select-bordered">
          <option value="">All Stock Status</option>
          <option value="in_stock">In Stock</option>
          <option value="low_stock">Low Stock</option>
          <option value="out_of_stock">Out of Stock</option>
        </select>
      </div>

      <!-- Products Table -->
      <div class="overflow-x-auto">
        <table class="table">
          <thead>
            <tr>
              <th>Product</th>
              <th>Stock</th>
              <th>Price</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <ProductListItem
              v-for="product in filteredProducts"
              :key="product.id"
              :product="product"
              @edit="$emit('edit', product)"
              @delete="$emit('delete', product)"
            />
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-if="!products.length" class="text-center py-8">
        <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">No products</h3>
        <p class="mt-1 text-sm text-gray-500">Get started by creating a new product.</p>
        <div class="mt-6">
          <button @click="$emit('add')" class="btn btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <line x1="12" y1="5" x2="12" y2="19"></line>
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            Add Product
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import ProductListItem from './ProductListItem.vue'

const props = defineProps({
  products: {
    type: Array,
    required: true
  }
})

defineEmits(['add', 'edit', 'delete'])

// State
const searchQuery = ref('')
const stockFilter = ref('')

// Computed
const filteredProducts = computed(() => {
  let filtered = [...props.products]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(product => 
      product.name.toLowerCase().includes(query) ||
      product.inventory?.sku?.toLowerCase().includes(query)
    )
  }

  if (stockFilter.value) {
    filtered = filtered.filter(product => 
      product.inventory?.status === stockFilter.value
    )
  }

  return filtered
})
</script>
