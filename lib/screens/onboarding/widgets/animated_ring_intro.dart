import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/cycle_utils.dart';
import '../../../core/utils/motion.dart';
import '../../../core/utils/ring_segments.dart';
import '../../../core/widgets/phase_glyph.dart';

/// Onboarding açılış sahnesi: imza ring'in segmentleri sırayla ÇİZİLİR —
/// ürün daha "merhaba" derken görsel imzasını tanıtır. Hareket
/// kısıtlıysa halka doğrudan tam çizili gelir.
class AnimatedRingIntro extends StatelessWidget {
  const AnimatedRingIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final motion = context.motionEnabled;
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: motion ? 0 : 1, end: 1),
        duration: context.motionDuration(const Duration(milliseconds: 1400)),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          painter: _RingIntroPainter(progress: t),
          child: Center(
            child: Opacity(
              // Glif çizim bitişine doğru belirir
              opacity: ((t - 0.55) / 0.45).clamp(0.0, 1.0),
              child: const PhaseGlyph(
                phase: CyclePhase.menstrual,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingIntroPainter extends CustomPainter {
  /// 0..1: halkanın ne kadarının çizildiği (saat 12'den saat yönünde)
  final double progress;

  static const _stroke = 13.0;
  static const _inset = 16.0;
  static const _gapRadians = 0.05;
  static const _cycleLength = 28;

  _RingIntroPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final segments = ringSegmentsFor(_cycleLength, 5);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _inset;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double dayStartAngle(int day) =>
        -math.pi / 2 + (day - 1) / _cycleLength * 2 * math.pi;

    // Toplam çizilen açı: -π/2'den saat yönünde progress * 2π
    final drawnUntil = -math.pi / 2 + progress * 2 * math.pi;

    for (final segment in segments) {
      final start = dayStartAngle(segment.startDay) + _gapRadians / 2;
      final end = dayStartAngle(segment.endDay + 1) - _gapRadians / 2;
      if (end <= start) continue;
      final visibleEnd = math.min(end, drawnUntil);
      if (visibleEnd <= start) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, start, visibleEnd - start, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingIntroPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
