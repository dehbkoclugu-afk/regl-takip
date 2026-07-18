import 'dart:ui' as ui;

/// Desteklenen arayüz dilleri (arb dosyalarıyla birebir).
const supportedLanguageCodes = ['tr', 'en', 'es', 'de', 'fr', 'ru'];

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
  final sys = ui.PlatformDispatcher.instance.locale.languageCode;
  return supportedLanguageCodes.contains(sys) ? sys : 'en';
}
