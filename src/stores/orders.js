import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'
import { isToday, parseISO } from 'date-fns'

export const useOrdersStore = defineStore('orders', () => {
  const orders = ref([])
  const loading = ref(false)
  const filter = ref('todos')

  // Computed
  const filteredOrders = computed(() => {
    if (filter.value === 'todos') return orders.value
    return orders.value.filter((o) => o.estado === filter.value)
  })

  const todayOrders = computed(() => {
    return orders.value.filter((o) => {
      const fecha = typeof o.fecha_entrega === 'string' ? parseISO(o.fecha_entrega) : o.fecha_entrega
      return isToday(fecha)
    })
  })

  const orderCounts = computed(() => ({
    total: orders.value.length,
    pendiente: orders.value.filter((o) => o.estado === 'pendiente').length,
    en_proceso: orders.value.filter((o) => o.estado === 'en_proceso').length,
    listo: orders.value.filter((o) => o.estado === 'listo').length,
    entregado: orders.value.filter((o) => o.estado === 'entregado').length,
  }))

  const totalRevenue = computed(() => {
    return orders.value
      .filter((o) => o.estado !== 'pendiente')
      .reduce((sum, o) => sum + Number(o.total_venta), 0)
  })

  // Actions
  async function fetchOrders() {
    loading.value = true
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .order('fecha_entrega', { ascending: true })

    if (!error) {
      orders.value = data
    }
    loading.value = false
  }

  async function createOrder(orderData) {
    const { data, error } = await supabase
      .from('orders')
      .insert([orderData])
      .select()
      .single()

    if (error) throw error
    orders.value.push(data)
    return data
  }

  async function updateOrder(id, updates) {
    const { data, error } = await supabase
      .from('orders')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    const index = orders.value.findIndex((o) => o.id === id)
    if (index !== -1) orders.value[index] = data
    return data
  }

  async function deleteOrder(id) {
    const { error } = await supabase.from('orders').delete().eq('id', id)
    if (error) throw error
    orders.value = orders.value.filter((o) => o.id !== id)
  }

  async function updateStatus(id, estado) {
    return updateOrder(id, { estado })
  }

  function setFilter(status) {
    filter.value = status
  }

  return {
    orders,
    loading,
    filter,
    filteredOrders,
    todayOrders,
    orderCounts,
    totalRevenue,
    fetchOrders,
    createOrder,
    updateOrder,
    deleteOrder,
    updateStatus,
    setFilter,
  }
})
