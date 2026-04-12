<script setup>
import { DollarSign, ShoppingBag, TrendingUp } from 'lucide-vue-next'
import BaseCard from '@/components/ui/BaseCard.vue'

const props = defineProps({
  totalRevenue: {
    type: Number,
    default: 0,
  },
  totalOrders: {
    type: Number,
    default: 0,
  },
  loading: Boolean,
})

function formatCurrency(amount) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
}

function averagePerOrder() {
  if (props.totalOrders === 0) return formatCurrency(0)
  return formatCurrency(props.totalRevenue / props.totalOrders)
}
</script>

<template>
  <div class="revenue-summary">
    <BaseCard hoverable>
      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--green">
          <DollarSign :size="22" />
        </div>
        <div>
          <span class="summary-card__label">Ingresos Totales</span>
          <span class="summary-card__value">{{ loading ? '...' : formatCurrency(totalRevenue) }}</span>
        </div>
      </div>
    </BaseCard>

    <BaseCard hoverable>
      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--blue">
          <ShoppingBag :size="22" />
        </div>
        <div>
          <span class="summary-card__label">Pedidos Completados</span>
          <span class="summary-card__value">{{ loading ? '...' : totalOrders }}</span>
        </div>
      </div>
    </BaseCard>

    <BaseCard hoverable>
      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--pink">
          <TrendingUp :size="22" />
        </div>
        <div>
          <span class="summary-card__label">Promedio por Pedido</span>
          <span class="summary-card__value">{{ loading ? '...' : averagePerOrder() }}</span>
        </div>
      </div>
    </BaseCard>
  </div>
</template>

<style scoped>
.revenue-summary {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--space-5);
}

.summary-card {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}

.summary-card__icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.summary-card__icon--green {
  background: var(--color-status-listo-bg);
  color: var(--color-status-listo);
}

.summary-card__icon--blue {
  background: var(--color-status-en-proceso-bg);
  color: var(--color-status-en-proceso);
}

.summary-card__icon--pink {
  background: var(--color-accent-light);
  color: var(--color-accent-dark);
}

.summary-card__label {
  display: block;
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.summary-card__value {
  display: block;
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
}

@media (max-width: 768px) {
  .revenue-summary {
    grid-template-columns: 1fr;
  }
}
</style>
