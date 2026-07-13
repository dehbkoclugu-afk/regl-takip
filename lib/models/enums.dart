import 'package:hive/hive.dart';

part 'enums.g.dart';

/// Yedek dosyalarındaki enum adlarını güvenli çözer.
/// Bilinmeyen ad (ileri sürümden gelen yedek) null döner — çağıran
/// taraf varsayılanla devam eder, içe aktarma patlamaz.
T? enumFromName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

@HiveType(typeId: 10)
enum FlowIntensity {
  @HiveField(0)
  light,
  @HiveField(1)
  normal,
  @HiveField(2)
  heavy,
  @HiveField(3)
  veryHeavy,
}

@HiveType(typeId: 11)
enum FlowColor {
  @HiveField(0)
  lightRed,
  @HiveField(1)
  red,
  @HiveField(2)
  darkRed,
  @HiveField(3)
  brown,
}

@HiveType(typeId: 12)
enum SymptomType {
  // Fiziksel
  @HiveField(0)
  cramp,
  @HiveField(1)
  headache,
  @HiveField(2)
  bloating,
  @HiveField(3)
  breastTenderness,
  @HiveField(4)
  backPain,
  @HiveField(5)
  fatigue,
  @HiveField(6)
  nausea,
  @HiveField(7)
  dizziness,
  // Duygusal
  @HiveField(8)
  stress,
  @HiveField(9)
  anxiety,
  @HiveField(10)
  irritability,
  @HiveField(11)
  crying,
  @HiveField(12)
  sensitivity,
  // Cilt
  @HiveField(13)
  acne,
  @HiveField(14)
  oilySkin,
  @HiveField(15)
  drySkin,
  @HiveField(16)
  glowing,
  // Sindirim
  @HiveField(17)
  constipation,
  @HiveField(18)
  diarrhea,
  @HiveField(19)
  gas,
  @HiveField(20)
  increasedAppetite,
  @HiveField(21)
  decreasedAppetite,
  // Diğer
  @HiveField(22)
  insomnia,
  @HiveField(23)
  hotFlash,
  @HiveField(24)
  edema,
  @HiveField(25)
  hairLoss,
}

@HiveType(typeId: 13)
enum MoodType {
  @HiveField(0)
  happy,
  @HiveField(1)
  sad,
  @HiveField(2)
  angry,
  @HiveField(3)
  anxious,
  @HiveField(4)
  calm,
  @HiveField(5)
  energetic,
  @HiveField(6)
  tired,
  @HiveField(7)
  romantic,
  @HiveField(8)
  sensitive,
  @HiveField(9)
  irritable,
  @HiveField(10)
  neutral,
}

@HiveType(typeId: 14)
enum ProtectionMethod {
  @HiveField(0)
  condom,
  @HiveField(1)
  pill,
  @HiveField(2)
  iud,
  @HiveField(3)
  none,
  @HiveField(4)
  other,
}

@HiveType(typeId: 16)
enum TrackingMode {
  @HiveField(0)
  period,
  @HiveField(1)
  pregnancy,
  @HiveField(2)
  pill,

  /// Gebe kalmaya çalışma (trying to conceive): regl takibi + doğurganlık
  /// odaklı ekstra araçlar (LH testi logu, doğurganlık skoru)
  @HiveField(3)
  ttc,
}

@HiveType(typeId: 15)
enum SymptomCategory {
  @HiveField(0)
  physical,
  @HiveField(1)
  emotional,
  @HiveField(2)
  skin,
  @HiveField(3)
  digestive,
  @HiveField(4)
  other,
}
