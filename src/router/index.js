import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '../lib/supabaseClient'
import ProductForm from '../views/ProductForm.vue'

// Auth guard
async function requireAuth(to, from, next) {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    
    if (!session) {
      // Not logged in, redirect to login
      next({
        path: '/login',
        query: { redirect: to.fullPath }
      })
    } else {
      // Check if user has a store, but don't sign out if not found
      const { data: store, error: storeError } = await supabase
        .from('stores')
        .select('id')
        .eq('seller_id', session.user.id)
        .maybeSingle()

      if (storeError) {
        console.error('Error fetching store:', storeError)
      }

      // Allow access even if store not found - this prevents issues during registration
      next()
    }
  } catch (error) {
    console.error('Auth error:', error)
    next({
      path: '/login',
      query: { redirect: to.fullPath }
    })
  }
}

// Public routes that don't require auth
const publicRoutes = ['Login', 'Register']

// Routes
const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    beforeEnter: (to, from, next) => {
      // If already logged in, redirect to dashboard
      supabase.auth.getSession().then(({ data: { session } }) => {
        if (session) {
          next('/')
        } else {
          next()
        }
      })
    }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/Register.vue'),
    beforeEnter: (to, from, next) => {
      // If already logged in, redirect to dashboard
      supabase.auth.getSession().then(({ data: { session } }) => {
        if (session) {
          next('/')
        } else {
          next()
        }
      })
    }
  },
  {
    path: '/',
    name: 'Dashboard',
    component: () => import('../views/Dashboard.vue'),
    beforeEnter: requireAuth
  },
  {
    path: '/products',
    name: 'Products',
    component: () => import('../views/Products.vue'),
    beforeEnter: requireAuth
  },
  {
    path: '/products/new',
    name: 'NewProduct',
    component: ProductForm,
    beforeEnter: requireAuth
  },
  {
    path: '/products/:id/edit',
    name: 'EditProduct',
    component: ProductForm,
    beforeEnter: requireAuth
  },
  {
    path: '/orders',
    name: 'Orders',
    component: () => import('../views/Orders.vue'),
    beforeEnter: requireAuth
  },
  {
    path: '/customers',
    name: 'Customers',
    component: () => import('../views/Customers.vue'),
    beforeEnter: requireAuth
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('../views/Settings.vue'),
    beforeEnter: requireAuth
  },
  // Catch all route for 404
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Global navigation guard
router.beforeEach(async (to, from, next) => {
  // Skip auth check for public routes
  if (publicRoutes.includes(to.name)) {
    next()
    return
  }

  // For all other routes, check auth
  const { data: { session } } = await supabase.auth.getSession()
  if (!session) {
    next({
      path: '/login',
      query: { redirect: to.fullPath }
    })
  } else {
    next()
  }
})

export default router
