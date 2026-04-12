<script setup>
import { ref, computed, onMounted } from 'vue'
import { Cake, CheckCircle, Phone, User, MapPin, Calendar, MessageCircle, Package, Hash, DollarSign, Banknote, CreditCard, ArrowLeftRight, Upload, FileCheck } from 'lucide-vue-next'
import { supabase } from '@/lib/supabase'
import BaseButton from '@/components/ui/BaseButton.vue'

const form = ref({
  cliente: '',
  telefono: '',
  producto: '',
  cantidad: 1,
  mensaje_pastel: '',
  total_venta: '',
  lugar_entrega: '',
  fecha_entrega: '',
  metodo_pago: '',
})

const saving = ref(false)
const submitted = ref(false)
const error = ref('')
const currentStep = ref(1)

const comprobanteFile = ref(null)
const comprobantePreview = ref('')

const metodosPago = [
  { value: 'efectivo', label: 'Efectivo', description: 'Paga al recibir', icon: Banknote },
  { value: 'transferencia', label: 'Transferencia', description: 'Sube tu comprobante', icon: ArrowLeftRight },
  { value: 'tarjeta', label: 'Tarjeta (Mercado Pago)', description: 'Te enviamos el link de pago', icon: CreditCard },
]

function handleComprobanteChange(event) {
  const file = event.target.files?.[0]
  if (!file) {
    comprobanteFile.value = null
    comprobantePreview.value = ''
    return
  }
  comprobanteFile.value = file
  if (file.type.startsWith('image/')) {
    comprobantePreview.value = URL.createObjectURL(file)
  } else {
    comprobantePreview.value = ''
  }
}

function selectMetodoPago(value) {
  form.value.metodo_pago = value
  if (value !== 'transferencia') {
    comprobanteFile.value = null
    comprobantePreview.value = ''
  }
}

// Dynamic products from Supabase
const productos = ref([])
const loadingProducts = ref(true)
const selectedProduct = ref(null)
const selectedSize = ref(null)

onMounted(async () => {
  const { data } = await supabase
    .from('products')
    .select('*, product_sizes(*)')
    .eq('activo', true)
    .order('orden', { ascending: true })

  if (data) {
    productos.value = data.map((p) => ({
      ...p,
      product_sizes: (p.product_sizes || [])
        .filter((s) => s.activo)
        .sort((a, b) => a.orden - b.orden),
    }))
  }
  loadingProducts.value = false
})

const activeSizes = computed(() => {
  if (!selectedProduct.value) return []
  return selectedProduct.value.product_sizes || []
})

function selectProduct(product) {
  selectedProduct.value = product
  form.value.producto = product.nombre
  // Reset size selection when changing product
  selectedSize.value = null
  form.value.total_venta = ''
}

function selectSize(size) {
  selectedSize.value = size
  form.value.total_venta = size.precio
}

function nextStep() {
  currentStep.value++
}

function prevStep() {
  currentStep.value--
}

function canGoNext() {
  if (currentStep.value === 1) {
    const hasSizes = selectedProduct.value?.product_sizes?.length > 0
    return !!form.value.producto && (!hasSizes || !!selectedSize.value)
  }
  if (currentStep.value === 2) return !!form.value.cliente && !!form.value.telefono
  if (currentStep.value === 3) {
    if (!form.value.lugar_entrega || !form.value.fecha_entrega || !form.value.total_venta) return false
    if (!form.value.metodo_pago) return false
    if (form.value.metodo_pago === 'transferencia' && !comprobanteFile.value) return false
    return true
  }
  return true
}

async function uploadComprobante() {
  if (!comprobanteFile.value) return null
  const file = comprobanteFile.value
  const ext = file.name.split('.').pop()
  const fileName = `${Date.now()}-${Math.random().toString(36).slice(2, 10)}.${ext}`

  const { error: uploadError } = await supabase.storage
    .from('comprobantes')
    .upload(fileName, file, { cacheControl: '3600', upsert: false })

  if (uploadError) throw uploadError

  const { data } = supabase.storage.from('comprobantes').getPublicUrl(fileName)
  return data.publicUrl
}

async function handleSubmit() {
  error.value = ''
  saving.value = true

  try {
    let comprobante_url = null
    if (form.value.metodo_pago === 'transferencia') {
      comprobante_url = await uploadComprobante()
    }

    const { error: insertError } = await supabase.from('orders').insert([
      {
        ...form.value,
        cantidad: Number(form.value.cantidad),
        total_venta: Number(form.value.total_venta),
        estado: 'pendiente',
        origen: 'formulario_publico',
        comprobante_url,
      },
    ])

    if (insertError) throw insertError
    submitted.value = true
  } catch (err) {
    error.value = 'Hubo un error al enviar tu pedido. Intenta de nuevo.'
  } finally {
    saving.value = false
  }
}

function resetForm() {
  form.value = {
    cliente: '',
    telefono: '',
    producto: '',
    cantidad: 1,
    mensaje_pastel: '',
    total_venta: '',
    lugar_entrega: '',
    fecha_entrega: '',
    metodo_pago: '',
  }
  comprobanteFile.value = null
  comprobantePreview.value = ''
  submitted.value = false
  error.value = ''
  currentStep.value = 1
  selectedProduct.value = null
  selectedSize.value = null
}
</script>

<template>
  <div class="page">
    <!-- Decorative background -->
    <div class="page__bg">
      <div class="page__blob page__blob--1" />
      <div class="page__blob page__blob--2" />
      <div class="page__blob page__blob--3" />
    </div>

    <div class="page__container">
      <!-- Header -->
      <header class="header">
        <div class="header__logo">
          <Cake :size="28" />
        </div>
        <div>
          <h1 class="header__title">Rosy's Cake</h1>
          <p class="header__tagline">Endulzamos tus momentos especiales</p>
        </div>
      </header>

      <!-- Success -->
      <div v-if="submitted" class="success">
        <div class="success__card">
          <div class="success__icon-wrapper">
            <div class="success__icon">
              <CheckCircle :size="40" />
            </div>
          </div>
          <h2 class="success__title">¡Pedido enviado!</h2>
          <p class="success__text">
            Tu pedido ha sido registrado exitosamente.<br />
            Nos pondremos en contacto contigo pronto para confirmar los detalles.
          </p>
          <div class="success__summary">
            <div class="success__row">
              <span>Producto</span>
              <strong>{{ form.producto }}</strong>
            </div>
            <div class="success__row">
              <span>Cantidad</span>
              <strong>{{ form.cantidad }}</strong>
            </div>
            <div class="success__row">
              <span>Cliente</span>
              <strong>{{ form.cliente }}</strong>
            </div>
          </div>
          <BaseButton variant="primary" size="lg" block @click="resetForm">
            Hacer otro pedido
          </BaseButton>
        </div>
      </div>

      <!-- Form -->
      <div v-else class="form-wrapper">
        <!-- Progress bar -->
        <div class="progress">
          <div class="progress__bar">
            <div class="progress__fill" :style="{ width: `${(currentStep / 3) * 100}%` }" />
          </div>
          <div class="progress__steps">
            <button
              v-for="step in 3"
              :key="step"
              class="progress__step"
              :class="{
                'progress__step--active': currentStep === step,
                'progress__step--done': currentStep > step,
              }"
              @click="step < currentStep && (currentStep = step)"
            >
              {{ step }}
            </button>
          </div>
          <p class="progress__label">
            {{ currentStep === 1 ? '¿Qué te gustaría?' : currentStep === 2 ? 'Tus datos' : 'Entrega y pago' }}
          </p>
        </div>

        <form @submit.prevent="handleSubmit">
          <!-- Step 1: Product selection -->
          <div v-show="currentStep === 1" class="step">
            <h2 class="step__title">¿Qué te gustaría ordenar?</h2>
            <p class="step__subtitle">Selecciona el producto que deseas</p>

            <div v-if="loadingProducts" class="step__loading">Cargando productos...</div>

            <div v-else-if="!productos.length" class="step__loading">
              No hay productos disponibles en este momento.
            </div>

            <template v-else>
              <div class="products">
                <button
                  v-for="prod in productos"
                  :key="prod.id"
                  type="button"
                  class="product-card"
                  :class="{ 'product-card--selected': selectedProduct?.id === prod.id }"
                  @click="selectProduct(prod)"
                >
                  <span class="product-card__emoji">{{ prod.emoji }}</span>
                  <span class="product-card__name">{{ prod.nombre }}</span>
                  <span v-if="prod.product_sizes.length" class="product-card__price">
                    Desde ${{ Math.min(...prod.product_sizes.map(s => Number(s.precio))).toLocaleString() }}
                  </span>
                </button>
              </div>

              <!-- Size selection -->
              <div v-if="activeSizes.length" class="step__field">
                <label class="field__label">
                  <Package :size="16" />
                  Selecciona el tamaño
                </label>
                <div class="sizes">
                  <button
                    v-for="size in activeSizes"
                    :key="size.id"
                    type="button"
                    class="size-card"
                    :class="{ 'size-card--selected': selectedSize?.id === size.id }"
                    @click="selectSize(size)"
                  >
                    <span class="size-card__name">{{ size.nombre }}</span>
                    <span class="size-card__price">${{ Number(size.precio).toLocaleString() }}</span>
                    <span v-if="size.descripcion" class="size-card__desc">{{ size.descripcion }}</span>
                  </button>
                </div>
              </div>
            </template>

            <div class="step__field">
              <label class="field__label">
                <Hash :size="16" />
                Cantidad
              </label>
              <div class="quantity">
                <button type="button" class="quantity__btn" @click="form.cantidad > 1 && form.cantidad--">−</button>
                <span class="quantity__value">{{ form.cantidad }}</span>
                <button type="button" class="quantity__btn" @click="form.cantidad++">+</button>
              </div>
            </div>

            <div class="step__field">
              <label class="field__label">
                <MessageCircle :size="16" />
                Mensaje en el pastel
                <span class="field__optional">opcional</span>
              </label>
              <input
                v-model="form.mensaje_pastel"
                class="field__input"
                placeholder='Ej: "Feliz cumpleaños Ana"'
              />
            </div>
          </div>

          <!-- Step 2: Customer info -->
          <div v-show="currentStep === 2" class="step">
            <h2 class="step__title">Cuéntanos sobre ti</h2>
            <p class="step__subtitle">Para poder contactarte sobre tu pedido</p>

            <div class="step__field">
              <label class="field__label">
                <User :size="16" />
                Nombre completo
              </label>
              <input
                v-model="form.cliente"
                class="field__input"
                placeholder="Tu nombre"
                required
              />
            </div>

            <div class="step__field">
              <label class="field__label">
                <Phone :size="16" />
                Teléfono
              </label>
              <input
                v-model="form.telefono"
                class="field__input"
                placeholder="Tu número de WhatsApp o teléfono"
                required
              />
            </div>
          </div>

          <!-- Step 3: Delivery & payment -->
          <div v-show="currentStep === 3" class="step">
            <h2 class="step__title">Detalles de entrega</h2>
            <p class="step__subtitle">¿Dónde y cuándo lo necesitas?</p>

            <div class="step__field">
              <label class="field__label">
                <MapPin :size="16" />
                Lugar de entrega
              </label>
              <input
                v-model="form.lugar_entrega"
                class="field__input"
                placeholder="Dirección o punto de entrega"
                required
              />
            </div>

            <div class="step__field">
              <label class="field__label">
                <Calendar :size="16" />
                Fecha y hora de entrega
              </label>
              <input
                v-model="form.fecha_entrega"
                class="field__input"
                type="datetime-local"
                required
              />
            </div>

            <div v-if="!selectedSize" class="step__field">
              <label class="field__label">
                <DollarSign :size="16" />
                Precio estimado (MXN)
              </label>
              <input
                v-model="form.total_venta"
                class="field__input"
                type="number"
                placeholder="0.00"
                required
              />
            </div>

            <!-- Payment method -->
            <div class="step__field">
              <label class="field__label">
                <DollarSign :size="16" />
                Método de pago
              </label>
              <div class="payment-methods">
                <button
                  v-for="method in metodosPago"
                  :key="method.value"
                  type="button"
                  class="payment-card"
                  :class="{ 'payment-card--selected': form.metodo_pago === method.value }"
                  @click="selectMetodoPago(method.value)"
                >
                  <component :is="method.icon" :size="22" />
                  <span class="payment-card__name">{{ method.label }}</span>
                  <span class="payment-card__desc">{{ method.description }}</span>
                </button>
              </div>
            </div>

            <!-- Transferencia: subir comprobante -->
            <div v-if="form.metodo_pago === 'transferencia'" class="step__field">
              <label class="field__label">
                <Upload :size="16" />
                Comprobante de transferencia
              </label>
              <label class="upload">
                <input
                  type="file"
                  accept="image/*,application/pdf"
                  class="upload__input"
                  @change="handleComprobanteChange"
                />
                <template v-if="!comprobanteFile">
                  <Upload :size="22" />
                  <span class="upload__text">Toca para subir imagen o PDF</span>
                </template>
                <template v-else>
                  <img
                    v-if="comprobantePreview"
                    :src="comprobantePreview"
                    alt="Comprobante"
                    class="upload__preview"
                  />
                  <FileCheck v-else :size="22" />
                  <span class="upload__text">{{ comprobanteFile.name }}</span>
                  <span class="upload__hint">Toca para cambiar</span>
                </template>
              </label>
            </div>

            <!-- Tarjeta: nota -->
            <div v-if="form.metodo_pago === 'tarjeta'" class="payment-note">
              <CreditCard :size="18" />
              <span>Te enviaremos un link de Mercado Pago por WhatsApp para completar el pago.</span>
            </div>

            <!-- Order preview -->
            <div class="preview">
              <h3 class="preview__title">Resumen de tu pedido</h3>
              <div class="preview__row">
                <span>Producto</span>
                <span>{{ form.producto || '—' }}</span>
              </div>
              <div v-if="selectedSize" class="preview__row">
                <span>Tamaño</span>
                <span>{{ selectedSize.nombre }}</span>
              </div>
              <div class="preview__row">
                <span>Cantidad</span>
                <span>{{ form.cantidad }}</span>
              </div>
              <div v-if="form.mensaje_pastel" class="preview__row">
                <span>Mensaje</span>
                <span>"{{ form.mensaje_pastel }}"</span>
              </div>
              <div class="preview__row">
                <span>Cliente</span>
                <span>{{ form.cliente || '—' }}</span>
              </div>
              <div v-if="form.metodo_pago" class="preview__row">
                <span>Método de pago</span>
                <span>{{ metodosPago.find(m => m.value === form.metodo_pago)?.label }}</span>
              </div>
              <div class="preview__row preview__row--total">
                <span>Total</span>
                <span>{{ form.total_venta ? `$${(Number(form.total_venta) * form.cantidad).toFixed(2)}` : '—' }}</span>
              </div>
            </div>
          </div>

          <p v-if="error" class="form-error">{{ error }}</p>

          <!-- Navigation buttons -->
          <div class="nav-buttons">
            <BaseButton
              v-if="currentStep > 1"
              variant="ghost"
              size="lg"
              @click="prevStep"
            >
              Anterior
            </BaseButton>
            <div v-else />

            <BaseButton
              v-if="currentStep < 3"
              variant="primary"
              size="lg"
              :disabled="!canGoNext()"
              @click="nextStep"
            >
              Siguiente
            </BaseButton>

            <BaseButton
              v-else
              variant="primary"
              size="lg"
              :loading="saving"
              :disabled="!canGoNext()"
            >
              Enviar pedido
            </BaseButton>
          </div>
        </form>
      </div>

      <!-- Footer -->
      <footer class="footer">
        <p>&copy; {{ new Date().getFullYear() }} Rosy's Cake &middot; Hecho con amor</p>
      </footer>
    </div>
  </div>
</template>

<style scoped>
.page {
  min-height: 100vh;
  background: #fffbfc;
  position: relative;
  overflow: hidden;
}

/* Decorative blobs */
.page__bg {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 0;
}

.page__blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.5;
}

.page__blob--1 {
  width: 400px;
  height: 400px;
  background: rgba(254, 194, 214, 0.4);
  top: -100px;
  right: -100px;
}

.page__blob--2 {
  width: 300px;
  height: 300px;
  background: rgba(254, 194, 214, 0.3);
  bottom: -50px;
  left: -80px;
}

.page__blob--3 {
  width: 200px;
  height: 200px;
  background: rgba(254, 230, 238, 0.5);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.page__container {
  position: relative;
  z-index: 1;
  max-width: 580px;
  margin: 0 auto;
  padding: var(--space-8) var(--space-4) var(--space-6);
}

/* Header */
.header {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  margin-bottom: var(--space-8);
}

.header__logo {
  width: 52px;
  height: 52px;
  background: var(--color-accent);
  color: var(--color-accent-text);
  border-radius: var(--radius-xl);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 4px 16px rgba(254, 194, 214, 0.5);
}

.header__title {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  line-height: 1.1;
}

.header__tagline {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  margin-top: 2px;
}

/* Progress */
.progress {
  margin-bottom: var(--space-8);
}

.progress__bar {
  height: 4px;
  background: var(--color-border-light);
  border-radius: var(--radius-full);
  overflow: hidden;
  margin-bottom: var(--space-4);
}

.progress__fill {
  height: 100%;
  background: var(--color-accent);
  border-radius: var(--radius-full);
  transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.progress__steps {
  display: flex;
  justify-content: center;
  gap: var(--space-3);
  margin-bottom: var(--space-2);
}

.progress__step {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
  border: 2px solid var(--color-border);
  color: var(--color-text-muted);
  background: var(--color-bg);
  transition: all var(--transition-normal);
}

.progress__step--active {
  border-color: var(--color-accent);
  background: var(--color-accent);
  color: var(--color-accent-text);
  transform: scale(1.1);
}

.progress__step--done {
  border-color: var(--color-accent);
  background: var(--color-accent-light);
  color: var(--color-accent-text);
  cursor: pointer;
}

.progress__label {
  text-align: center;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
}

/* Form wrapper */
.form-wrapper {
  background: var(--color-bg);
  border-radius: var(--radius-xl);
  box-shadow: 0 4px 24px rgba(59, 24, 21, 0.06), 0 1px 4px rgba(59, 24, 21, 0.04);
  padding: var(--space-8);
  border: 1px solid rgba(254, 194, 214, 0.2);
}

/* Steps */
.step__title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--space-1);
}

.step__subtitle {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  margin-bottom: var(--space-6);
}

.step__field {
  margin-top: var(--space-5);
}

/* Field styles */
.field__label {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
  margin-bottom: var(--space-2);
}

.field__optional {
  font-size: var(--font-size-xs);
  color: var(--color-gray-subtle);
  font-weight: var(--font-weight-normal);
}

.field__input {
  width: 100%;
  height: 44px;
  padding: 0 var(--space-4);
  background: var(--color-bg-secondary);
  border: 1.5px solid transparent;
  border-radius: var(--radius-lg);
  font-size: var(--font-size-sm);
  font-family: var(--font-sans);
  color: var(--color-text);
  transition: all var(--transition-fast);
}

.field__input::placeholder {
  color: var(--color-gray-subtle);
}

.field__input:focus {
  outline: none;
  background: var(--color-bg);
  border-color: var(--color-accent);
  box-shadow: 0 0 0 4px rgba(254, 194, 214, 0.2);
}

/* Product cards */
.products {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: var(--space-3);
}

.product-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-4) var(--space-3);
  background: var(--color-bg-secondary);
  border: 2px solid transparent;
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: all var(--transition-fast);
  text-align: center;
}

.product-card:hover {
  background: var(--color-bg);
  border-color: var(--color-border);
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.product-card--selected {
  background: var(--color-accent-light);
  border-color: var(--color-accent);
}

.product-card--selected:hover {
  background: var(--color-accent-light);
  border-color: var(--color-accent-hover);
}

.product-card__emoji {
  font-size: 2rem;
  line-height: 1;
}

.product-card__name {
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
}

.product-card__price {
  font-size: 10px;
  color: var(--color-text-muted);
}

/* Size cards */
.sizes {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.size-card {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  background: var(--color-bg-secondary);
  border: 2px solid transparent;
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: all var(--transition-fast);
  text-align: left;
}

.size-card:hover {
  border-color: var(--color-border);
  background: var(--color-bg);
}

.size-card--selected {
  border-color: var(--color-accent);
  background: var(--color-accent-light);
}

.size-card__name {
  flex: 1;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
}

.size-card__price {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-bold);
  color: var(--color-accent-text);
}

.size-card__desc {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}

.step__loading {
  text-align: center;
  padding: var(--space-8);
  color: var(--color-text-muted);
  font-size: var(--font-size-sm);
}

/* Quantity selector */
.quantity {
  display: inline-flex;
  align-items: center;
  gap: 0;
  background: var(--color-bg-secondary);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.quantity__btn {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  transition: background var(--transition-fast);
}

.quantity__btn:hover {
  background: var(--color-accent-light);
}

.quantity__value {
  width: 48px;
  text-align: center;
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
}

/* Payment methods */
.payment-methods {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--space-2);
}

.payment-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  gap: var(--space-1);
  padding: var(--space-3) var(--space-2);
  background: var(--color-bg-secondary);
  border: 2px solid transparent;
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: all var(--transition-fast);
  text-align: center;
  color: var(--color-text);
}

.payment-card:hover {
  border-color: var(--color-border);
  background: var(--color-bg);
}

.payment-card--selected {
  border-color: var(--color-accent);
  background: var(--color-accent-light);
}

.payment-card__name {
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-semibold);
  margin-top: var(--space-1);
}

.payment-card__desc {
  font-size: 10px;
  color: var(--color-text-muted);
  line-height: 1.2;
}

/* Upload */
.upload {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  padding: var(--space-5);
  background: var(--color-bg-secondary);
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: all var(--transition-fast);
  color: var(--color-text);
}

.upload:hover {
  border-color: var(--color-accent);
  background: var(--color-bg);
}

.upload__input {
  display: none;
}

.upload__text {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  word-break: break-all;
  text-align: center;
}

.upload__hint {
  font-size: var(--font-size-xs);
  color: var(--color-text-muted);
}

.upload__preview {
  max-width: 100%;
  max-height: 180px;
  border-radius: var(--radius-md);
  object-fit: contain;
}

/* Payment note */
.payment-note {
  display: flex;
  align-items: flex-start;
  gap: var(--space-2);
  margin-top: var(--space-4);
  padding: var(--space-3) var(--space-4);
  background: var(--color-accent-light);
  border-radius: var(--radius-lg);
  font-size: var(--font-size-sm);
  color: var(--color-text);
  line-height: 1.5;
}

/* Preview */
.preview {
  margin-top: var(--space-6);
  padding: var(--space-4);
  background: var(--color-bg-secondary);
  border-radius: var(--radius-lg);
}

.preview__title {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--space-3);
}

.preview__row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-2) 0;
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  border-bottom: 1px solid var(--color-border-light);
}

.preview__row:last-child {
  border-bottom: none;
}

.preview__row span:last-child {
  color: var(--color-text);
  font-weight: var(--font-weight-medium);
}

.preview__row--total {
  margin-top: var(--space-2);
  padding-top: var(--space-3);
  border-top: 2px solid var(--color-border);
  border-bottom: none;
}

.preview__row--total span:last-child {
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-bold);
  color: var(--color-accent-text);
}

/* Navigation */
.nav-buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: var(--space-8);
  padding-top: var(--space-5);
  border-top: 1px solid var(--color-border-light);
}

.form-error {
  margin-top: var(--space-4);
  font-size: var(--font-size-sm);
  color: #dc2626;
  text-align: center;
  padding: var(--space-3);
  background: #fee2e2;
  border-radius: var(--radius-md);
}

/* Success */
.success__card {
  background: var(--color-bg);
  border-radius: var(--radius-xl);
  box-shadow: 0 4px 24px rgba(59, 24, 21, 0.06);
  padding: var(--space-10);
  text-align: center;
  border: 1px solid rgba(254, 194, 214, 0.2);
}

.success__icon-wrapper {
  margin-bottom: var(--space-5);
}

.success__icon {
  width: 72px;
  height: 72px;
  background: var(--color-status-listo-bg);
  color: var(--color-status-listo);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  animation: pop 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.success__title {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--space-2);
}

.success__text {
  color: var(--color-text-muted);
  line-height: 1.6;
  margin-bottom: var(--space-6);
}

.success__summary {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
  margin-bottom: var(--space-6);
  text-align: left;
}

.success__row {
  display: flex;
  justify-content: space-between;
  padding: var(--space-2) 0;
  font-size: var(--font-size-sm);
}

.success__row span:first-child {
  color: var(--color-text-muted);
}

/* Footer */
.footer {
  text-align: center;
  margin-top: var(--space-8);
  font-size: var(--font-size-xs);
  color: var(--color-gray-subtle);
}

@keyframes pop {
  0% { transform: scale(0.5); opacity: 0; }
  70% { transform: scale(1.1); }
  100% { transform: scale(1); opacity: 1; }
}

@media (max-width: 480px) {
  .page__container {
    padding: var(--space-5) var(--space-3) var(--space-4);
  }

  .form-wrapper {
    padding: var(--space-5);
  }

  .products {
    grid-template-columns: repeat(2, 1fr);
  }

  .payment-methods {
    grid-template-columns: 1fr;
  }

  .success__card {
    padding: var(--space-6);
  }
}
</style>
