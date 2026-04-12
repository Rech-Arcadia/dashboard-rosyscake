-- ============================================
-- Rosy's Cake - Métodos de pago + comprobantes
-- ============================================
-- Ejecuta este SQL en el SQL Editor de Supabase
-- (después de supabase-schema.sql)

-- 1. Nuevas columnas en orders
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS metodo_pago TEXT
    CHECK (metodo_pago IN ('efectivo','transferencia','tarjeta')),
  ADD COLUMN IF NOT EXISTS comprobante_url TEXT;

-- 2. Bucket de Storage para comprobantes de transferencia
--    Público para facilitar la visualización en el dashboard.
INSERT INTO storage.buckets (id, name, public)
VALUES ('comprobantes', 'comprobantes', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Políticas del bucket
--    - Usuarios anónimos pueden SUBIR (formulario público)
--    - Cualquiera puede LEER (bucket público)
--    - Solo autenticados pueden ELIMINAR

DROP POLICY IF EXISTS "comprobantes_anon_insert" ON storage.objects;
CREATE POLICY "comprobantes_anon_insert" ON storage.objects
  FOR INSERT
  WITH CHECK (bucket_id = 'comprobantes');

DROP POLICY IF EXISTS "comprobantes_public_read" ON storage.objects;
CREATE POLICY "comprobantes_public_read" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'comprobantes');

DROP POLICY IF EXISTS "comprobantes_auth_delete" ON storage.objects;
CREATE POLICY "comprobantes_auth_delete" ON storage.objects
  FOR DELETE
  USING (bucket_id = 'comprobantes' AND auth.role() = 'authenticated');
