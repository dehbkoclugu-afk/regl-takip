// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 6;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      symptoms: (fields[2] as List).cast<SymptomEntry>(),
      mood: fields[3] as MoodEntry?,
      temperature: fields[4] as double?,
      temperatureTime: fields[5] as String?,
      weight: fields[6] as double?,
      waterIntake: fields[7] as int,
      sleepStart: fields[8] as String?,
      sleepEnd: fields[9] as String?,
      sleepQuality: fields[10] as int?,
      sexualActivity: fields[11] as SexualActivityEntry?,
      medications: (fields[12] as List).cast<MedicationEntry>(),
      notes: fields[13] as String?,
      flowIntensity: fields[14] as FlowIntensity?,
      flowColor: fields[15] as FlowColor?,
      hasClots: fields[16] as bool?,
      padChangeCount: fields[17] as int?,
      ovulationTestPositive: fields[18] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.symptoms)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.temperature)
      ..writeByte(5)
      ..write(obj.temperatureTime)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.waterIntake)
      ..writeByte(8)
      ..write(obj.sleepStart)
      ..writeByte(9)
      ..write(obj.sleepEnd)
      ..writeByte(10)
      ..write(obj.sleepQuality)
      ..writeByte(11)
      ..write(obj.sexualActivity)
      ..writeByte(12)
      ..write(obj.medications)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.flowIntensity)
      ..writeByte(15)
      ..write(obj.flowColor)
      ..writeByte(16)
      ..write(obj.hasClots)
      ..writeByte(17)
      ..write(obj.padChangeCount)
      ..writeByte(18)
      ..write(obj.ovulationTestPositive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
