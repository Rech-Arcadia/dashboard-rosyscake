<script setup>
import { ref, computed } from 'vue'
import {
  startOfMonth,
  endOfMonth,
  eachDayOfInterval,
  getDay,
  format,
  isSameDay,
  addMonths,
  subMonths,
  isToday,
  parseISO,
} from 'date-fns'
import { es } from 'date-fns/locale'
import { ChevronLeft, ChevronRight } from 'lucide-vue-next'
import { useOrdersStore } from '@/stores/orders'
import BaseCard from '@/components/ui/BaseCard.vue'

const ordersStore = useOrdersStore()
const currentMonth = ref(new Date())

const monthLabel = computed(() => {
  return format(currentMonth.value, 'MMMM yyyy', { locale: es })
})

const weekDays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']

const calendarDays = computed(() => {
  const start = startOfMonth(currentMonth.value)
  const end = endOfMonth(currentMonth.value)
  const days = eachDayOfInterval({ start, end })

  // Padding for the first week
  const firstDayOfWeek = getDay(start)
  const padding = Array.from({ length: firstDayOfWeek }, () => null)

  return [...padding, ...days]
})

function getOrdersForDay(day) {
  if (!day) return []
  return ordersStore.orders.filter((o) => {
    const fecha = typeof o.fecha_entrega === 'string' ? parseISO(o.fecha_entrega) : o.fecha_entrega
    return isSameDay(fecha, day)
  })
}

function prevMonth() {
  currentMonth.value = subMonths(currentMonth.value, 1)
}

function nextMonth() {
  currentMonth.value = addMonths(currentMonth.value, 1)
}
</script>

<template>
  <BaseCard>
    <div class="calendar">
      <div class="calendar__header">
        <h3 class="calendar__title">Calendario de Pedidos</h3>
        <div class="calendar__nav">
          <button class="calendar__nav-btn" @click="prevMonth">
            <ChevronLeft :size="18" />
          </button>
          <span class="calendar__month">{{ monthLabel }}</span>
          <button class="calendar__nav-btn" @click="nextMonth">
            <ChevronRight :size="18" />
          </button>
        </div>
      </div>

      <div class="calendar__grid">
        <div v-for="day in weekDays" :key="day" class="calendar__weekday">
          {{ day }}
        </div>

        <div
          v-for="(day, index) in calendarDays"
          :key="index"
          class="calendar__day"
          :class="{
            'calendar__day--empty': !day,
            'calendar__day--today': day && isToday(day),
            'calendar__day--has-orders': day && getOrdersForDay(day).length > 0,
          }"
        >
          <template v-if="day">
            <span class="calendar__day-number">{{ format(day, 'd') }}</span>
            <div v-if="getOrdersForDay(day).length" class="calendar__dots">
              <span
                v-for="(order, i) in getOrdersForDay(day).slice(0, 3)"
                :key="i"
                class="calendar__dot"
                :class="`calendar__dot--${order.estado}`"
              />
              <span v-if="getOrdersForDay(day).length > 3" class="calendar__more">
                +{{ getOrdersForDay(day).length - 3 }}
              </span>
            </div>
          </template>
        </div>
      </div>
    </div>
  </BaseCard>
</template>

<style scoped>
.calendar__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--space-5);
}

.calendar__title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
}

.calendar__nav {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.calendar__nav-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  color: var(--color-text-muted);
  transition: all var(--transition-fast);
}

.calendar__nav-btn:hover {
  background: var(--color-bg-secondary);
  color: var(--color-text);
}

.calendar__month {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  min-width: 130px;
  text-align: center;
  text-transform: capitalize;
}

.calendar__grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 1px;
}

.calendar__weekday {
  padding: var(--space-2);
  text-align: center;
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-muted);
}

.calendar__day {
  aspect-ratio: 1;
  padding: var(--space-1);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  border-radius: var(--radius-md);
  transition: background var(--transition-fast);
}

.calendar__day:not(.calendar__day--empty):hover {
  background: var(--color-bg-secondary);
}

.calendar__day--today {
  background: var(--color-accent-light) !important;
}

.calendar__day--today .calendar__day-number {
  background: var(--color-accent);
  color: var(--color-accent-text);
  border-radius: var(--radius-full);
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.calendar__day-number {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
}

.calendar__dots {
  display: flex;
  gap: 2px;
  align-items: center;
}

.calendar__dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.calendar__dot--pendiente { background: var(--color-status-pendiente); }
.calendar__dot--en_proceso { background: var(--color-status-en-proceso); }
.calendar__dot--listo { background: var(--color-status-listo); }
.calendar__dot--entregado { background: var(--color-status-entregado); }

.calendar__more {
  font-size: 9px;
  color: var(--color-text-muted);
}
</style>
