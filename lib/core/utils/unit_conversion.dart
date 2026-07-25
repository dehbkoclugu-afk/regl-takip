class UnitConversion {
  UnitConversion._();

  static const double poundsPerKilogram = 2.2046226218;

  static double kilogramsToPounds(double kilograms) =>
      kilograms * poundsPerKilogram;

  static double poundsToKilograms(double pounds) => pounds / poundsPerKilogram;

  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  static double fahrenheitToCelsius(double fahrenheit) =>
      (fahrenheit - 32) * 5 / 9;
}
