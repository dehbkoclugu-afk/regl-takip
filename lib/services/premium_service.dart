import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Premium abonelik servisi.
///
/// Model: 30 gün ücretsiz tam deneme (deneme başlangıcı SharedPreferences'ta
/// — "tüm verileri sil" Hive'ı temizler ama denemeyi sıfırlamaz), sonrasında
/// abonelik yoksa yalnız regl takibi (erişim kararı providers'taki
/// accessProvider'da).
///
/// Ürünler (Play Console'da abonelik olarak tanımlanmalı):
/// - premium_monthly  (₺29/ay)
/// - premium_yearly   (₺199/yıl)
/// - premium_no_ads   (eski tek seferlik alıcılar — hak korunur)
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String monthlyId = 'premium_monthly';
  static const String yearlyId = 'premium_yearly';
  static const String legacyId = 'premium_no_ads';
  static const Set<String> _productIds = {monthlyId, yearlyId, legacyId};

  static const String _prefsKey = 'premium_active';
  static const String _verifiedKey = 'premium_last_verified_epoch';
  static const String trialStartKey = 'trial_start_epoch';
  static const int trialDays = 30;

  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);
  bool get isPremium => isPremiumNotifier.value;

  ProductDetails? monthlyProduct;
  ProductDetails? yearlyProduct;
  bool storeAvailable = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _sawEntitlementThisSession = false;

  /// Deneme başlangıcını okur; hiç yoksa şimdi başlatır ve kalıcılaştırır.
  static Future<DateTime> ensureTrialStart() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(trialStartKey);
    if (stored != null) {
      return DateTime.fromMillisecondsSinceEpoch(stored);
    }
    final now = DateTime.now();
    await prefs.setInt(trialStartKey, now.millisecondsSinceEpoch);
    return now;
  }

  Future<void> init() async {
    try {
      // Önce yerel önbellek: mağazaya ulaşılamasa da premium kalır
      final prefs = await SharedPreferences.getInstance();
      isPremiumNotifier.value = prefs.getBool(_prefsKey) ?? false;

      storeAvailable = await InAppPurchase.instance.isAvailable();
      if (!storeAvailable) return;

      _subscription =
          InAppPurchase.instance.purchaseStream.listen(_onPurchaseUpdates);

      final response =
          await InAppPurchase.instance.queryProductDetails(_productIds);
      for (final product in response.productDetails) {
        if (product.id == monthlyId) monthlyProduct = product;
        if (product.id == yearlyId) yearlyProduct = product;
      }

      // Sessiz geri yükleme: cihaz değişiminde ve abonelik yenilemelerinde
      // haklar otomatik döner
      await InAppPurchase.instance.restorePurchases();

      // Sunucusuz süre kontrolü: abonelik bitince mağaza restore'da artık
      // hak göndermez. Önbellek "premium" diyor ama 35+ gündür mağazadan
      // teyit gelmediyse ve bu oturumda da gelmediyse hak düşmüş demektir.
      // (10 sn: restore olaylarının akışa düşmesi için pay.)
      unawaited(Future.delayed(const Duration(seconds: 10), () async {
        if (!isPremiumNotifier.value ||
            _sawEntitlementThisSession ||
            !storeAvailable) {
          return;
        }
        final verified = prefs.getInt(_verifiedKey);
        final stale = verified == null ||
            DateTime.now()
                    .difference(
                        DateTime.fromMillisecondsSinceEpoch(verified))
                    .inDays >
                35;
        if (stale) {
          debugPrint('[IAP] entitlement stale, downgrading');
          await _setPremium(false);
        }
      }));
    } catch (e) {
      debugPrint('[IAP] init failed: $e');
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (_productIds.contains(purchase.productID) &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        _sawEntitlementThisSession = true;
        await _setPremium(true);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            _verifiedKey, DateTime.now().millisecondsSinceEpoch);
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    isPremiumNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  /// Abonelik satın alma akışını başlatır. Sonuç purchaseStream'den gelir.
  Future<bool> buy(ProductDetails? details) async {
    if (details == null) return false;
    return InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  Future<bool> buyMonthly() => buy(monthlyProduct);
  Future<bool> buyYearly() => buy(yearlyProduct);

  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  void dispose() {
    _subscription?.cancel();
  }
}
