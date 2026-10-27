import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Yanlış PIN denemelerinin kalıcı deposu (testlerde bellek içi).
abstract class PinAttemptStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecurePinAttemptStore implements PinAttemptStore {
  const SecurePinAttemptStore();
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Brute-force koruması: [maxFreeAttempts] yanlış denemeden sonra her
/// fazladan deneme bekleme süresini 30 sn artırır (en çok 5 dk).
///
/// Kilit ekranında vardı ama PIN'i kaldırmak/değiştirmek için kullanılan
/// doğrulama ekranında yoktu: oradan 10.000 kombinasyon beklemesiz
/// denenebiliyordu. İki ekran da artık aynı sayacı paylaşıyor.
class PinLockout {
  PinLockout({
    this.store = const SecurePinAttemptStore(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PinAttemptStore store;
  final DateTime Function() _clock;

  static const int maxFreeAttempts = 5;
  static const String attemptsKey = 'pin_failed_attempts';
  static const String lockoutKey = 'pin_lockout_until';

  static int lockoutSecondsFor(int attempts) {
    if (attempts < maxFreeAttempts) return 0;
    return (30 * (attempts - maxFreeAttempts + 1)).clamp(30, 300);
  }

  /// Süren beklemenin kalan saniyesi (yoksa 0).
  Future<int> remainingSeconds() async {
    final until = int.tryParse(await store.read(lockoutKey) ?? '');
    if (until == null) return 0;
    final remainingMs = until - _clock().millisecondsSinceEpoch;
    return remainingMs > 0 ? (remainingMs / 1000).ceil() : 0;
  }

  /// Yanlış denemeyi kaydeder; başlayan beklemenin saniyesini döndürür.
  Future<int> registerFailure() async {
    final attempts =
        (int.tryParse(await store.read(attemptsKey) ?? '') ?? 0) + 1;
    await store.write(attemptsKey, attempts.toString());
    final seconds = lockoutSecondsFor(attempts);
    if (seconds > 0) {
      final until = _clock()
          .add(Duration(seconds: seconds))
          .millisecondsSinceEpoch;
      await store.write(lockoutKey, until.toString());
    }
    return seconds;
  }

  Future<void> clear() async {
    await store.delete(attemptsKey);
    await store.delete(lockoutKey);
  }
}
