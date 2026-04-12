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
      <OrderStatusFilter />
      <BaseButton variant="primary" @click="openNewOrder">
        <Plus :size="18" />
        Nuevo Pedido
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
  flex-wrap: wrap;
  gap: var(--space-3);
}
</style>
