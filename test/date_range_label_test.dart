import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:regl_takip/core/utils/date_range_label.dart';

void main() {
  setUpAll(initializeDateFormatting);

  group('verimli pencere etiketi', () {
    // Kart ekran genişliğinin üçte birine sığmak zorunda: "25 Tem - 31 Tem"
    // sarınca kırılma tarihin ortasına düşüyor ve ay adı günden kopuyordu.
    test('aynı ay içindeki aralıkta ay bir kez yazılır', () {
      expect(
        fertileWindowLabel(DateTime(2026, 7, 25), DateTime(2026, 7, 31), 'tr'),
        '25 - 31 Tem',
      );
    });

    test('aylar farklıysa iki tarih de tam yazılır', () {
      expect(
        fertileWindowLabel(DateTime(2026, 7, 28), DateTime(2026, 8, 3), 'tr'),
        '28 Tem - 3 Ağu',
      );
    });

    test('yıl farkı ayı tekrar ettirir', () {
      // Aralık-ocak geçişinde ay numaraları eşit olmasa da yıl kontrolü
      // olmadan aynı-ay dalına düşen bir aralık üretmek mümkün olurdu
      expect(
        fertileWindowLabel(DateTime(2026, 12, 29), DateTime(2027, 1, 4), 'tr'),
        '29 Ara - 4 Oca',
      );
    });

    test('gün ile ay arasında bölünmez boşluk var', () {
      final label =
          fertileWindowLabel(DateTime(2026, 7, 28), DateTime(2026, 8, 3), 'tr');
      // Sarma yalnız tirenin iki yanındaki normal boşluklardan olmalı
      expect(label.split(' ').length, 3);
      expect(label.contains(' '), isTrue);
    });

    test('ingilizce yerelde de aynı kural işler', () {
      expect(
        fertileWindowLabel(DateTime(2026, 7, 25), DateTime(2026, 7, 31), 'en'),
        '25 - 31 Jul',
      );
    });
  });
}
