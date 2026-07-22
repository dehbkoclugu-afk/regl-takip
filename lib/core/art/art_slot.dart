import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'art_registry.dart';

/// Renders finished artwork when the slot [id] is registered in [artRegistry],
/// otherwise an elegant labeled placeholder — so a screen's layout is final
/// before its art exists. See `docs/asset-briefs.md`.
class ArtSlot extends StatelessWidget {
  final String id;
  final double height;

  /// `cover` fills the frame (hero art); `contain` floats spot art.
  final BoxFit fit;
  final double radius;

  /// Rendered above the art (scrims, text, buttons).
  final Widget? child;

  const ArtSlot({
    super.key,
    required this.id,
    required this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final path = artRegistry[id];
    final spec = artSpecs[id];

    final Widget layer =
        path != null
            ? Image.asset(
              path,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
            )
            : _Placeholder(id: id, spec: spec, radius: radius);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [layer, if (child != null) child!],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String id;
  final ArtSpec? spec;
  final double radius;

  const _Placeholder({required this.id, required this.spec, required this.radius});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.secondary;
    return CustomPaint(
      painter: _DashedBorderPainter(color: accent, radius: radius),
      child: Container(
        color: AppColors.sf(context).withValues(alpha: 0.6),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 22, color: accent),
            const SizedBox(height: 6),
            Text(
              id,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
            if (spec != null) ...[
              const SizedBox(height: 2),
              Text(
                '${spec!.label} · ${spec!.size}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  color: AppColors.ts(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lightweight dashed rounded border — the placeholder's signature look.
/// ponytail: hand-rolled to avoid a dashed-border dependency.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 6.0, gap = 5.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, (d + dash).clamp(0, metric.length)),
          paint,
        );
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
