# Cihaz ve mağaza doğrulama planı

Bu plan hazırlanmıştır; aşağıdaki fiziksel testler çalıştırılmış sayılmaz. Her çalıştırmada sürüm/commit, cihaz, OS, saat dilimi, izinler, beklenen/gerçek sonuç ve ekran kaydı yazılmalı. Sentetik sağlık verileri ve mağaza test hesapları kullanılmalı.

| Alan | Adımlar | Kabul sonucu |
|---|---|---|
| Android bildirim | Pixel, Samsung ve Xiaomi üzerinde saatli ilaç kur; normal, pil tasarrufu ve kısıtlı pil durumunda bekle; cihazı yeniden başlat. | İzin ve üretici kısıtına göre teslim sonucu kaydedilir; tam dakika garantisi verilmez. Uygulama yeniden açılınca plan yenilenir. |
| İzin reddi | Android 13+ bildirim iznini reddet; günlük kaydet; ayarlardan izin verip geri dön. | Kayıt başarısız olmaz, izin sonrası yeni plan oluşur. |
| Zorla durdurma | Sistem ayarından force-stop; zamanı geçir; uygulamayı elle yeniden aç. | Android'in force-stop teslim kısıtı açıkça kaydedilir; açılışta plan tekrar kurulur. |
| Saat/dil | İstanbul→Berlin ve Berlin yaz saati sınırında saat dilimini değiştir; sistem dilini EN→AR değiştir, uygulamaya dön. | Hatırlatma yerel saati ve widget dili güncellenir; aynı güne yanlış kayıt oluşmaz. |
| Eski ilaç bildirimi | Aynı adlı iki farklı doz kur; bildirimi gece yarısından sonra aç; kilit açık/kapalı ve gizli modu dene. | Kilitliyken kayıt yok; yinelenen bildirimde kullanıcı günü seçer; yalnız seçilen doz değişir. İptalde yazma olmaz. |
| iOS önizleme | Hassas günlük açıkken uygulama değiştiriciye geç, ekran kaydı al; bildirim merkezi ve izin diyaloğunu da dene. | Arka plan önizlemesinde sağlık içeriği görünmez; dönüşte örtü kalkar. Ekran görüntüsü engeli vaat edilmez. |
| Health platformu | Hafif/yoğun/bilinmeyen akışlı üç gün aktar; tekrar aktar; eski günü değiştir/sil; izni kaldırıp yeniden dene. | Akış korunur; uygulamanın kayıtları çoğalmaz; başarısız yazma başarı sayılmaz; başka uygulamanın kayıtları silinmez. |
| Mağaza pending | Play lisans testçisinde bekleyen ödeme başlat; ikinci kez satın almaya bas; iptal et. | Bekleme görünür, ikinci akış başlamaz, premium açılmaz; iptal durumu gösterilir. |
| Mağaza hakları | Aylık/yıllık/ömür boyu satın al; yenileme, iptal, grace, expiry, refund/revoke durumlarını mağaza araçlarıyla oluştur. | Sunucunun gerçek hak ve bitiş yanıtıyla arayüz uyuşur; doğrulama olmadan acknowledgement yapılmaz; süresi biten aylık hak ömür boyu hakkı kapatmaz. |
| Çevrimdışı/cihaz değişimi | Geçerli yıllık hakla ağı kes; yeni kurulumda restore; sunucuya timeout/500 döndür. | Geçerli önbellek süresine kadar korunur; yeni doğrulanmamış hak açılmaz; başarısız işlem tekrar denenebilir. |
| Sahte makbuz | Sandbox endpoint'ine yanlış ürün/paket/bundle, bozuk JWS ve başka uygulama token'ı gönder. | Aktif hak verilmez; loglara token/makbuz/sağlık verisi yazılmaz. |
| Ekran okuyucu | TalkBack ve VoiceOver ile yeni regl kaydet, geçmiş günü bul, ring ve takvim işaretlerini oku, günlük düzenle. | Gün, seçili durum ve gerçek/tahmin anlamı renge bakmadan anlaşılır; görev tamamlanır. |
| Büyük yazı | AR/DE/HI/ZH, 320 px eşdeğeri, %200 yazı, klavye açık: dil seçimi, tüm kurulum formları ve tahmin kartları. | Temel düğmeler kaydırarak erişilebilir; metin/klavye örtüşmesi ve kesilen denetim yok. |
| On yıllık geçmiş | Düşük donanımlı Android'de 3653 günlük sentetik yedek aç; dashboard, aralık filtresi ve tam PDF üret. | Açılış, etkileşim, en yüksek bellek ve çıktı süresi ölçülür; işletim sistemi süreci öldürmez. Otomatik masaüstü testi telefon performansı yerine sayılmaz. |
| PDF görsel kalite | İnternet kapalı AR/HI/ZH/TR raporu üret; uzun not ve karışık sayı/Latin metni koy. | Birleşik harfler, RTL sırası, satır sonları ve glifler gözle denetlenir; eksik emoji/glifler ayrıca kaydedilir. |

Sunucu kurulumu ve sır yönetimi için `../server/billing/README.md` kullanılır. Gizli anahtarlar veya servis hesabı JSON'u mobil uygulamaya/repository'ye konmaz.
