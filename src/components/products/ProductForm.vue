<script setup>
import { ref, computed } from 'vue'
import { Plus, Trash2 } from 'lucide-vue-next'
import { useProductsStore } from '@/stores/products'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseSelect from '@/components/ui/BaseSelect.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

const props = defineProps({
  product: {
    type: Object,
    default: null,
  },
})

const emit = defineEmits(['save', 'cancel'])
const productsStore = useProductsStore()

const form = ref({
  nombre: props.product?.nombre ?? '',
  descripcion: props.product?.descripcion ?? '',
  emoji: props.product?.emoji ?? '🎂',
  categoria: props.product?.categoria ?? 'pasteles',
  activo: props.product?.activo ?? true,
  orden: props.product?.orden ?? 0,
})

const sizes = ref(
  props.product?.sizes?.map((s) => ({ ...s })) ?? [
    { nombre: '', precio: '', descripcion: '', activo: true, orden: 0 },
  ],
)

const saving = ref(false)
const isEditing = computed(() => !!props.product)

const emojis = ['🎂', '🎨', '💒', '🧁', '🍪', '🍞', '🍰', '🎀', '🌸', '✨', '❤️', '🍫']

const categoriaOptions = productsStore.categorias.map((c) => ({
  value: c.value,
  label: c.label,
}))

function addSize() {
  sizes.value.push({
    nombre: '',
    precio: '',
    descripcion: '',
    activo: true,
    orden: sizes.value.length,
  })
}

function removeSize(index) {
  sizes.value.splice(index, 1)
}

async function handleSubmit() {
  saving.value = true
  try {
    const validSizes = sizes.value
      .filter((s) => s.nombre && s.precio)
      .map((s, i) => ({
        nombre: s.nombre,
        precio: Number(s.precio),
        descripcion: s.descripcion || null,
        activo: s.activo,
        orden: i,
      }))

    emit('save', { ...form.value, sizes: validSizes })
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <form class="product-form" @submit.prevent="handleSubmit">
    <!-- Emoji selector -->
    <div class="product-form__emoji-section">
      <label class="product-form__label">Ícono del producto</label>
      <div class="emoji-picker">
        <button
          v-for="e in emojis"
          :key="e"
          type="button"
          class="emoji-btn"
          :class="{ 'emoji-btn--selected': form.emoji === e }"
          @click="form.emoji = e"
        >
          {{ e }}
        </button>
      </div>
    </div>

    <div class="product-form__grid">
      <BaseInput
        v-model="form.nombre"
        label="Nombre del producto"
        placeholder="Ej: Pastel de chocolate"
        required
      />

      <BaseSelect
        v-model="form.categoria"
        label="Categoría"
        :options="categoriaOptions"
        required
      />

      <div class="product-form__full">
        <BaseInput
          v-model="form.descripcion"
          label="Descripción"
          placeholder="Breve descripción del producto"
        />
      </div>

      <BaseInput
        v-model="form.orden"
        label="Orden de aparición"
        type="number"
        placeholder="0"
      />
    </div>

    <!-- Sizes section -->
    <div class="sizes-section">
      <div class="sizes-section__header">
        <h3 class="sizes-section__title">Tamaños y Precios</h3>
        <BaseButton variant="ghost" size="sm" type="button" @click="addSize">
          <Plus :size="16" />
          Agregar tamaño
        </BaseButton>
      </div>

      <div v-if="!sizes.length" class="sizes-section__empty">
        <p>No hay tamaños definidos. Agrega al menos uno.</p>
      </div>

      <div v-else class="sizes-list">
        <div v-for="(size, index) in sizes" :key="index" class="size-row">
          <div class="size-row__fields">
            <BaseInput
              v-model="size.nombre"
              label="Tamaño"
              placeholder="Ej: Chico (10 personas)"
              required
            />
            <BaseInput
              v-model="size.precio"
              label="Precio (MXN)"
              type="number"
              placeholder="0.00"
              required
            />
            <BaseInput
              v-model="size.descripcion"
              label="Nota"
              placeholder="Opcional"
            />
          </div>
          <button
            type="button"
            class="size-row__delete"
            title="Eliminar tamaño"
            @click="removeSize(index)"
          >
            <Trash2 :size="16" />
          </button>
        </div>
      </div>
    </div>

    <div class="product-form__actions">
      <BaseButton variant="secondary" type="button" @click="emit('cancel')">
        Cancelar
      </BaseButton>
      <BaseButton variant="primary" :loading="saving">
        {{ isEditing ? 'Guardar cambios' : 'Crear producto' }}
      </BaseButton>
    </div>
  </form>
</template>

<style scoped>
.product-form__emoji-section {
  margin-bottom: var(--space-5);
}

.product-form__label {
  display: block;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
  margin-bottom: var(--space-2);
}

.emoji-picker {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
}

.emoji-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.25rem;
  border-radius: var(--radius-md);
  border: 2px solid transparent;
  background: var(--color-bg-secondary);
  transition: all var(--transition-fast);
}

.emoji-btn:hover {
  border-color: var(--color-border);
  transform: scale(1.1);
}

.emoji-btn--selected {
  border-color: var(--color-accent);
  background: var(--color-accent-light);
}

.product-form__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}

.product-form__full {
  grid-column: 1 / -1;
}

/* Sizes */
.sizes-section {
  margin-top: var(--space-6);
  padding-top: var(--space-5);
  border-top: 1px solid var(--color-border-light);
}

.sizes-section__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-4);
}

.sizes-section__title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
}

.sizes-section__empty {
  padding: var(--space-5);
  text-align: center;
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-md);
}

.sizes-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
}

.size-row {
  display: flex;
  gap: var(--space-3);
  align-items: flex-end;
  padding: var(--space-4);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-lg);
}

.size-row__fields {
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 120px 1fr;
  gap: var(--space-3);
}

.size-row__delete {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
  flex-shrink: 0;
}

.size-row__delete:hover {
  background: #fee2e2;
  color: #dc2626;
}

.product-form__actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--space-3);
  margin-top: var(--space-6);
  padding-top: var(--space-5);
  border-top: 1px solid var(--color-border-light);
}

@media (max-width: 640px) {
  .product-form__grid {
    grid-template-columns: 1fr;
  }

  .size-row__fields {
    grid-template-columns: 1fr;
  }

  .size-row {
    flex-direction: column;
    align-items: stretch;
  }

  .size-row__delete {
    align-self: flex-end;
  }
}
</style>
