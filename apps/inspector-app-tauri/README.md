# InspecOS — App de Inspección Técnica (Tauri v2)

Aplicación nativa para Tablets (Android / iPadOS) y PC para inspecciones de campo **100% offline-first**.

## Arquitectura de la Solución
1. **Frontend:** Vue 3 + TypeScript (mismo diseño y componentes que `mobile-preview.vue`).
2. **Almacenamiento Local:** SQLite nativo mediante `@tauri-apps/plugin-sql` y guardado de archivos con `@tauri-apps/plugin-fs`.
3. **Criptografía:** Cálculo nativo de hash **SHA-256** en Rust (`src-tauri/src/main.rs`).
4. **Almacenamiento en la Nube:** Fotografías y planos dirigidos a **Cloudflare R2** mediante URLs pre-firmadas (`$0.00 Egress`).
5. **Base de Datos Central:** **Supabase (PostgreSQL con RLS)** para autenticación, asignación de inspecciones y sincronización de observaciones estructuradas.

## Requisitos para Compilar
- **Node.js:** v20+ o v22+
- **Rust y Cargo:** `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Tauri CLI:** `pnpm add -D @tauri-apps/cli@^2.0.0`

## Comandos Principales
- Modo desarrollo (Desktop): `pnpm tauri dev`
- Modo desarrollo (Android tablet): `pnpm tauri android dev`
- Generar instalador APK (Android): `pnpm tauri android build`
- Generar instalador Desktop: `pnpm tauri build`
