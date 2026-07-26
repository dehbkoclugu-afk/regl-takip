import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/models/period_record.dart';
import 'package:regl_takip/services/health_sync_service.dart';

PeriodRecord record(DateTime start, DateTime? end) =>
    PeriodRecord(id: 'x', startDate: start, endDate: end);

void main() {
  group('bitişik günleri gruplama', () {
    test('boş liste boş sonuç verir', () {
      expect(HealthSyncService.groupConsecutiveDays([]), isEmpty);
    });

    test('tek gün tek aralık', () {
      final ranges = HealthSyncService.groupConsecutiveDays(
          [DateTime(2026, 3, 10)]);
      expect(ranges.length, 1);
      expect(ranges.first.$1, DateTime(2026, 3, 10));
      expect(ranges.first.$2, DateTime(2026, 3, 10));
    });

    test('ardışık günler tek aralıkta toplanır', () {
      final ranges = HealthSyncService.groupConsecutiveDays([
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 11),
        DateTime(2026, 3, 12),
      ]);
      expect(ranges.length, 1);
      expect(ranges.first.$1, DateTime(2026, 3, 10));
      expect(ranges.first.$2, DateTime(2026, 3, 12));
    });

    test('boşluk yeni aralık başlatır', () {
      final ranges = HealthSyncService.groupConsecutiveDays([
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 11),
        DateTime(2026, 4, 8),
        DateTime(2026, 4, 9),
      ]);
      expect(ranges.length, 2);
      expect(ranges[0].$2, DateTime(2026, 3, 11));
      expect(ranges[1].$1, DateTime(2026, 4, 8));
    });

    test('sırasız giriş sıralanır', () {
      // Health Connect sırayı garanti etmiyor
      final ranges = HealthSyncService.groupConsecutiveDays([
        DateTime(2026, 3, 12),
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 11),
      ]);
      expect(ranges.length, 1);
      expect(ranges.first.$1, DateTime(2026, 3, 10));
    });

    test('tekrarlı günler tek sayılır', () {
      final ranges = HealthSyncService.groupConsecutiveDays([
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 10, 18),
        DateTime(2026, 3, 11),
      ]);
      expect(ranges.length, 1);
      expect(ranges.first.$2, DateTime(2026, 3, 11));
    });

    test('ay sınırını aşan ardışıklık bölünmez', () {
      final ranges = HealthSyncService.groupConsecutiveDays([
        DateTime(2026, 3, 30),
        DateTime(2026, 3, 31),
        DateTime(2026, 4, 1),
      ]);
      expect(ranges.length, 1);
      expect(ranges.first.$1, DateTime(2026, 3, 30));
      expect(ranges.first.$2, DateTime(2026, 4, 1));
    });
  });

  group('mevcut kayıtla kesişim', () {
    final existing = [
      record(DateTime(2026, 3, 10), DateTime(2026, 3, 14)),
    ];

    test('tamamen önce kesişmez', () {
      expect(
        HealthSyncService.overlapsExisting(
            (DateTime(2026, 3, 1), DateTime(2026, 3, 5)), existing),
        isFalse,
      );
    });

    test('tamamen sonra kesişmez', () {
      expect(
        HealthSyncService.overlapsExisting(
            (DateTime(2026, 3, 20), DateTime(2026, 3, 24)), existing),
        isFalse,
      );
    });

    test('bitişik gün kesişmez', () {
      // 15 Mart, 14'te biten kaydın hemen ertesi: ayrı bir dönem
      expect(
        HealthSyncService.overlapsExisting(
            (DateTime(2026, 3, 15), DateTime(2026, 3, 18)), existing),
        isFalse,
      );
    });

    test('tek gün örtüşmesi kesişim sayılır', () {
      expect(
        HealthSyncService.overlapsExisting(
            (DateTime(2026, 3, 14), DateTime(2026, 3, 18)), existing),
        isTrue,
      );
    });

    test('tamamen içine düşen aralık kesişir', () {
      expect(
        HealthSyncService.overlapsExisting(
            (DateTime(2026, 3, 11), DateTime(2026, 3, 12)), existing),
        isTrue,
      );
    });

    test('devam eden kayıt bugüne kadar kapsar', () {
      final ongoing = [record(DateTime.now().subtract(const Duration(days: 3)), null)];
      final today = DateTime.now();
      expect(
        HealthSyncService.overlapsExisting(
          (DateTime(today.year, today.month, today.day),
              DateTime(today.year, today.month, today.day)),
          ongoing,
        ),
        isTrue,
      );
    });

    test('kayıt yoksa hiçbir şey kesişmez', () {
      expect(
        HealthSyncService.overlapsExisting(
            (DateTime(2026, 3, 10), DateTime(2026, 3, 14)), const []),
        isFalse,
      );
    });
  });
}
