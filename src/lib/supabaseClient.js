import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Storage bucket names
export const STORAGE_BUCKETS = {
  PRODUCT_MEDIA: 'product-media' // This bucket needs to be created in Supabase
}

// Helper function to upload multiple files
export async function uploadProductMedia(storeId, files) {
  try {
    const uploadPromises = Array.from(files).map(async file => {
      const fileExt = file.name.split('.').pop()
      const isVideo = file.type.startsWith('video/')
      const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
      const filePath = `${storeId}/${isVideo ? 'videos' : 'images'}/${fileName}`

      const { error: uploadError, data } = await supabase.storage
        .from(STORAGE_BUCKETS.PRODUCT_MEDIA)
        .upload(filePath, file, {
          cacheControl: '3600',
          upsert: false
        })

      if (uploadError) throw uploadError

      const { data: { publicUrl } } = supabase.storage
        .from(STORAGE_BUCKETS.PRODUCT_MEDIA)
        .getPublicUrl(filePath)

      return {
        url: publicUrl,
        type: isVideo ? 'video' : 'image'
      }
    })

    return await Promise.all(uploadPromises)
  } catch (error) {
    console.error('Error uploading media:', error)
    throw error
  }
}

// Helper function to delete media
export async function deleteProductMedia(filePath) {
  try {
    const { error } = await supabase.storage
      .from(STORAGE_BUCKETS.PRODUCT_MEDIA)
      .remove([filePath])

    if (error) throw error
  } catch (error) {
    console.error('Error deleting media:', error)
    throw error
  }
}
