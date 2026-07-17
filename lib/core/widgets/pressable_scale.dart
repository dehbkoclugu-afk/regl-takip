import 'package:flutter/material.dart';

import '../utils/motion.dart';

/// Dokunuşun fiziksel ağırlığı: basılıyken hafif küçülme (0.98, ~100ms).
/// Ripple "dokundun" der, ölçek "bastın" hissi verir — ikisi birlikte
/// pahalı his farkının büyük kısmıdır. InkWell'in üstüne sarılır;
/// dokunma olaylarını YUTMAZ (Listener kullanır), alt ağaçtaki
/// InkWell/GestureDetector aynen çalışır.
class PressableScale extends StatefulWidget {
  final Widget child;

  const PressableScale({super.key, required this.child});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final motion = context.motionEnabled;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && motion ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
