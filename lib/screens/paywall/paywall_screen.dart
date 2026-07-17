import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../services/premium_service.dart';

/// Premium teklif ekranı. Deneme sürerken üst bilgi kalan günü söyler;
/// deneme bittiyse ücretsiz katmanın kapsamını açıklar. Fiyatlar mağazadan
/// gelir; mağaza cevap vermediyse tanıtım fiyatları gösterilir (satın alma
/// yine mağaza üzerinden doğrulanır).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _busy = false;

  Future<void> _buy(Future<bool> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final started = await action();
      if (!started && mounted) {
        messenger.showSnackBar(SnackBar(
            content: Text(l10n.storeUnavailable),
            backgroundColor: AppColors.warning));
      }
      // Sonuç purchaseStream'den gelir; isPremiumProvider köprüyle döner —
      // build'deki dinleyici ekranı kendiliğinden kapatır
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final access = ref.watch(accessProvider);
    final daysLeft = ref.watch(trialDaysLeftProvider);
    final service = PremiumService();

    // Satın alma tamamlandığında ekran görevini bitirmiş demektir
    ref.listen(isPremiumProvider, (prev, next) {
      if (next == true && mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final monthlyPrice = service.monthlyProduct?.price ?? '₺29';
    final yearlyPrice = service.yearlyProduct?.price ?? '₺199';

    final features = [
      (Icons.edit_calendar_rounded, l10n.paywallFeatureTrackers),
      (Icons.insights_rounded, l10n.paywallFeatureStats),
      (Icons.auto_awesome_rounded, l10n.paywallFeatureInsights),
      (Icons.picture_as_pdf_rounded, l10n.paywallFeatureExport),
      (Icons.favorite_rounded, l10n.paywallFeatureHealth),
      (Icons.visibility_off_rounded, l10n.paywallFeatureDisguise),
      (Icons.block_rounded, l10n.paywallFeatureNoAds),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.tp(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.workspace_premium_rounded,
                  size: 48, color: AppColors.primaryStrong),
              const SizedBox(height: 12),
              Text(
                l10n.paywallTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.tp(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                access == AccessLevel.trial
                    ? l10n.paywallTrialSubtitle(daysLeft)
                    : l10n.paywallFreeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.ts(context),
                ),
              ),
              const SizedBox(height: 24),
              // Özellikler
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(f.$1, size: 20, color: AppColors.primaryStrong),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(f.$2,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.tp(context))),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              // Yıllık plan — vurgulu
              _PlanCard(
                title: l10n.planYearly,
                price: yearlyPrice,
                suffix: l10n.perYear,
                badge: l10n.bestValue,
                highlighted: true,
                busy: _busy,
                onTap: () => _buy(service.buyYearly),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: l10n.planMonthly,
                price: monthlyPrice,
                suffix: l10n.perMonth,
                highlighted: false,
                busy: _busy,
                onTap: () => _buy(service.buyMonthly),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy ? null : () => service.restore(),
                child: Text(l10n.restorePurchases),
              ),
              TextButton(
                onPressed:
                    _busy ? null : () => Navigator.of(context).maybePop(),
                child: Text(
                  access == AccessLevel.free
                      ? l10n.continueFreeBtn
                      : l10n.maybeLater,
                  style: TextStyle(color: AppColors.ts(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String suffix;
  final String? badge;
  final bool highlighted;
  final bool busy;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.suffix,
    this.badge,
    required this.highlighted,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $price$suffix',
      child: Material(
        color: highlighted
            ? AppColors.primaryStrong
            : AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: busy ? null : onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: highlighted
                  ? null
                  : Border.all(color: AppColors.dv(context)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: highlighted
                                    ? Colors.white
                                    : AppColors.tp(context),
                              )),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(badge!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryStrong,
                                  )),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text('$price$suffix',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: highlighted
                          ? Colors.white
                          : AppColors.tp(context),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
