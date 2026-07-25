class AppConstants {
  AppConstants._();

  // Varsayılan değerler
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  // Giriş doğrulama sınırları: bu aralığın dışındaki değerler kayıt hatası
  // sayılır ve hesaplamaya alınmaz. Yaygın kabul edilen aralıkla
  // karıştırılmamalı — onlar aşağıda.
  static const int minCycleLength = 18;
  static const int maxCycleLength = 45;
  static const int minPeriodLength = 2;
  static const int maxPeriodLength = 10;

  // Yaygın kabul edilen aralıklar. Ekrandaki sayıya bağlam vermek için:
  // "29,3 gün" tek başına iyi mi kötü mü söylemiyor. Tanı ölçütü değil,
  // yalnız okuma yardımı.
  static const int typicalCycleMin = 21;
  static const int typicalCycleMax = 35;
  static const int typicalPeriodMin = 2;
  static const int typicalPeriodMax = 7;

  /// Düzenlilik yargısı için gereken en az döngü aralığı sayısı.
  /// Altında "yetersiz veri" denir — iki döngüyle düzenlilik konuşulmaz.
  static const int minGapsForRegularity = 3;
  static const int fertileWindowDays = 6;
  static const int ovulationDayBeforePeriod = 14;

  /// Verimli pencere ovülasyondan kaç gün önce açılır.
  /// Sperm ömrü nedeniyle asıl fırsat ovülasyon gününden ÖNCE başlar;
  /// TTC bildirimi bu güne kurulur, ovülasyon gününe değil.
  static const int fertileWindowStartBeforeOvulation = 5;

  // Hap paketi: 21 etkin + 7 ara/plasebo
  static const int pillActiveDays = 21;
  static const int pillPackDays = 28;

  /// Gebelik testinin anlamlı olduğu en erken gün: ovülasyondan bu kadar
  /// gün sonra. Daha erken test yanlış negatif verir — implantasyon ve
  /// hCG'nin ölçülebilir düzeye çıkması zaman ister.
  static const int pregnancyTestAfterOvulation = 12;

  // Su tüketimi
  static const int defaultWaterGoal = 8;
  static const int waterGlassMl = 250;

  // Sıcaklık
  static const double minTemperatureCelsius = 35.0;
  static const double maxTemperatureCelsius = 40.0;

  // Hive box isimleri
  static const String userProfileBox = 'user_profile';
  static const String periodRecordsBox = 'period_records';
  static const String dailyLogsBox = 'daily_logs';
  static const String medicationsBox = 'medications';
  static const String settingsBox = 'settings';

  // Hive keys
  static const String currentUserKey = 'current_user';
}
