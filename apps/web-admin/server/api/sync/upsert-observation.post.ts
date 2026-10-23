// Almacén en memoria para registro de operaciones e idempotencia en dev/testing
const processedOperations = new Map<string, any>()

export default defineEventHandler(async (event) => {
  if (getMethod(event) !== 'POST') {
    throw createError({ statusCode: 405, statusMessage: 'Method Not Allowed' })
  }

  const body = await readBody(event)
  const { idempotencyKey, observation, evidenceServerIds, clientVersion } = body || {}

  if (!idempotencyKey || !observation) {
    throw createError({
      statusCode: 400,
      statusMessage: 'idempotencyKey and observation payload are required'
    })
  }

  // Comprobar idempotencia: si ya fue procesada, retornar el resultado previo sin duplicar
  if (processedOperations.has(idempotencyKey)) {
    const existing = processedOperations.get(idempotencyKey)
    return {
      success: true,
      wasDuplicate: true,
      observationId: existing.observationId,
      serverVersion: existing.serverVersion,
      status: 'SYNCED',
      processedAt: existing.processedAt
    }
  }

  // Regla Evidence-First: verificar que si la observación requiere evidencia, exista el server ID
  if (observation.hasEvidence && (!evidenceServerIds || evidenceServerIds.length === 0)) {
    throw createError({
      statusCode: 422,
      statusMessage: 'Evidence-First rule violation: Evidence must be confirmed in Storage before syncing observation'
    })
  }

  const result = {
    observationId: observation.id || `obs-srv-${Date.now()}`,
    serverVersion: (clientVersion || 1) + 1,
    processedAt: new Date().toISOString()
  }

  processedOperations.set(idempotencyKey, result)

  return {
    success: true,
    wasDuplicate: false,
    observationId: result.observationId,
    serverVersion: result.serverVersion,
    status: 'SYNCED',
    processedAt: result.processedAt
  }
})
