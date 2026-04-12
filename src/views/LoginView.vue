<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Cake } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'
import BaseInput from '@/components/ui/BaseInput.vue'
import BaseButton from '@/components/ui/BaseButton.vue'

const router = useRouter()
const auth = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function handleLogin() {
  error.value = ''
  loading.value = true

  try {
    await auth.login(email.value, password.value)
    router.push('/dashboard')
  } catch (err) {
    error.value = 'Credenciales incorrectas. Intenta de nuevo.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login">
    <div class="login__card">
      <div class="login__brand">
        <div class="login__logo">
          <Cake :size="32" />
        </div>
        <h1 class="login__title">Rosy's Cake</h1>
        <p class="login__subtitle">Inicia sesión en tu dashboard</p>
      </div>

      <form class="login__form" @submit.prevent="handleLogin">
        <BaseInput
          v-model="email"
          label="Correo electrónico"
          type="email"
          placeholder="tu@email.com"
          required
        />

        <BaseInput
          v-model="password"
          label="Contraseña"
          type="password"
          placeholder="••••••••"
          required
        />

        <p v-if="error" class="login__error">{{ error }}</p>

        <BaseButton variant="primary" block :loading="loading" @click="handleLogin">
          Iniciar sesión
        </BaseButton>
      </form>
    </div>
  </div>
</template>

<style scoped>
.login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg-secondary);
  padding: var(--space-4);
}

.login__card {
  width: 100%;
  max-width: 400px;
  background: var(--color-bg);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-lg);
  padding: var(--space-10);
}

.login__brand {
  text-align: center;
  margin-bottom: var(--space-8);
}

.login__logo {
  width: 64px;
  height: 64px;
  background: var(--color-accent);
  color: var(--color-accent-text);
  border-radius: var(--radius-xl);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto var(--space-4);
}

.login__title {
  font-size: var(--font-size-2xl);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
}

.login__subtitle {
  font-size: var(--font-size-sm);
  color: var(--color-text-muted);
  margin-top: var(--space-1);
}

.login__form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.login__error {
  font-size: var(--font-size-sm);
  color: #dc2626;
  text-align: center;
  padding: var(--space-2) var(--space-3);
  background: #fee2e2;
  border-radius: var(--radius-md);
}
</style>
