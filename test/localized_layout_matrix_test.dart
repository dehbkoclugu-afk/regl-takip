import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/services/hive_service.dart';
import 'package:regl_takip/screens/settings/settings_screen.dart';
import 'package:regl_takip/screens/onboarding/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('layout-matrix-');
    Hive.init(dir.path);
    HiveService().resetForTesting();
    await HiveService().init(
        encryptionKey: List.filled(32, 7),
        manageHivePath: false,
        assumeEncrypted: true);
    await HiveService().saveUserProfile(UserProfile(
        name: 'Test',
        lastPeriodStart: DateTime.now(),
        onboardingCompleted: true));
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });
  for (final code in ['ar', 'de', 'hi', 'zh']) {
    for (final onboarding in [false, true]) {
      testWidgets(
          '$code ${onboarding ? 'onboarding' : 'settings'} 320px 200% keyboard',
          (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(ProviderScope(
            child: MaterialApp(
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(
                  textScaler: const TextScaler.linear(2),
                  viewInsets: const EdgeInsets.only(bottom: 180)),
              child: child!),
          home: onboarding ? const OnboardingScreen() : const SettingsScreen(),
        )));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
