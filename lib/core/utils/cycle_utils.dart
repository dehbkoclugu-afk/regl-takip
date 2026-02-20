import '../../models/period_record.dart';
import '../constants/app_constants.dart';

class CycleUtils {
  CycleUtils._();

  /// Bir sonraki adet başlangıç tarihini tahmin eder
  static DateTime predictNextPeriod(
      DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  /// Ovülasyon tarihini tahmin eder (bir sonraki adetten 14 gün önce)
  static DateTime predictOvulation(
      DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart
        .add(Duration(days: cycleLength - AppConstants.ovulationDayBeforePeriod));
  }

  /// Verimli pencere başlangıcını hesaplar (ovülasyondan 5 gün önce)
  static DateTime fertileWindowStart(
      DateTime lastPeriodStart, int cycleLength) {
    final ovulation = predictOvulation(lastPeriodStart, cycleLength);
    return ovulation.subtract(const Duration(days: 5));
  }

  /// Verimli pencere bitişini hesaplar (ovülasyondan 1 gün sonra)
  static DateTime fertileWindowEnd(
      DateTime lastPeriodStart, int cycleLength) {
    final ovulation = predictOvulation(lastPeriodStart, cycleLength);
    return ovulation.add(const Duration(days: 1));
  }

  /// Döngünün kaçıncı günü olduğunu hesaplar
  static int currentCycleDay(DateTime lastPeriodStart) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedStart = DateTime(
        lastPeriodStart.year, lastPeriodStart.month, lastPeriodStart.day);
    return normalizedNow.difference(normalizedStart).inDays + 1;
  }

  /// Döngü fazını belirler
  static CyclePhase getCurrentPhase(
    DateTime lastPeriodStart,
    int cycleLength,
    int periodLength,
  ) {
    final cycleDay = currentCycleDay(lastPeriodStart);

    if (cycleDay <= periodLength) {
      return CyclePhase.menstrual;
    }

    final ovulationDay = cycleLength - AppConstants.ovulationDayBeforePeriod;
    final fertileStart = ovulationDay - 5;

    if (cycleDay < fertileStart) {
      return CyclePhase.follicular;
    }

    if (cycleDay >= fertileStart && cycleDay <= ovulationDay + 1) {
      return CyclePhase.ovulation;
    }

    return CyclePhase.luteal;
  }

  /// Ortalama döngü süresini hesaplar
  static double calculateAverageCycleLength(List<PeriodRecord> records) {
    if (records.length < 2) return AppConstants.defaultCycleLength.toDouble();

    final sorted = List<PeriodRecord>.from(records)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    double totalDays = 0;
    int count = 0;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      if (diff >= AppConstants.minCycleLength &&
          diff <= AppConstants.maxCycleLength) {
        totalDays += diff;
        count++;
      }
    }

    return count > 0 ? totalDays / count : AppConstants.defaultCycleLength.toDouble();
  }

  /// Bir tarihin verimli pencerede olup olmadığını kontrol eder
  static bool isInFertileWindow(
      DateTime date, DateTime lastPeriodStart, int cycleLength) {
    final start = fertileWindowStart(lastPeriodStart, cycleLength);
    final end = fertileWindowEnd(lastPeriodStart, cycleLength);
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(start) && !normalized.isAfter(end);
  }

  /// Bir tarihin ovülasyon günü olup olmadığını kontrol eder
  static bool isOvulationDay(
      DateTime date, DateTime lastPeriodStart, int cycleLength) {
    final ovulation = predictOvulation(lastPeriodStart, cycleLength);
    return date.year == ovulation.year &&
        date.month == ovulation.month &&
        date.day == ovulation.day;
  }

  /// Sonraki adete kalan gün sayısı
  static int daysUntilNextPeriod(DateTime lastPeriodStart, int cycleLength) {
    final nextPeriod = predictNextPeriod(lastPeriodStart, cycleLength);
    final now = DateTime.now();
    final diff = nextPeriod.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff > 0 ? diff : 0;
  }
}

enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}
