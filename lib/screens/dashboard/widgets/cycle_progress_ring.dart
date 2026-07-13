import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cycle_utils.dart';
import '../../../core/utils/motion.dart';

class CycleProgressRing extends StatelessWidget {
  final int cycleDay;
  final int cycleLength;
  final CyclePhase phase;
  final int daysUntilNextPeriod;

  const CycleProgressRing({
    super.key,
    required this.cycleDay,
    required this.cycleLength,
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

  Color get _phaseBackgroundColor {
    return _ringColor.withValues(alpha: 0.15);
  }

  String get _phaseEmoji {
    switch (phase) {
      case CyclePhase.menstrual:
        return '\u{1F339}';
      case CyclePhase.follicular:
        return '\u{1F331}';
      case CyclePhase.ovulation:
        return '\u{2728}';
      case CyclePhase.luteal:
        return '\u{1F319}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double progress = (cycleDay / cycleLength).clamp(0.0, 1.0);
    final isDark = AppColors.isDark(context);
    final motion = context.motionEnabled;

    // Arkasında kayan içerik yok — BackdropFilter gereksiz maliyetti
    final ring = ClipRRect(
      borderRadius: BorderRadius.circular(140),
      child: Container(
          padding: const EdgeInsets.all(28),
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
          child: CircularPercentIndicator(
            radius: 110.0,
            lineWidth: 16.0,
            animation: motion,
            animationDuration: 1500,
            percent: progress,
            center: _buildCenterContent(l10n, context),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: _ringColor,
            backgroundColor: _phaseBackgroundColor,
            backgroundWidth: 6.0,
            startAngle: 270.0,
          ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _phaseEmoji,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          '$cycleDay',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: _ringColor,
            height: 1.0,
          ),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: _ringColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            daysUntilNextPeriod > 0
                ? l10n.daysLater(daysUntilNextPeriod)
                : l10n.todayExclamation,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _ringColor,
            ),
          ),
        ),
      ],
    );
  }
}
