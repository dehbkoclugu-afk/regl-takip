import 'dart:async';
import 'purchase_verifier.dart';
import 'usage_metrics.dart';
import 'entitlement_cache.dart';

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
/// - premium_no_ads   (tek seferlik ömür boyu premium; eski hak korunur)
enum PurchaseFlowState {
  idle,
  launching,
  pending,
  verifying,
  success,
  canceled,
  error
}

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
  ProductDetails? lifetimeProduct;

  /// Ürün detayları mağazadan asenkron gelir. Paywall bu bildiriciyi dinler:
  /// aksi halde ekran ürünler dönmeden açıldığında tanıtım fiyatlarında
  /// donup kalıyordu (rebuild tetikleyen hiçbir şey yoktu) ve kullanıcı
  /// mağaza ekranında başka bir rakamla karşılaşıyordu.
  final ValueNotifier<int> productsRevision = ValueNotifier(0);

  bool storeAvailable = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final purchaseState = ValueNotifier(PurchaseFlowState.idle);
  bool get purchaseBusy => [
        PurchaseFlowState.launching,
        PurchaseFlowState.pending,
        PurchaseFlowState.verifying
      ].contains(purchaseState.value);
  Future<void> _purchaseQueue = Future.value();

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
      await _setPremium(EntitlementCache.active(prefs, DateTime.now()));

      storeAvailable = await InAppPurchase.instance.isAvailable();
      if (!storeAvailable) {
        productsRevision.value++;
        return;
      }

      _subscription =
          InAppPurchase.instance.purchaseStream.listen(_onPurchaseUpdates);

      final response =
          await InAppPurchase.instance.queryProductDetails(_productIds);
      for (final product in response.productDetails) {
        if (product.id == monthlyId) monthlyProduct = product;
        if (product.id == yearlyId) yearlyProduct = product;
        if (product.id == legacyId) lifetimeProduct = product;
      }
      // Sorgu sonuçsuz bitse de haber ver: paywall "hâlâ yükleniyor" ile
      // "mağaza ürünü döndürmedi" durumlarını ancak böyle ayırt edebilir
      productsRevision.value++;

      // Sessiz geri yükleme: cihaz değişiminde ve abonelik yenilemelerinde
      // haklar otomatik döner
      await InAppPurchase.instance.restorePurchases();

      // Expiration is supplied by the verification server, not a guessed 35-day
      // window. Preserve legacy paid access until migration can be verified.
    } catch (e) {
      debugPrint('[IAP] init failed: $e');
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) {
    final next = _purchaseQueue.then((_) => _handlePurchases(purchases));
    _purchaseQueue = next.catchError((Object _) {});
    return next;
  }

  Future<void> refreshCachedEntitlement() {
    final next = _purchaseQueue.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await _setPremium(EntitlementCache.active(prefs, DateTime.now()));
    });
    _purchaseQueue = next.catchError((Object _) {});
    return _purchaseQueue;
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (!_productIds.contains(purchase.productID)) continue;
      if (purchase.status == PurchaseStatus.pending) {
        purchaseState.value = PurchaseFlowState.pending;
        continue;
      }
      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        purchaseState.value = purchase.status == PurchaseStatus.canceled
            ? PurchaseFlowState.canceled
            : PurchaseFlowState.error;
        continue;
      }
      try {
        purchaseState.value = PurchaseFlowState.verifying;
        final entitlement = await PurchaseVerifier().verify(purchase);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_verifiedKey, DateTime.now().millisecondsSinceEpoch);
        await _setPremium(
            await EntitlementCache.save(prefs, entitlement, DateTime.now()));
        if (entitlement.active) {
          await UsageMetrics.record(UsageEvent.verifiedPurchase);
        }
        // Only acknowledge after authoritative verification has succeeded.
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        purchaseState.value = entitlement.active
            ? PurchaseFlowState.success
            : PurchaseFlowState.error;
      } catch (_) {
        purchaseState.value = PurchaseFlowState.error;
        // Keep unacknowledged purchase retryable; never grant unverified access.
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
    if (details == null || purchaseBusy || !PurchaseVerifier.configured) {
      return false;
    }
    purchaseState.value = PurchaseFlowState.launching;
    try {
      final started = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: details),
      );
      if (!started) purchaseState.value = PurchaseFlowState.error;
      return started;
    } catch (_) {
      purchaseState.value = PurchaseFlowState.error;
      return false;
    }
  }

  Future<bool> buyMonthly() => buy(monthlyProduct);
  Future<bool> buyYearly() => buy(yearlyProduct);
  Future<bool> buyLifetime() => buy(lifetimeProduct);

  /// Geri yükleme akışı; hak dönerse true.
  ///
  /// `restorePurchases()` yalnız akışı başlatır, haklar `purchaseStream`
  /// üzerinden asenkron gelir. Sonucu beklemeden dönülürse arayüz kullanıcıya
  /// hiçbir şey söyleyemiyor: buton basılıyor ve geri yüklenecek bir şey
  /// yoksa ekranda hiçbir şey olmuyordu. Verilen pencerede hak gelmezse
  /// geri yüklenecek bir şey yok kabul edilir.
  Future<bool> restore({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    if (isPremium) return true;

    final completer = Completer<bool>();
    void onEntitlement() {
      if (isPremiumNotifier.value && !completer.isCompleted) {
        completer.complete(true);
      }
    }

    isPremiumNotifier.addListener(onEntitlement);
    try {
      await InAppPurchase.instance.restorePurchases();
      return await completer.future.timeout(timeout, onTimeout: () => false);
    } catch (e) {
      debugPrint('[IAP] restore failed: $e');
      return false;
    } finally {
      isPremiumNotifier.removeListener(onEntitlement);
    }
  }

  void dispose() {
    _subscription?.cancel();
    productsRevision.dispose();
  }
}
