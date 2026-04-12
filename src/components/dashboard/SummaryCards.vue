<script setup>
import { computed } from 'vue'
import { ClipboardList, Clock, Loader, DollarSign } from 'lucide-vue-next'
import { useOrdersStore } from '@/stores/orders'
import BaseCard from '@/components/ui/BaseCard.vue'

const ordersStore = useOrdersStore()

function formatCurrency(amount) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
}

const cards = computed(() => [
  {
    title: 'Total Pedidos',
    value: ordersStore.orderCounts.total,
    icon: ClipboardList,
    color: '--color-accent',
    bg: '--color-accent-light',
  },
  {
    title: 'Pendientes',
    value: ordersStore.orderCounts.pendiente,
    icon: Clock,
    color: '--color-status-pendiente',
    bg: '--color-status-pendiente-bg',
  },
  {
    title: 'En Proceso',
    value: ordersStore.orderCounts.en_proceso,
    icon: Loader,
    color: '--color-status-en-proceso',
    bg: '--color-status-en-proceso-bg',
  },
  {
    title: 'Ingresos',
    value: formatCurrency(ordersStore.totalRevenue),
    icon: DollarSign,
    color: '--color-status-listo',
    bg: '--color-status-listo-bg',
  },
])
</script>

<template>
  <div class="summary">
    <BaseCard v-for="card in cards" :key="card.title" hoverable>
      <div class="summary__card">
        <div class="summary__icon" :style="{ background: `var(${card.bg})`, color: `var(${card.color})` }">
          <component :is="card.icon" :size="22" />
        </div>
        <div class="summary__info">
          <span class="summary__label">{{ card.title }}</span>
          <span class="summary__value">{{ card.value }}</span>
        </div>
      </div>
    </BaseCard>
  </div>
</template>

<style scoped>
.summary {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--space-5);
}

.summary__card {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.summary__icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.summary__info {
  display: flex;
  flex-direction: column;
}

.summary__label {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.summary__value {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
}

@media (max-width: 1024px) {
  .summary {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .summary {
    grid-template-columns: 1fr;
  }
}
</style>
