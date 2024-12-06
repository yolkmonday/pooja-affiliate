<template>
  <div class="card bg-base-100 shadow-xl mt-8">
    <div class="card-body">
      <div v-if="loading" class="flex justify-center items-center h-32">
        <span class="loading loading-spinner loading-lg"></span>
      </div>
      <div v-if="!loading && products.length === 0" class="text-center">
        <p class="text-gray-600">No products found.</p>
      </div>
      <div v-if="!loading && products.length > 0" class="space-y-4">
        <div
          v-for="product in products"
          :key="product.id"
          class="flex items-center w-full justify-between space-x-4"
        >
          <div class="flex items-center gap-2">
            <img
              alt="Product Image"
              :src="product?.images[0]"
              onerror="this.src = 'https://via.placeholder.com/24'"
              class="w-24 h-24 object-cover rounded-lg"
            />
            <div>
              <h3>{{ product.name }}</h3>
              <p class="font-semibold">
                Rp {{ formatNumber(product.sale_price) }}
              </p>
            </div>
          </div>
          <div>
            <button
              @click="$emit('openDeleteModal', product)"
              class="btn btn-danger ml-2"
            >
              Delete
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from "vue";

const props = defineProps({
  products: Array,
  loading: Boolean,
});

const emit = defineEmits(["openDeleteModal"]);

function formatNumber(number) {
  return new Intl.NumberFormat("id-ID").format(number);
}
</script>
