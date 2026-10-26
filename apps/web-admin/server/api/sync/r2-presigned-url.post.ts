import { createR2UploadPresignedUrl } from '../../utils/r2-storage'

export default defineEventHandler(async (event) => {
  if (getMethod(event) !== 'POST') {
    throw createError({ statusCode: 405, statusMessage: 'Method Not Allowed' })
  }

  const body = await readBody(event)
  const { fileName, contentType, inspectionId, sha256 } = body || {}

  if (!fileName || !inspectionId) {
    throw createError({
      statusCode: 400,
      statusMessage: 'fileName and inspectionId are required'
    })
  }

  // Estructura de almacenamiento por unidad / inspección para organización limpia
  const timestamp = Date.now()
  const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_')
  const storageKey = `inspections/${inspectionId}/evidence/${timestamp}-${sanitizedFileName}`

  try {
    const { uploadUrl, key, publicUrl } = await createR2UploadPresignedUrl(
      storageKey,
      contentType || 'image/jpeg',
      3600 // 1 hora de validez
    )

    return {
      success: true,
      storageKey: key,
      uploadUrl,
      publicUrl,
      sha256VerificationRequired: !!sha256
    }
  } catch (error: any) {
    return {
      success: false,
      message: 'No se pudo generar la URL de subida a Cloudflare R2',
      error: error?.message
    }
  }
})
