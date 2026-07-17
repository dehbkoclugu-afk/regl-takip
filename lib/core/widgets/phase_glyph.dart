import 'package:flutter/material.dart';

import '../utils/cycle_utils.dart';

/// Dört fazın ÖZEL glifleri — markanın alfabesi. Material'ın genel
/// ikonları yerine tek çizgi dilinde (yuvarlak uçlu stroke) dört küçük
/// işaret: damla (regl), filiz (folliküler), parıltı (ovülasyon),
/// hilal (luteal). Ring merkezi, faz çipi ve koç kartı aynı alfabeyi
/// konuşur.
class PhaseGlyph extends StatelessWidget {
  final CyclePhase phase;
  final double size;
  final Color color;

  const PhaseGlyph({
    super.key,
    required this.phase,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PhaseGlyphPainter(phase: phase, color: color),
      ),
    );
  }
}

class _PhaseGlyphPainter extends CustomPainter {
  final CyclePhase phase;
  final Color color;

  _PhaseGlyphPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    switch (phase) {
      case CyclePhase.menstrual:
        _drawDrop(canvas, s, paint);
      case CyclePhase.follicular:
        _drawSprout(canvas, s, paint);
      case CyclePhase.ovulation:
        _drawSpark(canvas, s, paint);
      case CyclePhase.luteal:
        _drawCrescent(canvas, s, paint);
    }
  }

  /// Damla: tepe noktasından iki yanak, altta yarım daire.
  void _drawDrop(Canvas canvas, double s, Paint paint) {
    final r = s * 0.27;
    final cx = s * 0.5;
    final cy = s * 0.60;
    final path = Path()
      ..moveTo(cx, s * 0.10)
      ..quadraticBezierTo(cx + r * 1.05, s * 0.38, cx + r, cy)
      ..arcToPoint(
        Offset(cx - r, cy),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..quadraticBezierTo(cx - r * 1.05, s * 0.38, cx, s * 0.10);
    canvas.drawPath(path, paint);
  }

  /// Filiz: sap + sağa açılan yaprak.
  void _drawSprout(Canvas canvas, double s, Paint paint) {
    final stem = Path()
      ..moveTo(s * 0.42, s * 0.90)
      ..quadraticBezierTo(s * 0.40, s * 0.55, s * 0.46, s * 0.28);
    canvas.drawPath(stem, paint);

    final leaf = Path()
      ..moveTo(s * 0.46, s * 0.52)
      ..quadraticBezierTo(s * 0.80, s * 0.52, s * 0.86, s * 0.16)
      ..quadraticBezierTo(s * 0.52, s * 0.20, s * 0.46, s * 0.52);
    canvas.drawPath(leaf, paint);
  }

  /// Parıltı: içbükey kenarlı dört uçlu yıldız.
  void _drawSpark(Canvas canvas, double s, Paint paint) {
    final c = s * 0.5;
    final path = Path()
      ..moveTo(c, s * 0.08)
      ..quadraticBezierTo(s * 0.58, s * 0.42, s * 0.92, c)
      ..quadraticBezierTo(s * 0.58, s * 0.58, c, s * 0.92)
      ..quadraticBezierTo(s * 0.42, s * 0.58, s * 0.08, c)
      ..quadraticBezierTo(s * 0.42, s * 0.42, c, s * 0.08);
    canvas.drawPath(path, paint);
  }

  /// Hilal: dış yay + içbükey iç yay, ağzı sağa bakar.
  void _drawCrescent(Canvas canvas, double s, Paint paint) {
    final top = Offset(s * 0.64, s * 0.12);
    final bottom = Offset(s * 0.64, s * 0.88);
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(
        bottom,
        radius: Radius.circular(s * 0.42),
        clockwise: false,
      )
      ..arcToPoint(
        top,
        radius: Radius.circular(s * 0.34),
        clockwise: true,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PhaseGlyphPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}
