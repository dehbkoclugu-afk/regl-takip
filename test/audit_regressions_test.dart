import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:regl_takip/core/utils/calendar_days.dart';
import 'package:regl_takip/core/utils/notification_action.dart';
import 'package:regl_takip/core/utils/medication_plan.dart';
import 'package:regl_takip/core/utils/pin_utils.dart';
import 'package:regl_takip/core/utils/cycle_utils.dart';
import 'package:regl_takip/models/enums.dart';
import 'package:regl_takip/models/daily_log.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/services/health_sync_service.dart';

void main() {
  test('calendar counting ignores UTC offsets and leap day is one day', () {
    expect(
        CalendarDays.between(DateTime(2026, 3, 30), DateTime(2026, 3, 29)), 1);
    expect(
        CalendarDays.between(DateTime(2024, 3, 1), DateTime(2024, 2, 28)), 2);
    expect(CalendarDays.add(DateTime(2026, 3, 29), 1), DateTime(2026, 3, 30));
  });
  test('lock and disguise gate defers notification writes', () {
    expect(
        notificationGate(
            resolved: true,
            locked: true,
            resumed: true,
            onboarded: true,
            disguised: false),
        NotificationGate.wait);
    expect(
        notificationGate(
            resolved: true,
            locked: false,
            resumed: true,
            onboarded: true,
            disguised: true),
        NotificationGate.discard);
  });
  test('notification identifies dose and historical target date', () {
    final morning =
        MedicationEntry(name: 'Same', dose: '5 mg', reminderTime: '08:00');
    final evening =
        MedicationEntry(name: 'Same', dose: '10 mg', reminderTime: '20:00');
    final parsed = parseMedicationNotification(
        medicationNotificationPayload(morning, DateTime(2026, 10, 22)))!;
    expect(parsed.id, medicationIdentity(morning));
    expect(parsed.id, isNot(medicationIdentity(evening)));
    expect(parsed.day, DateTime(2026, 10, 22));
    expect(parseMedicationNotification('Same'), isNull);
    final recurring = recurringMedicationPayload(evening);
    expect(parseRecurringMedicationId(recurring), medicationIdentity(evening));
    expect(parseMedicationNotification(recurring), isNull);
  });
  test('malformed expensive PIN metadata fails quickly', () {
    final salt = base64Encode(List.filled(16, 1)),
        hash = base64Encode(List.filled(32, 1));
    expect(
        PinUtils.verifyPin('pbkdf2\$999999999\$$salt\$$hash', '1234'), false);
    expect(PinUtils.verifyPin('pbkdf2\$10\$AQ==\$AQ==', '1234'), false);
  });
  test('custom pill schedules round trip through date math', () {
    final today = DateTime.now();
    final start = CalendarDays.add(today, -24);
    expect(CycleUtils.pillDayInPack(start, activeDays: 24, breakDays: 4), 25);
    expect(CycleUtils.pillIsBreak(25, activeDays: 24), true);
    expect(CycleUtils.pillDaysUntilBreak(10, activeDays: 28, breakDays: 0), 0);
  });
  test('health plan preserves intensity and includes backdated entries', () {
    final plan = HealthSyncService.buildSyncPlan([
      PeriodRecord(
          id: 'one',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 2))
    ], [
      DailyLog(
          id: 'd',
          date: DateTime(2026, 1, 1),
          flowIntensity: FlowIntensity.light)
    ]);
    expect(plan['2026-01-01'], 'light:1');
    expect(plan['2026-01-02'], 'unspecified:0');
    expect(HealthSyncService.flowFor(FlowIntensity.veryHeavy),
        MenstrualFlow.heavy);
  });
  test('sparse baseline or fever cannot imply confirmed ovulation', () {
    final sparse = List.generate(
        9, (i) => MapEntry(DateTime(2026, 1, i * 2 + 1), i < 6 ? 36.2 : 36.6));
    expect(CycleUtils.detectOvulationFromBBT(sparse), isNull);
    final fever = List.generate(
        9, (i) => MapEntry(DateTime(2026, 1, i + 1), i < 6 ? 36.2 : 38.0));
    expect(CycleUtils.detectOvulationFromBBT(fever), isNull);
  });
}
