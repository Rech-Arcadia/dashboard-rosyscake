import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { supabase } from '@/lib/supabase'

export const useProductsStore = defineStore('products', () => {
  const products = ref([])
  const loading = ref(false)

  const activeProducts = computed(() => {
    return products.value
      .filter((p) => p.activo)
      .sort((a, b) => a.orden - b.orden)
  })

  const categorias = [
    { value: 'pasteles', label: 'Pasteles' },
    { value: 'cupcakes', label: 'Cupcakes' },
    { value: 'galletas', label: 'Galletas' },
    { value: 'pan', label: 'Pan' },
    { value: 'otros', label: 'Otros' },
  ]

  async function fetchProducts() {
    loading.value = true
    const { data, error } = await supabase
      .from('products')
      .select('*, product_sizes(*)')
      .order('orden', { ascending: true })

    if (!error) {
      products.value = data.map((p) => ({
        ...p,
        product_sizes: (p.product_sizes || []).sort((a, b) => a.orden - b.orden),
      }))
    }
    loading.value = false
  }

  async function createProduct(productData) {
    const { sizes, ...product } = productData
    const { data, error } = await supabase
      .from('products')
      .insert([product])
      .select()
      .single()

    if (error) throw error

    if (sizes?.length) {
      const sizesWithProductId = sizes.map((s) => ({ ...s, product_id: data.id }))
      const { error: sizesError } = await supabase
        .from('product_sizes')
        .insert(sizesWithProductId)

      if (sizesError) throw sizesError
    }

    await fetchProducts()
    return data
  }

  async function updateProduct(id, productData) {
    const { sizes, product_sizes, ...product } = productData

    const { error } = await supabase
      .from('products')
      .update(product)
      .eq('id', id)

    if (error) throw error

    if (sizes) {
      // Delete existing sizes and re-insert
      await supabase.from('product_sizes').delete().eq('product_id', id)

      if (sizes.length) {
        const sizesWithProductId = sizes.map((s) => ({
          nombre: s.nombre,
          precio: s.precio,
          descripcion: s.descripcion || null,
          activo: s.activo ?? true,
          orden: s.orden ?? 0,
          product_id: id,
        }))
        const { error: sizesError } = await supabase
          .from('product_sizes')
          .insert(sizesWithProductId)

        if (sizesError) throw sizesError
      }
    }

    await fetchProducts()
  }

  async function deleteProduct(id) {
    const { error } = await supabase.from('products').delete().eq('id', id)
    if (error) throw error
    products.value = products.value.filter((p) => p.id !== id)
  }

  async function toggleActive(id, activo) {
    const { error } = await supabase
      .from('products')
      .update({ activo })
      .eq('id', id)

    if (error) throw error
    const product = products.value.find((p) => p.id === id)
    if (product) product.activo = activo
  }

  return {
    products,
    loading,
    activeProducts,
    categorias,
    fetchProducts,
    createProduct,
    updateProduct,
    deleteProduct,
    toggleActive,
  }
})
