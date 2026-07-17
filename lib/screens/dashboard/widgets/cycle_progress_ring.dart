import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cycle_utils.dart';
import '../../../core/utils/motion.dart';
import '../../../core/utils/ring_segments.dart';

export '../../../core/utils/ring_segments.dart' show RingSegment, ringSegmentsFor;

class CycleProgressRing extends StatelessWidget {
  final int cycleDay;
  final int cycleLength;
  final int periodLength;
  final CyclePhase phase;
  final int daysUntilNextPeriod;

  const CycleProgressRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
    this.periodLength = 5,
    required this.phase,
    required this.daysUntilNextPeriod,
  });

  /// Daha koyu/doygun ring rengi - arka plandan ayrışması için
  Color get _ringColor {
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.ringMenstrual;
      case CyclePhase.follicular:
        return AppColors.ringFollicular;
      case CyclePhase.ovulation:
        return AppColors.ringOvulation;
      case CyclePhase.luteal:
        return AppColors.ringLuteal;
    }
  }

  /// Merkezdeki METİN için renk: açık zeminde ring tonları (özellikle
  /// folliküler/luteal turuncu-amber) 3:1'in bile altında kalıyordu —
  /// açık temada koyulaştırılmış metin tonu, koyu temada ring tonu.
  Color _textColor(bool isDark) {
    if (isDark) return _ringColor;
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.menstrualText;
      case CyclePhase.follicular:
        return AppColors.follicularText;
      case CyclePhase.ovulation:
        return AppColors.ovulationText;
      case CyclePhase.luteal:
        return AppColors.lutealText;
    }
  }

  IconData get _phaseIcon {
    switch (phase) {
      case CyclePhase.menstrual:
        return Icons.water_drop_rounded;
      case CyclePhase.follicular:
        return Icons.spa_rounded;
      case CyclePhase.ovulation:
        return Icons.auto_awesome_rounded;
      case CyclePhase.luteal:
        return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = AppColors.isDark(context);
    final motion = context.motionEnabled;

    // Faz değişiminde (ör. "Reglim başladı") ışıma ve merkez renkleri
    // atlamaz, yeni faza yumuşakça akar — motion bütçesi asıl bu ana
    final phaseShift = motion
        ? const Duration(milliseconds: 600)
        : Duration.zero;

    final ring = AnimatedContainer(
      duration: phaseShift,
      curve: Curves.easeOutQuart,
      width: 264,
      height: 264,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.65),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        // Hero ışıması: yalnız ring'de — yumuşak, faz renginde hale
        boxShadow: [
          BoxShadow(
            color: _ringColor.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _SegmentedRingPainter(
          segments: ringSegmentsFor(cycleLength, periodLength),
          cycleLength: cycleLength,
          todayDay: cycleDay,
          ovulationDay: CycleUtils.ovulationDayNumber(cycleLength),
          trackColor: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        child: Center(child: _buildCenterContent(l10n, context)),
      ),
    );

    // Ekran okuyucu için ring tek bir özet olarak duyurulur
    final labeled = Semantics(
      label:
          '${l10n.cycleDay}: $cycleDay / $cycleLength. '
          '${daysUntilNextPeriod > 0 ? l10n.daysLater(daysUntilNextPeriod) : l10n.todayExclamation}',
      child: ExcludeSemantics(child: ring),
    );

    if (!motion) return labeled;
    return labeled
        .animateSafe(context)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOutQuart,
        )
        .fadeIn(duration: 500.ms);
  }

  Widget _buildCenterContent(AppLocalizations l10n, BuildContext context) {
    final textColor = _textColor(AppColors.isDark(context));
    final phaseShift = context.motionEnabled
        ? const Duration(milliseconds: 600)
        : Duration.zero;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_phaseIcon, size: 26, color: _ringColor),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: phaseShift,
          curve: Curves.easeOutQuart,
          // Metrik ölçeği temadan (tabular w800) — kahraman sayı dili
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(color: textColor),
          child: Text('$cycleDay'),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.day,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.tp(context),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: phaseShift,
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _ringColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AnimatedDefaultTextStyle(
            duration: phaseShift,
            curve: Curves.easeOutQuart,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            child: Text(
              daysUntilNextPeriod > 0
                  ? l10n.daysLater(daysUntilNextPeriod)
                  : l10n.todayExclamation,
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedRingPainter extends CustomPainter {
  final List<RingSegment> segments;
  final int cycleLength;
  final int todayDay;
  final int ovulationDay;
  final Color trackColor;

  static const _stroke = 16.0;
  static const _inset = 22.0; // dış kenardan yay merkezine mesafe
  static const _gapRadians = 0.035; // segmentler arası nefes boşluğu

  _SegmentedRingPainter({
    required this.segments,
    required this.cycleLength,
    required this.todayDay,
    required this.ovulationDay,
    required this.trackColor,
  });

  /// Gün -> açı: gün 1 üstten (saat 12) başlar, saat yönünde ilerler.
  /// Bir günün yay aralığı [dayStartAngle(d), dayStartAngle(d+1)).
  double _dayStartAngle(int day) =>
      -math.pi / 2 + (day - 1) / cycleLength * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - _inset;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Zemin izi
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    // Faz segmentleri
    for (final segment in segments) {
      final start = _dayStartAngle(segment.startDay) + _gapRadians / 2;
      final end = _dayStartAngle(segment.endDay + 1) - _gapRadians / 2;
      if (end <= start) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round
        ..color = segment.color;
      canvas.drawArc(rect, start, end - start, false, paint);
    }

    // Ovülasyon işareti: bandın içinde koyu mor nokta
    final ovAngle = _dayStartAngle(ovulationDay) +
        math.pi / cycleLength; // gün ortası
    final ovCenter = Offset(
      center.dx + radius * math.cos(ovAngle),
      center.dy + radius * math.sin(ovAngle),
    );
    canvas.drawCircle(
        ovCenter, 5, Paint()..color = AppColors.ringOvulation);

    // Bugün işareti: beyaz halkalı nokta — haritada "buradasın"
    final todayAngle =
        _dayStartAngle(todayDay.clamp(1, cycleLength)) +
            math.pi / cycleLength;
    final todayCenter = Offset(
      center.dx + radius * math.cos(todayAngle),
      center.dy + radius * math.sin(todayAngle),
    );
    canvas.drawCircle(todayCenter, 9, Paint()..color = Colors.white);
    canvas.drawCircle(
        todayCenter,
        6,
        Paint()
          ..color = segments
              .firstWhere(
                (s) => todayDay >= s.startDay && todayDay <= s.endDay,
                orElse: () => segments.last,
              )
              .color);
  }

  @override
  bool shouldRepaint(_SegmentedRingPainter oldDelegate) =>
      oldDelegate.todayDay != todayDay ||
      oldDelegate.cycleLength != cycleLength ||
      oldDelegate.trackColor != trackColor;
}
