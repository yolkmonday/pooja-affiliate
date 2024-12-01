import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import './style.css'
import { supabase } from './lib/supabaseClient'

// Router configuration
const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('./views/Login.vue'),
      meta: { public: true }
    },
    {
      path: '/register',
      name: 'Register',
      component: () => import('./views/Register.vue'),
      meta: { public: true }
    },
    {
      path: '/',
      name: 'Dashboard',
      component: () => import('./views/Dashboard.vue')
    },
    {
      path: '/products',
      name: 'Products',
      component: () => import('./views/Products.vue')
    },
    {
      path: '/products/new',
      name: 'NewProduct',
      component: () => import('./views/ProductForm.vue')
    },
    {
      path: '/products/:id/edit',
      name: 'EditProduct',
      component: () => import('./views/ProductForm.vue')
    },
    {
      path: '/orders',
      name: 'Orders',
      component: () => import('./views/Orders.vue')
    },
    {
      path: '/customers',
      name: 'Customers',
      component: () => import('./views/Customers.vue')
    },
    {
      path: '/settings',
      name: 'Settings',
      component: () => import('./views/Settings.vue')
    }
  ]
})

// Auth guard
router.beforeEach(async (to) => {
  // Wait for supabase to initialize
  const { data: { session } } = await supabase.auth.getSession()
  
  // Allow public routes
  if (to.meta.public) {
    // If logged in and trying to access public route, redirect to dashboard
    if (session) {
      return { path: '/' }
    }
    return true
  }

  // Protected routes
  if (!session) {
    // Save the location we were trying to access
    return { 
      path: '/login',
      query: { redirect: to.fullPath }
    }
  }

  return true
})

// Create app
const app = createApp(App)

// Use router
app.use(router)

// Mount app
app.mount('#app')
