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
  static bool _isLoadingOpenAd = false;

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized');
  }

  static Future<void> loadOpenAd() async {
    if (_isLoadingOpenAd) return;
    _isLoadingOpenAd = true;
    try {
      await InterstitialAd.load(
        adUnitId: kDebugMode ? _testInterstitialId : _openAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _openAd = ad;
            debugPrint('Open Ad yuklendi');
          },
          onAdFailedToLoad: (error) {
            debugPrint('Open Ad yuklenemedi: $error');
          },
        ),
      );
    } finally {
      _isLoadingOpenAd = false;
    }
  }

  static Future<void> showOpenAd() async {
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
      debugPrint('Open Ad henuz yuklenmedi');
    }
  }

  static void dispose() {
    _openAd?.dispose();
  }
}
