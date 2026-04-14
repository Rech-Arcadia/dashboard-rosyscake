<script setup>
import { computed } from 'vue'
import { useOrdersStore } from '@/stores/orders'

const ordersStore = useOrdersStore()

const tabs = [
  { value: 'todos', label: 'Todos' },
  { value: 'pendiente', label: 'Pendiente' },
  { value: 'en_proceso', label: 'En Proceso' },
  { value: 'listo', label: 'Listo' },
  { value: 'entregado', label: 'Entregado' },
]

function countFor(value) {
  if (value === 'todos') return ordersStore.orderCounts.total
  return ordersStore.orderCounts[value] ?? 0
}
</script>

<template>
  <div class="status-filter">
    <button
      v-for="tab in tabs"
      :key="tab.value"
      type="button"
      class="status-filter__tab"
      :class="[
        { 'status-filter__tab--active': ordersStore.filter === tab.value },
        `status-filter__tab--${tab.value}`,
      ]"
      @click="ordersStore.setFilter(tab.value)"
    >
      <span class="status-filter__dot" />
      <span class="status-filter__label">{{ tab.label }}</span>
      <span class="status-filter__count">{{ countFor(tab.value) }}</span>
    </button>
  </div>
</template>

<style scoped>
.status-filter {
  display: flex;
  gap: var(--space-2);
  padding: var(--space-1);
  width: 100%;
}

.status-filter__tab {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-4);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
  background: var(--color-bg);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-full, 999px);
  cursor: pointer;
  transition: all var(--transition-fast);
  white-space: nowrap;
}

.status-filter__tab:hover {
  color: var(--color-text);
  border-color: var(--color-border);
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

.status-filter__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-text-muted);
  flex-shrink: 0;
  transition: all var(--transition-fast);
}

.status-filter__tab--todos .status-filter__dot {
  background: var(--color-text-muted);
}
.status-filter__tab--pendiente .status-filter__dot {
  background: var(--color-status-pendiente);
}
.status-filter__tab--en_proceso .status-filter__dot {
  background: var(--color-status-en-proceso);
}
.status-filter__tab--listo .status-filter__dot {
  background: var(--color-status-listo);
}
.status-filter__tab--entregado .status-filter__dot {
  background: var(--color-status-entregado);
}

.status-filter__count {
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  background: var(--color-bg-secondary);
  color: var(--color-text-muted);
  padding: 1px 8px;
  border-radius: var(--radius-full, 999px);
  min-width: 22px;
  text-align: center;
  transition: all var(--transition-fast);
}

.status-filter__tab--active {
  color: var(--color-text);
  background: var(--color-bg);
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(254, 194, 214, 0.25), var(--shadow-sm);
}

.status-filter__tab--active .status-filter__count {
  background: var(--color-accent);
  color: var(--color-accent-text);
}

@media (max-width: 640px) {
  .status-filter {
    overflow-x: auto;
    max-width: 100%;
    padding-bottom: var(--space-2);
    gap: var(--space-2);
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
    scroll-snap-type: x mandatory;
  }

  .status-filter::-webkit-scrollbar {
    display: none;
  }

  .status-filter__tab {
    padding: var(--space-2) var(--space-3);
    scroll-snap-align: start;
    flex-shrink: 0;
  }
}
</style>
