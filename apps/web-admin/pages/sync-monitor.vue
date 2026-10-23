<template>
  <div class="sync-monitor-page">
    <header class="page-header">
      <div>
        <h1>Monitor del Motor de Sincronización (Fase 3)</h1>
        <p class="subtitle">Supervisión de cola Outbox, integridad de fotos por SHA-256 y detección de conflictos concurrentes</p>
      </div>
      <div class="header-actions">
        <button class="btn-primary" @click="simulateSyncEngineProcess">▶ Ejecutar Ciclo de Sincronización</button>
      </div>
    </header>

    <!-- Métricas del Motor -->
    <div class="sync-stats-grid">
      <div class="sync-card">
        <span class="icon">📥</span>
        <h3>Cola Outbox</h3>
        <p class="value">{{ queue.length }}</p>
        <span class="hint">Operaciones pendientes</span>
      </div>
      <div class="sync-card accent-green">
        <span class="icon">✅</span>
        <h3>Sincronizados (ACK)</h3>
        <p class="value">{{ syncedCount }}</p>
        <span class="hint">Verificados con SHA-256</span>
      </div>
      <div class="sync-card accent-orange">
        <span class="icon">⚠️</span>
        <h3>Conflictos Detectados</h3>
        <p class="value">{{ conflictsCount }}</p>
        <span class="hint">Sin sobrescritura silenciosa</span>
      </div>
      <div class="sync-card">
        <span class="icon">🔄</span>
        <h3>Estado de Conectividad</h3>
        <p class="value status-online">ONLINE</p>
        <span class="hint">Supabase Storage / Postgres</span>
      </div>
    </div>

    <!-- Regla de Arquitectura: Integridad y Orden de Evidencia -->
    <div class="pipeline-banner">
      <div class="pipeline-step active">
        <span class="step-num">1</span>
        <div>
          <h4>Captura Local</h4>
          <p>SQLite + Hash Inmutable</p>
        </div>
      </div>
      <div class="pipeline-arrow">➔</div>
      <div class="pipeline-step active">
        <span class="step-num">2</span>
        <div>
          <h4>Cola Outbox</h4>
          <p>Priorización de Evidencias</p>
        </div>
      </div>
      <div class="pipeline-arrow">➔</div>
      <div class="pipeline-step active">
        <span class="step-num">3</span>
        <div>
          <h4>Upload Binario</h4>
          <p>Validación SHA-256 Storage</p>
        </div>
      </div>
      <div class="pipeline-arrow">➔</div>
      <div class="pipeline-step active">
        <span class="step-num">4</span>
        <div>
          <h4>Upsert Observación</h4>
          <p>ACK e Idempotencia</p>
        </div>
      </div>
    </div>

    <!-- Tabla de la Cola Outbox -->
    <div class="table-card">
      <div class="card-header">
        <h3>Lote Activo de Sincronización (Prioridad Evidencia-First)</h3>
        <span class="badge-tag">Flujo Bidireccional</span>
      </div>

      <div class="table-responsive">
        <table class="data-table">
          <thead>
            <tr>
              <th>Orden</th>
              <th>Entidad</th>
              <th>Operación</th>
              <th>Firma Hash / SHA-256</th>
              <th>Estado Outbox</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, idx) in queue" :key="item.id" class="table-row">
              <td>#{{ idx + 1 }}</td>
              <td>
                <span class="entity-pill" :class="`entity-${item.type}`">
                  {{ item.type === 'evidence' ? '📸 FOTO (Evidencia)' : '📝 Observación' }}
                </span>
                <span class="entity-title">{{ item.title }}</span>
              </td>
              <td><code>{{ item.operation }}</code></td>
              <td>
                <code class="hash-code">{{ item.hash.substring(0, 16) }}...</code>
              </td>
              <td>
                <span class="status-badge" :class="`badge-${item.status.toLowerCase()}`">
                  {{ item.status }}
                </span>
              </td>
              <td>
                <button
                  v-if="item.status === 'OUTBOX'"
                  class="btn-sync-single"
                  @click="syncSingle(item)"
                >
                  Subir Ahora
                </button>
                <span v-else class="ack-done">✔ ACK</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
interface OutboxItem {
  id: string
  type: 'evidence' | 'observation'
  title: string
  operation: string
  hash: string
  status: 'OUTBOX' | 'UPLOADING' | 'SYNCED' | 'CONFLICT'
}

const queue = ref<OutboxItem[]>([
  {
    id: 'outbox-1',
    type: 'evidence',
    title: 'Foto: Fisura muro norte Sala',
    operation: 'UPLOAD_STORAGE',
    hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    status: 'OUTBOX'
  },
  {
    id: 'outbox-2',
    type: 'evidence',
    title: 'Foto: Detalle tina sin silicona',
    operation: 'UPLOAD_STORAGE',
    hash: 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb',
    status: 'OUTBOX'
  },
  {
    id: 'outbox-3',
    type: 'observation',
    title: 'Fisura en tabique de drywall',
    operation: 'UPSERT_RECORD',
    hash: '9f83c605cad048b0e69252baac44e0413756b2a270741444ec4e363161f5ac52',
    status: 'OUTBOX'
  },
  {
    id: 'outbox-4',
    type: 'observation',
    title: 'Ausencia de sellador sanitario',
    operation: 'UPSERT_RECORD',
    hash: 'd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35',
    status: 'OUTBOX'
  }
])

const syncedCount = computed(() => queue.value.filter(q => q.status === 'SYNCED').length)
const conflictsCount = computed(() => queue.value.filter(q => q.status === 'CONFLICT').length)

const syncSingle = (item: OutboxItem) => {
  item.status = 'UPLOADING'
  setTimeout(() => {
    item.status = 'SYNCED'
  }, 600)
}

const simulateSyncEngineProcess = () => {
  queue.value.forEach((item, idx) => {
    setTimeout(() => {
      item.status = 'UPLOADING'
      setTimeout(() => {
        item.status = 'SYNCED'
      }, 500)
    }, idx * 400)
  })
}
</script>

<style scoped>
.sync-monitor-page {
  padding-bottom: 40px;
}
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 2rem;
  margin: 0 0 6px 0;
}
.subtitle {
  color: var(--text-secondary);
  margin: 0;
}

.sync-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}
.sync-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 16px;
  padding: 24px;
  border-left: 4px solid var(--primary);
}
.sync-card.accent-green { border-left-color: #03dac6; }
.sync-card.accent-orange { border-left-color: #ffc107; }
.sync-card .icon { font-size: 1.5rem; display: block; margin-bottom: 8px; }
.sync-card h3 {
  color: var(--text-secondary);
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin: 0 0 6px 0;
}
.sync-card .value {
  font-size: 2.2rem;
  font-weight: bold;
  margin: 0 0 4px 0;
}
.status-online { color: #03dac6; font-size: 1.6rem !important; }
.sync-card .hint { font-size: 0.75rem; color: var(--text-secondary); }

/* Pipeline Banner */
.pipeline-banner {
  background: #151515;
  border: 1px solid var(--border-color);
  border-radius: 16px;
  padding: 20px 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.pipeline-step {
  display: flex;
  align-items: center;
  gap: 12px;
}
.step-num {
  background: var(--primary);
  color: #fff;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
}
.pipeline-step h4 { margin: 0 0 2px 0; font-size: 0.95rem; }
.pipeline-step p { margin: 0; font-size: 0.75rem; color: var(--text-secondary); }
.pipeline-arrow { color: #555; font-size: 1.2rem; }

/* Table */
.table-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 16px;
  overflow: hidden;
}
.card-header {
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid var(--border-color);
}
.card-header h3 { margin: 0; font-size: 1.1rem; }
.badge-tag {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  font-size: 0.75rem;
  padding: 4px 10px;
  border-radius: 20px;
  font-weight: bold;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
}
.data-table th {
  text-align: left;
  padding: 14px 20px;
  color: var(--text-secondary);
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  border-bottom: 1px solid var(--border-color);
}
.data-table td {
  padding: 14px 20px;
  border-bottom: 1px solid rgba(255,255,255,0.04);
  font-size: 0.9rem;
}
.entity-pill {
  font-size: 0.72rem;
  padding: 3px 8px;
  border-radius: 6px;
  font-weight: bold;
  margin-right: 8px;
}
.entity-evidence { background: rgba(3, 218, 198, 0.15); color: #03dac6; }
.entity-observation { background: rgba(26, 115, 232, 0.15); color: #4d9eff; }
.entity-title { font-weight: 500; }
.hash-code {
  color: #a0a0a0;
  font-size: 0.8rem;
  background: rgba(0,0,0,0.3);
  padding: 2px 6px;
  border-radius: 4px;
}
.status-badge {
  font-size: 0.72rem;
  font-weight: bold;
  padding: 3px 10px;
  border-radius: 12px;
}
.badge-outbox { background: rgba(255, 193, 7, 0.15); color: #ffc107; }
.badge-uploading { background: rgba(26, 115, 232, 0.15); color: #4d9eff; }
.badge-synced { background: rgba(3, 218, 198, 0.15); color: #03dac6; }
.badge-conflict { background: rgba(207, 102, 121, 0.15); color: var(--error); }
.btn-sync-single {
  background: rgba(26, 115, 232, 0.2);
  border: 1px solid var(--primary);
  color: #fff;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.75rem;
  cursor: pointer;
}
.btn-sync-single:hover { background: var(--primary); }
.ack-done { color: #03dac6; font-size: 0.8rem; font-weight: bold; }
</style>
