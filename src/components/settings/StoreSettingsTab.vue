<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title">Store Information</h2>
      
      <form @submit.prevent="save" class="space-y-4">
        <!-- Store Logo -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Store Logo</span>
          </label>
          <div class="flex items-center gap-4">
            <div class="avatar">
              <div class="w-24 rounded">
                <img :src="form.logo_url || '/placeholder-logo.png'" alt="Store logo" />
              </div>
            </div>
            <input 
              type="file" 
              class="file-input file-input-bordered w-full max-w-xs" 
              accept="image/*"
              @change="handleLogoUpload"
            />
          </div>
        </div>

        <!-- Store Banner -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Store Banner</span>
          </label>
          <div class="space-y-4">
            <div class="aspect-[3/1] rounded-lg overflow-hidden bg-base-200">
              <img 
                :src="form.banner_url || '/placeholder-banner.png'" 
                alt="Store banner"
                class="w-full h-full object-cover"
              />
            </div>
            <input 
              type="file" 
              class="file-input file-input-bordered w-full" 
              accept="image/*"
              @change="handleBannerUpload"
            />
            <p class="text-sm text-gray-500">
              Recommended size: 1200x400 pixels
            </p>
          </div>
        </div>

        <!-- Store Name -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Store Name</span>
          </label>
          <input 
            v-model="form.name"
            type="text" 
            class="input input-bordered" 
            required
          />
        </div>

        <!-- Store URL -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Store URL</span>
          </label>
          <div class="join">
            <span class="join-item input input-bordered bg-base-200">
              https://
            </span>
            <input 
              v-model="form.slug"
              type="text" 
              class="join-item input input-bordered flex-1" 
              required
            />
            <span class="join-item input input-bordered bg-base-200">
              .pooja.id
            </span>
          </div>
        </div>

        <!-- Store Description -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Description</span>
          </label>
          <textarea 
            v-model="form.description"
            class="textarea textarea-bordered h-24"
          ></textarea>
        </div>

        <!-- Contact Information -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Contact Email</span>
          </label>
          <input 
            v-model="form.contact_email"
            type="email" 
            class="input input-bordered"
            required
          />
        </div>

        <div class="form-control">
          <label class="label">
            <span class="label-text">Contact Phone</span>
          </label>
          <input 
            v-model="form.contact_phone"
            type="tel" 
            class="input input-bordered"
            required
          />
        </div>

        <!-- Store Address -->
        <div class="form-control">
          <label class="label">
            <span class="label-text">Store Address</span>
          </label>
          <textarea 
            v-model="form.address"
            class="textarea textarea-bordered"
            required
          ></textarea>
        </div>

        <!-- Social Media Links -->
        <div class="space-y-4">
          <h3 class="font-medium">Social Media Links</h3>
          
          <div class="form-control">
            <label class="label">
              <span class="label-text">Facebook</span>
            </label>
            <input 
              v-model="form.social_media.facebook"
              type="url" 
              class="input input-bordered"
              placeholder="https://facebook.com/your-page"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Instagram</span>
            </label>
            <input 
              v-model="form.social_media.instagram"
              type="url" 
              class="input input-bordered"
              placeholder="https://instagram.com/your-account"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">Twitter</span>
            </label>
            <input 
              v-model="form.social_media.twitter"
              type="url" 
              class="input input-bordered"
              placeholder="https://twitter.com/your-account"
            />
          </div>

          <div class="form-control">
            <label class="label">
              <span class="label-text">TikTok</span>
            </label>
            <input 
              v-model="form.social_media.tiktok"
              type="url" 
              class="input input-bordered"
              placeholder="https://tiktok.com/@your-account"
            />
          </div>
        </div>

        <div class="flex justify-end gap-2">
          <button 
            type="button" 
            class="btn" 
            @click="$emit('reset')"
          >
            Reset
          </button>
          <button 
            type="submit" 
            class="btn btn-primary"
            :disabled="saving"
          >
            {{ saving ? 'Saving...' : 'Save Changes' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { supabase } from '../../lib/supabaseClient'
import { useToast } from '../../composables/useToast'

const toast = useToast()

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  },
  storeId: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['update:modelValue', 'reset'])

const saving = ref(false)
const form = ref({ ...props.modelValue })

// Watch for external changes
watch(() => props.modelValue, (newVal) => {
  form.value = { ...newVal }
}, { deep: true })

// Watch for form changes
watch(form, (newVal) => {
  emit('update:modelValue', { ...newVal })
}, { deep: true })

async function handleLogoUpload(event) {
  const file = event.target.files[0]
  if (!file) return

  try {
    const fileExt = file.name.split('.').pop()
    const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
    const filePath = `store-assets/${props.storeId}/logo/${fileName}`

    const { error: uploadError } = await supabase.storage
      .from('store-assets')
      .upload(filePath, file)

    if (uploadError) throw uploadError

    const { data: { publicUrl } } = supabase.storage
      .from('store-assets')
      .getPublicUrl(filePath)

    form.value.logo_url = publicUrl
    toast.success('Logo uploaded successfully')
  } catch (error) {
    console.error('Error uploading logo:', error)
    toast.error('Failed to upload logo')
  }
}

async function handleBannerUpload(event) {
  const file = event.target.files[0]
  if (!file) return

  try {
    const fileExt = file.name.split('.').pop()
    const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
    const filePath = `store-assets/${props.storeId}/banner/${fileName}`

    const { error: uploadError } = await supabase.storage
      .from('store-assets')
      .upload(filePath, file)

    if (uploadError) throw uploadError

    const { data: { publicUrl } } = supabase.storage
      .from('store-assets')
      .getPublicUrl(filePath)

    form.value.banner_url = publicUrl
    toast.success('Banner uploaded successfully')
  } catch (error) {
    console.error('Error uploading banner:', error)
    toast.error('Failed to upload banner')
  }
}

async function save() {
  try {
    saving.value = true

    const { error } = await supabase
      .from('stores')
      .update({
        name: form.value.name,
        slug: form.value.slug,
        description: form.value.description,
        logo_url: form.value.logo_url,
        banner_url: form.value.banner_url,
        contact_email: form.value.contact_email,
        contact_phone: form.value.contact_phone,
        address: form.value.address,
        social_media: form.value.social_media
      })
      .eq('id', props.storeId)

    if (error) throw error

    toast.success('Store settings saved successfully')
  } catch (error) {
    console.error('Error saving store settings:', error)
    toast.error('Failed to save store settings')
  } finally {
    saving.value = false
  }
}
</script>
