# 50 önerinin uygulama durumu

23 Ekim 2026. Bu belge ilk incelemenin devamıdır. **Kod değişikliği, fiziksel cihaz testi, mağaza doğrulaması ve uzman onayı ayrı sonuçlardır.** “Uygulandı” kaynak kodu ve belirtilen otomatik kontrollerin kapsamını anlatır; üretime hazır olduğuna dair genel bir onay değildir.

| No | Durum | Yapılan değişiklik ve kalan iş |
|---|---|---|
| 1 | Uygulandı | Yeni şifreli nesil kutuları hazırlanıp flush edilir; katalog kaydı en son değiştirilir. Ara aşama hataları ve yeniden açılış testleri var. |
| 2 | Uygulandı | Şifreleme hatasında düz metin depolamaya sessiz dönüş kaldırıldı; açılış kurtarma ekranına gider. |
| 3 | Uygulandı | Yanlış anahtarda otomatik silme, budama ve boş veritabanına dönüş kaldırıldı. Özgün baytları koruma testi var. |
| 4 | Uygulandı | Geri yükleme aynı nesil değiştirme işlemini kullanır; normal yazmalar da aynı kuyruğa alınır. Başarısızlık ve eşzamanlı yazma testleri var. |
| 5 | Uygulandı | Döngü, saat, dakika, su, sıcaklık, kilo, belirti şiddeti ve hap planı sınırları değiştirme öncesi doğrulanır. |
| 6 | Kısmi | Çift kimlik/tarih ve çakışan regl aralıkları reddedilir; mevcut onayda toplam kayıt sayısı gösterilir. Alan bazında ayrıntılı hata/atlanacak kayıt önizlemesi henüz yok; sessiz birleştirme yapılmaz. |
| 7 | Uygulandı | Bildirim eylemleri kilit, kurulum, yaşam döngüsü ve gizli mod kapısından geçer; kilit açılana kadar bekler. |
| 8 | Uygulandı | Yalnız uygulamaya ait bilinen adlardaki iki günden eski geçici çıktılar temizlenir; yeni/ilgisiz dosyaları koruyan test var. |
| 9 | Cihaz doğrulaması gerekli | iOS arka plan önizlemesi için yerel örtü eklendi. Swift derlemesi ve fiziksel iPhone uygulama değiştirici videosu bu ortamda doğrulanmadı. |
| 10 | Uygulandı | PBKDF2 tur üst sınırı, tuz/hash uzunluğu ve biçim kontrolleri eklendi; pahalı bozuk kayıt testi var. |
| 11 | Sunucu kurulumu gerekli | Play Developer API ve Apple imzalı işlem doğrulaması kullanan servis ve istemci hazır. HTTPS dağıtımı, mağaza yetkileri ve sandbox testleri yapılmadı. Yeni satın alma doğrulamasız açılmaz/onaylanmaz. |
| 12 | Kısmi | 35 gün varsayımı kaldırıldı; gerçek son tarih ve ürün bazında ayrı hak önbelleği var. Ömür boyu hakkın başka abonelikle kapanmaması test edildi. Eski ödenmiş yerel haklar geçişte korunur; iptal/iade ancak sunucuya yeniden ulaşıldığında öğrenilir. |
| 13 | Uygulandı | Başlatılıyor/bekliyor/doğrulanıyor/başarılı/iptal/hata durumları paywall'a taşınır; eşzamanlı satın alma engellenir. Mağaza entegrasyon testi ayrıca gerekli. |
| 14 | Uygulandı | Reklam başlatma, yükleme ve gösterme yollarında UMP `canRequestAds` kapısı var; izin yokken önceden yüklenen reklam da bırakılır. |
| 15 | Uygulandı | UMP gerektiğini bildiriyorsa ayarlarda reklam gizlilik seçenekleri gösterilir. Gerçek bölgesel UMP akışı cihazda sınanmalı. |
| 16 | Uygulandı | Tarihli bildirim payload'ı doğru günü taşır. Sürekli yinelenen ilaç bildiriminde teslim günü payload'dan bilinemez; kilit sonrası kullanıcıdan gün seçmesi istenir, otomatik olarak bugüne yazılmaz. Hatırlatmalar uygulama açılmasa da sürer. |
| 17 | Uygulandı | İlaç eşleşmesi ad+doz+saat kimliği kullanır; farklı sabah/akşam dozları birlikte işaretlenmez. Belirsiz eski yalnız-ad payload'ları yazma yapmaz. |
| 18 | Uygulandı | Dil ve dakika değişimleri bildirimleri yeniden planlar; günlükler korunur. |
| 19 | Uygulandı | Cihaz dili değişimi ve uygulamaya dönüşte saat dilimi, bildirim ve widget yenilenir; planlamalar seri çalışır. Seyahat senaryosu cihaz testi bekliyor. |
| 20 | Test planı hazır | Yeniden başlatma, pil kısıtı, izin ve zorla durdurma senaryoları `cihaz-ve-magaza-dogrulama.md` içinde. Fiziksel sonuçlar henüz yok. |
| 21 | Uygulandı | Yeni regl kaydı yokken gün yeniden 1'e sarılmaz; gecikmede belirsiz tahmin gösterilir ve kesin faz koçu gizlenir. Uzun gecikme testleri güncellendi. |
| 22 | Uygulandı | Döngü aralıkları ve regl süresi ortak yıl/ay/gün takvim hesabına geçirildi; artık gün ve tarih sınırı testleri var. Platform saat dilimi geçişi cihazda ayrıca sınanmalı. |
| 23 | Uygulandı | BBT metinleri “olası/örüntüyle uyumlu” olarak değiştirildi; kesin klinik doğrulama ifadesi kaldırıldı. |
| 24 | Kısmi | Altı temel+üç yüksek ölçüm için dokuz ardışık takvim günü ve ateş/sonlu değer kontrolü var. Uyku/hastalık/ölçüm saati işaretleri için tam kalite modeli henüz yok. |
| 25 | Uzman incelemesi gerekli | Kesin hormon/performans ve tedavi eşdeğerliği ifadeleri daha temkinli metinlerle değiştirildi. Tıbbi editör onayı alınmadı. |
| 26 | Uygulandı | Kullanıcının reçetesine göre aktif/ara günleri düzenlenebilir; 24+4 ve arasız plan desteklenir. Hive/JSON eski kayıt varsayılanı 21+7 olarak korunur. |
| 27 | Uygulandı | Sağlık platformunda başarısız silme/yazma hata sayılır; günlük ledger ancak başarılı işlemden sonra ilerler. Yerel SDK davranışı cihaz doğrulaması bekliyor. |
| 28 | Uygulandı | Gerçek hafif/normal/yoğun akış eşlenir; bilgi yoksa unspecified kullanılır. Saf eşleme testi var. |
| 29 | Kısmi | Şifreli gün bazlı fingerprint ledger geçmiş ekleme, düzeltme ve bilinen silmeleri izler; tekrar denemede önce uygulamanın ilgili gün verisi değiştirilir. Eski sürümde silinmiş ve ledger'a hiç girmemiş platform kayıtları otomatik tanınamaz. HealthKit/Connect üzerinde doğrulanmalı. |
| 30 | Kısmi | En az üç döngü aralığı sonrası son altı gözlemin min–maks aralığı gösterilir. Bu klinik güven aralığı değildir; saklanmış geçmiş tahminlere dayalı kişisel hata kalibrasyonu henüz yok. |
| 31 | Uygulandı | CSV/PDF temel ölçüm birimlerini °C ve kg olarak açıkça yazar. |
| 32 | Kısmi | PDF'de 30 karakterlik sessiz kesme kaldırıldı; tam notlar Unicode kod noktalarını bölmeden ek bölümde yazılır. Emoji ve karma yazı şekillendirmesi için görsel kontrol hâlâ gerekli. |
| 33 | Uygulandı | CSV ayrı tür, başlangıç, bitiş ve süre sütunlarıyla günlük tutulmamış regl kayıtlarını da içerir; CSV ayrıştırma testi var. |
| 34 | Kısmi | İstatistik ekranından PDF seçili aralığı izler; tüm günlük seçimi desteklenir. Alan seçmeli ayrıntılı rapor önizlemesi henüz yok. |
| 35 | Kısmi | PDF sayfa sınırı genişletildi, uzun notlar bölümlenir; 3653 günlük ve uzun notlu gerçek PDF üretim testi eklendi. Az bellekli fiziksel telefonda süre/bellek ölçümü henüz yok. |
| 36 | Uygulandı | EN/ES/FR/DE/PT/AR/HI/ZH ile TR/RU korunur; toplam 10 dil. Yeni özellik metinleri de kaynaklara eklendi. |
| 37 | Uygulandı | Desteklenmeyen cihaz dili arayüz, servisler ve açılış kurtarma ekranında ortak İngilizce geri dönüşünü kullanır. |
| 38 | Kısmi | Gömülü Noto fontları, RTL ve dört dilde PDF üretim testleri var. Hindi birleşik harfleri, emoji ve karma RTL PDF görsel onayı tamamlanmadı. |
| 39 | Editör gerekli | Otomatik çeviriler ve bağlama göre düzeltmeler mevcut. Ana dil editörleri tarafından onaylanmış terim sözlüğü/ekran incelemesi henüz yok. |
| 40 | Kısmi | Altı sayaç ICU çoğul/yerel sayı biçimine geçirildi; Arapça çoğul kategorileri eklendi. Politika 10 dilde mevcut; sekiz yeni politika çevirisi otomatik ve uzman incelemesi beklediği açıkça yazıyor. Tüm elle birleştirilmiş sayaçlar bitirilmiş değil. |
| 41 | Kısmi | Açılış hatası beyaz ekran yerine dosyaları koruyan açıklama ve tekrar deneme gösterir. Açılamayan veritabanını bu ekrandan harici yedekle değiştirme sihirbazı henüz yok. |
| 42 | Uygulandı | Kısmi günlük güncellemeleri gün başına seri çalışır ve nesnenin kopyasını yazar; su/not/ilaç eşzamanlı güncelleme testi var. |
| 43 | Kısmi | On yıllık sentetik geçmiş hesaplama ve çıktı testleri eklendi. Düşük donanımlı telefonda açılış/çizim profili alınmadı; ölçülmemiş bir hız artışı iddia edilmiyor. |
| 44 | Uygulandı | Her PR için yerelleştirme üretimi, analiz, Flutter testleri ve ödeme servisi testleri çalıştıran ayrı salt okunur kalite iş akışı var. Uzak CI sonucu ayrıca kontrol edilmeli. |
| 45 | Uygulandı | Analiz uyarılarını yutan APK bayrakları kaldırıldı; kalite kapısı temiz analiz ister. |
| 46 | Uygulandı | Gerçek minimum Dart/Flutter gereksinimi ve `.fvmrc` Flutter 3.44.8 sabitlemesi eklendi. |
| 47 | Sandbox gerekli | Servis için aktif/grace/bekleyen/iptal/iade/son tarih mantık testleri var. Play lisans testçisi ve StoreKit sandbox yaşam döngüsü testleri yapılmadı. |
| 48 | Kısmi | Ring semantiği tahmin/gecikme/gün bilgisini renkten bağımsız verir. TalkBack/VoiceOver ile tam takip görevi fiziksel olarak doğrulanmadı; test adımları belgelendi. |
| 49 | Kısmi | AR/DE/HI/ZH, 320 px, %200 yazı ve klavye matrisinde ayarlar/onboarding testleri geçer; gerçek onboarding taşması düzeltildi. Tüm kurulum formları ve tahmin kartlarının kombinasyonları henüz aynı matriste değil. |
| 50 | Kısmi | Varsayılan kapalı açık tercih ve sağlık payload'ı kabul etmeyen yerel toplu olay sayaçları var; tercih kapatılınca silinir. Cihazlar arası dönüşüm analitiği sunucusu ve fiyat/teklif deneyi henüz yok; hiçbir analitik gönderilmez. |

## Yayın öncesi somut engeller

- `server/billing/README.md` adımlarına göre doğrulama servisi HTTPS üzerinde kurulmalı, mağaza yetkileri verilmeli ve `PURCHASE_VERIFY_URL` tanımlanmalı. Bunlar olmadan yeni ödeme akışı açılmaz. Bu dal doğrudan üretime dağıtılmamalı.
- Android/iOS derlemesi, mağaza sandbox, Health Connect/HealthKit ve fiziksel bildirim/erişilebilirlik testlerinin sonuçları kaydedilmeli.
- Sağlık ve yasal metinler ile otomatik çeviriler ilgili uzmanlarca gözden geçirilmeli. Buradaki kod çalışması uzman onayı yerine geçmez.

İlk rapor tarihsel bulguları korur; güncel uygulama durumu bu tablodur. Tamamlanmamış alt özellikler tamamlanmış gibi işaretlenmemiştir.

## Otomatik doğrulama

- Flutter 3.44.8: 315 test başarılı. Bunlar dosya koruma, atomik geri yükleme, eşzamanlı kayıt, ürün bazlı hak önbelleği, 10 dil kapsamı, dar ekran matrisi ve CSV/PDF üretimini içerir.
- 3653 günlük ve 18.000 karakterlik not içeren tam PDF üretimi başarılı. Bu masaüstü testidir; telefon belleği veya tipografik görsel onay değildir.
- Ödeme doğrulama servisinin dokuz mağaza durum mantığı testi başarılı. Gerçek mağaza API'sine bağlı sandbox satın alma testi değildir.
- Yerelleştirme kaynakları yeniden üretildi; `flutter analyze --no-pub` temiz (No issues found); `git diff --check` temiz. Uzak CI sonucu bu yerel sonuçlardan ayrıdır.
