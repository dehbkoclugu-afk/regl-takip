import '../../models/daily_log.dart';
import '../../models/enums.dart';

/// Hızlı kayıt sayfasındaki semptom listesini kullanıcının kendi
/// geçmişine göre sıralar.
///
/// Liste sabit bir sırayla duruyordu: kullanıcı her seferinde kendi
/// semptomunu aramak zorundaydı. Sık girdikleri öne alınınca liste
/// kullanıldıkça kişiselleşiyor.
class SymptomRanking {
  SymptomRanking._();

  /// Sıralamada kaç günlük geçmişe bakılacağı. Daha eskisi artık geçerli
  /// olmayan bir dönemi (ör. bıraktığı bir ilacın yan etkisi) öne taşır.
  static const int windowDays = 90;

  /// [fallback] sırasını koruyarak, [logs] içinde son [windowDays] günde
  /// en çok görülen semptomları öne alır.
  ///
  /// Dönen liste her zaman [fallback] ile aynı uzunlukta ve aynı öğeleri
  /// içerir — yalnız sıra değişir. Sayfadaki seçenek kümesinin kullanıcının
  /// geçmişine göre daralması, hiç girmediği bir semptomu bulmasını
  /// imkânsız kılardı.
  static List<SymptomType> reorder(
    List<SymptomType> fallback,
    Iterable<DailyLog> logs, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final cutoff = reference.subtract(const Duration(days: windowDays));

    final counts = <SymptomType, int>{};
    for (final log in logs) {
      if (log.date.isBefore(cutoff)) continue;
      for (final entry in log.symptoms) {
        counts[entry.type] = (counts[entry.type] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return List<SymptomType>.from(fallback);

    // Sıralama kararlı olmalı: eşit sayıda girilen iki semptom, listede
    // önce geleni önce kalsın — sıra her açılışta zıplamamalı
    final ordered = List<SymptomType>.from(fallback);
    ordered.sort((a, b) {
      final diff = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      if (diff != 0) return diff;
      return fallback.indexOf(a).compareTo(fallback.indexOf(b));
    });
    return ordered;
  }
}
