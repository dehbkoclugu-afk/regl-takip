# Büyük Yazı Ölçeği Uyarlama Uygulama Planı

1. `lib/core/utils/adaptive_layout.dart` içinde etkin metin ölçeği, büyük
   yazı eşiği, uyarlanabilir grid sütunu ve kart yüksekliği hesaplarını saf
   fonksiyonlar olarak ekle.
2. Ruh hâli, semptom ve günlük kategori gridlerini gerçek genişlik ile metin
   ölçeğine göre sütun azaltacak ve kart yüksekliğini büyütecek biçimde
   güncelle.
3. Onboarding seçim gridlerini aynı hesaplara bağla; uzun başlık ve
   açıklamalardaki birincil ellipsis'i kaldır.
4. Akış yoğunluğu/renk seçenekleri ile su, uyku ve diğer takip ekranlarındaki
   metin taşıyan sabit satırları büyük yazıda `Wrap` veya dikey düzene geçir.
5. Paywall, profil, hızlı kayıt, ayarlar, ilaç ve regl geçmişindeki sabit
   satır/sabit yükseklik risklerini tara; yalnız doğrulanabilir riskleri
   düzelt.
6. Dashboard, takvim, istatistik, uygulama kabuğu, kilit/PIN ve ortak
   diyaloglarda daha önceki korumaları denetle; yinelenen çözüm ekleme.
7. Saf düzen hesaplarını birim testiyle, öncelikli riskli bileşenleri 320 dp
   ve 2× `TextScaler` widget testleriyle kapsa.
8. Tasarım önerisi 77'yi ve changelog'u tamamlandı olarak güncelle.
9. Diff, Dart ayraçları, ARB eşliği ve sabit geometri taramalarını çalıştır;
   Flutter SDK yoksa çalıştırılamayan render/test doğrulamasını belirt.
