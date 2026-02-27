import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../services/premium_service.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback? onPremiumActivated;

  const PaywallScreen({super.key, this.onPremiumActivated});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final _premiumService = PremiumService();
  bool _loading = true;
  bool _purchasing = false;
  String _price = '₺29,90/ay';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _premiumService.initializeIAP();
    if (_premiumService.products.isNotEmpty) {
      _price = '${_premiumService.products.first.price}/ay';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    try {
      await _premiumService.buySubscription();
      await Future.delayed(const Duration(seconds: 2));
      if (await _premiumService.isPremium() && mounted) {
        widget.onPremiumActivated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alma başarısız: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    try {
      await _premiumService.restorePurchases();
      await Future.delayed(const Duration(seconds: 2));
      if (await _premiumService.isPremium() && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Abonelik geri yüklendi!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onPremiumActivated?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Aktif abonelik bulunamadı.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.secondary.withValues(alpha: 0.08),
                    AppColors.bg(context),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Premium icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.diamond_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        'Premium\'a Geç',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tp(context),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Deneme süreniz sona erdi.\nPremium ile tüm özelliklere erişmeye devam edin!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.ts(context),
                          height: 1.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                      const SizedBox(height: 32),
                      // Features
                      ..._buildFeatures(context)
                          .animate(interval: 100.ms)
                          .fadeIn(delay: 400.ms, duration: 400.ms)
                          .slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 32),
                      // Price card
                      GlassCard(
                        borderRadius: 28,
                        blur: 15,
                        opacity: 0.2,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '1 Ay Ücretsiz Deneme',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'sonrasında',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.ts(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _price,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.tp(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'İstediğin zaman iptal edebilirsin',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.ts(context),
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 500.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      // Purchase button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _purchasing ? null : _purchase,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: _purchasing
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Abone Ol',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                      const SizedBox(height: 16),
                      // Restore button
                      TextButton(
                        onPressed: _purchasing ? null : _restore,
                        child: Text(
                          'Satın Alımları Geri Yükle',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.ts(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> _buildFeatures(BuildContext context) {
    final features = [
      (Icons.block_rounded, 'Reklamsız Deneyim', 'Tüm reklamlar kaldırılır'),
      (Icons.all_inclusive_rounded, 'Sınırsız Erişim', 'Tüm özellikler açık'),
      (Icons.insights_rounded, 'Detaylı İstatistik', 'Gelişmiş döngü analizi'),
      (Icons.update_rounded, 'Erken Erişim', 'Yeni özellikler önce sizde'),
    ];

    return features.map((f) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          borderRadius: 20,
          blur: 10,
          opacity: 0.15,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.secondary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(f.$1, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tp(context),
                      ),
                    ),
                    Text(
                      f.$3,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.ts(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
