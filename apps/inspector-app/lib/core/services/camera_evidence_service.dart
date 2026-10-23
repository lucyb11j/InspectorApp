import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class EvidenceCaptureResult {
  final String id;
  final String localFilePath;
  final String fileName;
  final String mimeType;
  final int fileSizeBytes;
  final String sha256;
  final DateTime capturedAt;
  final String? deviceId;

  EvidenceCaptureResult({
    required this.id,
    required this.localFilePath,
    required this.fileName,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.sha256,
    required this.capturedAt,
    this.deviceId,
  });
}

class CameraEvidenceService {
  final Uuid _uuid = const Uuid();

  /// Procesa un archivo de imagen capturado por la cámara:
  /// 1. Calcula inmediatamente su digest criptográfico SHA-256
  /// 2. Extrae tamaño en bytes y determina MIME type
  /// 3. Genera un identificador único e inmutable (UUID v4)
  Future<EvidenceCaptureResult> processCapturedPhoto({
    required File photoFile,
    String? deviceId,
  }) async {
    if (!await photoFile.exists()) {
      throw ArgumentError('Captured photo file does not exist at: ${photoFile.path}');
    }

    final bytes = await photoFile.readAsBytes();
    final digest = sha256.convert(bytes).toString();
    final size = bytes.length;
    final fileName = photoFile.path.split(Platform.pathSeparator).last;
    final ext = fileName.split('.').last.toLowerCase();

    String mimeType = 'image/jpeg';
    if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'webp') {
      mimeType = 'image/webp';
    }

    return EvidenceCaptureResult(
      id: _uuid.v4(),
      localFilePath: photoFile.path,
      fileName: fileName,
      mimeType: mimeType,
      fileSizeBytes: size,
      sha256: digest,
      capturedAt: DateTime.now().toUtc(),
      deviceId: deviceId,
    );
  }

  /// Calcula el hash de estado de una observación para detección de conflictos
  String computeObservationHash({
    required String title,
    required String? description,
    required String severity,
    required String status,
    required String updatedAtIso,
  }) {
    final payload = '$title|$description|$severity|$status|$updatedAtIso';
    return sha256.convert(payload.codeUnits).toString();
  }
}
