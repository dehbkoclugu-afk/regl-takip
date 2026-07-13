import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/cycle_utils.dart';

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
        return const Color(0xFFD4607E);
      case CyclePhase.follicular:
        return const Color(0xFFE8944A);
      case CyclePhase.ovulation:
        return const Color(0xFF9060A8);
      case CyclePhase.luteal:
        return const Color(0xFFE8A830);
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(140),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
            boxShadow: [
              BoxShadow(
                color: _ringColor.withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircularPercentIndicator(
            radius: 110.0,
            lineWidth: 16.0,
            animation: true,
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
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 600.ms);
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
