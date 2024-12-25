<template>
  <div class="min-h-screen flex items-center justify-center">
    <div class="card bg-base-100 w-full max-w-md shadow-xl">
      <div class="card-body">
        <!-- Add logo -->
        <div class="flex justify-center mb-4">
          <img src="/poojalogo.png" alt="Pooja Logo" class="h-16 w-auto" />
        </div>

        <h2 class="card-title justify-center mb-4">
          Create Affiliator Account
        </h2>

        <!-- Registration Form -->
        <form @submit.prevent="handleRegister" class="space-y-4">
          <!-- Affiliator Info -->
          <!-- <div class="form-control">
            <label class="label">
              <span class="label-text">Affiliator Name</span>
            </label>
            <input
              v-model="form.affiliator_name"
              type="text"
              class="input input-bordered"
              required
              :disabled="registering"
            />
          </div> -->

          <!-- Personal Info -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Full Name</span>
            </label>
            <input
              v-model="form.full_name"
              type="text"
              class="input input-bordered"
              required
              :disabled="registering"
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
              required
              :disabled="registering"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Phone Number</span>
            </label>
            <input
              v-model="form.phone_number"
              type="tel"
              class="input input-bordered"
              required
              :disabled="registering"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Password</span>
            </label>
            <div class="relative">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                class="input input-bordered w-full"
                required
                minlength="6"
                :disabled="registering"
              />
              <button
                type="button"
                class="absolute inset-y-0 right-0 pr-3 flex items-center text-sm leading-5"
                @click="toggleShowPassword"
              >
                <svg
                  v-if="showPassword"
                  class="h-5 w-5"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-.274.823-.676 1.597-1.186 2.285M15 12a3 3 0 01-6 0 3 3 0 016 0zm-3 3c-1.657 0-3-1.343-3-3s1.343-3 3-3 3 1.343 3 3-1.343 3-3 3z"
                  />
                </svg>
                <svg
                  v-else
                  class="h-5 w-5"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13.875 18.825A10.05 10.05 0 0112 19c-4.477 0-8.268-2.943-9.542-7 .274-.823.676-1.597 1.186-2.285M15 12a3 3 0 11-6 0 3 3 0 016 0zm-3 3c-1.657 0-3-1.343-3-3s1.343-3 3-3 3 1.343 3 3-1.343 3-3 3z"
                  />
                </svg>
              </button>
            </div>
            <label class="label">
              <span class="label-text-alt">At least 6 characters</span>
            </label>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Confirm Password</span>
            </label>
            <div class="relative">
              <input
                v-model="form.confirm_password"
                :type="showConfirmPassword ? 'text' : 'password'"
                class="input input-bordered w-full"
                required
                :disabled="registering"
              />
              <button
                type="button"
                class="absolute inset-y-0 right-0 pr-3 flex items-center text-sm leading-5"
                @click="toggleShowConfirmPassword"
              >
                <svg
                  v-if="showConfirmPassword"
                  class="h-5 w-5"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M2.458 12C3.732 7.943 7.523 5 12 5c4.477 0 8.268 2.943 9.542 7-.274.823-.676 1.597-1.186 2.285M15 12a3 3 0 01-6 0 3 3 0 016 0zm-3 3c-1.657 0-3-1.343-3-3s1.343-3 3-3 3 1.343 3 3-1.343 3-3 3z"
                  />
                </svg>
                <svg
                  v-else
                  class="h-5 w-5"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13.875 18.825A10.05 10.05 0 0112 19c-4.477 0-8.268-2.943-9.542-7 .274-.823.676-1.597 1.186-2.285M15 12a3 3 0 11-6 0 3 3 0 016 0zm-3 3c-1.657 0-3-1.343-3-3s1.343-3 3-3 3 1.343 3 3-1.343 3-3 3z"
                  />
                </svg>
              </button>
            </div>
          </div>

          <!-- Submit Button -->
          <div class="form-control mt-6">
            <button
              type="submit"
              class="btn btn-primary"
              :disabled="registering"
            >
              <span v-if="registering" class="loading loading-spinner"></span>
              {{ registering ? "Creating Account..." : "Create Account" }}
            </button>
          </div>

          <!-- Login Link -->
          <div class="text-center text-sm">
            Already have an account?
            <router-link to="/login" class="link link-primary"
              >Login here</router-link
            >
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { supabase } from "../lib/supabaseClient";
import { useToast } from "../composables/useToast";

const router = useRouter();
const toast = useToast();

// Form state
const form = ref({
  affiliator_name: "",
  full_name: "",
  email: "",
  password: "",
  confirm_password: "",
  phone_number: "",
});

const registering = ref(false);
const showPassword = ref(false);
const showConfirmPassword = ref(false);

// Generate a URL-friendly slug from affiliator name
function generateSlug(name) {
  return name
    .toLowerCase()
    .replace(/[^\w\s-]/g, "") // Remove special characters
    .replace(/\s+/g, "-") // Replace spaces with hyphens
    .replace(/-+/g, "-"); // Replace multiple hyphens with single hyphen
}

// Validate password strength
function isValidPassword(password) {
  return password.length >= 6;
}

// Toggle show/hide password
function toggleShowPassword() {
  showPassword.value = !showPassword.value;
}

function toggleShowConfirmPassword() {
  showConfirmPassword.value = !showConfirmPassword.value;
}

// Handle registration
async function handleRegister() {
  try {
    // Validate passwords match
    if (form.value.password !== form.value.confirm_password) {
      toast.error("Passwords do not match");
      return;
    }

    // Validate password strength
    if (!isValidPassword(form.value.password)) {
      toast.error("Password must be at least 6 characters long");
      return;
    }

    registering.value = true;

    // Step 1: Create user account with auto-confirm for development
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.value.email,
      password: form.value.password,
      options: {
        emailRedirectTo: `${window.location.origin}/login`,
        // For development, don't require email verification
        emailConfirm: false,
      },
    });

    if (authError) {
      if (authError.message.includes("already exists")) {
        toast.error("An account with this email already exists");
      } else {
        toast.error(authError.message);
      }
      return;
    }

    if (!authData.user) {
      throw new Error("Failed to create account");
    }

    // Step 2: Create affiliator
    const affiliatorData = {
      id: authData.user.id,
      name: form.value.affiliator_name,
      email: form.value.email,
      phone_number: form.value.phone_number,
    };

    const { error: affiliatorError } = await supabase
      .from("affiliators")
      .insert([affiliatorData]);

    if (affiliatorError) {
      console.error("Affiliator creation error:", affiliatorError);
      throw affiliatorError;
    }

    // Step 3: Sign in the user
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email: form.value.email,
      password: form.value.password,
    });

    if (signInError) {
      console.error("Sign in error:", signInError);
      throw signInError;
    }

    toast.success("Account created successfully!");
    router.push("/");
  } catch (error) {
    console.error("Registration error:", error);

    // Rollback actions
    if (authData && authData.user) {
      await supabase.auth.api.deleteUser(authData.user.id);
      await supabase.from("affiliators").delete().eq("id", authData.user.id);
    }

    toast.error("Failed to create account. Please try again.");
  } finally {
    registering.value = false;
  }
}
</script>
