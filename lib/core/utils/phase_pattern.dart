import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../theme/app_colors.dart';

/// Renk körü dostu doku modu: faz renkleri tek başına yeterince
/// ayrışmıyorsa (özellikle folliküler/luteal turuncu ailesi
/// deuteranopiada birbirine karışır) her faza renk + DOKU çifti verilir.
/// Menstrüel bant düz kalır (referans), diğerleri farklı yönde/karakterde
/// desen taşır: folliküler çapraz, fertil noktalı, luteal yatay.

/// Faz rengine göre şerit/çubuk yüzeyleri için desen açısı.
/// null = düz (menstrüel ve nötr zemin).
///
/// Takvim hücreleri kendi pastel paletini kullanıyor (ring tonlarını değil),
/// bu yüzden desen modu açıkken bile düz kalıyorlardı: ovülasyon moru ile
/// regl pembesi deuteranopiada birbirine yakın iki soluk tona düşüyor ve
/// hücrede ayırt edici başka bir şey yok. Aynı fazın takvim karşılığı
/// ring'dekiyle aynı açıyı alır — iki ekranda aynı doku, aynı anlam.
double? patternAngleFor(Color color) {
  final argb = color.toARGB32();
  if (argb == AppColors.ringFollicular.toARGB32()) {
    return math.pi / 4;
  }
  if (argb == AppColors.ringFertile.toARGB32() ||
      argb == AppColors.fertileWindow.toARGB32() ||
      argb == AppColors.fertileWindowLight.toARGB32()) {
    return math.pi / 2;
  }
  if (argb == AppColors.ringLuteal.toARGB32()) return 0;
  // Ovülasyonun ring'de kendi yayı yok (fertil segmentin içinde) ama
  // takvimde kendi hücresi var: fertil pencerenin dikey dokusundan
  // ayrışsın diye ters çapraz
  if (argb == AppColors.ringOvulation.toARGB32() ||
      argb == AppColors.ovulationDay.toARGB32()) {
    return -math.pi / 4;
  }
  return null;
}

/// Küçük renk bantlarının üstüne binen çizgi dokusu (foregroundDecoration).
/// Solukluk (ör. gelecekteki günler) desenden bağımsız — desen beyaz
/// yarı saydam çizgilerle çizilir, alttaki rengi taşır.
Decoration? patternOverlayFor(Color color, {BorderRadius? radius}) {
  final angle = patternAngleFor(color);
  if (angle == null) return null;
  return BoxDecoration(
    borderRadius: radius,
    gradient: LinearGradient(
      transform: GradientRotation(angle),
      tileMode: TileMode.repeated,
      begin: Alignment.topLeft,
      // Kısa gradyan vektörü + repeated = ince şerit dokusu
      end: const Alignment(-0.4, -1.0),
      colors: [
        const Color(0x00FFFFFF),
        const Color(0x00FFFFFF),
        const Color(0x8CFFFFFF),
        const Color(0x8CFFFFFF),
      ],
      stops: const [0.0, 0.55, 0.55, 1.0],
    ),
  );
}

/// Ring yayları için kesik çizgi deseni: [çizgi, boşluk] px.
/// null = düz yay (menstrüel).
List<double>? dashIntervalsFor(Color color) {
  if (color.toARGB32() == AppColors.ringFollicular.toARGB32()) {
    return const [7, 6];
  }
  if (color.toARGB32() == AppColors.ringFertile.toARGB32()) {
    return const [2.5, 7];
  }
  if (color.toARGB32() == AppColors.ringLuteal.toARGB32()) {
    return const [14, 6];
  }
  return null;
}

/// Bir yay yolunu kesik çizgilere böler (ring doku overlay'i için).
Path dashArc(Rect rect, double start, double sweep, List<double> intervals) {
  final source = Path()..addArc(rect, start, sweep);
  final dashed = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    var draw = true;
    var i = 0;
    while (distance < metric.length) {
      final len = intervals[i % intervals.length];
      if (draw) {
        dashed.addPath(
            metric.extractPath(distance, distance + len), Offset.zero);
      }
      distance += len;
      draw = !draw;
      i++;
    }
  }
  return dashed;
}
