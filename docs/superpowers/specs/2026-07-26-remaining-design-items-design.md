# Kalan tasarım maddeleri — tasarım

## Kapsam

`docs/tasarim-onerileri.md` içinde açık veya kısmi kalan 3, 7, 9 ve 71.
maddeleri tamamlanır. Mevcut veri modeli ve satın alma hakları geriye uyumlu
kalır.

## 3 — Ücretsiz salt-okunur erişim

Denemesi biten kullanıcı günlük takip rotalarını ve geçmiş verisini
görüntüleyebilir. Router bu rotaları artık paywall'a yönlendirmez. Veri
değiştiren ekran eylemleri ortak premium kapısından geçer; ücretsiz kullanıcı
yazmayı denediğinde plan ekranı açılır ve hiçbir provider/Hive yazması
gerçekleşmez. Regl başlangıcı/bitişi ve regl geçmişi düzeltmesi ücretsiz
katmanın mevcut istisnası olarak korunur.

## 7 — Kayıt sonrası reklam

Uygulama açılışı ve kilit açılışı reklam tetiklemez. Başarılı kullanıcı kaydı
sonrasında uygulama köküne tek bir olay gönderilir. Ücretsiz katmanda bunun
gerçek kaynağı regl başlatma/bitirme ve düzeltme akışıdır; geri alınan kayıt
olay üretmez. Kök, ücretsiz erişim,
deneme sonu açıklaması, 24 saat sınırı, kılık/kilit ve oturumdaki tek gösterim
kurallarını yeniden doğruladıktan sonra reklamı gösterir. Bir hızlı kayıt
birden fazla alan yazsa bile olay yalnız kullanıcı eylemi tamamlanınca
gönderilir.

## 9 — Ömür boyu plan

Mevcut `premium_no_ads` tek seferlik mağaza ürünü ömür boyu premium planı
olarak kullanılır. Mağaza ürün ayrıntısını döndürürse paywall'da aylık ve
yıllık planların altında görünür; ürün tanımlı değilse kart hiç çizilmez.
Satın alma ve geri yükleme mevcut premium hakkını kullanır.

## 71 — Bildirim sıklığı

Kullanıcı döngü başına bildirim yoğunluğunu temel, dengeli veya ayrıntılı
seçer. Temel yalnız etkin regl hatırlatmasını; dengeli ayrıca etkin ovülasyon
hatırlatmasını; ayrıntılı bunlara gecikme, TTC verimli pencere, kişisel faz
içgörüsü ve zincir sonu uyarısını ekler. Tür başına aç/kapa tercihleri üst
sınırdır. İlaç hatırlatmaları günlük tedavi güvenliği nedeniyle bu tercihten
etkilenmez. Varsayılan `3`, eski davranıştır.

## Veri ve test

Yeni profil alanı Hive alanı 31 ve JSON anahtarı
`cycleNotificationFrequency` olarak eklenir; eksik/eski kayıtta `3` kabul
edilir. Saf bildirim düzeyi kararları test edilir. Satın alma ürün çözümleme
ve reklam zamanlama kontrolleri mevcut test yüzeylerini korur.
