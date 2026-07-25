import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/providers.dart';
import '../../services/premium_service.dart';

/// Premium teklif ekranı. Deneme sürerken üst bilgi kalan günü söyler;
/// deneme bittiyse ücretsiz katmanın kapsamını açıklar. Fiyatlar yalnız
/// mağazadan gelir ve geldiklerinde ekran kendini tazeler; gelene kadar
/// plan kartlarında fiyat yerine bekleme göstergesi durur.
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

  /// Geri yükleme sonucu kullanıcıya söylenmeli: hak dönerse ekran zaten
  /// kendiliğinden kapanıyor, dönmezse sessiz kalmak butonu bozuk gösteriyordu.
  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(l10n.restoringPurchases)));
    try {
      final restored = await PremiumService().restore();
      if (!mounted) return;
      if (!restored) {
        messenger.showSnackBar(
            SnackBar(content: Text(l10n.noPurchasesToRestore)));
      }
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
              // Kullanıcının biriktirdiği veri, özellik listesinden daha
              // somut bir argüman: soyut vaat yerine kendi emeği. Verinin
              // silinmediğini söylemek de deneme bitişinin en büyük
              // korkusunu doğrudan karşılıyor.
              _buildYourDataCard(context, l10n, ref),
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
              // Fiyatlar mağazadan asenkron gelir; sabit bir tanıtım fiyatı
              // göstermek kullanıcının mağaza ekranında başka rakam görmesi
              // demekti (ülkeye/kura/indirime göre değişir). Gelene kadar
              // fiyat yerine bekleme göstergesi var.
              ValueListenableBuilder<int>(
                valueListenable: service.productsRevision,
                builder: (context, revision, _) {
                  final resolved = revision > 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Yıllık plan — vurgulu
                      _PlanCard(
                        title: l10n.planYearly,
                        price: service.yearlyProduct?.price,
                        suffix: l10n.perYear,
                        badge: l10n.bestValue,
                        highlighted: true,
                        busy: _busy,
                        onTap: () => _buy(service.buyYearly),
                      ),
                      const SizedBox(height: 12),
                      _PlanCard(
                        title: l10n.planMonthly,
                        price: service.monthlyProduct?.price,
                        suffix: l10n.perMonth,
                        highlighted: false,
                        busy: _busy,
                        onTap: () => _buy(service.buyMonthly),
                      ),
                      // Mağaza cevap verdi ama ürünleri döndürmediyse sebebi
                      // söylenmeli — boş kartlara bakıp beklemesin
                      if (resolved &&
                          service.yearlyProduct == null &&
                          service.monthlyProduct == null) ...[
                        const SizedBox(height: 12),
                        Text(
                          l10n.storeUnavailable,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.ts(context),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy ? null : _restore,
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

/// "Bunlar sende kalır" kartı: kayıt sayıları + verinin silinmeyeceği sözü.
/// Hiç veri yoksa çizilmez — boş bir "0 kayıt" kartı argümanın tersini
/// söylerdi.
Widget _buildYourDataCard(
    BuildContext context, AppLocalizations l10n, WidgetRef ref) {
  final cycles = ref.watch(periodRecordsProvider).length;
  final logs = ref.watch(dailyLogProvider).length;
  if (cycles == 0 && logs == 0) return const SizedBox.shrink();

  final parts = <String>[
    if (cycles > 0) l10n.nCyclesRecorded(cycles),
    if (logs > 0) l10n.nLogsRecorded(logs),
  ];

  return Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.sf(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.dv(context)),
    ),
    child: Row(
      children: [
        Icon(Icons.inventory_2_rounded,
            size: 20, color: AppColors.primaryStrong),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parts.join(' · '),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tp(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.yourDataStays,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.ts(context),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlanCard extends StatelessWidget {
  final String title;

  /// Mağazadan gelen yerelleştirilmiş fiyat. Henüz gelmediyse null: kart
  /// bekleme göstergesi gösterir ve dokunmaya kapalıdır — uydurma bir fiyat
  /// göstermektense beklemek dürüst olan.
  final String? price;
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
    final ready = price != null;
    final foreground = highlighted ? Colors.white : AppColors.tp(context);

    return Semantics(
      button: true,
      enabled: ready && !busy,
      label: ready ? '$title, $price$suffix' : title,
      child: Material(
        color: highlighted
            ? AppColors.primaryStrong
            : AppColors.sf(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (busy || !ready) ? null : onTap,
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
                                color: foreground,
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
                if (ready)
                  Text('$price$suffix',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ))
                else
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
