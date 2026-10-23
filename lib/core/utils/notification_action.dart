import 'dart:convert';
import 'medication_plan.dart';
import '../../models/period_record.dart';

enum NotificationGate { wait, discard, allow }

NotificationGate notificationGate(
    {required bool resolved,
    required bool locked,
    required bool resumed,
    required bool onboarded,
    required bool disguised}) {
  if (!resolved || locked || !resumed) return NotificationGate.wait;
  if (!onboarded || disguised) return NotificationGate.discard;
  return NotificationGate.allow;
}

String medicationNotificationPayload(MedicationEntry med, DateTime day) =>
    jsonEncode({
      'v': 1,
      'id': medicationIdentity(med),
      'day': DateTime(day.year, day.month, day.day).toIso8601String()
    });

String recurringMedicationPayload(MedicationEntry med) =>
    jsonEncode({'v': 2, 'id': medicationIdentity(med)});

String? parseRecurringMedicationId(String? source) {
  try {
    final data = jsonDecode(source ?? '') as Map<String, dynamic>;
    return data['v'] == 2 && data['id'] is String ? data['id'] as String : null;
  } catch (_) {
    return null;
  }
}

({String id, DateTime day})? parseMedicationNotification(String? source) {
  try {
    final data = jsonDecode(source ?? '') as Map<String, dynamic>;
    final day = DateTime.tryParse(data['day'] as String);
    if (data['v'] != 1 || data['id'] is! String || day == null) return null;
    return (
      id: data['id'] as String,
      day: DateTime(day.year, day.month, day.day)
    );
  } catch (_) {
    return null;
  }
}
