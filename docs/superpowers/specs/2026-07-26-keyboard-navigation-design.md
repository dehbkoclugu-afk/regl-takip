# Klavye Gezinmesi Tasarımı

## Amaç

Tasarım önerisi 82'yi tamamlamak: tablet veya masaüstüne fiziksel klavye
bağlayan kullanıcı, dokunmaya ihtiyaç duymadan temel uygulama akışlarını
tamamlayabilmeli. Tab sırası görünen okuma sırasını izlemeli, odak her temada
belirgin olmalı ve açılan katmanlar klavyeyle yönetilebilmelidir.

## Başarı ölçütleri

- `Tab` ileri, `Shift+Tab` geri yönde yalnız etkin ve görünür kontrollere
  gider.
- Odak sırası mobilde yukarıdan aşağıya; geniş iki kolonlu yüzeylerde görsel
  okuma sırasına uygundur.
- Buton, kart ve seçimler `Enter` veya `Space` ile dokunmayla aynı eylemi
  gerçekleştirir.
- `Escape` açık sheet veya diyaloğu kapatır; alt sayfada bir önceki rotaya
  döner. Uygulamanın kök rotasında etkisizdir.
- Kapatılan katmandan sonra odak, katmanı açan kontrole döner.
- Kaydırılabilir bir ekranda odaklanan kontrol görünür alana taşınır.
- Açık ve koyu temada odak, zeminden yeterli kontrastla ayrılan belirgin bir
  Material odak katmanı; özel kartlarda ayrıca iki piksellik sınırla görünür.
- Fare ve dokunma davranışı ile mevcut mobil görsel düzen değişmez.

## Yaklaşım

Flutter'ın yerleşik odak ve eylem sistemini temel alan hedefli bir denetim
yapılacaktır. Standart `IconButton`, `TextButton`, `ElevatedButton`,
`NavigationBar`, form alanları ve `InkWell` davranışları yeniden
yazılmayacaktır. Yalnız gerçek boşluklar düzeltilecektir:

1. Karmaşık geniş düzenlerde `FocusTraversalGroup` ile kaynak ve görsel sıra
   eşleştirilir.
2. Tıklanabilir olup klavye odağı alamayan özel `GestureDetector` yüzeyleri
   Material denetimine veya `FocusableActionDetector` yapısına geçirilir.
3. Standart Material denetimlerine ortak, yüksek kontrastlı tema odak rengi
   verilir. Dekorasyonu bu katmanı örten özel kartlarda ayrıca iki piksellik
   görünür sınır kullanılır. Tek kullanımlık yeni bir odak bileşeni
   oluşturulmaz.
4. Modal katmanlarda Flutter'ın yerleşik `DismissIntent` davranışı önce
   doğrulanır; yalnız eksik kalan rota veya sheet'e `Escape` eşlemesi eklenir.

Her kontrole elle sıra numarası veya kalıcı `FocusNode` vermek
reddedilmiştir. Bu yaklaşım yerleşim değiştiğinde kolayca bozulur ve yaşam
döngüsü yükü yaratır.

## Denetim kapsamı

### Uygulama kabuğu

- Alt gezinme çubuğu
- Dashboard, takvim, kayıt ve istatistik sekmeleri arasında geçiş
- Geri dönüşte daha önce odaklanan sekmenin korunması

### Temel akışlar

- Dashboard ana eylemleri, tahmin ve günlük özet kartları
- Takvim ay gezinmesi, gün hücreleri, yıl görünümü ve gün ayrıntısı
- Günlük kayıt kategori ızgarası ve hızlı kayıt sheet'i
- Takip ekranlarının seçimleri, form alanları ve kaydet eylemleri
- Ayarlar, profil, paywall ve regl geçmişi
- PIN ekranı, standart diyaloglar, tarih seçiciler ve bottom sheet'ler

Kılık ekranındaki gizli sağlık uygulaması açma hareketi güvenlik davranışıdır;
normal Tab sırasına eklenmeyecektir. Grafiklerin veri noktaları da ayrı ayrı
odaklanabilir yapılmayacaktır; mevcut metin alternatifleri tek odak hedefi
olarak kalır.

## Odak sırası

Varsayılan sıra widget sırasıdır. Mobil görünümde kaynak sırası zaten okuma
sırasını izlemelidir. Tablet düzeninde iki kolon varsa:

- önce üst başlık ve ortak eylemler,
- sonra sol kolon yukarıdan aşağıya,
- ardından sağ kolon yukarıdan aşağıya,
- en son alt gezinme veya sayfa sonu eylemleri

izlenir. Bir ızgarada sıra satır bazında soldan sağa, sonra aşağıya gider.
Gizli, devre dışı veya erişim kapısı arkasındaki kontroller sıraya girmez.

## Etkinleştirme ve kapatma

Standart Material denetimlerinde Flutter'ın `ActivateIntent` davranışı
korunur. Özel kartlarda `Enter` ve `Space`, `onTap` ile aynı tek işlevi
çağırır; ayrı veri yazma yolu oluşturulmaz.

`Escape` yalnız en üst katmanı kapatır. Kaydedilmemiş form için mevcut geri
çıkış uyarısı varsa aynı uyarı çalışır. Zorunlu PIN veya onboarding adımı
atlatılmaz. Kapatma mümkün değilse tuş sessizce yutulmak yerine mevcut
güvenlik kuralına göre etkisiz kalır.

## Görünür odak

Odak görünümü uygulamanın pembe vurgu ailesini kullanır ancak pastel dolguya
tek başına güvenmez. Hedef:

- açık temada koyu pembe iki piksellik sınır veya eşdeğer Material katmanı,
- koyu temada açık pembe iki piksellik sınır veya eşdeğer Material katmanı,
- mevcut köşe yarıçapını izleyen şekil,
- odak kaybolduğunda normal görünümün aynen geri gelmesi.

Basılı animasyonu yalnız işaretçi davranışı olarak kalabilir; klavye odağı
hareket azaltma ayarından bağımsız, durağan biçimde görünür.

## Hata ve sınır durumları

- Ekran yeniden kurulduğunda artık var olmayan bir hedefe odak zorlanmaz.
- Bir kontrol işlem sırasında devre dışı kalırsa odak sıradaki geçerli
  hedefe geçebilir.
- Modal kapanırken `BuildContext` artık bağlı değilse ek bir geri dönüş
  isteği yapılmaz.
- Tab ile kaydırılan uzun ekranlarda odaklanan hedef görünür alana getirilir;
  kullanıcı ayrı bir kaydırma hareketine zorlanmaz.
- RTL dil eklenirse okuma yönü Flutter'ın `Directionality` davranışını
  izler; sabit sol/sağ sıra kodlanmaz.

## Test stratejisi

Widget testleri, gerçek tuş olaylarını `sendKeyEvent` veya uygun
`sendKeyDownEvent`/`sendKeyUpEvent` çağrılarıyla gönderir.

1. Uygulama kabuğunda `Tab` ve `Shift+Tab` sırası ile sekme etkinleştirme.
2. Dashboard ve takvim geniş görünümünde iki kolon/ızgara odak sırası.
3. Bir özel kartta hem `Enter` hem `Space` ile tek etkinleştirme.
4. Hızlı kayıt sheet'i veya standart bir diyalogda `Escape`, katman kapanışı
   ve odağın açan kontrole dönüşü.
5. Uzun ayarlar ekranında Tab ile aşağı ilerlerken hedefin görünür alana
   taşınması.
6. Açık ve koyu temada odak göstergesinin widget ağacında etkinleşmesi.

Testler tablet boyutu olarak 1024×768 kullanır. Aynı temel sıra 390×844
mobil boyutta en az bir duman testiyle korunur. Flutter SDK bulunmayan
ortamda test dosyaları ve statik kontroller hazırlanır; çalıştırılamayan
render doğrulaması açıkça raporlanır.

## Kapsam dışı

- Oyun kumandası, TV uzaktan kumandası ve özel donanım tuşları
- Tüm ızgaralara ok tuşlarıyla “roving focus” davranışı
- Uygulama geneli özel kısayol paleti
- Grafiklerde her veri noktasını ayrı odak hedefi yapmak
- Ekran okuyucu etiketlerini baştan tasarlamak

Bu işler #82'nin temel klavye erişimi hedefi için gerekli değildir.
