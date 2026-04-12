<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { Menu } from 'lucide-vue-next'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'

const route = useRoute()

defineEmits(['toggleSidebar'])

const today = computed(() => {
  return format(new Date(), "EEEE, d 'de' MMMM yyyy", { locale: es })
})

const pageTitle = computed(() => {
  return route.meta.title || 'Dashboard'
})
</script>

<template>
  <header class="topbar">
    <div class="topbar__left">
      <button class="topbar__menu" @click="$emit('toggleSidebar')">
        <Menu :size="24" />
      </button>
      <div>
        <h1 class="topbar__title">{{ pageTitle }}</h1>
        <p class="topbar__date">{{ today }}</p>
      </div>
    </div>
  </header>
</template>

<style scoped>
.topbar {
  height: var(--topbar-height);
  padding: 0 var(--space-6);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-bg);
  border-bottom: 1px solid var(--color-border-light);
  position: sticky;
  top: 0;
  z-index: 50;
}

.topbar__left {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.topbar__menu {
  display: none;
  width: 40px;
  height: 40px;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  color: var(--color-text);
  transition: background var(--transition-fast);
}

.topbar__menu:hover {
  background: var(--color-bg-secondary);
}

.topbar__title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.topbar__date {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  text-transform: capitalize;
}

@media (max-width: 768px) {
  .topbar__menu {
    display: flex;
  }
}
</style>
