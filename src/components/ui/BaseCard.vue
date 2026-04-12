<script setup>
defineProps({
  padding: {
    type: String,
    default: 'md',
    validator: (v) => ['sm', 'md', 'lg'].includes(v),
  },
  hoverable: Boolean,
})
</script>

<template>
  <div class="card" :class="[`card--pad-${padding}`, { 'card--hoverable': hoverable }]">
    <slot />
  </div>
</template>

<style scoped>
.card {
  background: var(--color-card-bg);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  transition: box-shadow var(--transition-fast);
}

.card--pad-sm {
  padding: var(--space-3);
}

.card--pad-md {
  padding: var(--space-5);
}

.card--pad-lg {
  padding: var(--space-8);
}

.card--hoverable:hover {
  box-shadow: var(--shadow-md);
}
</style>
