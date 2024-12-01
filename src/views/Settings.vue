<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="mb-8">
      <h1 class="text-2xl font-bold">Settings</h1>
      <p class="text-gray-600">Manage your store settings and preferences</p>
    </div>

    <!-- Settings Tabs -->
    <div class="tabs tabs-boxed mb-6">
      <button 
        class="tab" 
        :class="{ 'tab-active': activeTab === 'store' }"
        @click="activeTab = 'store'"
      >
        Store Settings
      </button>
      <button 
        class="tab" 
        :class="{ 'tab-active': activeTab === 'theme' }"
        @click="activeTab = 'theme'"
      >
        Theme
      </button>
      <button 
        class="tab" 
        :class="{ 'tab-active': activeTab === 'shipping' }"
        @click="activeTab = 'shipping'"
      >
        Shipping
      </button>
      <button 
        class="tab" 
        :class="{ 'tab-active': activeTab === 'payment' }"
        @click="activeTab = 'payment'"
      >
        Payment
      </button>
      <button 
        class="tab" 
        :class="{ 'tab-active': activeTab === 'profile' }"
        @click="activeTab = 'profile'"
      >
        Profile
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center min-h-[200px]">
      <span class="loading loading-spinner loading-lg text-primary"></span>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="alert alert-error">
      <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <span>{{ error }}</span>
    </div>

    <!-- Settings Content -->
    <template v-else>
      <!-- Store Settings -->
      <StoreSettingsTab
        v-if="activeTab === 'store'"
        :store-id="storeId"
        :model-value="storeData"
        @update:model-value="updateStoreData"
        @reset="fetchStoreSettings"
      />

      <!-- Theme Settings -->
      <ThemeSettingsTab
        v-if="activeTab === 'theme'"
        :store-id="storeId"
        :model-value="storeData.theme"
        :store-name="storeData.name"
        :store-description="storeData.description"
        :store-logo="storeData.logo_url"
        @update:model-value="updateTheme"
        @reset="resetThemeSettings"
      />

      <!-- Shipping Settings -->
      <ShippingSettingsTab
        v-if="activeTab === 'shipping'"
        :store-id="storeId"
      />

      <!-- Payment Settings -->
      <PaymentSettingsTab
        v-if="activeTab === 'payment'"
        :store-id="storeId"
      />

      <!-- Profile Settings -->
      <ProfileSettingsTab
        v-if="activeTab === 'profile'"
        :user-data="userData"
      />
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useToast } from '../composables/useToast'
import StoreSettingsTab from '../components/settings/StoreSettingsTab.vue'
import ThemeSettingsTab from '../components/settings/ThemeSettingsTab.vue'
import ShippingSettingsTab from '../components/settings/ShippingSettingsTab.vue'
import PaymentSettingsTab from '../components/settings/PaymentSettingsTab.vue'
import ProfileSettingsTab from '../components/settings/ProfileSettingsTab.vue'

const toast = useToast()

// State
const activeTab = ref('store')
const loading = ref(true)
const error = ref(null)
const storeId = ref(null)
const userData = ref(null)

// Store data with default values
const storeData = ref({
  name: '',
  slug: '',
  description: '',
  logo_url: '',
  banner_url: '',
  contact_email: '',
  contact_phone: '',
  address: '',
  theme: {
    primary_color: '#6419E6',
    secondary_color: '#D926AA',
    accent_color: '#1FB2A5',
    neutral_color: '#191D24',
    font_family: 'Inter, sans-serif'
  },
  social_media: {
    facebook: '',
    instagram: '',
    twitter: '',
    tiktok: ''
  }
})

// Methods
function updateStoreData(newData) {
  // Create a new object to avoid reactivity issues
  storeData.value = { ...storeData.value, ...newData }
}

function updateTheme(newTheme) {
  // Create a new object to avoid reactivity issues
  storeData.value = {
    ...storeData.value,
    theme: { ...newTheme }
  }
}

function resetThemeSettings() {
  storeData.value.theme = {
    primary_color: '#6419E6',
    secondary_color: '#D926AA',
    accent_color: '#1FB2A5',
    neutral_color: '#191D24',
    font_family: 'Inter, sans-serif'
  }
}

async function fetchStoreSettings() {
  try {
    loading.value = true
    error.value = null

    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('Not authenticated')

    userData.value = user
    
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .select('*')
      .eq('seller_id', user.id)
      .single()

    if (storeError) throw storeError

    storeId.value = store.id
    storeData.value = {
      ...store,
      theme: store.theme || storeData.value.theme,
      social_media: store.social_media || storeData.value.social_media
    }
  } catch (err) {
    console.error('Error fetching store settings:', err)
    error.value = err.message
    toast.error('Failed to load settings')
  } finally {
    loading.value = false
  }
}

// Initialize
onMounted(() => {
  fetchStoreSettings()
})
</script>
