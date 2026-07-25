import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/medication_plan.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/period_record.dart';

void main() {
  test('en yeni günlük ilaç listesi kalıcı plana dönüştürülür', () {
    final logs = [
      DailyLog(
        id: 'old',
        date: DateTime(2026, 7, 1),
        medications: [MedicationEntry(name: 'Eski', taken: true)],
      ),
      DailyLog(
        id: 'new',
        date: DateTime(2026, 7, 2),
        medications: [
          MedicationEntry(
            name: ' Yeni ',
            dose: ' 10 mg ',
            reminderTime: '08:00',
            taken: true,
          ),
        ],
      ),
    ];

    final plan = medicationPlanFromLogs(logs);
    expect(plan, hasLength(1));
    expect(plan.single.name, 'Yeni');
    expect(plan.single.dose, '10 mg');
    expect(plan.single.reminderTime, '08:00');
    expect(plan.single.taken, isFalse);
  });

  test('profil planı seçili günün alınma durumuyla birleşir', () {
    final plan = [
      MedicationEntry(name: 'A', dose: '5 mg', reminderTime: '09:00'),
      MedicationEntry(name: 'B'),
    ];
    final daily = [
      MedicationEntry(
        name: 'A',
        dose: '5 mg',
        reminderTime: '09:00',
        taken: true,
      ),
    ];

    final entries = medicationEntriesForDay(plan, daily);
    expect(entries.map((entry) => entry.taken), [true, false]);
  });

  test('plandan silinen ilaç geçmiş günlük kayıtta korunur', () {
    final current = [MedicationEntry(name: 'Güncel', taken: true)];
    final existing = [
      MedicationEntry(name: 'Silinmiş', taken: true),
      MedicationEntry(name: 'Güncel'),
    ];

    final record = medicationDailyRecord(current, existing);
    expect(record.map((entry) => entry.name), ['Silinmiş', 'Güncel']);
    expect(record.last.taken, isTrue);
  });
}
