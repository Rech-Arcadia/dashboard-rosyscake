<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'
import gsap from 'gsap'
import { ClipboardList, ChefHat, PackageCheck, PartyPopper } from 'lucide-vue-next'

// Mascot assets — drop the 6 images in src/assets/mascot/ with these names.
// Swap paths freely once the real art lands.
import pendienteApuntar from '@/assets/mascot/pendiente-apuntar.png'
import pendienteLike from '@/assets/mascot/pendiente-like.png'
import procesoAmasar1 from '@/assets/mascot/proceso-amasar-1.png'
import procesoAmasar2 from '@/assets/mascot/proceso-amasar-2.png'
import listoGuardar from '@/assets/mascot/listo-guardar.png'
import entregadoGracias from '@/assets/mascot/entregado-gracias.png'

const props = defineProps({
  estado: { type: String, required: true },
})

const STATES = [
  { key: 'pendiente',  label: 'Pendiente',  icon: ClipboardList },
  { key: 'en_proceso', label: 'En proceso', icon: ChefHat },
  { key: 'listo',      label: 'Listo',      icon: PackageCheck },
  { key: 'entregado',  label: 'Entregado',  icon: PartyPopper },
]

const STATE_COPY = {
  pendiente: {
    title: 'Tu pedido está siendo revisado',
    text: 'Ya tomamos nota de tu pedido. Pronto lo confirmaremos por WhatsApp.',
  },
  en_proceso: {
    title: '¡Manos a la masa!',
    text: 'Estamos preparando tu pedido con mucho cariño.',
  },
  listo: {
    title: '¡Tu pedido está listo!',
    text: 'Ten en cuenta la hora de entrega acordada para recibirlo en el domicilio indicado.',
  },
  entregado: {
    title: '¡Gracias por tu preferencia!',
    text: 'Esperamos que lo disfrutes. ¡Gracias por elegir Rosy\'s Cake!',
  },
}

const currentIndex = computed(() => STATES.findIndex((s) => s.key === props.estado))

// Active mascot frame (swaps during the animation)
const mascotSrc = ref(pendienteApuntar)
const stageEl = ref(null)
const mascotEl = ref(null)
const textEl = ref(null)
let tl = null

function killTimeline() {
  if (tl) {
    tl.kill()
    tl = null
  }
}

async function playAnimation(estado) {
  killTimeline()
  await nextTick()
  if (!mascotEl.value) return

  gsap.set(mascotEl.value, { clearProps: 'all' })
  if (textEl.value) gsap.set(textEl.value, { clearProps: 'all' })

  tl = gsap.timeline()
  tl.from(textEl.value, { y: 16, opacity: 0, duration: 0.5, ease: 'power2.out' }, 0)

  if (estado === 'pendiente') {
    // Loop: apunta nota (cabeceo) → swap a like (escala + saltito) → vuelve a apuntar
    mascotSrc.value = pendienteApuntar
    tl.from(mascotEl.value, { y: 40, opacity: 0, duration: 0.6, ease: 'back.out(1.6)' }, 0)
    const loop = gsap.timeline({ repeat: -1, repeatDelay: 0.3 })
    loop
      .call(() => { mascotSrc.value = pendienteApuntar })
      .to(mascotEl.value, { rotation: -3, duration: 0.4, yoyo: true, repeat: 3, ease: 'sine.inOut' })
      .call(() => { mascotSrc.value = pendienteLike })
      .fromTo(mascotEl.value,
        { scale: 0.85 },
        { scale: 1, duration: 0.5, ease: 'back.out(2)' },
      )
      .to(mascotEl.value, { y: -10, duration: 0.4, yoyo: true, repeat: 1, ease: 'sine.inOut' })
      .to({}, { duration: 0.4 })
    tl.add(loop)
  } else if (estado === 'en_proceso') {
    // Amasando: alterna dos frames como sprite, en loop
    mascotSrc.value = procesoAmasar1
    tl.from(mascotEl.value, { scale: 0.8, opacity: 0, duration: 0.5, ease: 'back.out(1.6)' }, 0)
    const swap = () => {
      mascotSrc.value = mascotSrc.value === procesoAmasar1 ? procesoAmasar2 : procesoAmasar1
    }
    tl.to(mascotEl.value, {
      y: -6,
      duration: 0.28,
      repeat: -1,
      yoyo: true,
      ease: 'sine.inOut',
      onRepeat: swap,
    })
  } else if (estado === 'listo') {
    // Loop: cae con bounce → escala + balanceo continuo
    mascotSrc.value = listoGuardar
    tl.from(mascotEl.value, { y: -30, opacity: 0, duration: 0.6, ease: 'bounce.out' }, 0)
    const loop = gsap.timeline({ repeat: -1, repeatDelay: 0.2 })
    loop
      .to(mascotEl.value, { scale: 1.05, duration: 0.4, yoyo: true, repeat: 1, ease: 'sine.inOut' })
      .to(mascotEl.value, { rotation: 4, duration: 0.3, yoyo: true, repeat: 3, ease: 'sine.inOut' })
      .to(mascotEl.value, { rotation: 0, duration: 0.2, ease: 'sine.out' })
    tl.add(loop)
  } else if (estado === 'entregado') {
    // Aparece con elastic, luego flota en loop
    mascotSrc.value = entregadoGracias
    tl.from(mascotEl.value, { scale: 0, opacity: 0, duration: 0.8, ease: 'elastic.out(1, 0.6)' }, 0)
      .to(mascotEl.value, { y: -12, duration: 0.5, yoyo: true, repeat: -1, ease: 'sine.inOut' })
  }
}

watch(() => props.estado, (v) => playAnimation(v))
onMounted(() => playAnimation(props.estado))
onBeforeUnmount(killTimeline)
</script>

<template>
  <div class="tracker">
    <!-- Timeline -->
    <div class="tracker__steps">
      <div
        v-for="(s, i) in STATES"
        :key="s.key"
        class="tracker__step"
        :class="{
          'tracker__step--done': i < currentIndex,
          'tracker__step--active': i === currentIndex,
        }"
      >
        <div class="tracker__dot">
          <component :is="s.icon" :size="18" />
        </div>
        <span class="tracker__label">{{ s.label }}</span>
        <div v-if="i < STATES.length - 1" class="tracker__line" />
      </div>
    </div>

    <!-- Mascot stage -->
    <div ref="stageEl" class="tracker__stage">
      <img ref="mascotEl" :src="mascotSrc" alt="" class="tracker__mascot" />
      <div ref="textEl" class="tracker__copy">
        <h3 class="tracker__title">{{ STATE_COPY[estado]?.title }}</h3>
        <p class="tracker__text">{{ STATE_COPY[estado]?.text }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.tracker {
  display: flex;
  flex-direction: column;
  gap: var(--space-6, 1.5rem);
}

.tracker__steps {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0;
  position: relative;
}

.tracker__step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  position: relative;
  color: #b9a5a3;
}

.tracker__step--done {
  color: #3B1815;
}

.tracker__step--active {
  color: #3B1815;
}

.tracker__dot {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  background: #f5e9ec;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #f5e9ec;
  transition: background 0.3s, border-color 0.3s, transform 0.3s;
  z-index: 1;
}

.tracker__step--done .tracker__dot {
  background: #FEC2D6;
  border-color: #FEC2D6;
}

.tracker__step--active .tracker__dot {
  background: #fff;
  border-color: #FEC2D6;
  box-shadow: 0 0 0 6px rgba(254, 194, 214, 0.25);
  transform: scale(1.1);
}

.tracker__label {
  font-size: 0.78rem;
  font-weight: 600;
  text-align: center;
}

.tracker__line {
  position: absolute;
  top: 21px;
  left: 50%;
  width: 100%;
  height: 2px;
  background: #f5e9ec;
  z-index: 0;
}

.tracker__step--done .tracker__line {
  background: #FEC2D6;
}

.tracker__stage {
  background: linear-gradient(180deg, #fff7f9 0%, #ffffff 100%);
  border: 1px solid #fce4ec;
  border-radius: 20px;
  padding: 1.75rem 1.25rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  text-align: center;
  overflow: hidden;
}

.tracker__mascot {
  width: 180px;
  height: 180px;
  object-fit: contain;
  will-change: transform;
}

.tracker__title {
  font-size: 1.15rem;
  font-weight: 700;
  color: #3B1815;
  margin: 0 0 0.35rem;
}

.tracker__text {
  font-size: 0.92rem;
  color: #6b4f4d;
  margin: 0;
  max-width: 32ch;
  line-height: 1.5;
}

@media (max-width: 480px) {
  .tracker__mascot { width: 140px; height: 140px; }
  .tracker__label { font-size: 0.68rem; }
  .tracker__dot { width: 36px; height: 36px; }
  .tracker__line { top: 18px; }
}
</style>
