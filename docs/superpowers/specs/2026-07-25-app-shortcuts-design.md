# Uygulama Kısayolları Tasarımı

## Amaç

Tasarım önerisi 98'i, uygulamanın mevcut hızlı kayıt ve ana ekran
akışlarını yeniden yazmadan tamamlamak. Kullanıcı uygulama ikonuna uzun
basarak bugünün hızlı kayıt sayfasına veya ana ekrana ulaşabilmeli.

## Kapsam

- Android App Shortcuts ve iOS Home Screen Quick Actions desteği
- Yerelleştirilmiş iki dinamik kısayol:
  - `Hızlı Kayıt`
  - `Bugünü Gör`
- PIN/biyometri, onboarding, premium erişim ve kılık modu ile uyum
- Altı desteklenen dilde kısayol adları

Widget üzerinden kayıt, özel native kısayol ikonları ve kullanıcı tarafından
özelleştirilebilir kısayol listesi bu turun dışında kalır.

## Yaklaşım

Resmî `quick_actions` Flutter paketi kullanılacak. Paket Android ve iOS için
tek Dart API'si sunuyor ve dinamik kısayolları çalışma zamanında ekleyip
silebiliyor.

Reddedilen seçenekler:

- Özel platform kanalları: aynı davranışı Kotlin ve Swift'te iki kez
  yazdırır ve bakım alanını gereksiz büyütür.
- Statik native kısayollar: daha az Dart kodu gerektirir ancak kılık modu
  açıldığında sağlıkla ilgili etiketleri anında gizleyemez.

## Bileşenler

### QuickActionService

Küçük bir servis:

- `quick_actions` eklentisini uygulama yaşam döngüsünün başında başlatır.
- Native geri çağrıyı tek bir bekleyen eylem olarak saklar.
- Kılık modu açıkken `clearShortcutItems` çağırır.
- Kılık modu kapalıyken etkin dilin iki etiketini `setShortcutItems` ile
  yayınlar.
- Bilinmeyen eylem türlerini yok sayar.

Birden çok eylem kuyruğu tutulmaz. İşletim sistemi kısayol seçimini uygulama
açılışı olarak iletir; son seçim kullanıcının güncel niyetidir.

### ReglTakipApp entegrasyonu

Uygulama mevcut bildirim aksiyonu desenini yeniden kullanır:

- Servisin bekleyen eylemi dinlenir.
- Eylem; kılık durumu çözülmeden, kilit açılmadan ve ilk kare hazır olmadan
  tüketilmez.
- Kılık modu etkinse bekleyen sağlık eylemi silinir.
- Onboarding tamamlanmamışsa yönlendirme yapılmaz; mevcut onboarding akışı
  korunur.
- Kısayolla başlatılan oturumda uygulama-açılış reklamı gösterilmez; doğrudan
  istenen işleme gidilir.

## Eylem akışları

### Hızlı Kayıt

1. Bugünün tarihi `selectedDateProvider` içine yazılır.
2. Kullanıcı günlük kayıt erişimine sahip değilse mevcut paywall açılır.
3. Erişim varsa dashboard'a gidilir.
4. İlk güvenli karede mevcut `showQuickLogSheet` açılır.

Sheet'in kayıt, tarih değiştirme, boş kayıt üretmeme ve geri bildirim
davranışı değişmez.

### Bugünü Gör

1. Bugünün tarihi `selectedDateProvider` içine yazılır.
2. Router `/dashboard` konumuna gider.
3. Başka modal açılmaz ve veri yazılmaz.

## Gizlilik

Kılık modu açıldığı anda bütün kısayollar kaldırılır. Sağlık etiketleri
yerine sahte “not” kısayolları yayınlanmaz; böyle bir kısayol gerçek not
uygulaması davranışını da eksiksiz taklit etmek zorunda kalır ve yeni bir
gizlilik yüzeyi oluşturur.

Kılık modu açıkken veya kılık durumu henüz çözümlenmemişken gelen bekleyen
eylem çalıştırılmaz. Böylece ikon etiketi değiştirilmiş olsa bile gerçek
uygulama bir kare ya da modal ile açığa çıkmaz.

## Yerelleştirme ve arayüz

Kısayol başlıkları ARB dosyalarından gelir. Dil değiştiğinde dinamik liste
yeniden yayınlanır. Başlıklar kısa tutulur; alt başlık ve özel ikon
eklenmez. Bu, uzun çevirilerde sistem menüsünün kırpılma riskini ve native
kaynak bakımını azaltır.

## Hata davranışı

Kısayol eklentisinin başlatma, yayınlama veya temizleme hatası uygulamanın
açılmasını engellemez. Hata debug günlüğüne yazılır; kullanıcı mevcut
dashboard yollarını kullanmaya devam eder.

Bekleyen eylem yalnız başarıyla yönlendirildiğinde veya güvenlik nedeniyle
bilinçli olarak reddedildiğinde temizlenir. Geçici olarak hazır olmayan
Navigator için eylem sonraki güvenli kareye kalır.

## Doğrulama

- Saf karar yardımcısı için birim testleri:
  - kılık açıkken kısayol listesi boştur
  - kılık kapalıyken iki eylem vardır
  - bilinmeyen eylem reddedilir
  - onboarding tamamlanmadan eylem çalışmaz
  - kilitliyken eylem bekler
- Altı ARB dosyası ve üretilen yerelleştirme sınıflarında anahtar eşliği
- Android ve iOS'ta elle:
  - soğuk açılış
  - uygulama arka plandayken seçim
  - PIN/biyometri sonrası devam
  - premium/paywall yolu
  - kılık açma ve kapatma
  - çalışma zamanında dil değiştirme

Flutter SDK bulunmayan geliştirme ortamında Dart/Flutter testleri
çalıştırılamazsa diff, JSON, yerelleştirme getter eşliği ve yapısal kaynak
kontrolleri çalıştırılıp sınırlama açıkça raporlanır.
