<script setup>
defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (v) => ['primary', 'secondary', 'ghost', 'danger'].includes(v),
  },
  size: {
    type: String,
    default: 'md',
    validator: (v) => ['sm', 'md', 'lg'].includes(v),
  },
  loading: Boolean,
  disabled: Boolean,
  block: Boolean,
})

defineEmits(['click'])
</script>

<template>
  <button
    class="btn"
    :class="[`btn--${variant}`, `btn--${size}`, { 'btn--block': block, 'btn--loading': loading }]"
    :disabled="disabled || loading"
    @click="$emit('click', $event)"
  >
    <span v-if="loading" class="btn__spinner" />
    <slot />
  </button>
</template>

<style scoped>
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-md);
  transition: all var(--transition-fast);
  white-space: nowrap;
  cursor: pointer;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Sizes */
.btn--sm {
  padding: var(--space-1) var(--space-3);
  font-size: var(--font-size-sm);
  height: 32px;
}

.btn--md {
  padding: var(--space-2) var(--space-4);
  font-size: var(--font-size-sm);
  height: 38px;
}

.btn--lg {
  padding: var(--space-3) var(--space-6);
  font-size: var(--font-size-base);
  height: 44px;
}

/* Variants */
.btn--primary {
  background: var(--color-accent);
  color: var(--color-accent-text);
}

.btn--primary:hover:not(:disabled) {
  background: var(--color-accent-hover);
}

.btn--secondary {
  background: var(--color-bg);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.btn--secondary:hover:not(:disabled) {
  background: var(--color-bg-secondary);
}

.btn--ghost {
  background: transparent;
  color: var(--color-text);
}

.btn--ghost:hover:not(:disabled) {
  background: var(--color-bg-secondary);
}

.btn--danger {
  background: #fee2e2;
  color: #dc2626;
}

.btn--danger:hover:not(:disabled) {
  background: #fecaca;
}

.btn--block {
  width: 100%;
}

/* Loading spinner */
.btn--loading {
  position: relative;
  color: transparent;
}

.btn__spinner {
  position: absolute;
  width: 16px;
  height: 16px;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

.btn--loading .btn__spinner {
  color: var(--color-text);
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
