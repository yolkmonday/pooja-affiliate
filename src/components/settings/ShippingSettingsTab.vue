<template>
  <div>
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <div class="flex justify-between items-center">
          <h2 class="card-title">Shipping Methods</h2>
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
                <th>Description</th>
                <th>Base Cost</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="method in methods" :key="method.id">
                <td>{{ method.name }}</td>
                <td>{{ method.description }}</td>
                <td>Rp {{ formatNumber(method.base_cost) }}</td>
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
          {{ editingMethod ? 'Edit Shipping Method' : 'Add Shipping Method' }}
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
              <span class="label-text">Description</span>
            </label>
            <textarea 
              v-model="form.description"
              class="textarea textarea-bordered"
            ></textarea>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Base Cost</span>
            </label>
            <input 
              v-model="form.base_cost"
              type="number" 
              class="input input-bordered"
              required
            />
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
import { useToast } from '../../composables/useToast'

const toast = useToast()

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
  description: '',
  base_cost: 0,
  is_active: true
})

// Methods
function formatNumber(number) {
  return new Intl.NumberFormat('id-ID').format(number)
}

function openAddModal() {
  editingMethod.value = null
  form.value = {
    name: '',
    description: '',
    base_cost: 0,
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
    description: '',
    base_cost: 0,
    is_active: true
  }
}

async function saveMethod() {
  try {
    saving.value = true

    if (editingMethod.value) {
      const { error } = await supabase
        .from('shipping_methods')
        .update({
          name: form.value.name,
          description: form.value.description,
          base_cost: form.value.base_cost,
          is_active: form.value.is_active
        })
        .eq('id', editingMethod.value.id)

      if (error) throw error
      toast.success('Shipping method updated successfully')
    } else {
      const { error } = await supabase
        .from('shipping_methods')
        .insert({
          store_id: props.storeId,
          name: form.value.name,
          description: form.value.description,
          base_cost: form.value.base_cost,
          is_active: form.value.is_active
        })

      if (error) throw error
      toast.success('Shipping method added successfully')
    }

    await fetchMethods()
    closeModal()
  } catch (error) {
    console.error('Error saving shipping method:', error)
    toast.error('Failed to save shipping method')
  } finally {
    saving.value = false
  }
}

async function deleteMethod(method) {
  if (!confirm('Are you sure you want to delete this shipping method?')) return

  try {
    const { error } = await supabase
      .from('shipping_methods')
      .delete()
      .eq('id', method.id)

    if (error) throw error

    toast.success('Shipping method deleted successfully')
    await fetchMethods()
  } catch (error) {
    console.error('Error deleting shipping method:', error)
    toast.error('Failed to delete shipping method')
  }
}

async function fetchMethods() {
  try {
    const { data, error } = await supabase
      .from('shipping_methods')
      .select('*')
      .eq('store_id', props.storeId)
      .order('created_at', { ascending: false })

    if (error) throw error

    methods.value = data
  } catch (error) {
    console.error('Error fetching shipping methods:', error)
    toast.error('Failed to fetch shipping methods')
  }
}

// Initialize
onMounted(() => {
  fetchMethods()
})
</script>
