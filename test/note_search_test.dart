import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/note_search.dart';
import 'package:regl_takip/models/daily_log.dart';

void main() {
  DailyLog log(int day, String? note) => DailyLog(
        id: '$day',
        date: DateTime(2026, 7, day),
        notes: note,
      );

  test('filters notes by text and inclusive date range, newest first', () {
    final results = filterNoteLogs(
      [
        log(3, 'Baş ağrısı'),
        log(8, 'Enerjim yüksek'),
        log(12, 'Baş ağrısı hafifledi'),
        log(15, null),
      ],
      query: 'AĞRISI',
      start: DateTime(2026, 7, 2),
      end: DateTime(2026, 7, 12),
    );

    expect(results.map((entry) => entry.id), ['12', '3']);
  });
}
