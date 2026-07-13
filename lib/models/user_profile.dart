import 'package:hive/hive.dart';

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

  @HiveField(15)
  int waterGoal;

  UserProfile({
    this.name = '',
    this.birthDate,
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.onboardingCompleted = false,
    this.language = 'tr',
    this.lastPeriodStart,
    this.periodReminderEnabled = true,
    this.ovulationReminderEnabled = true,
    this.medicationReminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
    this.darkModeEnabled = false,
    this.waterGoal = 8,
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
    );
  }

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
