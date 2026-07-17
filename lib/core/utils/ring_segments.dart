import 'dart:math' as math;
import 'dart:ui';

import '../theme/app_colors.dart';
import 'cycle_utils.dart';

/// Ring segmenti: döngü günleri [startDay..endDay] aralığını kaplar.
/// (Dashboard ring'inden core'a taşındı: takvim faz şeridi ve ana ekran
/// widget'ı aynı harita mantığını paylaşıyor — imza görsel tek kaynaktan.)
class RingSegment {
  final int startDay;
  final int endDay;
  final Color color;

  const RingSegment(this.startDay, this.endDay, this.color);
}

/// Döngüyü faz segmentlerine böler — ilerleme çubuğu değil, fazların
/// haritası: regl / folliküler / fertil bant / luteal.
List<RingSegment> ringSegmentsFor(int cycleLength, int periodLength) {
  final ovulationDay = CycleUtils.ovulationDayNumber(cycleLength);
  final period = periodLength.clamp(1, cycleLength);
  // Kısa döngüde fertil pencere regl günlerine taşabilir; haritada regl
  // bandı görsel önceliklidir — fertil bant regl bitiminden erken başlamaz
  final fertileStart = (ovulationDay - 5).clamp(period + 1, cycleLength);
  final fertileEnd = (ovulationDay + 1).clamp(1, cycleLength);

  final segments = <RingSegment>[
    RingSegment(1, period, AppColors.ringMenstrual),
  ];
  if (fertileStart > period + 1) {
    segments.add(
        RingSegment(period + 1, fertileStart - 1, AppColors.ringFollicular));
  }
  if (fertileEnd >= fertileStart) {
    segments.add(RingSegment(fertileStart, fertileEnd, AppColors.ringFertile));
  }
  final lutealStart = math.max(fertileEnd, period) + 1;
  if (lutealStart <= cycleLength) {
    segments.add(RingSegment(lutealStart, cycleLength, AppColors.ringLuteal));
  }
  return segments;
}

/// Verilen döngü günü hangi segmentteyse rengini döndürür.
Color segmentColorForDay(List<RingSegment> segments, int day) {
  for (final s in segments) {
    if (day >= s.startDay && day <= s.endDay) return s.color;
  }
  return segments.isEmpty ? const Color(0x00000000) : segments.last.color;
}
