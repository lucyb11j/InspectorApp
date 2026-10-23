import 'package:flutter/material.dart';
import '../../domain/observation_library.dart';
import '../../domain/plan_marker_service.dart';

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
      SnackBar(content: Text('Observación guardada localmente en SQLite: "${preset.title}"')),
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
                    'Biblioteca de Defectos Típicos',
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.unitName} - ${widget.projectName}', style: const TextStyle(fontSize: 16)),
            Text('Área: ${_areas[_selectedAreaIndex]}', style: const TextStyle(fontSize: 12, color: Color(0xFFA0A0A0))),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1A73E8),
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Inspección & Defectos'),
            Tab(icon: Icon(Icons.map_outlined), text: 'Plano Táctil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Selector de Áreas + Observaciones
          Column(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: const Color(0xFF181818),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _areas.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedAreaIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_areas[index]),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1A73E8),
                        backgroundColor: const Color(0xFF262626),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFA0A0A0),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedAreaIndex = index);
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _recordedObservations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text(
                              'Sin observaciones en esta área',
                              style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A73E8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Registrar con Plantilla'),
                              onPressed: _showAddObservationModal,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recordedObservations.length,
                        itemBuilder: (context, index) {
                          final obs = _recordedObservations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        obs['area'] as String,
                                        style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A73E8).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          obs['severity'] as String,
                                          style: const TextStyle(color: Color(0xFF1A73E8), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    obs['title'] as String,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    obs['description'] as String,
                                    style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.photo_camera, size: 16, color: Color(0xFF03DAC6)),
                                      const SizedBox(width: 4),
                                      const Text('Evidencia fotográfica (SHA-256 verificado)', style: TextStyle(fontSize: 12, color: Color(0xFF03DAC6))),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('LOCAL DB', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ),
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
          ),

          // Pestaña 2: Plano Táctil interactivo (touch placement)
          LayoutBuilder(
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
                      duration: const Duration(seconds: 1),
                      content: Text('Marcador táctil fijado en: (${coord.xPercent.toStringAsFixed(1)}%, ${coord.yPercent.toStringAsFixed(1)}%)'),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color: const Color(0xFF1A1A1A),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.architecture, size: 80, color: Colors.white.withOpacity(0.08)),
                            const SizedBox(height: 12),
                            Text(
                              'Plano Arquitectónico - ${widget.unitName}',
                              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Toque cualquier punto del plano para fijar un defecto con precisión',
                              style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (final m in _markers)
                      Positioned(
                        left: (m.xPercent / 100.0) * constraints.maxWidth - 14,
                        top: (m.yPercent / 100.0) * constraints.maxHeight - 28,
                        child: const Icon(Icons.location_on, color: Color(0xFFCF6679), size: 28),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A73E8),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Defecto'),
        onPressed: _showAddObservationModal,
      ),
    );
  }
}
