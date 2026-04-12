<script setup>
import { ref, onMounted } from 'vue'
import { Plus } from 'lucide-vue-next'
import { useOrdersStore } from '@/stores/orders'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import OrderTable from '@/components/orders/OrderTable.vue'
import OrderForm from '@/components/orders/OrderForm.vue'
import OrderStatusFilter from '@/components/orders/OrderStatusFilter.vue'

const ordersStore = useOrdersStore()
const showModal = ref(false)
const editingOrder = ref(null)

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
    <div class="orders__header">
      <div class="orders__filter-wrapper">
        <OrderStatusFilter />
      </div>
      <BaseButton variant="primary" class="orders__new-btn" @click="openNewOrder">
        <Plus :size="18" />
        <span class="orders__new-label">Nuevo Pedido</span>
      </BaseButton>
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

.orders__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-3);
}

.orders__filter-wrapper {
  flex: 1;
  min-width: 0;
}

@media (max-width: 640px) {
  .orders__header {
    flex-direction: column;
    align-items: stretch;
  }

  .orders__filter-wrapper {
    width: 100%;
  }

  .orders__new-btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
