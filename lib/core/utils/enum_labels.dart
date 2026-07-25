import 'package:regl_takip/l10n/generated/app_localizations.dart';

import '../../models/enums.dart';
import 'cycle_utils.dart';

/// Enum -> lokalize etiket eşlemeleri. Ekranlardaki kopya map'lerin
/// tek kaynağı (statistics / quick status / calendar / symptom screen).
class EnumLabels {
  EnumLabels._();

  static String mood(MoodType mood, AppLocalizations l10n) {
    final names = {
      MoodType.happy: l10n.happy, MoodType.sad: l10n.sad,
      MoodType.angry: l10n.angry, MoodType.anxious: l10n.anxious,
      MoodType.calm: l10n.calm, MoodType.energetic: l10n.energetic,
      MoodType.tired: l10n.tired, MoodType.romantic: l10n.romantic,
      MoodType.sensitive: l10n.sensitiveM, MoodType.irritable: l10n.irritableM,
      MoodType.neutral: l10n.neutralM,
    };
    return names[mood] ?? mood.name;
  }

  /// Döngü fazının okunur adı. Ana ekran ve istatistik ekranı aynı
  /// switch'i birebir kopyalamıştı; ring'in ekran okuyucu etiketi de
  /// aynısına ihtiyaç duyunca üçüncü kopya yerine buraya taşındı.
  static String phase(CyclePhase phase, AppLocalizations l10n) {
    switch (phase) {
      case CyclePhase.menstrual:
        return l10n.menstrualPhase;
      case CyclePhase.follicular:
        return l10n.follicularPhase;
      case CyclePhase.ovulation:
        return l10n.ovulationPhase;
      case CyclePhase.luteal:
        return l10n.lutealPhase;
    }
  }

  static String flow(FlowIntensity intensity, AppLocalizations l10n) {
    final names = {
      FlowIntensity.light: l10n.light,
      FlowIntensity.normal: l10n.medium,
      FlowIntensity.heavy: l10n.heavy,
      FlowIntensity.veryHeavy: l10n.veryHeavy,
    };
    return names[intensity] ?? intensity.name;
  }

  static String symptom(SymptomType type, AppLocalizations l10n) {
    final names = {
      SymptomType.cramp: l10n.cramps, SymptomType.headache: l10n.headache,
      SymptomType.bloating: l10n.bloating,
      SymptomType.breastTenderness: l10n.breastTenderness,
      SymptomType.backPain: l10n.backPain, SymptomType.fatigue: l10n.fatigue,
      SymptomType.nausea: l10n.nausea, SymptomType.dizziness: l10n.dizziness,
      SymptomType.stress: l10n.stress, SymptomType.anxiety: l10n.anxiety,
      SymptomType.irritability: l10n.irritability,
      SymptomType.crying: l10n.crying,
      SymptomType.sensitivity: l10n.sensitivity, SymptomType.acne: l10n.acne,
      SymptomType.oilySkin: l10n.oilySkin, SymptomType.drySkin: l10n.drySkin,
      SymptomType.glowing: l10n.glowingSkin,
      SymptomType.constipation: l10n.constipation,
      SymptomType.diarrhea: l10n.diarrhea, SymptomType.gas: l10n.gas,
      SymptomType.increasedAppetite: l10n.increasedAppetite,
      SymptomType.decreasedAppetite: l10n.decreasedAppetite,
      SymptomType.insomnia: l10n.insomnia, SymptomType.hotFlash: l10n.hotFlash,
      SymptomType.edema: l10n.swelling, SymptomType.hairLoss: l10n.hairLoss,
    };
    return names[type] ?? type.name;
  }
}
