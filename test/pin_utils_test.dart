import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/pin_utils.dart';

void main() {
  // Testlerde tur sayısı düşük: PBKDF2'nin doğruluğu turdan bağımsız
  const rounds = 1000;

  group('PinUtils modern format', () {
    test('doğru PIN doğrulanır, yanlış PIN reddedilir', () {
      final stored = PinUtils.encodePin('1234', rounds: rounds);
      expect(PinUtils.verifyPin(stored, '1234'), isTrue);
      expect(PinUtils.verifyPin(stored, '1235'), isFalse);
      expect(PinUtils.verifyPin(stored, ''), isFalse);
    });

    test('aynı PIN farklı tuzlarla farklı hash üretir', () {
      final a = PinUtils.encodePin('1234', rounds: rounds);
      final b = PinUtils.encodePin('1234', rounds: rounds);
      expect(a, isNot(equals(b)));
      expect(PinUtils.verifyPin(a, '1234'), isTrue);
      expect(PinUtils.verifyPin(b, '1234'), isTrue);
    });

    test(r'format pbkdf2$tur$tuz$hash olarak saklanır', () {
      final stored = PinUtils.encodePin('1234', rounds: rounds);
      final parts = stored.split(r'$');
      expect(parts.length, 4);
      expect(parts[0], 'pbkdf2');
      expect(int.parse(parts[1]), rounds);
      expect(PinUtils.isModern(stored), isTrue);
    });

    test('bozuk kayıt çökmeden reddedilir', () {
      expect(PinUtils.verifyPin(r'pbkdf2$abc$xx', '1234'), isFalse);
      expect(PinUtils.verifyPin(r'pbkdf2$1000$!!!$!!!', '1234'), isFalse);
    });
  });

  group('PinUtils eski format geçişi', () {
    test('tuzsuz SHA-256 kaydı hâlâ doğrulanır', () {
      final legacy = PinUtils.hashPin('1234');
      expect(PinUtils.isModern(legacy), isFalse);
      expect(PinUtils.verifyPin(legacy, '1234'), isTrue);
      expect(PinUtils.verifyPin(legacy, '9999'), isFalse);
    });

    test('düz metin kaydı (en eski sürüm) hâlâ doğrulanır', () {
      expect(PinUtils.verifyPin('1234', '1234'), isTrue);
      expect(PinUtils.verifyPin('1234', '4321'), isFalse);
    });

    test('yükseltilen kayıt modern formatta doğrulanır', () {
      const pin = '4321';
      final legacy = PinUtils.hashPin(pin);
      expect(PinUtils.verifyPin(legacy, pin), isTrue);
      final upgraded = PinUtils.encodePin(pin, rounds: rounds);
      expect(PinUtils.isModern(upgraded), isTrue);
      expect(PinUtils.verifyPin(upgraded, pin), isTrue);
    });
  });
}
