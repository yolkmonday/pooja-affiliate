<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-2xl font-bold">Dashboard</h1>
        <p class="text-gray-600">Welcome back, {{ storeName }}</p>
      </div>
      <a :href="storeUrl" target="_blank" class="btn btn-primary">
        View Store
        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-2" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
          <polyline points="15 3 21 3 21 9"></polyline>
          <line x1="10" y1="14" x2="21" y2="3"></line>
        </svg>
      </a>
    </div>

    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <!-- Total Sales -->
      <div class="card-stats">
        <div class="card-body">
          <div class="flex items-center justify-between">
            <h2 class="card-title text-gray-600">Total Sales</h2>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <line x1="12" y1="1" x2="12" y2="23"></line>
              <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold">Rp {{ formatNumber(stats.totalSales) }}</p>
          <div class="text-sm text-gray-500">
            <span :class="stats.salesTrend >= 0 ? 'text-success' : 'text-error'">
              {{ stats.salesTrend >= 0 ? '↑' : '↓' }} {{ Math.abs(stats.salesTrend) }}%
            </span>
            vs last month
          </div>
        </div>
      </div>

      <!-- Total Orders -->
      <div class="card-stats">
        <div class="card-body">
          <div class="flex items-center justify-between">
            <h2 class="card-title text-gray-600">Orders</h2>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
              <line x1="3" y1="6" x2="21" y2="6"></line>
              <path d="M16 10a4 4 0 0 1-8 0"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold">{{ stats.totalOrders }}</p>
          <div class="text-sm text-gray-500">
            <span :class="stats.ordersTrend >= 0 ? 'text-success' : 'text-error'">
              {{ stats.ordersTrend >= 0 ? '↑' : '↓' }} {{ Math.abs(stats.ordersTrend) }}%
            </span>
            vs last month
          </div>
        </div>
      </div>

      <!-- Products -->
      <div class="card-stats">
        <div class="card-body">
          <div class="flex items-center justify-between">
            <h2 class="card-title text-gray-600">Products</h2>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold">{{ stats.totalProducts }}</p>
          <div class="text-sm text-gray-500">
            {{ stats.lowStockProducts }} low stock items
          </div>
        </div>
      </div>

      <!-- Customers -->
      <div class="card-stats">
        <div class="card-body">
          <div class="flex items-center justify-between">
            <h2 class="card-title text-gray-600">Customers</h2>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
              <circle cx="9" cy="7" r="4"></circle>
              <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
              <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
          </div>
          <p class="text-2xl font-bold">{{ stats.totalCustomers }}</p>
          <div class="text-sm text-gray-500">
            {{ stats.newCustomers }} new this month
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Orders -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center mb-4">
          <h2 class="card-title">Recent Orders</h2>
          <router-link to="/orders" class="btn btn-sm btn-ghost">
            View All
          </router-link>
        </div>
        
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Status</th>
                <th>Total</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in recentOrders" :key="order.id" class="hover">
                <td>{{ order.order_number }}</td>
                <td>{{ order.customer_name }}</td>
                <td>
                  <div class="badge" :class="getStatusBadgeClass(order.status)">
                    {{ order.status }}
                  </div>
                </td>
                <td>Rp {{ formatNumber(order.total_amount) }}</td>
                <td>{{ formatDate(order.created_at) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabaseClient'

const storeName = ref('')
const storeUrl = ref('')
const stats = ref({
  totalSales: 0,
  salesTrend: 0,
  totalOrders: 0,
  ordersTrend: 0,
  totalProducts: 0,
  lowStockProducts: 0,
  totalCustomers: 0,
  newCustomers: 0
})
const recentOrders = ref([])

// Format number to currency
function formatNumber(number) {
  return new Intl.NumberFormat('id-ID').format(number)
}

// Format date
function formatDate(date) {
  return new Date(date).toLocaleDateString('id-ID', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Get badge class based on order status
function getStatusBadgeClass(status) {
  const classes = {
    pending: 'badge-warning',
    confirmed: 'badge-info',
    processing: 'badge-primary',
    shipped: 'badge-secondary',
    delivered: 'badge-success',
    cancelled: 'badge-error'
  }
  return classes[status] || 'badge-ghost'
}

// Fetch store data
async function fetchStoreData() {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    
    const { data: store, error } = await supabase
      .from('stores')
      .select('*')
      .eq('seller_id', user.id)
      .single()

    if (error) throw error

    storeName.value = store.name
    storeUrl.value = `https://${store.slug}.pooja.id`

    // Fetch statistics
    await Promise.all([
      fetchSalesStats(store.id),
      fetchOrderStats(store.id),
      fetchProductStats(store.id),
      fetchCustomerStats(store.id),
      fetchRecentOrders(store.id)
    ])
  } catch (error) {
    console.error('Error fetching store data:', error)
  }
}

// Fetch sales statistics
async function fetchSalesStats(storeId) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('total_amount, created_at')
      .eq('store_id', storeId)
      .gte('created_at', new Date(new Date().setMonth(new Date().getMonth() - 1)).toISOString())

    if (error) throw error

    const totalSales = data.reduce((sum, order) => sum + order.total_amount, 0)
    stats.value.totalSales = totalSales
    stats.value.salesTrend = 15 // Mock trend data
  } catch (error) {
    console.error('Error fetching sales stats:', error)
  }
}

// Fetch order statistics
async function fetchOrderStats(storeId) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('id')
      .eq('store_id', storeId)

    if (error) throw error

    stats.value.totalOrders = data.length
    stats.value.ordersTrend = 8 // Mock trend data
  } catch (error) {
    console.error('Error fetching order stats:', error)
  }
}

// Fetch product statistics
async function fetchProductStats(storeId) {
  try {
    const { data: products, error: productsError } = await supabase
      .from('products')
      .select('id')
      .eq('store_id', storeId)

    if (productsError) throw productsError

    const { data: inventory, error: inventoryError } = await supabase
      .from('inventory')
      .select('status')
      .eq('status', 'low_stock')
      .in('product_id', products.map(p => p.id))

    if (inventoryError) throw inventoryError

    stats.value.totalProducts = products.length
    stats.value.lowStockProducts = inventory.length
  } catch (error) {
    console.error('Error fetching product stats:', error)
  }
}

// Fetch customer statistics
async function fetchCustomerStats(storeId) {
  try {
    const { data, error } = await supabase
      .from('customers')
      .select('id, created_at')
      .eq('store_id', storeId)

    if (error) throw error

    stats.value.totalCustomers = data.length
    stats.value.newCustomers = data.filter(customer => 
      new Date(customer.created_at) > new Date(new Date().setMonth(new Date().getMonth() - 1))
    ).length
  } catch (error) {
    console.error('Error fetching customer stats:', error)
  }
}

// Fetch recent orders
async function fetchRecentOrders(storeId) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select(`
        id,
        order_number,
        status,
        total_amount,
        created_at,
        customers (name)
      `)
      .eq('store_id', storeId)
      .order('created_at', { ascending: false })
      .limit(5)

    if (error) throw error

    recentOrders.value = data.map(order => ({
      ...order,
      customer_name: order.customers?.name || 'Unknown Customer'
    }))
  } catch (error) {
    console.error('Error fetching recent orders:', error)
  }
}

onMounted(() => {
  fetchStoreData()
})
</script>
