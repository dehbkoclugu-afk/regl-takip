import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/input_parsing.dart';

void main() {
  group('InputParsing.weightKg', () {
    test('nokta ve virgül aynı sonucu verir (TR klavye virgül yazar)', () {
      expect(InputParsing.weightKg('60.5'), 60.5);
      expect(InputParsing.weightKg('60,5'), 60.5);
    });

    test('boşluklu girdi kabul edilir', () {
      expect(InputParsing.weightKg(' 72,3 '), 72.3);
    });

    test('bir ondalığa yuvarlanır', () {
      expect(InputParsing.weightKg('60,56'), 60.6);
      expect(InputParsing.weightKg('60,54'), 60.5);
    });

    test('aralık dışı ve anlamsız girdi null döner', () {
      expect(InputParsing.weightKg('19.9'), isNull);
      expect(InputParsing.weightKg('300.1'), isNull);
      expect(InputParsing.weightKg(''), isNull);
      expect(InputParsing.weightKg('abc'), isNull);
      expect(InputParsing.weightKg('-70'), isNull);
    });

    test('sınır değerler geçerli', () {
      expect(InputParsing.weightKg('20'), 20.0);
      expect(InputParsing.weightKg('300'), 300.0);
    });
  });
}
