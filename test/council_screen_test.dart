import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regl_takip/core/widgets/info_dialog.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/models/user_profile.dart';
import 'package:regl_takip/screens/dashboard/dashboard_screen.dart';
import 'package:regl_takip/screens/calendar/calendar_screen.dart';
import 'package:regl_takip/screens/dashboard/widgets/cycle_progress_ring.dart';
import 'package:regl_takip/services/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('council-screens');
    Hive.init(dir.path);
    HiveService().resetForTesting();
    await HiveService().init(
      encryptionKey: List.filled(32, 8),
      manageHivePath: false,
      assumeEncrypted: true,
    );
    await HiveService().saveUserProfile(
      UserProfile(
        name: 'Test',
        lastPeriodStart: DateTime.now().subtract(const Duration(days: 8)),
        onboardingCompleted: true,
      ),
    );
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });
  Widget app(Widget screen, {Locale locale = const Locale('tr')}) =>
      ProviderScope(
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: screen,
        ),
      );

  testWidgets('actual dashboard exposes the ring at 320 dp and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const DashboardScreen()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CycleProgressRing), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('actual calendar renders a day without overflow', (tester) async {
    await tester.pumpWidget(app(const CalendarScreen()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('info dialog remains dismissible with long German copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showInfoDialog(
                context,
                icon: const Icon(Icons.info),
                color: Colors.blue,
                title: 'Information',
                body: List.filled(30, 'Längere Erklärung').join(' '),
                doneLabel: 'Fertig',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Fertig'));
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
