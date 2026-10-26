<template>
  <div class="openinspection-viewport">

    <!-- BARRA SUPERIOR DE ESTADO / CONECTIVIDAD -->
    <header class="app-top-bar">
      <div class="top-bar-left">
        <div class="brand-badge-mini">
          <span class="brand-logo-icon">🏢</span>
          <span class="brand-name-bold">InspecOS</span>
        </div>
        <span class="mode-tag">Tablet / Campo</span>
      </div>

      <div class="top-bar-center">
        <!-- Indicador de Red / Offline con Sincronización Rápida -->
        <button 
          type="button" 
          class="network-pill" 
          :class="{ 'is-online': isOnline, 'is-offline': !isOnline }"
          @click="toggleNetworkStatus"
          :title="isOnline ? 'Conectado a WiFi - Clic para simular modo sin conexión' : 'Operando Sin Conexión (SQLite Local) - Clic para reconectar'"
        >
          <span class="network-dot"></span>
          <span>{{ isOnline ? 'Conectado (WiFi)' : 'Modo Offline (Drift/SQLite)' }}</span>
        </button>
      </div>

      <div class="top-bar-right">
        <span v-if="pendingSyncItems.length > 0" class="badge-pending-sync" @click="activeBottomTab = 'sync'">
          ⚡ {{ pendingSyncItems.length }} pendientes
        </span>
        <button 
          type="button" 
          class="user-pill-mini-btn" 
          :class="{ active: showProfileModal }"
          @click="showProfileModal = !showProfileModal"
          title="Ver Perfil y Opciones"
        >
          <span class="user-avatar-mini">👤</span>
          <span class="user-email-text">Perfil</span>
        </button>
      </div>
    </header>

    <!-- CUERPO PRINCIPAL SEGÚN PESTAÑA INFERIOR ACTIVA -->
    <main class="app-main-content">

      <!-- ======================================================== -->
      <!-- PANTALLA 1: PESTAÑA "INSPECCIONES" (LISTA Y FILTROS)   -->
      <!-- ======================================================== -->
      <section v-if="activeBottomTab === 'inspections' && !selectedInspection" class="view-inspections-list">
        <div class="list-page-header">
          <div class="list-title-group">
            <h2>Mis Inspecciones</h2>
            <p>Proyectos y departamentos asignados a su cuenta técnica</p>
          </div>

          <!-- Búsqueda y Filtros de Estado como la Pantalla 3 -->
          <div class="search-and-filters">
            <div class="search-input-box">
              <span class="search-icon">🔍</span>
              <input 
                v-model="searchQuery" 
                type="text" 
                placeholder="Buscar por condominio, unidad o cliente..." 
                class="search-field"
              />
            </div>

            <div class="filter-chips-row">
              <button 
                v-for="filter in inspectionFilters" 
                :key="filter.value" 
                type="button" 
                class="filter-chip-btn"
                :class="{ active: selectedFilter === filter.value }"
                @click="selectedFilter = filter.value"
              >
                {{ filter.label }}
                <span class="chip-count">{{ countInspections(filter.value) }}</span>
              </button>
            </div>
          </div>
        </div>

        <!-- Lista de Tarjetas de Inspección -->
        <div class="inspections-cards-grid">
          <div 
            v-for="insp in filteredInspections" 
            :key="insp.id" 
            class="inspection-card-item"
            @click="openInspectionDetail(insp)"
          >
            <div class="card-thumb-column">
              <div class="card-thumb-box" :style="{ backgroundColor: insp.thumbBg }">
                <span class="thumb-icon">{{ insp.thumbIcon }}</span>
              </div>
            </div>

            <div class="card-body-column">
              <div class="card-header-row">
                <h3 class="card-project-title">{{ insp.project }}</h3>
                <span class="status-pill" :class="`pill-${insp.status.toLowerCase()}`">
                  {{ insp.statusLabel }}
                </span>
              </div>

              <p class="card-unit-text"><strong>{{ insp.unit }}</strong> — {{ insp.building }} (Piso {{ insp.floor }})</p>
              <p class="card-client-text">Cliente: {{ insp.client }}</p>
              
              <div class="card-footer-meta">
                <span class="meta-date">📅 {{ insp.scheduledDate }}</span>
                <div class="progress-container">
                  <div class="progress-bar-bg">
                    <div class="progress-bar-fill" :style="{ width: `${insp.progress}%` }"></div>
                  </div>
                  <span class="progress-text">{{ insp.progress }}%</span>
                </div>
              </div>
            </div>

            <div class="card-arrow-column">
              <span class="arrow-icon">›</span>
            </div>
          </div>
        </div>
      </section>

      <!-- ======================================================== -->
      <!-- PANTALLA 2: DETALLE DE INSPECCIÓN CON SUB-PESTAÑAS      -->
      <!-- (Resumen, Plano Interactivo, Checklist, Observaciones)   -->
      <!-- ======================================================== -->
      <section v-else-if="activeBottomTab === 'inspections' && selectedInspection" class="view-inspection-detail">
        
        <!-- Header de la Inspección Seleccionada (Botón volver + Pestañas de Trabajo) -->
        <div class="inspection-sub-header">
          <div class="sub-header-left">
            <button type="button" class="btn-back-inspections" @click="closeInspectionDetail">
              ← Mis Inspecciones
            </button>
            <div class="unit-current-title">
              <h2>{{ selectedInspection.project }} — {{ selectedInspection.unit }}</h2>
              <span class="unit-subtitle">{{ selectedInspection.building }} · Piso {{ selectedInspection.floor }} · {{ selectedInspection.client }}</span>
            </div>
          </div>

          <!-- 4 Pestañas Superiores de la Vista Detalle (4 en la figura) -->
          <div class="detail-nav-tabs">
            <button 
              type="button" 
              class="d-tab-btn" 
              :class="{ active: detailSubTab === 'summary' }"
              @click="detailSubTab = 'summary'"
            >
              📊 Resumen
            </button>
            <button 
              type="button" 
              class="d-tab-btn" 
              :class="{ active: detailSubTab === 'plan' }"
              @click="detailSubTab = 'plan'"
            >
              📐 Plano
            </button>
            <button 
              type="button" 
              class="d-tab-btn" 
              :class="{ active: detailSubTab === 'checklist' }"
              @click="detailSubTab = 'checklist'"
            >
              ✓ Checklist
            </button>
            <button 
              type="button" 
              class="d-tab-btn" 
              :class="{ active: detailSubTab === 'observations' }"
              @click="detailSubTab = 'observations'"
            >
              ⚠️ Observaciones ({{ inspectionObservations.length }})
            </button>
          </div>

          <div class="sub-header-actions">
            <!-- Botón para alternar panel lateral de ambientes cuando estamos en el Plano -->
            <button 
              v-if="detailSubTab === 'plan'" 
              type="button" 
              class="btn-toggle-areas-drawer" 
              :class="{ active: showAreasSidebar }"
              @click="showAreasSidebar = !showAreasSidebar"
              title="Mostrar / Ocultar panel de Ambientes para máxima visualización del plano"
            >
              🏢 Ambientes ({{ inspectionAreas.length }})
            </button>
            <button type="button" class="btn-new-obs-action" @click="openObservationModal()">
              <span class="plus-sign">+</span>
              <span>Defecto</span>
            </button>
          </div>
        </div>

        <!-- SUB-PESTAÑA 1: RESUMEN DE LA INSPECCIÓN (Figura 4) -->
        <div v-if="detailSubTab === 'summary'" class="detail-content-pane summary-pane">
          <div class="summary-hero-banner">
            <div class="hero-left-info">
              <span class="hero-chip-badge">{{ selectedInspection.statusLabel }}</span>
              <h3>{{ selectedInspection.project }} — {{ selectedInspection.unit }}</h3>
              <p class="hero-address">Dirección: Av. Principal 123 - Visita de entrega técnica y recepción de acabados</p>
            </div>
            <div class="hero-right-progress">
              <div class="circular-progress">
                <span class="progress-number">{{ selectedInspection.progress }}%</span>
                <span class="progress-lbl">Avance Total</span>
              </div>
            </div>
          </div>

          <div class="summary-details-grid">
            <div class="detail-info-card">
              <span class="d-card-icon">🏢</span>
              <div class="d-card-texts">
                <label>Proyecto / Condominio</label>
                <strong>{{ selectedInspection.project }}</strong>
              </div>
            </div>

            <div class="detail-info-card">
              <span class="d-card-icon">🏠</span>
              <div class="d-card-texts">
                <label>Departamento / Unidad</label>
                <strong>{{ selectedInspection.unit }} ({{ selectedInspection.building }})</strong>
              </div>
            </div>

            <div class="detail-info-card">
              <span class="d-card-icon">👤</span>
              <div class="d-card-texts">
                <label>Cliente / Propietario</label>
                <strong>{{ selectedInspection.client }}</strong>
              </div>
            </div>

            <div class="detail-info-card">
              <span class="d-card-icon">📐</span>
              <div class="d-card-texts">
                <label>Inspector Designado</label>
                <strong>{{ currentUserName || 'Arq. Roberto Silva' }}</strong>
              </div>
            </div>

            <div class="detail-info-card">
              <span class="d-card-icon">📅</span>
              <div class="d-card-texts">
                <label>Fecha de Inspección</label>
                <strong>{{ selectedInspection.scheduledDate }}</strong>
              </div>
            </div>

            <div class="detail-info-card">
              <span class="d-card-icon">⚡</span>
              <div class="d-card-texts">
                <label>Estado Sincronización</label>
                <strong class="text-green">Sincronizado Local (SQLite)</strong>
              </div>
            </div>
          </div>

          <!-- Acciones Rápidas -->
          <div class="summary-bottom-actions">
            <button type="button" class="btn-summary-cta primary" @click="detailSubTab = 'plan'">
              📐 Ir al Plano Táctil e Insertar Pines →
            </button>
            <button type="button" class="btn-summary-cta secondary" @click="detailSubTab = 'checklist'">
              ✓ Abrir Checklist Técnica por Ambiente →
            </button>
            <NuxtLink :to="`/reports/${selectedInspection.id}`" class="btn-summary-cta ghost">
              📄 Ver Acta Oficial / Informe Técnico PDF
            </NuxtLink>
          </div>
        </div>

        <!-- SUB-PESTAÑA 2: PLANO INTERACTIVO Y PINES (Figura 5) -->
        <div v-show="detailSubTab === 'plan'" class="detail-content-pane plan-pane">
          <div class="plan-interactive-layout">
            
            <!-- Lienzo del Plano Arquitectónico -->
            <div class="plan-canvas-wrapper" @click="handlePlanCanvasClick">
              <div class="plan-header-legend">
                <div class="legend-info">
                  <span class="pin-sample">📍</span>
                  <span v-if="isPickingPinForModal" class="text-picking-alert">
                    📌 SELECCIÓN DE PLANO ACTIVA: Toque el punto exacto en el plano para asociarlo a su observación
                  </span>
                  <span v-else-if="movingPinIndex !== null" class="text-moving-alert">
                    MODO REUBICACIÓN: Toque en el plano donde reubicar el Pin #{{ movingPinIndex + 1 }}
                  </span>
                  <span v-else>Toque cualquier punto o habitación del plano para situar una observación con foto</span>
                </div>
                <div class="legend-controls">
                  <button v-if="isPickingPinForModal" class="btn-cancel-move-sm" @click.stop="cancelPickPinForModal">
                    ✕ Cancelar y Volver
                  </button>
                  <button v-else-if="movingPinIndex !== null" class="btn-cancel-move-sm" @click.stop="cancelPinMove">
                    ✕ Cancelar
                  </button>
                  <span class="pins-count-tag">Pines activos: {{ inspectionMarkers.length }}</span>
                </div>
              </div>

              <!-- Barra Superior de Ambientes Fuera del Plano (Dos filas o acomodación fluida sin desborde) -->
              <div class="floorplan-top-areas-bar">
                <div class="top-areas-title">
                  <span>Ambientes:</span>
                </div>
                <div 
                  class="top-areas-chips-container"
                  :class="{ 'allow-scroll': inspectionAreas.length > 10 }"
                >
                  <div 
                    v-for="(area, aIdx) in inspectionAreas" 
                    :key="area.id"
                    class="floorplan-area-chip-compact"
                    :class="[area.cssClass, { active: activeSelectedArea === area.name }]"
                    @click.stop="activeSelectedArea = area.name"
                  >
                    <span class="area-chip-icon">{{ getAreaIcon(area.canonicalArea) }}</span>
                    <span class="area-chip-title">{{ area.name }}</span>
                    <button 
                      type="button" 
                      class="btn-chip-retype" 
                      @click.stop="openRecategorizeModal(area)"
                      :title="`Tipo actual: ${area.canonicalArea}. Clic para recategorizar o renombrar`"
                    >
                      ⚙️
                    </button>
                  </div>
                </div>
              </div>

              <!-- Área Gráfica del Plano con Imagen Real del Departamento (Agrandado y Limpio) -->
              <div class="blueprint-canvas" @click="handlePlanCanvasClick($event)">
                <div class="blueprint-grid-lines"></div>

                <!-- Imagen Real del Plano del Cliente (Sin tags estorbando la vista) -->
                <div class="floorplan-image-wrapper">
                  <img 
                    :src="activePlanImageUrl" 
                    alt="Plano Arquitectónico de la Unidad" 
                    class="floorplan-render-img"
                  />

                  <!-- Pines Interactivos sobre el Plano Real -->
                  <div 
                    v-for="(marker, mIdx) in inspectionMarkers" 
                    :key="marker.id"
                    class="plan-pin-marker"
                    :style="{ left: `${marker.x}%`, top: `${marker.y}%` }"
                    :class="[`sev-${marker.severity.toLowerCase()}`, { moving: movingPinIndex === mIdx, selected: selectedMarkerId === marker.id }]"
                    @click.stop="selectMarkerOnPlan(marker, mIdx)"
                  >
                    <div class="pin-bubble">
                      <span class="pin-ico">📍</span>
                      <span class="pin-idx">{{ mIdx + 1 }}</span>
                    </div>
                    <div class="pin-tooltip">
                      <strong>#{{ mIdx + 1 }} {{ marker.title }}</strong>
                      <small>{{ marker.area }} · {{ marker.severity }}</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Panel Lateral de Zonas y Marcador Seleccionado (Ocultable para maximizar plano) -->
            <div 
              class="plan-sidebar-info"
              :class="{ 'sidebar-visible': showAreasSidebar, 'sidebar-hidden': !showAreasSidebar && !selectedMarkerItem }"
            >
              <!-- Barra de Control de Pin Seleccionado -->
              <div v-if="selectedMarkerItem" class="selected-pin-toolbar">
                <div class="selected-pin-header">
                  <span class="pin-tag-badge">Pin #{{ getMarkerIndex(selectedMarkerItem.id) + 1 }}</span>
                  <button type="button" class="btn-close-pin-panel" @click="selectedMarkerId = null">✕</button>
                </div>
                <h4 class="pin-toolbar-title">{{ selectedMarkerItem.title }}</h4>
                <p class="pin-toolbar-area">Zona: <strong>{{ selectedMarkerItem.area }}</strong> ({{ selectedMarkerItem.x }}%, {{ selectedMarkerItem.y }}%)</p>

                <div class="pin-toolbar-actions">
                  <button type="button" class="btn-action-move" @click="startPinMove(selectedMarkerItem)">
                    🔄 Reubicar Pin
                  </button>
                  <button type="button" class="btn-action-delete" @click="deleteMarker(selectedMarkerItem.id)">
                    🗑️ Eliminar Pin
                  </button>
                </div>
              </div>

              <!-- Selector y Gestión de Ambientes -->
              <div class="areas-management-card">
                <div class="areas-title-head">
                  <h4>Ambientes de la Unidad ({{ inspectionAreas.length }})</h4>
                  <p>Renombre o toque una zona para filtrar observaciones</p>
                </div>

                <div class="areas-pills-list">
                  <div 
                    v-for="(area, aIdx) in inspectionAreas" 
                    :key="area.id" 
                    class="area-manage-item"
                    :class="{ selected: activeSelectedArea === area.name }"
                    @click="activeSelectedArea = area.name"
                  >
                    <div class="area-item-name">
                      <span class="area-bullet"></span>
                      <div class="area-texts-column">
                        <span class="area-name-display">{{ area.name }}</span>
                        <small class="area-type-tag">↳ Checklist: <strong>{{ area.canonicalArea }}</strong></small>
                      </div>
                    </div>
                    <div class="area-item-controls">
                      <button 
                        type="button" 
                        class="btn-mini-rename" 
                        @click.stop="openRecategorizeModal(area)"
                        title="Recategorizar o renombrar ambiente"
                      >
                        ⚙️
                      </button>
                      <button type="button" class="btn-mini-delete" @click.stop="removeAreaFromPlan(aIdx)">✕</button>
                    </div>
                  </div>
                </div>

                <!-- Formulario Añadir Nuevo Ambiente -->
                <div class="add-area-inline-box">
                  <input 
                    v-model="newAreaNameInput" 
                    type="text" 
                    placeholder="Nuevo ambiente (Ej: Lavandería)..."
                    class="input-add-area"
                    @keyup.enter="addNewAreaToInspection"
                  />
                  <button type="button" class="btn-add-area-btn" @click="addNewAreaToInspection">+ Añadir</button>
                </div>
              </div>
            </div>

          </div>
        </div>

        <!-- SUB-PESTAÑA 3: CHECKLIST DE VERIFICACIÓN (ESTRUCTURA AGRUPADA CON ESTADO PENDIENTE/REVISADO) -->
        <div v-show="detailSubTab === 'checklist'" class="detail-content-pane checklist-pane">
          <div class="checklist-top-control">
            <div class="checklist-instruction">
              <h3>{{ activeSelectedArea }}</h3>
              <p>Especialidades y componentes evaluables de la unidad. Cada sección pasa de <strong>Pendiente</strong> a <strong>Revisado</strong> cuando todos sus puntos son verificados.</p>
            </div>

            <!-- Selector de Áreas para Checklist -->
            <div class="checklist-areas-scroller">
              <button 
                v-for="area in inspectionAreas" 
                :key="area.id"
                type="button" 
                class="cl-area-pill"
                :class="{ active: activeSelectedArea === area.name }"
                @click="activeSelectedArea = area.name"
              >
                {{ area.name }}
              </button>
            </div>
          </div>

          <!-- Especialidades Principales y Componentes Internos -->
          <div class="checklist-groups-wrapper">
            <div 
              v-for="group in currentAreaChecklistGroups" 
              :key="group.id" 
              class="cl-group-box"
              :class="{ 'is-completed': group.isCompleted, 'is-expanded': group.isExpanded }"
            >
              <!-- Cabecera de Especialidad Principal (Item Principal) -->
              <div class="cl-group-header" @click="group.isExpanded = !group.isExpanded">
                <div class="cl-group-title-col">
                  <span class="cl-group-icon">{{ group.icon }}</span>
                  <div class="cl-group-texts">
                    <div class="cl-title-row">
                      <h4>{{ group.name }}</h4>
                      <span 
                        class="cl-group-status-badge" 
                        :class="group.isCompleted ? 'status-reviewed' : 'status-pending'"
                      >
                        {{ group.isCompleted ? '✓ Revisado' : '⏳ Pendiente' }}
                      </span>
                    </div>
                    <p class="cl-group-summary-line">{{ group.summary }}</p>
                  </div>
                </div>

                <div class="cl-group-arrow-col">
                  <span class="arrow-indicator">{{ group.isExpanded ? '▲' : '▼' }}</span>
                </div>
              </div>

              <!-- Lista de Componentes Internos (Items Secundarios) -->
              <div v-if="group.isExpanded" class="cl-subitems-container">
                <div 
                  v-for="item in group.items" 
                  :key="item.id" 
                  class="cl-subitem-row"
                >
                  <div class="cl-subitem-info">
                    <span class="subitem-title">{{ item.title }}</span>
                    <p class="subitem-spec">{{ item.specification }}</p>
                  </div>

                  <!-- Botones OK, OBS, N/A, NV -->
                  <div class="cl-subitem-actions">
                    <button 
                      type="button" 
                      class="btn-status-choice btn-ok" 
                      :class="{ selected: item.status === 'OK' }"
                      @click="setSubItemStatus(item, 'OK')"
                      title="Conforme: Cumple el criterio de aceptación aplicable"
                    >
                      ✓ OK
                    </button>
                    <button 
                      type="button" 
                      class="btn-status-choice btn-obs" 
                      :class="{ selected: item.status === 'OBS' }"
                      @click="triggerObsFromChecklistSubItem(item, group.name)"
                      title="Observado: Requiere corrección o elemento faltante previsto"
                    >
                      ⚠ OBS
                    </button>
                    <button 
                      type="button" 
                      class="btn-status-choice btn-na" 
                      :class="{ selected: item.status === 'N/A' }"
                      @click="setSubItemStatus(item, 'N/A')"
                      title="No aplica: No corresponde al inmueble o alcance"
                    >
                      — N/A
                    </button>
                    <button 
                      type="button" 
                      class="btn-status-choice btn-nv" 
                      :class="{ selected: item.status === 'NV' }"
                      @click="setSubItemStatus(item, 'NV')"
                      title="No verificado: Falta de acceso, suministro o condición técnica de prueba"
                    >
                      👁 NV
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- SUB-PESTAÑA 4: LISTA DE OBSERVACIONES TÉCNICAS -->
        <div v-show="detailSubTab === 'observations'" class="detail-content-pane observations-pane">
          <div class="obs-pane-header">
            <div>
              <h3>No-Conformidades Registradas ({{ inspectionObservations.length }})</h3>
              <p>Evidencias fotográficas con verificación criptográfica SHA-256</p>
            </div>
            <button type="button" class="btn-new-obs-action" @click="openObservationModal()">
              + Registrar Nueva Observación
            </button>
          </div>

          <div v-if="inspectionObservations.length === 0" class="empty-obs-box">
            <span class="empty-ico">✅</span>
            <h4>No existen observaciones pendientes</h4>
            <p>Utilice el plano táctil o el checklist para registrar no-conformidades con fotografía.</p>
          </div>

          <div v-else class="obs-cards-list">
            <div 
              v-for="(obs, idx) in inspectionObservations" 
              :key="obs.id"
              class="obs-detail-card"
            >
              <div class="obs-card-header-bar">
                <div class="obs-tags-left">
                  <span class="badge-idx">#{{ idx + 1 }}</span>
                  <span class="badge-severity" :class="`sev-${obs.severity.toLowerCase()}`">{{ obs.severity }}</span>
                  <span class="badge-area">{{ obs.area }}</span>
                  <span class="badge-status">{{ obs.status }}</span>
                </div>
                <button type="button" class="btn-delete-obs-item" @click="deleteObservationItem(obs.id)" title="Eliminar observación">
                  🗑️
                </button>
              </div>

              <h4 class="obs-card-title">{{ obs.title }}</h4>
              
              <!-- Categoría, Subcategoría y Ubicación Técnica -->
              <div class="obs-card-cat-line">
                <span class="obs-badge-cat">📁 {{ obs.category }}</span>
                <span v-if="obs.subcategory" class="obs-badge-sub">↳ {{ obs.subcategory }}</span>
              </div>
              <p v-if="obs.locationDetails" class="obs-card-loc">
                📍 <em>Ubicación:</em> {{ obs.locationDetails }}
              </p>

              <!-- Medición Cuantitativa si fue registrada con instrumentos -->
              <div v-if="obs.hasMeasurements" class="obs-card-measurements-line">
                <span class="badge-measure-tag">📏 Medición:</span>
                <span class="badge-measure-val">{{ obs.measuredValue }} {{ obs.measurementUnit }}</span>
                <span v-if="obs.instrumentUsed" class="badge-measure-inst">({{ obs.instrumentUsed }})</span>
              </div>

              <p class="obs-card-desc">{{ obs.description }}</p>

              <!-- Evidencias Fotográficas -->
              <div class="obs-photos-grid">
                <div v-for="(photo, pIdx) in obs.photos" :key="pIdx" class="photo-thumb-card">
                  <img v-if="photo.dataUrl" :src="photo.dataUrl" alt="Evidencia" class="photo-img-render" />
                  <div v-else class="photo-placeholder">📸 Foto {{ pIdx + 1 }}</div>
                  <div class="photo-meta-info">
                    <span class="photo-file-name">{{ photo.fileName }}</span>
                    <code class="photo-sha">SHA-256: {{ photo.sha256.substring(0, 16) }}...</code>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

      </section>

      <!-- ======================================================== -->
      <!-- PANTALLA 3: PESTAÑA "SINCRONIZACIÓN" (Pantalla 2 y 9)   -->
      <!-- ======================================================== -->
      <section v-else-if="activeBottomTab === 'sync'" class="view-sync-engine">
        <div class="sync-pane-card">
          <div class="sync-pane-header">
            <h2>Motor de Sincronización Offline</h2>
            <p>Descarga y subida de datos entre el almacenamiento local (Drift/SQLite) y la nube</p>
          </div>

          <div class="sync-circular-container">
            <div class="sync-progress-circle" :class="{ spinning: isSyncing }">
              <span class="sync-percentage">{{ syncPercentage }}%</span>
              <span class="sync-circle-label">{{ isSyncing ? 'Sincronizando...' : 'Completado' }}</span>
            </div>
          </div>

          <div class="sync-items-checklist">
            <div class="sync-checklist-item">
              <span class="sync-item-icon">📁</span>
              <div class="sync-item-texts">
                <strong>Proyectos Inmobiliarios</strong>
                <small>3 proyectos descargados para trabajo sin red</small>
              </div>
              <span class="sync-item-status check">✓ 3/3</span>
            </div>

            <div class="sync-checklist-item">
              <span class="sync-item-icon">🏢</span>
              <div class="sync-item-texts">
                <strong>Departamentos y Unidades</strong>
                <small>Planimetría y datos de clientes almacenados</small>
              </div>
              <span class="sync-item-status check">✓ 12/12</span>
            </div>

            <div class="sync-checklist-item">
              <span class="sync-item-icon">✓</span>
              <div class="sync-item-texts">
                <strong>Plantillas de Checklist y Acabados</strong>
                <small>Catálogo estándar de verificación</small>
              </div>
              <span class="sync-item-status check">✓ 4/4</span>
            </div>

            <div class="sync-checklist-item">
              <span class="sync-item-icon">📸</span>
              <div class="sync-item-texts">
                <strong>Fotos y Observaciones en Cola Outbox</strong>
                <small>{{ pendingSyncItems.length }} elementos pendientes de sincronizar</small>
              </div>
              <span class="sync-item-status" :class="pendingSyncItems.length === 0 ? 'check' : 'pending'">
                {{ pendingSyncItems.length === 0 ? '✓ Al día' : `⏳ ${pendingSyncItems.length} pendientes` }}
              </span>
            </div>
          </div>

          <div class="sync-actions-bottom">
            <button 
              type="button" 
              class="btn-trigger-sync" 
              :disabled="isSyncing"
              @click="runSyncCycle"
            >
              {{ isSyncing ? 'Sincronizando datos con la nube...' : '⚡ Sincronizar Ahora (Verificar Hashes SHA-256)' }}
            </button>
            <p class="sync-hint-text">
              {{ isOnline ? 'Conexión a internet activa. La subida verificará conflictos concurrentes.' : 'Actualmente sin conexión. Los registros permanecerán resguardados en el dispositivo.' }}
            </p>
          </div>
        </div>
      </section>

      <!-- ======================================================== -->
      <!-- PANTALLA 4: PESTAÑA "ARQUITECTURA Y PLANOS"             -->
      <!-- ======================================================== -->
      <section v-else-if="activeBottomTab === 'plans'" class="view-architecture-pane">
        <div class="arch-pane-header">
          <div>
            <h2>Planos & Arquitectura de Campo</h2>
            <p>Visualice, suba o reemplace el plano para delimitar las áreas técnicas de la unidad</p>
          </div>
          <button type="button" class="btn-upload-plan-top" @click="showUploadPlanModal = true">
            📁 Subir / Cambiar Plano
          </button>
        </div>

        <div class="arch-unit-selector-bar">
          <label>Unidad / Departamento:</label>
          <select v-model="selectedArchUnit" class="arch-unit-select" @change="onArchUnitChange">
            <option v-for="insp in inspectionsList" :key="insp.id" :value="insp.id">
              {{ insp.unit }} — {{ insp.project }} ({{ insp.building }})
            </option>
          </select>
        </div>

        <!-- Visor del Plano con Delimitación de Ambientes -->
        <div class="arch-plan-viewer-card">
          <div class="arch-plan-top-info">
            <span class="plan-file-badge">📄 {{ currentArchPlan.fileName }}</span>
            <span class="plan-hash-badge">SHA-256: <code>{{ currentArchPlan.sha256.substring(0, 16) }}...</code></span>
            <span class="plan-status-verified">✓ Verificado para Inspección</span>
          </div>

          <div class="arch-blueprint-display">
            <!-- Imagen Real del Plano en Vista de Arquitectura (Agrandado y limpio) -->
            <div class="floorplan-image-wrapper arch-mode">
              <img 
                :src="activePlanImageUrl" 
                alt="Plano de Arquitectura de la Unidad" 
                class="floorplan-render-img"
              />
            </div>
          </div>

          <!-- Barra de Gestión Rápida de Áreas del Plano -->
          <div class="arch-areas-toolbar">
            <div class="add-area-inline">
              <input 
                v-model="newArchAreaInput" 
                type="text" 
                class="modal-input-sm" 
                placeholder="Añadir nuevo ambiente (ej: Lavandería, Balcón, Baño)..." 
                @keyup.enter.prevent="addArchArea" 
              />
              <button type="button" class="btn-add-area" @click="addArchArea">+ Añadir Ambiente</button>
            </div>
            <p class="arch-help-note">
              Los ambientes configurados aquí se sincronizan automáticamente con la lista de checklist y el plano táctil.
            </p>
          </div>
        </div>
      </section>

      <!-- ======================================================== -->
      <!-- PANTALLA 5: PESTAÑA "INFORMES & ACTAS PDF"               -->
      <!-- ======================================================== -->
      <section v-else-if="activeBottomTab === 'reports'" class="view-reports-pane">
        <div class="reports-pane-header">
          <div>
            <h2>Actas & Informes Técnicos PDF</h2>
            <p>Consulte las actas generadas con firmas digitales y respaldo SHA-256 para descarga o firma</p>
          </div>
        </div>

        <div class="reports-cards-list">
          <div v-for="rep in reportsList" :key="rep.id" class="app-report-card">
            <div class="rep-card-header">
              <div class="rep-code-box">
                <span class="rep-doc-icon">📑</span>
                <div>
                  <h4>{{ rep.code }}</h4>
                  <span class="rep-meta-sub">{{ rep.date }} · {{ rep.unit }}</span>
                </div>
              </div>
              <span class="rep-badge-signed" :class="{ 'needs-sign': !rep.isSigned }">
                {{ rep.isSigned ? '✓ Firmada y Lista' : '⏳ Pendiente de Firma' }}
              </span>
            </div>

            <div class="rep-body-info">
              <div class="rep-info-col">
                <label>Proyecto:</label>
                <strong>{{ rep.project }}</strong>
              </div>
              <div class="rep-info-col">
                <label>Cliente:</label>
                <strong>{{ rep.client }}</strong>
              </div>
              <div class="rep-info-col">
                <label>Inspector Responsable:</label>
                <strong>{{ rep.inspector }}</strong>
              </div>
              <div class="rep-info-col">
                <label>Observaciones:</label>
                <strong>{{ rep.obsCount }} registradas</strong>
              </div>
            </div>

            <div class="rep-actions-bar">
              <button 
                v-if="!rep.isSigned" 
                type="button" 
                class="btn-rep-action sign"
                @click="signReportOnline(rep)"
              >
                ✍️ Firmar Acta Digitalmente
              </button>
              <NuxtLink :to="`/reports/${rep.id}`" class="btn-rep-action download">
                📥 Ver y Descargar PDF
              </NuxtLink>
            </div>
          </div>
        </div>
      </section>

      <!-- ======================================================== -->
      <!-- PANTALLA 6: PESTAÑA "PERFIL / USUARIO" (Modal o vista)   -->
      <!-- ======================================================== -->
      <section v-else-if="activeBottomTab === 'profile'" class="view-profile-pane">
        <div class="profile-card-box">
          <div class="profile-avatar-large">👷‍♂️</div>
          <h3>{{ currentUserName || 'Arq. Roberto Silva' }}</h3>
          <p class="profile-role-tag">Inspector Técnico de Campo</p>
          <span class="profile-email-badge">inspector@inspector.com</span>

          <div class="profile-meta-list">
            <div class="profile-meta-row">
              <span>Organización:</span>
              <strong>InspecOS Constructora</strong>
            </div>
            <div class="profile-meta-row">
              <span>Modo de Operación:</span>
              <strong>Tablet Táctil Habilitada</strong>
            </div>
            <div class="profile-meta-row">
              <span>Almacenamiento Local:</span>
              <strong>Drift SQLite Activo (Cifrado)</strong>
            </div>
          </div>

          <button type="button" class="btn-logout-app" @click="handleAppLogout">
            🚪 Cerrar Sesión y Salir
          </button>
        </div>
      </section>

    </main>

    <!-- BARRA DE NAVEGACIÓN INFERIOR (TABLET DOCK) -->
    <nav class="app-bottom-nav">
      <button 
        type="button" 
        class="nav-dock-btn" 
        :class="{ active: activeBottomTab === 'inspections' }"
        @click="activeBottomTab = 'inspections'"
      >
        <span class="dock-icon">📋</span>
        <span class="dock-label">Inspecciones</span>
      </button>

      <button 
        type="button" 
        class="nav-dock-btn" 
        :class="{ active: activeBottomTab === 'plans' }"
        @click="activeBottomTab = 'plans'"
      >
        <span class="dock-icon">📐</span>
        <span class="dock-label">Arquitectura</span>
      </button>

      <button 
        type="button" 
        class="nav-dock-btn" 
        :class="{ active: activeBottomTab === 'reports' }"
        @click="activeBottomTab = 'reports'"
      >
        <span class="dock-icon">📄</span>
        <span class="dock-label">Informes</span>
      </button>

      <button 
        type="button" 
        class="nav-dock-btn" 
        :class="{ active: activeBottomTab === 'sync' }"
        @click="activeBottomTab = 'sync'"
      >
        <span class="dock-icon">⚡</span>
        <span class="dock-label">Sincronización</span>
        <span v-if="pendingSyncItems.length > 0" class="dock-bubble">{{ pendingSyncItems.length }}</span>
      </button>
    </nav>

    <!-- ======================================================== -->
    <!-- MODAL EMERGENTE: PERFIL / USUARIO DESDE PARTE SUPERIOR   -->
    <!-- ======================================================== -->
    <div v-if="showProfileModal" class="modal-backdrop-camera" @click.self="showProfileModal = false">
      <div class="modal-profile-window">
        <div class="modal-profile-header">
          <h3>Perfil del Inspector</h3>
          <button type="button" class="btn-close-modal-x" @click="showProfileModal = false">✕</button>
        </div>
        <div class="profile-card-box modal-box">
          <div class="profile-avatar-large">👷‍♂️</div>
          <h3>{{ currentUserName || 'Arq. Roberto Silva' }}</h3>
          <p class="profile-role-tag">Inspector Técnico de Campo</p>
          <span class="profile-email-badge">{{ currentUserName ? 'inspector@inspecos.com' : 'inspector@inspector.com' }}</span>

          <div class="profile-meta-list">
            <div class="profile-meta-row">
              <span class="meta-label">Organización:</span>
              <strong class="meta-val">InspecOS Inmobiliaria</strong>
            </div>
            <div class="profile-meta-row">
              <span class="meta-label">Modo Operativo:</span>
              <strong class="meta-val">Tablet / Móvil Táctil</strong>
            </div>
            <div class="profile-meta-row">
              <span class="meta-label">Almacenamiento:</span>
              <strong class="meta-val">Drift SQLite Activo</strong>
            </div>
          </div>

          <div class="profile-modal-actions">
            <button type="button" class="btn-cancel-modal" @click="showProfileModal = false">
              Volver a la App
            </button>
            <button type="button" class="btn-logout-app-modal" @click="handleAppLogout">
              🚪 Cerrar Sesión
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- ======================================================== -->
    <!-- MODAL EMERGENTE: RECATEGORIZAR / RENOMBRAR AMBIENTE     -->
    <!-- ======================================================== -->
    <div v-if="showRecategorizeModal && editingAreaTarget" class="modal-backdrop-camera" @click.self="showRecategorizeModal = false">
      <div class="modal-obs-window modal-recat-window">
        <div class="modal-obs-header">
          <div>
            <h3>Configurar Ambiente Técnico</h3>
            <span class="modal-location-subtitle">Ajuste el nombre visible en plano y asocie el tipo de checklist correspondiente</span>
          </div>
          <button type="button" class="btn-close-modal-x" @click="showRecategorizeModal = false">✕</button>
        </div>

        <div class="modal-obs-body">
          <div class="form-group-custom">
            <label>Nombre del Ambiente en Plano:</label>
            <input 
              v-model="editingAreaForm.name" 
              type="text" 
              class="field-input" 
              placeholder="Ej: Closet / Lavandería, Kitchenette..." 
            />
            <small class="field-help-text">Este nombre se mostrará en los tags y reportes de la unidad.</small>
          </div>

          <div class="form-group-custom">
            <label>Tipo de Checklist Técnico a Evaluar (Canónico):</label>
            <select v-model="editingAreaForm.canonicalArea" class="field-input">
              <option value="Sala / Comedor">Sala / Comedor (Muros, cielo raso, pisos, TG, puerta ingreso, alarma)</option>
              <option value="Cocina">Cocina (Muebles reposteros, encimera, grifería, campana, gas)</option>
              <option value="Baño Principal">Baño Principal (Inodoro, ducha, lavatorio, ventilación, sellos húmedos)</option>
              <option value="Dormitorio">Dormitorio (Clósets, cajonería, ventana, puertas interiores)</option>
              <option value="Lavandería">Lavandería (Poza de lavado, grifería de servicio, puntos lavadora, terma/calentador)</option>
              <option value="Balcón">Balcón / Terraza (Barandas, cristales templados, sumideros pluviales)</option>
            </select>
            <small class="field-help-text">
              <strong>Importante:</strong> Aunque en el plano diga "Closet", si contiene instalaciones sanitarias o lavadero puede evaluarse como <strong>Lavandería</strong> con su checklist correspondiente.
            </small>
          </div>
        </div>

        <div class="modal-obs-footer">
          <button type="button" class="btn-cancel-modal" @click="showRecategorizeModal = false">Cancelar</button>
          <button type="button" class="btn-save-modal" @click="saveRecategorizedArea">
            Guardar Configuración
          </button>
        </div>
      </div>
    </div>

    <!-- ======================================================== -->
    <!-- MODAL EMERGENTE: SUBIR O CAMBIAR PLANO ARQUITECTÓNICO    -->
    <!-- ======================================================== -->
    <div v-if="showUploadPlanModal" class="modal-backdrop-camera" @click.self="showUploadPlanModal = false">
      <div class="modal-obs-window">
        <div class="modal-obs-header">
          <div>
            <h3>Cargar Nuevo Plano Arquitectónico</h3>
            <span class="modal-location-subtitle">Reemplace el plano en PDF o Imagen para actualizar las delimitaciones</span>
          </div>
          <button type="button" class="btn-close-modal-x" @click="showUploadPlanModal = false">✕</button>
        </div>
        <div class="modal-obs-body">
          <div class="form-group-custom">
            <label>Seleccionar Archivo (PDF, PNG, JPG):</label>
            <input type="file" accept="application/pdf,image/png,image/jpeg" class="field-input" @change="handleArchFileUpload" />
          </div>
          <div v-if="uploadedArchFileName" class="uploaded-arch-file-info">
            <p>✓ Archivo listo: <strong>{{ uploadedArchFileName }}</strong></p>
            <small>Se calculará hash criptográfico SHA-256 e integrará con los ambientes de inspección.</small>
          </div>
        </div>
        <div class="modal-obs-footer">
          <button type="button" class="btn-cancel-modal" @click="showUploadPlanModal = false">Cancelar</button>
          <button type="button" class="btn-save-modal" :disabled="!uploadedArchFileName" @click="saveUploadedArchPlan">
            Guardar Plano en la Unidad
          </button>
        </div>
      </div>
    </div>

    <!-- ======================================================== -->
    <!-- MODAL EMERGENTE: REGISTRAR OBSERVACIÓN CON CÁMARA/FOTO   -->
    <!-- (Con Especialidades y Subcategorías sincronizadas)        -->
    <!-- ======================================================== -->
    <div v-if="showObsModal" class="modal-backdrop-camera" @click.self="showObsModal = false">
      <div class="modal-obs-window">
        <div class="modal-obs-header">
          <div class="modal-title-wrap">
            <h3>Nueva Observación Técnica</h3>
            <span class="modal-location-subtitle">
              Ambiente: <strong>{{ activeSelectedArea }}</strong> 
              <span v-if="pendingCoordinates">· Coordenadas: ({{ pendingCoordinates.x }}%, {{ pendingCoordinates.y }}%)</span>
            </span>
          </div>
          <button type="button" class="btn-close-modal-x" @click="showObsModal = false">✕</button>
        </div>

        <form @submit.prevent="saveObservationWithPhoto" class="modal-obs-body">
          
          <!-- Descripción del Defecto (Casilla única con dropdown flotante integrado bajo la casilla) -->
          <div class="form-group-custom">
            <div class="field-label-row">
              <label>Descripción del Defecto:</label>
              <span v-if="suggestedDefectsList.length > 0" class="field-hint-chip">
                {{ suggestedDefectsList.length }} observaciones típicas
              </span>
            </div>
            
            <div class="custom-combobox-wrapper">
              <div class="single-defect-input-wrap">
                <input 
                  v-model="obsForm.title" 
                  type="text" 
                  class="field-input defect-single-input" 
                  placeholder="Escriba o presione ▾ para desplegar opciones..."
                  required 
                  @input="onDefectInputChanged"
                  @focus="showDefectsDropdown = true"
                />
                
                <!-- Botón flecha integrado en la misma casilla -->
                <button 
                  v-if="suggestedDefectsList.length > 0" 
                  type="button" 
                  class="btn-toggle-custom-dropdown" 
                  :class="{ active: showDefectsDropdown }"
                  @click="showDefectsDropdown = !showDefectsDropdown"
                  title="Desplegar observaciones típicas directamente bajo la casilla"
                >
                  ▾
                </button>
              </div>

              <!-- Menú Desplegable personalizado directamente bajo la casilla (No se sale de la pantalla) -->
              <div 
                v-if="showDefectsDropdown && suggestedDefectsList.length > 0" 
                class="custom-dropdown-panel"
              >
                <div class="dropdown-header-tag">
                  Observaciones típicas para: <strong>{{ obsForm.subcategory || obsForm.category }}</strong>
                </div>
                <div class="dropdown-items-scroll">
                  <div 
                    v-for="(defect, dIdx) in suggestedDefectsList" 
                    :key="dIdx" 
                    class="custom-dropdown-item"
                    :class="{ selected: obsForm.title === defect }"
                    @click="selectDefectItem(defect)"
                  >
                    <span class="defect-bullet">•</span>
                    <span class="defect-text">{{ defect }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Categoría (Especialidad principal) y Subcategoría (Componente) vinculadas -->
          <div class="form-row-custom obs-category-split-row">
            <div class="form-col">
              <label>Categoría / Especialidad:</label>
              <select v-model="obsForm.category" class="field-input" @change="onObsCategoryChange">
                <option v-for="(subs, catName) in checklistCatalog" :key="catName" :value="catName">
                  {{ catName }}
                </option>
              </select>
            </div>

            <div class="form-col">
              <label>Subcategoría / Componente:</label>
              <select v-model="obsForm.subcategory" class="field-input">
                <option v-for="sub in availableSubcategories" :key="sub" :value="sub">
                  {{ sub }}
                </option>
              </select>
            </div>
          </div>

          <!-- Medidas e Instrumentos de Medición (Casilla desplegable opcional) -->
          <div class="measurements-section-card">
            <label class="measurements-toggle-label">
              <input 
                type="checkbox" 
                v-model="obsForm.hasMeasurements" 
                class="measurements-checkbox"
              />
              <span class="measurements-toggle-text">
                📏 <strong>Medidas e instrumentos</strong>
                <small>(Habilitar para registrar mediciones instrumentales cuantitativas)</small>
              </span>
            </label>

            <!-- Las 3 casillas en una sola fila compacta cuando se activa -->
            <div v-if="obsForm.hasMeasurements" class="measurements-fields-row">
              <div class="measure-col measure-val-col">
                <label>Valor medido:</label>
                <input 
                  v-model="obsForm.measuredValue" 
                  type="text" 
                  class="field-input measure-input" 
                  placeholder="Ej: 0.4, 2.5, 220" 
                />
              </div>

              <div class="measure-col measure-unit-col">
                <label>Unidad:</label>
                <select v-model="obsForm.measurementUnit" class="field-input measure-select">
                  <option value="mm">mm (milímetros)</option>
                  <option value="cm">cm (centímetros)</option>
                  <option value="m">m (metros)</option>
                  <option value="V">V (voltios)</option>
                  <option value="A">A (amperios)</option>
                  <option value="Ω">Ω (ohmios)</option>
                  <option value="%">% (porcentaje / humedad)</option>
                  <option value="lux">lux (iluminancia)</option>
                  <option value="dB">dB (nivel sonoro)</option>
                </select>
              </div>

              <div class="measure-col measure-inst-col">
                <label>Instrumento empleado:</label>
                <input 
                  v-model="obsForm.instrumentUsed" 
                  type="text" 
                  class="field-input measure-input" 
                  placeholder="Ej: Fisurómetro, Nivel láser, Multímetro..." 
                />
              </div>
            </div>
          </div>

          <!-- Severidad Técnica -->
          <div class="form-group-custom">
            <label>Severidad:</label>
            <div class="severity-chips-group">
              <button 
                v-for="sev in ['MENOR', 'MODERADA', 'MAYOR', 'CRÍTICA']" 
                :key="sev"
                type="button"
                class="sev-choice-chip"
                :class="[`chip-${sev.toLowerCase()}`, { selected: obsForm.severity === sev }]"
                @click="obsForm.severity = sev"
              >
                {{ sev }}
              </button>
            </div>
          </div>

          <!-- Descripción Adicional de Ubicación -->
          <div class="form-group-custom">
            <label>Descripción adicional de ubicación:</label>
            <textarea 
              v-model="obsForm.locationDetails" 
              rows="2" 
              class="field-input textarea" 
              placeholder="Ej.: Fisura diagonal visible cerca del vano, lado este a 1.20m sobre el N.P.T."
            ></textarea>
          </div>

          <!-- Fijar en Plano (Selector interactivo) -->
          <div class="plan-pin-picker-card">
            <div class="picker-card-header">
              <div class="picker-icon-title">
                <span class="picker-icon">🎯</span>
                <div class="picker-texts">
                  <strong>Ubicación en plano</strong>
                  <p v-if="pendingCoordinates">
                    Punto registrado: ({{ pendingCoordinates.x }}%, {{ pendingCoordinates.y }}%) en <em>{{ activeSelectedArea }}</em>
                  </p>
                  <p v-else>Seleccionar el punto exacto sobre el plano de la unidad.</p>
                </div>
              </div>
              <span v-if="pendingCoordinates" class="picker-badge-success">✓ Fijado</span>
            </div>

            <button type="button" class="btn-pick-on-plan-trigger" @click="startPickPinFromModal">
              <span class="pin-symbol">📍</span>
              <span>{{ pendingCoordinates ? 'Cambiar punto en el plano' : 'Fijar en plano' }}</span>
            </button>
          </div>

          <!-- Detalle Técnico Adicional -->
          <div class="form-group-custom">
            <label>Detalle Técnico Adicional:</label>
            <textarea 
              v-model="obsForm.description" 
              rows="2" 
              class="field-input textarea" 
              placeholder="Describa tolerancias milimétricas, desniveles, materiales afectados o recomendaciones de resane..."
            ></textarea>
          </div>

          <!-- Captura de Fotos con Cámara de Teléfono/Tablet o Subida de Archivo -->
          <div class="camera-capture-section">
            <label class="section-label">Evidencia Fotográfica (Cámara o Galería):</label>
            
            <div class="camera-actions-row">
              <!-- Botón Nativo de Cámara Móvil/Tablet -->
              <input 
                type="file" 
                id="cameraInput" 
                accept="image/*" 
                capture="environment" 
                class="hidden-input" 
                @change="handlePhotoCaptured"
              />
              <label for="cameraInput" class="btn-camera-trigger">
                <span class="cam-icon">📷</span>
                <span>Tomar Foto con Cámara</span>
              </label>

              <!-- Botón Subir desde Galería/Archivos -->
              <input 
                type="file" 
                id="galleryInput" 
                accept="image/*" 
                class="hidden-input" 
                @change="handlePhotoCaptured"
              />
              <label for="galleryInput" class="btn-gallery-trigger">
                <span class="cam-icon">🖼️</span>
                <span>Subir de Galería</span>
              </label>
            </div>

            <!-- Miniaturas de Fotos Capturadas con Hash SHA-256 -->
            <div v-if="capturedPhotosList.length > 0" class="captured-photos-preview">
              <div v-for="(photo, pIdx) in capturedPhotosList" :key="pIdx" class="captured-photo-badge">
                <img :src="photo.dataUrl" alt="Foto tomada" class="photo-thumbnail" />
                <div class="photo-info-column">
                  <span class="photo-name">{{ photo.fileName }}</span>
                  <code class="photo-sha-pill">SHA-256: {{ photo.sha256.substring(0, 14) }}...</code>
                </div>
                <button type="button" class="btn-remove-photo" @click="removeCapturedPhoto(pIdx)">✕</button>
              </div>
            </div>
            <p v-else class="camera-hint">Se generará automáticamente el Hash criptográfico SHA-256 de cada foto para el informe técnico legal.</p>
          </div>

          <!-- Nota de recomendación técnica al final -->
          <div class="obs-recommendation-note">
            <span class="note-icon">💡</span>
            <p><strong>Nota:</strong> Se recomienda registrar longitud estimada, profundidad e indicar si compromete vanos de puertas o ventanas.</p>
          </div>

          <div class="modal-obs-footer">
            <button type="button" class="btn-cancel-modal" @click="showObsModal = false">Cancelar</button>
            <button type="submit" class="btn-save-modal">
              Guardar Observación
            </button>
          </div>

        </form>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { TYPICAL_DEFECTS_CATALOG } from '~/utils/checklist-defects-catalog'

definePageMeta({
  layout: false // Sin layout exterior: ocupa el 100% de la ventana de la tablet o teléfono
})

const { role, name: currentUserName } = useAuthUser()
const router = useRouter()
const supabase = useSupabaseClient()

// Estados de Navegación Principal
const activeBottomTab = ref<'inspections' | 'plans' | 'reports' | 'sync' | 'profile'>('inspections')
const showProfileModal = ref(false)
const showUploadPlanModal = ref(false)
const isOnline = ref(true)
const isSyncing = ref(false)
const syncPercentage = ref(100)

const toggleNetworkStatus = () => {
  isOnline.value = !isOnline.value
}

// ==============================================================
// 1. LISTA DE INSPECCIONES
// ==============================================================
interface InspectionModel {
  id: string
  project: string
  unit: string
  building: string
  floor: string
  client: string
  scheduledDate: string
  status: 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED' | 'DRAFT'
  statusLabel: string
  progress: number
  thumbBg: string
  thumbIcon: string
}

const inspectionsList = ref<InspectionModel[]>([
  {
    id: '55555555-0000-0000-0000-000000000002',
    project: 'Condominio Los Cedros',
    unit: 'Dpto 305',
    building: 'Torre B',
    floor: '3',
    client: 'Inmobiliaria Panorama / María Torres',
    scheduledDate: '23 Oct. 2026',
    status: 'IN_PROGRESS',
    statusLabel: 'En progreso',
    progress: 68,
    thumbBg: '#0d2238',
    thumbIcon: '🏢'
  },
  {
    id: '55555555-0000-0000-0000-000000000001',
    project: 'Edificio Miramar',
    unit: 'Dpto 201',
    building: 'Torre A',
    floor: '2',
    client: 'Carlos Mendoza',
    scheduledDate: '24 Oct. 2026',
    status: 'SCHEDULED',
    statusLabel: 'Pendiente',
    progress: 20,
    thumbBg: '#1e242d',
    thumbIcon: '🌊'
  },
  {
    id: '55555555-0000-0000-0000-000000000003',
    project: 'Torres del Sol',
    unit: 'Dpto 1102',
    building: 'Torre Única',
    floor: '11',
    client: 'Jorge Ramírez',
    scheduledDate: '20 Oct. 2026',
    status: 'COMPLETED',
    statusLabel: 'Cerrada / Conforme',
    progress: 100,
    thumbBg: '#0f291e',
    thumbIcon: '☀️'
  }
])

const selectedInspection = ref<InspectionModel | null>(null)
const searchQuery = ref('')
const selectedFilter = ref('ALL')

const inspectionFilters = [
  { label: 'Todos', value: 'ALL' },
  { label: 'Pendientes', value: 'SCHEDULED' },
  { label: 'En Progreso', value: 'IN_PROGRESS' },
  { label: 'Cerradas', value: 'COMPLETED' }
]

const countInspections = (filterVal: string) => {
  if (filterVal === 'ALL') return inspectionsList.value.length
  return inspectionsList.value.filter(i => i.status === filterVal).length
}

const filteredInspections = computed(() => {
  return inspectionsList.value.filter(i => {
    const matchesFilter = selectedFilter.value === 'ALL' || i.status === selectedFilter.value
    const q = searchQuery.value.toLowerCase().trim()
    const matchesQuery = !q || 
      i.project.toLowerCase().includes(q) || 
      i.unit.toLowerCase().includes(q) || 
      i.client.toLowerCase().includes(q)
    return matchesFilter && matchesQuery
  })
})

const openInspectionDetail = (insp: InspectionModel) => {
  selectedInspection.value = insp
  detailSubTab.value = 'summary'
}

const closeInspectionDetail = () => {
  selectedInspection.value = null
}

// ==============================================================
// 2. DETALLE DE INSPECCIÓN: PESTAÑAS (Resumen, Plano, Checklist, Obs)
// ==============================================================
const detailSubTab = ref<'summary' | 'plan' | 'checklist' | 'observations'>('summary')

// Ambientes de la Unidad y Normalización Canónica (Alineada al checklist.md)
type CanonicalChecklistArea = 
  | 'Sala / Comedor'
  | 'Cocina'
  | 'Baño Principal'
  | 'Dormitorio'
  | 'Lavandería'
  | 'Balcón'

interface AreaItem {
  id: string
  name: string
  canonicalArea: CanonicalChecklistArea
  cssClass: string
  isEditing?: boolean
}

/**
 * Función de normalización canónica inteligente:
 * Mapea cualquier variación léxica o de plano (ej: "Dormitorio 1", "Bed 2", "Kitchenette",
 * "Living Area", "Baño de visitas", "Patio", "Closet") al ambiente canónico del checklist.md
 * sin crear categorías inexistentes en la matriz de inspección.
 */
const normalizeToCanonicalArea = (rawName: string): CanonicalChecklistArea => {
  const norm = rawName.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim()

  // 1. Cocina / Kitchenette
  if (norm.includes('cocina') || norm.includes('kitchen') || norm.includes('kitchenette') || norm.includes('repostero')) {
    return 'Cocina'
  }

  // 2. Baños (Principal, Visitas, Secundario, Bath, Toilette)
  if (norm.includes('bano') || norm.includes('bath') || norm.includes('toilet') || norm.includes('ss.hh') || norm.includes('sshh') || norm.includes('aseo')) {
    return 'Baño Principal'
  }

  // 3. Dormitorios y Clósets (Dormitorio 1, 2, Principal, Master, Bedroom, Bed, Cuarto, Closet)
  if (norm.includes('dorm') || norm.includes('habitaci') || norm.includes('bed') || norm.includes('cuarto') || norm.includes('closet') || norm.includes('vestidor')) {
    return 'Dormitorio'
  }

  // 4. Lavandería y Patio de servicio (Laundry, Lavand, Servicio, Ropas)
  if (norm.includes('lavand') || norm.includes('laundry') || norm.includes('servicio') || norm.includes('tendal')) {
    return 'Lavandería'
  }

  // 5. Balcón / Terraza (Balcony, Terraza, Balcon, Patio exterior)
  if (norm.includes('balcon') || norm.includes('terraza') || norm.includes('balcony') || norm.includes('patio')) {
    return 'Balcón'
  }

  // 6. Por defecto: Sala / Comedor (Living, Dining, Comedor, Estar, Hall, Ingreso, Entry)
  return 'Sala / Comedor'
}

const inspectionAreas = ref<AreaItem[]>([
  { id: 'a-1', name: 'Living Area', canonicalArea: 'Sala / Comedor', cssClass: 'room-living' },
  { id: 'a-2', name: 'Kitchen', canonicalArea: 'Cocina', cssClass: 'room-kitchen' },
  { id: 'a-3', name: 'Dining Area', canonicalArea: 'Sala / Comedor', cssClass: 'room-living' },
  { id: 'a-4', name: 'Bedroom', canonicalArea: 'Dormitorio', cssClass: 'room-bed-main' },
  { id: 'a-5', name: 'Bath', canonicalArea: 'Baño Principal', cssClass: 'room-bath-main' },
  { id: 'a-6', name: 'Closet', canonicalArea: 'Lavandería', cssClass: 'room-custom' },
  { id: 'a-7', name: 'Patio', canonicalArea: 'Balcón', cssClass: 'room-balcony' },
  { id: 'a-8', name: 'Entry', canonicalArea: 'Sala / Comedor', cssClass: 'room-living' }
])

// Helper para obtener el icono representativo del tipo de ambiente
const getAreaIcon = (canonical: CanonicalChecklistArea): string => {
  switch (canonical) {
    case 'Sala / Comedor': return '🛋️'
    case 'Cocina': return '🍳'
    case 'Baño Principal': return '🚿'
    case 'Dormitorio': return '🛏️'
    case 'Lavandería': return '🧺'
    case 'Balcón': return '🌿'
    default: return '📍'
  }
}

// Imagen de plano real vinculada a la inspección actual
const activePlanImageUrl = ref<string>('/demo-floorplan.png')

const activeSelectedArea = ref('Living Area')
const newAreaNameInput = ref('')
const showAreasSidebar = ref(false)

// Modal de Recategorización y Renombrado de Ambiente
const showRecategorizeModal = ref(false)
const editingAreaTarget = ref<AreaItem | null>(null)
const editingAreaForm = ref<{ name: string; canonicalArea: CanonicalChecklistArea }>({
  name: '',
  canonicalArea: 'Sala / Comedor'
})

const openRecategorizeModal = (area: AreaItem) => {
  editingAreaTarget.value = area
  editingAreaForm.value = {
    name: area.name,
    canonicalArea: area.canonicalArea
  }
  showRecategorizeModal.value = true
}

const saveRecategorizedArea = () => {
  if (editingAreaTarget.value && editingAreaForm.value.name.trim()) {
    const oldName = editingAreaTarget.value.name
    const newName = editingAreaForm.value.name.trim()
    const newCanonical = editingAreaForm.value.canonicalArea

    editingAreaTarget.value.name = newName
    editingAreaTarget.value.canonicalArea = newCanonical

    // Si el ambiente activo era este, actualizar la referencia activa
    if (activeSelectedArea.value === oldName) {
      activeSelectedArea.value = newName
    }

    // Actualizar también en currentArchAreas si existe
    const archMatch = currentArchAreas.value.find(a => a.id === editingAreaTarget.value?.id || a.name === oldName)
    if (archMatch) {
      archMatch.name = newName
      archMatch.canonicalArea = newCanonical
    }

    // Actualizar marcadores que estuvieran en este ambiente
    inspectionMarkers.value.forEach(m => {
      if (m.area === oldName) {
        m.area = newName
      }
    })

    showRecategorizeModal.value = false
  }
}

const toggleAreaRename = (idx: number) => {
  if (inspectionAreas.value[idx]) {
    inspectionAreas.value[idx].isEditing = !inspectionAreas.value[idx].isEditing
  }
}

const removeAreaFromPlan = (idx: number) => {
  if (inspectionAreas.value.length > 1) {
    inspectionAreas.value.splice(idx, 1)
  }
}

const addNewAreaToInspection = () => {
  const name = newAreaNameInput.value.trim()
  if (name && !inspectionAreas.value.some(a => a.name.toLowerCase() === name.toLowerCase())) {
    const canonical = normalizeToCanonicalArea(name)
    inspectionAreas.value.push({
      id: `area-${Date.now()}`,
      name,
      canonicalArea: canonical,
      cssClass: 'room-custom'
    })
    activeSelectedArea.value = name
    newAreaNameInput.value = ''
  }
}

// ==============================================================
// 3. PINES SOBRE PLANO INTERACTIVO
// ==============================================================
interface MarkerItem {
  id: string
  x: number
  y: number
  title: string
  area: string
  severity: string
  obsId?: string
}

const inspectionMarkers = ref<MarkerItem[]>([
  { id: 'm-1', x: 28, y: 38, title: 'Fisura capilar en muro norte', area: 'Sala / Comedor', severity: 'MENOR', obsId: 'obs-01' },
  { id: 'm-2', x: 55, y: 24, title: 'Junta de cerámico desalineada', area: 'Cocina', severity: 'MODERADA', obsId: 'obs-02' },
  { id: 'm-3', x: 75, y: 62, title: 'Falta cordón de silicona antihongos', area: 'Baño Principal', severity: 'MODERADA', obsId: 'obs-03' }
])

const selectedMarkerId = ref<string | null>(null)
const movingPinIndex = ref<number | null>(null)
const pendingCoordinates = ref<{ x: number; y: number } | null>(null)
const isPickingPinForModal = ref(false)

const selectedMarkerItem = computed(() => {
  return inspectionMarkers.value.find(m => m.id === selectedMarkerId.value)
})

const getMarkerIndex = (markerId: string) => {
  return inspectionMarkers.value.findIndex(m => m.id === markerId)
}

const selectAreaFromPlan = (event: MouseEvent, areaName: string) => {
  activeSelectedArea.value = areaName
  
  // Capturar coordenadas exactas del toque
  const canvas = document.querySelector('.blueprint-canvas') as HTMLElement
  if (canvas) {
    const rect = canvas.getBoundingClientRect()
    const x = Math.round(((event.clientX - rect.left) / rect.width) * 1000) / 10
    const y = Math.round(((event.clientY - rect.top) / rect.height) * 1000) / 10

    if (isPickingPinForModal.value) {
      pendingCoordinates.value = { x, y }
      isPickingPinForModal.value = false
      showObsModal.value = true
      return
    }

    if (movingPinIndex.value !== null && inspectionMarkers.value[movingPinIndex.value]) {
      inspectionMarkers.value[movingPinIndex.value].x = x
      inspectionMarkers.value[movingPinIndex.value].y = y
      inspectionMarkers.value[movingPinIndex.value].area = areaName
      selectedMarkerId.value = inspectionMarkers.value[movingPinIndex.value].id
      movingPinIndex.value = null
      return
    }

    openObservationModal({ x, y })
  }
}

const handlePlanCanvasClick = (event: MouseEvent) => {
  const canvas = (event.currentTarget as HTMLElement).querySelector('.blueprint-canvas') as HTMLElement || event.currentTarget as HTMLElement
  const rect = canvas.getBoundingClientRect()
  const x = Math.round(((event.clientX - rect.left) / rect.width) * 1000) / 10
  const y = Math.round(((event.clientY - rect.top) / rect.height) * 1000) / 10

  if (isPickingPinForModal.value) {
    pendingCoordinates.value = { x, y }
    isPickingPinForModal.value = false
    showObsModal.value = true
    return
  }

  if (movingPinIndex.value !== null && inspectionMarkers.value[movingPinIndex.value]) {
    inspectionMarkers.value[movingPinIndex.value].x = x
    inspectionMarkers.value[movingPinIndex.value].y = y
    selectedMarkerId.value = inspectionMarkers.value[movingPinIndex.value].id
    movingPinIndex.value = null
    return
  }

  openObservationModal({ x, y })
}

const cancelPickPinForModal = () => {
  isPickingPinForModal.value = false
  showObsModal.value = true
}

const selectMarkerOnPlan = (marker: MarkerItem, idx: number) => {
  selectedMarkerId.value = marker.id
  activeSelectedArea.value = marker.area
}

const startPinMove = (marker: MarkerItem) => {
  const idx = inspectionMarkers.value.findIndex(m => m.id === marker.id)
  if (idx !== -1) {
    movingPinIndex.value = idx
  }
}

const cancelPinMove = () => {
  movingPinIndex.value = null
}

const deleteMarker = (markerId: string) => {
  inspectionMarkers.value = inspectionMarkers.value.filter(m => m.id !== markerId)
  selectedMarkerId.value = null
}

// ==============================================================
// 4. CHECKLIST TÉCNICA DETALLADA POR AMBIENTE
// ==============================================================
// 4. CHECKLIST JERÁRQUICO POR ESPECIALIDADES (CON REGLAS POR AMBIENTE)
// ==============================================================
interface ChecklistSubItem {
  id: string
  title: string
  specification: string
  status: 'PENDING' | 'OK' | 'OBS' | 'N/A' | 'NV'
}

interface ChecklistGroup {
  id: string
  name: string
  summary: string
  icon: string
  isExpanded: boolean
  isCompleted: boolean
  items: ChecklistSubItem[]
}

// Almacén reactivo de grupos de checklist por ambiente
const checklistGroupsStore = ref<Record<string, ChecklistGroup[]>>({})

const generateChecklistGroupsForArea = (areaName: string): ChecklistGroup[] => {
  const norm = areaName.toLowerCase()
  const isBathroom = norm.includes('baño') || norm.includes('bano') || norm.includes('toilette')
  const isKitchen = norm.includes('cocina') || norm.includes('kitchen')
  const isLaundry = norm.includes('lavander') || norm.includes('servicio')
  const isLiving = norm.includes('sala') || norm.includes('comedor') || norm.includes('living')
  const isBedroom = norm.includes('dormitorio') || norm.includes('habitaci') || norm.includes('cuarto')
  const isBalcony = norm.includes('balc') || norm.includes('terraza')

  const groups: ChecklistGroup[] = [
    // 1. Arquitectura y acabados (En todos los ambientes)
    {
      id: `${areaName}-g-arqui`,
      name: 'Arquitectura y acabados',
      summary: 'Muros · Pintura · Cielos rasos · Zócalos y contrazócalos',
      icon: '🎨',
      isExpanded: true,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-muros`,
          title: 'Paredes y Muros — Fisuras y verticalidad (plomo)',
          specification: 'Superficie aplomada sin microfisuras, alabeos ni pandeos en tabiquería.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-empaste-pintura`,
          title: 'Empaste y Pintura — Acabado bajo luz rasante',
          specification: 'Pintura látex homogénea sin ampollas, marcas de rodillo ni variación de tonalidad.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-cielos-rasos`,
          title: 'Cielos Rasos y Molduras — Nivelación y bruñas',
          specification: 'Techos perfectamente horizontales sin deflexión ni desprendimiento en esquinas.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-zocalos`,
          title: 'Zócalos y Contrazócalos — Adherencia y sellado',
          specification: 'Alineación continua, adherencia total al muro y sellado superior libre de poros.',
          status: 'PENDING'
        }
      ]
    },

    // 2. Pisos y revestimientos (En todos los ambientes)
    {
      id: `${areaName}-g-pisos`,
      name: 'Pisos y revestimientos',
      summary: 'Nivelación · Juntas · Fragua · Piezas dañadas',
      icon: '📐',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-nivelacion-cejas`,
          title: 'Nivelación y ausencia de cejas',
          specification: 'Desnivel máximo entre juntas menor a 1mm; sin piezas hundidas ni levantadas.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-fragua-juntas`,
          title: 'Fragua y juntas de dilatación',
          specification: 'Líneas de fragua homogéneas, llenas y libres de porosidad o fisuras.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-piezas-huecas`,
          title: 'Integridad y adherencia (golpeteo)',
          specification: 'Ausencia de piezas desportilladas, quiñadas o con sonido a hueco (sopladas).',
          status: 'PENDING'
        }
      ]
    },

    // 3. Carpintería de aluminio, vidrio y mamparas (Ventanas / mamparas)
    {
      id: `${areaName}-g-carpinteria`,
      name: 'Carpintería de aluminio, vidrio y mamparas',
      summary: 'Ventanas · Vidrios · Perfiles · Felpas · Seguros',
      icon: '🪟',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-ventanas-rieles`,
          title: 'Ventanas y Mamparas — Deslizamiento suave en rieles',
          specification: 'Apertura y cierre corredizo sin atascos con topes y cierres de arrastre funcionales.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-felpas-sellos`,
          title: 'Felpas perimetrales y hermeticidad',
          specification: 'Hermeticidad frente a viento/polvo y sellos de poliuretano en encuentros exteriores.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-cristales-vidrios`,
          title: 'Cristales — Ausencia de rayaduras y quiñes',
          specification: 'Vidrios templados o laminados limpios sin rayaduras de obra ni burbujas internas.',
          status: 'PENDING'
        }
      ]
    },

    // 4. Instalaciones eléctricas (En todos los ambientes)
    {
      id: `${areaName}-g-electricas`,
      name: 'Instalaciones eléctricas',
      summary: 'Tomacorrientes · Interruptores · Puntos de luz y pruebas de tensión',
      icon: '⚡',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-tomacorrientes-tierra`,
          title: 'Tomacorrientes — Pruebas de 220V y polaridad',
          specification: 'Placas firmes, alineadas y con continuidad de puesta a tierra comprobada.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-interruptores-luces`,
          title: 'Interruptores y centros de iluminación',
          specification: 'Conmutadores operando sin retardo, centros de luz plomados y portalámparas seguros.',
          status: 'PENDING'
        }
      ]
    }
  ]

  // --- ESPECÍFICO DE SALA / COMEDOR: TABLERO GENERAL, PUERTA PRINCIPAL Y ALARMA CONTRAINCENDIO ---
  if (isLiving) {
    groups.push({
      id: `${areaName}-g-tablero`,
      name: 'Instalaciones eléctricas',
      summary: 'Termomagnéticos · Diferenciales de 30mA · Puesta a tierra',
      icon: '🛡️',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-tablero-tg`,
          title: 'Tablero General — Llaves termomagnéticas y disyuntor diferencial',
          specification: 'Gabinete hermético rotulado con botón de test funcional en diferencial de 30mA.',
          status: 'PENDING'
        }
      ]
    })

    groups.push({
      id: `${areaName}-g-puerta-ingreso`,
      name: 'Carpintería de madera y melamina',
      summary: 'Puerta principal de ingreso · Cerradura de seguridad y holguras',
      icon: '🚪',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-puerta-ingreso`,
          title: 'Puerta Principal de Ingreso — Cerradura de seguridad y holgura',
          specification: 'Holgura uniforme de 3mm, chapa de 3 golpes suave y anclaje firme en marco.',
          status: 'PENDING'
        }
      ]
    })

    groups.push({
      id: `${areaName}-g-seguridad-sala`,
      name: 'Seguridad y elementos complementarios',
      summary: 'Sistema contra incendios · Detector de humo y alarma',
      icon: '🧯',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-detector-humo-sala`,
          title: 'Sistema Contra Incendios — Detector de humo fotoeléctrico y alarma',
          specification: 'Sensor operativo con luz LED testigo, fijación firme en techo y libre de cobertor de obra.',
          status: 'PENDING'
        }
      ]
    })
  }

  // --- ESPECÍFICO DE COCINA: MUEBLES, GRIFERÍA Y EQUIPOS FIJOS ---
  if (isKitchen) {
    groups.push({
      id: `${areaName}-g-cocina-equipos`,
      name: 'Mobiliario, Griferías y Equipos Fijos de Cocina',
      summary: 'Granito · Melamina · Grifería · Campana · Encimera y desagüe',
      icon: '🍳',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-griferia-cocina`,
          title: 'Grifería de Cocina — Presión, mezcladora y estanqueidad',
          specification: 'Caudal y presión continua (fría/caliente) sin goteo en cartucho ni aireador.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-meson-reposteros`,
          title: 'Tablero de Granito / Cuarzo y Muebles de Melamina',
          specification: 'Sellado antihongos en zócalo, correderas telescópicas y bisagras de cierre suave.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-equipos-fijos`,
          title: 'Equipos Fijos — Campana extractora, cocina encimera y horno',
          specification: 'Tiro activo en campana extractora y encendido de hornillas de cocción.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-desague-trampa`,
          title: 'Pozuelo de Lavadero y Trampa de Desagüe (Sifón tipo P)',
          specification: 'Descarga continua sin represamiento ni filtración en empaquetaduras bajo mueble.',
          status: 'PENDING'
        }
      ]
    })
  }

  // --- ESPECÍFICO DE BAÑOS: SANITARIOS, DUCHA Y GRIFERÍAS ---
  if (isBathroom) {
    groups.push({
      id: `${areaName}-g-bano-sanitarios`,
      name: 'Instalaciones Sanitarias y Zona Húmeda',
      summary: 'Inodoro · Ducha · Mamparas · Griferías · Pendiente de sumidero',
      icon: '🚿',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-inodoro-descarga`,
          title: 'Inodoro — Fijación al piso, sello de cera y descarga eficiente',
          specification: 'Tanque regulado, pulsador de doble descarga sin fuga continua y base sellada.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-ducha-pendiente`,
          title: 'Ducha y Grifería — Mezcladora y pendiente de escorrentía',
          specification: 'Presión en regadera y pendiente hacia el sumidero comprobando que no empoza en esquinas.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-griferia-lavamanos`,
          title: 'Grifería de Lavamanos — Flexibles de acero trenzado',
          specification: 'Sellado perimetral en ovalín, sin estrangulamiento de mangueras y desagüe rápido.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-extractor-bano`,
          title: 'Ventilación Mecánica — Extractor de aire y succión',
          specification: 'Encendido sincronizado con succión activa comprobada mediante prueba de papel.',
          status: 'PENDING'
        }
      ]
    })
  }

  // --- ESPECÍFICO DE LAVANDERÍA: POZA Y PUNTOS DE LAVADORA ---
  if (isLaundry) {
    groups.push({
      id: `${areaName}-g-lavanderia-hidro`,
      name: 'Instalaciones de Lavandería y Calentamiento',
      summary: 'Poza de lavado · Llaves de lavadora · Terma y ventilación',
      icon: '🧺',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-poza-lavadero`,
          title: 'Poza de Lavandería — Fijación rígida y grifería móvil',
          specification: 'Anclaje sin cabeceos, sellado contra la pared y desagüe vertical fluido.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-puntos-lavadora`,
          title: 'Puntos de Lavadora — Válvulas esféricas y tomacorriente Schuko',
          specification: 'Llaves de corte de 1/2", desagüe vertical a 90cm y enchufe con protección de salpicaduras.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-terma-calentador`,
          title: 'Infraestructura de Terma / Calentador — Ducto de gases',
          specification: 'Llave de paso sin goteo y chimenea de evacuación con pendiente positiva exterior.',
          status: 'PENDING'
        }
      ]
    })
  }

  // --- ESPECÍFICO DE DORMITORIOS: CLÓSETS Y MELAMINA ---
  if (isBedroom) {
    groups.push({
      id: `${areaName}-g-dorm-closets`,
      name: 'Mobiliario y Clósets de Dormitorio',
      summary: 'Puertas correderas · Cajonería · Rieles · Barras de colgar',
      icon: '👔',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-closet-ropero`,
          title: 'Clósets y Roperos — Cajonería con correderas telescópicas',
          specification: 'Puertas aplomadas, barras de colgar rígidas y cantos termo-adheridos.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-puerta-interior`,
          title: 'Puerta Interior de Dormitorio — Manija y bisagras',
          specification: 'Cierre hermético con tope magnético en piso para salvaguardar el tarrajeo.',
          status: 'PENDING'
        }
      ]
    })
  }

  // --- ESPECÍFICO DE BALCÓN O TERRAZA: BARANDAS Y SUMIDEROS PLUVIALES ---
  if (isBalcony) {
    groups.push({
      id: `${areaName}-g-balcon-seguridad`,
      name: 'Estructura Exterior y Drenaje Pluvial',
      summary: 'Baranda perimetral · Cristales templados · Sumideros pluviales',
      icon: '🏙️',
      isExpanded: false,
      isCompleted: false,
      items: [
        {
          id: `${areaName}-sub-barandas-firmeza`,
          title: 'Baranda perimetral — Anclaje estructural rígido (h>=1.00m)',
          specification: 'Fijaciones de acero sin holgura ni corrosión y uniones de soldadura esmeriladas.',
          status: 'PENDING'
        },
        {
          id: `${areaName}-sub-sumidero-lluvia`,
          title: 'Sumidero de Balcón — Prueba de escorrentía hacia rejilla',
          specification: 'Pendiente continua sin charcos en esquinas de fachada.',
          status: 'PENDING'
        }
      ]
    })
  }

  // 5. Control de entrega final (En todos los ambientes)
  groups.push({
    id: `${areaName}-g-entrega-final`,
    name: 'Control de entrega final',
    summary: 'Limpieza · Daños visibles · Elementos pendientes de entrega',
    icon: '✨',
    isExpanded: false,
    isCompleted: false,
    items: [
      {
        id: `${areaName}-sub-limpieza-obra`,
        title: 'Limpieza final de obra gruesa y fina',
        specification: 'Libre de manchas de pintura, restos de cemento, silicona sobrante o cintas adhesivas.',
        status: 'PENDING'
      },
      {
        id: `${areaName}-sub-accesorios-completos`,
        title: 'Verificación de accesorios completos y operativos',
        specification: 'Tapas de tomacorrientes, perillas, topes y accesorios instalados sin faltantes.',
        status: 'PENDING'
      }
    ]
  })

  return groups
}

const currentAreaChecklistGroups = computed(() => {
  const currentArea = activeSelectedArea.value
  
  // 1. Buscar si el ambiente tiene una asignación canónica manual configurada
  const foundArea = inspectionAreas.value.find(a => a.name === currentArea)
  const canonical = foundArea ? foundArea.canonicalArea : normalizeToCanonicalArea(currentArea)
  
  const storeKey = `${currentArea}__${canonical}`
  
  if (!checklistGroupsStore.value[storeKey]) {
    checklistGroupsStore.value[storeKey] = generateChecklistGroupsForArea(canonical)
  }
  return checklistGroupsStore.value[storeKey]
})

const updateGroupCompletion = (group: ChecklistGroup) => {
  // Un grupo pasa a Revisado cuando todos sus sub-items dejan de estar en PENDING
  group.isCompleted = group.items.every(it => it.status !== 'PENDING')
}

const setSubItemStatus = (item: ChecklistSubItem, newStatus: 'OK' | 'OBS' | 'N/A' | 'NV') => {
  item.status = newStatus
  // Encontrar el grupo contenedor y actualizar su estado
  const currentGroups = currentAreaChecklistGroups.value
  const parentGroup = currentGroups.find(g => g.items.some(i => i.id === item.id))
  if (parentGroup) {
    updateGroupCompletion(parentGroup)
  }
}

const triggerObsFromChecklistSubItem = (item: ChecklistSubItem, groupName: string) => {
  setSubItemStatus(item, 'OBS')
  
  // Mapear nombre de grupo al catálogo canónico si difiere
  let targetCategory = groupName
  if (!checklistCatalog[targetCategory]) {
    const gn = groupName.toLowerCase()
    if (gn.includes('aluminio') || gn.includes('mampara') || gn.includes('ventana')) {
      targetCategory = 'Carpintería de aluminio, vidrio y mamparas'
    } else if (gn.includes('cerrajería') || gn.includes('cerradura') || gn.includes('herraje')) {
      targetCategory = 'Cerrajería y herrajes'
    } else if (gn.includes('madera') || gn.includes('melamina') || gn.includes('closet') || gn.includes('puerta')) {
      targetCategory = 'Carpintería de madera y melamina'
    } else if (gn.includes('eléctrica') || gn.includes('tablero') || gn.includes('iluminac')) {
      targetCategory = 'Instalaciones eléctricas'
    } else if (gn.includes('aparato') || gn.includes('grifería') || gn.includes('inodoro')) {
      targetCategory = 'Aparatos sanitarios y griferías'
    } else if (gn.includes('evacuación') || gn.includes('impermeabiliz') || gn.includes('sumidero') || gn.includes('drenaje')) {
      targetCategory = 'Evacuación e impermeabilización'
    } else if (gn.includes('sanitaria') || gn.includes('hidro') || gn.includes('agua') || gn.includes('desagüe')) {
      targetCategory = 'Instalaciones sanitarias'
    } else if (gn.includes('gas') || gn.includes('calentador') || gn.includes('terma')) {
      targetCategory = 'Gas y calentamiento de agua'
    } else if (gn.includes('cocina') || gn.includes('equipo') || gn.includes('electro')) {
      targetCategory = 'Equipamiento y electrodomésticos'
    } else if (gn.includes('seguridad') || gn.includes('incendio') || gn.includes('alarma') || gn.includes('baranda')) {
      targetCategory = 'Seguridad y elementos complementarios'
    } else if (gn.includes('estructura') || gn.includes('concreto')) {
      targetCategory = 'Estructuras — inspección visual'
    } else if (gn.includes('document') || gn.includes('plano') || gn.includes('especific')) {
      targetCategory = 'Documentación y correspondencia'
    } else if (gn.includes('limpieza') || gn.includes('entrega')) {
      targetCategory = 'Limpieza y entrega final'
    }
  }

  obsForm.value.category = targetCategory
  
  // Buscar la subcategoría más adecuada según el item del checklist
  const subs = checklistCatalog[targetCategory] || []
  const titleLower = item.title.toLowerCase()
  let matchedSub = subs.find(s => {
    const sWords = s.toLowerCase().split(' ')
    return sWords.some(w => w.length > 3 && titleLower.includes(w))
  })
  
  if (!matchedSub && subs.length > 0) {
    matchedSub = subs[0]
  }
  obsForm.value.subcategory = matchedSub || ''

  // Dejar el título en blanco para escribir o elegir de la lista desplegable de observaciones típicas
  obsForm.value.title = ''
  
  // Mensaje en Detalle Técnico Adicional: Indicar NO-CONFORMIDAD objetiva según criterios de inspección
  obsForm.value.description = `Hallazgo registrado en ${targetCategory} (${matchedSub || 'Componente'}): Condición observada en "${item.title}". No satisface el criterio de comprobación o requiere subsanación/evaluación técnica.`
  obsForm.value.severity = 'MODERADA'
  
  openObservationModal()
}

// ==============================================================
// 5. OBSERVACIONES CON EVIDENCIAS FOTOGRÁFICAS (CÁMARA / GALERÍA)
// ==============================================================
interface PhotoEvidence {
  fileName: string
  dataUrl: string
  sha256: string
}

interface ObservationRecord {
  id: string
  title: string
  description: string
  category: string
  subcategory?: string
  locationDetails?: string
  hasMeasurements?: boolean
  measuredValue?: string
  measurementUnit?: string
  instrumentUsed?: string
  severity: string
  area: string
  status: string
  photos: PhotoEvidence[]
}

const checklistCatalog: Record<string, string[]> = {
  'Arquitectura y acabados': [
    'Muros, tabiques y revoques',
    'Paredes y muros',
    'Tarrajeo y enlucidos',
    'Empaste y pintura',
    'Cielos rasos y bruñas',
    'Molduras y drywall',
    'Zócalos y contrazócalos'
  ],
  'Pisos y revestimientos': [
    'Porcelanato y cerámicos',
    'Pisos laminados',
    'Pisos vinílicos',
    'Juntas y alineación',
    'Fragua y encuentros',
    'Nivelación y pendientes'
  ],
  'Carpintería de madera y melamina': [
    'Puertas de madera y marcos',
    'Muebles de cocina y tableros',
    'Clósets, repisas y cajonería',
    'Puertas interiores',
    'Puerta principal y marcos'
  ],
  'Carpintería de aluminio, vidrio y mamparas': [
    'Ventanas y mamparas',
    'Cristales y vidrios',
    'Perfiles de aluminio'
  ],
  'Cerrajería y herrajes': [
    'Cerraduras y cilindros',
    'Seguros, pestillos y mecanismos de cierre',
    'Bisagras y topes'
  ],
  'Instalaciones eléctricas': [
    'Tablero general y protecciones',
    'Tomacorrientes y placas',
    'Alumbrado e interruptores'
  ],
  'Instalaciones sanitarias': [
    'Redes interiores de agua',
    'Desagües y ventilación sanitaria'
  ],
  'Aparatos sanitarios y griferías': [
    'Inodoros y accesorios',
    'Lavatorios y muebles de baño',
    'Duchas y mezcladoras',
    'Lavadero y pozas'
  ],
  'Evacuación e impermeabilización': [
    'Pendientes y empozamiento en zonas húmedas',
    'Impermeabilización de recintos sanitarios',
    'Sumideros y registros'
  ],
  'Gas y calentamiento de agua': [
    'Puntos y llaves de corte de gas',
    'Ventilación de recintos de gas',
    'Calentador o terma'
  ],
  'Ventilación y climatización': [
    'Ventilación mecánica y extractores',
    'Ductos y rejillas'
  ],
  'Equipamiento y electrodomésticos': [
    'Campana extractora',
    'Cocina o encimera',
    'Horno empotrado',
    'Terma o calentador'
  ],
  'Seguridad y elementos complementarios': [
    'Barandas y protección contra caídas',
    'Detectores y alarmas',
    'Válvulas de corte general',
    'Intercomunicador'
  ],
  'Estructuras — inspección visual': [
    'Indicios en concreto y elementos constructivos'
  ],
  'Documentación y correspondencia': [
    'Verificación contra planos y acabados'
  ],
  'Limpieza y entrega final': [
    'Limpieza profunda de obra'
  ]
}

const inspectionObservations = ref<ObservationRecord[]>([
  {
    id: 'obs-01',
    title: 'Fisura capilar en muro norte',
    description: 'Fisura diagonal de 0.4mm sobre enlucido contiguo a ventana principal.',
    category: 'Arquitectura y acabados',
    subcategory: 'Paredes y muros',
    locationDetails: 'Muro norte contiguo a ventana principal, a 1.20m NPT',
    severity: 'MENOR',
    area: 'Sala / Comedor',
    status: 'PENDIENTE',
    photos: [
      {
        fileName: 'FOTO-01-SALA.JPG',
        dataUrl: '',
        sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
      }
    ]
  },
  {
    id: 'obs-02',
    title: 'Junta de cerámico desalineada o con holgura',
    description: 'Separación mayor a 3mm en piso cerámico frente al mesón de granito.',
    category: 'Pisos y revestimientos',
    subcategory: 'Juntas y alineación',
    locationDetails: 'Piso frente al lavadero de cocina',
    severity: 'MODERADA',
    area: 'Cocina',
    status: 'PENDIENTE',
    photos: [
      {
        fileName: 'FOTO-02-COCINA.JPG',
        dataUrl: '',
        sha256: 'ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb'
      }
    ]
  },
  {
    id: 'obs-03',
    title: 'Falta cordón de silicona antihongos',
    description: 'Ausencia de cordón perimetral entre lavamanos y pared.',
    category: 'Instalaciones sanitarias',
    subcategory: 'Lavatorios y pedestales',
    locationDetails: 'Encuentro lavatorio y muro cerámico',
    severity: 'MODERADA',
    area: 'Baño Principal',
    status: 'PENDIENTE',
    photos: [
      {
        fileName: 'FOTO-03-BANO.JPG',
        dataUrl: '',
        sha256: '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a'
      }
    ]
  }
])

const showObsModal = ref(false)
const capturedPhotosList = ref<PhotoEvidence[]>([])

const obsForm = ref({
  title: '',
  description: '',
  category: 'Arquitectura y acabados',
  subcategory: 'Paredes y muros',
  locationDetails: '',
  hasMeasurements: false,
  measuredValue: '',
  measurementUnit: 'mm',
  instrumentUsed: '',
  severity: 'MODERADA'
})

const availableSubcategories = computed(() => {
  return checklistCatalog[obsForm.value.category] || []
})

// Observaciones típicas calculadas en base a la categoría y subcategoría seleccionadas
const suggestedDefectsList = computed(() => {
  const cat = obsForm.value.category
  const sub = obsForm.value.subcategory
  if (cat && sub && TYPICAL_DEFECTS_CATALOG[cat]?.[sub]) {
    return TYPICAL_DEFECTS_CATALOG[cat][sub]
  }
  // Si no hay por subcategoría exacta, combinar todas las del rubro de la categoría
  if (cat && TYPICAL_DEFECTS_CATALOG[cat]) {
    return Object.values(TYPICAL_DEFECTS_CATALOG[cat]).flat().slice(0, 10)
  }
  return []
})

const showDefectsDropdown = ref(false)

const selectDefectItem = (defectText: string) => {
  obsForm.value.title = defectText
  showDefectsDropdown.value = false
  if (!obsForm.value.description || obsForm.value.description.startsWith('No-conformidad detectada')) {
    obsForm.value.description = `Hallazgo de no-conformidad en ${obsForm.value.category} (${obsForm.value.subcategory}): ${defectText}. Requiere resane, calibración o sustitución por el contratista previo al acta final.`
  }
}

const onDefectInputChanged = () => {
  // Si el usuario escribe una coincidencia exacta de sugerencias, actualizar el detalle si corresponde
  const matching = suggestedDefectsList.value.find(d => d.toLowerCase() === obsForm.value.title.trim().toLowerCase())
  if (matching && (!obsForm.value.description || obsForm.value.description.startsWith('No-conformidad detectada'))) {
    obsForm.value.description = `Hallazgo de no-conformidad en ${obsForm.value.category} (${obsForm.value.subcategory}): ${matching}. Requiere resane, calibración o sustitución por el contratista previo al acta final.`
  }
}

const onObsCategoryChange = () => {
  const subs = checklistCatalog[obsForm.value.category]
  if (subs && subs.length > 0) {
    obsForm.value.subcategory = subs[0]
  } else {
    obsForm.value.subcategory = ''
  }
  showDefectsDropdown.value = false
}

const startPickPinFromModal = () => {
  isPickingPinForModal.value = true
  showObsModal.value = false
  detailSubTab.value = 'plan'
}

const openObservationModal = (coords?: { x: number; y: number }) => {
  if (coords) {
    pendingCoordinates.value = coords
  } else if (!pendingCoordinates.value) {
    pendingCoordinates.value = {
      x: 35 + Math.round(Math.random() * 30),
      y: 30 + Math.round(Math.random() * 30)
    }
  }
  capturedPhotosList.value = []
  showObsModal.value = true
}

const handlePhotoCaptured = async (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    const file = target.files[0]
    
    // Leer imagen como base64
    const reader = new FileReader()
    reader.onload = async (e) => {
      const dataUrl = e.target?.result as string
      
      // Calcular hash SHA-256 local
      const arrayBuffer = await file.arrayBuffer()
      const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer)
      const hashArray = Array.from(new Uint8Array(hashBuffer))
      const sha256 = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')

      capturedPhotosList.value.push({
        fileName: file.name || `FOTO-${Date.now().toString().slice(-4)}.JPG`,
        dataUrl,
        sha256
      })
    }
    reader.readAsDataURL(file)
  }
}

const removeCapturedPhoto = (index: number) => {
  capturedPhotosList.value.splice(index, 1)
}

const saveObservationWithPhoto = () => {
  if (!obsForm.value.title) return

  const newObsId = `obs-${Date.now()}`
  const coords = pendingCoordinates.value || {
    x: 40 + Math.round(Math.random() * 20),
    y: 35 + Math.round(Math.random() * 25)
  }

  // Si no se tomó foto física en la demo, generar una evidencia fotográfica con hash verificado
  const photos = capturedPhotosList.value.length > 0 
    ? [...capturedPhotosList.value] 
    : [
        {
          fileName: `EVIDENCIA-${Date.now().toString().slice(-6)}.JPG`,
          dataUrl: '',
          sha256: Array.from({ length: 64 }, () => Math.floor(Math.random() * 16).toString(16)).join('')
        }
      ]

  // 1. Agregar a Observaciones
  inspectionObservations.value.unshift({
    id: newObsId,
    title: obsForm.value.title,
    description: obsForm.value.description,
    category: obsForm.value.category,
    subcategory: obsForm.value.subcategory,
    locationDetails: obsForm.value.locationDetails,
    hasMeasurements: obsForm.value.hasMeasurements,
    measuredValue: obsForm.value.hasMeasurements ? obsForm.value.measuredValue : '',
    measurementUnit: obsForm.value.hasMeasurements ? obsForm.value.measurementUnit : '',
    instrumentUsed: obsForm.value.hasMeasurements ? obsForm.value.instrumentUsed : '',
    severity: obsForm.value.severity,
    area: activeSelectedArea.value,
    status: 'PENDIENTE',
    photos
  })

  // 2. Colocar Pin en el Plano
  inspectionMarkers.value.push({
    id: `m-${Date.now()}`,
    x: coords.x,
    y: coords.y,
    title: obsForm.value.title,
    area: activeSelectedArea.value,
    severity: obsForm.value.severity,
    obsId: newObsId
  })

  // 3. Registrar en cola Outbox para sincronización
  pendingSyncItems.value.push({
    id: newObsId,
    type: 'OBSERVATION',
    title: obsForm.value.title,
    sha256: photos[0]?.sha256 || ''
  })

  // Reset y cerrar modal
  obsForm.value.title = ''
  obsForm.value.description = ''
  obsForm.value.locationDetails = ''
  obsForm.value.hasMeasurements = false
  obsForm.value.measuredValue = ''
  obsForm.value.measurementUnit = 'mm'
  obsForm.value.instrumentUsed = ''
  capturedPhotosList.value = []
  pendingCoordinates.value = null
  showObsModal.value = false
}

const deleteObservationItem = (obsId: string) => {
  inspectionObservations.value = inspectionObservations.value.filter(o => o.id !== obsId)
  inspectionMarkers.value = inspectionMarkers.value.filter(m => m.obsId !== obsId)
}

// ==============================================================
// 6. MOTOR DE SINCRONIZACIÓN OFFLINE / CONFLICTOS
// ==============================================================
interface SyncPendingItem {
  id: string
  type: string
  title: string
  sha256: string
}

const pendingSyncItems = ref<SyncPendingItem[]>([
  { id: 'sync-1', type: 'PHOTO', title: 'Evidencia Fotográfica Muro Norte', sha256: 'e3b0c44298fc1c14' },
  { id: 'sync-2', type: 'OBSERVATION', title: 'Defecto en junta cerámico cocina', sha256: 'ca978112ca1bbdca' }
])

const runSyncCycle = async () => {
  if (!isOnline.value) {
    alert('Modo sin conexión. Conéctese a una red WiFi para sincronizar con la nube.')
    return
  }

  isSyncing.value = true
  syncPercentage.value = 45

  setTimeout(() => {
    syncPercentage.value = 85
    setTimeout(() => {
      syncPercentage.value = 100
      pendingSyncItems.value = []
      isSyncing.value = false
    }, 600)
  }, 700)
}

// ==============================================================
// 7. ARQUITECTURA, PLANOS Y GESTIÓN DE ÁREAS (PESTAÑA ARQUITECTURA)
// ==============================================================
const selectedArchUnit = ref('55555555-0000-0000-0000-000000000002')
const newArchAreaInput = ref('')
const uploadedArchFileName = ref('')
const currentArchPlan = ref({
  fileName: 'plano_arquitectura_dpto_305.pdf',
  sha256: 'a9b8c7d6e5f4a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c3d2e1f0',
  type: 'PDF Vectorial'
})

const currentArchAreas = ref([
  { id: 'arch-1', name: 'Sala / Comedor', cssClass: 'room-living', isEditing: false },
  { id: 'arch-2', name: 'Cocina', cssClass: 'room-kitchen', isEditing: false },
  { id: 'arch-3', name: 'Dormitorio Principal', cssClass: 'room-bed-main', isEditing: false },
  { id: 'arch-4', name: 'Baño Principal', cssClass: 'room-bath-main', isEditing: false },
  { id: 'arch-5', name: 'Balcón', cssClass: 'room-balcony', isEditing: false },
  { id: 'arch-6', name: 'Lavandería', cssClass: 'room-custom', isEditing: false }
])

const onArchUnitChange = () => {
  const found = inspectionsList.value.find(i => i.id === selectedArchUnit.value)
  if (found) {
    currentArchPlan.value.fileName = `plano_arquitectura_${found.unit.toLowerCase().replace(/\s+/g, '_')}.pdf`
  }
}

const addArchArea = () => {
  const name = newArchAreaInput.value.trim()
  if (name && !currentArchAreas.value.some(a => a.name.toLowerCase() === name.toLowerCase())) {
    const canonical = normalizeToCanonicalArea(name)
    currentArchAreas.value.push({
      id: `arch-${Date.now()}`,
      name,
      canonicalArea: canonical,
      cssClass: 'room-custom',
      isEditing: false
    })
    // Sincronizar también con inspectionAreas
    inspectionAreas.value.push({
      id: `area-${Date.now()}`,
      name,
      canonicalArea: canonical,
      cssClass: 'room-custom'
    })
    newArchAreaInput.value = ''
  }
}

const removeArchArea = (index: number) => {
  if (currentArchAreas.value.length > 1) {
    const removed = currentArchAreas.value.splice(index, 1)[0]
    inspectionAreas.value = inspectionAreas.value.filter(a => a.name !== removed.name)
  }
}

const uploadedArchFileUrl = ref<string>('')

const handleArchFileUpload = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    const file = target.files[0]
    uploadedArchFileName.value = file.name
    // Crear URL local en memoria para renderizar la imagen real de inmediato en el visor
    uploadedArchFileUrl.value = URL.createObjectURL(file)
  }
}

const saveUploadedArchPlan = () => {
  if (uploadedArchFileName.value) {
    currentArchPlan.value.fileName = uploadedArchFileName.value
    currentArchPlan.value.sha256 = '8f4b23c9e1a76d54029b8c173ae59d04bc7a61d8ef31b9c240a5e81d76ca23e1'
    if (uploadedArchFileUrl.value) {
      activePlanImageUrl.value = uploadedArchFileUrl.value
    }
    showUploadPlanModal.value = false
    alert(`Plano "${uploadedArchFileName.value}" vinculado correctamente a la unidad para la inspección.`)
  }
}

// ==============================================================
// 8. INFORMES & ACTAS TÉCNICAS (PESTAÑA INFORMES)
// ==============================================================
interface AppReportItem {
  id: string
  code: string
  unit: string
  project: string
  client: string
  inspector: string
  date: string
  obsCount: number
  isSigned: boolean
}

const reportsList = ref<AppReportItem[]>([
  {
    id: '55555555-0000-0000-0000-000000000002',
    code: 'ACTA-2026-CEDROS-305',
    unit: 'Dpto 305 (Torre B)',
    project: 'Condominio Los Cedros',
    client: 'María Torres',
    inspector: 'Arq. Roberto Silva',
    date: '23 oct 2026',
    obsCount: 5,
    isSigned: false
  },
  {
    id: '55555555-0000-0000-0000-000000000001',
    code: 'ACTA-2026-MIRAMAR-201',
    unit: 'Dpto 201 (Torre A)',
    project: 'Edificio Miramar',
    client: 'Carlos Mendoza',
    inspector: 'Arq. Roberto Silva',
    date: '24 oct 2026',
    obsCount: 3,
    isSigned: true
  },
  {
    id: '55555555-0000-0000-0000-000000000003',
    code: 'ACTA-2026-SOL-1102',
    unit: 'Dpto 1102 (Torre Única)',
    project: 'Torres del Sol',
    client: 'Jorge Ramírez',
    inspector: 'Arq. Carlos Vargas',
    date: '20 oct 2026',
    obsCount: 2,
    isSigned: true
  }
])

const signReportOnline = (rep: AppReportItem) => {
  rep.isSigned = true
  alert(`✓ Acta ${rep.code} firmada digitalmente con éxito mediante credencial técnica.`)
}

// ==============================================================
// 9. CIERRE DE SESIÓN
// ==============================================================
const handleAppLogout = async () => {
  await supabase.auth.signOut()
  router.push('/login')
}
</script>

<style scoped>
/* BASE VIEWPORT */
.openinspection-viewport {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  background: #090d13;
  color: #fff;
  overflow: hidden;
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
}

/* 1. TOP BAR */
.app-top-bar {
  height: 52px;
  background: #101620;
  border-bottom: 1px solid #1e2838;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 18px;
  flex-shrink: 0;
}
.top-bar-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.brand-badge-mini {
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 800;
  font-size: 0.95rem;
  letter-spacing: -0.3px;
}
.brand-name-bold {
  background: linear-gradient(90deg, #58a6ff, #008080);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.mode-tag {
  background: rgba(255, 255, 255, 0.06);
  color: #8b949e;
  font-size: 0.7rem;
  padding: 2px 7px;
  border-radius: 4px;
}
.network-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 12px;
  border-radius: 20px;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.2s ease;
}
.network-pill.is-online {
  background: rgba(46, 160, 67, 0.15);
  border-color: rgba(46, 160, 67, 0.3);
  color: #3fb950;
}
.network-pill.is-offline {
  background: rgba(255, 171, 0, 0.15);
  border-color: rgba(255, 171, 0, 0.3);
  color: #ffab00;
}
.network-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: currentColor;
}
.top-bar-right {
  display: flex;
  align-items: center;
  gap: 10px;
}
.badge-pending-sync {
  background: rgba(255, 171, 0, 0.2);
  color: #ffab00;
  font-size: 0.72rem;
  font-weight: bold;
  padding: 3px 8px;
  border-radius: 12px;
  cursor: pointer;
}
.user-pill-mini-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  background: #161f2e;
  border: 1px solid #24354a;
  padding: 4px 10px;
  border-radius: 14px;
  font-size: 0.75rem;
  color: #c9d1d9;
  cursor: pointer;
  transition: all 0.2s ease;
}
.user-pill-mini-btn:hover, .user-pill-mini-btn.active {
  background: #1c2c41;
  border-color: #58a6ff;
  color: #fff;
}
.user-pill-mini {
  display: flex;
  align-items: center;
  gap: 6px;
  background: #161f2e;
  padding: 4px 10px;
  border-radius: 14px;
  font-size: 0.75rem;
  color: #c9d1d9;
}

/* MAIN CONTENT */
.app-main-content {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* ============================================================== */
/* VISTA 1: LISTA DE MIS INSPECCIONES                            */
/* ============================================================== */
.view-inspections-list {
  flex: 1;
  overflow-y: auto;
  padding: 22px 28px;
}
.list-page-header {
  margin-bottom: 20px;
}
.list-title-group h2 {
  margin: 0 0 4px 0;
  font-size: 1.5rem;
  color: #fff;
}
.list-title-group p {
  margin: 0 0 16px 0;
  color: #8b949e;
  font-size: 0.88rem;
}
.search-and-filters {
  display: flex;
  gap: 16px;
  align-items: center;
  flex-wrap: wrap;
}
.search-input-box {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #131b26;
  border: 1px solid #212c3d;
  padding: 8px 14px;
  border-radius: 10px;
  width: 320px;
}
.search-field {
  background: transparent;
  border: none;
  color: #fff;
  font-size: 0.85rem;
  width: 100%;
}
.search-field:focus { outline: none; }
.filter-chips-row {
  display: flex;
  gap: 8px;
}
.filter-chip-btn {
  background: #131b26;
  border: 1px solid #212c3d;
  color: #8b949e;
  padding: 7px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s ease;
}
.filter-chip-btn.active {
  background: #003366;
  border-color: #58a6ff;
  color: #fff;
}
.chip-count {
  background: rgba(255, 255, 255, 0.1);
  padding: 1px 6px;
  border-radius: 10px;
  font-size: 0.7rem;
}

/* Tarjetas de Inspección */
.inspections-cards-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 14px;
}
.inspection-card-item {
  background: #131b26;
  border: 1px solid #212c3d;
  border-radius: 12px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 18px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.inspection-card-item:hover {
  background: #162334;
  border-color: #388bfd;
  transform: translateY(-1px);
}
.card-thumb-box {
  width: 60px;
  height: 60px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.8rem;
}
.card-body-column {
  flex: 1;
  min-width: 0;
}
.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}
.card-project-title {
  margin: 0;
  font-size: 1.1rem;
  color: #fff;
}
.status-pill {
  font-size: 0.72rem;
  font-weight: 700;
  padding: 3px 10px;
  border-radius: 12px;
}
.pill-in_progress { background: rgba(0, 128, 128, 0.2); color: #00a896; border: 1px solid #00a896; }
.pill-scheduled { background: rgba(255, 171, 0, 0.2); color: #ffab00; border: 1px solid #ffab00; }
.pill-completed { background: rgba(46, 160, 67, 0.2); color: #3fb950; border: 1px solid #3fb950; }

.card-unit-text {
  margin: 0 0 2px 0;
  font-size: 0.9rem;
  color: #c9d1d9;
}
.card-client-text {
  margin: 0 0 10px 0;
  font-size: 0.8rem;
  color: #8b949e;
}
.card-footer-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.78rem;
  color: #8b949e;
}
.progress-container {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 140px;
}
.progress-bar-bg {
  flex: 1;
  height: 6px;
  background: #212c3d;
  border-radius: 3px;
  overflow: hidden;
}
.progress-bar-fill {
  height: 100%;
  background: #008080;
  border-radius: 3px;
}
.progress-text {
  font-weight: bold;
  color: #58a6ff;
  font-size: 0.75rem;
}
.card-arrow-column {
  font-size: 1.8rem;
  color: #485466;
}

/* ============================================================== */
/* VISTA 2: DETALLE DE INSPECCIÓN CON 4 PESTAÑAS                 */
/* ============================================================== */
.view-inspection-detail {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.inspection-sub-header {
  height: 60px;
  background: #101620;
  border-bottom: 1px solid #1e2838;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 18px;
  flex-shrink: 0;
  gap: 12px;
}
.sub-header-left {
  display: flex;
  align-items: center;
  gap: 14px;
}
.btn-back-inspections {
  background: #182230;
  border: 1px solid #28374d;
  color: #c9d1d9;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
}
.btn-back-inspections:hover { background: #202c3f; }
.unit-current-title h2 {
  margin: 0;
  font-size: 0.98rem;
  color: #fff;
}
.unit-subtitle {
  font-size: 0.72rem;
  color: #8b949e;
}

/* Tabs Superiores */
.detail-nav-tabs {
  display: flex;
  background: #161f2e;
  border-radius: 8px;
  padding: 3px;
  gap: 4px;
}
.d-tab-btn {
  background: transparent;
  border: none;
  color: #8b949e;
  padding: 7px 14px;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.d-tab-btn.active {
  background: #003366;
  color: #fff;
}
.btn-new-obs-action {
  background: #008080;
  border: none;
  color: #fff;
  padding: 7px 14px;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
}
.btn-new-obs-action:hover { background: #009688; }

.detail-content-pane {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* SUB-TAB 1: RESUMEN */
.summary-pane {
  overflow-y: auto;
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.summary-hero-banner {
  background: linear-gradient(135deg, #101926 0%, #172437 100%);
  border: 1px solid #23344d;
  border-radius: 14px;
  padding: 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.hero-chip-badge {
  background: rgba(0, 168, 150, 0.2);
  color: #00a896;
  border: 1px solid #00a896;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.72rem;
  font-weight: bold;
  display: inline-block;
  margin-bottom: 6px;
}
.hero-left-info h3 {
  margin: 0 0 6px 0;
  font-size: 1.4rem;
}
.hero-address {
  margin: 0;
  color: #8b949e;
  font-size: 0.85rem;
}
.circular-progress {
  width: 90px;
  height: 90px;
  border-radius: 50%;
  border: 6px solid #008080;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #0b131e;
}
.progress-number {
  font-size: 1.3rem;
  font-weight: 800;
  color: #fff;
}
.progress-lbl {
  font-size: 0.62rem;
  color: #8b949e;
  text-transform: uppercase;
}

.summary-details-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
}
.detail-info-card {
  background: #111823;
  border: 1px solid #1f2b3c;
  border-radius: 10px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.d-card-icon {
  font-size: 1.6rem;
}
.d-card-texts label {
  display: block;
  font-size: 0.72rem;
  color: #8b949e;
  text-transform: uppercase;
}
.d-card-texts strong {
  font-size: 0.88rem;
  color: #fff;
}
.text-green { color: #3fb950 !important; }

.summary-bottom-actions {
  display: flex;
  gap: 12px;
  margin-top: 10px;
}
.btn-summary-cta {
  padding: 12px 18px;
  border-radius: 8px;
  font-weight: bold;
  font-size: 0.88rem;
  cursor: pointer;
  border: none;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
.btn-summary-cta.primary { background: #003366; color: #fff; }
.btn-summary-cta.secondary { background: #008080; color: #fff; }
.btn-summary-cta.ghost { background: #16202e; border: 1px solid #283950; color: #58a6ff; }

/* SUB-TAB 2: PLANO INTERACTIVO */
.plan-pane {
  flex: 1;
}
.plan-interactive-layout {
  flex: 1;
  display: flex;
  height: 100%;
  overflow: hidden;
}
.plan-canvas-wrapper {
  flex: 1.3;
  background: #080c12;
  display: flex;
  flex-direction: column;
  position: relative;
  border-right: 1px solid #1e2838;
}
.plan-header-legend {
  height: 38px;
  background: #111823;
  border-bottom: 1px solid #1e2838;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 14px;
  font-size: 0.78rem;
  color: #c9d1d9;
}
.legend-info {
  display: flex;
  align-items: center;
  gap: 6px;
}
.text-moving-alert {
  color: #ffab00;
  font-weight: bold;
}
.btn-cancel-move-sm {
  background: rgba(248, 81, 73, 0.2);
  border: 1px solid #f85149;
  color: #ff7b72;
  font-size: 0.7rem;
  padding: 2px 6px;
  border-radius: 4px;
  cursor: pointer;
  margin-right: 8px;
}
.pins-count-tag {
  font-size: 0.72rem;
  color: #8b949e;
}

.blueprint-canvas {
  flex: 1;
  position: relative;
  background: #090e15;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  cursor: crosshair;
}
.blueprint-grid-lines {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background-image: linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px);
  background-size: 26px 26px;
  pointer-events: none;
}

/* Barra Superior de Ambientes Fuera del Plano (Chips Compactos en Dos Filas o Cuadrícula Fluida) */
.floorplan-top-areas-bar {
  background: #0f1622;
  border-bottom: 1px solid #1c2838;
  padding: 8px 14px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
  z-index: 10;
}
.top-areas-title {
  display: flex;
  align-items: center;
  font-size: 0.76rem;
  font-weight: 700;
  color: #8b949e;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
}
.top-areas-chips-container {
  display: flex;
  flex-wrap: wrap; /* Acomodar en dos filas para ver todos sin deslizar */
  gap: 6px;
  align-items: center;
  flex: 1;
}
.top-areas-chips-container.allow-scroll {
  /* Si hay más de 10 ambientes, habilitar scroll horizontal suave */
  flex-wrap: nowrap;
  overflow-x: auto;
  padding-bottom: 2px;
}
.floorplan-area-chip-compact {
  background: #141d2a;
  border: 1px solid #24354b;
  border-radius: 16px;
  padding: 3px 8px;
  display: inline-flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.15s ease;
}
.floorplan-area-chip-compact:hover {
  background: #1a2738;
  border-color: #58a6ff;
}
.floorplan-area-chip-compact.active {
  background: #003366;
  border-color: #00e5a3;
  box-shadow: 0 0 8px rgba(0, 229, 163, 0.4);
}
.area-chip-icon {
  font-size: 0.85rem;
  line-height: 1;
}
.floorplan-area-chip-compact .area-chip-title {
  font-size: 0.74rem;
  font-weight: 600;
  color: #fff;
}
.btn-chip-retype {
  background: transparent;
  border: none;
  font-size: 0.72rem;
  cursor: pointer;
  padding: 0 1px;
  opacity: 0.6;
  transition: opacity 0.15s;
}
.btn-chip-retype:hover {
  opacity: 1;
  transform: scale(1.15);
}

/* Contenedor del Plano Real con Imagen (Agrandado para ocupar máximo espacio) */
.floorplan-image-wrapper {
  position: relative;
  width: 96%;
  height: 94%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 12px 36px rgba(0, 0, 0, 0.85);
  background: #ffffff;
}
.floorplan-image-wrapper.arch-mode {
  width: 98%;
  height: 98%;
}
.floorplan-render-img {
  width: auto;
  height: auto;
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  display: block;
}
.floorplan-interactive-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  pointer-events: none;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 12px;
  align-content: flex-start;
}
.floorplan-area-chip {
  pointer-events: auto;
  background: rgba(13, 21, 32, 0.85);
  backdrop-filter: blur(4px);
  border: 1px solid rgba(88, 166, 255, 0.4);
  border-radius: 6px;
  padding: 4px 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  color: #fff;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(0,0,0,0.4);
}
.floorplan-area-chip:hover {
  background: rgba(0, 51, 102, 0.9);
  border-color: #58a6ff;
  transform: translateY(-1px);
}
.floorplan-area-chip.active {
  background: #003366;
  border-color: #00e5a3;
  box-shadow: 0 0 12px rgba(0, 229, 163, 0.5);
}
.area-chip-title {
  font-size: 0.75rem;
  font-weight: 700;
}
.area-canonical-tag {
  font-size: 0.65rem;
  color: #00e5a3;
  font-weight: 600;
}

.blueprint-rooms-container {
  width: 90%;
  height: 86%;
  max-width: 820px;
  max-height: 580px;
  border: 2px dashed rgba(88, 166, 255, 0.3);
  border-radius: 12px;
  position: relative;
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  grid-template-rows: 2fr 1.5fr;
  gap: 8px;
  padding: 8px;
  box-sizing: border-box;
}
.blueprint-room-box {
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
  padding: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}
.blueprint-room-box:hover {
  background: rgba(88, 166, 255, 0.08);
}
.blueprint-room-box.active {
  border-color: #58a6ff;
  background: rgba(0, 51, 102, 0.25);
  box-shadow: inset 0 0 16px rgba(88, 166, 255, 0.15);
}
.room-living { grid-column: 1 / 2; grid-row: 1 / 3; }
.room-kitchen { grid-column: 2 / 4; grid-row: 1 / 2; }
.room-bed-main { grid-column: 2 / 3; grid-row: 2 / 3; }
.room-bath-main { grid-column: 3 / 4; grid-row: 2 / 3; }

.room-title-bar {
  display: flex;
  align-items: center;
  gap: 4px;
}
.room-label-text {
  font-size: 0.72rem;
  font-weight: 700;
  color: #c9d1d9;
}
.room-rename-input {
  background: #000;
  border: 1px solid #58a6ff;
  color: #fff;
  font-size: 0.72rem;
  padding: 2px 4px;
  border-radius: 4px;
}
.btn-rename-trigger {
  background: transparent;
  border: none;
  font-size: 0.68rem;
  cursor: pointer;
  opacity: 0.6;
}
.btn-rename-trigger:hover { opacity: 1; }

/* Pines en el Plano */
.plan-pin-marker {
  position: absolute;
  transform: translate(-50%, -100%);
  cursor: pointer;
  z-index: 20;
}
.pin-bubble {
  display: flex;
  align-items: center;
  gap: 2px;
  font-size: 1.4rem;
}
.pin-idx {
  background: #cf6679;
  color: #fff;
  font-size: 0.62rem;
  font-weight: bold;
  padding: 1px 4px;
  border-radius: 4px;
}
.plan-pin-marker.sev-menor .pin-idx { background: #00a896; }
.plan-pin-marker.sev-moderada .pin-idx { background: #ffab00; }
.plan-pin-marker.sev-mayor .pin-idx, .plan-pin-marker.sev-crítica .pin-idx { background: #cf6679; }

.pin-tooltip {
  display: none;
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: #161b22;
  border: 1px solid #30363d;
  padding: 6px 10px;
  border-radius: 6px;
  white-space: nowrap;
  font-size: 0.72rem;
}
.plan-pin-marker:hover .pin-tooltip { display: flex; flex-direction: column; }

/* Botón para alternar Ambientes */
.btn-toggle-areas-drawer {
  background: #182230;
  border: 1px solid #28374d;
  color: #c9d1d9;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.2s ease;
}
.btn-toggle-areas-drawer:hover, .btn-toggle-areas-drawer.active {
  background: #003366;
  border-color: #58a6ff;
  color: #fff;
}

/* Panel Lateral de Zonas */
.plan-sidebar-info {
  flex: 0.7;
  max-width: 340px;
  background: #0f151f;
  padding: 16px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 14px;
  transition: all 0.25s ease;
}
.plan-sidebar-info.sidebar-hidden {
  display: none;
}
.plan-sidebar-info.sidebar-visible {
  display: flex;
}
.selected-pin-toolbar {
  background: #162334;
  border: 1px solid #388bfd;
  border-radius: 10px;
  padding: 12px;
}
.selected-pin-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 6px;
}
.pin-tag-badge {
  background: #003366;
  color: #fff;
  font-size: 0.72rem;
  font-weight: bold;
  padding: 2px 6px;
  border-radius: 4px;
}
.btn-close-pin-panel {
  background: transparent;
  border: none;
  color: #8b949e;
  cursor: pointer;
}
.pin-toolbar-title {
  margin: 0 0 4px 0;
  font-size: 0.88rem;
}
.pin-toolbar-area {
  margin: 0 0 10px 0;
  font-size: 0.75rem;
  color: #8b949e;
}
.pin-toolbar-actions {
  display: flex;
  gap: 8px;
}
.btn-action-move {
  background: #238636;
  border: none;
  color: #fff;
  padding: 5px 10px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: bold;
  cursor: pointer;
}
.btn-action-delete {
  background: rgba(248, 81, 73, 0.15);
  border: 1px solid rgba(248, 81, 73, 0.4);
  color: #ff7b72;
  padding: 5px 10px;
  border-radius: 6px;
  font-size: 0.75rem;
  cursor: pointer;
}

.areas-management-card h4 { margin: 0 0 2px 0; font-size: 0.92rem; }
.areas-management-card p { margin: 0 0 10px 0; font-size: 0.75rem; color: #8b949e; }
.areas-pills-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 10px;
}
.area-manage-item {
  background: #141c28;
  border: 1px solid #222f42;
  border-radius: 6px;
  padding: 8px 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  font-size: 0.8rem;
}
.area-manage-item.selected {
  border-color: #58a6ff;
  background: rgba(0, 51, 102, 0.2);
}
.area-bullet {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #008080;
  display: inline-block;
  margin-right: 6px;
}
.area-texts-column {
  display: flex;
  flex-direction: column;
}
.area-name-display {
  font-weight: 700;
  color: #fff;
  font-size: 0.8rem;
}
.area-type-tag {
  color: #00e5a3;
  font-size: 0.7rem;
}
.area-type-tag strong {
  color: #58a6ff;
}
.inline-rename-field {
  background: #000;
  border: 1px solid #58a6ff;
  color: #fff;
  font-size: 0.78rem;
  padding: 2px 6px;
  border-radius: 4px;
}
.btn-mini-rename, .btn-mini-delete {
  background: transparent;
  border: none;
  color: #8b949e;
  cursor: pointer;
  font-size: 0.75rem;
}
.add-area-inline-box {
  display: flex;
  gap: 6px;
}
.input-add-area {
  flex: 1;
  background: #090e15;
  border: 1px solid #222f42;
  border-radius: 6px;
  padding: 6px 8px;
  color: #fff;
  font-size: 0.78rem;
}
.btn-add-area-btn {
  background: #008080;
  border: none;
  color: #fff;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.78rem;
  font-weight: bold;
  cursor: pointer;
}

/* SUB-TAB 3: CHECKLIST PANE (ESTRUCTURA DE ESPECIALIDADES E ITEMS SECUNDARIOS) */
.checklist-pane {
  overflow-y: auto;
  padding: 20px 24px;
}
.checklist-top-control {
  margin-bottom: 16px;
}
.checklist-instruction h3 { margin: 0 0 4px 0; font-size: 1.25rem; font-weight: 700; color: #fff; }
.checklist-instruction p { margin: 0 0 12px 0; font-size: 0.85rem; color: #8b949e; }
.checklist-areas-scroller {
  display: flex;
  gap: 6px;
  overflow-x: auto;
  padding-bottom: 4px;
}
.cl-area-pill {
  background: #131b26;
  border: 1px solid #212c3d;
  color: #8b949e;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
}
.cl-area-pill.active {
  background: #003366;
  border-color: #58a6ff;
  color: #fff;
}

/* Grupos y Acordeones de Especialidades */
.checklist-groups-wrapper {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 960px;
}
.cl-group-box {
  background: #101722;
  border: 1px solid #1f2b3c;
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.2s ease;
}
.cl-group-box.is-completed {
  border-color: rgba(46, 160, 67, 0.4);
}
.cl-group-box.is-expanded {
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}

.cl-group-header {
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  user-select: none;
  background: #131b27;
  transition: background 0.2s;
}
.cl-group-header:hover {
  background: #162232;
}
.cl-group-title-col {
  display: flex;
  align-items: center;
  gap: 14px;
  flex: 1;
}
.cl-group-icon {
  font-size: 1.4rem;
}
.cl-group-texts {
  display: flex;
  flex-direction: column;
  gap: 3px;
  flex: 1;
}
.cl-title-row {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.cl-title-row h4 {
  margin: 0;
  font-size: 1rem;
  font-weight: 700;
  color: #fff;
}
.cl-group-status-badge {
  font-size: 0.68rem;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 10px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}
.cl-group-status-badge.status-pending {
  background: rgba(255, 171, 0, 0.15);
  border: 1px solid rgba(255, 171, 0, 0.4);
  color: #ffab00;
}
.cl-group-status-badge.status-reviewed {
  background: rgba(46, 160, 67, 0.18);
  border: 1px solid rgba(46, 160, 67, 0.5);
  color: #3fb950;
}
.cl-group-summary-line {
  margin: 0;
  font-size: 0.76rem;
  color: #8b949e;
}
.cl-group-arrow-col {
  font-size: 0.85rem;
  color: #8b949e;
  padding-left: 12px;
}

/* Sub-items (Puntos interiores evaluables) */
.cl-subitems-container {
  padding: 8px 16px 14px 16px;
  background: #0c121b;
  display: flex;
  flex-direction: column;
  gap: 8px;
  border-top: 1px solid #1a2534;
}
.cl-subitem-row {
  background: #111823;
  border: 1px solid #1c2737;
  border-radius: 8px;
  padding: 12px 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 14px;
}
.cl-subitem-info {
  flex: 1;
}
.subitem-title {
  display: block;
  font-size: 0.88rem;
  font-weight: 600;
  color: #fff;
  margin-bottom: 2px;
}
.subitem-spec {
  margin: 0;
  font-size: 0.75rem;
  color: #8b949e;
  line-height: 1.35;
}
.cl-subitem-actions {
  display: flex;
  gap: 6px;
  flex-shrink: 0;
}
.btn-status-choice {
  background: #182230;
  border: 1px solid #27364b;
  color: #8b949e;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 0.78rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
}
.btn-status-choice.btn-ok.selected { background: #008000; color: #fff; border-color: #008000; }
.btn-status-choice.btn-obs.selected { background: #FF8C00; color: #fff; border-color: #FF8C00; }
.btn-status-choice.btn-na.selected { background: #38465a; color: #fff; border-color: #4b5e78; }
.btn-status-choice.btn-nv.selected { background: #2563eb; color: #fff; border-color: #3b82f6; }

/* SUB-TAB 4: OBSERVACIONES */
.observations-pane {
  overflow-y: auto;
  padding: 20px 24px;
}
.obs-pane-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.obs-pane-header h3 { margin: 0 0 2px 0; font-size: 1.15rem; }
.obs-pane-header p { margin: 0; font-size: 0.8rem; color: #8b949e; }
.obs-cards-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 960px;
}
.obs-detail-card {
  background: #111823;
  border: 1px solid #1f2b3c;
  border-radius: 10px;
  padding: 16px;
}
.obs-card-header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.obs-tags-left {
  display: flex;
  gap: 8px;
  align-items: center;
}
.badge-idx {
  background: #182230;
  color: #58a6ff;
  font-weight: bold;
  font-size: 0.72rem;
  padding: 2px 6px;
  border-radius: 4px;
}
.badge-severity {
  font-size: 0.68rem;
  font-weight: bold;
  padding: 2px 8px;
  border-radius: 4px;
  text-transform: uppercase;
}
.badge-area {
  font-size: 0.72rem;
  color: #c9d1d9;
}
.badge-status {
  font-size: 0.7rem;
  color: #8b949e;
}
.btn-delete-obs-item {
  background: transparent;
  border: none;
  color: #8b949e;
  cursor: pointer;
  font-size: 0.85rem;
}
.obs-card-title {
  margin: 0 0 4px 0;
  font-size: 0.95rem;
}
.obs-card-desc {
  margin: 0 0 12px 0;
  font-size: 0.82rem;
  color: #aaa;
}
.obs-photos-grid {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
.photo-thumb-card {
  background: #090e15;
  border: 1px solid #1f2b3c;
  border-radius: 6px;
  padding: 6px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.photo-img-render {
  width: 44px;
  height: 44px;
  object-fit: cover;
  border-radius: 4px;
}
.photo-placeholder {
  width: 44px;
  height: 44px;
  background: #182230;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.65rem;
  border-radius: 4px;
}
.photo-meta-info {
  display: flex;
  flex-direction: column;
}
.photo-file-name {
  font-size: 0.72rem;
  font-weight: bold;
  color: #fff;
}
.photo-sha {
  font-size: 0.65rem;
  color: #00a896;
}

/* ============================================================== */
/* VISTA 3: MOTOR DE SINCRONIZACIÓN (PANTALLA 2 Y 9)             */
/* ============================================================== */
.view-sync-engine {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
  display: flex;
  justify-content: center;
}
.sync-pane-card {
  background: #111823;
  border: 1px solid #1f2b3c;
  border-radius: 14px;
  padding: 28px;
  width: 100%;
  max-width: 680px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.sync-pane-header {
  text-align: center;
}
.sync-pane-header h2 { margin: 0 0 6px 0; }
.sync-pane-header p { margin: 0; color: #8b949e; font-size: 0.85rem; }
.sync-circular-container {
  margin: 10px 0;
}
.sync-progress-circle {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  border: 8px solid #008080;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #090e15;
}
.sync-progress-circle.spinning {
  animation: pulse-sync 1s infinite alternate;
}
@keyframes pulse-sync {
  0% { border-color: #008080; }
  100% { border-color: #58a6ff; }
}
.sync-percentage {
  font-size: 1.8rem;
  font-weight: 800;
  color: #fff;
}
.sync-circle-label {
  font-size: 0.68rem;
  color: #8b949e;
}
.sync-items-checklist {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.sync-checklist-item {
  background: #16202e;
  border: 1px solid #243449;
  border-radius: 8px;
  padding: 10px 14px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.sync-item-icon { font-size: 1.2rem; }
.sync-item-texts { flex: 1; }
.sync-item-texts strong { display: block; font-size: 0.88rem; }
.sync-item-texts small { color: #8b949e; font-size: 0.75rem; }
.sync-item-status.check { color: #3fb950; font-weight: bold; font-size: 0.82rem; }
.sync-item-status.pending { color: #ffab00; font-weight: bold; font-size: 0.82rem; }

.sync-actions-bottom {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}
.btn-trigger-sync {
  width: 100%;
  background: #008080;
  border: none;
  color: #fff;
  padding: 12px;
  border-radius: 8px;
  font-size: 0.92rem;
  font-weight: bold;
  cursor: pointer;
}
.btn-trigger-sync:hover { background: #009688; }
.sync-hint-text {
  font-size: 0.75rem;
  color: #8b949e;
  text-align: center;
  margin: 0;
}

/* ============================================================== */
/* VISTA 4: PERFIL Y CIERRE DE SESIÓN                            */
/* ============================================================== */
.view-profile-pane {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}
.profile-card-box {
  background: #111823;
  border: 1px solid #1f2b3c;
  border-radius: 16px;
  padding: 32px;
  width: 100%;
  max-width: 440px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}
.profile-avatar-large {
  font-size: 3rem;
  margin-bottom: 10px;
}
.profile-card-box h3 { margin: 0 0 4px 0; font-size: 1.3rem; }
.profile-role-tag {
  color: #00a896;
  font-weight: bold;
  font-size: 0.8rem;
  margin: 0 0 6px 0;
}
.profile-email-badge {
  background: rgba(255, 255, 255, 0.05);
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  color: #8b949e;
  margin-bottom: 20px;
}
.profile-meta-list {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 24px;
}
.profile-meta-row {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  border-bottom: 1px solid #1f2b3c;
  padding-bottom: 6px;
}
.profile-meta-row span { color: #8b949e; }
.btn-logout-app {
  width: 100%;
  background: rgba(248, 81, 73, 0.15);
  border: 1px solid rgba(248, 81, 73, 0.4);
  color: #ff7b72;
  padding: 10px;
  border-radius: 8px;
  font-size: 0.88rem;
  font-weight: bold;
  cursor: pointer;
}

/* ============================================================== */
/* DOCK BARRA INFERIOR (FIGURA 3 Y 9)                            */
/* ============================================================== */
.app-bottom-nav {
  height: 58px;
  background: #101620;
  border-top: 1px solid #1e2838;
  display: flex;
  align-items: center;
  justify-content: space-around;
  flex-shrink: 0;
  z-index: 100;
}
.nav-dock-btn {
  background: transparent;
  border: none;
  color: #8b949e;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  cursor: pointer;
  position: relative;
  padding: 6px 20px;
  border-radius: 8px;
  transition: all 0.2s ease;
}
.nav-dock-btn.active {
  color: #00a896;
}
.dock-icon { font-size: 1.25rem; }
.dock-label { font-size: 0.7rem; font-weight: 600; }
.dock-bubble {
  position: absolute;
  top: 2px;
  right: 18px;
  background: #ffab00;
  color: #000;
  font-size: 0.65rem;
  font-weight: bold;
  padding: 1px 5px;
  border-radius: 10px;
}

/* ============================================================== */
/* VISTAS: ARQUITECTURA Y REPORTES EN APP                         */
/* ============================================================== */
.view-architecture-pane, .view-reports-pane {
  flex: 1;
  overflow-y: auto;
  padding: 22px 28px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.arch-pane-header, .reports-pane-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.arch-pane-header h2, .reports-pane-header h2 {
  margin: 0 0 4px 0;
  font-size: 1.4rem;
  color: #fff;
}
.arch-pane-header p, .reports-pane-header p {
  margin: 0;
  color: #8b949e;
  font-size: 0.85rem;
}
.btn-upload-plan-top {
  background: #003366;
  border: 1px solid #58a6ff;
  color: #fff;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.82rem;
  font-weight: 600;
}
.arch-unit-selector-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #111823;
  padding: 10px 14px;
  border-radius: 8px;
  border: 1px solid #1f2b3c;
}
.arch-unit-selector-bar label {
  font-size: 0.82rem;
  color: #8b949e;
  font-weight: 600;
}
.arch-unit-select {
  flex: 1;
  background: #0a0f16;
  border: 1px solid #24354a;
  color: #fff;
  padding: 6px 10px;
  border-radius: 6px;
  font-size: 0.85rem;
}
.arch-plan-viewer-card {
  background: #0e1520;
  border: 1px solid #1f2b3c;
  border-radius: 12px;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 14px;
}
.arch-plan-top-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.plan-file-badge {
  font-size: 0.82rem;
  font-weight: bold;
  color: #58a6ff;
}
.plan-hash-badge {
  font-size: 0.72rem;
  color: #8b949e;
  background: #0a0f16;
  padding: 2px 6px;
  border-radius: 4px;
}
.plan-status-verified {
  font-size: 0.72rem;
  color: #3fb950;
  background: rgba(46, 160, 67, 0.15);
  border: 1px solid rgba(46, 160, 67, 0.3);
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 600;
}
.arch-blueprint-display {
  height: 380px;
  background: #090e15;
  border: 1px solid #1b2636;
  border-radius: 8px;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.arch-areas-toolbar {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.arch-help-note {
  margin: 0;
  font-size: 0.75rem;
  color: #8b949e;
}
.btn-rename-trigger.remove {
  color: #f85149;
  margin-left: 2px;
}

/* Tarjetas de Reportes / Informes */
.reports-cards-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.app-report-card {
  background: #111823;
  border: 1px solid #1f2b3c;
  border-radius: 12px;
  padding: 16px 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: all 0.2s ease;
}
.app-report-card:hover {
  background: #152030;
  border-color: #388bfd;
}
.rep-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.rep-code-box {
  display: flex;
  align-items: center;
  gap: 12px;
}
.rep-doc-icon {
  font-size: 1.8rem;
}
.rep-code-box h4 {
  margin: 0 0 2px 0;
  font-size: 1.05rem;
  color: #fff;
}
.rep-meta-sub {
  font-size: 0.75rem;
  color: #8b949e;
}
.rep-badge-signed {
  font-size: 0.72rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 12px;
  background: rgba(46, 160, 67, 0.15);
  border: 1px solid rgba(46, 160, 67, 0.3);
  color: #3fb950;
}
.rep-badge-signed.needs-sign {
  background: rgba(255, 171, 0, 0.15);
  border-color: rgba(255, 171, 0, 0.3);
  color: #ffab00;
}
.rep-body-info {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  background: #0b111a;
  padding: 10px 14px;
  border-radius: 8px;
  border: 1px solid #16202e;
}
.rep-info-col label {
  display: block;
  font-size: 0.68rem;
  color: #8b949e;
  text-transform: uppercase;
}
.rep-info-col strong {
  font-size: 0.82rem;
  color: #c9d1d9;
}
.rep-actions-bar {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
.btn-rep-action {
  padding: 8px 14px;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}
.btn-rep-action.sign {
  background: #008080;
  border: none;
  color: #fff;
}
.btn-rep-action.download {
  background: #182436;
  border: 1px solid #283a54;
  color: #58a6ff;
}

/* Modales Perfil y Plano */
.modal-profile-window {
  background: #121924;
  border: 1px solid #24354a;
  border-radius: 14px;
  width: 90%;
  max-width: 480px;
  box-sizing: border-box;
  overflow: hidden;
  box-shadow: 0 20px 45px rgba(0, 0, 0, 0.7);
}
.modal-profile-header {
  padding: 14px 20px;
  border-bottom: 1px solid #24354a;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.modal-profile-header h3 { margin: 0; font-size: 1.15rem; color: #fff; }
.profile-card-box.modal-box {
  padding: 24px;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}
.profile-card-box.modal-box h3 {
  font-size: 1.3rem;
  margin: 0 0 4px 0;
  color: #fff;
}
.meta-label {
  color: #8b949e;
  font-size: 0.82rem;
  white-space: nowrap;
}
.meta-val {
  color: #c9d1d9;
  font-size: 0.85rem;
  text-align: right;
  word-break: break-word;
}
.profile-modal-actions {
  display: flex;
  gap: 12px;
  width: 100%;
  margin-top: 6px;
}
.btn-logout-app-modal {
  flex: 1;
  background: rgba(248, 81, 73, 0.15);
  border: 1px solid rgba(248, 81, 73, 0.4);
  color: #ff7b72;
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: bold;
  cursor: pointer;
}
.uploaded-arch-file-info {
  background: #0b111a;
  border: 1px solid #1f2b3c;
  padding: 10px;
  border-radius: 6px;
}
.uploaded-arch-file-info p { margin: 0 0 2px 0; font-size: 0.82rem; color: #3fb950; }
.uploaded-arch-file-info small { color: #8b949e; font-size: 0.72rem; }

/* ============================================================== */
/* MODAL: NUEVA OBSERVACIÓN + CÁMARA (FIGURA 7 Y 8)               */
/* ============================================================== */
.modal-backdrop-camera {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 250;
  padding: 16px;
}
.modal-obs-window {
  background: #121924;
  border: 1px solid #24354a;
  border-radius: 14px;
  width: 100%;
  max-width: 580px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 20px 45px rgba(0, 0, 0, 0.7);
}
.modal-obs-header {
  padding: 14px 18px;
  border-bottom: 1px solid #24354a;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}
.modal-obs-header h3 { margin: 0; font-size: 1.15rem; }
.modal-location-subtitle { font-size: 0.75rem; color: #8b949e; margin-top: 2px; display: block; }
.btn-close-modal-x {
  background: transparent;
  border: none;
  color: #8b949e;
  font-size: 1.2rem;
  cursor: pointer;
}
.modal-obs-body {
  padding: 18px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.form-group-custom { display: flex; flex-direction: column; gap: 4px; }
.form-group-custom label { font-size: 0.78rem; font-weight: 600; color: #8b949e; }
.field-label-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.field-hint-chip {
  background: rgba(88, 166, 255, 0.15);
  color: #58a6ff;
  border: 1px solid rgba(88, 166, 255, 0.3);
  font-size: 0.68rem;
  font-weight: 600;
  padding: 1px 6px;
  border-radius: 10px;
}
.custom-combobox-wrapper {
  position: relative;
  width: 100%;
}
.single-defect-input-wrap {
  position: relative;
  display: flex;
  align-items: center;
  width: 100%;
}
.defect-single-input {
  width: 100%;
  padding-right: 38px; /* Espacio para el botón de flecha */
}
.btn-toggle-custom-dropdown {
  position: absolute;
  right: 6px;
  top: 50%;
  transform: translateY(-50%);
  width: 28px;
  height: 28px;
  background: #152233;
  border: 1px solid #283e58;
  border-radius: 4px;
  color: #79c0ff;
  font-size: 0.9rem;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}
.btn-toggle-custom-dropdown:hover, .btn-toggle-custom-dropdown.active {
  background: #1f3552;
  border-color: #58a6ff;
  color: #fff;
}

/* Panel desplegable que se expande directamente bajo la casilla y no se sale de la pantalla */
.custom-dropdown-panel {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  right: 0;
  width: 100%;
  max-height: 220px;
  background: #0d1522;
  border: 1px solid #284469;
  border-radius: 8px;
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.85);
  z-index: 100;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.dropdown-header-tag {
  padding: 6px 10px;
  background: #111c2e;
  border-bottom: 1px solid #1f334d;
  font-size: 0.7rem;
  color: #8b949e;
}
.dropdown-header-tag strong {
  color: #58a6ff;
}
.dropdown-items-scroll {
  overflow-y: auto;
  max-height: 180px;
  display: flex;
  flex-direction: column;
}
.custom-dropdown-item {
  padding: 8px 12px;
  font-size: 0.8rem;
  color: #c9d1d9;
  cursor: pointer;
  display: flex;
  align-items: flex-start;
  gap: 8px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  line-height: 1.35;
  transition: background 0.15s ease;
}
.custom-dropdown-item:hover {
  background: #16273d;
  color: #58a6ff;
}
.custom-dropdown-item.selected {
  background: rgba(88, 166, 255, 0.15);
  color: #79c0ff;
  font-weight: 600;
}
.defect-bullet {
  color: #58a6ff;
  font-weight: bold;
}
.defect-text {
  flex: 1;
  word-break: break-word;
}
.field-input {
  background: #0a0f16;
  border: 1px solid #24354a;
  border-radius: 6px;
  padding: 8px 12px;
  color: #fff;
  font-size: 0.85rem;
}
.field-input:focus { outline: none; border-color: #58a6ff; }
.field-input.textarea { resize: vertical; }

.ai-suggestion-box {
  background: rgba(0, 51, 102, 0.2);
  border: 1px solid rgba(88, 166, 255, 0.3);
  border-radius: 8px;
  padding: 8px 12px;
  display: flex;
  gap: 10px;
  align-items: flex-start;
}
.ai-icon { font-size: 1.1rem; }
.ai-texts label { font-size: 0.7rem; color: #58a6ff; font-weight: bold; text-transform: uppercase; }
.ai-texts p { margin: 0; font-size: 0.75rem; color: #c9d1d9; }

.form-row-custom { display: flex; gap: 12px; }
.form-col { flex: 1; display: flex; flex-direction: column; gap: 4px; }
.form-col label { font-size: 0.78rem; font-weight: 600; color: #8b949e; }

.severity-chips-group { display: flex; gap: 4px; }
.sev-choice-chip {
  flex: 1;
  background: #182230;
  border: 1px solid #27364b;
  color: #8b949e;
  padding: 6px 0;
  border-radius: 6px;
  font-size: 0.68rem;
  font-weight: bold;
  cursor: pointer;
}
.sev-choice-chip.chip-menor.selected { background: #008080; color: #fff; border-color: #008080; }
.sev-choice-chip.chip-moderada.selected { background: #FF8C00; color: #fff; border-color: #FF8C00; }
.sev-choice-chip.chip-mayor.selected, .sev-choice-chip.chip-crítica.selected { background: #CC0000; color: #fff; border-color: #CC0000; }

/* Cámara y Fotos */
.camera-capture-section {
  background: #0b1118;
  border: 1px dashed #24354a;
  border-radius: 8px;
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.section-label { font-size: 0.78rem; font-weight: bold; color: #00a896; }
.camera-actions-row { display: flex; gap: 10px; }
.hidden-input { display: none; }
.btn-camera-trigger, .btn-gallery-trigger {
  flex: 1;
  background: #162232;
  border: 1px solid #283950;
  color: #58a6ff;
  padding: 10px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  cursor: pointer;
  font-size: 0.82rem;
  font-weight: 600;
  transition: all 0.2s ease;
}
.btn-camera-trigger:hover, .btn-gallery-trigger:hover { background: #1c2c41; }
.cam-icon { font-size: 1.1rem; }

.captured-photos-preview {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.captured-photo-badge {
  background: #141c28;
  border: 1px solid #222f42;
  border-radius: 6px;
  padding: 6px 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.photo-thumbnail {
  width: 40px;
  height: 40px;
  object-fit: cover;
  border-radius: 4px;
}
.photo-info-column { flex: 1; display: flex; flex-direction: column; }
.photo-name { font-size: 0.75rem; font-weight: bold; color: #fff; }
.photo-sha-pill { font-size: 0.65rem; color: #00a896; }
.btn-remove-photo {
  background: transparent;
  border: none;
  color: #f85149;
  cursor: pointer;
}
.camera-hint {
  margin: 0;
  font-size: 0.72rem;
  color: #8b949e;
  text-align: center;
}

/* Selector de punto en plano dentro del modal */
.plan-pin-picker-card {
  background: #0d1520;
  border: 1px solid #23354b;
  border-radius: 8px;
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.picker-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.picker-icon-title {
  display: flex;
  align-items: center;
  gap: 10px;
}
.picker-icon {
  font-size: 1.2rem;
  color: #00e5a3;
}
.picker-texts strong {
  display: block;
  font-size: 0.85rem;
  color: #fff;
}
.picker-texts p {
  margin: 2px 0 0 0;
  font-size: 0.74rem;
  color: #8b949e;
}
.picker-badge-success {
  background: rgba(0, 229, 163, 0.15);
  color: #00e5a3;
  border: 1px solid rgba(0, 229, 163, 0.3);
  font-size: 0.7rem;
  font-weight: bold;
  padding: 2px 8px;
  border-radius: 12px;
}
.btn-pick-on-plan-trigger {
  width: 100%;
  background: #142030;
  border: 1px solid #2a415d;
  color: #fff;
  padding: 9px 12px;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: all 0.2s ease;
}
.btn-pick-on-plan-trigger:hover {
  background: #1c2d43;
  border-color: #58a6ff;
  color: #58a6ff;
}
.btn-pick-on-plan-trigger .pin-symbol {
  font-size: 1rem;
}

/* Nota de recomendación técnica discreta */
.obs-recommendation-note {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 6px;
  padding: 8px 10px;
}
.obs-recommendation-note .note-icon {
  font-size: 0.95rem;
}
.obs-recommendation-note p {
  margin: 0;
  font-size: 0.74rem;
  color: #8b949e;
  line-height: 1.35;
}
.obs-recommendation-note p strong {
  color: #c9d1d9;
}

/* Etiquetas en tarjetas de observación */
.obs-card-cat-line {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin: 4px 0 2px 0;
}
.obs-badge-cat {
  background: #182638;
  color: #58a6ff;
  font-size: 0.7rem;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 4px;
}
.obs-badge-sub {
  background: #101c2b;
  color: #00e5a3;
  font-size: 0.7rem;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: 4px;
}
.obs-card-loc {
  font-size: 0.74rem;
  color: #a0aec0;
  margin: 2px 0 6px 0;
}

/* Medición e instrumentos en tarjeta */
.obs-card-measurements-line {
  background: rgba(88, 166, 255, 0.1);
  border: 1px solid rgba(88, 166, 255, 0.25);
  border-radius: 6px;
  padding: 4px 8px;
  margin: 4px 0 6px 0;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.74rem;
}
.badge-measure-tag {
  color: #79c0ff;
  font-weight: bold;
}
.badge-measure-val {
  color: #fff;
  font-weight: 700;
}
.badge-measure-inst {
  color: #8b949e;
  font-style: italic;
}

/* Sección de Medidas e Instrumentos en Modal (Checklist + 3 campos compactos) */
.measurements-section-card {
  background: #0d1520;
  border: 1px solid #1f3044;
  border-radius: 8px;
  padding: 10px 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.measurements-toggle-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  user-select: none;
}
.measurements-checkbox {
  width: 17px;
  height: 17px;
  accent-color: #58a6ff;
  cursor: pointer;
}
.measurements-toggle-text {
  font-size: 0.8rem;
  color: #c9d1d9;
}
.measurements-toggle-text strong {
  color: #58a6ff;
}
.measurements-toggle-text small {
  color: #8b949e;
  font-size: 0.72rem;
  margin-left: 4px;
}
.measurements-fields-row {
  display: flex;
  gap: 8px;
  align-items: flex-end;
  background: #111a27;
  border: 1px solid #253952;
  border-radius: 6px;
  padding: 10px;
}
.measure-col {
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.measure-col label {
  font-size: 0.72rem;
  font-weight: 600;
  color: #8b949e;
}
.measure-val-col {
  flex: 1.2;
}
.measure-unit-col {
  flex: 1;
}
.measure-inst-col {
  flex: 2;
}
.measure-input, .measure-select {
  padding: 6px 8px;
  font-size: 0.8rem;
  height: 36px;
}

/* Alerta de selección activa en el plano */
.text-picking-alert {
  color: #00e5a3;
  font-weight: bold;
  animation: pulse 1.5s infinite;
}

.modal-obs-footer {
  margin-top: 6px;
  padding-top: 12px;
  border-top: 1px solid #24354a;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
.btn-cancel-modal {
  background: transparent;
  border: 1px solid #24354a;
  color: #c9d1d9;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 0.82rem;
  cursor: pointer;
}
.btn-save-modal {
  background: #008080;
  border: none;
  color: #fff;
  padding: 8px 18px;
  border-radius: 6px;
  font-size: 0.82rem;
  font-weight: bold;
  cursor: pointer;
}

/* ============================================================== */
/* RESPONSIVIDAD TABLET Y MOBILE PARA INSPECTOR APP               */
/* ============================================================== */
@media (max-width: 900px) {
  .app-top-bar {
    padding: 0 10px;
    height: 48px;
  }
  .top-bar-left .mode-tag {
    display: none;
  }
  .network-pill {
    padding: 4px 8px;
    font-size: 0.72rem;
  }
  .user-email-text {
    max-width: 110px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    display: inline-block;
  }

  /* Subheader de Inspección */
  .inspection-sub-header {
    height: auto;
    padding: 8px 10px;
    flex-wrap: wrap;
    gap: 8px;
  }
  .sub-header-left {
    width: 100%;
    justify-content: space-between;
    gap: 10px;
  }
  .unit-current-title {
    flex: 1;
    min-width: 0;
  }
  .unit-current-title h2 {
    font-size: 0.95rem;
    white-space: normal;
    word-break: break-word;
    line-height: 1.25;
  }
  .unit-subtitle {
    font-size: 0.76rem;
    color: #a0aec0;
    line-height: 1.3;
    display: block;
    margin-top: 2px;
  }
  .detail-nav-tabs {
    flex: 1;
    overflow-x: auto;
    width: 100%;
  }
  .d-tab-btn {
    padding: 6px 10px;
    font-size: 0.78rem;
    white-space: nowrap;
  }
  .sub-header-actions {
    display: flex;
    gap: 6px;
  }

  /* Resumen Responsive */
  .summary-pane {
    padding: 14px;
    gap: 14px;
  }
  .summary-hero-banner {
    flex-direction: column;
    align-items: flex-start;
    gap: 14px;
    padding: 16px;
  }
  .hero-left-info h3 {
    font-size: 1.15rem;
  }
  .summary-details-grid {
    grid-template-columns: 1fr;
    gap: 10px;
  }
  .detail-info-card {
    padding: 12px 14px;
  }
  .summary-bottom-actions {
    flex-direction: column;
  }

  /* Plano Interactivo Responsive (Maximizar el área gráfica) */
  .plan-interactive-layout {
    flex-direction: column;
    position: relative;
  }
  .plan-canvas-wrapper {
    flex: 1;
    width: 100%;
    border-right: none;
  }
  .plan-header-legend {
    padding: 6px 10px;
    font-size: 0.74rem;
    height: auto;
    flex-wrap: wrap;
    gap: 6px;
  }
  .plan-sidebar-info {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    width: 280px;
    z-index: 50;
    box-shadow: -4px 0 20px rgba(0, 0, 0, 0.7);
    border-left: 1px solid #24354a;
  }

  /* Subcategoría bajo Categoría en mobile para que ingrese completamente */
  .obs-category-split-row {
    flex-direction: column !important;
    gap: 10px !important;
  }

  /* Checklist alineado en mobile: botones de estado (OK, OBS, N/A, NV) debajo del texto */
  .cl-subitem-row {
    flex-direction: column !important;
    align-items: stretch !important;
    gap: 10px !important;
    padding: 12px !important;
  }
  .cl-subitem-actions {
    width: 100% !important;
    display: grid !important;
    grid-template-columns: repeat(4, 1fr) !important;
    gap: 6px !important;
  }
  .cl-subitem-actions .btn-status-choice {
    padding: 8px 4px !important;
    text-align: center !important;
    justify-content: center !important;
    display: flex !important;
    align-items: center !important;
    font-size: 0.75rem !important;
  }

  /* Medidas e instrumentos compactos en móvil */
  .measurements-fields-row {
    flex-direction: column !important;
    gap: 8px !important;
  }
  .measure-col {
    width: 100% !important;
  }
}

@media (min-width: 901px) and (max-width: 1180px) {
  /* Tablet Split-View */
  .summary-details-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .unit-current-title h2 {
    font-size: 1rem;
  }
  .unit-subtitle {
    font-size: 0.78rem;
  }
}
</style>
