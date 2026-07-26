import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/services/encrypted_backup_codec.dart';

void main() {
  final codec = EncryptedBackupCodec();
  const password = 'uzun ve güçlü parola';
  const payload = '{"health":"private-cycle-data"}';
  final salt = List<int>.generate(16, (index) => index);
  final nonce = List<int>.generate(12, (index) => index + 16);
  final createdAt = DateTime.utc(2026, 7, 26, 12);

  Future<String> encrypted() => codec.encrypt(
        payload,
        password,
        salt: salt,
        nonce: nonce,
        createdAt: createdAt,
      );

  test('password length uses Unicode code points', () {
    expect(isValidBackupPassword('1234567890'), isTrue);
    expect(isValidBackupPassword('123456789'), isFalse);
    expect(isValidBackupPassword('🔒🔒🔒🔒🔒🔒🔒🔒🔒🔒'), isTrue);
    expect(
      isValidBackupPassword(List<String>.filled(129, 'x').join()),
      isFalse,
    );
  });

  test('password confirmation must match exactly', () {
    expect(
      validateBackupPassword(password, confirmation: password),
      BackupPasswordValidation.valid,
    );
    expect(
      validateBackupPassword(password, confirmation: '$password '),
      BackupPasswordValidation.mismatch,
    );
  });

  test('Argon2id and AES-GCM round-trip hides plaintext', () async {
    final envelope = await encrypted();

    expect(envelope, isNot(contains('private-cycle-data')));
    expect(codec.isEncryptedEnvelope(envelope), isTrue);
    expect(await codec.decrypt(envelope, password), payload);
  });

  test('fresh salt and nonce produce different envelopes', () async {
    final first = await codec.encrypt(payload, password);
    final second = await codec.encrypt(payload, password);
    expect(first, isNot(second));
  });

  test('wrong password or modified ciphertext is rejected', () async {
    final envelope = await encrypted();
    await expectLater(
      codec.decrypt(envelope, 'başka güçlü bir parola'),
      throwsA(
        isA<EncryptedBackupException>().having(
          (error) => error.error,
          'error',
          EncryptedBackupError.authenticationFailed,
        ),
      ),
    );

    final decoded = jsonDecode(envelope) as Map<String, dynamic>;
    final cipher = decoded['cipher'] as Map<String, dynamic>;
    final ciphertext = base64Decode(cipher['ciphertext'] as String);
    ciphertext[0] ^= 1;
    cipher['ciphertext'] = base64Encode(ciphertext);
    await expectLater(
      codec.decrypt(jsonEncode(decoded), password),
      throwsA(
        isA<EncryptedBackupException>().having(
          (error) => error.error,
          'error',
          EncryptedBackupError.authenticationFailed,
        ),
      ),
    );
  });

  test('modified authenticated header is rejected', () async {
    final decoded =
        jsonDecode(await encrypted()) as Map<String, dynamic>;
    decoded['createdAt'] = '2026-07-27T12:00:00.000Z';

    await expectLater(
      codec.decrypt(jsonEncode(decoded), password),
      throwsA(isA<EncryptedBackupException>()),
    );
  });

  test('unsupported parameters and malformed fields fail before decrypt',
      () async {
    final decoded =
        jsonDecode(await encrypted()) as Map<String, dynamic>;
    (decoded['kdf'] as Map<String, dynamic>)['memoryKiB'] = 999999999;

    await expectLater(
      codec.decrypt(jsonEncode(decoded), password),
      throwsA(
        isA<EncryptedBackupException>().having(
          (error) => error.error,
          'error',
          EncryptedBackupError.invalidFormat,
        ),
      ),
    );

    (decoded['kdf'] as Map<String, dynamic>)['memoryKiB'] = 19456;
    (decoded['cipher'] as Map<String, dynamic>)['nonce'] = 'not-base64';
    await expectLater(
      codec.decrypt(jsonEncode(decoded), password),
      throwsA(isA<EncryptedBackupException>()),
    );
  });

  test('salt, MAC, version, and createdAt have strict formats', () async {
    final source = await encrypted();

    Future<void> rejects(
      void Function(Map<String, dynamic> envelope) mutate,
    ) async {
      final envelope = jsonDecode(source) as Map<String, dynamic>;
      mutate(envelope);
      await expectLater(
        codec.decrypt(jsonEncode(envelope), password),
        throwsA(
          isA<EncryptedBackupException>().having(
            (error) => error.error,
            'error',
            EncryptedBackupError.invalidFormat,
          ),
        ),
      );
    }

    await rejects((envelope) {
      (envelope['kdf'] as Map<String, dynamic>)['salt'] =
          base64Encode(List<int>.filled(15, 0));
    });
    await rejects((envelope) {
      (envelope['cipher'] as Map<String, dynamic>)['mac'] =
          base64Encode(List<int>.filled(15, 0));
    });
    await rejects((envelope) => envelope['envelopeVersion'] = 2);
    await rejects((envelope) => envelope['createdAt'] = 123);
  });
}
