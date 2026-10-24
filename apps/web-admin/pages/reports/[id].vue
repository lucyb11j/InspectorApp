<template>
  <div class="report-page">
    <!-- Barra de Herramientas de Impresión / Exportación (No se imprime) -->
    <header class="report-toolbar no-print">
      <div class="toolbar-left">
        <NuxtLink to="/inspections" class="btn-back">← Volver a Inspecciones</NuxtLink>
        <span class="report-title-top">Acta de Visita Técnica #{{ inspectionId.substring(0, 8) }}</span>
      </div>
      <div class="toolbar-right">
        <button type="button" class="btn-print" @click="printReport">
          🖨️ Imprimir / Guardar como PDF
        </button>
      </div>
    </header>

    <!-- Documento Formal Imprimible -->
    <main class="report-sheet">
      <!-- Encabezado Formal -->
      <section class="report-header">
        <div class="header-logo-block">
          <div class="logo-mark">🏢</div>
          <div>
            <h1 class="company-name">INSPECOS</h1>
            <p class="company-tagline">Plataforma Profesional de Inspección Técnica Inmobiliaria</p>
          </div>
        </div>
        <div class="header-code-block">
          <span class="doc-badge">ACTA DE INSPECCIÓN TÉCNICA</span>
          <p class="doc-code">CÓDIGO: <strong>ACTA-2026-{{ inspectionId.substring(0, 6).toUpperCase() }}</strong></p>
          <p class="doc-date">Fecha de Emisión: <strong>{{ formattedDate }}</strong></p>
        </div>
      </section>

      <!-- Ficha de Datos del Inmueble y la Visita -->
      <section class="meta-section">
        <h2 class="section-title">1. DATOS GENERALES DE LA VISITA</h2>
        <table class="meta-table">
          <tbody>
            <tr>
              <th>Proyecto / Condominio:</th>
              <td>{{ reportData.project }}</td>
              <th>Unidad Inmobiliaria:</th>
              <td><strong>{{ reportData.unit }}</strong></td>
            </tr>
            <tr>
              <th>Edificio / Torre:</th>
              <td>{{ reportData.building }} (Piso {{ reportData.floor }})</td>
              <th>Cliente / Propietario:</th>
              <td>{{ reportData.client }}</td>
            </tr>
            <tr>
              <th>Inspector Responsable:</th>
              <td>{{ reportData.inspector }}</td>
              <th>Estado de Inspección:</th>
              <td><span class="status-pill">{{ reportData.status }}</span></td>
            </tr>
          </tbody>
        </table>
      </section>

      <!-- Resumen Cuantitativo de Defectos -->
      <section class="summary-section">
        <h2 class="section-title">2. RESUMEN DE NO-CONFORMIDADES REGISTRADAS</h2>
        <div class="kpi-boxes">
          <div class="kpi-box">
            <span class="kpi-num">{{ totalObservations }}</span>
            <span class="kpi-lbl">Total Observaciones</span>
          </div>
          <div class="kpi-box sev-box-menor">
            <span class="kpi-num">{{ countBySeverity('MENOR') }}</span>
            <span class="kpi-lbl">Menor</span>
          </div>
          <div class="kpi-box sev-box-mod">
            <span class="kpi-num">{{ countBySeverity('MODERADA') }}</span>
            <span class="kpi-lbl">Moderada</span>
          </div>
          <div class="kpi-box sev-box-may">
            <span class="kpi-num">{{ countBySeverity('MAYOR') }}</span>
            <span class="kpi-lbl">Mayor</span>
          </div>
          <div class="kpi-box sev-box-crit">
            <span class="kpi-num">{{ countBySeverity('CRÍTICA') }}</span>
            <span class="kpi-lbl">Crítica</span>
          </div>
        </div>
      </section>

      <!-- Matriz de Defectos con Fotografía y Ubicación en Plano -->
      <section class="details-section">
        <h2 class="section-title">3. DETALLE DE OBSERVACIONES Y EVIDENCIAS FOTOGRÁFICAS</h2>
        
        <div v-for="(obs, index) in observationsList" :key="obs.id" class="obs-row">
          <div class="obs-item-header">
            <span class="obs-index">Ítem #{{ index + 1 }}</span>
            <span class="obs-item-area">{{ obs.area }}</span>
            <span class="obs-item-sev" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
          </div>

          <div class="obs-item-body">
            <div class="obs-text-col">
              <h3 class="obs-item-title">{{ obs.title }}</h3>
              <p class="obs-item-desc">{{ obs.description }}</p>
              
              <div class="obs-tech-meta">
                <p>📍 <strong>Ubicación en Plano:</strong> Coordenadas (X: {{ obs.markerX }}%, Y: {{ obs.markerY }}%)</p>
                <p>🔒 <strong>Integridad de Imagen (SHA-256):</strong> <code>{{ obs.sha256 }}</code></p>
              </div>
            </div>

            <!-- Miniatura de Evidencia Fotográfica y Plano con Pin -->
            <div class="obs-visual-col">
              <div class="evidence-photo-box">
                <div class="fake-photo">
                  <span class="cam-icon">📷</span>
                  <span class="photo-lbl">FOTO DE DEFECTO</span>
                </div>
              </div>
              <div class="evidence-pin-box">
                <div class="mini-blueprint">
                  <div class="mini-pin" :style="{ left: `${obs.markerX}%`, top: `${obs.markerY}%` }">📍 #{{ index + 1 }}</div>
                </div>
                <span class="mini-pin-lbl">Ubicación en Plano</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Cuadro de Firmas y Conformidad Técnica -->
      <section class="signatures-section">
        <h2 class="section-title">4. CONSTANCIA Y FIRMAS DE CONFORMIDAD</h2>
        <p class="legal-text">
          Las partes dejan constancia de las observaciones registradas durante la visita técnica de inspección. La constructora/responsable se compromete a subsanar los puntos acordados en los plazos establecidos contractualmente.
        </p>

        <div class="signatures-grid">
          <div class="sign-box">
            <div class="sign-line"></div>
            <p class="sign-name">{{ reportData.inspector }}</p>
            <p class="sign-role">Inspector Técnico Colegiado</p>
            <p class="sign-sub">Firma Digital Verificada</p>
          </div>
          <div class="sign-box">
            <div class="sign-line"></div>
            <p class="sign-name">{{ reportData.client }}</p>
            <p class="sign-role">Propietario / Cliente</p>
            <p class="sign-sub">DNI / Documento de Identidad</p>
          </div>
        </div>
      </section>

      <!-- Pie de Página -->
      <footer class="report-footer">
        <p>Documento generado electrónicamente por InspecOS Platform · Inmutabilidad respaldada mediante algoritmo SHA-256</p>
      </footer>
    </main>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false // Sin layout para permitir impresión limpia en PDF
})

const route = useRoute()
const inspectionId = computed(() => (route.params.id as string) || '55555555-0000-0000-0000-000000000001')

const formattedDate = new Intl.DateTimeFormat('es-PE', {
  day: '2-digit', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit'
}).format(new Date())

const reportData = {
  project: 'Condominio Los Cedros - Torre B',
  unit: 'Unidad 305',
  building: 'Torre B',
  floor: '3',
  client: 'Carlos Mendoza',
  inspector: 'Arq. Roberto Silva (CIP 84920)',
  status: 'COMPLETADA'
}

const observationsList = [
  {
    id: 'obs-01',
    area: 'Sala / Comedor',
    title: 'Fisura capilar en enlucido de muro norte',
    description: 'Fisura superficial diagonal de 0.4mm sobre enlucido de yeso contiguo a vano de ventana.',
    severity: 'MENOR',
    markerX: 28,
    markerY: 38,
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  },
  {
    id: 'obs-02',
    area: 'Cocina',
    title: 'Junta de cerámico desalineada o con holgura',
    description: 'Separación mayor a 3mm en piso cerámico frente al mesón de granito con sonido a hueco.',
    severity: 'MODERADA',
    markerX: 55,
    markerY: 24,
    sha256: 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'
  },
  {
    id: 'obs-03',
    area: 'Baño Principal',
    title: 'Falta sellado de silicona sanitaria antihongos',
    description: 'Ausencia de cordón perimetral entre mesada de granito y revestimiento cerámico.',
    severity: 'MODERADA',
    markerX: 75,
    markerY: 62,
    sha256: '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a'
  }
]

const totalObservations = computed(() => observationsList.length)

const countBySeverity = (sev: string) => {
  return observationsList.filter(o => o.severity === sev).length
}

const printReport = () => {
  if (typeof window !== 'undefined') {
    window.print()
  }
}
</script>

<style scoped>
.report-page {
  background: #2b2b2b;
  min-height: 100vh;
  padding: 20px 0 60px 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #111;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}

/* Toolbar superior (no imprimible) */
.report-toolbar {
  width: 100%;
  max-width: 860px;
  background: #181818;
  border: 1px solid #333;
  border-radius: 10px;
  padding: 12px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  box-sizing: border-box;
}
.toolbar-left {
  display: flex;
  align-items: center;
  gap: 16px;
}
.btn-back {
  color: #aaa;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
}
.btn-back:hover {
  color: #fff;
}
.report-title-top {
  color: #fff;
  font-weight: 700;
  font-size: 0.92rem;
}
.btn-print {
  background: var(--primary, #1a73e8);
  color: #fff;
  border: none;
  padding: 8px 18px;
  border-radius: 8px;
  font-weight: bold;
  font-size: 0.88rem;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(26,115,232,0.3);
}

/* Hoja Formal Imprimible */
.report-sheet {
  width: 100%;
  max-width: 860px;
  background: #fff;
  padding: 40px 50px;
  box-shadow: 0 10px 40px rgba(0,0,0,0.5);
  box-sizing: border-box;
  color: #222;
}

/* Header */
.report-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  border-bottom: 2px solid #1a73e8;
  padding-bottom: 20px;
  margin-bottom: 24px;
}
.header-logo-block {
  display: flex;
  align-items: center;
  gap: 14px;
}
.logo-mark {
  font-size: 2.2rem;
}
.company-name {
  font-size: 1.4rem;
  margin: 0;
  letter-spacing: 1.5px;
  color: #1a73e8;
}
.company-tagline {
  font-size: 0.75rem;
  color: #666;
  margin: 2px 0 0 0;
}
.header-code-block {
  text-align: right;
}
.doc-badge {
  display: inline-block;
  background: #1a73e8;
  color: #fff;
  font-size: 0.72rem;
  font-weight: bold;
  padding: 4px 10px;
  border-radius: 4px;
  letter-spacing: 0.8px;
  margin-bottom: 6px;
}
.doc-code, .doc-date {
  font-size: 0.8rem;
  color: #555;
  margin: 2px 0;
}

/* Sección Título */
.section-title {
  font-size: 0.95rem;
  font-weight: 800;
  color: #111;
  text-transform: uppercase;
  border-bottom: 1px solid #ddd;
  padding-bottom: 6px;
  margin: 24px 0 12px 0;
}

/* Tabla Meta */
.meta-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.84rem;
}
.meta-table th {
  text-align: left;
  background: #f7f9fa;
  padding: 8px 12px;
  border: 1px solid #e1e4e8;
  color: #555;
  width: 20%;
}
.meta-table td {
  padding: 8px 12px;
  border: 1px solid #e1e4e8;
  color: #111;
  width: 30%;
}
.status-pill {
  background: #e6f4ea;
  color: #137333;
  padding: 2px 8px;
  border-radius: 4px;
  font-weight: bold;
  font-size: 0.75rem;
}

/* KPI Summary */
.kpi-boxes {
  display: flex;
  gap: 12px;
  margin-top: 10px;
}
.kpi-box {
  flex: 1;
  background: #f8f9fa;
  border: 1px solid #e1e4e8;
  border-radius: 8px;
  padding: 12px 8px;
  text-align: center;
}
.kpi-num {
  display: block;
  font-size: 1.4rem;
  font-weight: 800;
  color: #111;
}
.kpi-lbl {
  font-size: 0.72rem;
  color: #666;
  text-transform: uppercase;
}
.sev-box-menor .kpi-num { color: #b06000; }
.sev-box-mod .kpi-num { color: #1a73e8; }
.sev-box-may .kpi-num { color: #d93025; }
.sev-box-crit .kpi-num { color: #a50e0e; }

/* Detalle Observaciones */
.obs-row {
  border: 1px solid #e1e4e8;
  border-radius: 8px;
  margin-bottom: 14px;
  overflow: hidden;
  page-break-inside: avoid;
}
.obs-item-header {
  background: #f1f3f4;
  padding: 8px 14px;
  display: flex;
  align-items: center;
  gap: 10px;
  border-bottom: 1px solid #e1e4e8;
  font-size: 0.8rem;
}
.obs-index {
  font-weight: 800;
  color: #1a73e8;
}
.obs-item-area {
  font-weight: 700;
  color: #333;
}
.obs-item-sev {
  margin-left: auto;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 800;
}
.sev-menor { background: #fef7e0; color: #b06000; }
.sev-moderada { background: #e8f0fe; color: #1a73e8; }
.sev-mayor { background: #fce8e6; color: #d93025; }
.sev-crítica { background: #fce8e6; color: #a50e0e; font-weight: 900; }

.obs-item-body {
  padding: 14px;
  display: flex;
  gap: 20px;
}
.obs-text-col {
  flex: 3;
}
.obs-item-title {
  margin: 0 0 6px 0;
  font-size: 0.95rem;
  color: #111;
}
.obs-item-desc {
  margin: 0 0 10px 0;
  font-size: 0.82rem;
  color: #444;
  line-height: 1.4;
}
.obs-tech-meta p {
  margin: 3px 0;
  font-size: 0.72rem;
  color: #666;
}
.obs-tech-meta code {
  background: #f1f3f4;
  padding: 2px 4px;
  border-radius: 3px;
  font-size: 0.7rem;
  color: #137333;
}

.obs-visual-col {
  flex: 2;
  display: flex;
  gap: 10px;
}
.evidence-photo-box, .evidence-pin-box {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
}
.fake-photo {
  width: 100%;
  height: 90px;
  background: #f1f3f4;
  border: 1px dashed #ccc;
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
}
.cam-icon { font-size: 1.3rem; }
.photo-lbl { font-size: 0.62rem; color: #666; font-weight: bold; }

.mini-blueprint {
  width: 100%;
  height: 90px;
  background: #e8f0fe;
  border: 1px solid #c2d7fe;
  border-radius: 6px;
  position: relative;
}
.mini-pin {
  position: absolute;
  transform: translate(-50%, -100%);
  font-size: 0.65rem;
  font-weight: bold;
  background: #cf6679;
  color: #fff;
  padding: 1px 4px;
  border-radius: 3px;
  white-space: nowrap;
}
.mini-pin-lbl {
  font-size: 0.62rem;
  color: #666;
  margin-top: 4px;
}

/* Firmas */
.signatures-section {
  margin-top: 30px;
  page-break-inside: avoid;
}
.legal-text {
  font-size: 0.75rem;
  color: #555;
  line-height: 1.4;
  margin-bottom: 24px;
}
.signatures-grid {
  display: flex;
  justify-content: space-around;
  margin-top: 50px;
}
.sign-box {
  text-align: center;
  width: 240px;
}
.sign-line {
  border-top: 1px solid #111;
  margin-bottom: 8px;
}
.sign-name {
  font-weight: 700;
  font-size: 0.85rem;
  margin: 0;
}
.sign-role {
  font-size: 0.75rem;
  color: #555;
  margin: 2px 0;
}
.sign-sub {
  font-size: 0.65rem;
  color: #1a73e8;
  font-weight: bold;
}

/* Footer */
.report-footer {
  border-top: 1px solid #eee;
  padding-top: 14px;
  margin-top: 30px;
  text-align: center;
  font-size: 0.68rem;
  color: #888;
}

/* =======================================================
   ESTILOS DE IMPRESIÓN (PRINT MEDIA)
   ======================================================= */
@media print {
  .no-print {
    display: none !important;
  }
  .report-page {
    background: transparent !important;
    padding: 0 !important;
  }
  .report-sheet {
    box-shadow: none !important;
    padding: 0 !important;
    width: 100% !important;
    max-width: 100% !important;
  }
}
</style>

