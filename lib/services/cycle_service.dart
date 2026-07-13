import '../core/constants/app_constants.dart';
import '../core/utils/cycle_utils.dart';
import 'hive_service.dart';

class CycleService {
  final HiveService _hiveService;

  CycleService(this._hiveService);

  /// Returns the current cycle day based on the user's last period start date.
  /// Returns 0 if no profile or no last period date is set.
  int getCurrentCycleDay() {
    final profile = _hiveService.getUserProfile();
    if (profile == null || profile.lastPeriodStart == null) return 0;
    return CycleUtils.currentCycleDay(profile.lastPeriodStart!);
  }

  /// Predicts the next period start date.
  /// Returns null if no profile or last period date is available.
  DateTime? getNextPeriodDate() {
    final profile = _hiveService.getUserProfile();
    if (profile == null || profile.lastPeriodStart == null) return null;
    return CycleUtils.predictNextPeriod(
      profile.lastPeriodStart!,
      profile.averageCycleLength,
    );
  }

  /// Predicts the ovulation date.
  /// Returns null if no profile or last period date is available.
  DateTime? getOvulationDate() {
    final profile = _hiveService.getUserProfile();
    if (profile == null || profile.lastPeriodStart == null) return null;
    return CycleUtils.predictOvulation(
      profile.lastPeriodStart!,
      profile.averageCycleLength,
    );
  }

  /// Returns the fertile window as a (start, end) pair.
  /// Returns null if no profile or last period date is available.
  (DateTime, DateTime)? getFertileWindowDates() {
    final profile = _hiveService.getUserProfile();
    if (profile == null || profile.lastPeriodStart == null) return null;

    final start = CycleUtils.fertileWindowStart(
      profile.lastPeriodStart!,
      profile.averageCycleLength,
    );
    final end = CycleUtils.fertileWindowEnd(
      profile.lastPeriodStart!,
      profile.averageCycleLength,
    );
    return (start, end);
  }

  /// Returns the current phase of the menstrual cycle.
  /// Defaults to follicular if data is unavailable.
  CyclePhase getCurrentPhase() {
    final profile = _hiveService.getUserProfile();
    if (profile == null || profile.lastPeriodStart == null) {
      return CyclePhase.follicular;
    }
    return CycleUtils.getCurrentPhase(
      profile.lastPeriodStart!,
      profile.averageCycleLength,
      profile.averagePeriodLength,
    );
  }

  // NOT: Regl başlatma/bitirme yazma işlemleri PeriodRecordsNotifier'da
  // (providers.dart) — tek yazma yolu orada tutuluyor.

  /// Calculates the average cycle length from historical period records.
  double getAverageCycleLength() {
    final records = _hiveService.getAllPeriodRecords();
    return CycleUtils.calculateAverageCycleLength(records);
  }

  /// Calculates the average period (bleeding) length from historical records.
  double getAveragePeriodLength() {
    final records = _hiveService.getAllPeriodRecords();
    final completedRecords = records.where((r) => !r.isOngoing).toList();

    if (completedRecords.isEmpty) {
      return AppConstants.defaultPeriodLength.toDouble();
    }

    final totalDays = completedRecords.fold<int>(
      0,
      (sum, record) => sum + record.durationDays,
    );
    return totalDays / completedRecords.length;
  }

  /// Checks if a given date is a period day based on all stored records.
  bool isPeriodDay(DateTime date) {
    final records = _hiveService.getAllPeriodRecords();
    return records.any((record) => record.containsDate(date));
  }
}
