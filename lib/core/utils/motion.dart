import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Sistem "animasyonları azalt / kaldır" ayarına saygı için yardımcı.
extension MotionContext on BuildContext {
  bool get motionEnabled => !MediaQuery.disableAnimationsOf(this);
}

extension MotionAnimate on Widget {
  /// `.animate()` yerine kullanılır: sistem animasyonları kapattıysa
  /// efektler oynatılmaz ve widget son (görünür) halinde durur —
  /// `autoPlay: false` tek başına fadeIn'li içeriği görünmez bırakırdı.
  Animate animateSafe(BuildContext context) {
    final enabled = context.motionEnabled;
    return animate(autoPlay: enabled, value: enabled ? 0 : 1);
  }
}
