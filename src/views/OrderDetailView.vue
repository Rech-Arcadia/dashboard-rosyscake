<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Trash2, ExternalLink, FileText } from 'lucide-vue-next'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { useOrdersStore } from '@/stores/orders'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseSelect from '@/components/ui/BaseSelect.vue'

const route = useRoute()
const router = useRouter()
const ordersStore = useOrdersStore()

const order = ref(null)
const loading = ref(true)

const statusOptions = [
  { value: 'pendiente', label: 'Pendiente' },
  { value: 'en_proceso', label: 'En Proceso' },
  { value: 'listo', label: 'Listo' },
  { value: 'entregado', label: 'Entregado' },
]

onMounted(async () => {
  await ordersStore.fetchOrders()
  order.value = ordersStore.orders.find((o) => o.id === route.params.id)
  loading.value = false
})

async function changeStatus(newStatus) {
  if (!order.value) return
  await ordersStore.updateStatus(order.value.id, newStatus)
  order.value.estado = newStatus
}

async function handleDelete() {
  if (!order.value) return
  if (!confirm('¿Estás seguro de eliminar este pedido?')) return
  await ordersStore.deleteOrder(order.value.id)
  router.push('/orders')
}

function formatDate(date) {
  return format(new Date(date), "d 'de' MMMM yyyy, h:mm a", { locale: es })
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
}

const metodoPagoLabel = computed(() => {
  const map = {
    efectivo: 'Efectivo',
    transferencia: 'Transferencia',
    tarjeta: 'Tarjeta (Mercado Pago)',
  }
  return order.value?.metodo_pago ? map[order.value.metodo_pago] : 'No especificado'
})

const comprobanteIsImage = computed(() => {
  const url = order.value?.comprobante_url
  if (!url) return false
  return /\.(png|jpe?g|gif|webp|bmp|svg)(\?|$)/i.test(url)
})
</script>

<template>
  <div class="detail">
    <div class="detail__header">
      <BaseButton variant="ghost" size="sm" @click="router.push('/orders')">
        <ArrowLeft :size="18" />
        Volver a pedidos
      </BaseButton>
    </div>

    <div v-if="loading" class="detail__loading">Cargando pedido...</div>

    <div v-else-if="!order" class="detail__not-found">Pedido no encontrado.</div>

    <template v-else>
      <BaseCard padding="lg">
        <div class="detail__top">
          <div>
            <h2 class="detail__title">Pedido de {{ order.cliente }}</h2>
            <p class="text-sm text-muted">Creado {{ formatDate(order.created_at) }}</p>
          </div>
          <div class="detail__actions">
            <BaseBadge :status="order.estado" />
            <BaseButton variant="danger" size="sm" @click="handleDelete">
              <Trash2 :size="16" />
              Eliminar
            </BaseButton>
          </div>
        </div>

        <div class="detail__grid">
          <div class="detail__field">
            <span class="detail__label">Producto</span>
            <span class="detail__value">{{ order.producto }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Cantidad</span>
            <span class="detail__value">{{ order.cantidad }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Total</span>
            <span class="detail__value detail__value--highlight">{{ formatCurrency(order.total_venta) }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Teléfono</span>
            <span class="detail__value">{{ order.telefono || 'No proporcionado' }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Mensaje en pastel</span>
            <span class="detail__value">{{ order.mensaje_pastel || 'Sin mensaje' }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Lugar de entrega</span>
            <span class="detail__value">{{ order.lugar_entrega }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Fecha de entrega</span>
            <span class="detail__value">{{ formatDate(order.fecha_entrega) }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Origen</span>
            <span class="detail__value">{{ order.origen === 'formulario_publico' ? 'Formulario público' : 'Dashboard' }}</span>
          </div>
          <div class="detail__field">
            <span class="detail__label">Método de pago</span>
            <span class="detail__value">{{ metodoPagoLabel }}</span>
          </div>
        </div>

        <div v-if="order.comprobante_url" class="detail__comprobante">
          <span class="detail__label">Comprobante de transferencia</span>
          <div class="comprobante">
            <a
              v-if="comprobanteIsImage"
              :href="order.comprobante_url"
              target="_blank"
              rel="noopener noreferrer"
              class="comprobante__image-link"
            >
              <img :src="order.comprobante_url" alt="Comprobante" class="comprobante__image" />
            </a>
            <a
              v-else
              :href="order.comprobante_url"
              target="_blank"
              rel="noopener noreferrer"
              class="comprobante__file"
            >
              <FileText :size="20" />
              <span>Ver comprobante</span>
              <ExternalLink :size="16" />
            </a>
          </div>
        </div>

        <div class="detail__status-change">
          <BaseSelect
            label="Cambiar estado"
            :options="statusOptions"
            :model-value="order.estado"
            @update:model-value="changeStatus"
          />
        </div>
      </BaseCard>
    </template>
  </div>
</template>

<style scoped>
.detail {
  max-width: 800px;
}

.detail__header {
  margin-bottom: var(--space-4);
}

.detail__loading,
.detail__not-found {
  text-align: center;
  padding: var(--space-12);
  color: var(--color-text-muted);
}

.detail__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
  margin-bottom: var(--space-6);
  padding-bottom: var(--space-6);
  border-bottom: 1px solid var(--color-border-light);
}

.detail__title {
  font-size: var(--font-size-xl);
  margin-bottom: var(--space-1);
}

.detail__actions {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

.detail__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-5);
}

.detail__field {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.detail__label {
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.detail__value {
  font-size: var(--font-size-sm);
}

.detail__value--highlight {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-accent-text);
}

.detail__comprobante {
  margin-top: var(--space-6);
  padding-top: var(--space-6);
  border-top: 1px solid var(--color-border-light);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.comprobante__image-link {
  display: block;
  max-width: 360px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--color-border-light);
  transition: transform var(--transition-fast);
}

.comprobante__image-link:hover {
  transform: scale(1.01);
}

.comprobante__image {
  display: block;
  width: 100%;
  height: auto;
}

.comprobante__file {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-4);
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
  text-decoration: none;
  transition: all var(--transition-fast);
  width: fit-content;
}

.comprobante__file:hover {
  border-color: var(--color-accent);
  background: var(--color-accent-light);
}

.detail__status-change {
  margin-top: var(--space-6);
  padding-top: var(--space-6);
  border-top: 1px solid var(--color-border-light);
  max-width: 240px;
}

@media (max-width: 640px) {
  .detail__grid {
    grid-template-columns: 1fr;
  }

  .detail__top {
    flex-direction: column;
  }
}
</style>
