import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Only application-owned exports are eligible. A generous retention window
/// protects files still in use by another application's share sheet.
class ExportCleanup {
  static Future<void> run({Directory? directory, DateTime? now}) async {
    final dir = directory ?? await getTemporaryDirectory();
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 2));
    final owned = RegExp(
        r'^(period_tracker_|period_calendar_|regl_takip_backup_)\d+_\d+\.(csv|pdf|ics|rtbackup)$');
    await for (final entry in dir.list(followLinks: false)) {
      if (entry is! File || !owned.hasMatch(entry.uri.pathSegments.last)) {
        continue;
      }
      try {
        if ((await entry.lastModified()).isBefore(cutoff)) await entry.delete();
      } on FileSystemException {/* An active share may still hold the file. */}
    }
  }
}
