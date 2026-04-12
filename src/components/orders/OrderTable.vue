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
  <BaseCard padding="sm">
    <div class="table-wrapper">
      <table v-if="ordersStore.filteredOrders.length" class="table">
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

      <div v-else class="table__empty">
        <p v-if="ordersStore.loading">Cargando pedidos...</p>
        <p v-else>No hay pedidos {{ ordersStore.filter !== 'todos' ? `con estado "${ordersStore.filter}"` : '' }}</p>
      </div>
    </div>
  </BaseCard>
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

.table__empty {
  padding: var(--space-12);
  text-align: center;
  color: var(--color-text-muted);
}
</style>
