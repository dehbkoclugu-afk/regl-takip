import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/motion.dart';

class PredictionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? infoText;

  const PredictionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.infoText,
  });

  void _showInfoDialog(BuildContext context) {
    if (infoText == null) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.sf(context).withValues(alpha: 0.95),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.15)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(infoText!,
            style: TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: infoText != null ? () => _showInfoDialog(context) : null,
        child: GlassCard(
          borderRadius: 20,
          blur: 0,
          opacity: 0.18,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.25),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ts(context),
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (infoText != null) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.info_outline_rounded,
                        size: 12, color: AppColors.ts(context)),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tp(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PredictionCardsRow extends StatelessWidget {
  final String nextPeriodDate;
  final String ovulationDate;
  final String fertileWindowDate;

  /// Sıcaklık verisinden teyit edildiyse true — ovülasyon kartı
  /// tahmin değil ölçüm gösterdiğini belli eder
  final bool ovulationConfirmed;

  const PredictionCardsRow({
    super.key,
    required this.nextPeriodDate,
    required this.ovulationDate,
    required this.fertileWindowDate,
    this.ovulationConfirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        PredictionCard(
          icon: Icons.water_drop_rounded,
          title: l10n.nextPeriod,
          value: nextPeriodDate,
          color: AppColors.menstrual,
          infoText: l10n.nextPeriodInfo,
        ),
        PredictionCard(
          icon: ovulationConfirmed
              ? Icons.verified_rounded
              : Icons.egg_rounded,
          title: ovulationConfirmed
              ? l10n.ovulationConfirmed
              : l10n.ovulation,
          value: ovulationDate,
          color: AppColors.ovulation,
          infoText: ovulationConfirmed
              ? l10n.ovulationConfirmedInfo
              : l10n.ovulationCardInfo,
        ),
        PredictionCard(
          icon: Icons.favorite_rounded,
          title: l10n.fertileWindow,
          value: fertileWindowDate,
          color: AppColors.fertileWindow,
          infoText: l10n.fertileWindowInfo,
        ),
      ],
    )
        .animateSafe(context)
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.15, end: 0, delay: 400.ms, duration: 600.ms);
  }
}
