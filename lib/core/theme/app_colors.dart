import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Returns theme-aware colors based on current brightness
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? backgroundDark : background;
  static Color sf(BuildContext context) =>
      isDark(context) ? surfaceDark : surface;
  static Color tp(BuildContext context) =>
      isDark(context) ? textPrimaryDark : textPrimary;
  static Color ts(BuildContext context) =>
      isDark(context) ? textSecondaryDark : textSecondary;
  static Color dv(BuildContext context) =>
      isDark(context) ? dividerDark : divider;
  static Color card(BuildContext context) =>
      isDark(context) ? cardDark : surface;

  // Ana renkler
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryLight = Color(0xFFFF6090);
  static const Color primaryDark = Color(0xFFB0003A);
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFD05CE3);
  static const Color accent = Color(0xFFFF4081);

  // Döngü fazı renkleri
  static const Color menstrual = Color(0xFFE53935);
  static const Color follicular = Color(0xFFFF8A65);
  static const Color ovulation = Color(0xFF7E57C2);
  static const Color luteal = Color(0xFFFFB74D);

  // Takvim işaretleri
  static const Color periodDay = Color(0xFFEF5350);
  static const Color periodDayLight = Color(0xFFFFCDD2);
  static const Color predictedPeriod = Color(0xFFFFAB91);
  static const Color ovulationDay = Color(0xFF7C4DFF);
  static const Color fertileWindow = Color(0xFF66BB6A);
  static const Color fertileWindowLight = Color(0xFFC8E6C9);

  // Akış yoğunluğu
  static const Color flowLight = Color(0xFFFFCDD2);
  static const Color flowNormal = Color(0xFFEF9A9A);
  static const Color flowHeavy = Color(0xFFE57373);
  static const Color flowVeryHeavy = Color(0xFFD32F2F);

  // Arka plan gradyanları
  static const List<Color> menstrualGradient = [
    Color(0xFFE91E63),
    Color(0xFFAD1457),
  ];
  static const List<Color> follicularGradient = [
    Color(0xFFFF6F00),
    Color(0xFFFF8F00),
  ];
  static const List<Color> ovulationGradient = [
    Color(0xFF7B1FA2),
    Color(0xFF9C27B0),
  ];
  static const List<Color> lutealGradient = [
    Color(0xFFFF8F00),
    Color(0xFFFFA000),
  ];
  static const List<Color> defaultGradient = [
    Color(0xFFE91E63),
    Color(0xFFFF6090),
  ];

  // Ruh hali renkleri
  static const Color moodHappy = Color(0xFFFFD54F);
  static const Color moodSad = Color(0xFF90CAF9);
  static const Color moodAngry = Color(0xFFEF5350);
  static const Color moodAnxious = Color(0xFFFFCC02);
  static const Color moodCalm = Color(0xFF81C784);
  static const Color moodEnergetic = Color(0xFFFF7043);
  static const Color moodTired = Color(0xFFB0BEC5);
  static const Color moodRomantic = Color(0xFFF48FB1);
  static const Color moodNeutral = Color(0xFFBDBDBD);

  // Takip ekranı renkleri
  static const Color water = Color(0xFF42A5F5);
  static const Color temperature = Color(0xFFFF7043);
  static const Color weightColor = Color(0xFF26A69A);
  static const Color sleep = Color(0xFF5C6BC0);
  static const Color medication = Color(0xFF66BB6A);
  static const Color notesColor = Color(0xFF8D6E63);

  // Genel - Light
  static const Color background = Color(0xFFFFF5F7);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  // Genel - Dark
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  static const Color dividerDark = Color(0xFF383838);
}
