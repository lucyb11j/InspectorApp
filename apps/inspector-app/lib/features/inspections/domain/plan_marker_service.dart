class PlanMarkerCoordinate {
  final double xPercent;
  final double yPercent;

  PlanMarkerCoordinate({
    required this.xPercent,
    required this.yPercent,
  }) {
    if (xPercent < 0.0 || xPercent > 100.0) {
      throw RangeError('xPercent must be within 0.0% and 100.0%');
    }
    if (yPercent < 0.0 || yPercent > 100.0) {
      throw RangeError('yPercent must be within 0.0% and 100.0%');
    }
  }

  /// Convierte toque táctil local a porcentaje normalizado independiente de resolución o zoom
  factory PlanMarkerCoordinate.fromPixelOffset({
    required double touchX,
    required double touchY,
    required double renderWidth,
    required double renderHeight,
  }) {
    if (renderWidth <= 0 || renderHeight <= 0) {
      throw ArgumentError('Render dimensions must be positive');
    }
    final x = (touchX / renderWidth * 100.0).clamp(0.0, 100.0);
    final y = (touchY / renderHeight * 100.0).clamp(0.0, 100.0);
    return PlanMarkerCoordinate(xPercent: x, yPercent: y);
  }
}
