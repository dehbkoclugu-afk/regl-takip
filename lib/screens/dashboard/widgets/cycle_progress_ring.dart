import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Color get _phaseColor {
    switch (phase) {
      case CyclePhase.menstrual:
        return AppColors.menstrual;
      case CyclePhase.follicular:
        return AppColors.follicular;
      case CyclePhase.ovulation:
        return AppColors.ovulation;
      case CyclePhase.luteal:
        return AppColors.luteal;
    }
  }

  Color get _phaseBackgroundColor {
    return _phaseColor.withValues(alpha: 0.15);
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _phaseColor.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CircularPercentIndicator(
        radius: 110.0,
        lineWidth: 14.0,
        animation: true,
        animationDuration: 1500,
        percent: progress,
        center: _buildCenterContent(l10n),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: _phaseColor,
        backgroundColor: _phaseBackgroundColor,
        backgroundWidth: 8.0,
        startAngle: 270.0,
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

  Widget _buildCenterContent(AppLocalizations l10n) {
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
          style: GoogleFonts.plusJakartaSans(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          l10n.day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            daysUntilNextPeriod > 0
                ? l10n.daysLater(daysUntilNextPeriod)
                : l10n.todayExclamation,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
