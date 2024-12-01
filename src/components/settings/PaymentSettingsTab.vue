<template>
  <div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center">
          <h2 class="card-title">Payment Methods</h2>
          <button 
            class="btn btn-primary"
            @click="openAddModal"
          >
            Add Method
          </button>
        </div>

        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Type</th>
                <th>Account</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="method in methods" :key="method.id">
                <td>{{ method.name }}</td>
                <td>{{ formatPaymentType(method.type) }}</td>
                <td>{{ method.account_number }}</td>
                <td>
                  <div class="badge" :class="method.is_active ? 'badge-success' : 'badge-error'">
                    {{ method.is_active ? 'Active' : 'Inactive' }}
                  </div>
                </td>
                <td>
                  <div class="flex gap-2">
                    <button 
                      class="btn btn-sm btn-ghost"
                      @click="editMethod(method)"
                    >
                      Edit
                    </button>
                    <button 
                      class="btn btn-sm btn-ghost text-error"
                      @click="deleteMethod(method)"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Add/Edit Modal -->
    <dialog ref="modal" class="modal">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">
          {{ editingMethod ? 'Edit Payment Method' : 'Add Payment Method' }}
        </h3>

        <form @submit.prevent="saveMethod" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Method Name</span>
            </label>
            <input 
              v-model="form.name"
              type="text" 
              class="input input-bordered"
              required
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Type</span>
            </label>
            <select 
              v-model="form.type"
              class="select select-bordered"
              required
            >
              <option value="bank_transfer">Bank Transfer</option>
              <option value="e_wallet">E-Wallet</option>
              <option value="cod">Cash on Delivery</option>
            </select>
          </div>

          <template v-if="form.type !== 'cod'">
            <div class="form-control">
              <label class="label">
                <span class="label-text">Account Number</span>
              </label>
              <input 
                v-model="form.account_number"
                type="text" 
                class="input input-bordered"
                required
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text">Account Name</span>
              </label>
              <input 
                v-model="form.account_name"
                type="text" 
                class="input input-bordered"
                required
              />
            </div>
          </template>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Payment Instructions</span>
            </label>
            <textarea 
              v-model="form.instructions"
              class="textarea textarea-bordered"
            ></textarea>
          </div>

          <div class="form-control">
            <label class="label cursor-pointer">
              <span class="label-text">Active</span>
              <input 
                v-model="form.is_active"
                type="checkbox" 
                class="toggle toggle-primary"
              />
            </label>
          </div>

          <div class="modal-action">
            <button type="button" class="btn" @click="closeModal">Cancel</button>
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="saving"
            >
              {{ saving ? 'Saving...' : 'Save Method' }}
            </button>
          </div>
        </form>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../../lib/supabaseClient'

const props = defineProps({
  storeId: {
    type: String,
    required: true
  }
})

// State
const methods = ref([])
const editingMethod = ref(null)
const saving = ref(false)
const modal = ref(null)

const form = ref({
  name: '',
  type: 'bank_transfer',
  account_number: '',
  account_name: '',
  instructions: '',
  is_active: true
})

// Methods
function formatPaymentType(type) {
  const types = {
    bank_transfer: 'Bank Transfer',
    e_wallet: 'E-Wallet',
    cod: 'Cash on Delivery'
  }
  return types[type] || type
}

function openAddModal() {
  editingMethod.value = null
  form.value = {
    name: '',
    type: 'bank_transfer',
    account_number: '',
    account_name: '',
    instructions: '',
    is_active: true
  }
  modal.value.showModal()
}

function editMethod(method) {
  editingMethod.value = method
  form.value = { ...method }
  modal.value.showModal()
}

function closeModal() {
  modal.value.close()
  editingMethod.value = null
  form.value = {
    name: '',
    type: 'bank_transfer',
    account_number: '',
    account_name: '',
    instructions: '',
    is_active: true
  }
}

async function saveMethod() {
  try {
    saving.value = true

    if (editingMethod.value) {
      const { error } = await supabase
        .from('payment_methods')
        .update({
          name: form.value.name,
          type: form.value.type,
          account_number: form.value.account_number,
          account_name: form.value.account_name,
          instructions: form.value.instructions,
          is_active: form.value.is_active
        })
        .eq('id', editingMethod.value.id)

      if (error) throw error
    } else {
      const { error } = await supabase
        .from('payment_methods')
        .insert({
          store_id: props.storeId,
          name: form.value.name,
          type: form.value.type,
          account_number: form.value.account_number,
          account_name: form.value.account_name,
          instructions: form.value.instructions,
          is_active: form.value.is_active
        })

      if (error) throw error
    }

    await fetchMethods()
    closeModal()
  } catch (error) {
    console.error('Error saving payment method:', error)
    alert('Failed to save payment method')
  } finally {
    saving.value = false
  }
}

async function deleteMethod(method) {
  if (!confirm('Are you sure you want to delete this payment method?')) return

  try {
    const { error } = await supabase
      .from('payment_methods')
      .delete()
      .eq('id', method.id)

    if (error) throw error

    await fetchMethods()
  } catch (error) {
    console.error('Error deleting payment method:', error)
    alert('Failed to delete payment method')
  }
}

async function fetchMethods() {
  try {
    const { data, error } = await supabase
      .from('payment_methods')
      .select('*')
      .eq('store_id', props.storeId)
      .order('created_at', { ascending: false })

    if (error) throw error

    methods.value = data
  } catch (error) {
    console.error('Error fetching payment methods:', error)
  }
}

// Initialize
onMounted(() => {
  fetchMethods()
})
</script>
