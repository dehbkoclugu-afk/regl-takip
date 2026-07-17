import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Açık ve koyu tema tek üreticiden çıkar: iki tema %85 aynıydı ve her
/// değişiklik iki yerde yapılmak zorundaydı (buton dolgusu, köşe yarıçapı,
/// snackbar biçimi...). Yalnız gerçekten ayrışan değerler dallanır.
///
/// Bilinçli temizlikler:
/// - cardTheme ve bottomNavigationBarTheme kaldırıldı: uygulama Material
///   `Card` widget'ı kullanmıyor (kartlar GlassCard) ve gezinme M3
///   `NavigationBar` (kendi temasını shell kuruyor) — ikisi de okuyana
///   yanlış harita çizen ölü konfigürasyondu.
/// - Koyu temada yarı saydam yüzeyler (kart %70, input dolgusu %60)
///   opaklaştırıldı: "opak yüzeyler" tasarım kararının kalıntısıydı,
///   yarı saydam yüzeyde metin kontrastı garanti edilemez.
class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Nunito';

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final ink = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final inkSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;

    TextStyle style(double size, FontWeight weight, Color color) =>
        TextStyle(fontSize: size, fontWeight: weight, color: color);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      textTheme: TextTheme(
        headlineLarge: style(28, FontWeight.w800, ink),
        headlineMedium: style(24, FontWeight.w800, ink),
        headlineSmall: style(20, FontWeight.w600, ink),
        titleLarge: style(18, FontWeight.w600, ink),
        titleMedium: style(16, FontWeight.w600, ink),
        // Gövde w500: display anları (w800) ile net kontrast —
        // her şey bold olunca vurgu ölüyordu
        bodyLarge: style(16, FontWeight.w500, ink),
        bodyMedium: style(14, FontWeight.w500, inkSecondary),
        bodySmall: style(12, FontWeight.w500, inkSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // Status bar ikonları temayı izler; global SystemChrome ayarı
        // yerine tema yönetir (açık temada beyaz ikon sorunu)
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: brightness,
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ink,
        ),
        iconTheme: IconThemeData(color: ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryStrong,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? AppColors.primaryLight : AppColors.primary,
          side: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryStrong,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: isDark
              ? const BorderSide(color: AppColors.dividerDark)
              : BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
