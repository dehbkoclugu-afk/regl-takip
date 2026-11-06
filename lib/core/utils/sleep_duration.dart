import 'package:flutter/material.dart';

/// The selected log day is the wake-up day. Clock-only records are evaluated
/// in the device's current timezone; historical travel across zones cannot be
/// reconstructed without storing an offset in the record.
Duration sleepElapsed(DateTime wakeDay, TimeOfDay bedtime, TimeOfDay wakeTime) {
  final bedMinutes = bedtime.hour * 60 + bedtime.minute;
  final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
  if (bedMinutes == wakeMinutes) {
    throw ArgumentError('Sleep start and end must differ');
  }
  final day = DateTime(wakeDay.year, wakeDay.month, wakeDay.day);
  final wake = DateTime(
    day.year, day.month, day.day, wakeTime.hour, wakeTime.minute,
  );
  final bedDay = DateTime(
    day.year, day.month, day.day - (bedMinutes > wakeMinutes ? 1 : 0),
  );
  final bed = DateTime(
    bedDay.year, bedDay.month, bedDay.day, bedtime.hour, bedtime.minute,
  );
  return wake.difference(bed);
}
