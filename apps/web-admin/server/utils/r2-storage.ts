import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'

// Configuración de cliente para Cloudflare R2 (API compatible con AWS S3)
// Variables de entorno requeridas:
// R2_ACCOUNT_ID: ID de la cuenta de Cloudflare
// R2_ACCESS_KEY_ID: Token R2 API Key ID
// R2_SECRET_ACCESS_KEY: Token R2 API Secret
// R2_BUCKET_NAME: Nombre del bucket (ej: 'inspecos-evidencias')
// R2_PUBLIC_DOMAIN: Opcional, dominio personalizado o r2.dev público (ej: 'https://cdn.inspecos.com')

export const getR2Client = () => {
  const accountId = process.env.R2_ACCOUNT_ID || 'mock-r2-account-id'
  const accessKeyId = process.env.R2_ACCESS_KEY_ID || 'mock-r2-access-key'
  const secretAccessKey = process.env.R2_SECRET_ACCESS_KEY || 'mock-r2-secret-key'

  return new S3Client({
    region: 'auto',
    endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId,
      secretAccessKey
    }
  })
}

export const getR2BucketName = () => {
  return process.env.R2_BUCKET_NAME || 'inspecos-evidencias'
}

/**
 * Genera una URL pre-firmada para subir evidencia fotográfica directamente desde la tablet/móvil
 * hacia Cloudflare R2 sin sobrecargar el servidor backend ni incurrir en costos de transferencia (Egress $0).
 */
export const createR2UploadPresignedUrl = async (key: string, contentType: string = 'image/jpeg', expiresInSeconds: number = 3600) => {
  const client = getR2Client()
  const bucket = getR2BucketName()

  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    ContentType: contentType
  })

  const uploadUrl = await getSignedUrl(client, command, { expiresIn: expiresInSeconds })
  return {
    uploadUrl,
    key,
    publicUrl: process.env.R2_PUBLIC_DOMAIN ? `${process.env.R2_PUBLIC_DOMAIN}/${key}` : null
  }
}

/**
 * Genera una URL de lectura temporal o CDN para visualizar fotografías en informes o portal.
 */
export const createR2DownloadPresignedUrl = async (key: string, expiresInSeconds: number = 7200) => {
  const client = getR2Client()
  const bucket = getR2BucketName()

  const command = new GetObjectCommand({
    Bucket: bucket,
    Key: key
  })

  return await getSignedUrl(client, command, { expiresIn: expiresInSeconds })
}

