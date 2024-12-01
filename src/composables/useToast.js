import { h, render } from 'vue'
import Toast from '../components/ui/Toast.vue'

// Create a persistent container for toasts
let toastContainer = document.getElementById('toast-container')
if (!toastContainer) {
  toastContainer = document.createElement('div')
  toastContainer.id = 'toast-container'
  document.body.appendChild(toastContainer)
}

// Keep track of active toasts
const activeToasts = new Map()

export function useToast() {
  function removeToast(id) {
    activeToasts.delete(id)
    renderToasts()
  }

  function renderToasts() {
    if (activeToasts.size === 0) {
      render(null, toastContainer)
      return
    }

    const toastElements = Array.from(activeToasts.entries()).map(([id, toast]) => {
      return h(Toast, {
        key: id,
        message: toast.message,
        type: toast.type,
        duration: toast.duration,
        onDestroy: () => removeToast(id)
      })
    })

    const toastGroup = h('div', 
      { class: 'toast toast-top toast-end z-50' },
      toastElements
    )
    
    render(toastGroup, toastContainer)
  }

  function show(message, type = 'success', duration = 3000) {
    const id = Date.now().toString()
    
    activeToasts.set(id, {
      message,
      type,
      duration
    })

    renderToasts()

    // Auto remove after duration
    setTimeout(() => {
      removeToast(id)
    }, duration)
  }

  return {
    success: (message) => show(message, 'success', 3000),
    error: (message) => show(message, 'error', 5000),
    info: (message) => show(message, 'info', 3000),
    warning: (message) => show(message, 'warning', 4000)
  }
}
