import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/theme/app_theme.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/screens/calendar/widgets/year_overview.dart';
import 'package:regl_takip/screens/dashboard/widgets/cycle_progress_ring.dart';

Widget _app(Widget child, {ThemeMode themeMode = ThemeMode.light}) =>
    MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Scaffold(body: child),
        ),
      ),
    );

void main() {
  test('themes expose a visible keyboard focus color', () {
    expect(AppTheme.lightTheme.focusColor, isNot(Colors.transparent));
    expect(AppTheme.darkTheme.focusColor, isNot(Colors.transparent));
    expect(
      AppTheme.lightTheme.focusColor,
      isNot(AppTheme.darkTheme.focusColor),
    );
  });

  testWidgets('cycle ring supports focus, Enter and Space', (tester) async {
    await tester.pumpWidget(
      _app(
        const Center(
          child: CycleProgressRing(
            cycleDay: 2,
            cycleLength: 28,
            periodLength: 5,
            phase: CyclePhase.menstrual,
            daysUntilNextPeriod: 26,
          ),
        ),
      ),
    );
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(CycleProgressRing)),
    )!;
    final ring = find
        .descendant(
          of: find.byType(CycleProgressRing),
          matching: find.byType(AnimatedContainer),
        )
        .first;

    expect(
      ((tester.widget<AnimatedContainer>(ring).decoration
                  as BoxDecoration)
              .border as Border)
          .top
          .width,
      1.5,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      ((tester.widget<AnimatedContainer>(ring).decoration
                  as BoxDecoration)
              .border as Border)
          .top
          .width,
      3,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(find.text(l10n.menstrualPhase), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(find.text(l10n.menstrualPhase), findsNothing);
  });

  testWidgets('year grid follows Tab and Shift+Tab reading order',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    DateTime? selectedMonth;

    await tester.pumpWidget(
      _app(
        YearOverviewSheet(
          initialYear: 2026,
          firstDayOfWeek: 1,
          records: const [],
          profile: null,
          cycleLength: 28,
          onMonthSelected: (month) => selectedMonth = month,
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(Focus.of(tester.element(find.text('January'))).hasFocus, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(
      Focus.of(
        tester.element(find.byIcon(Icons.chevron_right_rounded)),
      ).hasFocus,
      isTrue,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(selectedMonth, DateTime(2026, 1));
  });

  testWidgets('mobile layout starts keyboard order at the header',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(
      _app(
        YearOverviewSheet(
          initialYear: 2026,
          firstDayOfWeek: 1,
          records: const [],
          profile: null,
          cycleLength: 28,
          onMonthSelected: (_) {},
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(
        tester.element(find.byIcon(Icons.chevron_left_rounded)),
      ).hasFocus,
      isTrue,
    );
  });

  testWidgets('Tab keeps a focused list control inside the viewport',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 400));

    await tester.pumpWidget(
      _app(
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (var index = 0; index < 20; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  key: ValueKey('item-$index'),
                  onPressed: () {},
                  child: Text('Item $index'),
                ),
              ),
          ],
        ),
      ),
    );

    for (var index = 0; index <= 15; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }

    final rect = tester.getRect(find.byKey(const ValueKey('item-15')));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(400));
  });

  testWidgets('Escape closes the top dialog and restores opener focus',
      (tester) async {
    final openerFocus = FocusNode();
    addTearDown(openerFocus.dispose);

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              focusNode: openerFocus,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Keyboard dialog'),
                ),
              ),
              child: const Text('Open dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard dialog'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Keyboard dialog'), findsNothing);
    expect(openerFocus.hasFocus, isTrue);
  });
}
