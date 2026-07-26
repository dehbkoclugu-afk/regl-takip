import 'package:flutter/material.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/adaptive_layout.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/motion.dart';

class PredictionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final String? infoText;

  /// Kart verilen boyu doldursun ve tarih altına yaslansın.
  ///
  /// Yalnız üçlü sıra bunu kullanıyor: orada kartların boyu eşitlendiği için
  /// tarihi alta yaslamak üç tarihi aynı hizaya getiriyor. Tek başına dikey
  /// dizildiğinde (büyük yazı) boy sınırsız olur, o durumda esnek çocuk
  /// kullanılamaz — bu yüzden varsayılan kapalı.
  final bool fillHeight;

  const PredictionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.infoText,
    this.fillHeight = false,
  });

  PredictionCard filling() => PredictionCard(
        icon: icon,
        title: title,
        value: value,
        color: color,
        infoText: infoText,
        fillHeight: true,
      );

  void _showInfoDialog(BuildContext context) {
    if (infoText == null) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.sf(context),
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
    // Kart ekran okuyucuya tek parça okunur ("Sonraki regl: 1 Tem") ve
    // bilgi metni varsa buton gibi davranır — dokunuşta ripple verir
    return Semantics(
        button: infoText != null,
        label: '$title: $value',
        child: GlassCard(
          borderRadius: 20,
          blur: 0,
          opacity: 0.18,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: infoText != null ? () => _showInfoDialog(context) : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize:
                        fillHeight ? MainAxisSize.max : MainAxisSize.min,
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
                      ),
                    ),
                  if (infoText != null) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.info_outline_rounded,
                        size: 12, color: AppColors.ts(context)),
                  ],
                ],
              ),
              // Başlık bir kartta bir, diğerinde iki satır olabiliyor; tarihi
              // alta yaslamak üçünü aynı hizada tutuyor.
              if (fillHeight) const Spacer() else const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tp(context),
                ),
                textAlign: TextAlign.center,
              ),
                    ],
                  ),
                ),
              ),
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
    final cards = [
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
    ];
    final content = usesLargeText(MediaQuery.textScalerOf(context))
        ? Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                SizedBox(width: double.infinity, child: cards[i]),
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          )
        // IntrinsicHeight + stretch: üç kart en uzun olanın boyuna eşitlenir.
        // Öncesinde Row ortalama yapıyordu, yani "Verimli Pencere" başlığı
        // iki satıra sardığında o kart uzuyor, diğer ikisi kısa kalıp dikeyde
        // ortalanıyordu — üç kutunun da üst ve alt kenarı birbirini tutmuyordu.
        // Kartlar eşit boya gelince tarihler de aynı hizaya oturuyor
        // (PredictionCard.fillHeight tarihi kartın altına yaslıyor).
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final card in cards)
                  Expanded(child: card.filling()),
              ],
            ),
          );
    return content
        .animateSafe(context)
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.15, end: 0, delay: 400.ms, duration: 600.ms);
  }
}
