# Widget'tan Regl Başlatma Uygulama Planı

1. `WidgetService` içine bilinen widget URI'sini, tek bekleyen eylemi,
   soğuk/sıcak açılış dinleyicisini ve saf uygunluk/çalıştırma kararlarını
   ekle.
2. Widget verisine eylem görünürlüğünü ve altı dilde erişilebilirlik
   etiketini yaz; kılık görünümünde eylemi koşulsuz gizle.
3. Kompakt ve geniş Android layout'larına en az 48 dp kayıt hedefi ekle;
   iki provider'da görünürlük, açıklama ve `HomeWidgetLaunchIntent` bağla.
4. Android manifest'e `home_widget` uygulama açma intent filtresini ekle.
5. `ReglTakipApp` içinde bekleyen eylemi kılık, onboarding, yaşam döngüsü,
   Navigator ve kilit koşullarından sonra bir kez tüket.
6. Mevcut regl başlatma/profil güncelleme davranışını ortak bir yardımcı
   üzerinden çalıştır; dashboard'da altı saniyelik geri alma göster ve
   widget açılış reklamını bastır.
7. Uygunluk, URI ve çalıştırma kararlarını küçük birim testleriyle kapsa.
8. Tasarım önerisi 97'yi ve changelog'u güncelle.
9. Diff, XML/manifest, ARB/getter eşliği ve Dart yapısal kontrollerini
   çalıştır; Flutter SDK yoksa çalıştırılamayan testleri açıkça belirt.
