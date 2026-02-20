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
}
