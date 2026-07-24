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

  /// Ham döngü gününü 1..cycleLength aralığına sarar.
  /// Döngü uzunluğu aşılmışsa yeni döngü başlamış kabul edilir.
  static int wrappedCycleDay(int rawDay, int cycleLength) {
    if (rawDay <= cycleLength) return rawDay;
    final mod = rawDay % cycleLength;
    return mod == 0 ? cycleLength : mod;
  }

  /// Döngü içinde ovülasyonun denk geldiği gün numarası.
  /// predictOvulation ile aynı gün: sonraki adetten 14 gün önce
  /// (28 günlük döngüde 15. gün). Tarih-bazlı ve gün-bazlı hesapların
  /// tek doğrusu burası.
  static int ovulationDayNumber(int cycleLength) =>
      cycleLength - AppConstants.ovulationDayBeforePeriod + 1;

  /// Kayıtlardan ortalama regl süresi. Yalnız bitmiş kayıtlar sayılır;
  /// hiç bitmiş kayıt yoksa [fallback] döner (aksi halde "0,0 gün" gibi
  /// anlamsız bir ortalama gösterilir).
  static double averagePeriodDuration(
      List<PeriodRecord> records, int fallback) {
    final completed = records.where((r) => r.endDate != null).toList();
    if (completed.isEmpty) return fallback.toDouble();
    final total =
        completed.fold<int>(0, (sum, r) => sum + r.durationDays);
    return total / completed.length;
  }

  /// Onboarding'de girilen "son regl başlangıcı" için kayıt bitiş tarihi.
  /// Regl bugün hâlâ sürüyorsa null döner: kayıt açık (isOngoing) kalmalı.
  static DateTime? completedPeriodEnd(
      DateTime start, int periodLength, DateTime today) {
    final s = DateTime(start.year, start.month, start.day);
    final t = DateTime(today.year, today.month, today.day);
    final end = s.add(Duration(days: periodLength - 1));
    return end.isAfter(t) ? null : end;
  }

  /// Belirli bir döngü günü için fazı belirler
  static CyclePhase phaseForDay(
    int cycleDay,
    int cycleLength,
    int periodLength,
  ) {
    if (periodLength > 0 && cycleDay <= periodLength) {
      return CyclePhase.menstrual;
    }

    final ovulationDay = ovulationDayNumber(cycleLength);
    final fertileStart = ovulationDay - 5;

    if (cycleDay < fertileStart) {
      return CyclePhase.follicular;
    }

    if (cycleDay >= fertileStart && cycleDay <= ovulationDay + 1) {
      return CyclePhase.ovulation;
    }

    return CyclePhase.luteal;
  }

  /// Döngü fazını belirler (gün, wrappedCycleDay ile sarılır —
  /// currentCycleDayProvider ile tutarlı kalması için)
  static CyclePhase getCurrentPhase(
    DateTime lastPeriodStart,
    int cycleLength,
    int periodLength,
  ) {
    final cycleDay =
        wrappedCycleDay(currentCycleDay(lastPeriodStart), cycleLength);
    return phaseForDay(cycleDay, cycleLength, periodLength);
  }

  /// Kayıtlardan geçerli döngü aralıklarını çıkarır (kronolojik sırayla,
  /// min/max dışındaki uç değerler elenir)
  static List<int> validCycleGaps(List<PeriodRecord> records) {
    if (records.length < 2) return const [];

    final sorted = List<PeriodRecord>.from(records)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final gaps = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final diff =
          sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      if (diff >= AppConstants.minCycleLength &&
          diff <= AppConstants.maxCycleLength) {
        gaps.add(diff);
      }
    }
    return gaps;
  }

  /// Ortalama döngü süresini hesaplar
  static double calculateAverageCycleLength(List<PeriodRecord> records) {
    final gaps = validCycleGaps(records);
    if (gaps.isEmpty) return AppConstants.defaultCycleLength.toDouble();
    return gaps.reduce((a, b) => a + b) / gaps.length;
  }

  /// Tahminlerde kullanılacak etkin döngü uzunluğu.
  /// Akıllı tahmin açıksa ve en az 3 geçerli aralık varsa son 6 aralığın
  /// ortalamasını (yuvarlanmış) kullanır; yoksa elle girilen değer.
  static int effectiveCycleLength(
    int manualLength,
    List<PeriodRecord> records, {
    bool smartEnabled = true,
  }) {
    if (!smartEnabled) return manualLength;
    final gaps = validCycleGaps(records);
    if (gaps.length < 3) return manualLength;
    final recent = gaps.length > 6 ? gaps.sublist(gaps.length - 6) : gaps;
    final avg = recent.reduce((a, b) => a + b) / recent.length;
    return avg.round();
  }

  /// Öğrenilen döngü uzunluğu (yeterli veri yoksa null) —
  /// ayarlarda "Öğrenilen: X gün" göstermek için
  static int? learnedCycleLength(List<PeriodRecord> records) {
    final gaps = validCycleGaps(records);
    if (gaps.length < 3) return null;
    final recent = gaps.length > 6 ? gaps.sublist(gaps.length - 6) : gaps;
    return (recent.reduce((a, b) => a + b) / recent.length).round();
  }

  /// Döngü düzensizliği: en az 3 geçerli aralık varken en uzun ile
  /// en kısa aralık farkı 9 gün ve üzeriyse düzensiz kabul edilir
  /// (tıbbi literatürdeki yaygın eşik). Veri yetersizse null.
  static bool? isIrregular(List<PeriodRecord> records) {
    final gaps = validCycleGaps(records);
    if (gaps.length < AppConstants.minGapsForRegularity) return null;
    final minGap = gaps.reduce((a, b) => a < b ? a : b);
    final maxGap = gaps.reduce((a, b) => a > b ? a : b);
    return (maxGap - minGap) >= 9;
  }

  /// Bir tarihin, verilen döngü parametrelerine göre kaçıncı döngü gününe
  /// denk geldiğini döndürür (1..cycleLength; lastPeriodStart öncesi null).
  /// Gelecek döngülere de sarar — takvim tahmin işaretleri için.
  static int? dayInCycleFor(
      DateTime date, DateTime lastPeriodStart, int cycleLength) {
    final normalized = DateTime(date.year, date.month, date.day);
    final start = DateTime(lastPeriodStart.year, lastPeriodStart.month,
        lastPeriodStart.day);
    final diff = normalized.difference(start).inDays;
    if (diff < 0) return null;
    return (diff % cycleLength) + 1;
  }

  /// Döngü gününe göre doğurganlık seviyesi (TTC modu):
  /// ovülasyon günü ve önceki 2 gün en doğurgan (high) — sperm ömrü
  /// nedeniyle gebelik olasılığı bu 3 günde zirve yapar;
  /// fertil pencerenin kalanı medium, pencere dışı low.
  static FertilityLevel fertilityLevelForDay(int cycleDay, int cycleLength) {
    final ovulationDay = ovulationDayNumber(cycleLength);
    if (cycleDay >= ovulationDay - 2 && cycleDay <= ovulationDay) {
      return FertilityLevel.high;
    }
    if (cycleDay >= ovulationDay - 5 && cycleDay <= ovulationDay + 1) {
      return FertilityLevel.medium;
    }
    return FertilityLevel.low;
  }

  /// Bazal vücut sıcaklığından ovülasyon teyidi (FAM "3-üstü-6" kuralı):
  /// ardışık 3 ölçümün tamamı önceki 6 ölçümün en yükseğinden (coverline)
  /// yüksekse ve üçüncüsü coverline'ın en az 0.2°C üzerindeyse, yükselişin
  /// başladığı günün BİR ÖNCEKİ günü ovülasyon kabul edilir.
  /// [temps] tarih-sıcaklık çiftleri (sırasız olabilir); en az 9 ölçüm ister.
  /// Teyit yoksa null.
  static DateTime? detectOvulationFromBBT(
      List<MapEntry<DateTime, double>> temps) {
    if (temps.length < 9) return null;

    final sorted = List<MapEntry<DateTime, double>>.from(temps)
      ..sort((a, b) => a.key.compareTo(b.key));

    for (int i = 6; i + 2 < sorted.length; i++) {
      double coverline = sorted[i - 6].value;
      for (int j = i - 5; j < i; j++) {
        if (sorted[j].value > coverline) coverline = sorted[j].value;
      }

      final rise1 = sorted[i].value;
      final rise2 = sorted[i + 1].value;
      final rise3 = sorted[i + 2].value;

      // Yükseliş üçlüsü ardışık TAKVİM günleri olmalı; ölçüm listesinde
      // ardışık olması yetmez — gün atlamalı seyrek veride yanlış teyit olur
      final d1 = sorted[i].key;
      final d2 = sorted[i + 1].key;
      final d3 = sorted[i + 2].key;
      final consecutiveDays =
          d2.difference(d1).inDays == 1 && d3.difference(d2).inDays == 1;

      if (consecutiveDays &&
          rise1 > coverline &&
          rise2 > coverline &&
          rise3 >= coverline + 0.2) {
        return DateTime(d1.year, d1.month, d1.day)
            .subtract(const Duration(days: 1));
      }
    }
    return null;
  }

  /// Gebelik haftası (1 tabanlı, son adet tarihinden — LMP).
  /// Gelecek tarih verilirse 1 döner; 42 ile sınırlanır.
  static int pregnancyWeek(DateTime pregnancyStart) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final start = DateTime(
        pregnancyStart.year, pregnancyStart.month, pregnancyStart.day);
    final days = normalizedNow.difference(start).inDays;
    if (days < 0) return 1;
    return ((days ~/ 7) + 1).clamp(1, 42);
  }

  /// 21+7 hap döngüsünde paket günü (1..28).
  /// 1-21 aktif hap, 22-28 ara hafta.
  static int pillDayInPack(DateTime packStart) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final start =
        DateTime(packStart.year, packStart.month, packStart.day);
    final days = normalizedNow.difference(start).inDays;
    if (days < 0) return 1;
    return (days % 28) + 1;
  }

  static bool isPillBreakDay(DateTime packStart) =>
      pillDayInPack(packStart) > 21;

  /// Gelecek döngülerde tahmini adet günü mü? (mevcut döngünün gerçek
  /// kayıtları hariç — onları PeriodRecord işaretler)
  static bool isPredictedPeriodDay(
    DateTime date,
    DateTime lastPeriodStart,
    int cycleLength,
    int periodLength, {
    int cyclesAhead = 3,
  }) {
    final normalized = DateTime(date.year, date.month, date.day);
    final start = DateTime(lastPeriodStart.year, lastPeriodStart.month,
        lastPeriodStart.day);
    final diff = normalized.difference(start).inDays;
    // Mevcut döngü (diff < cycleLength) tahmin değil, gerçek kayıt alanı
    if (diff < cycleLength) return false;
    if (diff >= cycleLength * (cyclesAhead + 1)) return false;
    final dayInCycle = (diff % cycleLength) + 1;
    return dayInCycle <= periodLength;
  }

  /// Bir tarihin verimli pencerede olup olmadığını kontrol eder
  /// (mevcut ve gelecek döngülere sarar)
  static bool isInFertileWindow(
      DateTime date, DateTime lastPeriodStart, int cycleLength) {
    final day = dayInCycleFor(date, lastPeriodStart, cycleLength);
    if (day == null) return false;
    final ovulationDay = ovulationDayNumber(cycleLength);
    return day >= ovulationDay - 5 && day <= ovulationDay + 1;
  }

  /// Bir tarihin ovülasyon günü olup olmadığını kontrol eder
  /// (mevcut ve gelecek döngülere sarar)
  static bool isOvulationDay(
      DateTime date, DateTime lastPeriodStart, int cycleLength) {
    final day = dayInCycleFor(date, lastPeriodStart, cycleLength);
    if (day == null) return false;
    return day == ovulationDayNumber(cycleLength);
  }

  /// Gelecekteki (bugün dahil) ilk tahmini adet başlangıcını döndürür.
  /// Tahmin geçmişte kaldıysa döngü uzunluğu kadar ileri sarar.
  static DateTime nextFuturePeriod(DateTime lastPeriodStart, int cycleLength) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var next = predictNextPeriod(lastPeriodStart, cycleLength);
    next = DateTime(next.year, next.month, next.day);
    while (next.isBefore(today)) {
      next = next.add(Duration(days: cycleLength));
    }
    return next;
  }

  /// Sonraki adete kalan gün sayısı
  static int daysUntilNextPeriod(DateTime lastPeriodStart, int cycleLength) {
    final nextPeriod = nextFuturePeriod(lastPeriodStart, cycleLength);
    final now = DateTime.now();
    final diff =
        nextPeriod.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Tahmini regl tarihinin üzerinden kaç gün geçtiği; gecikme yoksa 0.
  ///
  /// Gecikme uygulamada hiçbir yerde görünmüyordu: [daysUntilNextPeriod]
  /// sonucu sıfıra kırpıyor, [nextFuturePeriod] geçmişte kalan tahmini bir
  /// sonraki döngüye ileri sarıyor. İkisi birlikte gecikmeyi tamamen
  /// görünmez kılıyordu — oysa kullanıcının uygulamaya en çok ihtiyaç
  /// duyduğu an tam orası.
  ///
  /// Üst sınır bir döngü boyu: gecikme döngü uzunluğuna ulaştıysa bir
  /// sonraki tahmini tarih de geçmiş demektir ve uygulama "çok geç kaldı"
  /// ile "kullanıcı uzun süredir kayıt girmiyor"u birbirinden ayıramaz.
  /// O noktada 0 dönüp normal tahmin diline geri dönmek dürüst olan.
  static int periodDelayDays(DateTime lastPeriodStart, int cycleLength) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final predicted = predictNextPeriod(lastPeriodStart, cycleLength);
    final delay = today
        .difference(DateTime(predicted.year, predicted.month, predicted.day))
        .inDays;
    if (delay <= 0 || delay >= cycleLength) return 0;
    return delay;
  }
}

enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}

/// TTC modu için günlük doğurganlık seviyesi
enum FertilityLevel { low, medium, high }
