// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlowIntensityAdapter extends TypeAdapter<FlowIntensity> {
  @override
  final int typeId = 10;

  @override
  FlowIntensity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FlowIntensity.light;
      case 1:
        return FlowIntensity.normal;
      case 2:
        return FlowIntensity.heavy;
      case 3:
        return FlowIntensity.veryHeavy;
      default:
        return FlowIntensity.light;
    }
  }

  @override
  void write(BinaryWriter writer, FlowIntensity obj) {
    switch (obj) {
      case FlowIntensity.light:
        writer.writeByte(0);
        break;
      case FlowIntensity.normal:
        writer.writeByte(1);
        break;
      case FlowIntensity.heavy:
        writer.writeByte(2);
        break;
      case FlowIntensity.veryHeavy:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlowIntensityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FlowColorAdapter extends TypeAdapter<FlowColor> {
  @override
  final int typeId = 11;

  @override
  FlowColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FlowColor.lightRed;
      case 1:
        return FlowColor.red;
      case 2:
        return FlowColor.darkRed;
      case 3:
        return FlowColor.brown;
      default:
        return FlowColor.lightRed;
    }
  }

  @override
  void write(BinaryWriter writer, FlowColor obj) {
    switch (obj) {
      case FlowColor.lightRed:
        writer.writeByte(0);
        break;
      case FlowColor.red:
        writer.writeByte(1);
        break;
      case FlowColor.darkRed:
        writer.writeByte(2);
        break;
      case FlowColor.brown:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlowColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomTypeAdapter extends TypeAdapter<SymptomType> {
  @override
  final int typeId = 12;

  @override
  SymptomType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SymptomType.cramp;
      case 1:
        return SymptomType.headache;
      case 2:
        return SymptomType.bloating;
      case 3:
        return SymptomType.breastTenderness;
      case 4:
        return SymptomType.backPain;
      case 5:
        return SymptomType.fatigue;
      case 6:
        return SymptomType.nausea;
      case 7:
        return SymptomType.dizziness;
      case 8:
        return SymptomType.stress;
      case 9:
        return SymptomType.anxiety;
      case 10:
        return SymptomType.irritability;
      case 11:
        return SymptomType.crying;
      case 12:
        return SymptomType.sensitivity;
      case 13:
        return SymptomType.acne;
      case 14:
        return SymptomType.oilySkin;
      case 15:
        return SymptomType.drySkin;
      case 16:
        return SymptomType.glowing;
      case 17:
        return SymptomType.constipation;
      case 18:
        return SymptomType.diarrhea;
      case 19:
        return SymptomType.gas;
      case 20:
        return SymptomType.increasedAppetite;
      case 21:
        return SymptomType.decreasedAppetite;
      case 22:
        return SymptomType.insomnia;
      case 23:
        return SymptomType.hotFlash;
      case 24:
        return SymptomType.edema;
      case 25:
        return SymptomType.hairLoss;
      default:
        return SymptomType.cramp;
    }
  }

  @override
  void write(BinaryWriter writer, SymptomType obj) {
    switch (obj) {
      case SymptomType.cramp:
        writer.writeByte(0);
        break;
      case SymptomType.headache:
        writer.writeByte(1);
        break;
      case SymptomType.bloating:
        writer.writeByte(2);
        break;
      case SymptomType.breastTenderness:
        writer.writeByte(3);
        break;
      case SymptomType.backPain:
        writer.writeByte(4);
        break;
      case SymptomType.fatigue:
        writer.writeByte(5);
        break;
      case SymptomType.nausea:
        writer.writeByte(6);
        break;
      case SymptomType.dizziness:
        writer.writeByte(7);
        break;
      case SymptomType.stress:
        writer.writeByte(8);
        break;
      case SymptomType.anxiety:
        writer.writeByte(9);
        break;
      case SymptomType.irritability:
        writer.writeByte(10);
        break;
      case SymptomType.crying:
        writer.writeByte(11);
        break;
      case SymptomType.sensitivity:
        writer.writeByte(12);
        break;
      case SymptomType.acne:
        writer.writeByte(13);
        break;
      case SymptomType.oilySkin:
        writer.writeByte(14);
        break;
      case SymptomType.drySkin:
        writer.writeByte(15);
        break;
      case SymptomType.glowing:
        writer.writeByte(16);
        break;
      case SymptomType.constipation:
        writer.writeByte(17);
        break;
      case SymptomType.diarrhea:
        writer.writeByte(18);
        break;
      case SymptomType.gas:
        writer.writeByte(19);
        break;
      case SymptomType.increasedAppetite:
        writer.writeByte(20);
        break;
      case SymptomType.decreasedAppetite:
        writer.writeByte(21);
        break;
      case SymptomType.insomnia:
        writer.writeByte(22);
        break;
      case SymptomType.hotFlash:
        writer.writeByte(23);
        break;
      case SymptomType.edema:
        writer.writeByte(24);
        break;
      case SymptomType.hairLoss:
        writer.writeByte(25);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodTypeAdapter extends TypeAdapter<MoodType> {
  @override
  final int typeId = 13;

  @override
  MoodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodType.happy;
      case 1:
        return MoodType.sad;
      case 2:
        return MoodType.angry;
      case 3:
        return MoodType.anxious;
      case 4:
        return MoodType.calm;
      case 5:
        return MoodType.energetic;
      case 6:
        return MoodType.tired;
      case 7:
        return MoodType.romantic;
      case 8:
        return MoodType.sensitive;
      case 9:
        return MoodType.irritable;
      case 10:
        return MoodType.neutral;
      default:
        return MoodType.happy;
    }
  }

  @override
  void write(BinaryWriter writer, MoodType obj) {
    switch (obj) {
      case MoodType.happy:
        writer.writeByte(0);
        break;
      case MoodType.sad:
        writer.writeByte(1);
        break;
      case MoodType.angry:
        writer.writeByte(2);
        break;
      case MoodType.anxious:
        writer.writeByte(3);
        break;
      case MoodType.calm:
        writer.writeByte(4);
        break;
      case MoodType.energetic:
        writer.writeByte(5);
        break;
      case MoodType.tired:
        writer.writeByte(6);
        break;
      case MoodType.romantic:
        writer.writeByte(7);
        break;
      case MoodType.sensitive:
        writer.writeByte(8);
        break;
      case MoodType.irritable:
        writer.writeByte(9);
        break;
      case MoodType.neutral:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtectionMethodAdapter extends TypeAdapter<ProtectionMethod> {
  @override
  final int typeId = 14;

  @override
  ProtectionMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProtectionMethod.condom;
      case 1:
        return ProtectionMethod.pill;
      case 2:
        return ProtectionMethod.iud;
      case 3:
        return ProtectionMethod.none;
      case 4:
        return ProtectionMethod.other;
      default:
        return ProtectionMethod.condom;
    }
  }

  @override
  void write(BinaryWriter writer, ProtectionMethod obj) {
    switch (obj) {
      case ProtectionMethod.condom:
        writer.writeByte(0);
        break;
      case ProtectionMethod.pill:
        writer.writeByte(1);
        break;
      case ProtectionMethod.iud:
        writer.writeByte(2);
        break;
      case ProtectionMethod.none:
        writer.writeByte(3);
        break;
      case ProtectionMethod.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtectionMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomCategoryAdapter extends TypeAdapter<SymptomCategory> {
  @override
  final int typeId = 15;

  @override
  SymptomCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SymptomCategory.physical;
      case 1:
        return SymptomCategory.emotional;
      case 2:
        return SymptomCategory.skin;
      case 3:
        return SymptomCategory.digestive;
      case 4:
        return SymptomCategory.other;
      default:
        return SymptomCategory.physical;
    }
  }

  @override
  void write(BinaryWriter writer, SymptomCategory obj) {
    switch (obj) {
      case SymptomCategory.physical:
        writer.writeByte(0);
        break;
      case SymptomCategory.emotional:
        writer.writeByte(1);
        break;
      case SymptomCategory.skin:
        writer.writeByte(2);
        break;
      case SymptomCategory.digestive:
        writer.writeByte(3);
        break;
      case SymptomCategory.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
