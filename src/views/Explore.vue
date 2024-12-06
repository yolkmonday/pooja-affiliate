<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-2xl font-bold">Explore</h1>
        <p class="text-gray-600">Search product you want</p>
        <!-- Corrected typo: proudct to product -->
      </div>
    </div>

    <!-- Search Input -->
    <div class="mb-4">
      <input
        v-model="searchQuery"
        @input="searchProducts"
        type="text"
        placeholder="Search products..."
        class="input input-bordered w-full"
      />
    </div>

    <!-- Products List -->
    <div class="card bg-base-100 shadow-xl mt-8">
      <div class="card-body">
        <div v-if="loading" class="flex justify-center items-center h-32">
          <span class="loading loading-spinner loading-lg"></span>
        </div>
        <div v-if="!loading" class="space-y-4">
          <div
            v-for="product in paginatedProducts"
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
                @click="addToMyProduct(product.id)"
                class="btn btn-primary"
              >
                Add to My Product
              </button>
            </div>
          </div>
        </div>

        <!-- Pagination Controls -->
        <div class="flex justify-between items-center mt-4">
          <button
            @click="prevPage"
            :disabled="currentPage === 1"
            class="btn btn-secondary"
          >
            Previous
          </button>
          <span>Page {{ currentPage }} of {{ totalPages }}</span>
          <button
            @click="nextPage"
            :disabled="currentPage === totalPages"
            class="btn btn-secondary"
          >
            Next
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { supabase } from "../lib/supabaseClient";
import { useToast } from "../composables/useToast";

const toast = useToast();

// State
const orders = ref([]);
const selectedOrder = ref(null);
const searchQuery = ref(""); // Added search query state
const statusFilter = ref("");
const dateFilter = ref("all");
const currentPage = ref(1); // Added current page state
const itemsPerPage = 10; // Number of items per page
const totalOrders = ref(0);
const storeId = ref(null);
const products = ref([]); // Added state for products
const loading = ref(true); // Added loading state
const affiliatorId = ref(null); // Affiliator ID

// Computed
const filteredOrders = computed(() => {
  // ...existing code...
});

const filteredProducts = computed(() => {
  if (!searchQuery.value) return products.value;
  return products.value.filter((product) =>
    product.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  );
});

const totalPages = computed(() => {
  return Math.ceil(filteredProducts.value.length / itemsPerPage);
});

const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredProducts.value.slice(start, end);
});

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage);
const endIndex = computed(() =>
  Math.min(startIndex.value + itemsPerPage, totalOrders.value)
);

// Methods
function formatNumber(number) {
  return new Intl.NumberFormat("id-ID").format(number);
}

function formatDate(date) {
  return new Date(date).toLocaleDateString("id-ID", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function getStatusBadgeClass(status) {
  // ...existing code...
}

function getPaymentBadgeClass(status) {
  // ...existing code...
}

function viewOrder(order) {
  selectedOrder.value = order;
  document.getElementById("order_modal").showModal();
}

function closeOrderModal() {
  document.getElementById("order_modal").close();
  selectedOrder.value = null;
}

async function fetchProducts() {
  loading.value = true;
  try {
    const { data, error } = await supabase.from("products").select(`
        *,
        store:stores (name)
      `);

    if (error) throw error;

    products.value = data;
  } catch (error) {
    console.error("Error fetching products:", error);
  } finally {
    loading.value = false;
  }
}

function viewProduct(product) {
  // Implement view product logic
  console.log("Viewing product:", product);
}

async function addToMyProduct(productId) {
  try {
    // Check if the product is already added
    const { data: existingProduct, error: checkError } = await supabase
      .from("affiliator_product")
      .select("id")
      .eq("affiliator_id", affiliatorId.value)
      .eq("product_id", productId)
      .single();

    if (checkError && checkError.code !== "PGRST116") {
      throw checkError;
    }

    if (existingProduct) {
      toast.error("Product has already been added to your products");
      return;
    }

    // Add the product if not already added
    const { data, error } = await supabase
      .from("affiliator_product")
      .insert([{ affiliator_id: affiliatorId.value, product_id: productId }]);

    if (error) throw error;

    toast.success("Product added to your products");
    console.log("Product added to my products:", data);
  } catch (error) {
    console.error("Error adding product to my products:", error);
    toast.error("Failed to add product to your products");
  }
}

function isValidImage(url) {
  const validExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp"];
  const extension = url.split(".").pop().toLowerCase();
  return validExtensions.includes(extension);
}

async function searchProducts() {
  loading.value = true;
  try {
    const { data, error } = await supabase
      .from("products")
      .select("*")
      .ilike("name", `%${searchQuery.value}%`);

    if (error) throw error;

    products.value = data;
  } catch (error) {
    console.error("Error searching products:", error);
  } finally {
    loading.value = false;
  }
}

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++;
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--;
  }
}

onMounted(async () => {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  affiliatorId.value = user.id;
  fetchProducts();
});
</script>

