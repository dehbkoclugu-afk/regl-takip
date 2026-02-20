// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodRecordAdapter extends TypeAdapter<PeriodRecord> {
  @override
  final int typeId = 1;

  @override
  PeriodRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodRecord(
      id: fields[0] as String,
      startDate: fields[1] as DateTime,
      endDate: fields[2] as DateTime?,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startDate)
      ..writeByte(2)
      ..write(obj.endDate)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomEntryAdapter extends TypeAdapter<SymptomEntry> {
  @override
  final int typeId = 2;

  @override
  SymptomEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SymptomEntry(
      type: fields[0] as SymptomType,
      severity: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SymptomEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.severity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 3;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      type: fields[0] as MoodType,
      note: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SexualActivityEntryAdapter extends TypeAdapter<SexualActivityEntry> {
  @override
  final int typeId = 4;

  @override
  SexualActivityEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SexualActivityEntry(
      protectionMethod: fields[0] as ProtectionMethod,
      orgasm: fields[1] as bool,
      note: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SexualActivityEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.protectionMethod)
      ..writeByte(1)
      ..write(obj.orgasm)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SexualActivityEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicationEntryAdapter extends TypeAdapter<MedicationEntry> {
  @override
  final int typeId = 5;

  @override
  MedicationEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationEntry(
      name: fields[0] as String,
      dose: fields[1] as String,
      taken: fields[2] as bool,
      reminderTime: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MedicationEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dose)
      ..writeByte(2)
      ..write(obj.taken)
      ..writeByte(3)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
