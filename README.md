# Regl Takip

Flutter ile geliştirilmiş yerel regl/döngü takip uygulaması. Sağlık kayıtları Hive kutularında cihaz üzerinde AES ile şifrelenir. Parolalı `.rtbackup` ve eski JSON yedeği ilk kurulumdan veya Ayarlar'dan açılır; mevcut veriler doğrulama ve yeni şifreli nesil yazımı bitmeden değiştirilmez.

## Geliştirme

- Flutter sürümü: `.fvmrc` içindeki 3.44.8; `flutter pub get` ve `flutter gen-l10n` çalıştırın.
- `flutter analyze`, `flutter test` ve `TZ=Europe/Berlin flutter test` kalite kapısıdır. `server/billing` için `npm ci --ignore-scripts && npm test` çalıştırın.
- `lib/main.dart` açılış ve kurtarma, `lib/app.dart` yaşam döngüsü/gezinti, `lib/providers` veri akışları, `lib/services/hive_service.dart` şifreli kayıt ve nesil değiştirme, `backup_service.dart` yedek işlemleri, `core/utils/cycle_prediction.dart` kaynak etiketli tahminlerdir.
- `lib/l10n/app_*.arb` değişince üretilmiş `lib/l10n/generated` çıktısını da commit edin. CI çıktının güncel olduğunu doğrular.

## Yayın

Codemagic Android/iOS işlerini `codemagic.yaml` tanımlar. İmzalı AAB için mevcut upload anahtarı ve mağaza yetkileri, satın alma için `server/billing/README.md` doğrulama servisi gerekir. Sırları depoya koymayın. PR kalite testinin geçmesi cihaz ve mağaza onayı yerine geçmez. `docs/cihaz-ve-magaza-dogrulama.md` üzerinde sürüm, cihaz, Android/iOS, Health, PIN/kılık, satın alma ve veri beyanı sonuçlarını kaydedin. Play'e çıkacak AAB'nin hedef API ve Billing sürümlerini artifact üzerinden kontrol edin.

Konsey raporundaki kalan doğrulamalar ve durumu: `docs/2026-11-05-konsey-durum.md`.
