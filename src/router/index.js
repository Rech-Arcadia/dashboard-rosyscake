import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/',
      component: () => import('@/layouts/DashboardLayout.vue'),
      meta: { requiresAuth: true },
      children: [
        { path: '', redirect: '/dashboard' },
        {
          path: 'dashboard',
          name: 'dashboard',
          component: () => import('@/views/DashboardView.vue'),
          meta: { title: 'Dashboard' },
        },
        {
          path: 'orders',
          name: 'orders',
          component: () => import('@/views/OrdersView.vue'),
          meta: { title: 'Pedidos' },
        },
        {
          path: 'orders/:id',
          name: 'order-detail',
          component: () => import('@/views/OrderDetailView.vue'),
          meta: { title: 'Detalle del Pedido' },
        },
        {
          path: 'revenue',
          name: 'revenue',
          component: () => import('@/views/RevenueView.vue'),
          meta: { title: 'Ingresos' },
        },
        {
          path: 'products',
          name: 'products',
          component: () => import('@/views/ProductsView.vue'),
          meta: { title: 'Productos' },
        },
      ],
    },
    {
      path: '/pedido',
      name: 'public-order',
      component: () => import('@/views/PublicOrderForm.vue'),
      meta: { requiresAuth: false, title: "Hacer Pedido - Rosy's Cake" },
    },
  ],
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()

  // Wait for auth to initialize
  if (auth.loading) {
    await new Promise((resolve) => {
      const unwatch = auth.$subscribe((_mutation, state) => {
        if (!state.loading) {
          unwatch()
          resolve()
        }
      })
    })
  }

  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login' }
  }

  if (to.name === 'login' && auth.isAuthenticated) {
    return { name: 'dashboard' }
  }
})

export default router
