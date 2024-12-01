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
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="stroke-current shrink-0 h-6 w-6"
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
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
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  class="inline-block w-5 h-5 stroke-current"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 6h16M4 12h16M4 18h16"
                  ></path>
                </svg>
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
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                >
                  <rect x="3" y="3" width="7" height="7"></rect>
                  <rect x="14" y="3" width="7" height="7"></rect>
                  <rect x="14" y="14" width="7" height="7"></rect>
                  <rect x="3" y="14" width="7" height="7"></rect>
                </svg>
                Dashboard
              </router-link>

              <router-link
                to="/products"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Products' }"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                >
                  <path
                    d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"
                  ></path>
                </svg>
                Products
              </router-link>

              <router-link
                to="/orders"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Orders' }"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                >
                  <path d="M9 17h6"></path>
                  <path d="M9 13h6"></path>
                  <path
                    d="M6 21h12a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2z"
                  ></path>
                </svg>
                Orders
              </router-link>

              <router-link
                to="/customers"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Customers' }"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                >
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                  <circle cx="9" cy="7" r="4"></circle>
                  <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                  <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                </svg>
                Customers
              </router-link>

              <router-link
                to="/settings"
                class="flex items-center gap-3 p-3 rounded-lg hover:bg-base-200"
                :class="{ 'bg-base-200': $route.name === 'Settings' }"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                >
                  <circle cx="12" cy="12" r="3"></circle>
                  <path
                    d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"
                  ></path>
                </svg>
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
import { supabase } from "./lib/supabaseClient";
import { useToast } from "./composables/useToast";

const router = useRouter();
const route = useRoute();
const toast = useToast();

// State
const initializing = ref(true);
const error = ref(null);
const storeName = ref("");
const user = ref(null);

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
    const { data: store, error: storeError } = await supabase
      .from("stores")
      .select("name")
      .eq("affiliator_id", userId)
      .maybeSingle();

    if (storeError) throw storeError;
    if (store) {
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
