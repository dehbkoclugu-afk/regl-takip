# Uygulama Kısayolları Uygulama Planı

1. `quick_actions` bağımlılığını ekle.
2. `lib/services/quick_action_service.dart` içinde iki eylemi, bekleyen
   eylem durumunu, dinamik yayınlama/temizlemeyi ve saf çalıştırma kararını
   tanımla.
3. `ReglTakipApp` içinde servisi dinle; onboarding, kılık, kilit, premium
   ve Navigator hazır olma koşullarından sonra eylemi çalıştır.
4. Kılık ve dil değişikliklerinde native kısayol listesini eşitle.
5. Altı ARB dosyasına kısa kısayol başlıklarını ekle ve üretilen
   yerelleştirme sınıflarını eşle.
6. Saf karar mantığını birim testiyle kapsa.
7. Tasarım önerisi 98'i ve changelog'u güncelle.
8. Diff, ARB/getter eşliği ve Dart yapısal kontrollerini çalıştır; Flutter
   SDK yoksa çalıştırılamayan testleri açıkça belirt.
