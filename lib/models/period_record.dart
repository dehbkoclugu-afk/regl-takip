import 'package:hive/hive.dart';
import 'enums.dart';

part 'period_record.g.dart';

@HiveType(typeId: 1)
class PeriodRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  DateTime? endDate;

  @HiveField(3)
  String? notes;

  PeriodRecord({
    required this.id,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'notes': notes,
      };

  factory PeriodRecord.fromJson(Map<String, dynamic> json) => PeriodRecord(
        id: json['id'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.tryParse(json['endDate'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  int get durationDays {
    if (endDate == null) return DateTime.now().difference(startDate).inDays + 1;
    return endDate!.difference(startDate).inDays + 1;
  }

  bool get isOngoing => endDate == null;

  bool containsDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = endDate != null
        ? DateTime(endDate!.year, endDate!.month, endDate!.day)
        : DateTime.now();
    return !normalizedDate.isBefore(normalizedStart) &&
        !normalizedDate.isAfter(normalizedEnd);
  }
}

@HiveType(typeId: 2)
class SymptomEntry {
  @HiveField(0)
  SymptomType type;

  @HiveField(1)
  int severity;

  SymptomEntry({
    required this.type,
    this.severity = 1,
  });

  Map<String, dynamic> toJson() => {'type': type.name, 'severity': severity};

  /// Bilinmeyen semptom tipi null döner (kayıt atlanır)
  static SymptomEntry? fromJson(Map<String, dynamic> json) {
    final type = enumFromName(SymptomType.values, json['type'] as String?);
    if (type == null) return null;
    return SymptomEntry(type: type, severity: json['severity'] as int? ?? 1);
  }
}

@HiveType(typeId: 3)
class MoodEntry {
  @HiveField(0)
  MoodType type;

  @HiveField(1)
  String? note;

  MoodEntry({
    required this.type,
    this.note,
  });

  Map<String, dynamic> toJson() => {'type': type.name, 'note': note};

  static MoodEntry? fromJson(Map<String, dynamic> json) {
    final type = enumFromName(MoodType.values, json['type'] as String?);
    if (type == null) return null;
    return MoodEntry(type: type, note: json['note'] as String?);
  }
}

@HiveType(typeId: 4)
class SexualActivityEntry {
  @HiveField(0)
  ProtectionMethod protectionMethod;

  @HiveField(1)
  bool orgasm;

  @HiveField(2)
  String? note;

  SexualActivityEntry({
    this.protectionMethod = ProtectionMethod.none,
    this.orgasm = false,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'protectionMethod': protectionMethod.name,
        'orgasm': orgasm,
        'note': note,
      };

  factory SexualActivityEntry.fromJson(Map<String, dynamic> json) =>
      SexualActivityEntry(
        protectionMethod: enumFromName(ProtectionMethod.values,
                json['protectionMethod'] as String?) ??
            ProtectionMethod.none,
        orgasm: json['orgasm'] as bool? ?? false,
        note: json['note'] as String?,
      );
}

@HiveType(typeId: 5)
class MedicationEntry {
  @HiveField(0)
  String name;

  @HiveField(1)
  String dose;

  @HiveField(2)
  bool taken;

  @HiveField(3)
  String? reminderTime;

  MedicationEntry({
    required this.name,
    this.dose = '',
    this.taken = false,
    this.reminderTime,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dose': dose,
        'taken': taken,
        'reminderTime': reminderTime,
      };

  factory MedicationEntry.fromJson(Map<String, dynamic> json) =>
      MedicationEntry(
        name: json['name'] as String? ?? '',
        dose: json['dose'] as String? ?? '',
        taken: json['taken'] as bool? ?? false,
        reminderTime: json['reminderTime'] as String?,
      );
}
