<script setup>
import { onMounted, computed } from 'vue'
import { useOrdersStore } from '@/stores/orders'
import SummaryCards from '@/components/dashboard/SummaryCards.vue'
import OrderCalendar from '@/components/dashboard/OrderCalendar.vue'
import TodayOrders from '@/components/dashboard/TodayOrders.vue'

const ordersStore = useOrdersStore()

onMounted(() => {
  ordersStore.fetchOrders()
})
</script>

<template>
  <div class="dashboard">
    <SummaryCards />

    <div class="dashboard__grid">
      <OrderCalendar />
      <TodayOrders />
    </div>
  </div>
</template>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.dashboard__grid {
  display: grid;
  grid-template-columns: 1fr 360px;
  gap: var(--space-6);
}

@media (max-width: 1024px) {
  .dashboard__grid {
    grid-template-columns: 1fr;
  }
}
</style>
