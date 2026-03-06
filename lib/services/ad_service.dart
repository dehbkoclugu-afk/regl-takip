import 'dart:async';
import 'dart:io' show Platform;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

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
  static Completer<void>? _loadCompleter;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized');
  }

  static Future<void> loadOpenAd() async {
    _loadCompleter = Completer<void>();
    InterstitialAd.load(
      adUnitId: kDebugMode ? _testInterstitialId : _openAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _openAd = ad;
          debugPrint('Open Ad yuklendi');
          _loadCompleter?.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Open Ad yuklenemedi: $error');
          _loadCompleter?.complete();
        },
      ),
    );
    // Maksimum 5 saniye bekle, yüklenemezse devam et
    await _loadCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Open Ad yukleme zaman asimi');
      },
    );
  }

  static Future<void> showOpenAd() async {
    // Reklam yüklenmemişse tekrar dene
    if (_openAd == null) {
      debugPrint('Open Ad yuklenmemis, tekrar deneniyor...');
      await loadOpenAd();
    }
    if (_openAd != null) {
      _openAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _openAd = null;
          debugPrint('Open Ad kapatildi');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _openAd = null;
          debugPrint('Open Ad gosterilemedi: $error');
        },
      );
      await _openAd!.show();
    } else {
      debugPrint('Open Ad yuklenemedi, reklam gosterilemiyor');
    }
  }

  static void dispose() {
    _openAd?.dispose();
  }
}
