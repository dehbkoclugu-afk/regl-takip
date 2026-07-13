import 'dart:convert';
import 'package:crypto/crypto.dart';

class PinUtils {
  PinUtils._();

  /// PIN'in SHA-256 hash'ini döndürür. PIN düz metin olarak saklanmaz.
  static String hashPin(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();
}
