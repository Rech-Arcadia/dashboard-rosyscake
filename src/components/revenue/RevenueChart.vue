<script setup>
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend, Filler)

defineProps({
  chartData: {
    type: Object,
    required: true,
  },
})

const options = {
  responsive: true,
  maintainAspectRatio: false,
  interaction: {
    intersect: false,
    mode: 'index',
  },
  plugins: {
    legend: {
      display: false,
    },
    tooltip: {
      backgroundColor: '#3B1815',
      titleFont: { family: 'Inter' },
      bodyFont: { family: 'Inter' },
      padding: 12,
      cornerRadius: 8,
      callbacks: {
        label: (ctx) => {
          return `$${ctx.parsed.y.toLocaleString('es-MX', { minimumFractionDigits: 2 })}`
        },
      },
    },
  },
  scales: {
    x: {
      grid: { display: false },
      ticks: {
        font: { family: 'Inter', size: 11 },
        color: '#8b6a67',
      },
    },
    y: {
      grid: {
        color: 'rgba(232, 224, 222, 0.5)',
      },
      ticks: {
        font: { family: 'Inter', size: 11 },
        color: '#8b6a67',
        callback: (value) => `$${value.toLocaleString()}`,
      },
    },
  },
}
</script>

<template>
  <div class="chart">
    <Line :data="chartData" :options="options" />
  </div>
</template>

<style scoped>
.chart {
  width: 100%;
  height: 350px;
}
</style>
