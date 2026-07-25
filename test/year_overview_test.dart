import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/l10n/generated/app_localizations.dart';
import 'package:regl_takip/screens/calendar/widgets/year_overview.dart';

void main() {
  test('month grid follows the locale week start', () {
    final mondayFirst = buildMonthGrid(2026, 7, 1);
    final sundayFirst = buildMonthGrid(2026, 7, 0);

    expect(mondayFirst.indexWhere((day) => day?.day == 1), 2);
    expect(sundayFirst.indexWhere((day) => day?.day == 1), 3);
    expect(mondayFirst, hasLength(42));
  });

  test('month grid includes leap day and rejects invalid week index', () {
    final february = buildMonthGrid(2028, 2, 1)
        .whereType<DateTime>()
        .toList();

    expect(february, hasLength(29));
    expect(february.last, DateTime(2028, 2, 29));
    expect(() => buildMonthGrid(2028, 2, 7), throwsRangeError);
  });

  testWidgets('year overview lays out at compact and large text sizes',
      (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final locale in const [Locale('de'), Locale('ru')]) {
      for (final width in [320.0, 600.0]) {
        for (final textScale in [1.0, 2.0]) {
          await tester.binding.setSurfaceSize(Size(width, 800));
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates:
                  AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: TextScaler.linear(textScale),
                ),
                child: Scaffold(
                  body: YearOverviewSheet(
                    initialYear: 2026,
                    firstDayOfWeek: 1,
                    records: const [],
                    profile: null,
                    cycleLength: 28,
                    onMonthSelected: (_) {},
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull,
              reason:
                  '${locale.languageCode}, $width dp, ${textScale}x text');
          expect(find.textContaining('2026'), findsOneWidget);
        }
      }
    }
  });
}
