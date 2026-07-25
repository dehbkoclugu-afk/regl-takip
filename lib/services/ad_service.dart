import 'dart:async';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';

class AdService {
  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  // Interstitial Ad Unit ID'ler
  static const String _openAdUnitIdAndroid =
      'ca-app-pub-2554058432197193/8369610145';
  static const String _openAdUnitIdIOS =
      'ca-app-pub-2554058432197193/1121675519';

  // Test ID
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get _openAdUnitId =>
      _isIOS ? _openAdUnitIdIOS : _openAdUnitIdAndroid;

  static InterstitialAd? _openAd;

  /// Açılış reklamının en son ne zaman gösterildiği (SharedPreferences).
  static const String _lastOpenAdKey = 'last_open_ad_epoch';

  /// İki açılış reklamı arasındaki en az süre.
  ///
  /// Reklam her açılışta gösteriliyordu. Regl takibi "gir-kaydet-çık"
  /// uygulaması: üç saniyelik işin önüne beş saniyelik tam ekran reklam
  /// koymak, uygulamayı açmayı caydırıyor — kaydedilmeyen gün, bozulan
  /// veri, işe yaramayan tahmin demek. Günde bir kez yeterli.
  static const Duration openAdInterval = Duration(hours: 24);

  /// Kurulumdan sonraki bu süre boyunca açılış reklamı hiç gösterilmez.
  /// İlk izlenim reklamla açılmamalı; deneme zaten reklamsız, bu yalnız
  /// denemesi bitmiş kullanıcının yeniden kurulumu gibi durumlar için.
  static const Duration openAdGracePeriod = Duration(days: 1);

  /// Zamana bağlı karar — saf, bu yüzden test edilebilir.
  /// Premium kontrolü ve depolama okuması [canShowOpenAd] tarafında.
  static bool shouldShowOpenAd({
    required DateTime now,
    required DateTime installedAt,
    required DateTime? lastShownAt,
  }) {
    if (now.difference(installedAt) < openAdGracePeriod) return false;
    if (lastShownAt == null) return true;
    return now.difference(lastShownAt) >= openAdInterval;
  }

  /// Açılış reklamı gösterilebilir mi?
  ///
  /// Kararı çağıran yerde değil burada tutmak önemli: gösterim koşulu tek
  /// yerde kalsın, "premium mi" kontrolüyle "ne zaman gösterildi" kontrolü
  /// iki ayrı dosyaya dağılmasın.
  static Future<bool> canShowOpenAd({required DateTime installedAt}) async {
    if (PremiumService().isPremium) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastEpoch = prefs.getInt(_lastOpenAdKey);
    return shouldShowOpenAd(
      now: DateTime.now(),
      installedAt: installedAt,
      lastShownAt: lastEpoch == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastEpoch),
    );
  }

  static Future<void> markOpenAdShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _lastOpenAdKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> initialize() async {
    try {
      // Reklam gösterilmeden önce rıza (UMP): AB/İngiltere kullanıcılarında
      // kişiselleştirilmiş reklam için Google'ın şartı, aksi halde uygulama
      // politika ihlali sayılıyor. Bölge dışında form gösterilmez.
      await _requestConsent();
      await MobileAds.instance.initialize();
      debugPrint('[AD] AdMob initialized successfully');
    } catch (e) {
      debugPrint('[AD] AdMob initialize FAILED: $e');
    }
  }

  static Future<void> _requestConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            ConsentForm.loadAndShowConsentFormIfRequired((error) {
              if (error != null) {
                debugPrint('[AD] consent form error: ${error.message}');
              }
              if (!completer.isCompleted) completer.complete();
            });
          } else if (!completer.isCompleted) {
            completer.complete();
          }
        } catch (e) {
          debugPrint('[AD] consent failed: $e');
          if (!completer.isCompleted) completer.complete();
        }
      },
      (error) {
        debugPrint('[AD] consent info update failed: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Rıza akışı takılırsa uygulama reklamsız devam eder, kilitlenmez
    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => debugPrint('[AD] consent TIMEOUT'),
    );
  }

  static Future<void> loadOpenAd() async {
    // Debug'da test ID (gerçek ID'ye test tıklaması AdMob ban riski),
    // release'te gerçek ID
    final adUnitId = kDebugMode ? _testInterstitialId : _openAdUnitId;
    debugPrint('[AD] Loading ad with ID: $adUnitId (debug=$kDebugMode, iOS=$_isIOS)');

    final completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _openAd = ad;
          debugPrint('[AD] Ad loaded successfully');
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AD] Ad FAILED to load: code=${error.code} domain=${error.domain} message=${error.message}');
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );

    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('[AD] Ad load TIMEOUT (10s)');
      },
    );
  }

  static Future<void> showOpenAd() async {
    if (PremiumService().isPremium) {
      debugPrint('[AD] Premium active, skipping ad');
      return;
    }
    if (_openAd == null) {
      debugPrint('[AD] Ad not loaded, retrying...');
      await loadOpenAd();
    }

    if (_openAd != null) {
      debugPrint('[AD] Showing ad...');
      _openAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          // Damga yükleme anında değil gösterim anında: yüklenip
          // gösterilemeyen reklam günlük hakkı harcamamalı
          markOpenAdShown();
          debugPrint('[AD] Ad SHOWN successfully');
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _openAd = null;
          debugPrint('[AD] Ad dismissed');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _openAd = null;
          debugPrint('[AD] Ad FAILED to show: $error');
        },
      );
      await _openAd!.show();
    } else {
      debugPrint('[AD] Ad could not be loaded, skipping');
    }
  }

  static void dispose() {
    _openAd?.dispose();
  }
}
