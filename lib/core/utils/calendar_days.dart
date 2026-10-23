/// Elapsed 24-hour durations are not calendar dates across DST changes.
class CalendarDays {
  static DateTime utc(DateTime d) => DateTime.utc(d.year, d.month, d.day);
  static int between(DateTime later, DateTime earlier) =>
      utc(later).difference(utc(earlier)).inDays;
  static DateTime add(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days, d.hour, d.minute);
}
