// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      birthDate: fields[1] as DateTime?,
      averageCycleLength: fields[2] as int,
      averagePeriodLength: fields[3] as int,
      pinEnabled: fields[4] as bool,
      biometricEnabled: fields[5] as bool,
      onboardingCompleted: fields[6] as bool,
      language: fields[7] as String,
      lastPeriodStart: fields[8] as DateTime?,
      periodReminderEnabled: fields[9] as bool,
      ovulationReminderEnabled: fields[10] as bool,
      medicationReminderEnabled: fields[11] as bool,
      reminderHour: fields[12] as int,
      reminderMinute: fields[13] as int,
      darkModeEnabled: fields[14] as bool,
      waterGoal: fields[15] == null ? 8 : fields[15] as int,
      smartPredictionEnabled: fields[16] == null ? true : fields[16] as bool,
      trackingMode:
          fields[17] == null ? TrackingMode.period : fields[17] as TrackingMode,
      pregnancyStartDate: fields[18] as DateTime?,
      pillPackStartDate: fields[19] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.birthDate)
      ..writeByte(2)
      ..write(obj.averageCycleLength)
      ..writeByte(3)
      ..write(obj.averagePeriodLength)
      ..writeByte(4)
      ..write(obj.pinEnabled)
      ..writeByte(5)
      ..write(obj.biometricEnabled)
      ..writeByte(6)
      ..write(obj.onboardingCompleted)
      ..writeByte(7)
      ..write(obj.language)
      ..writeByte(8)
      ..write(obj.lastPeriodStart)
      ..writeByte(9)
      ..write(obj.periodReminderEnabled)
      ..writeByte(10)
      ..write(obj.ovulationReminderEnabled)
      ..writeByte(11)
      ..write(obj.medicationReminderEnabled)
      ..writeByte(12)
      ..write(obj.reminderHour)
      ..writeByte(13)
      ..write(obj.reminderMinute)
      ..writeByte(14)
      ..write(obj.darkModeEnabled)
      ..writeByte(15)
      ..write(obj.waterGoal)
      ..writeByte(16)
      ..write(obj.smartPredictionEnabled)
      ..writeByte(17)
      ..write(obj.trackingMode)
      ..writeByte(18)
      ..write(obj.pregnancyStartDate)
      ..writeByte(19)
      ..write(obj.pillPackStartDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
