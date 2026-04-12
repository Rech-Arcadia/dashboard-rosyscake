<script setup>
defineProps({
  status: {
    type: String,
    required: true,
    validator: (v) => ['pendiente', 'en_proceso', 'listo', 'entregado'].includes(v),
  },
})

const statusLabels = {
  pendiente: 'Pendiente',
  en_proceso: 'En Proceso',
  listo: 'Listo',
  entregado: 'Entregado',
}
</script>

<template>
  <span class="badge" :class="`badge--${status}`">
    {{ statusLabels[status] }}
  </span>
</template>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  padding: 2px var(--space-2);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-full);
  white-space: nowrap;
}

.badge--pendiente {
  background: var(--color-status-pendiente-bg);
  color: var(--color-status-pendiente);
}

.badge--en_proceso {
  background: var(--color-status-en-proceso-bg);
  color: var(--color-status-en-proceso);
}

.badge--listo {
  background: var(--color-status-listo-bg);
  color: var(--color-status-listo);
}

.badge--entregado {
  background: var(--color-status-entregado-bg);
  color: var(--color-status-entregado);
}
</style>
