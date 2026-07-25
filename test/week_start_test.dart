import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/screens/calendar/calendar_screen.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('haftanın ilk günü eşlemesi', () {
    // İki sayım farklı yerden başlıyor: Flutter'ın firstDayOfWeekIndex
    // 0 = pazar, table_calendar'ın enum'u 0 = pazartesi. Kaydırmayı gözle
    // doğrulamak zor, o yüzden yedi indeksin hepsi yazılı.
    test('pazar (İngilizce yerelinin varsayılanı)', () {
      expect(startingDayOfWeekFromIndex(0), StartingDayOfWeek.sunday);
    });

    test('pazartesi (tr, de, fr, ru)', () {
      expect(startingDayOfWeekFromIndex(1), StartingDayOfWeek.monday);
    });

    test('aradaki günler kaymadan eşleşir', () {
      expect(startingDayOfWeekFromIndex(2), StartingDayOfWeek.tuesday);
      expect(startingDayOfWeekFromIndex(3), StartingDayOfWeek.wednesday);
      expect(startingDayOfWeekFromIndex(4), StartingDayOfWeek.thursday);
      expect(startingDayOfWeekFromIndex(5), StartingDayOfWeek.friday);
    });

    test('cumartesi (indeks 6) sonuncuya değil doğru güne düşer', () {
      expect(startingDayOfWeekFromIndex(6), StartingDayOfWeek.saturday);
    });

    test('yedi indeksin hepsi farklı bir güne gider', () {
      final mapped = [for (var i = 0; i < 7; i++) startingDayOfWeekFromIndex(i)];
      expect(mapped.toSet().length, 7);
    });
  });
}
