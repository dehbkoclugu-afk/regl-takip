# Büyük Yazı Ölçeği Uyarlama Tasarımı

## Amaç

Tasarım önerisi 77'yi tamamlamak: uygulamanın bütün kullanıcı akışları,
telefon genişliğinde ve yüzde 200 sistem yazı ölçeğinde taşma, kırpılmış
birincil metin veya erişilemeyen eylem üretmeden çalışmalıdır.

Normal yazı ölçeğindeki mevcut tasarım ve bilgi yoğunluğu korunacak; yalnız
alan gerçekten daraldığında düzen uyarlanacaktır. Kullanıcının erişilebilirlik
tercihini etkisizleştiren global metin ölçeği sınırı uygulanmayacaktır.

## Başarı ölçütü

Asgari doğrulama matrisi:

- 320 dp ve 600 dp kullanılabilir genişlik;
- `TextScaler.linear(1)` ve `TextScaler.linear(2)`;
- desteklenen dillerden uzun etiket üreten Almanca ve Rusça;
- telefon portre görünümü ile tablet/yatay görünüm;
- boş, dolu, seçili ve hata durumları.

Bu birleşimlerde:

- sarı/siyah Flutter taşma şeridi veya layout exception oluşmaz;
- başlık, alan etiketi, seçim etiketi, açıklama ve birincil düğme metni
  üç noktayla kesilmez;
- kaydetme, geri dönme, seçim ve silme gibi eylemler görünür veya kaydırarak
  erişilebilir kalır;
- dokunma hedefleri en az 48 dp olmaya devam eder;
- görsel sıra ile ekran okuyucu/klavye sırası ayrışmaz.

Tek satırlık geçmiş kayıt özeti gibi ayrıntısı başka yerde tamamen açılabilen
ikincil metinlerde mevcut kontrollü ellipsis kullanılabilir.

## Yaklaşım

Hedefli uyarlanabilir düzen kullanılacak. Normal ölçekte mevcut satır ve
gridler korunacak; etkin metin ölçeği büyüdükçe yalnız sabit geometri kullanan
bileşenler sütun azaltacak, saracak veya dikey düzene geçecektir.

Reddedilen seçenekler:

- Bütün ekranları kalıcı olarak tek kolonlu listeye çevirmek: büyük yazıda
  güvenlidir fakat normal görünümde gereksiz boşluk ve daha uzun gezinme
  üretir.
- `MediaQuery` üzerinden metin ölçeğini sınırlamak: en küçük kod değişimi
  olsa da kullanıcının sistem erişilebilirlik tercihini bozar.
- Her ekrana bağımsız eşik ve hesap eklemek: aynı sorun için farklı
  davranışlar ve bakım yükü oluşturur.

## Ortak düzen kararı

`lib/core/utils/adaptive_layout.dart` içinde küçük, saf hesaplar tutulur:

- etkin ölçek, `TextScaler.scale(14) / 14` ile gövde metni üzerinden ölçülür;
- `1.3` ve üzeri büyük yazı düzenine geçer;
- grid sütun sayısı kullanılabilir genişlik, hedef kart genişliği ve etkin
  ölçekten hesaplanır;
- sonuç hiçbir zaman sıfır olmaz ve ekranın mevcut normal sütun sayısını
  aşmaz.

Yardımcı yalnız karar verir; renk, boşluk, widget üretimi veya ekran bilgisi
taşımaz. Ekranlar `LayoutBuilder` ile gerçek kullanılabilir genişliği verir.
Bu sınır, büyük yazıda bütün ekranı yeniden tasarlamak yerine aynı davranışı
tek yerde tutar.

## Uyarlanacak bileşen sınıfları

### Seçim gridleri

Ruh hâli, semptom, günlük kategori, onboarding seçimleri ve benzeri sabit
`crossAxisCount` kullanan gridler:

- normal ölçekte mevcut sütun sayısını korur;
- dar/büyük yazı birleşiminde sütun azaltır;
- eş yapılı seçim kartlarında yükseklik, etkin ölçekten hesaplanan
  `mainAxisExtent` ile büyür;
- değişken uzunlukta açıklama taşıyan kartlar grid yerine doğal yüksekliği
  olan `Wrap` veya tek kolonlu listeye geçer;
- birincil etikette `maxLines: 1` ve ellipsis kullanmaz.

İkon ve seçim göstergesi küçültülmez. Kart alanı metne yer açmak için büyür.

### Sabit yatay seçimler

Akış yoğunluğu ve rengi, sayaçlar, plan seçenekleri, profil segmentleri,
diyalog eylemleri ve benzeri metin taşıyan `Row` yapıları:

- yeterli alanda mevcut yatay sırayı korur;
- büyük yazıda `Wrap` ile alt satıra geçer veya anlamlı gruplar hâlinde
  `Column` olur;
- görsel ve semantik sıra kaynak listedeki sırayı izler;
- yalnız dekoratif boşluklar daralır, hedef ve metin küçülmez.

### Sabit yükseklikli alanlar

Metin içeren kart, sekme, alt eylem alanı ve tanıtım yüzeylerinde sabit
yükseklik kaldırılır veya asgari yüksekliğe çevrilir. Gövde mevcut
`SingleChildScrollView`, `ListView` ya da `CustomScrollView` üzerinden
kaydırılabilir kalır.

`TrackerScaffold` alt eylem alanı içerikle büyümeye devam eder; ekranlar
birincil düğmelere ayrı sabit yükseklik dayatmaz.

### Gezinme ve paylaşılan yüzeyler

Ana ekran, takvim ve yıl görünümünde daha önce eklenen geniş yazı/uzun metin
korumaları yeniden denetlenir fakat gereksiz yere yazılmaz. `AppShell`,
kilit/PIN, hızlı kayıt sheet'i, paywall, ayarlar, onboarding ve ortak
diyaloglar doğrulama matrisine dahildir.

Material bileşeni kendi içinde ölçeği güvenle yönetiyorsa özel bir kopya
oluşturulmaz. Gerçek taşma bulunan yerde dış margin azaltma, sarma veya dikey
düzen uygulanır; font boyutu düşürülmez.

## Ekran tarama sırası

1. Günlük işin çekirdeği: dashboard, hızlı kayıt, günlük kategori ekranı.
2. Sabit seçim yoğunluğu yüksek takipçiler: akış, ruh hâli, semptom, su,
   uyku ve cinsel aktivite.
3. Yönetim akışları: ayarlar, profil, ilaç, notlar ve regl geçmişi.
4. Giriş ve gelir yüzeyleri: onboarding, kilit/PIN ve paywall.
5. Veri yoğun yüzeyler: takvim, yıl görünümü, istatistik, sıcaklık ve kilo.
6. Uygulama kabuğu ve ortak diyaloglar.

Tarama bütün ekranları kapsar; değişiklik yalnız doğrulama matrisinde risk
taşıyan bileşene yapılır.

## Durum ve hata davranışı

- Metin uzadığında kullanıcı eylemi gizlenmez; içerik büyür veya kaydırılır.
- Seçili durum, satır sardığında da ikon/çerçeve ve semantics ile korunur.
- Klavye açıldığında alt eylem alanı mevcut `SafeArea` davranışını izler;
  odaklanan alan görünür kalmalıdır.
- Çok uzun kullanıcı girdisi kart düzenini bozmadan ikincil özet olarak
  kesilebilir; düzenleme ekranında tam değer görünür.
- Grafik çizim alanları metin büyüdüğü için sıfıra düşmez; legend sarar ve
  grafik için asgari anlamlı alan korunur.

## Doğrulama

### Saf testler

- etkin ölçek hesabının 1× ve 2× sonuçları;
- 320/600 dp genişlikte sütun hesabı;
- büyük yazıda sütunun azalması, hiçbir zaman sıfır olmaması ve normal
  sütun üst sınırını aşmaması.

### Widget testleri

Öncelikli riskli bileşenler `MediaQuery` altında 320 dp genişlik ve 2×
ölçekle pump edilir:

- ruh hâli ve semptom seçim gridleri;
- akış yoğunluğu/renk seçimleri;
- günlük kategori kartları;
- onboarding seçimi ve paywall planları;
- hızlı kayıt sheet'i ve ortak alt kaydetme alanı.

Testler framework exception toplar, birincil eylemlerin bulunduğunu ve
kaydırmayla erişilebildiğini doğrular. Aynı bileşenlerin 1× görünümü de
regresyon için çalıştırılır.

### Yapısal ve elle doğrulama

- bütün ekranlarda sabit `Row`, `GridView`, `maxLines: 1`, ellipsis ve metin
  taşıyan sabit yükseklik taraması;
- uygulamanın altı dilindeki ARB dosyalarının anahtar eşliği;
- Android emülatörde yüzde 100/yüzde 200 yazı ve telefon/tablet turu;
- TalkBack odak sırası ile kaydırma sonrası eylem erişimi.

Flutter SDK bulunmayan geliştirme ortamında widget testleri ve gerçek render
çalıştırılamazsa saf kaynak, ayraç, ARB ve değişiklik kapsamı kontrolleri
çalıştırılır; cihaz/render doğrulaması eksik olarak açıkça raporlanır.

## Kapsam dışı

- Yazı tipini, renk sistemini veya ekran bilgi mimarisini yeniden tasarlamak;
- işletim sisteminin metin ölçeğini uygulama içinde değiştirmek;
- masaüstüne özel yeni gezinme deseni;
- madde 82'nin bütün uygulama için uçtan uca klavye test turu.

Bu çalışma klavye odağını bozmayacak ve dokunduğu bileşenlerin sırasını
koruyacak; ancak tüm klavye gezinmesi ayrı madde olarak açık kalacaktır.
