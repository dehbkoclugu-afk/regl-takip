import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/screens/medication/medication_tracking_screen.dart';
import 'package:regl_takip/services/hive_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('medication-screen-');
    Hive.init(dir.path);
    HiveService().resetForTesting();
    await HiveService().init(
      encryptionKey: List.filled(32, 5),
      manageHivePath: false,
      assumeEncrypted: true,
    );
    await HiveService().saveUserProfile(UserProfile(
      onboardingCompleted: true,
      medicationPlan: [MedicationEntry(name: 'Test medicine')],
      medicationPlanMigrated: true,
    ));
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('failed daily write does not mark medication as taken', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MedicationTrackingScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsNothing);

    // Hive disk I/O must finish outside the widget test's fake async zone.
    await tester.runAsync(() => Hive.close());
    final toggle = find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.label == 'Test medicine');
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swipe removes the plan entry only after persistence', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MedicationTrackingScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Test medicine'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(HiveService().getUserProfile()!.medicationPlan, isEmpty);
    expect(find.text('Test medicine'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
