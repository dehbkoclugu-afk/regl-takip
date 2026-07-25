# Widget'tan Regl Başlatma Tasarımı

## Amaç

Tasarım önerisi 97'yi, mevcut iki Android ana ekran widget'ını salt
görüntüleme yüzeyinden güvenli bir hızlı kayıt girişine dönüştürerek
tamamlamak. Kullanıcı widget'taki `Reglim başladı` eylemine dokunduğunda
uygulama açılmalı, varsa kilit çözüldükten sonra bugünün regl başlangıç
kaydı oluşturulmalı ve altı saniyelik geri alma seçeneği gösterilmelidir.

## Kapsam

- Mevcut kompakt ve geniş Android widget boyutları
- Yerelleştirilmiş, en az 48 dp dokunma alanına sahip açık bir kayıt eylemi
- Uygulama kapalıyken ve çalışırken gelen widget tıklamaları
- PIN/biyometri, onboarding, takip modu ve kılık modu ile uyum
- Mevcut regl başlatma, profil güncelleme ve geri alma davranışının yeniden
  kullanılması

iOS Widget Extension, uygulama açılmadan arka planda veri yazma, geriye dönük
tarih seçimi ve yeni bir widget boyutu bu turun dışında kalır. Depoda iOS
widget hedefi bulunmadığı için öneri, var olan iki Android widget'ı kapsar.

## Yaklaşım

Mevcut `home_widget` bağımlılığının Android tıklama desteği kullanılacak.
Widget sağlayıcıları `HomeWidgetLaunchIntent` ile uygulamayı özel bir URI
üzerinden açacak; Flutter tarafı URI'yi soğuk veya sıcak açılıştan alıp
mevcut sağlayıcılar üzerinden kaydı oluşturacak.

Reddedilen seçenekler:

- Widget'ın tamamını kayıt düğmesi yapmak: görüntülemek için dokunmayı kayıt
  niyetiyle karıştırır ve yanlış kayıt riskini büyütür.
- Android arka plan callback'inde doğrudan Hive'a yazmak: PIN ile korunan,
  şifreli uygulama verisini ayrı bir çalışma bağlamında açmayı gerektirir;
  mevcut güvenlik ve geri alma akışını atlar.
- Yeni bir Flutter paketi veya özel platform kanalı eklemek: kurulu
  `home_widget` aynı işi zaten destekler.

## Widget arayüzü

Eylem yalnız şu koşulların tümünde görünür:

- onboarding tamamlanmış;
- kılık modu kapalı;
- takip modu regl veya gebelik deneme (TTC);
- devam eden regl kaydı yok.

Gebelik ve hap modunda, devam eden regl sırasında ya da kılık modunda eylem
gizlenir. Uygulama tıklama anında bu koşulları yeniden denetler; widget
verisinin eski kalması kayıt oluşturmaya yetmez.

Kompakt widget'ta alan darlığı nedeniyle eylem görünürken 56 dp halka
göstergesinin yerini, mevcut renk sistemini kullanan 48 dp dairesel düğme
alır. Eylem gizliyken halka korunur. Geniş widget'ta halka ve tahmin içeriği
korunur; eylem sağ kenarda ayrı bir 48 dp hedef olarak yer alır.

Düğme, kısa bir artı simgesi ile yerelleştirilmiş `Reglim başladı`
erişilebilirlik açıklamasını taşır. Renk tek başına anlam iletmez; simge ve
açıklama birlikte kullanılır. Widget'ın kalan alanına dokunmak yalnız
uygulamayı açar, kayıt oluşturmaz.

## Bileşenler

### WidgetService

Mevcut servis ek olarak:

- `period_action_visible` uygunluk değerini;
- `period_action_label` yerelleştirilmiş erişilebilirlik metnini

`HomeWidget` veri alanına yazar. Uygunluk hesabı saf bir yardımcı olarak
tutulur ve birim testine açılır. Kılık görünümü yayınlanırken değer koşulsuz
olarak `false` yazılır.

### Android widget sağlayıcıları

`CycleWidgetProvider` ve `CycleWideWidgetProvider` aynı URI'yi kullanan bir
`PendingIntent` bağlar:

`regltakip://widget/period-start`

Sağlayıcılar kayıt düğmesini kaydedilmiş uygunluk değerine göre gösterir veya
gizler. Manifest'teki ana aktiviteye `home_widget` paketinin uygulama açma
eylemi için gereken intent filtresi eklenir.

### Flutter eylem işleyicisi

Widget tıklama desteği, ayrı bir genel yönlendirme sistemi kurmadan
`WidgetService` içinde tutulur:

- `initiallyLaunchedFromHomeWidget()` soğuk açılışı alır;
- `widgetClicked` çalışan uygulamadaki tıklamaları dinler;
- yalnız bilinen URI tek bir bekleyen eylem olarak saklanır;
- yinelenen tıklama aynı kayıt akışı sürerken ikinci kez işlenmez.

`ReglTakipApp`, mevcut uygulama kısayolu ve kilit sonrası yönlendirme desenini
kullanarak bekleyen eylemi güvenli zamanda tüketir.

## Veri akışı

1. Kullanıcı widget'taki kayıt eylemine dokunur.
2. Android uygulamayı widget URI'siyle açar.
3. Flutter URI'yi tek bir bekleyen regl başlatma eylemine dönüştürür.
4. Eylem; kılık durumu çözülmeden, uygulama ön plana gelmeden, Navigator
   hazır olmadan veya PIN/biyometri kilidi açılmadan tüketilmez.
5. Uygulama onboarding, takip modu, kılık durumu ve devam eden regl kaydını
   güncel veriden yeniden denetler.
6. Koşullar uygunsa mevcut `periodRecordsProvider.startPeriod(DateTime.now())`
   akışı çağrılır ve profilin önceki `lastPeriodStart` değeri saklanarak
   bugüne güncellenir.
7. Dashboard açılır ve mevcut metinle altı saniyelik `Geri Al` bildirimi
   gösterilir.
8. Geri alma seçilirse oluşturulan kayıt silinir ve profilin önceki
   `lastPeriodStart` değeri geri yüklenir.
9. Widget verisi kayıt veya geri alma sonrasında yeniden yayınlanır.

Widget, kullanıcı tarafından başlatılan amaçlı bir giriş olduğu için bu
oturumdaki uygulama-açılış reklamı gösterilmez. Regl başlangıcı ücretsiz ana
işlev olduğundan premium kontrolü eklenmez.

## Hata ve yarış durumları

- Bilinmeyen veya bozuk URI sessizce yok sayılır.
- Kılık modu, desteklenmeyen takip modu, eksik onboarding veya devam eden
  regl nedeniyle geçersiz kalan eski tıklama veri yazmadan tüketilir.
- Kilit, Navigator veya yaşam döngüsü henüz hazır değilse eylem bekletilir.
- Aynı günün kaydı zaten varsa yeni kayıt veya yeni geri alma bildirimi
  oluşturulmaz.
- Kayıt ya da profil güncellemesi başarısız olursa eylem yeniden otomatik
  çalıştırılmaz; uygulamanın mevcut hata bildirimi kullanılır.
- Widget güncelleme hatası uygulamanın açılmasını veya oluşturulan kaydı geri
  almayı engellemez.

## Doğrulama

- Saf uygunluk yardımcısı testleri:
  - regl ve TTC modunda, onboarding tamamlanmış ve devam eden kayıt yokken
    eylem görünür;
  - gebelik, hap, kılık, eksik onboarding ve devam eden regl durumlarında
    gizlidir.
- URI/eylem karar testleri:
  - bilinen URI kabul edilir;
  - bilinmeyen URI reddedilir;
  - kilit, yaşam döngüsü ve Navigator hazır değilken eylem bekler;
  - geçersiz güncel durumda eylem kayıt yazmadan tüketilir;
  - aynı eylem yalnız bir kez yürütülür.
- Android kaynak denetimleri:
  - iki layout'ta da en az 48 dp hedef;
  - iki sağlayıcıda da görünürlük ve `PendingIntent` bağı;
  - manifest intent filtresi.
- Altı dilde erişilebilirlik etiketinin ARB ve üretilen yerelleştirme
  sınıflarında eşliği.
- Android cihaz veya emülatörde elle:
  - soğuk açılış;
  - uygulama arka plandayken tıklama;
  - PIN/biyometri sonrası otomatik kayıt;
  - altı saniyelik geri alma;
  - kılık ve takip modu geçişleri;
  - kompakt/geniş widget ve büyük yazı ölçeği.

Flutter SDK bulunmayan geliştirme ortamında Dart/Flutter testleri
çalıştırılamazsa diff, XML, manifest, ARB/JSON, yerelleştirme getter eşliği
ve yapısal Dart kontrolleri çalıştırılıp sınırlama açıkça raporlanır.
