<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-2xl font-bold">Orders</h1>
        <p class="text-gray-600">Manage and process customer orders</p>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="flex flex-col sm:flex-row gap-4 mb-6">
      <div class="flex-1">
        <div class="join w-full max-w-md">
          <input 
            v-model="searchQuery"
            class="input input-bordered join-item flex-1" 
            placeholder="Search by order number or customer..."
          />
          <button class="btn join-item">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
          </button>
        </div>
      </div>
      <div class="flex gap-2">
        <select v-model="statusFilter" class="select select-bordered w-full max-w-xs">
          <option value="">All Status</option>
          <option value="pending">Pending</option>
          <option value="confirmed">Confirmed</option>
          <option value="processing">Processing</option>
          <option value="shipped">Shipped</option>
          <option value="delivered">Delivered</option>
          <option value="cancelled">Cancelled</option>
        </select>
        <select v-model="dateFilter" class="select select-bordered w-full max-w-xs">
          <option value="all">All Time</option>
          <option value="today">Today</option>
          <option value="week">This Week</option>
          <option value="month">This Month</option>
        </select>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Order Details</th>
                <th>Customer</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Payment</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in filteredOrders" :key="order.id" class="hover">
                <td>
                  <div>
                    <div class="font-bold">#{{ order.order_number }}</div>
                    <div class="text-sm opacity-50">{{ formatDate(order.created_at) }}</div>
                  </div>
                </td>
                <td>
                  <div>
                    <div class="font-bold">{{ order.customer.name }}</div>
                    <div class="text-sm opacity-50">{{ order.customer.phone }}</div>
                  </div>
                </td>
                <td>
                  <div>
                    <div class="font-bold">Rp {{ formatNumber(order.total_amount) }}</div>
                    <div class="text-sm opacity-50">{{ order.order_items.length }} items</div>
                  </div>
                </td>
                <td>
                  <div class="badge" :class="getStatusBadgeClass(order.status)">
                    {{ order.status }}
                  </div>
                </td>
                <td>
                  <div class="badge" :class="getPaymentBadgeClass(order.payment_status)">
                    {{ order.payment_status }}
                  </div>
                </td>
                <td>
                  <button @click="viewOrder(order)" class="btn btn-sm btn-ghost">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                      <circle cx="12" cy="12" r="3"></circle>
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination -->
        <div class="flex justify-between items-center mt-4">
          <div class="text-sm text-gray-600">
            Showing {{ startIndex + 1 }} to {{ endIndex }} of {{ totalOrders }} orders
          </div>
          <div class="join">
            <button 
              class="join-item btn" 
              :disabled="currentPage === 1"
              @click="currentPage--"
            >
              «
            </button>
            <button class="join-item btn">Page {{ currentPage }}</button>
            <button 
              class="join-item btn" 
              :disabled="endIndex >= totalOrders"
              @click="currentPage++"
            >
              »
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Order Details Modal -->
    <dialog id="order_modal" class="modal">
      <div class="modal-box max-w-3xl">
        <h3 class="font-bold text-lg mb-4">
          Order #{{ selectedOrder?.order_number }}
        </h3>
        
        <div v-if="selectedOrder" class="space-y-6">
          <!-- Order Status -->
          <div class="flex justify-between items-center">
            <div class="badge badge-lg" :class="getStatusBadgeClass(selectedOrder.status)">
              {{ selectedOrder.status }}
            </div>
            <select 
              v-model="selectedOrder.status" 
              class="select select-bordered"
              @change="updateOrderStatus(selectedOrder)"
            >
              <option value="pending">Pending</option>
              <option value="confirmed">Confirmed</option>
              <option value="processing">Processing</option>
              <option value="shipped">Shipped</option>
              <option value="delivered">Delivered</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>

          <!-- Customer Details -->
          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">Customer Details</h4>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <div class="text-sm opacity-50">Name</div>
                <div>{{ selectedOrder.customer.name }}</div>
              </div>
              <div>
                <div class="text-sm opacity-50">Phone</div>
                <div>{{ selectedOrder.customer.phone }}</div>
              </div>
            </div>
          </div>

          <!-- Shipping Details -->
          <div class="bg-base-200 p-4 rounded-lg">
            <h4 class="font-semibold mb-2">Shipping Details</h4>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <div class="text-sm opacity-50">Address</div>
                <div>{{ selectedOrder.shipping_address.address }}</div>
              </div>
              <div>
                <div class="text-sm opacity-50">Courier</div>
                <div>{{ selectedOrder.shipping_courier }} - {{ selectedOrder.shipping_service }}</div>
              </div>
              <div v-if="selectedOrder.tracking_number">
                <div class="text-sm opacity-50">Tracking Number</div>
                <div>{{ selectedOrder.tracking_number }}</div>
              </div>
            </div>
          </div>

          <!-- Order Items -->
          <div>
            <h4 class="font-semibold mb-2">Order Items</h4>
            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr>
                    <th>Product</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Subtotal</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in selectedOrder.order_items" :key="item.id">
                    <td>
                      <div class="flex items-center gap-2">
                        <div class="avatar">
                          <div class="w-8 h-8">
                            <img :src="item.product.images[0]" :alt="item.product.name" class="rounded" />
                          </div>
                        </div>
                        <div>{{ item.product.name }}</div>
                      </div>
                    </td>
                    <td>{{ item.quantity }}</td>
                    <td>Rp {{ formatNumber(item.unit_price) }}</td>
                    <td>Rp {{ formatNumber(item.subtotal) }}</td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="3" class="text-right font-semibold">Subtotal</td>
                    <td>Rp {{ formatNumber(selectedOrder.subtotal) }}</td>
                  </tr>
                  <tr>
                    <td colspan="3" class="text-right font-semibold">Shipping Fee</td>
                    <td>Rp {{ formatNumber(selectedOrder.shipping_fee) }}</td>
                  </tr>
                  <tr>
                    <td colspan="3" class="text-right font-semibold">Platform Fee (3%)</td>
                    <td>Rp {{ formatNumber(selectedOrder.platform_commission_amount) }}</td>
                  </tr>
                  <tr v-if="selectedOrder.affiliate_commission_amount">
                    <td colspan="3" class="text-right font-semibold">Affiliate Commission</td>
                    <td>Rp {{ formatNumber(selectedOrder.affiliate_commission_amount) }}</td>
                  </tr>
                  <tr class="text-lg">
                    <td colspan="3" class="text-right font-bold">Total</td>
                    <td class="font-bold">Rp {{ formatNumber(selectedOrder.total_amount) }}</td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </div>

        <div class="modal-action">
          <button class="btn" @click="closeOrderModal">Close</button>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabaseClient'

// State
const orders = ref([])
const selectedOrder = ref(null)
const searchQuery = ref('')
const statusFilter = ref('')
const dateFilter = ref('all')
const currentPage = ref(1)
const itemsPerPage = 10
const totalOrders = ref(0)
const storeId = ref(null)

// Computed
const filteredOrders = computed(() => {
  let filtered = [...orders.value]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(order => 
      order.order_number.toLowerCase().includes(query) ||
      order.customer.name.toLowerCase().includes(query)
    )
  }

  if (statusFilter.value) {
    filtered = filtered.filter(order => 
      order.status === statusFilter.value
    )
  }

  if (dateFilter.value !== 'all') {
    const now = new Date()
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const orderDate = new Date(order.created_at)

    switch (dateFilter.value) {
      case 'today':
        filtered = filtered.filter(order => 
          new Date(order.created_at) >= today
        )
        break
      case 'week':
        const weekAgo = new Date(today)
        weekAgo.setDate(weekAgo.getDate() - 7)
        filtered = filtered.filter(order => 
          new Date(order.created_at) >= weekAgo
        )
        break
      case 'month':
        const monthAgo = new Date(today)
        monthAgo.setMonth(monthAgo.getMonth() - 1)
        filtered = filtered.filter(order => 
          new Date(order.created_at) >= monthAgo
        )
        break
    }
  }

  return filtered
})

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, totalOrders.value))

// Methods
function formatNumber(number) {
  return new Intl.NumberFormat('id-ID').format(number)
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('id-ID', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

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

function getPaymentBadgeClass(status) {
  const classes = {
    pending: 'badge-warning',
    settlement: 'badge-success',
    deny: 'badge-error',
    cancel: 'badge-error',
    expire: 'badge-error',
    refund: 'badge-info'
  }
  return classes[status] || 'badge-ghost'
}

function viewOrder(order) {
  selectedOrder.value = order
  document.getElementById('order_modal').showModal()
}

function closeOrderModal() {
  document.getElementById('order_modal').close()
  selectedOrder.value = null
}

async function updateOrderStatus(order) {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status: order.status })
      .eq('id', order.id)

    if (error) throw error

    // Refresh orders list
    await fetchOrders()
  } catch (error) {
    console.error('Error updating order status:', error)
    alert('Failed to update order status')
  }
}

async function fetchOrders() {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .select('id')
      .eq('seller_id', user.id)
      .single()

    if (storeError) throw storeError
    
    storeId.value = store.id

    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        customer:customers (
          name,
          phone
        ),
        order_items (
          id,
          quantity,
          unit_price,
          subtotal,
          product:products (
            name,
            images
          )
        )
      `)
      .eq('store_id', store.id)
      .order('created_at', { ascending: false })

    if (error) throw error

    orders.value = data
    totalOrders.value = data.length
  } catch (error) {
    console.error('Error fetching orders:', error)
  }
}

onMounted(() => {
  fetchOrders()
})
</script>
