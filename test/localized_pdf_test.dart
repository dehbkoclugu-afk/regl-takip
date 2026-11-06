import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('localized-pdf-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => temporary.path);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await temporary.delete(recursive: true);
  });

  for (final code in ['pt', 'ar', 'hi', 'zh']) {
    test('$code exports a PDF using bundled offline fonts', () async {
      final file = await ExportService().exportPdf(
        UserProfile(name: 'Ana / سارة / आशा / 小明'),
        [],
        {},
        lookupAppLocalizations(Locale(code)),
      );
      final bytes = await File(file).readAsBytes();
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });
  }
}
