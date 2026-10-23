import 'dart:ui' as ui;

/// Desteklenen arayüz dilleri (arb dosyalarıyla birebir).
const supportedLanguageCodes = ['tr', 'en', 'es', 'de', 'fr', 'ru', 'pt', 'ar', 'hi', 'zh'];

/// Profildeki dil tercihini somut dil koduna çözer.
/// 'system' (ya da tanınmayan değer) = cihaz dili; cihaz dili
/// desteklenmiyorsa İngilizce. Bildirim/widget gibi BuildContext'siz
/// yerler bu fonksiyonu kullanır — arayüz MaterialApp'in kendi sistem
/// dili çözümlemesini izler.
String resolveLanguageCode(String? stored) {
  if (stored != null &&
      stored != 'system' &&
      supportedLanguageCodes.contains(stored)) {
    return stored;
  }
  return resolveAppLocale(ui.PlatformDispatcher.instance.locales).languageCode;
}

/// Match the user's ordered language preferences and use English otherwise.
/// Shared by MaterialApp and services so unsupported devices never get Arabic
/// merely because generated locales are sorted alphabetically.
ui.Locale resolveAppLocale(List<ui.Locale>? preferred) {
  for (final locale in preferred ?? const <ui.Locale>[]) {
    if (supportedLanguageCodes.contains(locale.languageCode)) {
      return ui.Locale(locale.languageCode);
    }
  }
  return const ui.Locale('en');
}
