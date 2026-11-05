import 'package:intl/intl.dart';

class UnitConversion {
  UnitConversion._();
  static String formatTemperature(
    double celsius, {
    bool fahrenheit = false,
    String locale = 'en',
  }) {
    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    ).format(fahrenheit ? celsiusToFahrenheit(celsius) : celsius);
    return '$number ${fahrenheit ? '°F' : '°C'}';
  }

  static const double poundsPerKilogram = 2.2046226218;

  static double kilogramsToPounds(double kilograms) =>
      kilograms * poundsPerKilogram;

  static double poundsToKilograms(double pounds) => pounds / poundsPerKilogram;

  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  static double fahrenheitToCelsius(double fahrenheit) =>
      (fahrenheit - 32) * 5 / 9;
}
