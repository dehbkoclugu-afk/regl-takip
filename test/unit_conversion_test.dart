import 'package:flutter_test/flutter_test.dart';
import 'package:regl_takip/core/utils/unit_conversion.dart';

void main() {
  group('weight conversion', () {
    test('kilograms and pounds round-trip', () {
      final pounds = UnitConversion.kilogramsToPounds(60);
      expect(pounds, closeTo(132.277, 0.001));
      expect(UnitConversion.poundsToKilograms(pounds), closeTo(60, 0.001));
    });
  });

  group('temperature conversion', () {
    test('body temperature converts to Fahrenheit and back', () {
      final fahrenheit = UnitConversion.celsiusToFahrenheit(36.5);
      expect(fahrenheit, closeTo(97.7, 0.001));
      expect(
        UnitConversion.fahrenheitToCelsius(fahrenheit),
        closeTo(36.5, 0.001),
      );
    });
  });
}
