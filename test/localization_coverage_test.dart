import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/language_utils.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';

void main() {
  test('every locale has every message and preserves interpolation arguments',
      () {
    Map<String, dynamic> read(String code) => jsonDecode(
          File('lib/l10n/app_$code.arb').readAsStringSync(),
        ) as Map<String, dynamic>;
    final template = read('tr');
    final keys = template.keys.where((k) => !k.startsWith('@')).toSet();
    List<String> arguments(String value) => RegExp(r'\{(\w+)(?:\}|,)')
        .allMatches(value)
        .map((m) => m[1]!)
        .toSet()
        .toList()
      ..sort();
    for (final code in supportedLanguageCodes) {
      final messages = read(code);
      expect(messages['@@locale'], code);
      expect(messages.keys.where((k) => !k.startsWith('@')).toSet(), keys,
          reason: 'Missing or extra message in $code');
      for (final key in keys) {
        final value = messages[key] as String;
        expect(value.trim(), isNotEmpty, reason: '$code.$key');
        expect(arguments(value), arguments(template[key] as String),
            reason: '$code.$key interpolation');
        expect(value, isNot(contains('ZXPH')), reason: '$code.$key');
      }
      expect(lookupAppLocalizations(Locale(code)).localeName, code);
    }
    expect(AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        supportedLanguageCodes.toSet());
  });

  test('locale resolution respects ordered preferences and English fallback',
      () {
    expect(resolveAppLocale(null), const Locale('en'));
    expect(resolveAppLocale(const [Locale('ja')]), const Locale('en'));
    expect(resolveAppLocale(const [Locale('ja'), Locale('pt', 'BR')]),
        const Locale('pt'));
    expect(resolveAppLocale(const [Locale('ar'), Locale('en')]),
        const Locale('ar'));
    expect(resolveAppLocale(const [Locale('zh', 'CN')]), const Locale('zh'));
  });

  for (final code in ['pt', 'ar', 'hi', 'zh']) {
    testWidgets(
        '$code loads app and platform translations with correct direction',
        (tester) async {
      late BuildContext localizedContext;
      await tester.pumpWidget(MaterialApp(
        locale: Locale(code),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(builder: (context) {
          localizedContext = context;
          return Scaffold(body: Text(AppLocalizations.of(context)!.appTitle));
        }),
      ));
      await tester.pumpAndSettle();
      expect(Localizations.localeOf(localizedContext).languageCode, code);
      expect(Directionality.of(localizedContext),
          code == 'ar' ? TextDirection.rtl : TextDirection.ltr);
      expect(
          MaterialLocalizations.of(localizedContext).okButtonLabel, isNotEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
