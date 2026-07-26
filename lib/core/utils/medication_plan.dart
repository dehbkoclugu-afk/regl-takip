import '../../models/daily_log.dart';
import '../../models/period_record.dart';

String medicationIdentity(MedicationEntry medication) =>
    '${medication.name.trim().toLowerCase()}\u0000'
    '${medication.dose.trim().toLowerCase()}\u0000'
    '${medication.reminderTime ?? ''}';

MedicationEntry medicationDefinition(MedicationEntry medication) =>
    MedicationEntry(
      name: medication.name.trim(),
      dose: medication.dose.trim(),
      reminderTime: medication.reminderTime,
    );

/// Eski modelden geçiş: en yeni ilaçlı gün, kalıcı planın başlangıcıdır.
List<MedicationEntry> medicationPlanFromLogs(Iterable<DailyLog> logs) {
  final candidates = logs.where((log) => log.medications.isNotEmpty).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  if (candidates.isEmpty) return const [];

  final seen = <String>{};
  return candidates.first.medications
      .map(medicationDefinition)
      .where((medication) => seen.add(medicationIdentity(medication)))
      .toList();
}

/// Kalıcı tanımları, seçili günün alınma durumlarıyla birleştirir.
List<MedicationEntry> medicationEntriesForDay(
  Iterable<MedicationEntry> plan,
  Iterable<MedicationEntry> dailyEntries,
) {
  final takenByIdentity = {
    for (final medication in dailyEntries)
      medicationIdentity(medication): medication.taken,
  };
  return plan.map((medication) {
    final definition = medicationDefinition(medication);
    return MedicationEntry(
      name: definition.name,
      dose: definition.dose,
      reminderTime: definition.reminderTime,
      taken: takenByIdentity[medicationIdentity(definition)] ?? false,
    );
  }).toList();
}

/// Güncel plan yazılırken plandan kaldırılmış tarihsel girdileri korur.
List<MedicationEntry> medicationDailyRecord(
  Iterable<MedicationEntry> currentEntries,
  Iterable<MedicationEntry> existingDailyEntries,
) {
  final current = currentEntries.toList();
  final currentIdentities = current.map(medicationIdentity).toSet();
  return [
    ...existingDailyEntries.where(
      (medication) =>
          !currentIdentities.contains(medicationIdentity(medication)),
    ),
    ...current,
  ];
}
