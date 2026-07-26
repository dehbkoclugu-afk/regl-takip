import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/services/export_service.dart';

void main() {
  group('PeriodRecord', () {
    test('durationDays includes both start and end day', () {
      final record = PeriodRecord(
        id: '1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
      );
      expect(record.durationDays, 5);
    });

    test('single-day period has duration 1', () {
      final record = PeriodRecord(
        id: '1',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 1),
      );
      expect(record.durationDays, 1);
    });

    test('isOngoing when endDate is null', () {
      final record = PeriodRecord(id: '1', startDate: DateTime(2026, 1, 1));
      expect(record.isOngoing, isTrue);
    });

    test('containsDate includes boundaries, excludes outside', () {
      final record = PeriodRecord(
        id: '1',
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 14),
      );
      expect(record.containsDate(DateTime(2026, 1, 10)), isTrue);
      expect(record.containsDate(DateTime(2026, 1, 14)), isTrue);
      expect(record.containsDate(DateTime(2026, 1, 9)), isFalse);
      expect(record.containsDate(DateTime(2026, 1, 15)), isFalse);
    });
  });

  group('ExportService.sanitizeCsvCell', () {
    test('prefixes formula-like cells', () {
      expect(ExportService.sanitizeCsvCell('=SUM(A1:A9)'), "'=SUM(A1:A9)");
      expect(ExportService.sanitizeCsvCell('+123'), "'+123");
      expect(ExportService.sanitizeCsvCell('-cmd'), "'-cmd");
      expect(ExportService.sanitizeCsvCell('@import'), "'@import");
    });

    test('leaves normal text untouched', () {
      expect(ExportService.sanitizeCsvCell('normal not'), 'normal not');
      expect(ExportService.sanitizeCsvCell(''), '');
      expect(ExportService.sanitizeCsvCell('ağrı vardı'), 'ağrı vardı');
    });
  });

  test('ICS export uses exclusive end date and escapes event title', () {
    final ics = ExportService.buildCalendarIcs(
      [
        PeriodRecord(
          id: 'period-1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 5),
        ),
      ],
      eventTitle: 'Regl, günü;',
      generatedAt: DateTime.utc(2026, 1, 10, 12),
    );

    expect(ics, contains('DTSTART;VALUE=DATE:20260101\r\n'));
    expect(ics, contains('DTEND;VALUE=DATE:20260106\r\n'));
    expect(ics, contains(r'SUMMARY:Regl\, günü\;'));
    expect(ics, endsWith('END:VCALENDAR\r\n'));
  });
}
