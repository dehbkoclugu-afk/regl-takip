# Konsey raporu uygulama durumu — 5 Kasım 2026

Bu tablo kod, otomatik test ve cihaz/mağaza kanıtını ayırır. PR #11, PR #10'u taban alır ve PR #7'nin daha önce ana dala girmeyen değişikliklerini içerir. `main` henüz güncellenmedi.

| Bulgu | Kod durumu | Kapanış için kalan kanıt/iş |
|---|---|---|
| R01/R13 veri değiştirme ve doğrulama | Geri yükleme, migrasyon ve tümünü silme için nesil tabanlı şifreli değiştirme; önce alan/ilişki doğrulama ve kesintili silme hata testleri var | Gerçek cihazda güç kesme, dolu disk, eski binary yükseltme/düşürme, karantina kurtarma |
| R02/R10 tahmin kaynağı ve tarihler | Kaynak etiketli hesap Bugün, takvim, halka ve widget'a taşındı; kesin teyit dili kaldırıldı | Her modda ve iki cihazda LH/BBT geçmişi ile takvim/push tutarlılığı; tıbbi editör incelemesi |
| R03/R14 gizlilik | PIN/kılık widget nötr, silme owned geçici dosya/notlar/PIN sayaçları ve yerel kullanım sayaçlarını kapsar; yardımcı temizlikten sonra Hive silinir, geçici dosya hatası başarı sayılmaz; Android native açılış nötr | Android 12+ açık/koyu, force-stop/widget/bildirim; iOS app switcher/Health ve veri/ağ akışı kanıtı |
| R04 Sağlık | Başarı/kısmi/başarısız/izin yok sonucu, yazılan/silinen/bekleyen sayıları; gün bazlı kalıcı defter ve seri işlem | Health Connect/HealthKit izin, tekrar dene, başka uygulama kaydını koru testi |
| R05 formlar | Düzenleyiciler tarih sabitler, günlük alan yazımı seri ve kopyayla yapılır; birleşik ölçüm yalnız değişen alanları yazar; hızlı kayıt dört alanı tek yazımda günceller ve aynı ruh hali notunu korur | Ekranların tamamında gece yarısı, taslak, disk hatası ve geri dönüş akışı |
| R06 ödeme/reklam | PR #7'nin hak önbelleği, doğrulama sunucusu, UMP kapısı ve mevcut ürün kimlikleri | HTTPS sunucu dağıtımı, Play/StoreKit sandbox iade/iptal/geç yanıt ve reklam ağ ölçümü |
| R07/R11 arayüz | Yüksek kontrastlı not/bilgi düğmesi, bilgi penceresinde kaydırma ve beyaz/metin zemini için 4,5:1 otomatik kontrast kapısı | 320 dp, %200, DE/RU, TalkBack/VoiceOver, fiziksel klavye ve tüm ekranlarda kontrast ölçümü |
| R08/R12 kalite | PR analizi, l10n, UTC/Berlin Flutter testleri; gerçek ekranlar ve dialog için smoke test | Düşük/orta seviye Android profil ölçümü, tamamlanmış kullanıcı akışı/boot ve imzalı release |
| R09 kurulum restore | Ayarlar ve ilk kurulum aynı şifreli/JSON seçimi, boyut sınırı, parola, doğrulama, önizleme ve iptal akışı | Başka cihazda doğru/yanlış parola, iptal, büyük/bozuk dosya kabul matrisi |
| R15/R16 mod/birim | Deneme sonunda kayıtlı mod korunur; takvim Fahrenheit tercihini kullanır | Mod değişirken açık ekran ve dışa aktarım birim/başlık matrisi |

Ayrıntılı ekran tablosundaki tasarım ve cihaz kabul senaryoları da tamamlanmış sayılmaz. Özellikle yıllık takvim, semptom sıralaması, uyku DST, PDF tipografisi, Play sağlık/Data Safety beyanı ve tüm dillerin anadili editörü kontrolü fiziksel veya uzman çalışması gerektirir. İlgili cihaz/mağaza kayıtları tamamlanana kadar üretime dağıtım yapılmamalıdır.
