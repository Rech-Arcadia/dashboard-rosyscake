<script setup>
import { useRouter } from 'vue-router'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { Eye, Pencil } from 'lucide-vue-next'
import { useOrdersStore } from '@/stores/orders'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'

const router = useRouter()
const ordersStore = useOrdersStore()

const emit = defineEmits(['edit'])

function formatDate(date) {
  return format(new Date(date), "d MMM yyyy, h:mm a", { locale: es })
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
}

function viewOrder(id) {
  router.push(`/orders/${id}`)
}
</script>

<template>
  <div v-if="!ordersStore.filteredOrders.length" class="empty">
    <BaseCard padding="lg">
      <div class="empty__content">
        <p v-if="ordersStore.loading">Cargando pedidos...</p>
        <p v-else>No hay pedidos {{ ordersStore.filter !== 'todos' ? `con estado "${ordersStore.filter}"` : '' }}</p>
      </div>
    </BaseCard>
  </div>

  <template v-else>
    <!-- Desktop: table -->
    <BaseCard padding="sm" class="table-card">
      <div class="table-wrapper">
        <table class="table">
          <thead>
            <tr>
              <th>Cliente</th>
              <th>Producto</th>
              <th>Cant.</th>
              <th>Entrega</th>
              <th>Total</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="order in ordersStore.filteredOrders" :key="order.id">
              <td>
                <div class="table__client">
                  <span class="font-medium">{{ order.cliente }}</span>
                  <span v-if="order.telefono" class="text-xs text-muted">{{ order.telefono }}</span>
                </div>
              </td>
              <td>{{ order.producto }}</td>
              <td>{{ order.cantidad }}</td>
              <td class="text-sm">{{ formatDate(order.fecha_entrega) }}</td>
              <td class="font-medium">{{ formatCurrency(order.total_venta) }}</td>
              <td><BaseBadge :status="order.estado" /></td>
              <td>
                <div class="table__actions">
                  <button class="table__action" title="Ver detalle" @click="viewOrder(order.id)">
                    <Eye :size="16" />
                  </button>
                  <button class="table__action" title="Editar" @click="emit('edit', order)">
                    <Pencil :size="16" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </BaseCard>

    <!-- Mobile: cards -->
    <div class="order-cards">
      <BaseCard
        v-for="order in ordersStore.filteredOrders"
        :key="order.id"
        padding="md"
        class="order-card"
        @click="viewOrder(order.id)"
      >
        <div class="order-card__top">
          <div class="order-card__client">
            <span class="order-card__name">{{ order.cliente }}</span>
            <span v-if="order.telefono" class="order-card__phone">{{ order.telefono }}</span>
          </div>
          <BaseBadge :status="order.estado" />
        </div>

        <div class="order-card__product">
          <span>{{ order.producto }}</span>
          <span class="order-card__qty">×{{ order.cantidad }}</span>
        </div>

        <div class="order-card__meta">
          <span class="order-card__date">{{ formatDate(order.fecha_entrega) }}</span>
          <span class="order-card__total">{{ formatCurrency(order.total_venta) }}</span>
        </div>

        <div class="order-card__actions" @click.stop>
          <button class="table__action" title="Ver detalle" @click="viewOrder(order.id)">
            <Eye :size="16" />
          </button>
          <button class="table__action" title="Editar" @click="emit('edit', order)">
            <Pencil :size="16" />
          </button>
        </div>
      </BaseCard>
    </div>
  </template>
</template>

<style scoped>
.table-wrapper {
  overflow-x: auto;
}

.table {
  width: 100%;
  font-size: var(--font-size-sm);
}

.table th {
  text-align: left;
  padding: var(--space-3) var(--space-4);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border-bottom: 1px solid var(--color-border-light);
}

.table td {
  padding: var(--space-3) var(--space-4);
  border-bottom: 1px solid var(--color-border-light);
  vertical-align: middle;
}

.table tbody tr:last-child td {
  border-bottom: none;
}

.table tbody tr:hover {
  background: var(--color-bg-secondary);
}

.table__client {
  display: flex;
  flex-direction: column;
}

.table__actions {
  display: flex;
  gap: var(--space-1);
}

.table__action {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
}

.table__action:hover {
  background: var(--color-bg-secondary);
  color: var(--color-text);
}

.empty__content {
  padding: var(--space-8) var(--space-4);
  text-align: center;
  color: var(--color-text-muted);
}

/* Mobile cards */
.order-cards {
  display: none;
  flex-direction: column;
  gap: var(--space-3);
}

.order-card {
  cursor: pointer;
  transition: transform var(--transition-fast);
}

.order-card:active {
  transform: scale(0.98);
}

.order-card__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}

.order-card__client {
  display: flex;
  flex-direction: column;
  min-width: 0;
  flex: 1;
}

.order-card__name {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.order-card__phone {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
  margin-top: 2px;
}

.order-card__product {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-3);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-md);
  font-size: var(--font-size-sm);
  color: var(--color-text);
  margin-bottom: var(--space-3);
}

.order-card__qty {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-muted);
}

.order-card__meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}

.order-card__date {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}

.order-card__total {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-bold);
  color: var(--color-accent-text);
}

.order-card__actions {
  display: flex;
  gap: var(--space-1);
  padding-top: var(--space-3);
  border-top: 1px solid var(--color-border-light);
}

@media (max-width: 640px) {
  .table-card {
    display: none;
  }

  .order-cards {
    display: flex;
  }
}
</style>
