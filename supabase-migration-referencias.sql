-- ============================================
-- Migración: imágenes de referencia + seguimiento público
-- ============================================
-- Ejecuta este SQL en el SQL Editor de Supabase

-- 1. Columna para URL de la imagen de referencia del pastel
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS imagen_referencia_url TEXT;

-- 2. Política para que usuarios anónimos puedan leer un pedido por su UUID.
--    El UUID actúa como token de acceso: es imposible de adivinar, así que el
--    cliente solo puede ver su propio pedido si conserva el link.
CREATE POLICY "anon_select_by_id" ON orders
  FOR SELECT
  TO anon
  USING (true);

-- 3. Crear bucket público para imágenes de referencia.
--    Si prefieres hacerlo desde la UI de Supabase: Storage > New bucket
--    > nombre "referencias", marca "Public bucket".
INSERT INTO storage.buckets (id, name, public)
VALUES ('referencias', 'referencias', true)
ON CONFLICT (id) DO NOTHING;

-- 4. Políticas del bucket: anon puede subir y leer
CREATE POLICY "referencias_anon_insert"
  ON storage.objects FOR INSERT
  TO anon
  WITH CHECK (bucket_id = 'referencias');

CREATE POLICY "referencias_public_read"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'referencias');
