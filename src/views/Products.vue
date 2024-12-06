<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-2xl font-bold">My Products</h1>
        <p class="text-gray-600">Manage your store products</p>
      </div>
      <!-- Search Input -->
      <div>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search products..."
          class="input input-bordered w-full"
        />
      </div>
    </div>
    <!-- Products List -->
    <div class="card bg-base-100 shadow-xl mt-8">
      <div class="card-body">
        <div v-if="loading" class="flex justify-center items-center h-32">
          <span class="loading loading-spinner loading-lg"></span>
        </div>
        <div
          v-if="!loading && paginatedProducts.length === 0"
          class="text-center"
        >
          <p class="text-gray-600">No products found.</p>
        </div>
        <div v-if="!loading && paginatedProducts.length > 0" class="space-y-4">
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
                @click="openDeleteModal(product)"
                class="btn btn-danger ml-2"
              >
                Delete
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

  <!-- Delete Confirmation Modal -->
  <div v-if="productToDelete" class="modal modal-open">
    <div class="modal-box">
      <h3 class="font-bold text-lg">Confirm Delete</h3>
      <p class="py-4">
        Are you sure you want to delete {{ productToDelete.name }}?
      </p>
      <div class="modal-action">
        <button @click="confirmDelete" class="btn btn-danger">Delete</button>
        <button @click="closeDeleteModal" class="btn">Cancel</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { supabase, STORAGE_BUCKETS } from "../lib/supabaseClient";
import { useToast } from "../composables/useToast";

const router = useRouter();
const toast = useToast();

// State
const products = ref([]);
const productToDelete = ref(null);
const deleting = ref(false);
const affiliatorId = ref(null);
const searchQuery = ref("");
const currentPage = ref(1);
const itemsPerPage = 10;
const loading = ref(true); // Added loading state

// Component refs
const deleteModal = ref(null);

// Computed property for filtered products
const filteredProducts = computed(() => {
  if (!searchQuery.value) return products.value;
  return products.value.filter((product) =>
    product.name.toLowerCase().includes(searchQuery.value.toLowerCase())
  );
});

// Computed property for paginated products
const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  const end = start + itemsPerPage;
  return filteredProducts.value.slice(start, end);
});

// Computed property for total pages
const totalPages = computed(() => {
  return Math.ceil(filteredProducts.value.length / itemsPerPage);
});

// Pagination handlers
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

// Modal handlers
function openDeleteModal(product) {
  productToDelete.value = product;
}

function closeDeleteModal() {
  productToDelete.value = null;
}

async function confirmDelete() {
  if (!productToDelete.value) return;
  deleting.value = true;
  try {
    const { error } = await supabase
      .from("affiliator_product")
      .delete()
      .eq("id", productToDelete.value.id);

    if (error) throw error;

    products.value = products.value.filter(
      (product) => product.id !== productToDelete.value.id
    );
    toast.success("Product deleted successfully");
  } catch (error) {
    console.error("Error deleting product:", error);
    toast.error("Failed to delete product");
  } finally {
    deleting.value = false;
    closeDeleteModal();
  }
}

// Fetch affiliator ID first
async function fetchAffiliatorId() {
  try {
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) throw new Error("Not authenticated");

    const { data: affiliator, error: affiliatorError } = await supabase
      .from("affiliators")
      .select("id")
      .eq("id", user.id)
      .single();

    if (affiliatorError) throw affiliatorError;
    if (!affiliator) throw new Error("Affiliator not found");

    affiliatorId.value = affiliator.id;
    return affiliator.id;
  } catch (err) {
    console.error("Error fetching affiliator ID:", err);
    throw err;
  }
}

// Fetch products with variations and inventory
async function fetchProducts() {
  loading.value = true;
  try {
    const {
      data: { user },
    } = await supabase.auth.getUser();

    const { data: affiliator, error: affiliatorError } = await supabase
      .from("affiliators")
      .select("id")
      .eq("id", user.id)
      .single();

    if (affiliatorError) throw affiliatorError;

    affiliatorId.value = affiliator.id;

    // Get basic products from affiliator_product table and join with products table
    const { data: productsData, error: productsError } = await supabase
      .from("affiliator_product")
      .select(
        `
        *,
        products (
          *
        )
      `
      )
      .eq("affiliator_id", affiliator.id)
      .order("created_at", { ascending: false });

    if (productsError) throw productsError;

    products.value = productsData.map((item) => ({
      ...item.products,
      ...item,
    }));
  } catch (error) {
    console.error("Error fetching products:", error);
    toast.error("Failed to load products");
  } finally {
    loading.value = false;
  }
}

// Number formatting function
function formatNumber(number) {
  return new Intl.NumberFormat("id-ID").format(number);
}

// Initialize
onMounted(async () => {
  try {
    await fetchAffiliatorId(); // Fetch affiliator ID first
    await fetchProducts(); // Then fetch products
  } catch (err) {
    console.error("Error initializing:", err);
    toast.error("Failed to initialize. Please try refreshing the page.");
  }
});
</script>
