import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tek non-consumable ürün: reklamları kaldırır.
/// Play Console / App Store Connect'te aynı ID ile ürün tanımlanmalı.
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String productId = 'premium_no_ads';
  static const String _prefsKey = 'premium_active';

  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);
  bool get isPremium => isPremiumNotifier.value;

  ProductDetails? product;
  bool storeAvailable = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

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
          await InAppPurchase.instance.queryProductDetails({productId});
      if (response.productDetails.isNotEmpty) {
        product = response.productDetails.first;
      }

      // Sessiz geri yükleme: cihaz değişiminde premium otomatik döner
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      debugPrint('[IAP] init failed: $e');
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        await _setPremium(true);
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

  /// Satın alma akışını başlatır. Sonuç purchaseStream'den gelir.
  Future<bool> buy() async {
    final details = product;
    if (details == null) return false;
    return InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  Future<void> restore() => InAppPurchase.instance.restorePurchases();

  void dispose() {
    _subscription?.cancel();
  }
}
