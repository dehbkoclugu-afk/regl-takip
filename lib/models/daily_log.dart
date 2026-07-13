import 'package:hive/hive.dart';
import 'enums.dart';
import 'period_record.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 6)
class DailyLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<SymptomEntry> symptoms;

  @HiveField(3)
  MoodEntry? mood;

  @HiveField(4)
  double? temperature;

  @HiveField(5)
  String? temperatureTime;

  @HiveField(6)
  double? weight;

  @HiveField(7)
  int waterIntake;

  @HiveField(8)
  String? sleepStart;

  @HiveField(9)
  String? sleepEnd;

  @HiveField(10)
  int? sleepQuality;

  @HiveField(11)
  SexualActivityEntry? sexualActivity;

  @HiveField(12)
  List<MedicationEntry> medications;

  @HiveField(13)
  String? notes;

  @HiveField(14)
  FlowIntensity? flowIntensity;

  @HiveField(15)
  FlowColor? flowColor;

  @HiveField(16)
  bool? hasClots;

  @HiveField(17)
  int? padChangeCount;

  DailyLog({
    required this.id,
    required this.date,
    this.symptoms = const [],
    this.mood,
    this.temperature,
    this.temperatureTime,
    this.weight,
    this.waterIntake = 0,
    this.sleepStart,
    this.sleepEnd,
    this.sleepQuality,
    this.sexualActivity,
    this.medications = const [],
    this.notes,
    this.flowIntensity,
    this.flowColor,
    this.hasClots,
    this.padChangeCount,
  });

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'symptoms': symptoms.map((s) => s.toJson()).toList(),
        'mood': mood?.toJson(),
        'temperature': temperature,
        'temperatureTime': temperatureTime,
        'weight': weight,
        'waterIntake': waterIntake,
        'sleepStart': sleepStart,
        'sleepEnd': sleepEnd,
        'sleepQuality': sleepQuality,
        'sexualActivity': sexualActivity?.toJson(),
        'medications': medications.map((m) => m.toJson()).toList(),
        'notes': notes,
        'flowIntensity': flowIntensity?.name,
        'flowColor': flowColor?.name,
        'hasClots': hasClots,
        'padChangeCount': padChangeCount,
      };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        symptoms: (json['symptoms'] as List<dynamic>? ?? [])
            .map((s) => SymptomEntry.fromJson(s as Map<String, dynamic>))
            .whereType<SymptomEntry>()
            .toList(),
        mood: json['mood'] != null
            ? MoodEntry.fromJson(json['mood'] as Map<String, dynamic>)
            : null,
        temperature: (json['temperature'] as num?)?.toDouble(),
        temperatureTime: json['temperatureTime'] as String?,
        weight: (json['weight'] as num?)?.toDouble(),
        waterIntake: json['waterIntake'] as int? ?? 0,
        sleepStart: json['sleepStart'] as String?,
        sleepEnd: json['sleepEnd'] as String?,
        sleepQuality: json['sleepQuality'] as int?,
        sexualActivity: json['sexualActivity'] != null
            ? SexualActivityEntry.fromJson(
                json['sexualActivity'] as Map<String, dynamic>)
            : null,
        medications: (json['medications'] as List<dynamic>? ?? [])
            .map((m) => MedicationEntry.fromJson(m as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
        flowIntensity:
            enumFromName(FlowIntensity.values, json['flowIntensity'] as String?),
        flowColor: enumFromName(FlowColor.values, json['flowColor'] as String?),
        hasClots: json['hasClots'] as bool?,
        padChangeCount: json['padChangeCount'] as int?,
      );
}
