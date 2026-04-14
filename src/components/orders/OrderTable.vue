<script setup>
import { useRouter } from 'vue-router'
import { format, isToday, isTomorrow, isPast, differenceInCalendarDays } from 'date-fns'
import { es } from 'date-fns/locale'
import { Eye, Pencil, Inbox } from 'lucide-vue-next'
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

function deliveryHint(date) {
  const d = new Date(date)
  if (isToday(d)) return { text: 'Hoy', tone: 'urgent' }
  if (isTomorrow(d)) return { text: 'Mañana', tone: 'soon' }
  if (isPast(d)) return { text: 'Atrasado', tone: 'late' }
  const days = differenceInCalendarDays(d, new Date())
  if (days <= 3) return { text: `En ${days} días`, tone: 'soon' }
  return { text: `En ${days} días`, tone: 'normal' }
}

function initials(name) {
  if (!name) return '?'
  return name
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase() ?? '')
    .join('')
}

function viewOrder(id) {
  router.push(`/orders/${id}`)
}
</script>

<template>
  <!-- Loading skeleton -->
  <div v-if="ordersStore.loading && !ordersStore.filteredOrders.length" class="skeleton-list">
    <div v-for="n in 4" :key="n" class="skeleton-row">
      <div class="skeleton skeleton--avatar" />
      <div class="skeleton-row__lines">
        <div class="skeleton skeleton--line skeleton--line-lg" />
        <div class="skeleton skeleton--line skeleton--line-sm" />
      </div>
      <div class="skeleton skeleton--pill" />
    </div>
  </div>

  <!-- Empty state -->
  <div v-else-if="!ordersStore.filteredOrders.length" class="empty">
    <div class="empty__icon">
      <Inbox :size="32" />
    </div>
    <h3 class="empty__title">Sin pedidos por mostrar</h3>
    <p class="empty__desc">
      {{ ordersStore.filter !== 'todos'
        ? `No hay pedidos con estado "${ordersStore.filter.replace('_', ' ')}" por ahora.`
        : 'Cuando crees un pedido aparecerá aquí.' }}
    </p>
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
              <th class="text-center">Cant.</th>
              <th>Entrega</th>
              <th class="text-right">Total</th>
              <th>Estado</th>
              <th class="text-right">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="order in ordersStore.filteredOrders"
              :key="order.id"
              :class="`table__row--${order.estado}`"
              @click="viewOrder(order.id)"
            >
              <td>
                <div class="table__client">
                  <div class="table__avatar">{{ initials(order.cliente) }}</div>
                  <div class="table__client-text">
                    <span class="table__client-name">{{ order.cliente }}</span>
                    <span v-if="order.telefono" class="table__client-phone">{{ order.telefono }}</span>
                  </div>
                </div>
              </td>
              <td class="table__product">{{ order.producto }}</td>
              <td class="text-center">
                <span class="table__qty">×{{ order.cantidad }}</span>
              </td>
              <td>
                <div class="table__delivery">
                  <span class="table__delivery-date">{{ formatDate(order.fecha_entrega) }}</span>
                  <span
                    class="table__delivery-hint"
                    :class="`table__delivery-hint--${deliveryHint(order.fecha_entrega).tone}`"
                  >
                    {{ deliveryHint(order.fecha_entrega).text }}
                  </span>
                </div>
              </td>
              <td class="table__total text-right">{{ formatCurrency(order.total_venta) }}</td>
              <td><BaseBadge :status="order.estado" /></td>
              <td @click.stop>
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
        :class="`order-card--${order.estado}`"
        @click="viewOrder(order.id)"
      >
        <div class="order-card__top">
          <div class="order-card__client">
            <div class="order-card__avatar">{{ initials(order.cliente) }}</div>
            <div class="order-card__client-text">
              <span class="order-card__name">{{ order.cliente }}</span>
              <span v-if="order.telefono" class="order-card__phone">{{ order.telefono }}</span>
            </div>
          </div>
          <BaseBadge :status="order.estado" />
        </div>

        <div class="order-card__product">
          <span class="order-card__product-name">{{ order.producto }}</span>
          <span class="order-card__qty">×{{ order.cantidad }}</span>
        </div>

        <div class="order-card__meta">
          <div class="order-card__date-wrap">
            <span class="order-card__date">{{ formatDate(order.fecha_entrega) }}</span>
            <span
              class="order-card__hint"
              :class="`order-card__hint--${deliveryHint(order.fecha_entrega).tone}`"
            >
              {{ deliveryHint(order.fecha_entrega).text }}
            </span>
          </div>
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
  border-collapse: separate;
  border-spacing: 0;
}

.table th {
  text-align: left;
  padding: var(--space-3) var(--space-4);
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  border-bottom: 1px solid var(--color-border-light);
  background: var(--color-bg-secondary);
  position: sticky;
  top: 0;
}

.table th.text-center { text-align: center; }
.table th.text-right { text-align: right; }
.table td.text-right { text-align: right; }
.table td.text-center { text-align: center; }

.table td {
  padding: var(--space-4);
  border-bottom: 1px solid var(--color-border-light);
  vertical-align: middle;
}

.table tbody tr {
  cursor: pointer;
  transition: background var(--transition-fast);
  position: relative;
}

.table tbody tr td:first-child {
  box-shadow: inset 3px 0 0 transparent;
  transition: box-shadow var(--transition-fast);
}

.table__row--pendiente td:first-child { box-shadow: inset 3px 0 0 var(--color-status-pendiente); }
.table__row--en_proceso td:first-child { box-shadow: inset 3px 0 0 var(--color-status-en-proceso); }
.table__row--listo td:first-child { box-shadow: inset 3px 0 0 var(--color-status-listo); }
.table__row--entregado td:first-child { box-shadow: inset 3px 0 0 var(--color-status-entregado); }

.table tbody tr:last-child td { border-bottom: none; }

.table tbody tr:hover {
  background: var(--color-bg-secondary);
}

.table__client {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  min-width: 0;
}

.table__avatar {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--color-accent-light);
  color: var(--color-accent-text);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-semibold);
  letter-spacing: 0.02em;
}

.table__client-text {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.table__client-name {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 180px;
}

.table__client-phone {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
  margin-top: 1px;
}

.table__product {
  color: var(--color-text);
}

.table__qty {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  padding: 2px 8px;
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-muted);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-full, 999px);
}

.table__delivery {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.table__delivery-date {
  font-size: var(--font-size-sm);
  color: var(--color-text);
  white-space: nowrap;
}

.table__delivery-hint {
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.table__delivery-hint--urgent { color: #d97706; }
.table__delivery-hint--late { color: #dc2626; }
.table__delivery-hint--soon { color: #2563eb; }
.table__delivery-hint--normal { color: var(--color-text-muted); }

.table__total {
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
}

.table__actions {
  display: flex;
  gap: var(--space-1);
  justify-content: flex-end;
}

.table__action {
  width: 34px;
  height: 34px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  background: transparent;
  border: none;
  cursor: pointer;
  transition: all var(--transition-fast);
}

.table__action:hover {
  background: var(--color-accent-light);
  color: var(--color-accent-text);
}

/* Empty state */
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--space-10, 64px) var(--space-5);
  background: var(--color-bg);
  border: 1px dashed var(--color-border);
  border-radius: var(--radius-xl, 16px);
  text-align: center;
}

.empty__icon {
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-secondary);
  color: var(--color-text-muted);
  border-radius: 50%;
  margin-bottom: var(--space-4);
}

.empty__title {
  margin: 0 0 var(--space-2);
  font-size: var(--font-size-lg, 1.125rem);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.empty__desc {
  margin: 0;
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  max-width: 360px;
}

/* Skeleton loader */
.skeleton-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  background: var(--color-bg);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: var(--space-3);
}

.skeleton-row {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3);
}

.skeleton-row__lines {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.skeleton {
  background: linear-gradient(
    90deg,
    var(--color-bg-secondary) 0%,
    var(--color-border-light) 50%,
    var(--color-bg-secondary) 100%
  );
  background-size: 200% 100%;
  border-radius: var(--radius-md);
  animation: skeleton-pulse 1.4s ease-in-out infinite;
}

.skeleton--avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  flex-shrink: 0;
}

.skeleton--line { height: 10px; }
.skeleton--line-lg { width: 60%; }
.skeleton--line-sm { width: 35%; }

.skeleton--pill {
  width: 70px;
  height: 22px;
  border-radius: var(--radius-full, 999px);
}

@keyframes skeleton-pulse {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Mobile cards */
.order-cards {
  display: none;
  flex-direction: column;
  gap: var(--space-3);
}

.order-card {
  cursor: pointer;
  transition: transform var(--transition-fast), box-shadow var(--transition-fast);
  position: relative;
  overflow: hidden;
}

.order-card::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  background: var(--color-border);
}

.order-card--pendiente::before { background: var(--color-status-pendiente); }
.order-card--en_proceso::before { background: var(--color-status-en-proceso); }
.order-card--listo::before { background: var(--color-status-listo); }
.order-card--entregado::before { background: var(--color-status-entregado); }

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
  align-items: center;
  gap: var(--space-3);
  min-width: 0;
  flex: 1;
}

.order-card__avatar {
  flex-shrink: 0;
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--color-accent-light);
  color: var(--color-accent-text);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-semibold);
}

.order-card__client-text {
  display: flex;
  flex-direction: column;
  min-width: 0;
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
  margin-top: 1px;
}

.order-card__product {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  padding: var(--space-3);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-md);
  font-size: var(--font-size-sm);
  color: var(--color-text);
  margin-bottom: var(--space-3);
}

.order-card__product-name {
  font-weight: var(--font-weight-medium);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.order-card__qty {
  flex-shrink: 0;
  padding: 2px 10px;
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-muted);
  background: var(--color-bg);
  border-radius: var(--radius-full, 999px);
}

.order-card__meta {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}

.order-card__date-wrap {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.order-card__date {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}

.order-card__hint {
  font-size: 10px;
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.order-card__hint--urgent { color: #d97706; }
.order-card__hint--late { color: #dc2626; }
.order-card__hint--soon { color: #2563eb; }
.order-card__hint--normal { color: var(--color-text-muted); }

.order-card__total {
  font-size: var(--font-size-lg, 1.125rem);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  font-variant-numeric: tabular-nums;
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

  .empty {
    padding: var(--space-8) var(--space-4);
  }
}
</style>
