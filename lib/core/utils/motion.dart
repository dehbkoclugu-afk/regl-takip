import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Sistem "animasyonları azalt / kaldır" ayarına saygı için yardımcı.
extension MotionContext on BuildContext {
  bool get motionEnabled => !MediaQuery.disableAnimationsOf(this);

  /// Örtük animasyonların (AnimatedContainer, AnimatedSwitcher,
  /// AnimatedScale, TweenAnimationBuilder…) süresi.
  ///
  /// [MotionAnimate.animateSafe] yalnız flutter_animate efektlerini
  /// kapsıyordu; örtük animasyonlar ayarı kendiliğinden dinlemiyor.
  /// Altı yerde elle `motionEnabled ? ... : Duration.zero` yazılmıştı,
  /// on dokuz yerde hiç yazılmamıştı — kalıp tek yere toplandı.
  ///
  /// Süre sıfır olunca widget hedef durumuna anında geçer: içerik kaybolmaz
  /// (flutter_animate'te `autoPlay: false`'un tek başına bıraktığı tuzak),
  /// yalnız geçiş oynatılmaz.
  Duration motionDuration(Duration duration) =>
      motionEnabled ? duration : Duration.zero;
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
