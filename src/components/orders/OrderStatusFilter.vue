<script setup>
import { useOrdersStore } from '@/stores/orders'

const ordersStore = useOrdersStore()

const tabs = [
  { value: 'todos', label: 'Todos' },
  { value: 'pendiente', label: 'Pendiente' },
  { value: 'en_proceso', label: 'En Proceso' },
  { value: 'listo', label: 'Listo' },
  { value: 'entregado', label: 'Entregado' },
]
</script>

<template>
  <div class="status-filter">
    <button
      v-for="tab in tabs"
      :key="tab.value"
      class="status-filter__tab"
      :class="{ 'status-filter__tab--active': ordersStore.filter === tab.value }"
      @click="ordersStore.setFilter(tab.value)"
    >
      {{ tab.label }}
      <span v-if="tab.value !== 'todos' && ordersStore.orderCounts[tab.value]" class="status-filter__count">
        {{ ordersStore.orderCounts[tab.value] }}
      </span>
    </button>
  </div>
</template>

<style scoped>
.status-filter {
  display: flex;
  gap: var(--space-1);
  background: var(--color-bg);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: var(--space-1);
}

.status-filter__tab {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  padding: var(--space-2) var(--space-3);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
  white-space: nowrap;
}

.status-filter__tab:hover {
  color: var(--color-text);
}

.status-filter__tab--active {
  background: var(--color-accent);
  color: var(--color-accent-text);
}

.status-filter__count {
  font-size: var(--font-size-xs);
  background: rgba(0, 0, 0, 0.1);
  padding: 0 6px;
  border-radius: var(--radius-full);
  min-width: 20px;
  text-align: center;
}

@media (max-width: 640px) {
  .status-filter {
    overflow-x: auto;
  }
}
</style>
