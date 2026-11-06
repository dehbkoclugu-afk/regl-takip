import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/screens/weight/weight_tracking_screen.dart';
import 'package:regl_takip/services/hive_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('weight-screen-');
    Hive.init(dir.path);
    HiveService().resetForTesting();
    await HiveService().init(
      encryptionKey: List.filled(32, 6),
      manageHivePath: false,
      assumeEncrypted: true,
    );
    await HiveService().saveUserProfile(UserProfile(
      usePounds: true,
      onboardingCompleted: true,
    ));
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Widget app({double textScale = 1}) => ProviderScope(
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: const WeightTrackingScreen(),
    ),
  );

  testWidgets('132.4 lb remains 132.4 lb after saving and reopening', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField), '132.4');
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));
    expect(HiveService().getAllDailyLogs().single.weight, closeTo(60.06, 0.001));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app());
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('132.4'), findsWidgets);
  });

  testWidgets('large text keeps pound value within compact card', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(textScale: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
