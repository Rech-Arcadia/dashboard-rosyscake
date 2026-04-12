<script setup>
defineProps({
  label: String,
  options: {
    type: Array,
    required: true,
  },
  error: String,
  required: Boolean,
  placeholder: String,
})

const model = defineModel()
</script>

<template>
  <div class="select-group">
    <label v-if="label" class="select-label">
      {{ label }}
      <span v-if="required" class="select-required">*</span>
    </label>
    <div class="select-wrapper">
      <select
        v-model="model"
        class="select"
        :class="{ 'select--error': error }"
        :required="required"
      >
        <option v-if="placeholder" value="" disabled>{{ placeholder }}</option>
        <option v-for="opt in options" :key="opt.value" :value="opt.value">
          {{ opt.label }}
        </option>
      </select>
    </div>
    <span v-if="error" class="select-error">{{ error }}</span>
  </div>
</template>

<style scoped>
.select-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.select-label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
}

.select-required {
  color: #dc2626;
}

.select-wrapper {
  position: relative;
}

.select {
  width: 100%;
  height: 38px;
  padding: 0 var(--space-8) 0 var(--space-3);
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: var(--font-size-sm);
  appearance: none;
  cursor: pointer;
  transition: border-color var(--transition-fast);
}

.select-wrapper::after {
  content: '';
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-left: 5px solid transparent;
  border-right: 5px solid transparent;
  border-top: 5px solid var(--color-gray-muted);
  pointer-events: none;
}

.select:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(254, 194, 214, 0.3);
}

.select--error {
  border-color: #dc2626;
}

.select-error {
  font-size: var(--font-size-xs);
  color: #dc2626;
}
</style>
