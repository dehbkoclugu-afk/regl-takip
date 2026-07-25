import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/symptom_ranking.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/period_record.dart';

const fallback = [
  SymptomType.cramp,
  SymptomType.headache,
  SymptomType.bloating,
  SymptomType.fatigue,
];

DailyLog logWith(DateTime date, List<SymptomType> symptoms) => DailyLog(
      id: date.toIso8601String(),
      date: date,
      symptoms:
          symptoms.map((t) => SymptomEntry(type: t, severity: 2)).toList(),
    );

void main() {
  final now = DateTime(2026, 7, 24);

  group('semptom sıralaması', () {
    test('geçmiş yoksa varsayılan sıra korunur', () {
      expect(SymptomRanking.reorder(fallback, const [], now: now), fallback);
    });

    test('sık girilen öne gelir', () {
      final logs = [
        logWith(now.subtract(const Duration(days: 2)),
            [SymptomType.fatigue]),
        logWith(now.subtract(const Duration(days: 5)),
            [SymptomType.fatigue]),
        logWith(now.subtract(const Duration(days: 9)),
            [SymptomType.headache]),
      ];
      final ordered = SymptomRanking.reorder(fallback, logs, now: now);
      expect(ordered.first, SymptomType.fatigue);
      expect(ordered[1], SymptomType.headache);
    });

    test('pencere dışındaki kayıtlar sayılmaz', () {
      final logs = [
        logWith(
            now.subtract(
                Duration(days: SymptomRanking.windowDays + 10)),
            [SymptomType.fatigue, SymptomType.fatigue]),
      ];
      // Yalnız eski kayıt var: sayım boş kalır, varsayılan sıra döner
      expect(SymptomRanking.reorder(fallback, logs, now: now), fallback);
    });

    test('eşit sayıda girilenler varsayılan sırayı korur', () {
      final logs = [
        logWith(now.subtract(const Duration(days: 1)),
            [SymptomType.bloating, SymptomType.headache]),
      ];
      final ordered = SymptomRanking.reorder(fallback, logs, now: now);
      // headache varsayılanda bloating'den önce geliyor
      expect(ordered[0], SymptomType.headache);
      expect(ordered[1], SymptomType.bloating);
    });

    test('sonuç varsayılanla aynı öğeleri içerir', () {
      final logs = [
        logWith(now.subtract(const Duration(days: 3)),
            [SymptomType.fatigue]),
      ];
      final ordered = SymptomRanking.reorder(fallback, logs, now: now);
      expect(ordered.length, fallback.length);
      expect(ordered.toSet(), fallback.toSet());
    });

    test('listede olmayan semptom sonucu bozmaz', () {
      // Kullanıcı semptom ekranından listede olmayan bir şey girmiş olabilir
      final logs = [
        logWith(now.subtract(const Duration(days: 1)),
            [SymptomType.acne, SymptomType.fatigue]),
      ];
      final ordered = SymptomRanking.reorder(fallback, logs, now: now);
      expect(ordered.length, fallback.length);
      expect(ordered.first, SymptomType.fatigue);
    });
  });
}
