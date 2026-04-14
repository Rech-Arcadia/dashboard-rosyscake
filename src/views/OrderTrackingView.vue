<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Cake, Calendar, MapPin, User, Package } from 'lucide-vue-next'
import { supabase } from '@/lib/supabase'
import OrderStatusTracker from '@/components/public/OrderStatusTracker.vue'

const route = useRoute()
const order = ref(null)
const loading = ref(true)
const error = ref('')

async function loadOrder() {
  loading.value = true
  error.value = ''
  const { data, error: err } = await supabase
    .from('orders')
    .select('*')
    .eq('id', route.params.id)
    .maybeSingle()

  if (err || !data) {
    error.value = 'No encontramos tu pedido. Verifica que el link sea correcto.'
  } else {
    order.value = data
  }
  loading.value = false
}

function formatDate(iso) {
  if (!iso) return ''
  return new Date(iso).toLocaleString('es-MX', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    hour: '2-digit',
    minute: '2-digit',
  })
}

onMounted(loadOrder)
</script>

<template>
  <div class="tracking-page">
    <div class="tracking-page__container">
      <header class="tracking-page__header">
        <div class="tracking-page__logo">
          <Cake :size="24" />
        </div>
        <div>
          <h1 class="tracking-page__title">Rosy's Cake</h1>
          <p class="tracking-page__tagline">Seguimiento de tu pedido</p>
        </div>
      </header>

      <div v-if="loading" class="tracking-page__state">Cargando tu pedido...</div>

      <div v-else-if="error" class="tracking-page__state tracking-page__state--error">
        {{ error }}
      </div>

      <div v-else class="tracking-page__card">
        <OrderStatusTracker :estado="order.estado" />

        <div class="tracking-page__details">
          <div class="detail-row">
            <User :size="16" />
            <span>{{ order.cliente }}</span>
          </div>
          <div class="detail-row">
            <Package :size="16" />
            <span>{{ order.producto }} · x{{ order.cantidad }}</span>
          </div>
          <div class="detail-row">
            <Calendar :size="16" />
            <span>{{ formatDate(order.fecha_entrega) }}</span>
          </div>
          <div class="detail-row">
            <MapPin :size="16" />
            <span>{{ order.lugar_entrega }}</span>
          </div>
        </div>

        <img
          v-if="order.imagen_referencia_url"
          :src="order.imagen_referencia_url"
          alt="Referencia"
          class="tracking-page__reference"
        />
      </div>

      <footer class="tracking-page__footer">
        <p>&copy; {{ new Date().getFullYear() }} Rosy's Cake · Hecho con amor</p>
      </footer>
    </div>
  </div>
</template>

<style scoped>
.tracking-page {
  min-height: 100vh;
  background: #fffbfc;
  padding: 2rem 1rem;
}

.tracking-page__container {
  max-width: 560px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.tracking-page__header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.tracking-page__logo {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: #FEC2D6;
  color: #3B1815;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tracking-page__title {
  margin: 0;
  font-size: 1.25rem;
  color: #3B1815;
}

.tracking-page__tagline {
  margin: 0;
  font-size: 0.85rem;
  color: #8a6f6d;
}

.tracking-page__state {
  padding: 2rem;
  text-align: center;
  background: white;
  border-radius: 16px;
  border: 1px solid #fce4ec;
  color: #6b4f4d;
}

.tracking-page__state--error { color: #b42318; }

.tracking-page__card {
  background: white;
  border-radius: 20px;
  border: 1px solid #fce4ec;
  padding: 1.5rem 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  box-shadow: 0 4px 24px rgba(254, 194, 214, 0.15);
}

.tracking-page__details {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding-top: 1rem;
  border-top: 1px dashed #f5e9ec;
}

.detail-row {
  display: flex;
  align-items: center;
  gap: 0.65rem;
  color: #3B1815;
  font-size: 0.92rem;
}

.detail-row :deep(svg) { color: #c48b9b; flex-shrink: 0; }

.tracking-page__reference {
  width: 100%;
  max-height: 280px;
  object-fit: cover;
  border-radius: 14px;
  border: 1px solid #f5e9ec;
}

.tracking-page__footer {
  text-align: center;
  color: #8a6f6d;
  font-size: 0.8rem;
}
</style>
