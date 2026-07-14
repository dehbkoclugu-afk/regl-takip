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
