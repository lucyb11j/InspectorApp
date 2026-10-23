<template>
  <div class="reports-index-page">
    <header class="page-header">
      <div>
        <h1>Informes y Actas Técnicas de Visita</h1>
        <p class="subtitle">Documentos formales generados con evidencia fotográfica y coordenadas de planos</p>
      </div>
    </header>

    <div class="reports-grid">
      <div v-for="report in reportsList" :key="report.id" class="report-summary-card">
        <div class="card-top">
          <span class="report-badge">{{ report.code }}</span>
          <span class="badge-status-completed">FIRMADA / LISTA</span>
        </div>

        <h3>{{ report.unit }} — {{ report.project }}</h3>
        <p class="meta-line">Cliente: <strong>{{ report.client }}</strong></p>
        <p class="meta-line">Inspector: <strong>{{ report.inspector }}</strong></p>
        <p class="meta-line">Fecha: {{ report.date }} · {{ report.obsCount }} observaciones</p>

        <div class="card-actions">
          <NuxtLink :to="`/reports/${report.id}`" class="btn-primary">
            Ver / Imprimir Acta PDF →
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const reportsList = [
  {
    id: '55555555-0000-0000-0000-000000000001',
    code: 'ACTA-2026-555555',
    unit: 'Unidad 305',
    project: 'Condominio Los Cedros - Torre B',
    client: 'Carlos Mendoza',
    inspector: 'Arq. Roberto Silva',
    date: '23 oct 2026',
    obsCount: 3
  },
  {
    id: '55555555-0000-0000-0000-000000000002',
    code: 'ACTA-2026-666666',
    unit: 'Unidad 201',
    project: 'Condominio Los Cedros - Torre A',
    client: 'María Torres',
    inspector: 'Ing. Javier Campos',
    date: '21 oct 2026',
    obsCount: 2
  }
]
</script>

<style scoped>
.page-header {
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 1.8rem;
  margin: 0 0 6px 0;
}
.subtitle {
  color: var(--text-secondary);
  margin: 0;
}
.reports-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
  gap: 16px;
}
.report-summary-card {
  background: var(--surface-dark);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  flex-direction: column;
}
.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.report-badge {
  background: rgba(26,115,232,0.15);
  color: #4d9eff;
  font-size: 0.75rem;
  padding: 3px 8px;
  border-radius: 4px;
  font-weight: bold;
}
.badge-status-completed {
  background: rgba(3, 218, 198, 0.15);
  color: #03dac6;
  font-size: 0.72rem;
  padding: 3px 8px;
  border-radius: 4px;
  font-weight: bold;
}
.report-summary-card h3 {
  margin: 0 0 8px 0;
  font-size: 1.1rem;
}
.meta-line {
  margin: 3px 0;
  font-size: 0.85rem;
  color: #aaa;
}
.card-actions {
  margin-top: 20px;
}
</style>

