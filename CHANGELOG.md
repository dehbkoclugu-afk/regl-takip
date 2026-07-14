# Changelog

## Yayınlanmamış — Sayfa denetimi (2026-07-14)

Her ekran tek tek UI/UX, kod mimarisi ve veri katmanı açısından denetleniyor.

### Kurulum (Onboarding)
- **Girilen son regl artık kayıt olarak da yazılıyor**: daha önce yalnız profile yazılıyordu; takvim, istatistik ve "reglim bitti" akışı kayıtlara baktığı için ilk kullanıcı boş bir takvimle karşılaşıyordu. Regl hâlâ sürüyorsa kayıt açık bırakılıyor, bittiyse kapatılıyor
- Son regl tarihi zorunlu hale geldi (tahmin/faz/bildirim tümü buna bağlı); seçilmeden "Devam" kapalı ve nedeni yazıyor. İsim ve doğum tarihi isteğe bağlı kaldı
- Android sistem geri hareketi formda bir adım geri alıyor (önceden kurulumdan çıkıyordu)
- Erişilebilirlik: tarih alanları gerçek buton (ripple + ekran okuyucu etiketi), slider'lar değer okuyor, adım göstergesi "Adım 3 / 5" diye anons ediliyor
- Onay penceresi yanlışlıkla kapatılamıyor ve uzun metinde kaydırılabiliyor
- İpucu/etiket renkleri token'a çekildi (kontrast), gereksiz katman kaldırıldı

### Kilit ekranı
- **PIN artık tuzlu PBKDF2 (50.000 tur) ile saklanıyor**: tuzsuz tek tur SHA-256, 4 haneli bir PIN'i hazır tablolarla anında çözülebilir yapıyordu. Eski kayıtlar ilk doğru girişte sessizce yükseltiliyor
- **Kalıcı kilitlenme düzeltildi**: cihaz yedeğinden dönüşte veriler geri gelip PIN kaydı kaybolabiliyordu; artık bu durumda kilit kendini kapatıyor
- Bekleme süresi diskten okunmadan giriş kabul edilmiyor (yeniden başlatarak bekleme atlatılamaz); PIN kaldırılınca/yenilenince yanlış deneme sayacı sıfırlanıyor
- Uygulama arka plana alınırken (recents önizlemesi dahil) kilit hemen devreye giriyor
- PIN doğrulama arka planda (isolate) çalışıyor, ekran donmuyor
- Tuş takımı ve nokta göstergesi tek ortak bileşene taşındı (iki ekranda kopya kod yoktu artık)

### Gezinme (shell + router)
- Kurulum tamamlanmadan hiçbir ekrana girilemiyor: bildirim/widget/deep link doğrudan sekmeye atlayıp boş veriyle ekran açamaz
- Bilinmeyen adres kırmızı hata ekranı yerine ana sayfaya düşüyor (eski bildirim bağlantıları)
- Sekme geçiş animasyonu 400 ms'den 250 ms'ye indi; sistem "animasyonları azalt" açıksa anında geçiyor
- Alt bar ve tablet rail'i artık tek hedef listesinden besleniyor (ikisi ayrı ayrı yazılıyordu)

### Ana sayfa (dashboard)
- İsim girilmediyse "Merhaba, !" yerine "Merhaba!" yazıyor
- **Hamilelik modu**: başlangıç tarihi girilmemişken "1. hafta" uydurmuyor; tarihi girmeye yönlendiren bir kart gösteriyor
- Faz rozeti, tahmin kartları ve "bugün nasılsın" kartı artık gerçek buton: dokunma efekti var, ekran okuyucu "Sonraki regl: 1 Tem" gibi tek parça okuyor
- Hamilelik kartındaki emoji yerine ikon (uygulamanın ikon diliyle tutarlı)

### Takvim
- **Sağlık uyarısı alt gezinme çubuğunun altında kalıyordu** — artık görünür
- Takvim günleri ekran okuyucuya durumuyla okunuyor: "14, regl günü, kayıt var"
- Tahmini regl günü gerçek regl gününden yalnız renk tonuyla ayrılıyordu (renk körlüğünde ayırt edilemez); artık çerçeveli
- Fertil gün metni kontrast token'ına çekildi

### Günlük + Hızlı Kayıt
- **Akış seçimini kaldırıp kaydedince eski değer silinmiyordu** — düzeltildi (regresyon testi eklendi)
- Boş sheet'te "Kaydet"e basmak takvimde sahte "kayıt var" noktası bırakıyordu; artık boş günlük yazılmıyor
- Ruh hali ve semptom chip'leri 33 px'ti (Material alt sınırı 48 dp): büyütüldü, dokunma efekti geldi
- Günlük ekranındaki özetler enum sırasına göre indeksleniyordu (enum'a değer eklenince yanlış etiket riski); ortak `EnumLabels` kaynağına bağlandı
- Gün şeridi ve kategori kartları gerçek buton oldu (ripple + ekran okuyucu "Akış: Orta" gibi okuyor)

### Akış, Semptom, Ruh Hali ekranları
- **Akış ekranında da seçim kaldırılınca eski değer siliniyordu** (şiddet/renk) — düzeltildi
- **Kayıtlı ruh halini silmek mümkün değildi**: seçim kaldırılınca "Kaydet" kapanıyordu; artık silme de kaydedilebiliyor
- Semptom şiddeti noktaları 14 px dokunma hedefindeydi (parmakla isabet ettirmek zor) — 28 px'e çıktı, her nokta "şiddet 3/5" diye okunuyor
- Boş kaydetmek artık takvimde sahte "kayıt var" noktası bırakmıyor (akış + semptom ekranları)
- Ruh hali etiketleri ekranın kendi kopya listesinden değil ortak kaynaktan geliyor
- Tüm seçim kartları (akış şiddeti/rengi, semptom, ruh hali) ekran okuyucuya seçili/seçilmedi bilgisini veriyor; ped sayacı butonları etiketlendi

### Sıcaklık, İlaç, Su, Uyku ekranları
- **İlaç hatırlatmaları artık her ilacın kendi saatinde geliyor** ve ilacın adını yazıyor; önceden ilaç saatleri hiç kullanılmıyor, tek bir genel bildirim atılıyordu. İlaç listesi değişince hatırlatmalar yeniden kuruluyor
- **Su takibinde hedefin üstüne çıkılamıyordu** (fazla içilen su kaydedilemiyordu) ve hedefi düşürmek o günün kaydını siliyordu — ikisi de düzeltildi
- İlaç listesinde bir kaydı silmek yanlış satırı siliyordu (liste anahtarı sıraya bağlıydı)
- İlaç ekleme sayfası her açılışta iki metin denetleyicisi sızdırıyordu
- Sıcaklık: yanlış girilen ölçüm artık silinebiliyor (BBT eğrisini ve ovülasyon teyidini bozuyordu); ölçümün nasıl yapılacağı ekranda yazıyor
- Onay kutusu / saat kartı / yıldız gibi dokunulabilir alanlar 48 dp'ye çıkarıldı ve ekran okuyucuya tanıtıldı

### Kilo, Not, Cinsel Aktivite ekranları
- **Kilo virgülle yazılınca (60,5) girdi sessizce yok sayılıyor, eski değer kaydediliyordu** — artık virgül de kabul ediliyor, geçersiz girişte uyarı çıkıyor (testlerle korundu)
- Kilo ve cinsel aktivite kayıtları silinebiliyor (girildikten sonra geri alınamıyordu)
- Not yazıp kaydetmeden geri dönünce metin sessizce siliniyordu; artık soruyor
- Not ekranı her tuş vuruşunda tüm sayfayı yeniden çiziyordu
- Boş not kaydetmek takvimde sahte "kayıt var" noktası bırakmıyor

### İstatistik
- **Devam eden regl varken "ortalama regl süresi: 0,0 gün" yazıyordu** — bitmiş kayıt yoksa profil değeri gösteriliyor (testlerle korundu)
- Filtre çipleri gerçek buton oldu (dokunma efekti + 48 dp yükseklik)
- Faz içgörüsü hesabı tip güvenli hale getirildi (`dynamic` + cast kaldırıldı)

## 1.1.0 (2026-07-13)

### Yeni
- **Hızlı Kayıt**: akış + ruh hali + semptomlar tek bottom sheet'te; dashboard ve takvimden açılır
- **Döngü haritası ring'i**: faz renkli segmentler, fertil bant, ovülasyon noktası, "buradasın" işareti
- **Akıllı tahmin**: yeterli kayıt varsa döngü uzunluğu geçmişten öğrenilir (Ayarlar'dan kapatılabilir)
- **BBT ovülasyon teyidi**: bazal vücut sıcaklığı yükselişi (3-üstü-6 kuralı) tahmini ölçüme çevirir
- **Modlar**: Hamilelik (hafta sayacı), Hap (21+7 takibi), Bebek Planı (doğurganlık skoru + LH testi kaydı)
- **Yedekleme**: JSON dışa/içe aktarma; tüm veriler artık cihazda şifreli (AES)
- **Gizli Mod**: uygulama çekmecede "Notlar" adıyla görünür (Android)
- **Ana ekran widget'ı** (Android), **Premium** (reklamsız), **Health Connect aktarımı**
- Günlük faz koçluğu kartı, istatistiklerde faz-semptom içgörüleri ve düzensizlik rozeti
- Takvimde 3 döngü ileriye tahmin; geçmiş günlere kayıt girme

### Düzeltme ve iyileştirme
- Bildirimler artık 3 döngü ileriye planlanır; döngü süresi değişince yeniden kurulur
- PIN SHA-256 ile saklanır; art arda yanlış denemede artan bekleme
- Kontrast/erişilebilirlik: WCAG AA metinler, ekran okuyucu özetleri, animasyonlar sistem ayarına saygılı
- Tasarım dili sadeleşti: opak yüzeyler (cam kaldırıldı), tutarlı köşe/gölge/tipografi ölçeği
- Gizlilik: uygulama içi politika, ilk kurulumda onay, "doğum kontrol aracı değildir" uyarısı
- Çok sayıda hata düzeltmesi (faz sarma, tarih atlamalı BBT, geri yükleme kilitlenmesi vb.)
