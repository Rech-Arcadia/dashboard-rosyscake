<script setup>
import { ref, onMounted } from 'vue'
import { Plus, Pencil, Trash2, Eye, EyeOff } from 'lucide-vue-next'
import { useProductsStore } from '@/stores/products'
import BaseCard from '@/components/ui/BaseCard.vue'
import BaseButton from '@/components/ui/BaseButton.vue'
import BaseBadge from '@/components/ui/BaseBadge.vue'
import BaseModal from '@/components/ui/BaseModal.vue'
import ProductForm from '@/components/products/ProductForm.vue'

const productsStore = useProductsStore()
const showModal = ref(false)
const editingProduct = ref(null)
const filterCategoria = ref('todos')

onMounted(() => {
  productsStore.fetchProducts()
})

function openNewProduct() {
  editingProduct.value = null
  showModal.value = true
}

function openEditProduct(product) {
  editingProduct.value = { ...product, sizes: [...(product.product_sizes || [])] }
  showModal.value = true
}

async function handleSave(data) {
  if (editingProduct.value) {
    await productsStore.updateProduct(editingProduct.value.id, data)
  } else {
    await productsStore.createProduct(data)
  }
  showModal.value = false
}

async function handleDelete(product) {
  if (!confirm(`¿Eliminar "${product.nombre}"? Esto no se puede deshacer.`)) return
  await productsStore.deleteProduct(product.id)
}

async function handleToggle(product) {
  await productsStore.toggleActive(product.id, !product.activo)
}

function filteredProducts() {
  if (filterCategoria.value === 'todos') return productsStore.products
  return productsStore.products.filter((p) => p.categoria === filterCategoria.value)
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
}

function priceRange(product) {
  const sizes = product.product_sizes || []
  if (!sizes.length) return 'Sin precios'
  const prices = sizes.filter((s) => s.activo).map((s) => Number(s.precio))
  if (!prices.length) return 'Sin precios activos'
  const min = Math.min(...prices)
  const max = Math.max(...prices)
  if (min === max) return formatCurrency(min)
  return `${formatCurrency(min)} - ${formatCurrency(max)}`
}
</script>

<template>
  <div class="products-page">
    <div class="products-page__header">
      <div class="products-page__filters">
        <button
          class="filter-btn"
          :class="{ 'filter-btn--active': filterCategoria === 'todos' }"
          @click="filterCategoria = 'todos'"
        >
          Todos
        </button>
        <button
          v-for="cat in productsStore.categorias"
          :key="cat.value"
          class="filter-btn"
          :class="{ 'filter-btn--active': filterCategoria === cat.value }"
          @click="filterCategoria = cat.value"
        >
          {{ cat.label }}
        </button>
      </div>
      <BaseButton variant="primary" @click="openNewProduct">
        <Plus :size="18" />
        Nuevo Producto
      </BaseButton>
    </div>

    <div v-if="productsStore.loading" class="products-page__loading">
      Cargando productos...
    </div>

    <div v-else-if="!filteredProducts().length" class="products-page__empty">
      <p>No hay productos registrados</p>
      <BaseButton variant="primary" size="sm" @click="openNewProduct">
        Agregar el primero
      </BaseButton>
    </div>

    <div v-else class="products-grid">
      <BaseCard
        v-for="product in filteredProducts()"
        :key="product.id"
        hoverable
        class="product-item"
        :class="{ 'product-item--inactive': !product.activo }"
      >
        <div class="product-item__header">
          <div class="product-item__emoji">{{ product.emoji }}</div>
          <div class="product-item__info">
            <h3 class="product-item__name">{{ product.nombre }}</h3>
            <span class="product-item__category">{{ product.categoria }}</span>
          </div>
          <div class="product-item__status">
            <span
              class="status-dot"
              :class="product.activo ? 'status-dot--active' : 'status-dot--inactive'"
            />
          </div>
        </div>

        <p v-if="product.descripcion" class="product-item__desc">
          {{ product.descripcion }}
        </p>

        <div class="product-item__price">
          {{ priceRange(product) }}
        </div>

        <div v-if="product.product_sizes?.length" class="product-item__sizes">
          <div
            v-for="size in product.product_sizes.filter((s) => s.activo)"
            :key="size.id"
            class="size-tag"
          >
            <span class="size-tag__name">{{ size.nombre }}</span>
            <span class="size-tag__price">{{ formatCurrency(size.precio) }}</span>
          </div>
        </div>

        <div class="product-item__actions">
          <button
            class="action-btn"
            :title="product.activo ? 'Desactivar' : 'Activar'"
            @click="handleToggle(product)"
          >
            <Eye v-if="product.activo" :size="16" />
            <EyeOff v-else :size="16" />
          </button>
          <button class="action-btn" title="Editar" @click="openEditProduct(product)">
            <Pencil :size="16" />
          </button>
          <button class="action-btn action-btn--danger" title="Eliminar" @click="handleDelete(product)">
            <Trash2 :size="16" />
          </button>
        </div>
      </BaseCard>
    </div>

    <BaseModal
      v-if="showModal"
      :title="editingProduct ? 'Editar Producto' : 'Nuevo Producto'"
      size="lg"
      @close="showModal = false"
    >
      <ProductForm
        :product="editingProduct"
        @save="handleSave"
        @cancel="showModal = false"
      />
    </BaseModal>
  </div>
</template>

<style scoped>
.products-page {
  display: flex;
  flex-direction: column;
  gap: var(--space-5);
}

.products-page__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: var(--space-3);
}

.products-page__filters {
  display: flex;
  gap: var(--space-1);
  background: var(--color-bg);
  border: 1px solid var(--color-border-light);
  border-radius: var(--radius-lg);
  padding: var(--space-1);
  overflow-x: auto;
}

.filter-btn {
  padding: var(--space-2) var(--space-3);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
  white-space: nowrap;
}

.filter-btn:hover {
  color: var(--color-text);
}

.filter-btn--active {
  background: var(--color-accent);
  color: var(--color-accent-text);
}

.products-page__loading,
.products-page__empty {
  text-align: center;
  padding: var(--space-12);
  color: var(--color-text-muted);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-3);
}

.products-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: var(--space-5);
}

.product-item--inactive {
  opacity: 0.55;
}

.product-item__header {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-bottom: var(--space-3);
}

.product-item__emoji {
  width: 48px;
  height: 48px;
  background: var(--color-accent-light);
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.product-item__info {
  flex: 1;
  min-width: 0;
}

.product-item__name {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.product-item__category {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
  text-transform: capitalize;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.status-dot--active {
  background: var(--color-status-listo);
}

.status-dot--inactive {
  background: var(--color-status-entregado);
}

.product-item__desc {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  margin-bottom: var(--space-3);
  line-height: 1.5;
}

.product-item__price {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--space-3);
}

.product-item__sizes {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-2);
  margin-bottom: var(--space-4);
}

.size-tag {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-1) var(--space-2);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-md);
  font-size: var(--font-size-xs);
}

.size-tag__name {
  color: var(--color-text-muted);
}

.size-tag__price {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.product-item__actions {
  display: flex;
  gap: var(--space-1);
  padding-top: var(--space-3);
  border-top: 1px solid var(--color-border-light);
}

.action-btn {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
}

.action-btn:hover {
  background: var(--color-bg-secondary);
  color: var(--color-text);
}

.action-btn--danger:hover {
  background: #fee2e2;
  color: #dc2626;
}

@media (max-width: 640px) {
  .products-grid {
    grid-template-columns: 1fr;
  }
}
</style>
