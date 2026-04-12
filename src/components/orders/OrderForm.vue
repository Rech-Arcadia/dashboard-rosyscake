<script setup>
import { ref, computed, onMounted } from 'vue'
import { useProductsStore } from '@/stores/products'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseSelect from '@/components/ui/BaseSelect.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

const props = defineProps({
  order: {
    type: Object,
    default: null,
  },
})

const emit = defineEmits(['save', 'cancel'])
const productsStore = useProductsStore()

const form = ref({
  cliente: props.order?.cliente ?? '',
  telefono: props.order?.telefono ?? '',
  producto: props.order?.producto ?? '',
  cantidad: props.order?.cantidad ?? 1,
  mensaje_pastel: props.order?.mensaje_pastel ?? '',
  total_venta: props.order?.total_venta ?? '',
  lugar_entrega: props.order?.lugar_entrega ?? '',
  fecha_entrega: props.order?.fecha_entrega
    ? new Date(props.order.fecha_entrega).toISOString().slice(0, 16)
    : '',
  estado: props.order?.estado ?? 'pendiente',
  metodo_pago: props.order?.metodo_pago ?? 'efectivo',
})

const metodoPagoOptions = [
  { value: 'efectivo', label: 'Efectivo' },
  { value: 'transferencia', label: 'Transferencia' },
  { value: 'tarjeta', label: 'Tarjeta (Mercado Pago)' },
]

const selectedSize = ref('')
const saving = ref(false)

const isEditing = computed(() => !!props.order)

onMounted(() => {
  if (!productsStore.products.length) {
    productsStore.fetchProducts()
  }
})

const productoOptions = computed(() => {
  return productsStore.activeProducts.map((p) => ({
    value: p.nombre,
    label: `${p.emoji} ${p.nombre}`,
  }))
})

const sizeOptions = computed(() => {
  const product = productsStore.activeProducts.find((p) => p.nombre === form.value.producto)
  if (!product?.product_sizes?.length) return []
  return product.product_sizes
    .filter((s) => s.activo)
    .map((s) => ({
      value: s.id,
      label: `${s.nombre} - $${Number(s.precio).toLocaleString()}`,
      precio: s.precio,
    }))
})

function onSizeChange(sizeId) {
  const opt = sizeOptions.value.find((s) => s.value === sizeId)
  if (opt) {
    form.value.total_venta = opt.precio
  }
}

function onProductChange() {
  selectedSize.value = ''
  // Auto-set price if only one size
  if (sizeOptions.value.length === 1) {
    selectedSize.value = sizeOptions.value[0].value
    form.value.total_venta = sizeOptions.value[0].precio
  }
}

const statusOptions = [
  { value: 'pendiente', label: 'Pendiente' },
  { value: 'en_proceso', label: 'En Proceso' },
  { value: 'listo', label: 'Listo' },
  { value: 'entregado', label: 'Entregado' },
]

async function handleSubmit() {
  saving.value = true
  try {
    const data = {
      ...form.value,
      cantidad: Number(form.value.cantidad),
      total_venta: Number(form.value.total_venta),
      origen: 'dashboard',
    }
    emit('save', data)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="order-form" @submit.prevent="handleSubmit">
    <div class="order-form__grid">
      <BaseInput
        v-model="form.cliente"
        label="Cliente"
        placeholder="Nombre del cliente"
        required
      />

      <BaseInput
        v-model="form.telefono"
        label="Teléfono"
        placeholder="Teléfono de contacto"
      />

      <BaseSelect
        v-model="form.producto"
        label="Producto"
        :options="productoOptions"
        placeholder="Selecciona un producto"
        required
        @update:model-value="onProductChange"
      />

      <BaseSelect
        v-if="sizeOptions.length"
        v-model="selectedSize"
        label="Tamaño"
        :options="sizeOptions"
        placeholder="Selecciona un tamaño"
        required
        @update:model-value="onSizeChange"
      />

      <BaseInput
        v-model="form.cantidad"
        label="Cantidad"
        type="number"
        placeholder="1"
        required
      />

      <BaseInput
        v-model="form.mensaje_pastel"
        label="Mensaje en el pastel"
        placeholder="Feliz cumpleaños..."
      />

      <BaseInput
        v-model="form.total_venta"
        label="Total de la venta (MXN)"
        type="number"
        placeholder="0.00"
        required
      />

      <BaseInput
        v-model="form.lugar_entrega"
        label="Lugar de entrega"
        placeholder="Dirección o punto de entrega"
        required
      />

      <BaseInput
        v-model="form.fecha_entrega"
        label="Fecha y hora de entrega"
        type="datetime-local"
        required
      />

      <BaseSelect
        v-model="form.metodo_pago"
        label="Método de pago"
        :options="metodoPagoOptions"
      />

      <BaseSelect
        v-if="isEditing"
        v-model="form.estado"
        label="Estado"
        :options="statusOptions"
      />
    </div>

    <div class="order-form__actions">
      <BaseButton variant="secondary" type="button" @click="emit('cancel')">
        Cancelar
      </BaseButton>
      <BaseButton variant="primary" :loading="saving">
        {{ isEditing ? 'Guardar cambios' : 'Crear pedido' }}
      </BaseButton>
    </div>
  </form>
</template>

<style scoped>
.order-form__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

.order-form__actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
  margin-top: var(--space-6);
  padding-top: var(--space-5);
  border-top: 1px solid var(--color-border-light);
}

@media (max-width: 640px) {
  .order-form__grid {
    grid-template-columns: 1fr;
  }
}
</style>
