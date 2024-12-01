<template>
  <div class="min-h-screen flex items-center justify-center">
    <div class="card bg-base-100 w-full max-w-md shadow-xl">
      <div class="card-body">
        <!-- Add logo -->
        <div class="flex justify-center mb-4">
          <img src="/poojalogo.png" alt="Pooja Logo" class="h-16 w-auto" />
        </div>

        <h2 class="card-title justify-center mb-4">Login to Seller Dashboard</h2>

        <!-- Login Form -->
        <form @submit.prevent="handleLogin" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Email</span>
            </label>
            <input 
              v-model="form.email"
              type="email" 
              class="input input-bordered" 
              required
              :disabled="loading"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Password</span>
            </label>
            <input 
              v-model="form.password"
              type="password" 
              class="input input-bordered" 
              required
              :disabled="loading"
            />
            <label class="label">
              <span class="label-text-alt">
                <a href="#" class="link link-primary" @click.prevent="handleForgotPassword">
                  Forgot password?
                </a>
              </span>
            </label>
          </div>

          <!-- Submit Button -->
          <div class="form-control mt-6">
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="loading"
            >
              {{ loading ? 'Logging in...' : 'Login' }}
            </button>
          </div>

          <!-- Register Link -->
          <div class="text-center text-sm">
            Don't have an account? 
            <router-link to="/register" class="link link-primary">Register here</router-link>
          </div>
        </form>
      </div>
    </div>

    <!-- Reset Password Modal -->
    <dialog ref="resetModal" class="modal">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">Reset Password</h3>
        
        <form @submit.prevent="handleResetPassword" class="space-y-4">
          <div class="form-control">
            <label class="label">
              <span class="label-text">Email</span>
            </label>
            <input 
              v-model="resetEmail"
              type="email" 
              class="input input-bordered" 
              required
              :disabled="resetting"
            />
          </div>

          <div class="modal-action">
            <button 
              type="button" 
              class="btn" 
              @click="closeResetModal"
              :disabled="resetting"
            >
              Cancel
            </button>
            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="resetting"
            >
              {{ resetting ? 'Sending...' : 'Send Reset Link' }}
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabaseClient'
import { useToast } from '../composables/useToast'

const router = useRouter()
const toast = useToast()

// Form state
const form = ref({
  email: '',
  password: ''
})

const loading = ref(false)

// Reset password state
const resetModal = ref(null)
const resetEmail = ref('')
const resetting = ref(false)

// Handle login
async function handleLogin() {
  try {
    loading.value = true

    const { data, error } = await supabase.auth.signInWithPassword({
      email: form.value.email,
      password: form.value.password
    })

    if (error) {
      if (error.message.includes('Invalid login')) {
        toast.error('Invalid email or password')
      } else if (error.message.includes('Email not confirmed')) {
        toast.warning('Please verify your email address first')
      } else {
        toast.error(error.message)
      }
      return
    }

    // Check if user has a store
    const { data: store, error: storeError } = await supabase
      .from('stores')
      .select('id')
      .eq('seller_id', data.user.id)
      .single()

    if (storeError) {
      toast.error('Failed to load store information')
      return
    }

    toast.success('Login successful')
    router.push('/')
  } catch (error) {
    console.error('Login error:', error)
    toast.error('Failed to login. Please try again.')
  } finally {
    loading.value = false
  }
}

// Handle forgot password
function handleForgotPassword() {
  resetEmail.value = form.value.email
  resetModal.value.showModal()
}

function closeResetModal() {
  resetModal.value.close()
  resetEmail.value = ''
}

async function handleResetPassword() {
  try {
    resetting.value = true

    const { error } = await supabase.auth.resetPasswordForEmail(resetEmail.value, {
      redirectTo: `${window.location.origin}/reset-password`
    })

    if (error) throw error

    toast.success('Password reset link sent to your email')
    closeResetModal()
  } catch (error) {
    console.error('Reset password error:', error)
    toast.error('Failed to send reset link. Please try again.')
  } finally {
    resetting.value = false
  }
}
</script>
