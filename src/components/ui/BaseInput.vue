<script setup>
const props = defineProps({
  label: String,
  type: {
    type: String,
    default: 'text',
  },
  placeholder: String,
  error: String,
  required: Boolean,
})

const model = defineModel()
</script>

<template>
  <div class="input-group">
    <label v-if="label" class="input-label">
      {{ label }}
      <span v-if="required" class="input-required">*</span>
    </label>
    <input
      v-model="model"
      class="input"
      :class="{ 'input--error': error }"
      :type="type"
      :placeholder="placeholder"
      :required="required"
    />
    <span v-if="error" class="input-error">{{ error }}</span>
  </div>
</template>

<style scoped>
.input-group {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.input-label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
}

.input-required {
  color: #dc2626;
}

.input {
  height: 38px;
  padding: 0 var(--space-3);
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  font-size: var(--font-size-sm);
  transition: border-color var(--transition-fast);
}

.input::placeholder {
  color: var(--color-gray-subtle);
}

.input:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(254, 194, 214, 0.3);
}

.input--error {
  border-color: #dc2626;
}

.input-error {
  font-size: var(--font-size-xs);
  color: #dc2626;
}
</style>
