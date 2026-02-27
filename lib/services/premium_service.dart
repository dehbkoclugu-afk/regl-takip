import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _trialStartKey = 'trial_start_date';
  static const String _isPremiumKey = 'is_premium';
  static const String productId = 'regl_monthly';
  static const int trialDays = 30;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];
  bool _initialized = false;

  /// Callback for when premium status changes
  VoidCallback? onPremiumChanged;

  /// İlk açılışta çağrılır - trial başlangıç tarihini kaydeder
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();

    // İlk kez açılıyorsa trial başlat
    if (!prefs.containsKey(_trialStartKey)) {
      await prefs.setString(
        _trialStartKey,
        DateTime.now().toIso8601String(),
      );
      debugPrint('Trial started: ${DateTime.now()}');
    }
  }

  /// Premium durumunu kontrol eder
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isPremiumKey) ?? false;
  }

  /// Premium durumunu ayarlar
  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, value);
    onPremiumChanged?.call();
  }

  /// Trial başlangıç tarihini döndürür
  Future<DateTime?> getTrialStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_trialStartKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  /// Trial bitiş tarihini döndürür
  Future<DateTime?> getTrialEndDate() async {
    final start = await getTrialStartDate();
    if (start == null) return null;
    return start.add(const Duration(days: trialDays));
  }

  /// Trial süresi aktif mi?
  Future<bool> isTrialActive() async {
    final endDate = await getTrialEndDate();
    if (endDate == null) return true;
    return DateTime.now().isBefore(endDate);
  }

  /// Kalan trial gün sayısı
  Future<int> remainingTrialDays() async {
    final endDate = await getTrialEndDate();
    if (endDate == null) return trialDays;
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining.clamp(0, trialDays);
  }

  /// Uygulamaya erişim var mı? (premium veya trial aktif)
  Future<bool> hasAccess() async {
    if (await isPremium()) return true;
    return await isTrialActive();
  }

  /// IAP başlat ve ürünleri yükle
  Future<void> initializeIAP() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (e) => debugPrint('IAP stream error: $e'),
    );

    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Product not found: ${response.notFoundIDs}');
    }
    products = response.productDetails;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == productId) {
          setPremium(true);
          debugPrint('Premium activated via purchase');
        }
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Abonelik satın al
  Future<void> buySubscription() async {
    if (products.isEmpty) {
      debugPrint('No products available');
      return;
    }
    final param = PurchaseParam(productDetails: products.first);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Satın alımları geri yükle
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
