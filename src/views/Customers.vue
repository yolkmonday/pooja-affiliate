<template>
  <div class="dashboard-container">
    <!-- Page Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-2xl font-bold">Customers</h1>
        <p class="text-gray-600">View and manage your customer base</p>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="flex flex-col sm:flex-row gap-4 mb-6">
      <div class="flex-1">
        <div class="join w-full max-w-md">
          <input 
            v-model="searchQuery"
            class="input input-bordered join-item flex-1" 
            placeholder="Search customers..."
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
        <select v-model="sortBy" class="select select-bordered w-full max-w-xs">
          <option value="recent">Most Recent</option>
          <option value="orders">Most Orders</option>
          <option value="spent">Highest Spent</option>
        </select>
      </div>
    </div>

    <!-- Customers Table -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Customer</th>
                <th>Contact</th>
                <th>Orders</th>
                <th>Total Spent</th>
                <th>Last Order</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="customer in sortedCustomers" :key="customer.id" class="hover">
                <td>
                  <div class="flex items-center gap-3">
                    <div class="avatar placeholder">
                      <div class="bg-neutral text-neutral-content rounded-full w-10">
                        <span>{{ getInitials(customer.name) }}</span>
                      </div>
                    </div>
                    <div>
                      <div class="font-bold">{{ customer.name }}</div>
                      <div class="text-sm opacity-50">Customer since {{ formatDate(customer.created_at) }}</div>
                    </div>
                  </div>
                </td>
                <td>
                  <div>
                    <div>{{ customer.email }}</div>
                    <div class="text-sm opacity-50">{{ customer.phone }}</div>
                  </div>
                </td>
                <td>{{ customer.total_orders }}</td>
                <td>Rp {{ formatNumber(customer.total_spent) }}</td>
                <td>{{ formatDate(customer.last_order_date) }}</td>
                <td>
                  <button @click="viewCustomer(customer)" class="btn btn-sm btn-ghost">
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
            Showing {{ startIndex + 1 }} to {{ endIndex }} of {{ totalCustomers }} customers
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
              :disabled="endIndex >= totalCustomers"
              @click="currentPage++"
            >
              »
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Customer Details Modal -->
    <dialog id="customer_modal" class="modal">
      <div class="modal-box max-w-3xl">
        <h3 class="font-bold text-lg mb-4" v-if="selectedCustomer">
          {{ selectedCustomer.name }}
        </h3>
        
        <div v-if="selectedCustomer" class="space-y-6">
          <!-- Customer Info -->
          <div class="grid grid-cols-2 gap-4 bg-base-200 p-4 rounded-lg">
            <div>
              <div class="text-sm opacity-50">Email</div>
              <div>{{ selectedCustomer.email }}</div>
            </div>
            <div>
              <div class="text-sm opacity-50">Phone</div>
              <div>{{ selectedCustomer.phone }}</div>
            </div>
            <div>
              <div class="text-sm opacity-50">Total Orders</div>
              <div>{{ selectedCustomer.total_orders }}</div>
            </div>
            <div>
              <div class="text-sm opacity-50">Total Spent</div>
              <div>Rp {{ formatNumber(selectedCustomer.total_spent) }}</div>
            </div>
          </div>

          <!-- Customer Addresses -->
          <div>
            <h4 class="font-semibold mb-2">Saved Addresses</h4>
            <div class="space-y-2">
              <div 
                v-for="(address, index) in selectedCustomer.address" 
                :key="index"
                class="bg-base-200 p-4 rounded-lg"
              >
                <div class="font-medium">{{ address.recipient_name }}</div>
                <div>{{ address.phone }}</div>
                <div>{{ address.address }}</div>
                <div>{{ address.city }}, {{ address.postal_code }}</div>
              </div>
            </div>
          </div>

          <!-- Order History -->
          <div>
            <h4 class="font-semibold mb-2">Order History</h4>
            <div class="overflow-x-auto">
              <table class="table table-sm">
                <thead>
                  <tr>
                    <th>Order ID</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="order in customerOrders" :key="order.id">
                    <td>#{{ order.order_number }}</td>
                    <td>{{ formatDate(order.created_at) }}</td>
                    <td>
                      <div class="badge" :class="getStatusBadgeClass(order.status)">
                        {{ order.status }}
                      </div>
                    </td>
                    <td>Rp {{ formatNumber(order.total_amount) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="modal-action">
          <button class="btn" @click="closeCustomerModal">Close</button>
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
const customers = ref([])
const selectedCustomer = ref(null)
const customerOrders = ref([])
const searchQuery = ref('')
const sortBy = ref('recent')
const currentPage = ref(1)
const itemsPerPage = 10
const totalCustomers = ref(0)
const storeId = ref(null)

// Computed
const sortedCustomers = computed(() => {
  let filtered = [...customers.value]

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(customer => 
      customer.name.toLowerCase().includes(query) ||
      customer.email?.toLowerCase().includes(query) ||
      customer.phone?.includes(query)
    )
  }

  switch (sortBy.value) {
    case 'orders':
      filtered.sort((a, b) => b.total_orders - a.total_orders)
      break
    case 'spent':
      filtered.sort((a, b) => b.total_spent - a.total_spent)
      break
    default: // recent
      filtered.sort((a, b) => new Date(b.last_order_date) - new Date(a.last_order_date))
  }

  return filtered
})

const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, totalCustomers.value))

// Methods
function formatNumber(number) {
  return new Intl.NumberFormat('id-ID').format(number)
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('id-ID', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

function getInitials(name) {
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
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

async function viewCustomer(customer) {
  selectedCustomer.value = customer
  await fetchCustomerOrders(customer.id)
  document.getElementById('customer_modal').showModal()
}

function closeCustomerModal() {
  document.getElementById('customer_modal').close()
  selectedCustomer.value = null
  customerOrders.value = []
}

async function fetchCustomerOrders(customerId) {
  try {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('customer_id', customerId)
      .order('created_at', { ascending: false })

    if (error) throw error

    customerOrders.value = data
  } catch (error) {
    console.error('Error fetching customer orders:', error)
  }
}

async function fetchCustomers() {
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
      .from('customers')
      .select('*')
      .eq('store_id', store.id)
      .order('created_at', { ascending: false })

    if (error) throw error

    customers.value = data
    totalCustomers.value = data.length
  } catch (error) {
    console.error('Error fetching customers:', error)
  }
}

onMounted(() => {
  fetchCustomers()
})
</script>
