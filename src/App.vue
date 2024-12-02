<template>
  <div class="min-h-screen bg-base-200">
    <!-- Initial Loading State -->
    <div
      v-if="initializing"
      class="min-h-screen flex items-center justify-center"
    >
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <!-- Error State -->
    <div
      v-else-if="error"
      class="min-h-screen flex items-center justify-center"
    >
      <div class="alert alert-error max-w-md">
        <Icon icon="mdi:alert-circle-outline" class="h-6 w-6" />
        <span>{{ error }}</span>
        <button class="btn btn-sm" @click="reloadPage">Reload Page</button>
      </div>
    </div>

    <!-- Main Content -->
    <template v-else>
      <!-- Public Routes (Login/Register) -->
      <router-view v-if="isPublicRoute"></router-view>

      <!-- Protected Routes (Dashboard) -->
      <div v-else-if="user" class="drawer lg:drawer-open">
        <!-- Drawer toggle for mobile -->
        <input id="drawer" type="checkbox" class="drawer-toggle" />

        <!-- Page content -->
        <div class="drawer-content flex flex-col">
          <!-- Top navigation -->
          <div class="navbar bg-base-100 shadow-sm lg:hidden">
            <div class="flex-none">
              <label
                for="drawer"
                class="btn btn-square btn-ghost drawer-button"
              >
                <Icon icon="mdi:menu" class="inline-block w-5 h-5" />
              </label>
            </div>
            <div class="flex-1">
              <img src="/poojalogo.png" alt="Pooja" class="h-16" />
            </div>
          </div>

          <!-- Main content -->
          <main class="flex-1 bg-base-200">
            <router-view></router-view>
          </main>
        </div>

        <!-- Sidebar -->
        <div class="drawer-side">
          <label for="drawer" class="drawer-overlay"></label>
          <aside class="bg-base-100 w-80 min-h-screen">
            <!-- Logo -->
            <div class="p-4 border-b">
              <img src="/poojalogo.png" alt="Pooja" class="h-16" />
            </div>

            <!-- Navigation links -->
            <nav class="p-4 space-y-2">
              <router-link
                to="/"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Dashboard' }"
              >
                <Icon icon="mdi:view-dashboard-outline" class="h-5 w-5" />
                Dashboard
              </router-link>

              <router-link
                to="/explore"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Explore' }"
              >
                <Icon icon="mdi:compass-outline" class="h-5 w-5" />
                Explore
              </router-link>

              <router-link
                to="/my-products"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'MyProducts' }"
              >
                <Icon icon="mdi:package-variant-closed" class="h-5 w-5" />
                My Products
              </router-link>

              <router-link
                to="/orders"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Orders' }"
              >
                <Icon icon="mdi:clipboard-list-outline" class="h-5 w-5" />
                Orders
              </router-link>

              <router-link
                to="/customers"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Customers' }"
              >
                <Icon icon="mdi:account-group-outline" class="h-5 w-5" />
                Customers
              </router-link>

              <router-link
                to="/settings"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Settings' }"
              >
                <Icon icon="mdi:cog-outline" class="h-5 w-5" />
                Settings
              </router-link>
            </nav>

            <!-- User section -->
            <div class="border-t mt-auto p-4">
              <div class="flex items-center gap-3">
                <div class="avatar placeholder">
                  <div
                    class="bg-neutral text-neutral-content rounded-full w-10"
                  >
                    <span class="text-lg">{{ userInitials }}</span>
                  </div>
                </div>
                <div>
                  <div class="font-medium">{{ storeName }}</div>
                  <button
                    @click="handleLogout"
                    class="text-sm text-gray-500 hover:text-primary"
                  >
                    Logout
                  </button>
                </div>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import { Icon } from "@iconify/vue"; // Add this import
import { supabase } from "./lib/supabaseClient";
import { useToast } from "./composables/useToast";
// Remove the iconify script import

// State
const initializing = ref(true);
const error = ref(null);
const storeName = ref("");
const user = ref(null);

// Hooks
const router = useRouter();
const route = useRoute();

// Computed
const isPublicRoute = computed(() => {
  return ["Login", "Register"].includes(route.name);
});

const userInitials = computed(() => {
  if (!storeName.value) return "";
  return storeName.value
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase();
});

// Methods
async function fetchStoreData(userId) {
  try {
    console.log("Fetching store data for user ID:", userId);
    const { data: store, error: storeError } = await supabase
      .from("affiliators")
      .select("name")
      .eq("id", userId)
      .maybeSingle();

    if (storeError) throw storeError;
    if (store) {
      console.log("Store data fetched:", store);
      storeName.value = store.name;
    }
  } catch (err) {
    console.error("Error fetching store:", err);
    // Don't set error state, just log it
  }
}

async function handleLogout() {
  try {
    const { error: logoutError } = await supabase.auth.signOut();
    if (logoutError) throw logoutError;

    user.value = null;
    storeName.value = "";
    toast.success("Logged out successfully");
    router.push("/login");
  } catch (err) {
    console.error("Error logging out:", err);
    toast.error("Failed to log out");
  }
}

function reloadPage() {
  window.location.reload();
}

// Initialize
onMounted(async () => {
  try {
    console.log("Initializing application...");

    // Create toast container if it doesn't exist
    if (!document.getElementById("toast-container")) {
      const container = document.createElement("div");
      container.id = "toast-container";
      document.body.appendChild(container);
    }

    // Get initial session
    const {
      data: { session },
    } = await supabase.auth.getSession();

    if (session?.user) {
      console.log("User session found:", session.user);
      user.value = session.user;
      await fetchStoreData(session.user.id);

      // Redirect if on public route
      if (isPublicRoute.value) {
        router.push("/");
      }
    } else if (!isPublicRoute.value) {
      // Redirect to login if not authenticated and not on public route
      router.push("/login");
    }
  } catch (err) {
    console.error("Initialization error:", err);
    error.value = "Failed to initialize application";
  } finally {
    initializing.value = false;
  }
});

// Auth state change handler
supabase.auth.onAuthStateChange(async (event, session) => {
  if (event === "SIGNED_IN" && session?.user) {
    user.value = session.user;
    // Add a small delay before fetching store data
    setTimeout(async () => {
      await fetchStoreData(session.user.id);
      if (isPublicRoute.value) {
        router.push("/");
      }
    }, 500);
  } else if (event === "SIGNED_OUT") {
    user.value = null;
    storeName.value = "";
    if (!isPublicRoute.value) {
      router.push("/login");
    }
  }
});
</script>

<style>
#toast-container {
  position: fixed;
  top: 1rem;
  right: 1rem;
  z-index: 9999;
  pointer-events: none;
}

#toast-container .alert {
  pointer-events: auto;
  cursor: pointer;
  max-width: 24rem;
  min-width: 20rem;
}

.dashboard-container {
  @apply p-4 lg:p-8 max-w-7xl mx-auto;
}
</style>
