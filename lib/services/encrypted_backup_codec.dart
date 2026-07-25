import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

enum EncryptedBackupError {
  invalidFormat,
  authenticationFailed,
}

class EncryptedBackupException implements Exception {
  final EncryptedBackupError error;

  const EncryptedBackupException(this.error);
}

enum BackupPasswordValidation {
  valid,
  invalidLength,
  mismatch,
}

BackupPasswordValidation validateBackupPassword(
  String password, {
  String? confirmation,
}) {
  final length = password.runes.length;
  if (length < EncryptedBackupCodec.minPasswordLength ||
      length > EncryptedBackupCodec.maxPasswordLength) {
    return BackupPasswordValidation.invalidLength;
  }
  if (confirmation != null && password != confirmation) {
    return BackupPasswordValidation.mismatch;
  }
  return BackupPasswordValidation.valid;
}

bool isValidBackupPassword(String password) {
  return validateBackupPassword(password) == BackupPasswordValidation.valid;
}

class EncryptedBackupCodec {
  static const envelopeVersion = 1;
  static const minPasswordLength = 10;
  static const maxPasswordLength = 128;
  static const maxFileBytes = 50 * 1024 * 1024;

  static const _memoryKiB = 19 * 1024;
  static const _iterations = 2;
  static const _parallelism = 1;
  static const _saltLength = 16;
  static const _nonceLength = 12;
  static const _macLength = 16;

  final AesGcm _cipher = AesGcm.with256bits();
  final Argon2id _kdf = Argon2id(
    memory: _memoryKiB,
    iterations: _iterations,
    parallelism: _parallelism,
    hashLength: 32,
  );

  Future<String> encrypt(
    String plainText,
    String password, {
    List<int>? salt,
    List<int>? nonce,
    DateTime? createdAt,
  }) async {
    if (!isValidBackupPassword(password)) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    final actualSalt = salt ?? _randomBytes(_saltLength);
    final actualNonce = nonce ?? _randomBytes(_nonceLength);
    if (actualSalt.length != _saltLength ||
        actualNonce.length != _nonceLength) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }

    final header = _header(
      createdAt: (createdAt ?? DateTime.now()).toUtc().toIso8601String(),
      salt: actualSalt,
      nonce: actualNonce,
    );
    final secretKey = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: actualSalt,
    );
    final box = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: secretKey,
      nonce: actualNonce,
      aad: _aad(header),
    );
    final envelope = <String, dynamic>{
      ...header,
      'cipher': <String, dynamic>{
        ...(header['cipher'] as Map<String, dynamic>),
        'ciphertext': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      },
    };
    final encoded = jsonEncode(envelope);
    if (utf8.encode(encoded).length > maxFileBytes) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    return encoded;
  }

  Future<String> decrypt(String source, String password) async {
    if (!isValidBackupPassword(password)) {
      throw const EncryptedBackupException(
        EncryptedBackupError.authenticationFailed,
      );
    }
    final envelope = _decodeEnvelope(source);
    final kdf = envelope['kdf'] as Map<String, dynamic>;
    final cipher = envelope['cipher'] as Map<String, dynamic>;
    final salt = _decodeBase64(kdf['salt'], _saltLength);
    final nonce = _decodeBase64(cipher['nonce'], _nonceLength);
    final mac = _decodeBase64(cipher['mac'], _macLength);
    final ciphertext = _decodeBase64(cipher['ciphertext'], null);
    if (ciphertext.isEmpty) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }

    final secretKey = await _kdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    final header = _header(
      createdAt: envelope['createdAt'] as String,
      salt: salt,
      nonce: nonce,
    );
    try {
      final clearText = await _cipher.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
        secretKey: secretKey,
        aad: _aad(header),
      );
      return utf8.decode(clearText);
    } catch (_) {
      throw const EncryptedBackupException(
        EncryptedBackupError.authenticationFailed,
      );
    }
  }

  bool isEncryptedEnvelope(String source) {
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> &&
          decoded['app'] == 'regl_takip' &&
          decoded.containsKey('envelopeVersion');
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decodeEnvelope(String source) {
    if (utf8.encode(source).length > maxFileBytes) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } catch (_) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    final createdAt = decoded is Map<String, dynamic>
        ? decoded['createdAt']
        : null;
    final parsedCreatedAt =
        createdAt is String ? DateTime.tryParse(createdAt) : null;
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'regl_takip' ||
        decoded['envelopeVersion'] != envelopeVersion ||
        createdAt is! String ||
        parsedCreatedAt == null ||
        !parsedCreatedAt.isUtc ||
        parsedCreatedAt.toIso8601String() != createdAt) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    final kdf = decoded['kdf'];
    final cipher = decoded['cipher'];
    if (kdf is! Map<String, dynamic> ||
        cipher is! Map<String, dynamic> ||
        kdf['name'] != 'argon2id' ||
        kdf['memoryKiB'] != _memoryKiB ||
        kdf['iterations'] != _iterations ||
        kdf['parallelism'] != _parallelism ||
        cipher['name'] != 'aes-256-gcm') {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    return decoded;
  }

  Map<String, dynamic> _header({
    required String createdAt,
    required List<int> salt,
    required List<int> nonce,
  }) =>
      <String, dynamic>{
        'app': 'regl_takip',
        'envelopeVersion': envelopeVersion,
        'createdAt': createdAt,
        'kdf': <String, dynamic>{
          'name': 'argon2id',
          'memoryKiB': _memoryKiB,
          'iterations': _iterations,
          'parallelism': _parallelism,
          'salt': base64Encode(salt),
        },
        'cipher': <String, dynamic>{
          'name': 'aes-256-gcm',
          'nonce': base64Encode(nonce),
        },
      };

  List<int> _aad(Map<String, dynamic> header) =>
      utf8.encode(jsonEncode(header));

  List<int> _decodeBase64(dynamic value, int? expectedLength) {
    if (value is! String) {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
    try {
      final bytes = base64Decode(value);
      if (expectedLength != null && bytes.length != expectedLength) {
        throw const EncryptedBackupException(
          EncryptedBackupError.invalidFormat,
        );
      }
      return bytes;
    } on FormatException {
      throw const EncryptedBackupException(
        EncryptedBackupError.invalidFormat,
      );
    }
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
