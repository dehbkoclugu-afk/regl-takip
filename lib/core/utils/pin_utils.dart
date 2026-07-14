import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// PIN saklama ve doğrulama.
///
/// Güncel format: `pbkdf2$<tur>$<tuzBase64>$<hashBase64>`.
/// Tuzsuz tek tur SHA-256, 4 haneli bir PIN için gökkuşağı tablosuyla anında
/// çözülür; PBKDF2 + rastgele tuz her cihazda farklı hash üretir ve deneme
/// başına maliyeti yükseltir.
///
/// Eski formatlar (düz metin, tuzsuz SHA-256) doğrulamada hâlâ kabul edilir;
/// çağıran taraf başarılı girişten sonra [encodePin] ile yükseltmelidir.
class PinUtils {
  PinUtils._();

  static const int iterations = 50000;
  static const String _prefix = 'pbkdf2';

  /// Eski (tuzsuz) format — yalnız geriye dönük doğrulama için.
  static String hashPin(String pin) =>
      sha256.convert(utf8.encode(pin)).toString();

  static String generateSalt() {
    final rnd = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  static String encodePin(String pin, {String? salt, int rounds = iterations}) {
    final s = salt ?? generateSalt();
    final hash = _pbkdf2(utf8.encode(pin), base64Decode(s), rounds);
    return '$_prefix\$$rounds\$$s\$${base64Encode(hash)}';
  }

  static bool isModern(String stored) => stored.startsWith('$_prefix\$');

  static bool verifyPin(String stored, String pin) {
    if (isModern(stored)) {
      final parts = stored.split(r'$');
      if (parts.length != 4) return false;
      final rounds = int.tryParse(parts[1]);
      if (rounds == null || rounds <= 0) return false;
      final List<int> expected;
      final List<int> salt;
      try {
        expected = base64Decode(parts[3]);
        salt = base64Decode(parts[2]);
      } on FormatException {
        return false;
      }
      final actual = _pbkdf2(utf8.encode(pin), salt, rounds);
      return _constantTimeEquals(expected, actual);
    }
    // Eski kurulumlar: tuzsuz SHA-256 ya da (çok eski) düz metin
    return stored == hashPin(pin) || stored == pin;
  }

  static List<int> _pbkdf2(List<int> password, List<int> salt, int rounds) {
    final hmac = Hmac(sha256, password);
    // PBKDF2 tek blok (dkLen = 32): U1 = HMAC(salt || INT(1))
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final out = List<int>.from(u);
    for (var i = 1; i < rounds; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < out.length; j++) {
        out[j] ^= u[j];
      }
    }
    return out;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// compute() girişleri: 50k turluk PBKDF2 UI thread'ini kilitlemesin diye
/// doğrulama ve üretme ayrı isolate'ta koşar.
bool verifyPinTask(List<String> storedAndPin) =>
    PinUtils.verifyPin(storedAndPin[0], storedAndPin[1]);

String encodePinTask(String pin) => PinUtils.encodePin(pin);
