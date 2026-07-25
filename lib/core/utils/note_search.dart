import '../../models/daily_log.dart';

List<DailyLog> filterNoteLogs(
  Iterable<DailyLog> logs, {
  String query = '',
  DateTime? start,
  DateTime? end,
}) {
  final normalizedQuery = _normalize(query);
  final results = logs.where((log) {
    final note = log.notes?.trim();
    if (note == null || note.isEmpty) return false;
    if (start != null && log.date.isBefore(_dateOnly(start))) return false;
    if (end != null && log.date.isAfter(_endOfDay(end))) return false;
    return normalizedQuery.isEmpty || _normalize(note).contains(normalizedQuery);
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return results;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

String _normalize(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll('\u0307', '')
    .replaceAll('ı', 'i');
