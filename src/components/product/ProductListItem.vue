<template>
  <tr class="hover">
    <td>
      <div class="flex items-center gap-3">
        <div class="avatar">
          <div class="w-16 h-16 rounded">
            <!-- Show video thumbnail if it's a video -->
            <video 
              v-if="product.images?.[0]?.endsWith('.mp4')"
              :src="product.images[0]"
              class="object-cover w-full h-full"
              preload="metadata"
            />
            <!-- Show image for non-video media -->
            <img 
              v-else
              :src="product.images?.[0] || '/placeholder-product.png'" 
              :alt="product.name"
              class="object-cover"
            />
          </div>
        </div>
        <div>
          <div class="font-bold">{{ product.name }}</div>
          <div class="text-sm opacity-50">
            <!-- Show variations if they exist -->
            <template v-if="product.variation_types?.length">
              {{ product.variation_types.length }} variations
            </template>
            <!-- Show single SKU if no variations -->
            <template v-else>
              SKU: {{ product.inventory?.sku }}
            </template>
          </div>
        </div>
      </div>
    </td>
    <td>
      <!-- Show total stock across all variations -->
      <template v-if="product.product_variations?.length">
        {{ getTotalStock }}
      </template>
      <!-- Show single stock if no variations -->
      <template v-else>
        {{ product.inventory?.quantity || 0 }}
      </template>
    </td>
    <td>
      <!-- Show price range if variations have different prices -->
      <template v-if="product.product_variations?.length">
        {{ formatPriceRange }}
      </template>
      <!-- Show single price if no variations -->
      <template v-else>
        Rp {{ formatNumber(product.base_price) }}
      </template>
    </td>
    <td>
      <div class="badge" :class="getStockBadgeClass(product.inventory?.status)">
        {{ product.inventory?.status }}
      </div>
    </td>
    <td>
      <div class="flex gap-2">
        <button @click="$emit('edit')" class="btn btn-sm btn-ghost">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
        </button>
        <button @click="$emit('delete')" class="btn btn-sm btn-ghost text-error">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <polyline points="3 6 5 6 21 6"></polyline>
            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
          </svg>
        </button>
      </div>
    </td>
  </tr>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  product: {
    type: Object,
    required: true
  }
})

defineEmits(['edit', 'delete'])

// Computed
const getTotalStock = computed(() => {
  if (!props.product.product_variations?.length) {
    return props.product.inventory?.quantity || 0
  }

  return props.product.product_variations.reduce((total, variation) => 
    total + (variation.inventory?.quantity || 0)
  , 0)
})

const formatPriceRange = computed(() => {
  if (!props.product.product_variations?.length) {
    return `Rp ${formatNumber(props.product.base_price)}`
  }

  const prices = props.product.product_variations.map(v => 
    props.product.base_price + (v.price_adjustment || 0)
  )
  const minPrice = Math.min(...prices)
  const maxPrice = Math.max(...prices)

  if (minPrice === maxPrice) {
    return `Rp ${formatNumber(minPrice)}`
  }

  return `Rp ${formatNumber(minPrice)} - ${formatNumber(maxPrice)}`
})

// Methods
function formatNumber(number) {
  return new Intl.NumberFormat('id-ID').format(number)
}

function getStockBadgeClass(status) {
  const classes = {
    in_stock: 'badge-success',
    low_stock: 'badge-warning',
    out_of_stock: 'badge-error'
  }
  return classes[status] || 'badge-ghost'
}
</script>
