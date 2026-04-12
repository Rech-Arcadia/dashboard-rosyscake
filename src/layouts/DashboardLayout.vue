<script setup>
import { ref } from 'vue'
import AppSidebar from '@/components/layout/AppSidebar.vue'
import AppTopbar from '@/components/layout/AppTopbar.vue'

const sidebarCollapsed = ref(true)

function toggleSidebar() {
  sidebarCollapsed.value = !sidebarCollapsed.value
}

function closeSidebar() {
  sidebarCollapsed.value = true
}
</script>

<template>
  <div class="layout">
    <AppSidebar :collapsed="sidebarCollapsed" @close="closeSidebar" />

    <div class="layout__overlay" :class="{ 'layout__overlay--visible': !sidebarCollapsed }" @click="closeSidebar" />

    <div class="layout__main">
      <AppTopbar @toggle-sidebar="toggleSidebar" />
      <main class="layout__content">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<style scoped>
.layout {
  display: flex;
  min-height: 100vh;
  max-width: 100vw;
  overflow-x: hidden;
}

.layout__main {
  flex: 1;
  margin-left: var(--sidebar-width);
  display: flex;
  flex-direction: column;
}

.layout__content {
  flex: 1;
  padding: var(--space-6);
  background: var(--color-bg-secondary);
}

.layout__overlay {
  display: none;
}

@media (max-width: 768px) {
  .layout__main {
    margin-left: 0;
    min-width: 0;
  }

  .layout__content {
    padding: var(--space-4) var(--space-3);
  }

  .layout__overlay {
    display: block;
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.4);
    z-index: 99;
    opacity: 0;
    pointer-events: none;
    transition: opacity var(--transition-normal);
  }

  .layout__overlay--visible {
    opacity: 1;
    pointer-events: auto;
  }
}
</style>
