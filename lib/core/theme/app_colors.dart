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

  // Ana renkler - Soft Pastel
  static const Color primary = Color(0xFFE8A0BF);
  static const Color primaryLight = Color(0xFFF2C6DE);
  static const Color primaryDark = Color(0xFFD4789E);
  // Beyaz metinle >=3:1 kontrast veren etkileşim tonları
  // (pastel primary beyazla 2.06:1 — buton/appbar zemini olarak kullanılamaz)
  static const Color primaryStrong = Color(0xFFC2607F);
  static const Color secondaryStrong = Color(0xFFA370B0);
  static const Color secondary = Color(0xFFBA90C6);
  static const Color secondaryLight = Color(0xFFD4B8DE);
  static const Color accent = Color(0xFFC0DBEA);

  // Döngü fazı renkleri - Soft
  static const Color menstrual = Color(0xFFE8A0BF);
  static const Color follicular = Color(0xFFFFCBA4);
  static const Color ovulation = Color(0xFFBA90C6);
  static const Color luteal = Color(0xFFFFD9A0);

  // Döngü fazı ring renkleri - koyu/doygun (arka plandan ayrışma için)
  static const Color ringMenstrual = Color(0xFFD4607E);
  static const Color ringFollicular = Color(0xFFE8944A);
  static const Color ringOvulation = Color(0xFF9060A8);
  static const Color ringLuteal = Color(0xFFE8A830);
  // Fertil bant: takvimdeki soluk yeşilin ring'de okunan doygun hali
  static const Color ringFertile = Color(0xFF5E9C78);

  // Takvim işaretleri
  static const Color periodDay = Color(0xFFE8A0BF);
  static const Color periodDayLight = Color(0xFFFCE4EC);
  static const Color predictedPeriod = Color(0xFFFFCCBC);
  static const Color ovulationDay = Color(0xFFBA90C6);
  static const Color fertileWindow = Color(0xFFA8D5BA);
  static const Color fertileWindowLight = Color(0xFFD4EDDA);

  // Akış yoğunluğu
  static const Color flowLight = Color(0xFFF8D0DE);
  static const Color flowNormal = Color(0xFFF0AAC0);
  static const Color flowHeavy = Color(0xFFE88AA8);
  static const Color flowVeryHeavy = Color(0xFFD4789E);

  // Arka plan gradyanları - Soft
  static const List<Color> menstrualGradient = [
    Color(0xFFE8A0BF),
    Color(0xFFD4789E),
  ];
  static const List<Color> follicularGradient = [
    Color(0xFFFFCBA4),
    Color(0xFFFFB87A),
  ];
  static const List<Color> ovulationGradient = [
    Color(0xFFBA90C6),
    Color(0xFFA370B0),
  ];
  static const List<Color> lutealGradient = [
    Color(0xFFFFD9A0),
    Color(0xFFFFC878),
  ];
  static const List<Color> defaultGradient = [
    Color(0xFFE8A0BF),
    Color(0xFFF2C6DE),
  ];

  // Ruh hali renkleri - Soft
  static const Color moodHappy = Color(0xFFFFE082);
  static const Color moodSad = Color(0xFFB3D4F0);
  static const Color moodAngry = Color(0xFFF0A0A0);
  static const Color moodAnxious = Color(0xFFFFE5A0);
  static const Color moodCalm = Color(0xFFA8D5BA);
  static const Color moodEnergetic = Color(0xFFFFBE9F);
  static const Color moodTired = Color(0xFFCFD8DC);
  static const Color moodRomantic = Color(0xFFF8BBD0);
  static const Color moodNeutral = Color(0xFFD5D5D5);

  // Takip ekranı renkleri - Soft
  static const Color water = Color(0xFF90CAF9);
  static const Color temperature = Color(0xFFFFAB91);
  static const Color weightColor = Color(0xFF80CBC4);
  static const Color sleep = Color(0xFF9FA8DA);
  static const Color medication = Color(0xFFA5D6A7);
  static const Color notesColor = Color(0xFFBCAAA4);

  // Glass efekt renkleri
  static const Color glassWhite = Color(0x59FFFFFF);
  static const Color glassWhiteStrong = Color(0x99FFFFFF);
  static const Color glassBorder = Color(0x1FBA90C6);
  static const Color glassBorderDark = Color(0x2EFFFFFF);
  static const Color glassShadow = Color(0x14000000);

  // Genel - Light
  static const Color background = Color(0xFFFDF2F8);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color textPrimary = Color(0xFF2D2D3A);
  // 4.6:1 on background — 14px gövde metni için WCAG AA
  static const Color textSecondary = Color(0xFF6E6E7A);
  static const Color divider = Color(0xFFF0E8EE);
  // 5.3:1 on surface — hata metni okunabilir olmalı
  static const Color error = Color(0xFFB04A4A);
  static const Color success = Color(0xFFA8D5BA);
  static const Color warning = Color(0xFFFFD9A0);

  // Genel - Dark
  static const Color backgroundDark = Color(0xFF1A1020);
  static const Color surfaceDark = Color(0xFF251A30);
  static const Color cardDark = Color(0xFF302240);
  static const Color textPrimaryDark = Color(0xFFE8E0F0);
  static const Color textSecondaryDark = Color(0xFFA098B0);
  static const Color dividerDark = Color(0xFF3A2E48);
}
