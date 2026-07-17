class AppConstants {
  AppConstants._();

  // Varsayılan değerler
  static const int defaultCycleLength = 28;
  static const int defaultPeriodLength = 5;
  static const int minCycleLength = 18;
  static const int maxCycleLength = 45;
  static const int minPeriodLength = 2;
  static const int maxPeriodLength = 10;
  static const int fertileWindowDays = 6;
  static const int ovulationDayBeforePeriod = 14;

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
