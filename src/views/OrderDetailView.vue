<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  ArrowLeft,
  Trash2,
  ExternalLink,
  FileText,
  User,
  Phone,
  MapPin,
  Calendar,
  Package,
  Hash,
  MessageCircle,
  CreditCard,
  Banknote,
  ArrowLeftRight,
  Globe,
  LayoutDashboard,
  CheckCircle2,
  Circle,
  Clock,
  ChefHat,
  PackageCheck,
  Image as ImageIcon,
} from 'lucide-vue-next'
import { format, isToday, isTomorrow, isPast, differenceInCalendarDays } from 'date-fns'
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

const statusFlow = [
  { value: 'pendiente', label: 'Pendiente', icon: Clock },
  { value: 'en_proceso', label: 'En Proceso', icon: ChefHat },
  { value: 'listo', label: 'Listo', icon: PackageCheck },
  { value: 'entregado', label: 'Entregado', icon: CheckCircle2 },
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

function formatShortDate(date) {
  return format(new Date(date), "d MMM yyyy", { locale: es })
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
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

const currentStepIndex = computed(() => {
  if (!order.value) return -1
  return statusFlow.findIndex((s) => s.value === order.value.estado)
})

const deliveryHint = computed(() => {
  if (!order.value) return null
  const d = new Date(order.value.fecha_entrega)
  if (isToday(d)) return { text: 'Entrega hoy', tone: 'urgent' }
  if (isTomorrow(d)) return { text: 'Entrega mañana', tone: 'soon' }
  if (isPast(d)) return { text: 'Entrega atrasada', tone: 'late' }
  const days = differenceInCalendarDays(d, new Date())
  if (days <= 3) return { text: `En ${days} días`, tone: 'soon' }
  return { text: `En ${days} días`, tone: 'normal' }
})

const metodoPagoLabel = computed(() => {
  const map = {
    efectivo: 'Efectivo',
    transferencia: 'Transferencia',
    tarjeta: 'Tarjeta (Mercado Pago)',
  }
  return order.value?.metodo_pago ? map[order.value.metodo_pago] : 'No especificado'
})

const metodoPagoIcon = computed(() => {
  const map = {
    efectivo: Banknote,
    transferencia: ArrowLeftRight,
    tarjeta: CreditCard,
  }
  return order.value?.metodo_pago ? map[order.value.metodo_pago] : CreditCard
})

const comprobanteIsImage = computed(() => {
  const url = order.value?.comprobante_url
  if (!url) return false
  return /\.(png|jpe?g|gif|webp|bmp|svg)(\?|$)/i.test(url)
})
</script>

<template>
  <div class="detail">
    <div class="detail__back">
      <BaseButton variant="ghost" size="sm" @click="router.push('/orders')">
        <ArrowLeft :size="18" />
        Volver a pedidos
      </BaseButton>
    </div>

    <div v-if="loading" class="detail__state">
      <div class="detail__spinner" />
      <p>Cargando pedido...</p>
    </div>

    <div v-else-if="!order" class="detail__state">
      <p>Pedido no encontrado.</p>
    </div>

    <template v-else>
      <!-- Hero header -->
      <div class="hero" :class="`hero--${order.estado}`">
        <div class="hero__main">
          <div class="hero__avatar">{{ initials(order.cliente) }}</div>
          <div class="hero__info">
            <div class="hero__eyebrow">
              <span>Pedido</span>
              <span class="hero__id">#{{ String(order.id).slice(0, 8) }}</span>
            </div>
            <h1 class="hero__title">{{ order.cliente }}</h1>
            <div class="hero__meta">
              <BaseBadge :status="order.estado" />
              <span class="hero__dot">•</span>
              <span class="hero__created">Creado {{ formatShortDate(order.created_at) }}</span>
              <span
                v-if="deliveryHint"
                class="hero__delivery-hint"
                :class="`hero__delivery-hint--${deliveryHint.tone}`"
              >
                {{ deliveryHint.text }}
              </span>
            </div>
          </div>
        </div>
        <div class="hero__actions">
          <BaseButton variant="danger" size="sm" @click="handleDelete">
            <Trash2 :size="16" />
            <span class="hero__action-label">Eliminar</span>
          </BaseButton>
        </div>
      </div>

      <!-- Status stepper -->
      <BaseCard padding="lg" class="stepper-card">
        <h3 class="section__title">Progreso del pedido</h3>
        <div class="stepper">
          <div
            v-for="(step, i) in statusFlow"
            :key="step.value"
            class="stepper__item"
            :class="{
              'stepper__item--active': i === currentStepIndex,
              'stepper__item--done': i < currentStepIndex,
            }"
          >
            <div class="stepper__circle">
              <component :is="i <= currentStepIndex ? step.icon : Circle" :size="18" />
            </div>
            <span class="stepper__label">{{ step.label }}</span>
            <div v-if="i < statusFlow.length - 1" class="stepper__line" />
          </div>
        </div>
      </BaseCard>

      <!-- Main grid -->
      <div class="grid">
        <div class="grid__main">
          <!-- Producto -->
          <BaseCard padding="lg" class="section">
            <div class="section__header">
              <div class="section__icon"><Package :size="18" /></div>
              <h3 class="section__title">Producto</h3>
            </div>
            <div class="section__body">
              <div class="field">
                <span class="field__label">Producto</span>
                <span class="field__value field__value--lg">{{ order.producto }}</span>
              </div>
              <div class="field-row">
                <div class="field">
                  <span class="field__label"><Hash :size="14" /> Cantidad</span>
                  <span class="field__value">{{ order.cantidad }}</span>
                </div>
                <div class="field">
                  <span class="field__label"><MessageCircle :size="14" /> Mensaje en pastel</span>
                  <span class="field__value">{{ order.mensaje_pastel || '—' }}</span>
                </div>
              </div>
            </div>
          </BaseCard>

          <!-- Cliente -->
          <BaseCard padding="lg" class="section">
            <div class="section__header">
              <div class="section__icon"><User :size="18" /></div>
              <h3 class="section__title">Cliente</h3>
            </div>
            <div class="section__body">
              <div class="field-row">
                <div class="field">
                  <span class="field__label"><User :size="14" /> Nombre</span>
                  <span class="field__value">{{ order.cliente }}</span>
                </div>
                <div class="field">
                  <span class="field__label"><Phone :size="14" /> Teléfono</span>
                  <span class="field__value">
                    <a v-if="order.telefono" :href="`tel:${order.telefono}`" class="field__link">
                      {{ order.telefono }}
                    </a>
                    <template v-else>No proporcionado</template>
                  </span>
                </div>
              </div>
            </div>
          </BaseCard>

          <!-- Entrega -->
          <BaseCard padding="lg" class="section">
            <div class="section__header">
              <div class="section__icon"><MapPin :size="18" /></div>
              <h3 class="section__title">Entrega</h3>
            </div>
            <div class="section__body">
              <div class="field">
                <span class="field__label"><MapPin :size="14" /> Lugar de entrega</span>
                <span class="field__value">{{ order.lugar_entrega }}</span>
              </div>
              <div class="field">
                <span class="field__label"><Calendar :size="14" /> Fecha y hora</span>
                <span class="field__value">{{ formatDate(order.fecha_entrega) }}</span>
              </div>
            </div>
          </BaseCard>

          <!-- Imagen de referencia -->
          <BaseCard v-if="order.imagen_referencia_url" padding="lg" class="section">
            <div class="section__header">
              <div class="section__icon"><ImageIcon :size="18" /></div>
              <h3 class="section__title">Imagen de referencia</h3>
            </div>
            <div class="section__body">
              <a
                :href="order.imagen_referencia_url"
                target="_blank"
                rel="noopener noreferrer"
                class="comprobante__image-link"
              >
                <img
                  :src="order.imagen_referencia_url"
                  alt="Imagen de referencia"
                  class="comprobante__image"
                />
                <span class="comprobante__overlay">
                  <ExternalLink :size="16" />
                  Ver en grande
                </span>
              </a>
            </div>
          </BaseCard>

          <!-- Comprobante -->
          <BaseCard v-if="order.comprobante_url" padding="lg" class="section">
            <div class="section__header">
              <div class="section__icon"><FileText :size="18" /></div>
              <h3 class="section__title">Comprobante de transferencia</h3>
            </div>
            <div class="section__body">
              <a
                v-if="comprobanteIsImage"
                :href="order.comprobante_url"
                target="_blank"
                rel="noopener noreferrer"
                class="comprobante__image-link"
              >
                <img :src="order.comprobante_url" alt="Comprobante" class="comprobante__image" />
                <span class="comprobante__overlay">
                  <ExternalLink :size="16" />
                  Ver en grande
                </span>
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
          </BaseCard>
        </div>

        <!-- Sidebar -->
        <aside class="grid__side">
          <BaseCard padding="lg" class="summary">
            <h3 class="section__title">Resumen de pago</h3>
            <div class="summary__total">
              <span class="summary__total-label">Total</span>
              <span class="summary__total-value">{{ formatCurrency(order.total_venta) }}</span>
            </div>
            <div class="summary__divider" />
            <div class="summary__row">
              <span class="summary__row-label">
                <component :is="metodoPagoIcon" :size="16" />
                Método de pago
              </span>
              <span class="summary__row-value">{{ metodoPagoLabel }}</span>
            </div>
            <div class="summary__row">
              <span class="summary__row-label">
                <component :is="order.origen === 'formulario_publico' ? Globe : LayoutDashboard" :size="16" />
                Origen
              </span>
              <span class="summary__row-value">
                {{ order.origen === 'formulario_publico' ? 'Formulario público' : 'Dashboard' }}
              </span>
            </div>
          </BaseCard>

          <BaseCard padding="lg" class="status-change">
            <h3 class="section__title">Cambiar estado</h3>
            <BaseSelect
              :options="statusOptions"
              :model-value="order.estado"
              @update:model-value="changeStatus"
            />
          </BaseCard>
        </aside>
      </div>
    </template>
  </div>
</template>

<style scoped>
.detail {
  width: 100%;
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.detail__back {
  margin-bottom: calc(var(--space-2) * -1);
}

.detail__state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-3);
  padding: var(--space-12);
  color: var(--color-text-muted);
}

.detail__spinner {
  width: 32px;
  height: 32px;
  border: 3px solid var(--color-border-light);
  border-top-color: var(--color-accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Hero */
.hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  padding: var(--space-6);
  background: linear-gradient(135deg, var(--color-bg) 0%, var(--color-bg-secondary) 100%);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-xl, 16px);
  box-shadow: var(--shadow-sm);
  position: relative;
  overflow: hidden;
}

.hero::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 6px;
  background: var(--color-border);
}

.hero--pendiente::before { background: var(--color-status-pendiente); }
.hero--en_proceso::before { background: var(--color-status-en-proceso); }
.hero--listo::before { background: var(--color-status-listo); }
.hero--entregado::before { background: var(--color-status-entregado); }

.hero__main {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  min-width: 0;
  flex: 1;
}

.hero__avatar {
  flex-shrink: 0;
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--color-accent-light);
  color: var(--color-accent-text);
  font-size: var(--font-size-xl, 1.5rem);
  font-weight: var(--font-weight-bold);
  box-shadow: 0 0 0 4px rgba(254, 194, 214, 0.25);
}

.hero__info {
  min-width: 0;
  flex: 1;
}

.hero__eyebrow {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--color-text-muted);
  margin-bottom: 2px;
}

.hero__id {
  font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
  padding: 1px 6px;
  background: var(--color-bg-secondary);
  border-radius: var(--radius-sm, 4px);
}

.hero__title {
  margin: 0;
  font-size: var(--font-size-xl, 1.5rem);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  line-height: 1.2;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.hero__meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--space-2);
  margin-top: var(--space-2);
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.hero__dot {
  color: var(--color-text-muted);
  opacity: 0.5;
}

.hero__delivery-hint {
  display: inline-flex;
  align-items: center;
  padding: 2px 10px;
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  border-radius: var(--radius-full, 999px);
  margin-left: var(--space-1);
}

.hero__delivery-hint--urgent { background: #fef3c7; color: #d97706; }
.hero__delivery-hint--late { background: #fee2e2; color: #dc2626; }
.hero__delivery-hint--soon { background: #dbeafe; color: #2563eb; }
.hero__delivery-hint--normal { background: var(--color-bg-secondary); color: var(--color-text-muted); }

.hero__actions {
  display: flex;
  gap: var(--space-2);
  flex-shrink: 0;
}

/* Stepper */
.stepper-card { padding: var(--space-5) var(--space-6); }

.stepper {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-top: var(--space-4);
  position: relative;
}

.stepper__item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  position: relative;
  min-width: 0;
}

.stepper__circle {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--color-bg-secondary);
  color: var(--color-text-muted);
  border: 2px solid var(--color-border-light);
  transition: all var(--transition-fast);
  position: relative;
  z-index: 1;
}

.stepper__label {
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
  text-align: center;
  transition: color var(--transition-fast);
}

.stepper__line {
  position: absolute;
  top: 22px;
  left: 50%;
  right: -50%;
  height: 2px;
  background: var(--color-border-light);
  z-index: 0;
}

.stepper__item--done .stepper__circle,
.stepper__item--active .stepper__circle {
  background: var(--color-accent);
  color: var(--color-accent-text);
  border-color: var(--color-accent);
}

.stepper__item--done .stepper__line {
  background: var(--color-accent);
}

.stepper__item--done .stepper__label,
.stepper__item--active .stepper__label {
  color: var(--color-text);
  font-weight: var(--font-weight-semibold);
}

.stepper__item--active .stepper__circle {
  box-shadow: 0 0 0 4px rgba(254, 194, 214, 0.3);
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { box-shadow: 0 0 0 4px rgba(254, 194, 214, 0.3); }
  50% { box-shadow: 0 0 0 8px rgba(254, 194, 214, 0.15); }
}

/* Grid layout */
.grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: var(--space-5);
  align-items: start;
}

.grid__main {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  min-width: 0;
}

.grid__side {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
  position: sticky;
  top: var(--space-5);
}

/* Sections */
.section__header {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-bottom: var(--space-4);
  padding-bottom: var(--space-3);
  border-bottom: 1px solid var(--color-border-light);
}

.section__icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-accent-light);
  color: var(--color-accent-text);
  border-radius: var(--radius-md);
}

.section__title {
  margin: 0;
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.section__body {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

/* Fields */
.field {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  min-width: 0;
}

.field-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

.field__label {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.field__value {
  font-size: var(--font-size-sm);
  color: var(--color-text);
  word-break: break-word;
}

.field__value--lg {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
}

.field__link {
  color: var(--color-accent-text);
  text-decoration: none;
  border-bottom: 1px dashed var(--color-accent);
}

.field__link:hover {
  color: var(--color-text);
}

/* Summary sidebar */
.summary__total {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
  padding: var(--space-4);
  margin: var(--space-4) 0 var(--space-2);
  background: var(--color-accent-light);
  border-radius: var(--radius-lg);
  text-align: center;
}

.summary__total-label {
  font-size: 11px;
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--color-accent-text);
  opacity: 0.85;
}

.summary__total-value {
  font-size: 1.75rem;
  font-weight: var(--font-weight-bold);
  color: var(--color-accent-text);
  font-variant-numeric: tabular-nums;
}

.summary__divider {
  height: 1px;
  background: var(--color-border-light);
  margin: var(--space-2) 0;
}

.summary__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
  padding: var(--space-2) 0;
  font-size: var(--font-size-sm);
}

.summary__row-label {
  display: inline-flex;
  align-items: center;
  gap: var(--space-2);
  color: var(--color-text-muted);
}

.summary__row-value {
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
  text-align: right;
}

/* Comprobante */
.comprobante__image-link {
  position: relative;
  display: block;
  max-width: 420px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  border: 1px solid var(--color-border-light);
  transition: all var(--transition-fast);
}

.comprobante__image-link:hover {
  border-color: var(--color-accent);
  box-shadow: var(--shadow-md);
}

.comprobante__image {
  display: block;
  width: 100%;
  height: auto;
}

.comprobante__overlay {
  position: absolute;
  bottom: var(--space-2);
  right: var(--space-2);
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: rgba(0, 0, 0, 0.75);
  color: white;
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-full, 999px);
  backdrop-filter: blur(4px);
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

/* Responsive */
@media (max-width: 960px) {
  .grid {
    grid-template-columns: minmax(0, 1fr);
  }

  .grid__side {
    position: static;
  }
}

@media (max-width: 640px) {
  .hero {
    flex-direction: column;
    align-items: stretch;
    padding: var(--space-5);
  }

  .hero__main {
    gap: var(--space-3);
  }

  .hero__avatar {
    width: 52px;
    height: 52px;
    font-size: var(--font-size-base);
  }

  .hero__title {
    font-size: var(--font-size-lg, 1.125rem);
    white-space: normal;
  }

  .hero__actions {
    width: 100%;
  }

  .hero__actions :deep(button) {
    width: 100%;
    justify-content: center;
  }

  .field-row {
    grid-template-columns: 1fr;
  }

  .stepper__label {
    font-size: 10px;
  }

  .stepper__circle {
    width: 36px;
    height: 36px;
  }

  .stepper__line {
    top: 18px;
  }

  .summary__total-value {
    font-size: 1.5rem;
  }
}
</style>
