import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Kilit gecikmesi tercihi.
///
/// Kilit yalnız uygulama arka plana alındığında devreye giriyordu ve
/// dönüşte her seferinde PIN istiyordu: bildirime bakıp geri gelmek,
/// fotoğraf seçiciden dönmek, bir bağlantıyı açıp kapatmak — hepsi yeniden
/// PIN demekti. Bu, kilidi kapattıran türden bir sürtünme.
///
/// Cihaza özel bir tercih olduğu için profilde değil SharedPreferences'ta:
/// PIN ve biyometri durumu da yedeğe girmiyor (`restoreBackup` ikisini de
/// sıfırlıyor), yeni cihazda kilit ayarı sıfırdan kurulur.
class LockTimeout {
  LockTimeout._();

  static const String prefsKey = 'lock_timeout_seconds';

  /// Varsayılan: hemen kilitle — mevcut davranışın aynısı.
  static const int defaultSeconds = 0;

  /// Ayarlarda sunulan seçenekler (saniye).
  static const List<int> options = [0, 60, 300, 900];

  static Future<int> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(prefsKey) ?? defaultSeconds;
  }

  static Future<void> write(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(prefsKey, seconds);
  }

  /// Arka planda [backgroundedAt]'ten beri geçen süre gecikmeyi aştı mı?
  ///
  /// [backgroundedAt] null ise (soğuk açılış) her zaman kilitlenir:
  /// uygulamanın hiç açık kalmadığı durumda gecikme tanınmamalı.
  static bool shouldLock({
    required DateTime now,
    required DateTime? backgroundedAt,
    required int timeoutSeconds,
  }) {
    if (backgroundedAt == null) return true;
    if (timeoutSeconds <= 0) return true;
    return now.difference(backgroundedAt).inSeconds >= timeoutSeconds;
  }
}
