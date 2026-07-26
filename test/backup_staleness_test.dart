import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/services/backup_service.dart';

void main() {
  group('yedek bayatlığı', () {
    test('hiç yedek alınmamışsa bayat sayılır', () {
      // En sık ve en tehlikeli durum: kullanıcı hiç yedek almamış
      expect(BackupService.isStale(null), isTrue);
    });

    test('bugün alınan yedek bayat değil', () {
      expect(BackupService.isStale(DateTime.now()), isFalse);
    });

    test('eşiğin bir gün altı hâlâ taze', () {
      final last = DateTime.now()
          .subtract(Duration(days: BackupService.backupStaleDays - 1));
      expect(BackupService.isStale(last), isFalse);
    });

    test('eşiğe ulaşan yedek bayat', () {
      final last = DateTime.now()
          .subtract(Duration(days: BackupService.backupStaleDays));
      expect(BackupService.isStale(last), isTrue);
    });

    test('çok eski yedek bayat', () {
      final last = DateTime.now().subtract(const Duration(days: 400));
      expect(BackupService.isStale(last), isTrue);
    });
  });
}
