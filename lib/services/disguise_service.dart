import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Uygulama kılığı (gizli mod): launcher'da ad/ikon "Notlar"a döner.
/// Android'e özgü — activity-alias'lar MethodChannel ile değiştirilir.
class DisguiseService {
  static const _channel = MethodChannel('regl_takip/disguise');

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<bool> isDisguised() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('isDisguised') ?? false;
    } catch (e) {
      debugPrint('[DISGUISE] isDisguised failed: $e');
      return false;
    }
  }

  static Future<bool> setDisguise(bool enabled) async {
    if (!isSupported) return false;
    try {
      await _channel.invokeMethod('setDisguise', {'enabled': enabled});
      return true;
    } catch (e) {
      debugPrint('[DISGUISE] setDisguise failed: $e');
      return false;
    }
  }
}
