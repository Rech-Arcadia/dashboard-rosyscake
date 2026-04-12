<script setup>
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { Clock, MapPin } from 'lucide-vue-next'
import { useOrdersStore } from '@/stores/orders'
import { useRouter } from 'vue-router'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'

const ordersStore = useOrdersStore()
const router = useRouter()

function formatTime(date) {
  return format(new Date(date), 'h:mm a', { locale: es })
}

function viewOrder(id) {
  router.push(`/orders/${id}`)
}
</script>

<template>
  <BaseCard>
    <div class="today">
      <div class="today__header">
        <h3 class="today__title">Pedidos de Hoy</h3>
        <span class="today__count">{{ ordersStore.todayOrders.length }} pedidos</span>
      </div>

      <div v-if="ordersStore.todayOrders.length" class="today__list">
        <div
          v-for="order in ordersStore.todayOrders"
          :key="order.id"
          class="today__item"
          @click="viewOrder(order.id)"
        >
          <div class="today__item-header">
            <span class="today__client font-medium">{{ order.cliente }}</span>
            <BaseBadge :status="order.estado" />
          </div>
          <p class="today__product text-sm">{{ order.producto }} x{{ order.cantidad }}</p>
          <div class="today__meta">
            <span class="today__meta-item">
              <Clock :size="14" />
              {{ formatTime(order.fecha_entrega) }}
            </span>
            <span class="today__meta-item">
              <MapPin :size="14" />
              {{ order.lugar_entrega }}
            </span>
          </div>
        </div>
      </div>

      <div v-else class="today__empty">
        <p>No hay pedidos para hoy</p>
      </div>
    </div>
  </BaseCard>
</template>

<style scoped>
.today__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-4);
}

.today__title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
}

.today__count {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.today__list {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  max-height: 460px;
  overflow-y: auto;
}

.today__item {
  padding: var(--space-3);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--transition-fast);
}

.today__item:hover {
  border-color: var(--color-accent);
  background: var(--color-accent-light);
}

.today__item-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-1);
}

.today__client {
  font-size: var(--font-size-sm);
}

.today__product {
  color: var(--color-text-muted);
  margin-bottom: var(--space-2);
}

.today__meta {
  display: flex;
  gap: var(--space-3);
}

.today__meta-item {
  display: flex;
  align-items: center;
  gap: var(--space-1);
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}

.today__empty {
  padding: var(--space-8);
  text-align: center;
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}
</style>
