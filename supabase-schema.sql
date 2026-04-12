-- ============================================
-- Rosy's Cake Dashboard - Supabase Schema
-- ============================================
-- Ejecuta este SQL en el SQL Editor de tu proyecto Supabase
-- (https://supabase.com/dashboard -> SQL Editor)

-- 1. Tabla de pedidos
CREATE TABLE orders (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at    TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at    TIMESTAMPTZ DEFAULT now() NOT NULL,

  -- Info del cliente
  cliente       TEXT NOT NULL,
  telefono      TEXT,

  -- Detalles del pedido
  producto      TEXT NOT NULL,
  cantidad      INTEGER NOT NULL DEFAULT 1,
  mensaje_pastel TEXT,
  total_venta   NUMERIC(10,2) NOT NULL,

  -- Entrega
  lugar_entrega TEXT NOT NULL,
  fecha_entrega TIMESTAMPTZ NOT NULL,

  -- Estado
  estado        TEXT NOT NULL DEFAULT 'pendiente'
                CHECK (estado IN ('pendiente','en_proceso','listo','entregado')),

  -- Origen del pedido
  origen        TEXT NOT NULL DEFAULT 'dashboard'
                CHECK (origen IN ('dashboard','formulario_publico'))
);

-- 2. Índices para consultas rápidas
CREATE INDEX idx_orders_fecha_entrega ON orders (fecha_entrega);
CREATE INDEX idx_orders_estado ON orders (estado);
CREATE INDEX idx_orders_created_at ON orders (created_at);

-- 3. Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- 4. Row Level Security (RLS)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Usuarios autenticados: acceso completo
CREATE POLICY "auth_full_access" ON orders
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Usuarios anónimos: solo pueden insertar (formulario público)
CREATE POLICY "anon_insert" ON orders
  FOR INSERT
  WITH CHECK (auth.role() = 'anon');

-- 5. Función RPC para agregación de ingresos
CREATE OR REPLACE FUNCTION revenue_by_period(
  period TEXT,
  start_date DATE,
  end_date DATE
)
RETURNS TABLE(period_label TEXT, total NUMERIC, order_count BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT
    CASE period
      WHEN 'daily'   THEN to_char(fecha_entrega, 'YYYY-MM-DD')
      WHEN 'weekly'  THEN to_char(date_trunc('week', fecha_entrega), 'YYYY-MM-DD')
      WHEN 'monthly' THEN to_char(fecha_entrega, 'YYYY-MM')
    END AS period_label,
    SUM(total_venta) AS total,
    COUNT(*) AS order_count
  FROM orders
  WHERE fecha_entrega >= start_date
    AND fecha_entrega <= end_date
    AND estado != 'pendiente'
  GROUP BY 1
  ORDER BY 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
