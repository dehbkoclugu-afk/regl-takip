import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// FLAG_SECURE köprüsü: kilit (PIN/biyometri) açıkken uygulama değiştirici
/// önizlemesi ve ekran görüntüsü engellenir. Recents sızıntısı için kilidi
/// `inactive`'te indirmek yerine doğru araç budur (bkz. app.dart).
class PrivacyScreenService {
  static const _channel = MethodChannel('regl_takip/privacy');

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<void> setSecureScreen(bool enabled) async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod('setSecureScreen', {'enabled': enabled});
    } catch (e) {
      debugPrint('[PRIVACY] setSecureScreen failed: $e');
    }
  }
}
