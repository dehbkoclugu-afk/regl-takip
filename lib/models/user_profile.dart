import 'package:hive/hive.dart';
import 'enums.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime? birthDate;

  @HiveField(2)
  int averageCycleLength;

  @HiveField(3)
  int averagePeriodLength;

  @HiveField(4)
  bool pinEnabled;

  @HiveField(5)
  bool biometricEnabled;

  @HiveField(6)
  bool onboardingCompleted;

  @HiveField(7)
  String language;

  @HiveField(8)
  DateTime? lastPeriodStart;

  @HiveField(9)
  bool periodReminderEnabled;

  @HiveField(10)
  bool ovulationReminderEnabled;

  @HiveField(11)
  bool medicationReminderEnabled;

  @HiveField(12)
  int reminderHour;

  @HiveField(13)
  int reminderMinute;

  @HiveField(14)
  bool darkModeEnabled;

  // defaultValue: sonradan eklenen alanlar — eski kayıtlarda null gelir,
  // anotasyonsuz cast upgrade'de crash olur
  @HiveField(15, defaultValue: 8)
  int waterGoal;

  /// Tahminlerde elle girilen değer yerine geçmiş kayıtlardan öğrenilen
  /// döngü uzunluğunu kullan (yeterli veri varsa)
  @HiveField(16, defaultValue: true)
  bool smartPredictionEnabled;

  /// Takip modu: regl (varsayılan), hamilelik veya doğum kontrol hapı
  @HiveField(17, defaultValue: TrackingMode.period)
  TrackingMode trackingMode;

  /// Hamilelik modunda gebelik haftası bunun üzerinden hesaplanır
  /// (son adet tarihi — LMP)
  @HiveField(18)
  DateTime? pregnancyStartDate;

  /// Hap modunda 21+7 döngüsünün paket başlangıcı
  @HiveField(19)
  DateTime? pillPackStartDate;

  /// Tema tercihi: 'system' / 'light' / 'dark'.
  /// '' (defaultValue) = alan eklenmeden önceki kayıt; etkin mod
  /// darkModeEnabled'dan türetilir (eski kullanıcının seçimi korunur,
  /// yeni kullanıcı sistem temasını izler). Eşleme providers'ta:
  /// themeModeFromProfile.
  @HiveField(20, defaultValue: '')
  String themePreference;

  UserProfile({
    this.name = '',
    this.birthDate,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.onboardingCompleted = false,
    // 'system' = cihaz dilini izle (desteklenmiyorsa İngilizce)
    this.language = 'system',
    this.lastPeriodStart,
    this.periodReminderEnabled = true,
    this.ovulationReminderEnabled = true,
    this.medicationReminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.darkModeEnabled = false,
    this.waterGoal = 8,
    this.smartPredictionEnabled = true,
    this.trackingMode = TrackingMode.period,
    this.pregnancyStartDate,
    this.pillPackStartDate,
    this.themePreference = 'system',
  });

  /// Yeni bir kopya döndürür; verilen alanlar güncellenir.
  /// Nullable alanlar (birthDate, lastPeriodStart) null'a çekilemez.
  UserProfile copyWith({
    String? name,
    DateTime? birthDate,
    int? averageCycleLength,
    int? averagePeriodLength,
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? onboardingCompleted,
    String? language,
    DateTime? lastPeriodStart,
    bool? periodReminderEnabled,
    bool? ovulationReminderEnabled,
    bool? medicationReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? darkModeEnabled,
    int? waterGoal,
    bool? smartPredictionEnabled,
    TrackingMode? trackingMode,
    DateTime? pregnancyStartDate,
    DateTime? pillPackStartDate,
    String? themePreference,
  }) {
    return UserProfile(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      averageCycleLength: averageCycleLength ?? this.averageCycleLength,
      averagePeriodLength: averagePeriodLength ?? this.averagePeriodLength,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      language: language ?? this.language,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      periodReminderEnabled:
          periodReminderEnabled ?? this.periodReminderEnabled,
      ovulationReminderEnabled:
          ovulationReminderEnabled ?? this.ovulationReminderEnabled,
      medicationReminderEnabled:
          medicationReminderEnabled ?? this.medicationReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      waterGoal: waterGoal ?? this.waterGoal,
      smartPredictionEnabled:
          smartPredictionEnabled ?? this.smartPredictionEnabled,
      trackingMode: trackingMode ?? this.trackingMode,
      pregnancyStartDate: pregnancyStartDate ?? this.pregnancyStartDate,
      pillPackStartDate: pillPackStartDate ?? this.pillPackStartDate,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'birthDate': birthDate?.toIso8601String(),
        'averageCycleLength': averageCycleLength,
        'averagePeriodLength': averagePeriodLength,
        'pinEnabled': pinEnabled,
        'biometricEnabled': biometricEnabled,
        'onboardingCompleted': onboardingCompleted,
        'language': language,
        'lastPeriodStart': lastPeriodStart?.toIso8601String(),
        'periodReminderEnabled': periodReminderEnabled,
        'ovulationReminderEnabled': ovulationReminderEnabled,
        'medicationReminderEnabled': medicationReminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'darkModeEnabled': darkModeEnabled,
        'waterGoal': waterGoal,
        'smartPredictionEnabled': smartPredictionEnabled,
        'trackingMode': trackingMode.name,
        'pregnancyStartDate': pregnancyStartDate?.toIso8601String(),
        'pillPackStartDate': pillPackStartDate?.toIso8601String(),
        'themePreference': themePreference,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        birthDate: json['birthDate'] != null
            ? DateTime.tryParse(json['birthDate'] as String)
            : null,
        averageCycleLength: json['averageCycleLength'] as int? ?? 28,
        averagePeriodLength: json['averagePeriodLength'] as int? ?? 5,
        pinEnabled: json['pinEnabled'] as bool? ?? false,
        biometricEnabled: json['biometricEnabled'] as bool? ?? false,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
        language: json['language'] as String? ?? 'tr',
        lastPeriodStart: json['lastPeriodStart'] != null
            ? DateTime.tryParse(json['lastPeriodStart'] as String)
            : null,
        periodReminderEnabled: json['periodReminderEnabled'] as bool? ?? true,
        ovulationReminderEnabled:
            json['ovulationReminderEnabled'] as bool? ?? true,
        medicationReminderEnabled:
            json['medicationReminderEnabled'] as bool? ?? false,
        reminderHour: json['reminderHour'] as int? ?? 9,
        reminderMinute: json['reminderMinute'] as int? ?? 0,
        darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
        waterGoal: json['waterGoal'] as int? ?? 8,
        smartPredictionEnabled:
            json['smartPredictionEnabled'] as bool? ?? true,
        trackingMode: enumFromName(
                TrackingMode.values, json['trackingMode'] as String?) ??
            TrackingMode.period,
        pregnancyStartDate: json['pregnancyStartDate'] != null
            ? DateTime.tryParse(json['pregnancyStartDate'] as String)
            : null,
        pillPackStartDate: json['pillPackStartDate'] != null
            ? DateTime.tryParse(json['pillPackStartDate'] as String)
            : null,
        // Eski yedekte alan yok: kullanıcının o günkü seçimi korunur
        themePreference: json['themePreference'] as String? ??
            ((json['darkModeEnabled'] as bool? ?? false) ? 'dark' : 'light'),
      );

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }
}
