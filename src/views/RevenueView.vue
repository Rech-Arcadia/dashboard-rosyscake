<script setup>
import { onMounted } from 'vue'
import { useRevenue } from '@/composables/useRevenue'
import BaseCard from '@/components/ui/BaseCard.vue'
import RevenueChart from '@/components/revenue/RevenueChart.vue'
import RevenueSummary from '@/components/revenue/RevenueSummary.vue'
import PeriodSelector from '@/components/revenue/PeriodSelector.vue'

const { data, period, loading, fetchRevenue, chartData, totalRevenue, totalOrders } = useRevenue()

onMounted(() => {
  fetchRevenue()
})

function handlePeriodChange(newPeriod) {
  period.value = newPeriod
  fetchRevenue()
}
</script>

<template>
  <div class="revenue">
    <div class="revenue__header">
      <h2 class="revenue__title">Análisis de Ingresos</h2>
      <PeriodSelector :period="period" @change="handlePeriodChange" />
    </div>

    <RevenueSummary :total-revenue="totalRevenue" :total-orders="totalOrders" :loading="loading" />

    <BaseCard>
      <div class="revenue__chart-container">
        <RevenueChart v-if="!loading && chartData.labels.length" :chart-data="chartData" />
        <p v-else-if="!loading" class="revenue__empty">No hay datos para el periodo seleccionado</p>
        <p v-else class="revenue__loading">Cargando datos...</p>
      </div>
    </BaseCard>
  </div>
</template>

<style scoped>
.revenue {
  display: flex;
  flex-direction: column;
  gap: var(--space-6);
}

.revenue__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: var(--space-3);
}

.revenue__title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
}

.revenue__chart-container {
  min-height: 350px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.revenue__empty,
.revenue__loading {
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}
</style>
