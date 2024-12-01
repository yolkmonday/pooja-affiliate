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
          <!-- Store Info -->
          <div class="form-control">
            <label class="label">
              <span class="label-text">Store Name</span>
            </label>
            <input
              v-model="form.store_name"
              type="text"
              class="input input-bordered"
              required
              :disabled="registering"
            />
          </div>

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
              <span class="label-text">Password</span>
            </label>
            <input
              v-model="form.password"
              type="password"
              class="input input-bordered"
              required
              minlength="6"
              :disabled="registering"
            />
            <label class="label">
              <span class="label-text-alt">At least 6 characters</span>
            </label>
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Confirm Password</span>
            </label>
            <input
              v-model="form.confirm_password"
              type="password"
              class="input input-bordered"
              required
              :disabled="registering"
            />
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
  store_name: "",
  full_name: "",
  email: "",
  password: "",
  confirm_password: "",
});

const registering = ref(false);

// Generate a URL-friendly slug from store name
function generateSlug(name) {
  return name
    .toLowerCase()
    .replace(/[^\w\s-]/g, "") // Remove special characters
    .replace(/\s+/g, "-") // Replace spaces with hyphens
    .replace(/-+/g, "-"); // Replace multiple hyphens with single hyphen
}

// Handle registration
async function handleRegister() {
  try {
    // Validate passwords match
    if (form.value.password !== form.value.confirm_password) {
      toast.error("Passwords do not match");
      return;
    }

    registering.value = true;

    // Step 1: Create user account with auto-confirm for development
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: form.value.email,
      password: form.value.password,
      options: {
        data: {
          full_name: form.value.full_name,
          type: "affiliator",
        },
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

    // Step 2: Create store
    const storeData = {
      affiliator_id: authData.user.id,
      name: form.value.store_name,
      slug: generateSlug(form.value.store_name),
      theme: {
        primary_color: "#6419E6",
        secondary_color: "#D926AA",
        accent_color: "#1FB2A5",
        neutral_color: "#191D24",
        font_family: "Inter, sans-serif",
      },
      social_media: {
        facebook: "",
        instagram: "",
        twitter: "",
        tiktok: "",
      },
    };

    const { error: storeError } = await supabase
      .from("stores")
      .insert([storeData]);

    if (storeError) {
      console.error("Store creation error:", storeError);
      throw storeError;
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
    toast.error("Failed to create account. Please try again.");
  } finally {
    registering.value = false;
  }
}
</script>
