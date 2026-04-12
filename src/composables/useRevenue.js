import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import { format, subDays, subMonths, startOfMonth } from 'date-fns'

export function useRevenue() {
  const data = ref([])
  const period = ref('daily')
  const loading = ref(false)

  function getDateRange() {
    const end = new Date()
    let start

    switch (period.value) {
      case 'daily':
        start = subDays(end, 30)
        break
      case 'weekly':
        start = subMonths(end, 3)
        break
      case 'monthly':
        start = subMonths(end, 12)
        break
      default:
        start = subDays(end, 30)
    }

    return {
      start_date: format(start, 'yyyy-MM-dd'),
      end_date: format(end, 'yyyy-MM-dd'),
    }
  }

  async function fetchRevenue() {
    loading.value = true
    const { start_date, end_date } = getDateRange()

    const { data: rows, error } = await supabase.rpc('revenue_by_period', {
      period: period.value,
      start_date,
      end_date,
    })

    if (!error && rows) {
      data.value = rows
    } else {
      // Fallback: calculate from orders directly if RPC not available
      await fetchRevenueFromOrders(start_date, end_date)
    }

    loading.value = false
  }

  async function fetchRevenueFromOrders(startDate, endDate) {
    const { data: orders, error } = await supabase
      .from('orders')
      .select('fecha_entrega, total_venta, estado')
      .gte('fecha_entrega', startDate)
      .lte('fecha_entrega', endDate)
      .neq('estado', 'pendiente')

    if (error || !orders) {
      data.value = []
      return
    }

    // Aggregate by period
    const grouped = {}
    for (const order of orders) {
      let key
      const date = new Date(order.fecha_entrega)

      switch (period.value) {
        case 'daily':
          key = format(date, 'yyyy-MM-dd')
          break
        case 'weekly': {
          const weekStart = new Date(date)
          weekStart.setDate(date.getDate() - date.getDay())
          key = format(weekStart, 'yyyy-MM-dd')
          break
        }
        case 'monthly':
          key = format(date, 'yyyy-MM')
          break
      }

      if (!grouped[key]) {
        grouped[key] = { period_label: key, total: 0, order_count: 0 }
      }
      grouped[key].total += Number(order.total_venta)
      grouped[key].order_count += 1
    }

    data.value = Object.values(grouped).sort((a, b) => a.period_label.localeCompare(b.period_label))
  }

  const chartData = computed(() => {
    const labels = data.value.map((r) => {
      if (period.value === 'monthly') {
        const [year, month] = r.period_label.split('-')
        const date = new Date(year, month - 1)
        return format(date, 'MMM yyyy')
      }
      const date = new Date(r.period_label + 'T00:00:00')
      return period.value === 'daily' ? format(date, 'dd MMM') : format(date, 'dd MMM')
    })

    return {
      labels,
      datasets: [
        {
          label: 'Ingresos (MXN)',
          data: data.value.map((r) => Number(r.total)),
          borderColor: '#FEC2D6',
          backgroundColor: 'rgba(254, 194, 214, 0.15)',
          fill: true,
          tension: 0.4,
          pointBackgroundColor: '#FEC2D6',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6,
        },
      ],
    }
  })

  const totalRevenue = computed(() => {
    return data.value.reduce((sum, r) => sum + Number(r.total), 0)
  })

  const totalOrders = computed(() => {
    return data.value.reduce((sum, r) => sum + Number(r.order_count), 0)
  })

  return { data, period, loading, fetchRevenue, chartData, totalRevenue, totalOrders }
}
