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
    <ProductList
      :products="paginatedProducts"
      :loading="loading"
      @openDeleteModal="openDeleteModal"
    />
    <!-- Pagination Controls -->
    <PaginationControls
      :currentPage="currentPage"
      :totalPages="totalPages"
      @prevPage="prevPage"
      @nextPage="nextPage"
    />
  </div>

  <!-- Delete Confirmation Modal -->
  <DeleteConfirmationModal
    v-if="productToDelete"
    :product="productToDelete"
    :deleting="deleting"
    @confirmDelete="confirmDelete"
    @closeDeleteModal="closeDeleteModal"
  />
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter } from "vue-router";
import { supabase, STORAGE_BUCKETS } from "../lib/supabaseClient";
import { useToast } from "../composables/useToast";
import PaginationControls from "@/components/PaginationControls.vue";
import DeleteConfirmationModal from "@/components/DeleteConfirmationModal.vue";
import ProductList from "@/components/ProductList.vue";

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
