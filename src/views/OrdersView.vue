<script setup>
import { ref, onMounted, computed } from 'vue'
import { Plus, ShoppingBag } from 'lucide-vue-next'
import { useOrdersStore } from '@/stores/orders'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import OrderTable from '@/components/orders/OrderTable.vue'
import OrderForm from '@/components/orders/OrderForm.vue'
import OrderStatusFilter from '@/components/orders/OrderStatusFilter.vue'

const ordersStore = useOrdersStore()
const showModal = ref(false)
const editingOrder = ref(null)

const subtitleText = computed(() => {
  const n = ordersStore.filteredOrders.length
  if (ordersStore.loading) return 'Cargando pedidos...'
  if (ordersStore.filter === 'todos') {
    return n === 0 ? 'Aún no hay pedidos registrados' : `${n} ${n === 1 ? 'pedido' : 'pedidos'} en total`
  }
  return `${n} ${n === 1 ? 'pedido' : 'pedidos'} en esta vista`
})

onMounted(() => {
  ordersStore.fetchOrders()
})

function openNewOrder() {
  editingOrder.value = null
  showModal.value = true
}

function openEditOrder(order) {
  editingOrder.value = { ...order }
  showModal.value = true
}

async function handleSave(data) {
  if (editingOrder.value) {
    await ordersStore.updateOrder(editingOrder.value.id, data)
  } else {
    await ordersStore.createOrder(data)
  }
  showModal.value = false
}
</script>

<template>
  <div class="orders">
    <div class="orders__hero">
      <div class="orders__hero-left">
        <div class="orders__hero-icon">
          <ShoppingBag :size="22" />
        </div>
        <div class="orders__hero-text">
          <h1 class="orders__title">Pedidos</h1>
          <p class="orders__subtitle">{{ subtitleText }}</p>
        </div>
      </div>
      <BaseButton variant="primary" class="orders__new-btn" @click="openNewOrder">
        <Plus :size="18" />
        <span class="orders__new-label">Nuevo Pedido</span>
      </BaseButton>
    </div>

    <div class="orders__toolbar">
      <OrderStatusFilter />
    </div>

    <OrderTable @edit="openEditOrder" />

    <BaseModal
      v-if="showModal"
      :title="editingOrder ? 'Editar Pedido' : 'Nuevo Pedido'"
      size="lg"
      @close="showModal = false"
    >
      <OrderForm :order="editingOrder" @save="handleSave" @cancel="showModal = false" />
    </BaseModal>
  </div>
</template>

<style scoped>
.orders {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.orders__hero {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  padding: var(--space-5) var(--space-6);
  background: linear-gradient(135deg, var(--color-bg) 0%, var(--color-bg-secondary) 100%);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-xl, 16px);
  box-shadow: var(--shadow-sm);
}

.orders__hero-left {
  display: flex;
  align-items: center;
  gap: var(--space-4);
  min-width: 0;
}

.orders__hero-icon {
  flex-shrink: 0;
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-accent-light);
  color: var(--color-accent-text);
  border-radius: var(--radius-lg);
}

.orders__hero-text {
  min-width: 0;
}

.orders__title {
  margin: 0;
  font-size: var(--font-size-xl, 1.5rem);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  line-height: 1.2;
}

.orders__subtitle {
  margin: 2px 0 0;
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
}

.orders__toolbar {
  display: flex;
  align-items: center;
  gap: var(--space-3);
}

@media (max-width: 640px) {
  .orders__hero {
    flex-direction: column;
    align-items: stretch;
    padding: var(--space-4);
  }

  .orders__hero-left {
    gap: var(--space-3);
  }

  .orders__new-btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
