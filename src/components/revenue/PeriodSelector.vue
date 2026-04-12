<script setup>
defineProps({
  period: {
    type: String,
    required: true,
  },
})

const emit = defineEmits(['change'])

const periods = [
  { value: 'daily', label: 'Diario' },
  { value: 'weekly', label: 'Semanal' },
  { value: 'monthly', label: 'Mensual' },
]
</script>

<template>
  <div class="period-selector">
    <button
      v-for="p in periods"
      :key="p.value"
      class="period-selector__btn"
      :class="{ 'period-selector__btn--active': period === p.value }"
      @click="emit('change', p.value)"
    >
      {{ p.label }}
    </button>
  </div>
</template>

<style scoped>
.period-selector {
  display: flex;
  gap: var(--space-1);
  background: var(--color-bg);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: var(--space-1);
}

.period-selector__btn {
  padding: var(--space-2) var(--space-3);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
}

.period-selector__btn:hover {
  color: var(--color-text);
}

.period-selector__btn--active {
  background: var(--color-accent);
  color: var(--color-accent-text);
}
</style>
