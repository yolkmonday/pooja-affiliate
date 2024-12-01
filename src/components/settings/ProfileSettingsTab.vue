<template>
  <div class="space-y-6">
    <!-- Profile Information -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">Profile Information</h2>
        
        <form @submit.prevent="saveProfile" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Full Name</span>
            </label>
            <input 
              v-model="form.full_name"
              type="text" 
              class="input input-bordered"
              required
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Email</span>
            </label>
            <input 
              v-model="form.email"
              type="email" 
              class="input input-bordered"
              disabled
            />
            <label class="label">
              <span class="label-text-alt">Email cannot be changed</span>
            </label>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Phone Number</span>
            </label>
            <input 
              v-model="form.phone"
              type="tel" 
              class="input input-bordered"
            />
          </div>

          <div class="flex justify-end">
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="saving"
            >
              {{ saving ? 'Saving...' : 'Save Profile' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Security Settings -->
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">Change Password</h2>
        
        <form @submit.prevent="changePassword" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Current Password</span>
            </label>
            <input 
              v-model="passwordForm.current"
              type="password" 
              class="input input-bordered"
              required
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">New Password</span>
            </label>
            <input 
              v-model="passwordForm.new"
              type="password" 
              class="input input-bordered"
              required
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Confirm New Password</span>
            </label>
            <input 
              v-model="passwordForm.confirm"
              type="password" 
              class="input input-bordered"
              required
            />
          </div>

          <div class="flex justify-end">
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="changingPassword"
            >
              {{ changingPassword ? 'Updating...' : 'Update Password' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '../../lib/supabaseClient'
import { useToast } from '../../composables/useToast'

const toast = useToast()

const props = defineProps({
  userData: {
    type: Object,
    required: true
  }
})

// State
const saving = ref(false)
const changingPassword = ref(false)

const form = ref({
  full_name: props.userData.user_metadata?.full_name || '',
  email: props.userData.email,
  phone: props.userData.user_metadata?.phone || ''
})

const passwordForm = ref({
  current: '',
  new: '',
  confirm: ''
})

// Methods
async function saveProfile() {
  try {
    saving.value = true

    const { error } = await supabase.auth.updateUser({
      data: {
        full_name: form.value.full_name,
        phone: form.value.phone
      }
    })

    if (error) throw error

    toast.success('Profile updated successfully')
  } catch (error) {
    console.error('Error updating profile:', error)
    toast.error('Failed to update profile')
  } finally {
    saving.value = false
  }
}

async function changePassword() {
  try {
    if (passwordForm.value.new !== passwordForm.value.confirm) {
      toast.error('New passwords do not match')
      return
    }

    changingPassword.value = true

    const { error } = await supabase.auth.updateUser({
      password: passwordForm.value.new
    })

    if (error) throw error

    toast.success('Password updated successfully')
    passwordForm.value = { current: '', new: '', confirm: '' }
  } catch (error) {
    console.error('Error changing password:', error)
    toast.error(error.message)
  } finally {
    changingPassword.value = false
  }
}
</script>
