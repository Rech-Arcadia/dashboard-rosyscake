<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { LayoutDashboard, ClipboardList, TrendingUp, LogOut, Cake, Package } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const auth = useAuthStore()

defineProps({
  collapsed: Boolean,
})

defineEmits(['close'])

const navItems = [
  { name: 'Dashboard', icon: LayoutDashboard, to: '/dashboard' },
  { name: 'Pedidos', icon: ClipboardList, to: '/orders' },
  { name: 'Productos', icon: Package, to: '/products' },
  { name: 'Ingresos', icon: TrendingUp, to: '/revenue' },
]

function isActive(path) {
  return route.path.startsWith(path)
}

async function handleLogout() {
  await auth.logout()
}
</script>

<template>
  <aside class="sidebar" :class="{ 'sidebar--collapsed': collapsed }">
    <div class="sidebar__brand">
      <div class="sidebar__logo">
        <Cake :size="28" />
      </div>
      <div class="sidebar__brand-text">
        <span class="sidebar__brand-name">Rosy's Cake</span>
        <span class="sidebar__brand-sub">Dashboard</span>
      </div>
    </div>

    <nav class="sidebar__nav">
      <RouterLink
        v-for="item in navItems"
        :key="item.to"
        :to="item.to"
        class="sidebar__link"
        :class="{ 'sidebar__link--active': isActive(item.to) }"
        @click="$emit('close')"
      >
        <component :is="item.icon" :size="20" />
        <span>{{ item.name }}</span>
      </RouterLink>
    </nav>

    <div class="sidebar__footer">
      <button class="sidebar__link" @click="handleLogout">
        <LogOut :size="20" />
        <span>Cerrar sesión</span>
      </button>
    </div>
  </aside>
</template>

<style scoped>
.sidebar {
  position: fixed;
  top: 0;
  left: 0;
  width: var(--sidebar-width);
  height: 100vh;
  background: var(--color-bg-sidebar);
  color: var(--color-text-inverse);
  display: flex;
  flex-direction: column;
  z-index: 100;
  transition: transform var(--transition-normal);
}

.sidebar__brand {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-6) var(--space-5);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.sidebar__logo {
  width: 44px;
  height: 44px;
  background: var(--color-accent);
  color: var(--color-accent-text);
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.sidebar__brand-text {
  display: flex;
  flex-direction: column;
}

.sidebar__brand-name {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-bold);
}

.sidebar__brand-sub {
  font-size: var(--font-size-xs);
  opacity: 0.6;
}

.sidebar__nav {
  flex: 1;
  padding: var(--space-4) var(--space-3);
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.sidebar__link {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-md);
  color: rgba(255, 255, 255, 0.7);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  transition: all var(--transition-fast);
  text-decoration: none;
  width: 100%;
  text-align: left;
}

.sidebar__link:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--color-text-inverse);
}

.sidebar__link--active {
  background: var(--color-accent);
  color: var(--color-accent-text);
}

.sidebar__link--active:hover {
  background: var(--color-accent-hover);
  color: var(--color-accent-text);
}

.sidebar__footer {
  padding: var(--space-3);
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

@media (max-width: 768px) {
  .sidebar--collapsed {
    transform: translateX(-100%);
  }
}
</style>
