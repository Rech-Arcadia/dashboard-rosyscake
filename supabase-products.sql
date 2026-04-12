-- ============================================
-- Rosy's Cake - Productos y Tamaños
-- ============================================
-- Ejecuta este SQL en el SQL Editor de tu proyecto Supabase
-- DESPUÉS de haber ejecutado supabase-schema.sql

-- 1. Tabla de productos
CREATE TABLE products (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at  TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at  TIMESTAMPTZ DEFAULT now() NOT NULL,
  nombre      TEXT NOT NULL,
  descripcion TEXT,
  emoji       TEXT DEFAULT '🎂',
  categoria   TEXT NOT NULL DEFAULT 'pasteles'
              CHECK (categoria IN ('pasteles','cupcakes','galletas','pan','otros')),
  activo      BOOLEAN DEFAULT true NOT NULL,
  orden       INTEGER DEFAULT 0 NOT NULL
);

-- 2. Tabla de tamaños por producto (cada producto puede tener varios tamaños con precio)
CREATE TABLE product_sizes (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id  UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  nombre      TEXT NOT NULL,
  precio      NUMERIC(10,2) NOT NULL,
  descripcion TEXT,
  activo      BOOLEAN DEFAULT true NOT NULL,
  orden       INTEGER DEFAULT 0 NOT NULL
);

-- 3. Índices
CREATE INDEX idx_products_activo ON products (activo);
CREATE INDEX idx_products_categoria ON products (categoria);
CREATE INDEX idx_products_orden ON products (orden);
CREATE INDEX idx_product_sizes_product_id ON product_sizes (product_id);
CREATE INDEX idx_product_sizes_activo ON product_sizes (activo);

-- 4. Trigger updated_at para products
CREATE TRIGGER set_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- 5. RLS para products
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Usuarios autenticados: acceso completo
CREATE POLICY "auth_products_full" ON products
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Usuarios anónimos: solo lectura de productos activos (para el formulario público)
CREATE POLICY "anon_products_read" ON products
  FOR SELECT
  USING (auth.role() = 'anon' AND activo = true);

-- 6. RLS para product_sizes
ALTER TABLE product_sizes ENABLE ROW LEVEL SECURITY;

-- Usuarios autenticados: acceso completo
CREATE POLICY "auth_sizes_full" ON product_sizes
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Usuarios anónimos: solo lectura de tamaños activos
CREATE POLICY "anon_sizes_read" ON product_sizes
  FOR SELECT
  USING (auth.role() = 'anon' AND activo = true);

-- 7. Datos iniciales de ejemplo (opcional, puedes borrar esto)
INSERT INTO products (nombre, descripcion, emoji, categoria, orden) VALUES
  ('Pastel personalizado', 'Diseño a tu gusto con decoración personalizada', '🎨', 'pasteles', 1),
  ('Pastel de cumpleaños', 'Pastel clásico para celebrar tu día especial', '🎂', 'pasteles', 2),
  ('Pastel de boda', 'Elegante pastel para tu gran día', '💒', 'pasteles', 3),
  ('Cupcakes', 'Cupcakes decorados para cualquier ocasión', '🧁', 'cupcakes', 4),
  ('Galletas decoradas', 'Galletas artesanales con diseños personalizados', '🍪', 'galletas', 5),
  ('Pan artesanal', 'Pan fresco horneado diariamente', '🍞', 'pan', 6);

-- Tamaños de ejemplo para "Pastel personalizado"
INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Chico (10 personas)', 350.00, 'Ideal para reuniones pequeñas', 1
FROM products WHERE nombre = 'Pastel personalizado';

INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Mediano (20 personas)', 550.00, 'Perfecto para fiestas', 2
FROM products WHERE nombre = 'Pastel personalizado';

INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Grande (30 personas)', 800.00, 'Para grandes celebraciones', 3
FROM products WHERE nombre = 'Pastel personalizado';

-- Tamaños de ejemplo para "Pastel de cumpleaños"
INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Chico (10 personas)', 300.00, NULL, 1
FROM products WHERE nombre = 'Pastel de cumpleaños';

INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Mediano (20 personas)', 500.00, NULL, 2
FROM products WHERE nombre = 'Pastel de cumpleaños';

INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Grande (30 personas)', 750.00, NULL, 3
FROM products WHERE nombre = 'Pastel de cumpleaños';

-- Tamaños para Cupcakes (por docena)
INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Media docena', 180.00, '6 cupcakes', 1
FROM products WHERE nombre = 'Cupcakes';

INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Docena', 320.00, '12 cupcakes', 2
FROM products WHERE nombre = 'Cupcakes';

-- Tamaños para Galletas
INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Paquete 6 piezas', 120.00, NULL, 1
FROM products WHERE nombre = 'Galletas decoradas';

INSERT INTO product_sizes (product_id, nombre, precio, descripcion, orden)
SELECT id, 'Paquete 12 piezas', 200.00, NULL, 2
FROM products WHERE nombre = 'Galletas decoradas';
