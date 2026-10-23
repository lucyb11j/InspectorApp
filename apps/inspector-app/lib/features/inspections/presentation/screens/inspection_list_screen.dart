import 'package:flutter/material.dart';
import 'inspection_workspace_screen.dart';

class InspectionListScreen extends StatelessWidget {
  const InspectionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inspecciones de prueba descargadas para trabajo offline
    final sampleInspections = [
      {
        'id': '55555555-0000-0000-0000-000000000002',
        'unit': 'Dpto 305',
        'project': 'Condominio Los Cedros - Torre B',
        'client': 'María Torres',
        'status': 'EN CURSO',
        'statusColor': const Color(0xFF1A73E8),
        'syncStatus': 'OFFLINE READY',
      },
      {
        'id': '55555555-0000-0000-0000-000000000003',
        'unit': 'Dpto 1102',
        'project': 'Edificio Miramar - Torre Única',
        'client': 'Jorge Ramírez',
        'status': 'PROGRAMADA',
        'statusColor': const Color(0xFFFFC107),
        'syncStatus': 'OFFLINE READY',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Inspecciones (Offline)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done, color: Color(0xFF03DAC6)),
            tooltip: 'Estado de Sincronización',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Motor Offline activo: Almacenamiento local SQLite')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleInspections.length,
        itemBuilder: (context, index) {
          final item = sampleInspections[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => InspectionWorkspaceScreen(
                      inspectionId: item['id'] as String,
                      unitName: item['unit'] as String,
                      projectName: item['project'] as String,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['unit'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (item['statusColor'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['status'] as String,
                            style: TextStyle(
                              color: item['statusColor'] as Color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['project'] as String,
                      style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: Color(0xFFA0A0A0)),
                            const SizedBox(width: 6),
                            Text(
                              item['client'] as String,
                              style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.offline_pin, size: 14, color: Color(0xFF03DAC6)),
                              const SizedBox(width: 4),
                              Text(
                                item['syncStatus'] as String,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF03DAC6)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
