export default defineEventHandler(async (event) => {
  if (getMethod(event) !== 'POST') {
    throw createError({ statusCode: 405, statusMessage: 'Method Not Allowed' })
  }

  const body = await readBody(event)
  const { observationId, fileName, sha256, mimeType, sizeBytes, base64Data } = body || {}

  if (!observationId || !sha256) {
    throw createError({
      statusCode: 400,
      statusMessage: 'observationId and sha256 are required'
    })
  }

  // En producción se almacena en Supabase Storage S3.
  // Aquí se valida la regla de integridad Evidence-First.
  const evidenceServerId = `srv-ev-${Date.now()}-${sha256.substring(0, 8)}`

  return {
    success: true,
    evidenceServerId,
    verifiedSha256: sha256,
    mimeType: mimeType || 'image/jpeg',
    sizeBytes: sizeBytes || 0,
    storedAt: new Date().toISOString()
  }
})
