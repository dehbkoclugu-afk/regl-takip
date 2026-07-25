# Klavye Gezinmesi Uygulama Planı

1. Tema, uygulama kabuğu ve özel etkileşim yüzeylerindeki mevcut odak
   davranışını tarayıp standart Material davranışının yeterli olduğu yerleri
   değiştirmeden bırak.
2. Açık ve koyu temaya yüksek kontrastlı ortak odak rengi ekle; dekorasyonu
   Material odak katmanını örten özel kartlarda mevcut bileşenin içinde
   iki piksellik odak sınırı göster.
3. Normal uygulamadaki klavye odağı alamayan tıklanabilir
   `GestureDetector` yüzeylerini `InkWell` veya `FocusableActionDetector`
   ile Enter/Space destekleyecek biçimde düzelt; kılık ekranındaki gizli
   açma hareketini kapsam dışında tut.
4. Mobil ve tablet dashboard, takvim, kayıt, istatistik, ayarlar ve takip
   ekranlarında Tab sırasını tara; yalnız kaynak sırası görsel sıradan
   ayrılan karmaşık yerlerde `FocusTraversalGroup` kullan.
5. Flutter'ın yerleşik `DismissIntent` davranışını sheet, diyalog ve alt
   rotalarda doğrula; eksik kalan en üst katmana Escape eşlemesi ekle ve
   güvenlik/onboarding kapılarını atlama.
6. 1024×768 tablette Tab/Shift+Tab, Enter/Space, Escape, odak dönüşü ve
   kaydırılabilir hedef görünürlüğünü; 390×844 mobilde temel sırayı widget
   testleriyle kapsa.
7. Tasarım önerisi 82'yi ve changelog'u tamamlandı olarak güncelle.
8. Diff, Dart ayraçları, ARB eşliği ve odak API taramasını çalıştır;
   Flutter SDK yoksa çalıştırılamayan test/render doğrulamasını belirt.
