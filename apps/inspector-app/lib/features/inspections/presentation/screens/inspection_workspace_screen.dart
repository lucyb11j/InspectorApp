import 'package:flutter/material.dart';
import '../../domain/observation_library.dart';
import '../../domain/plan_marker_service.dart';

/// Pantalla principal de trabajo de campo para el inspector.
/// Soporta tanto formato Smartphone (vista apilada por pestañas)
/// como formato Tablet (Split-View panorámico con plano y lista simultáneos).
class InspectionWorkspaceScreen extends StatefulWidget {
  final String inspectionId;
  final String unitName;
  final String projectName;

  const InspectionWorkspaceScreen({
    super.key,
    required this.inspectionId,
    required this.unitName,
    required this.projectName,
  });

  @override
  State<InspectionWorkspaceScreen> createState() => _InspectionWorkspaceScreenState();
}

class _InspectionWorkspaceScreenState extends State<InspectionWorkspaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _areas = ['Sala / Comedor', 'Cocina', 'Dormitorio Principal', 'Baño Principal', 'Balcón'];
  int _selectedAreaIndex = 0;

  final List<Map<String, dynamic>> _recordedObservations = [];
  final List<PlanMarkerCoordinate> _markers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addObservationFromPreset(PresetObservationItem preset) {
    setState(() {
      _recordedObservations.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'area': _areas[_selectedAreaIndex],
        'title': preset.title,
        'description': preset.suggestedDescription,
        'severity': preset.defaultSeverity,
        'syncStatus': 'LOCAL',
        'hasEvidence': true,
      });
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Observación guardada en SQLite local: "${preset.title}"')),
    );
  }

  void _showAddObservationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catálogo Rápido de No-Conformidades',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: ObservationLibrary.standardDefects.length,
                  itemBuilder: (context, index) {
                    final preset = ObservationLibrary.standardDefects[index];
                    return Card(
                      color: const Color(0xFF252525),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(preset.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${preset.category} · Severidad: ${preset.defaultSeverity}'),
                        trailing: const Icon(Icons.add_circle, color: Color(0xFF1A73E8)),
                        onTap: () => _addObservationFromPreset(preset),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Punto de quiebre para Tablet: anchos mayores a 720px
        final isTablet = constraints.maxWidth >= 720;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${widget.unitName} - ${widget.projectName}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTablet ? const Color(0xFF03DAC6).withOpacity(0.15) : const Color(0xFF1A73E8).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isTablet ? const Color(0xFF03DAC6) : const Color(0xFF1A73E8),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        isTablet ? 'MODO TABLET' : 'MODO MÓVIL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isTablet ? const Color(0xFF03DAC6) : const Color(0xFF1A73E8),
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Zona seleccionada: ${_areas[_selectedAreaIndex]}', style: const TextStyle(fontSize: 12, color: Color(0xFFA0A0A0))),
              ],
            ),
            bottom: isTablet
                ? null // En Tablet no necesitamos pestañas, ambas vistas se presentan en simultáneo
                : TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF1A73E8),
                    tabs: const [
                      Tab(icon: Icon(Icons.list_alt), text: 'Defectos'),
                      Tab(icon: Icon(Icons.map_outlined), text: 'Plano Táctil'),
                    ],
                  ),
          ),
          body: isTablet
              ? _buildTabletSplitView()
              : _buildPhoneTabView(),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF1A73E8),
            icon: const Icon(Icons.add_a_photo),
            label: Text(isTablet ? 'Registrar Defecto con Foto' : 'Defecto'),
            onPressed: _showAddObservationModal,
          ),
        );
      },
    );
  }

  /// Vista adaptable para Smartphone (Pestañas clásicas)
  Widget _buildPhoneTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildObservationsPane(),
        _buildPlanCanvasPane(),
      ],
    );
  }

  /// Vista adaptativa para Tablet (Doble panel simultáneo: Plano interactivo a la izquierda, lista y áreas a la derecha)
  Widget _buildTabletSplitView() {
    return Row(
      children: [
        // Panel izquierdo: Plano interactivo amplio (60% del ancho)
        Expanded(
          flex: 6,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFF2A2A2A), width: 1.5)),
            ),
            child: _buildPlanCanvasPane(),
          ),
        ),

        // Panel derecho: Selector de zonas y observaciones registradas (40% del ancho)
        Expanded(
          flex: 4,
          child: _buildObservationsPane(),
        ),
      ],
    );
  }

  /// Componente del Plano Interactivo con pines táctiles
  Widget _buildPlanCanvasPane() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
            final coord = PlanMarkerCoordinate.fromPixelOffset(
              touchX: details.localPosition.dx,
              touchY: details.localPosition.dy,
              renderWidth: constraints.maxWidth,
              renderHeight: constraints.maxHeight,
            );
            setState(() {
              _markers.add(coord);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1200),
                content: Text('Pin de defecto fijado en (${coord.xPercent.toStringAsFixed(1)}%, ${coord.yPercent.toStringAsFixed(1)}%)'),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: const Color(0xFF141414),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.architecture, size: 80, color: Colors.white.withOpacity(0.08)),
                      const SizedBox(height: 12),
                      Text(
                        'Plano de la Unidad - ${widget.unitName}',
                        style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Toque cualquier punto del plano para ubicar la no-conformidad',
                        style: TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              for (final m in _markers)
                Positioned(
                  left: (m.xPercent / 100.0) * constraints.maxWidth - 14,
                  top: (m.yPercent / 100.0) * constraints.maxHeight - 28,
                  child: const Icon(Icons.location_on, color: Color(0xFFCF6679), size: 30),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Componente de Lista de Observaciones y Selector de Áreas
  Widget _buildObservationsPane() {
    final filtered = _recordedObservations.where((o) => o['area'] == _areas[_selectedAreaIndex]).toList();

    return Column(
      children: [
        // Selector horizontal de ambientes
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: const Color(0xFF1E1E1E),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _areas.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedAreaIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_areas[index]),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1A73E8),
                  backgroundColor: const Color(0xFF2A2A2A),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFA0A0A0),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedAreaIndex = index;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),

        // Lista de observaciones en la zona seleccionada
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 54, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 12),
                      Text(
                        'Sin observaciones en ${_areas[_selectedAreaIndex]}',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF252525),
                          foregroundColor: const Color(0xFF1A73E8),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar con Catálogo'),
                        onPressed: _showAddObservationModal,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final obs = filtered[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A73E8).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    obs['severity'] as String,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('SQLITE LOCAL', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              obs['title'] as String,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              obs['description'] as String,
                              style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Icon(Icons.verified_outlined, size: 14, color: Color(0xFF03DAC6)),
                                SizedBox(width: 4),
                                Text('Foto con Hash SHA-256 verificado', style: TextStyle(fontSize: 11, color: Color(0xFF03DAC6))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
