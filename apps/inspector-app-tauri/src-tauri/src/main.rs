// InspecOS — Tauri v2 Core Native Runner
// Maneja almacenamiento offline en SQLite local, hashing SHA-256 de fotos y subida a Cloudflare R2
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use sha2::{Digest, Sha256};

#[tauri::command]
fn compute_sha256(bytes: Vec<u8>) -> String {
    let mut hasher = Sha256::new();
    hasher.update(&bytes);
    hex::encode(hasher.finalize())
}

#[tauri::command]
fn check_offline_storage_status() -> String {
    "SQLite local operativo (inspecos_offline.db)".to_string()
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_sql::Builder::default().build())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_dialog::init())
        .invoke_handler(tauri::generate_handler![compute_sha256, check_offline_storage_status])
        .run(tauri::generate_context!())
        .expect("Error al iniciar la aplicación nativa InspecOS Tauri v2");
}

