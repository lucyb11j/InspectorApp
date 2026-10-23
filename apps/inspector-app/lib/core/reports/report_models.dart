import 'dart:typed_data';

/// Tipos de formato de exportación soportados por el motor de informes.
enum ReportFormat {
  pdf,
  docx,
  html,
  csv,
  json,
}

/// Estado de un trabajo de generación de informe.
enum ReportJobStatus {
  queued,
  processing,
  completed,
  failed,
  cancelled,
}

/// Datos base para generar un informe de inspección.
class InspectionReportData {
  final String inspectionId;
  final String inspectionCode;
  final String clientName;
  final String address;
  final DateTime inspectionDate;
  final String inspectorName;
  final List<ReportSection> sections;
  final Map<String, dynamic> metadata;

  const InspectionReportData({
    required this.inspectionId,
    required this.inspectionCode,
    required this.clientName,
    required this.address,
    required this.inspectionDate,
    required this.inspectorName,
    required this.sections,
    this.metadata = const {},
  });
}

/// Sección genérica del informe (área, observación, etc.)
class ReportSection {
  final String title;
  final String? subtitle;
  final List<ReportItem> items;
  final Map<String, dynamic> extra;

  const ReportSection({
    required this.title,
    this.subtitle,
    required this.items,
    this.extra = const {},
  });
}

/// Elemento dentro de una sección.
class ReportItem {
  final String label;
  final String? value;
  final String? description;
  final List<String> evidenceUris;
  final Map<String, dynamic> extra;

  const ReportItem({
    required this.label,
    this.value,
    this.description,
    this.evidenceUris = const [],
    this.extra = const {},
  });
}

/// Resultado de la generación de un informe.
class GeneratedReport {
  final ReportFormat format;
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String? sha256;

  const GeneratedReport({
    required this.format,
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.sha256,
  });
}

/// Interfaz para motores de generación de informes.
abstract class ReportGenerator {
  ReportFormat get supportedFormat;
  Future<GeneratedReport> generate(InspectionReportData data, {Map<String, dynamic> options = const {}});
}

/// Fabrica simple para seleccionar generador por formato.
class ReportGeneratorFactory {
  final Map<ReportFormat, ReportGenerator> _generators = {};

  void register(ReportGenerator generator) {
    _generators[generator.supportedFormat] = generator;
  }

  ReportGenerator? getFor(ReportFormat format) => _generators[format];

  bool supports(ReportFormat format) => _generators.containsKey(format);
}
