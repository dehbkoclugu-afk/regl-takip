/// Acknowledges each successful platform operation durably. A failed day is
/// left pending; retry deletes/replaces only that application's own day.
class HealthSyncCounts {
  final int written, deleted, pending;
  const HealthSyncCounts({
    this.written = 0,
    this.deleted = 0,
    this.pending = 0,
  });
  bool get complete => pending == 0;
}

Future<HealthSyncCounts> runHealthSyncBatch({
  required Map<String, String> plan,
  required Map<String, dynamic> ledger,
  required Future<bool> Function(String key) delete,
  required Future<bool> Function(String key, String value) write,
  required Future<void> Function(Map<String, dynamic>) persist,
}) async {
  final keys = {
    ...ledger.keys,
    ...plan.keys,
  }.where((key) => ledger[key] != plan[key]).toList()..sort();
  var written = 0, deleted = 0, pending = 0;
  for (final key in keys) {
    try {
      if (!await delete(key)) {
        pending++;
        continue;
      }
      final next = plan[key];
      if (next != null) {
        if (!await write(key, next)) {
          pending++;
          continue;
        }
        ledger[key] = next;
      } else {
        ledger.remove(key);
      }
      await persist(Map.of(ledger));
      if (next == null) {
        deleted++;
      } else {
        written++;
      }
    } catch (_) {
      // Persistence failures stop the batch; the next run re-reads the durable
      // ledger and safely replaces the ambiguous day before retrying it.
      return HealthSyncCounts(
        written: written,
        deleted: deleted,
        pending: keys.length - written - deleted,
      );
    }
  }
  return HealthSyncCounts(written: written, deleted: deleted, pending: pending);
}
