import '../core/constants/app_constants.dart';
import 'backup_service.dart';

/// Validate the complete replacement before touching the active database.
void validateBackupData(BackupData data) {
  void require(bool value, String field) {
    if (!value) throw BackupException('Invalid backup: $field');
  }

  bool hour(int? n) => n == null || (n >= 0 && n <= 23);
  bool minute(int? n) => n == null || (n >= 0 && n <= 59);
  final p = data.profile;
  if (p != null) {
    require(
        p.averageCycleLength >= AppConstants.minCycleLength &&
            p.averageCycleLength <= AppConstants.maxCycleLength,
        'cycle length');
    require(
        p.averagePeriodLength >= 1 &&
            p.averagePeriodLength <= 15 &&
            p.averagePeriodLength <= p.averageCycleLength,
        'period length');
    require(
        p.pillActiveDays >= 1 &&
            p.pillActiveDays <= 120 &&
            p.pillBreakDays >= 0 &&
            p.pillBreakDays <= 14,
        'pill schedule');
    require(p.waterGoal >= 1 && p.waterGoal <= 100, 'water goal');
    require(
        hour(p.reminderHour) &&
            hour(p.medicationReminderHour) &&
            hour(p.cycleReminderHour),
        'hour');
    require(
        minute(p.reminderMinute) &&
            minute(p.medicationReminderMinute) &&
            minute(p.cycleReminderMinute),
        'minute');
    require(p.periodReminderLeadDays >= 0 && p.periodReminderLeadDays <= 30,
        'reminder lead');
  }
  final ids = <String>{};
  final sorted = [...data.periodRecords]
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  DateTime? previousEnd;
  for (final r in sorted) {
    require(r.id.isNotEmpty && ids.add(r.id), 'duplicate period id');
    require(
        r.endDate == null || !r.endDate!.isBefore(r.startDate), 'date order');
    require(previousEnd == null || r.startDate.isAfter(previousEnd),
        'overlapping periods');
    previousEnd = r.endDate ?? DateTime(9999);
  }
  final dates = <String>{};
  ids.clear();
  for (final log in data.dailyLogs) {
    require(log.id.isNotEmpty && ids.add(log.id), 'duplicate log id');
    require(dates.add(log.dateKey), 'duplicate log date');
    require(log.waterIntake >= 0 && log.waterIntake <= 1000, 'water intake');
    require(
        log.temperature == null ||
            (log.temperature!.isFinite &&
                log.temperature! >= 30 &&
                log.temperature! <= 45),
        'temperature');
    require(
        log.weight == null ||
            (log.weight!.isFinite && log.weight! > 0 && log.weight! <= 1000),
        'weight');
    require(
        log.sleepQuality == null ||
            (log.sleepQuality! >= 1 && log.sleepQuality! <= 5),
        'sleep quality');
    require(log.symptoms.every((s) => s.severity >= 1 && s.severity <= 5),
        'symptom severity');
    require(
        log.padChangeCount == null ||
            (log.padChangeCount! >= 0 && log.padChangeCount! <= 1000),
        'pad count');
  }
}
