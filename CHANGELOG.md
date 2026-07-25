# Changelog

## Yayınlanmamış — Tasarım incelemesini kapatma (2026-07-26)

Tasarım incelemesinin kalan 3, 7, 9 ve 71. maddeleri tamamlandı.

- Denemesi biten kullanıcı günlük takip ekranlarında geçmişini salt okunur
  görebiliyor; yazma ve silme eylemleri veriye dokunmadan plan ekranına gidiyor
- Tam ekran reklam uygulama açılışından kaldırıldı; yalnız başarılı kayıt
  sonrasında, ücretsiz katmanda ve mevcut 24 saat sınırıyla çalışıyor
- Mağazanın `premium_no_ads` ürününü döndürdüğü kurulumlarda yerelleştirilmiş
  fiyatlı ömür boyu premium planı paywall'da koşullu gösteriliyor
- Döngü bildirimlerine Temel/Dengeli/Ayrıntılı yoğunluk tercihi eklendi;
  ilaç hatırlatmaları bu ayardan bağımsız tutuldu
- Yeni bildirim tercihi Hive ve yedek JSON'unda geriye uyumlu saklanıyor;
  altı dilin arayüz metinleri eşitlendi

## Yayınlanmamış — Parolalı yedekleme (2026-07-26)

Tasarım incelemesinin veri güvenliği turu
(`docs/tasarim-onerileri.md` madde 89).

- Yeni yedekler düz JSON yerine `.rtbackup` uzantılı, AES-256-GCM ile
  şifrelenmiş ve bütünlüğü doğrulanan dosyalar olarak oluşturuluyor
- Anahtar, her dosyaya özel 16 bayt salt ve Argon2id (19 MiB, 2 tur,
  paralellik 1) ile 10–128 karakterlik kullanıcı parolasından türetiliyor
- Parola iki kez doğrulanıyor; cihazda saklanmadığı ve kurtarılamadığı
  yedek oluşturulmadan önce açıkça belirtiliyor
- Şifreleme ve çözme arka plan isolate'ında çalışıyor; engelleyici ilerleme
  durumu çift işlem başlatılmasını önlüyor
- Yanlış parola, değiştirilmiş yük ve bozuk şifreli dosya aynı güvenli
  mesajla reddediliyor; başarılı çözme ve iç JSON doğrulaması bitmeden
  mevcut kayıtlar değiştirilmiyor
- Eski düz `.json` yedekleri yalnız geri yükleme için destekleniyor ve
  onaydan önce şifresiz oldukları açıklanıyor; yeni düz JSON yedeği
  üretilmiyor
- Zarf sürümü, algoritmalar, KDF parametreleri, Base64 alan uzunlukları ve
  50 MiB dosya sınırı doğrulanıyor; kötü amaçlı KDF başlığı kabul edilmiyor

## Yayınlanmamış — Klavye gezinmesi (2026-07-26)

Tasarım incelemesinin erişilebilir giriş turu
(`docs/tasarim-onerileri.md` madde 82).

- Uygulamadaki etkileşim yüzeyleri tablet klavyesi için tarandı; standart
  Material Tab/Shift+Tab ve Enter/Space davranışı yeniden yazılmadan korundu
- Açık ve koyu temaya yüksek kontrastlı ortak odak göstergesi eklendi
- Döngü halkası görünür klavye odağı aldı; Enter ve Space güncel faz
  ayrıntısını dokunmayla aynı veri yolu üzerinden açıp kapatıyor
- Takvim günleri doğrudan odaklanabilir Material yüzeylerine dönüştürüldü;
  seçme ve uzun basma davranışları korunuyor
- Tablet yıl ızgarası sırası, özel yüzey etkinleştirmesi, Escape ile modal
  kapanışı ve odağın açan kontrole dönüşü widget testleriyle kapsandı

## Yayınlanmamış — Büyük yazı düzeni (2026-07-26)

Tasarım incelemesinin erişilebilir düzen turu
(`docs/tasarim-onerileri.md` madde 77).

- %200 sistem yazısı için 320 ve 600 dp genişliklerde tüm ekranlar tarandı;
  genel ölçek kısıtlamak yerine yalnız gerçek sabit geometri riskleri düzeltildi
- Metin taşıyan seçim ızgaraları genişlik ve yazı ölçeğine göre sütun azaltıp
  kart yüksekliğini artırıyor; ikon veya gün noktası ızgaraları değişmedi
- Ana ekran, hızlı kayıt, onboarding, ayarlar, istatistikler ve takip
  ekranlarındaki sıkışan satırlar büyük yazıda sarılıyor veya dikey akıyor
- Birincil etiketlerdeki kesmeler kaldırıldı, en az 48 dp dokunma hedefleri ve
  normal yazı ölçeğindeki mevcut görsel düzen korundu
- Ortak düzen hesapları birim testiyle; yıl görünümü 320/600 dp ve 1×/2×
  widget düzen testiyle kapsandı

## Yayınlanmamış — Widget'tan regl başlangıcı (2026-07-26)

Tasarım incelemesinin sistem entegrasyonu turu
(`docs/tasarim-onerileri.md` madde 97).

- Kompakt ve geniş Android widget'a yerelleştirilmiş “Reglim başladı”
  eylemi eklendi; hedef en az 48 dp ve ekran okuyucu açıklaması taşıyor
- Widget tıklaması soğuk/sıcak açılışta çalışıyor; PIN/biyometri,
  onboarding, kılık ve takip modu kurallarını atlamıyor
- Devam eden regl veya bugüne ait başlangıç varken yinelenen kayıt
  oluşturulmuyor
- Başarılı kayıttan sonra altı saniyelik geri alma gösteriliyor ve önceki
  profil tarihi geri yükleniyor
- Amaçlı widget açılışı uygulama-açılış reklamıyla kesilmiyor; güvenlik
  kararları saf birim testiyle kapsandı

## Yayınlanmamış — Uygulama kısayolları (2026-07-25)

Tasarım incelemesinin sistem entegrasyonu turu
(`docs/tasarim-onerileri.md` madde 98).

- Android ve iOS ikon menüsüne “Hızlı Kayıt” ile “Bugünü Gör” eklendi
- Kısayol eylemleri onboarding, PIN/biyometri ve premium kapılarını atlamıyor
- Kılık modu sağlık kısayollarını anında kaldırıyor; kapatıldığında etkin
  dilde geri getiriyor
- Kısayolla başlatılan amaçlı akış uygulama-açılış reklamıyla kesilmiyor
- Kısayol kararları saf birim testiyle kapsandı

## Yayınlanmamış — Kalıcı ilaç planı (2026-07-25)

Tasarım incelemesinin ilaç veri modeli turu
(`docs/tasarim-onerileri.md` madde 33).

- İlaç adı, doz ve hatırlatma saati günlük kayıttan ayrılıp profil içindeki
  kalıcı plana taşındı; “alındı” durumu seçili güne ait kalmaya devam ediyor
- Eski kullanıcıların en yeni ilaç listesi bir kez otomatik taşınıyor;
  `taken` sıfırlanıyor ve geçiş işareti silinen planın yeniden doğmasını
  engelliyor
- Ekleme/silme planı ve bildirimleri güncelliyor; onay kutusu yalnız seçili
  günün geçmişini yazıyor
- Bildirimden “alındı” eylemi günlük kayıt yoksa profil planından oluşturuyor
- Plandan kaldırılmış ilaçlar geçmiş günlük kayıtlarda ve JSON yedeklerinde
  korunuyor
- Plan geçişi, günlük durum birleştirmesi ve tarihsel kayıt koruması birim
  testleriyle kapsandı

## Yayınlanmamış — Hamilelik haftası bağlamı (2026-07-25)

Tasarım incelemesinin hamilelik modu turu
(`docs/tasarim-onerileri.md` madde 21).

- Hamilelik hero’sunun altına trimester grubuna göre değişen kısa gelişim
  bilgisi eklendi
- Kişiye özel tıbbi takvim varsaymak yerine, sağlık uzmanının önerdiği
  kontrol planını izlemeyi hatırlatan sakin bir satır kullanıldı
- Başlangıç tarihi yokken gelişim metni gösterilmiyor; mevcut tarih ayarlama
  yönlendirmesi korunuyor
- Kart büyük metin ve uzun çevirilerde büyüyebiliyor; ekran okuyucu gelişim
  ve kontrol hatırlatmasını tek bağlamda duyuyor
- Trimester sınır eşlemesi ortak yardımcıya taşındı ve sınır günleri birim
  testiyle kapsandı

## Yayınlanmamış — Birleşik günlük ölçümler (2026-07-25)

Tasarım incelemesinin günlük kayıt sadeleştirme turu
(`docs/tasarim-onerileri.md` madde 28).

- Su, uyku, kilo ve sıcaklık tek “Günlük Ölçümler” ekranında toplandı;
  günlük kayıt ızgarasındaki dört ayrı kart tek girişe indirildi
- Boş kilo/sıcaklık alanları ve kapalı uyku bölümü veri üretmiyor; kullanıcı
  birleşik ekrandan mevcut ölçümleri temizleyebiliyor
- kg/lb ve °C/°F tercihleri, sıcaklık saati, uyku saatleri ve kalite puanı
  aynı akışta korunuyor; dört grup tek Hive yazımıyla kaydediliyor
- Eski ayrı ölçüm rotaları bildirim ve derin bağlantı uyumluluğu için
  tutuldu; birleşik kayıt/temizleme davranışı provider testiyle kapsandı

## Yayınlanmamış — Ana ekran önceliği (2026-07-25)

Tasarım incelemesinin kişiselleştirme turu
(`docs/tasarim-onerileri.md` madde 24).

- Ayarlar > Tercihler bölümüne “Döngü önce / Bugün önce” seçimi eklendi
- “Bugün önce” seçildiğinde günlük özet ana ekranın üst bölümüne taşınıyor;
  varsayılan döngü odaklı mevcut sıra değişmiyor
- Tercih cihazda kalıcı tutuluyor ve bilinmeyen/eski değerler güvenle
  varsayılan düzene dönüyor
- Seçici uzun çevirilerde ve büyük metinde satır kırabilen chip yapısını
  kullanıyor; kalıcı değer çözümlemesi birim testiyle kapsandı

## Yayınlanmamış — Deneme bitişi geçişi (2026-07-25)

Tasarım incelemesinin erişim geçişi turu
(`docs/tasarim-onerileri.md` madde 3).

- Denemenin son üç gününde ana ekran erişim çipi uyarı tonuna geçiyor
- Deneme bittiğinde yalnız ilk ücretsiz açılışta ücretsiz kapsamı ve
  kayıtların cihazda kalacağını anlatan erişilebilir bir diyalog gösteriliyor
- Kullanıcı aynı diyalogdan ücretsiz devam edebiliyor veya planları açabiliyor
- Geçiş açıklaması kalıcı olarak tek seferle sınırlandı; ilk ücretsiz
  oturumda açılış reklamı açıklamanın önüne geçmiyor
- Diyaloğun yalnız tamamlanmış onboarding, ücretsiz erişim ve gösterilmemiş
  durum birleşiminde açılması birim testiyle kapsandı

## Yayınlanmamış — Tablet içerik düzeni (2026-07-25)

Tasarım incelemesinin tablet uyarlama turu
(`docs/tasarim-onerileri.md` madde 99; madde 82 kısmi).

- Ana ekran geniş görünümde döngü/eylem ve tahmin/içgörü kümelerini iki
  dengeli kolona ayırıyor; mobilde mevcut okuma sırası korunuyor
- Takvim geniş görünümde aylık ızgara ile faz, ay özeti, legend ve açıklama
  panelini yan yana gösteriyor
- Her iki ekran masaüstünde aşırı gerilmeyi önlemek için 1180 px ile
  sınırlandırıldı
- İki kolonlu bölgeler widget sıralı klavye odak gruplarına alındı; takvim
  legend'i uzun çevirilerde taşmak yerine satır kırıyor

## Yayınlanmamış — Takvim yıl görünümü (2026-07-25)

Tasarım incelemesinin takvim yıl görünümü turu
(`docs/tasarim-onerileri.md` madde 43; madde 82 kısmi).

- Takvim araç çubuğuna 12 aylık kuş bakışı eklendi; gerçek regl günleri dolu,
  tahmin günleri içi boş işaretle ayrılıyor
- Bir aya dokunmak aylık takvimi doğrudan seçilen aya götürüyor
- Izgara telefon ve tablet genişliklerine uyarlanıyor; ay kartları doğal
  okuma sıralı klavye odağı ve ekran okuyucu özeti taşıyor
- Yerel hafta başlangıcı, artık yıl görünümündeki mini ayları da belirliyor;
  ay ızgarası ve artık yıl sınırı birim testiyle kapsandı

## Yayınlanmamış — Geçmiş veri ve döngü karşılaştırması (2026-07-25)

Tasarım incelemesinin geçmiş veri/karşılaştırma turu
(`docs/tasarim-onerileri.md` madde 37 ve 53).

- Takvimden en fazla üç geçmiş regl aralığı tek akışta eklenebiliyor;
  çakışan paket veri yazılmadan reddediliyor ve kayıtlar birlikte geri
  alınabiliyor
- Son iki döngünün günlük toplam belirti şiddeti aynı döngü günlerine
  hizalanarak düz ve kesikli çizgilerle üst üste gösteriliyor
- Önceki döngü verisi adil karşılaştırma için mevcut döngünün ulaştığı günle
  sınırlandırılıyor
- Toplu kayıt atomik doğrulaması ve döngü günü hizalaması birim testleriyle
  kapsandı

## Yayınlanmamış — Tahmin ayrımı ve döngü işaretleri (2026-07-25)

Tasarım incelemesinin görsel döngü turu (`docs/tasarim-onerileri.md` madde
42 ve 55).

- Takvimde tahmini regl günleri açık dolgu ve kesikli daireyle gerçek
  kayıtlardan renk dışı ikinci bir kanalla ayrıldı
- Sıcaklık ve kilo trendlerine her döngünün ovülasyon çizgisi eklendi;
  mevcut döngüde BBT/LH teyidi tahmini tarihin yerini alıyor
- Grafik noktasının araç ipucu ölçümle birlikte o günün döngü fazını da
  gösteriyor; ovülasyon işareti ekran okuyucu özetine eklendi

## Yayınlanmamış — Devamlılık, yerel takvim ve ICS (2026-07-25)

Tasarım incelemesinin devamlılık/veri turu (`docs/tasarim-onerileri.md`
madde 30, 84 ve 95).

- Bugünün özetine günlük seri ve son yedi gün kayıt doluluğu eklendi; bugün
  henüz boşsa dün biten seri korunuyor
- Takvim hafta başlangıcı seçilen Material yerelleştirmesinin pazar,
  pazartesi veya cumartesi kuralını izliyor
- Regl geçmişi standart tüm-gün etkinlikleri içeren `.ics` dosyası olarak
  paylaşılabiliyor
- Seri hesabı ve iCalendar tarih/kaçış kuralları birim testleriyle kapsandı

## Yayınlanmamış — Takvim aralık kaydı ve paylaşım (2026-07-25)

Tasarım incelemesinin takvim turu (`docs/tasarim-onerileri.md` madde 44, 46
ve 47).

- Uzun-bas gün önizlemesi, ilk kullanımdan sonra kalıcı olarak kaybolan kısa
  bir ipucuyla keşfedilebilir hâle getirildi
- Başlangıç ve bitiş günü tek tarih aralığı seçicisinden kapalı regl kaydı
  olarak eklenebiliyor; çakışmalar engelleniyor ve işlem geri alınabiliyor
- Görünen ay kartı uygulama içinden PNG olarak sistem paylaşım menüsüne
  gönderilebiliyor
- Tarih normalizasyonu ve çakışma koruması provider testine eklendi

## Yayınlanmamış — İstatistik güveni ve ayrıntı (2026-07-25)

Tasarım incelemesinin istatistik turu (`docs/tasarim-onerileri.md` madde 32,
54, 56 ve 57).

- Belirti sıklığı grafiğine ilk beş belirtinin ortalama 1–5 şiddeti eklendi
- Faz içgörülerinin her belirti için en sık fazı ve yüzdesini zaten gösterdiği
  doğrulandı; tasarım belgesindeki açık durum kapatıldı
- Seçili dönemin kayıt doluluğu ile son 12 aya kadar aylık yoğunluk çubukları
  eklendi; içeriksiz günlük nesneleri hesaba katılmıyor
- Sıcaklık ve kilo grafiklerinde dokunulan nokta ilgili günlük kaydı açıyor
- Belirti özeti ve veri yoğunluğu sınırları için birim testleri eklendi

## Yayınlanmamış — Not arama ve ortak boş durumlar (2026-07-25)

Tasarım incelemesinin günlük kullanım turu (`docs/tasarim-onerileri.md`
madde 36, 96 ve 100).

- Geçmiş notlar metne ve kapsayıcı tarih aralığına göre aranabiliyor; sonuçlar
  yeniden eskiye sıralanıyor ve dokunulan gün aynı düzenleyicide açılıyor
- Ayarların en üstüne, cihaz şifrelemesini ve kullanıcı kontrollü dışa
  aktarma/Health Connect istisnalarını birlikte söyleyen kısa gizlilik özeti
  eklendi
- İstatistik genel boşluğu ve not arama sonucu ortak `EmptyState` bileşenine
  bağlandı; mevcut dönem geçmişi, ilaç ve istatistik kartlarıyla aynı görsel
  dil tamamlandı
- Not filtreleme için büyük/küçük harf, tarih sınırları ve sıralamayı kapsayan
  birim testi eklendi

## Yayınlanmamış — Gizli mod ve geri alınamaz silme (2026-07-25)

Tasarım incelemesinin güvenlik turu (`docs/tasarim-onerileri.md` madde 85,
88, 90 ve 91).

- Gizli mod Güvenlik kartının ilk sırasına taşındı; onboarding uzatılmadan
  görünürlüğü artırıldı
- Sahte Notlar ekranı ilk açılışta arayüz diline uygun iki sıradan notla
  geliyor; kullanıcı boşaltırsa örnekler yeniden oluşturulmuyor
- Android'de PIN'den bağımsız ekran görüntüsü ve son uygulamalar önizleme
  koruması eklendi; tercih değişikliği `FLAG_SECURE` durumuna anında yansıyor
- Tüm verileri silme butonu, kullanıcı yerelleştirilmiş "Sil" sözcüğünü
  yazmadan etkinleşmiyor

## Yayınlanmamış — Onboarding geri dönüş ve kurtarma (2026-07-25)

Tasarım incelemesinin onboarding turu (`docs/tasarim-onerileri.md` madde
63–66).

- İlk günlük kayıt yönlendirmesi ile görünür ve sistem geri hareketlerinin
  zaten mevcut olduğu doğrulandı; tasarım belgesi gerçek durumla eşitlendi
- Takip modu değişmeden önce modun etkisini açıklayan onay adımı eklendi;
  hamilelik modu tahmin ve regl bildirimlerinin duracağını açıkça söylüyor
- Veri sıfırlama uyarısına doğrudan JSON yedeği geri yükleme eylemi eklendi
- Onboarding içinden geri yükleme profil, dönem ve günlük provider'larını
  yeniliyor; bildirimleri ve ana ekran widget'ını yeniden kuruyor

## Yayınlanmamış — Deneme görünürlüğü ve plan karşılaştırması (2026-07-25)

Tasarım incelemesinin para/ana ekran turu (`docs/tasarim-onerileri.md` madde
8, 10 ve 15).

- Yıllık plan kartı, mağazanın güncel fiyatlarından aylık karşılığı ve gerçek
  tasarruf yüzdesini hesaplıyor; sabit veya ülkeye özgü varsayımsal fiyat yok
- Deneme çipi ilk 23 gün ana ekranda yer kaplamıyor, yalnız son 7 günde
  görünerek bitişi haber veriyor
- Her açılışta tekrarlanan tıbbi uyarılar ana ekrandan kaldırıldı; ayarlar,
  takvim ve istatistik yüzeylerinde erişilebilir olmaya devam ediyor

## Yayınlanmamış — Hızlı akış, semptom şiddeti ve birim tercihleri (2026-07-25)

Tasarım incelemesinin yeni kayıt turu (`docs/tasarim-onerileri.md` madde 25,
29, 32, 35 ve 38).

- Hafta şeridindeki geçmiş veya bugünkü güne uzun basınca doğrudan akış
  yoğunluğu seçilebiliyor
- Hızlı kayıtta seçilen semptomun şiddeti 1–5 arasında ayarlanabiliyor
- Ayarlara kg/lb ve °C/°F tercihleri eklendi; kayıt ekranları ile günlük
  özetler seçilen birimi gösteriyor
- Ölçümler içeride kg ve °C kalıyor; mevcut kayıtlar, grafikler ve sağlık
  hesapları birim değişiminden etkilenmiyor
- Birim tercihleri Hive profilinde geriye uyumlu iki alanla ve yedek JSON'unda
  korunuyor
- Kayıt izi ve kayıt sonrası sheet kapanışı kodda zaten vardı; tasarım
  belgesinin durum özeti gerçek uygulamayla eşitlendi
- Dönüşümler ve yedek gidiş-dönüşü için testler eklendi

## Yayınlanmamış — Renk körlüğü: takvim hücreleri ve pasta lejantı (2026-07-25)

Tasarım incelemesinin yirmi üçüncü grubu (`docs/tasarim-onerileri.md` madde 79, 80).

- **Madde 79'da saydığım üç yer yanlış seçilmişti**: akış yoğunluğunda damla sayısı (1–4) + etiket, ruh hâlinde emoji + etiket, semptomda ikon + etiket var. Renk hiçbirinde tek kanal değil — oralara desen eklemek gürültü olurdu
- **Renk gerçekten tek kanal olan iki yer bulundu.** Birincisi **takvim hücreleri**: desen modu açıkken ring ve şeritler dokuluyken hücrelerin kendisi düz kalıyordu, çünkü hücreler ring tonlarını değil kendi pastel paletini kullanıyor ve eşleme tablosunda yoklardı. Ovülasyon moru ile regl pembesi deuteranopiada birbirine yakın iki soluk tona düşüyordu
- **Aynı fazın takvim karşılığı ring'dekiyle aynı dokuyu alıyor**: fertil dikey, ovülasyon ters çapraz (fertilden ayrışsın diye), foliküler çapraz, luteal yatay, regl düz. İki ekranda aynı doku, aynı anlam
- İkincisi **ruh hâli pastası**: dilimi lejanttaki adına bağlayan tek şey renkti ve palet pastel — deuteranopiada sarı/turuncu/yeşil noktalar birbirine karışıyor. Lejant artık yüzdeyi de yazıyor, dilimin içindeki "%38" ile eşleşiyor
- **Desen metnin altına konuldu, üstüne değil**: şeritlerde `foregroundDecoration` doğru çünkü orada çocuk yok; hücrede gün numarası var ve yarı saydam beyaz çizgiler rakamı soldururdu. Ayrı bir katman + `StackFit.expand` (gevşek yığın deseni yalnız rakam kadar boyardı)
- **Yolda ayrı bir kontrast hatası çıktı**: takvim hücrelerinde gün numarası pastel zeminde **beyaz** yazılıyordu — regl hücresinde 2,06:1, ovülasyonda 2,66:1, seçili günde 2,06:1, tahmin hücresinde pembe metinle 2,50:1. Kod tabanının kendi kuralı zaten yazılıydı ("pastel primary beyazla 2.06:1, zemin olarak kullanılamaz"), takvimde atlanmıştı. Dördü de koyu metne çevrildi (5,10–11,27:1)
- **Madde 80 geri çekildi**: "fl_chart görselleri için metin alternatifi yok" demiştim; üç grafiğin üçü de `Semantics` + `ExcludeSemantics` çiftiyle sarılıymış ve veriyi metin olarak duyuruyormuş (çubukta "semptom: sayı", pastada "ruh hâli: %", çizgide "son / min / maks"). Benim incelememden önce eklenmiş

## Yayınlanmamış — Hareket azaltma ve ring'in ekran okuyucu etiketi (2026-07-25)

Tasarım incelemesinin yirmi ikinci grubu (`docs/tasarim-onerileri.md` madde 81, 83).

- **Madde 81'in gerekçesi yanlıştı**: "`animate()` doğrudan çağrılan yerler kalmış" demiştim; kod tabanındaki tek `.animate()` çağrısı `animateSafe`'in kendi içinde. flutter_animate tarafı eksiksizmiş
- **Asıl boşluk örtük animasyonlardaydı**: `AnimatedContainer`, `AnimatedSwitcher`, `AnimatedScale`, `AnimatedSize`, `AnimatedDefaultTextStyle` ve `TweenAnimationBuilder` sistem "animasyonları azalt" ayarını kendiliğinden dinlemiyor. 26 örtük animasyonun 19'unda hiçbir şey yoktu; 6'sında elle `motionEnabled ? ... : Duration.zero` yazılmıştı
- **Kalıp tek yere toplandı**: `context.motionDuration(...)`. Maddenin asıl sözü ("kalıp her yerde aynı olmalı") böyle yerine geldi. Süre sıfır olunca widget hedef durumuna anında geçiyor — `autoPlay: false`'un içeriği görünmez bırakma tuzağı burada yok
- **Madde 83'ün örneği de yanlıştı**: ring'in etiketi zaten "Döngü günü: 12 / 28. 16 gün sonra" diyordu, gün numarası duyuruluyordu
- **Ama etiketi okuyunca iki gerçek eksik çıktı**: faz adı hiç duyurulmuyordu (ortadaki glif ve renk göreni bilgilendiriyor, görmeyeni değil), ve **gecikmede "Bugün!" deniyordu** — görünen rozet "3 gün gecikme" yazarken ekran okuyucu yanlış bilgi veriyordu. Etiket artık gördüğünün aynısını söylüyor: faz + gün + durum
- **Faz adı için üçüncü kopya yazılmadı**: ana ekran ve istatistik ekranı aynı switch'i birebir kopyalamıştı, `EnumLabels.phase` eklenip ikisi de ona bağlandı

## Yayınlanmamış — Sessiz bildirimler (2026-07-25)

Tasarım incelemesinin yirmi birinci grubu (`docs/tasarim-onerileri.md` madde 71).

- **Tek anahtar, bütün türler** (madde 71): ayarlarda yalnız tür başına aç/kapa vardı, "bildirim istiyorum ama telefonum çalmasın" diyen kullanıcının tek seçeneği hepsini kapatmaktı. Yeni "sessiz bildirimler" anahtarı ses ve açılır baloncuğu kaldırıyor, bildirim yalnız gölgelikte duruyor
- **Gizlilik faydası da var**: kilit ekranında öne çıkmayan bildirim yandaki kişiye görünmüyor
- **Android'in kanal tuzağı**: kanalın önem derecesi kanal *oluşturulurken* sabitlenir, sonradan gönderilen `importance` yok sayılır. Aynı kanal kimliğiyle gönderilseydi anahtar hiçbir şey değiştirmezdi — sessiz sürüm kendi kanalını kullanıyor (`_quiet` sonekli kimlik, kanal adında da görünen bir işaret)
- **Tercih değişince bildirimler yeniden planlanıyor**: kanal kimliği değiştiği için kurulu bildirimler eski kanalda kalırdı
- **Yedi kopya bloğu bire indi**: her planlama metodu kendi `NotificationDetails` bloğunu kopyalıyordu; sessizlik hepsine dokunmayı gerektirdiği için tek bir `_details` yardımcısına toplandı. Sessizlik kapalıyken üretilen değerler eskisiyle birebir aynı (regl/ovülasyon/ilaç yüksek önem + ses; gecikme, faz ipucu, zincir sonu varsayılan önem + sessiz iOS)
- **Sıklık ayarı yapılmadı**: türler zaten ayrı ayrı açılıp kapanıyor ve her tür döngüde bir kez gidiyor — "sıklık" burada somut bir karşılığı olmayan bir istek. Madde kısmi olarak işaretlendi
- Profil alanı 26 (`quietNotifications`, varsayılan kapalı), Hive adaptörü elle güncellendi, üç yeni test + yedek gidiş-dönüşüne iki doğrulama. 3 yeni metin altı dile eklendi

## Yayınlanmamış — Bildirimler: zincirin sonu, verimli pencere, metin çeşitliliği (2026-07-25)

Tasarım incelemesinin yirminci grubu (`docs/tasarim-onerileri.md` madde 72, 73, 74).

- **Regl bildirimi yanlış gün söylüyordu** (madde 74'ü ararken çıktı): gövde "yarın başlayabilir" diye sabitti, oysa madde 68 ile hatırlatma penceresi ayarlanabilir olmuştu. 3 gün önceye kurulan bildirim yine "yarın" diyordu. Gövde artık pencereye göre kuruluyor: bugün / yarın / N gün sonra
- **Metin ile tarih aynı değeri kullanıyor**: pencere 0–7 gün aralığına kırpılıyordu ama gövde kırpılmamış değerle yazılsaydı tarihten farklı bir gün söylerdi — kırpma tek yerde yapılıp ikisine de veriliyor
- **Bildirim metinleri dönüyor** (madde 74): regl bildirimi zamanlama cümlesinden sonra üç ipuçlu havuzdan birini, gecikme bildirimi üç gövdeden birini alıyor. Seçim tahmini tarihin ay numarasına bakıyor; döngü indeksi kullanılsaydı her yeniden planlamada havuz başa döner ve ardışık aylar aynı cümleyi alabilirdi
- **TTC'de verimli pencere bildirimi** (madde 73): pencere ovülasyondan 5 gün önce açılıyor ve gebe kalma şansı asıl orada — TTC modunda pencerenin açıldığı güne ayrı bir bildirim kuruluyor, ovülasyon günü bildirimi de duruyor. Takip modunda kurulmuyor (gereksiz gürültü)
- **Maddenin ilk yarısı yanlıştı**: "ovülasyon bildirimi hap modunda anlamsız" deniyordu ama hap ve hamilelik modunda döngü tahmini bildirimlerinin hiçbiri zaten kurulmuyor
- **Zincirin sonu artık sessiz değil** (madde 72): hatırlatmalar üç döngü ileriye kurulabiliyor (platform sınırı), uygulama o süre açılmazsa zincir sessizce kopuyordu. Son döngünün bir döngü ardına tek bir "hatırlatmalar duraklıyor, uygulamayı aç" bildirimi kuruluyor. Düzenli kullanan onu hiç görmüyor: her açılışta zincir uzuyor, bu bildirim de ileri kayıyor
- **Gizli modda nötrlenmiyor**: "hatırlatmalar bitti, uygulamayı aç" cümlesi bir not defteri için de aynen geçerli, döngü bilgisi taşımıyor
- **Sabit tek kaynağa indi**: verimli pencerenin ovülasyondan kaç gün önce açıldığı `cycle_utils` içinde 5 olarak gömülüydü; `AppConstants.fertileWindowStartBeforeOvulation` oldu ve bildirim de onu kullanıyor
- 12 yeni metin altı dile eklendi; kullanılmaz hâle gelen `notificationPeriodBody` kaldırıldı. Üç yeni test (`cycle_utils_test.dart`)

## Yayınlanmamış — Gradyan kontrastı ve dokunma hedefleri (2026-07-24)

Tasarım incelemesinin on dokuzuncu grubu (`docs/tasarim-onerileri.md` madde 16, 78).

- **Faz gradyanının üstündeki metin okunur oldu** (madde 16): ölçüm iddiayı doğruladı ve genişletti. Açık temada ikincil metin dört fazın hepsinde 3,47–4,29:1 (en kötüsü ovülasyon), koyu temada 2,60–3,68:1
- **İki tema iki farklı ilaç istedi**: açık temada alfayı kısmak çözmüyor — pastel tint zemini yalnız biraz açtığı için alfa %5'te bile 4,43:1'de kalıyor, yani metnin kendisi koyulaşmalıydı (`textSecondary` #6E6E7A → #5A5A64). Koyu temada ise tersi: tint zemini *açtığı* için açık renkli metnin kontrastı düşüyor, orada çözüm alfayı kısmak (%35/%20 → %15/%10)
- **Sonuç**: açık temada 4,70–5,83:1, koyu temada 4,93–6,26:1 — her iki temada dört faz da AA sınırının üstünde. Düz zeminde ikincil metin 4,61:1'den 6,24:1'e çıktı, `textPrimary` ile hiyerarşi farkı korundu (12,42:1)
- **Koyu temada gradyanın kısılması** "parlak öğeler dark'ta kısılır" ilkesiyle zaten uyumlu
- **Dokunma hedefleri** (madde 78): üç yerde `VisualDensity.compact` hedefi Material'ın 48 px asgarisinin altına indiriyordu (takvim efsane kapatma, bugüne dön, tema seçici) — kaldırıldı. Bu turda eklenen "eksik olan" satırının yüksekliği de 48 px'e çıkarıldı

## Yayınlanmamış — Bugün özeti eyleme dönüştü (2026-07-24)

Tasarım incelemesinin on sekizinci grubu (`docs/tasarim-onerileri.md` madde 20).

- **Yarı dolu gün için yönlendirme** (madde 20): hiçbir şey girilmemişken yönlendirme vardı ama ruh hâli girilip semptom girilmediğinde (ya da tersi) eksik olan hiç istenmiyordu. Artık ince bir satır eksik olanı söylüyor ve doğrudan oraya götürüyor
- **Dolu kartlar dokunulabilir**: özet gösteriliyordu ama düzeltmek için günlük ekranından dolaşmak gerekiyordu. Ruh hâli ve semptom kartları kendi ekranlarını açıyor
- **Kart kabuğu bozulmadı**: dokunulabilirlik `Material` + `InkWell` sarmalıyla eklendi, kartın gölgesi ve kenarlığı olduğu gibi kaldı

### Düzeltme

- Madde 19 (koç kartı statik) tamamen geri çekildi: genel faz ipucunun üstünde kullanıcının kendi kayıtlarından çıkan içgörü zaten duruyor ("Kayıtlarına göre bu fazda en sık: X (%Y)") ve motoru istatistikle aynı. Yanlış bir eleştiriydi

## Yayınlanmamış — Hap ve TTC modları (2026-07-24)

Tasarım incelemesinin on yedinci grubu (`docs/tasarim-onerileri.md` madde 22, 23).

- **Hap modu kart oldu** (madde 22): tek bir çipti, kaçıncı gün olduğu yazıyordu ama bu modun asıl sorusu cevapsızdı. Artık ara dönemin ne zaman başlayacağını (ya da ara dönemdeyse yeni paketin ne zaman geleceğini) ve paketin 28 gününün neresinde olunduğunu söylüyor
- **Gebelik testi günü** (madde 23): TTC kullanıcısının en beklediği tarih hiçbir yerde yoktu. Ovülasyondan 12 gün sonrası — daha erken test yanlış negatif verir, implantasyon ve hCG'nin ölçülebilir düzeye çıkması zaman ister. Gün geldiyse metin "artık anlamlı olabilir"e dönüyor
- **Ovülasyon teyidi hesaba katılıyor**: sıcaklıktan teyit varsa test günü tahmin yerine ölçülen ovülasyondan sayılıyor (kart zaten teyitli tarihi kullanıyordu, artık test günü de ondan türüyor)
- **Sabitler `AppConstants`'a taşındı**: `pillActiveDays`, `pillPackDays`, `pregnancyTestAfterOvulation` — 21/28/12 çıplak sayı olarak duruyordu
- `pillIsBreak`, `pillDaysUntilBreak`, `pillDaysUntilNewPack` ve `earliestPregnancyTestDay` için 14 birim testi (dönem sınırları, ay ve yıl sınırını aşan test günü, saat bileşeni)

## Yayınlanmamış — Bildirim aksiyonları (2026-07-24)

Tasarım incelemesinin on altıncı grubu (`docs/tasarim-onerileri.md` madde 69, 34).

- **"Reglim başladı" bildirimden işaretlenebiliyor** (madde 69): hatırlatma "reglin başlayabilir" diyordu ama üzerinden hiçbir şey yapılamıyordu; kullanıcı uygulamayı açıp aynı işi elle yapıyordu. Regl ve gecikme hatırlatmalarında aksiyon butonu var
- **"Aldım" ilaç hatırlatmasında** (madde 34): hangi ilaç olduğu payload'da taşınıyor, bugünün kaydında o ad işaretleniyor
- **Aksiyonlar uygulamayı açıyor** (`showsUserInterface: true`): yazma ana isolate'te provider üzerinden yapılıyor. Arka plan isolate'inde şifreli Hive kutularına yazmak hem kırılgan hem ekrandaki durumla ayrışma riski
- **Soğuk açılış ele alındı**: uygulama kapalıyken aksiyona basıldıysa `getNotificationAppLaunchDetails` ile yakalanıyor
- **Aksiyon tek seferlik**: uygulandıktan sonra temizleniyor, yoksa her açılışta tekrar çalışırdı
- **Gizli modda aksiyon konmuyor**: buton etiketinin kendisi ("Reglim başladı") kılığı deşifre ederdi
- **Manifest'e `ActionBroadcastReceiver` eklendi**: bu receiver olmadan aksiyon butonları çalışmıyor
- Eklenti API'si 18.0.1 dokümanına karşı doğrulandı: `AndroidNotificationAction(id, title, {showsUserInterface})`, `initialize(settings, {onDidReceiveNotificationResponse})`, `NotificationResponse.actionId/payload`

### Düzeltme

- Madde 34 (ilaç alındı işaretlemesi yok) kapsamı daraltıldı: `MedicationEntry.taken` alanı da ilaç ekranındaki geçiş de zaten vardı. Eksik olan yalnız bildirimden işaretlemeydi

## Yayınlanmamış — Semptom sıralaması ve tüm zamanlar (2026-07-24)

Tasarım incelemesinin on beşinci grubu (`docs/tasarim-onerileri.md` madde 31, 52).

- **Sık girilen semptomlar önde** (madde 31): hızlı kayıt sayfasındaki liste sabit sıradaydı, kullanıcı her seferinde kendi semptomunu arıyordu. Son 90 günün kayıtlarına göre sıralanıyor
- **Seçenek kümesi daralmıyor**: yalnız sıra değişiyor. Listeyi kullanıcının geçmişine göre kısaltmak, hiç girmediği bir semptomu bulmasını imkânsız kılardı
- **Sıralama kararlı**: eşit sayıda girilen iki semptom varsayılan sırasını koruyor — liste her açılışta zıplamamalı
- **Pencere 90 gün**: daha eskisi artık geçerli olmayan bir dönemi (bırakılmış bir ilacın yan etkisi gibi) öne taşırdı
- **İstatistikte "Tümü" filtresi** (madde 52): 3/6/12 ay sabitti; 12 aydan eski kaydı olan kullanıcı kendi verisinin tamamını göremiyordu
- `SymptomRanking.reorder` için 6 birim testi (boş geçmiş, pencere dışı kayıt, eşitlik, listede olmayan semptom)

### Düzeltme

- Madde 32 (ağrı şiddeti yok) 🟡'dan 🔵'ye indirildi: "semptom var/yok olarak kaydediliyor" demiştim, doğru değil — `SymptomEntry.severity` var ve semptom ekranında beş noktalı seçici duruyor. Kalan iş şiddeti hızlı kayda ve istatistiğe taşımak

## Yayınlanmamış — Health Connect artık iki yönlü (2026-07-24)

Tasarım incelemesinin on dördüncü grubu (`docs/tasarim-onerileri.md` madde 93).

- **Health Connect'ten içe aktarma** (madde 93): entegrasyon tek yönlüydü — uygulama yazıyordu ama okumuyordu. Başka bir uygulamadan geçen kullanıcının geçmişi Health Connect'te dururken elle yeniden girmek zorunda kalıyordu. Son 12 ayın adet günleri okunup bitişik bloklara ayrılıyor
- **Okuma öneri üretir, yazma onaydan sonra**: kimsenin geçmişi sorulmadan değiştirilmemeli. Kaç dönem bulunduğu söyleniyor, kullanıcı onaylarsa yazılıyor
- **Mevcut kayıtlarla kesişen aralıklar eleniyor**: kullanıcının kendi kaydı esas, içe aktarma onu ezmiyor. Devam eden kayıt bugüne kadar kapsıyor sayılıyor
- **Yalnız tarih okunuyor**: akış şiddetinin karşılığı platformdan platforma değişiyor, tarih ise sabit
- **Manifest'e `READ_MENSTRUATION` eklendi**
- `groupConsecutiveDays` ve `overlapsExisting` için 15 birim testi (sırasız giriş, tekrarlı gün, ay sınırı, bitişik ama ayrı dönem, devam eden kayıt)

## Yayınlanmamış — İstatistik kilidi ve doktor özeti (2026-07-24)

Tasarım incelemesinin on üçüncü grubu (`docs/tasarim-onerileri.md` madde 5, 51).

- **Kilit ekranı artık neyin kilitli olduğunu gösteriyor** (madde 5): ikon + metin + butondan ibaretti, kullanıcı neyi kaçırdığını görmüyordu. Arkada kendi verisi bulanık olarak duruyor — uydurma bir örnek değil, gerçeğin bulanıklaştırılmışı. Üstünde kilit kartı, altında okunmaz ama tanınabilir grafikler
- **Bulanık katman etkileşime kapalı**: `IgnorePointer` + kaydırma kapalı; arkadaki içerik gezilecek bir şey değil, gösterilecek bir şey
- **Doktor özeti istatistiğin başında** (madde 51): PDF raporu uygulamanın en somut faydası ama ayarların derinliğinde duruyordu. İstatistik ekranının en üstüne alındı; ayarlardaki giriş de duruyor
- **`dart:ui` importu düzeltildi**: `show TextDirection` kısıtlıydı, `ImageFilter` eklenmeden bulanıklık çözülmezdi

## Yayınlanmamış — Takvim (2026-07-24)

Tasarım incelemesinin on ikinci grubu (`docs/tasarim-onerileri.md` madde 40, 41, 45).

- **Efsane kapatılabilir** (madde 40): renk anlamları her açılışta yer kaplıyordu. İlk birkaç kullanımdan sonra kullanıcı renkleri biliyor; kapatılabiliyor, tercih kalıcı ve tek dokunuşla geri açılıyor
- **Ay özeti** (madde 41): önceki aya gidince "bu ayda ne oldu" sorusu cevapsız kalıyordu. Takvimin altında görünen ayın regl günü ve kayıtlı gün sayısı yazıyor; hiç kayıt yoksa bunu söylüyor
- **Bugüne dön** (madde 45): birkaç ay geriye kaydıran kullanıcı bugüne elle dönmek zorundaydı. Görünen ay bu ay değilken özet satırının yanında kısayol çıkıyor

### Düzeltme

- Madde 42 (tahmin/gerçek ayrımı) 🟡'dan 🔵'ye indirildi: "aynı doluluğa sahip" demiştim, doğru değil — tahmin günlerinin hem daha açık dolgusu hem 1,5 px çerçevesi var ve kodda gerekçesi yazılı. Kalan iş yalnız kesikli çerçeve

## Yayınlanmamış — Hızlı kayıt (2026-07-24)

Tasarım incelemesinin on birinci grubu (`docs/tasarim-onerileri.md` madde 26, 27).

- **Hızlı kayıtta gün gezinmesi** (madde 27): sheet açıldığı güne çakılıydı. Akşam uygulamayı açıp dünü girmek tipik davranış ama kullanıcı sheet'i kapatıp takvime inmek zorundaydı. Başlıkta ileri/geri gün okları var; gelecek gün kapalı
- **Gün değiştirirken girdi kaybolmuyor**: ekrandaki hâl önce mevcut güne yazılıyor. "Dünü girdim, şimdi bugüne geçeyim" akışı veri kaybetmemeli
- **Not alanı hızlı kayda geldi** (madde 26): en sık girilen dördüncü alandı ama "tüm kayıt türleri"nin arkasında duruyordu
- **Boş kayıt koruması korundu ve genişletildi**: hiçbir şey girilmemişse ve o güne ait kayıt yoksa hiçbir şey yazılmıyor (takvimde sahte "kayıt var" noktası çıkarıyordu); artık bu durumda "Kaydedildi" bildirimi de gösterilmiyor — yazılmayan şey için onay vermek yanlış bilgi

## Yayınlanmamış — Kilit ve PIN (2026-07-24)

Tasarım incelemesinin onuncu grubu (`docs/tasarim-onerileri.md` madde 86, 87).

- **Kilit gecikmesi** (madde 86): kilit yalnız arka plana alınınca devreye giriyordu ve dönüşte her seferinde PIN istiyordu — bildirime bakıp geri gelmek, fotoğraf seçiciden dönmek, bir bağlantı açıp kapatmak hepsi yeniden PIN demekti. Bu, kilidi tamamen kapattıran türden bir sürtünme. Artık "hemen / 1 dk / 5 dk / 15 dk" seçilebiliyor
- **Kilit kararı dönüş anına taşındı**: arka plana geçişte yalnız zaman damgası alınıyor, kilitleme kararı `resumed` olayında veriliyor. Soğuk açılışta damga yok, o yüzden her zaman kilitleniyor — gecikme yalnız uygulama açık kalmışken tanınıyor
- **Varsayılan değişmedi**: "hemen" varsayılan, yani mevcut kullanıcılar için davranış aynı. Negatif ya da bozuk bir tercih de hemen kilitlemek sayılıyor — bozuk ayar güvenliği gevşetmemeli
- **Tercih profilde değil SharedPreferences'ta**: cihaza özel bir ayar, PIN ve biyometri durumu da yedeğe girmiyor (`restoreBackup` ikisini de sıfırlıyor)
- **PIN kurtarma uyarısı** (madde 87): PIN unutulursa tek çıkış tüm verinin silinmesi. Bu, PIN kurulurken söyleniyor — sonradan öğrenen kullanıcı yıllarının kaydını kaybediyor
- `shouldLock` için 8 birim testi (soğuk açılış, sınır değeri, negatif tercih)

### Düzeltme

- Madde 85 (gizli mod keşfedilmiyor) 🟠'dan 🔵'ye indirildi: ayarlardaki satırın zaten açıklayıcı alt metni var ve özellik paywall listesinde de geçiyor. "Hiç anlatılmıyor" demek doğru değildi

## Yayınlanmamış — Reklam sıklığı ve kurulum uzunluğu (2026-07-24)

Tasarım incelemesinin dokuzuncu grubu (`docs/tasarim-onerileri.md` madde 6, 58).

- **Açılış reklamı günde bir kez** (madde 6): ücretsiz katmanda uygulama her açılışta tam ekran reklam gösteriyordu. Regl takibi "gir-kaydet-çık" uygulaması; üç saniyelik işin önündeki beş saniyelik reklam uygulamayı açmayı caydırıyor — kaydedilmeyen gün, bozulan veri, işe yaramayan tahmin demek. 24 saatlik aralık ve kurulumdan sonraki ilk gün için tam sessizlik eklendi
- **Damga gösterim anında atılıyor**: yüklenip gösterilemeyen reklam günlük hakkı harcamamalı; `onAdShowedFullScreenContent` içinde yazılıyor
- **Karar saf fonksiyona ayrıldı**: `shouldShowOpenAd` premium kontrolü ve depolamadan bağımsız, bu yüzden test edilebilir
- **Kurulum altı adımdan beşe indi** (madde 58): döngü uzunluğu ve regl uzunluğu aynı biçimde iki slider'dı ve ayrı sayfalardaydı — kullanıcı aynı iş için iki kez "Devam"a basıyordu. Tek adımda birleşti, ortak slider yardımcısı iki kopya kodu da eritti. İkisi de varsayılanla geçilebiliyor ve adım altyazısı bunu söylüyor
- `shouldShowOpenAd` için 6 birim testi (bekleme süresi, aralık sınırı, yeniden kurulumda eski damganın aldatmaması)

## Yayınlanmamış — Yedekleme (2026-07-24)

Tasarım incelemesinin sekizinci grubu (`docs/tasarim-onerileri.md` madde 92, 89).

- **Yedek hatırlatması** (madde 92): yedekleme tamamen kullanıcıya bırakılmıştı, hatırlatan hiçbir şey yoktu ve telefon kaybında yılların verisi gidiyordu. Ayarlardaki veri bölümü artık son yedeğin ne zaman alındığını gösteriyor; 30 günü geçtiyse veya hiç alınmadıysa uyarı tonuna geçip sonucunu söylüyor
- **Zaman damgası paylaşım sonrası yazılıyor**: dosyayı yazmak yeterli değil, kullanıcı paylaşım sayfasını iptal etmiş olabilir. Damga `shareFile` döndükten sonra atılıyor
- **Şifresiz yedek uyarısı** (madde 89, ilk adım): dışa aktarmadan önce
  dosyanın tüm döngü ve sağlık kayıtlarını okunabilir biçimde içerdiği,
  cihazdaki verinin şifreli ama bu dosyanın şifresiz olduğu söyleniyordu.
  Bu geçici akış daha sonra yukarıdaki parolalı `.rtbackup` uygulamasıyla
  değiştirildi
- **Yedek durumu Hive'da değil SharedPreferences'ta**: "tüm verileri sil" yedek geçmişini de silmemeli
- `isStale` için 5 birim testi (hiç yedek yok, eşik değeri, eşiğin bir altı)

## Yayınlanmamış — İstatistikte dürüstlük (2026-07-24)

Tasarım incelemesinin yedinci grubu (`docs/tasarim-onerileri.md` madde 48, 49, 50).

- **Sayılara bağlam** (madde 48): "Ort. döngü 29,3 gün" tek başına iyi mi kötü mü söylemiyordu. Genel bakış kartının altında yaygın kabul edilen aralık yazıyor (döngü 21–35 gün, regl 7 güne kadar) ve bunun tanı ölçütü olmadığı belirtiliyor
- **"Düzensiz" etiketi açıklanıyor** (madde 49): tıbbi ağırlığı olan bir yargı, ölçütü söylenmeden ve ne yapılacağı belirtilmeden duruyordu. Etiket artık dokunulabilir: ölçütün ne olduğunu (en kısa ve en uzun döngü arasında 9+ gün fark), döngü uzunluğunun değişmesinin çok yaygın olduğunu ve bunun bir tanı olmadığını anlatıyor; ayrıca hangi durumlarda hekime danışılması gerektiğini söylüyor
- **Kırmızı kalktı** (madde 49 devamı): "Düzensiz" hata kırmızısıyla ve uyarı üçgeniyle gösteriliyordu — "sende bir sorun var" diye okunuyor. Uyarı tonuna ve bilgi ikonuna alındı; değişkenlik bir bulgu, hata değil
- **Az veri uyarısı** (madde 50): iki döngüden ortalama hesaplamak yanıltıcı. Üç döngü aralığından az veriyle ortalamaların kaç döngüden çıktığı ve kayıt geldikçe netleşeceği yazıyor
- **Sabitler adlandırıldı**: `typicalCycleMin/Max`, `typicalPeriodMin/Max` ve `minGapsForRegularity` `AppConstants`'a taşındı. Mevcut `minCycleLength/maxCycleLength` giriş doğrulama sınırlarıydı (18–45) ve yaygın aralıkla karıştırılabiliyordu; ikisinin farkı yorumla açıklandı

## Yayınlanmamış — Hatırlatma zamanlaması (2026-07-24)

Tasarım incelemesinin altıncı grubu (`docs/tasarim-onerileri.md` madde 67, 68).

- **Tür başına hatırlatma saati** (madde 67): tek bir saat regl, ovülasyon, gecikme, faz ipucu ve ilaç hatırlatmalarının hepsini yönetiyordu — ilacını sabah alan ama regl uyarısını akşam isteyen kullanıcı birinden vazgeçmek zorundaydı. Ayarlarda artık "döngü hatırlatma saati" ve "ilaç hatırlatma saati" ayrı. Özel saat girilmediyse ikisi de genel saate düşüyor, yani mevcut kullanıcılar için davranış değişmiyor
- **Haber verme penceresi ayarlanabilir** (madde 68): regl hatırlatması sabit olarak tahmini tarihten 1 gün önce gidiyordu. Artık aynı gün / 1 / 2 / 3 / 5 / 7 gün önce seçilebiliyor (servis tarafında 0–7 aralığına kırpılıyor)
- **Profil modeline 5 alan eklendi** (21–25): `medicationReminderHour/Minute`, `cycleReminderHour/Minute`, `periodReminderLeadDays`. Hive adaptörü elle güncellendi — bu ortamda `build_runner` çalıştırılamıyor. Eski kayıtlarda bu alanlar yok, Hive null döndürüyor ve `effective*` getter'ları genel saate düşüyor; 15–20 numaralı alanlar da aynı kalıpla eklenmişti
- **Yedek uyumu**: `toJson`/`fromJson` yeni alanları taşıyor, alanları olmayan eski yedekler varsayılanlarla okunuyor
- Etkin saat çözümü, pencere varsayılanı ve yedek gidiş-dönüşü için 8 birim testi eklendi (saat 0'ın geçerli değer olup null ile karışmaması dahil)

## Yayınlanmamış — Kurulum akışı (2026-07-24)

Tasarım incelemesinin beşinci grubu (`docs/tasarim-onerileri.md` madde 59, 60, 61, 62).

- **Bildirim izni artık gerekçesiyle isteniyor** (madde 61): sistem diyaloğu soğuk açılışta, kurulum ekranının üstünde, hiçbir bağlam olmadan çıkıyordu. Android'de bildirim izni tek atış — reddedilince sistem bir daha sormuyor, yani tüm hatırlatma altyapısı tek bir bağlamsız dokunuşa bağlıydı. İzin artık kurulum bittikten sonra, ne hatırlatılacağı ve bildirimlerin cihazdan çıkmadığı anlatılarak isteniyor. "Şimdi değil" denirse sistem diyaloğu hiç gösterilmiyor, izin ileride ayarlardan istenebilir kalıyor. Profili olan kurulumlarda davranış değişmedi
- **"Tam hatırlamıyorum" yolu** (madde 60): son regl tarihi kurulumun tek zorunlu sorusuydu ve tarihi hatırlamayan kullanıcı sıkışıp kalıyordu. Hafta cinsinden yaklaşık seçenekler eklendi ("bu hafta", "geçen hafta", "yaklaşık 2 hafta önce"…) — kullanıcı "3 Temmuz" diye değil "geçen hafta" diye hatırlıyor. Yaklaşık tarih, uydurma bir kesinlikten iyi: tahminler kayıt geldikçe kendini düzeltiyor
- **Gizlilik vaadi ilk ekranda** (madde 62): "verilerin yalnızca bu cihazda, şifreli saklanır" bu kategorideki en güçlü argümandı ve kurulumun sonundaki onay diyaloğunda gömülüydü. Artık karşılama ekranında rozet olarak duruyor
- **İsteğe bağlı alanlar işaretlendi** (madde 59): isim ve doğum tarihi kodda zaten atlanabiliyordu ama kullanıcıya söylenmiyordu

## Yayınlanmamış — Ücretsiz katman deneyimi (2026-07-24)

Tasarım incelemesinin dördüncü grubu (`docs/tasarim-onerileri.md` madde 39, 3, 4).

- **Takvimden regl işaretlenebiliyor** (madde 39): gün özeti sayfası herkese açılıyordu ama içindeki tek eylem premium kapısına çarpıyordu — ücretsiz katmanda takvim salt okunur bir kartondu. Gün bir kayda düşüyorsa "Bu kaydı düzenle", düşmüyorsa "Reglim bu gün başladı" eylemi eklendi; ikisi de premium kapısının dışında. Günlük kayıt (akış, ruh hâli, semptom) premium kapsamında kalıyor
- **Geri al artık sadık** (madde 39 devamı): `startPeriod` devam eden bir kayıt varken onu kapatıyor, gün kaydın başlangıcında/öncesindeyse mevcut kaydı geri döndürüyor. Takvimden başlatmada bu durumlar mümkün olduğu için geri al önceki durumu yakalayıp geri kuruyor — aksi hâlde kullanıcının eski kaydını silebilirdi
- **Deneme bitişi sürpriz olmuyor** (madde 3, kısmi): son 3 günde ana ekrandaki erişim çipi uyarı diline geçiyor (ton, kenarlık, ağırlık). Salt-okunur premium katmanı yapılmadı — 11 takip ekranının her birine okuma modu eklemek ayrı bir iş
- **Paywall kullanıcının emeğini gösteriyor** (madde 4): soyut özellik listesinin üstünde "{n} döngü kaydı · {n} günlük kayıt" ve verinin cihazda kalacağı sözü. Hiç veri yoksa kart çizilmiyor — boş bir "0 kayıt" kartı argümanın tersini söylerdi

## Yayınlanmamış — Gecikme durumu (2026-07-24)

Tasarım incelemesinin üçüncü grubu (`docs/tasarim-onerileri.md` madde 17, 18, 70).

- **Gecikme artık görünüyor** (madde 18): uygulamada gecikmeyi gösteren hiçbir şey yoktu — `daysUntilNextPeriod` sonucu sıfıra kırpıyor, `nextFuturePeriod` geçmişte kalan tahmini bir sonraki döngüye ileri sarıyordu. İkisi birlikte gecikmeyi tamamen görünmez kılıyordu, oysa kullanıcının uygulamaya en çok ihtiyaç duyduğu an tam orası. Yeni `CycleUtils.periodDelayDays` tahmini tarihin kaç gün geçtiğini veriyor, ana ekran başlığı "Reglin 3 gün gecikti" diyor, alt satır sakinleştirici ve eyleme dönük
- **Ring gecikmeyi ayırt ediyor** (madde 17): rozet "bugün!" derken kullanıcı üç gündür bekliyor olabiliyordu. Gecikmede rozet kendi metnini ve uyarı tonunu alıyor
- **Gecikme bildirimi** (madde 70): tahmini tarihten 3 gün sonra hatırlatma gönderiliyor (ertesi gün sormak erken, bir hafta geç). Regl kaydedildiğinde `rescheduleAll` yeniden çalıştığı için bildirim kendiliğinden iptal oluyor. Gizli modda nötr metin, hamilelik ve hap modunda hiç kurulmuyor
- **Sınır bilinçli**: gecikme döngü uzunluğuna ulaştığında 0'a dönüyor — o noktada bir sonraki tahmini tarih de geçmiş demektir ve uygulama "çok geç kaldı" ile "kullanıcı uzun süredir kayıt girmiyor"u ayırt edemez
- **Metinler tanı koymuyor**: ne ekranda ne bildirimde gebelikten söz ediliyor; sapmanın yaygın olduğu söylenip kaydı güncellemeye yönlendiriliyor
- `periodDelayDays` için 7 birim testi eklendi (sınır değerleri, döngü uzunluğuyla kayma, saat bileşeni)

## Yayınlanmamış — Ana ekran soruya cevap veriyor (2026-07-24)

Tasarım incelemesinin ikinci grubu (`docs/tasarim-onerileri.md` madde 11, 12, 13, 14).

- **Tek cümlelik cevap** (madde 13): ring döngü gününü görsel olarak anlatıyordu ama "ne zaman?" sorusuna açık bir cümleyle cevap veren hiçbir şey yoktu — tarih yalnız tahmin kartlarının içinde, kaydırmanın altındaydı. Ekranın en büyük yazısı artık cevabın kendisi: "Reglin 6 gün sonra" + altında tarih. Durumlar ayrı ayrı ele alındı: bugün, yarın, N gün sonra, regl sürerken "Reglinin 3. günü", kayıt yokken "Son regl tarihini ekle"
- **Tema düğmesi ana ekrandan kalktı** (madde 11): ayda bir kullanılan bir tercih her açılışta göz hizasındaki köşeyi tutuyordu. Ayarlardaki üçlü seçici (sistem/açık/koyu) zaten daha eksiksiz — hızlı geçiş düğmesi "sistem" tercihine dönemiyordu bile
- **Selamlama küçüldü** (madde 14): 26 punto display anıydı ama bilgi taşımıyordu; artık başlığın üstünde tek satırlık ikincil metin. Display ağırlığı cevaba geçti
- **Deneme çipi tepeden indi** (madde 12): ücretsiz/deneme durumu görünür kalıyor ama ekranın tepesinde değil, aksiyon bloğunun altında — orası cevabın yeri

## Yayınlanmamış — Kayıt doğruluğu ve kontrast (2026-07-24)

Tasarım incelemesinin ilk grubu (`docs/tasarim-onerileri.md` madde 1, 2, 75, 76, 77).

- **Regl kaydı ücretsiz katmanda da düzeltilebiliyor** (madde 1): kayıt düzenleyici istatistik ekranının içinde yaşıyordu, o ekran da ücretsiz katmanda tamamen kilitli. Ücretsiz kullanıcının tek yazma eylemi "Reglim başladı" butonuydu ve 6 saniyelik geri al penceresi kapandıktan sonra yanlış kaydı düzeltmesinin hiçbir yolu yoktu. Düzenleyici ortak bir dosyaya taşındı, ayarlardan açılan yeni "Regl geçmişi" ekranı premium kapısının dışında
- **Geriye dönük regl tarihi** (madde 2): buton her zaman `DateTime.now()` yazıyordu; regl iki gün sonra hatırlandığında yanlış tarih girmekten başka yol yoktu. Butona uzun basmak gün seçiciyi açıyor (90 gün geriye, gelecek seçilemez, bitiş başlangıçtan önce olamaz). Hareket keşfedilebilir olsun diye butonun altında ipucu duruyor, bir kez kullanılınca kalıcı olarak kapanıyor
- **Kategori renkleri metin olarak okunuyor** (madde 75): su, uyku, kilo, ilaç ve sıcaklık ekranlarında pastel kategori renkleri doğrudan metin rengiydi — beyaz zeminde 1,6:1 ile 2,3:1 arası, WCAG AA sınırı 4,5:1. `app_colors.dart` bu kuralı zaten yazmıştı ama kendi ekranları uymuyordu. Faz renklerindeki kalıba uygun `*Text` varyantları eklendi (5,4:1 – 6,5:1), `categoryText()` açık/koyu temaya göre seçiyor
- **Seçili etiketler okunur oldu** (madde 76): ruh hâli, semptom ve akış ekranlarında seçim etiketi kendi pasteline dönüyordu — en kötüsü `moodHappy` beyaz üstünde 1,26:1. Ruh hâlinde ton korunup parlaklık kısılıyor (`readable()`, en kötü durum 4,78:1), semptomda ailenin bordo ucu kullanılıyor (6,30:1), akışta ise dört ton yalnız parlaklıkla ayrıştığı için etiket okunur renge alındı — yoğunluğu damla sayısı ve çerçeve taşıyor
- **Metin ölçeklemesinde taşma koruması** (madde 77, kısmi): ana ekranda selamlama, faz çipi, erişim çipi ve aksiyon butonu etiketleri `maxLines`/`Flexible` ile korundu. Tahmin kartlarında koruma zaten vardı; kalan ekranların taraması sürüyor

## Yayınlanmamış — Bildirim ve paywall düzeltmeleri (2026-07-24)

- **Zamanlanmış bildirimler artık gerçekten düşüyor**: flutter_local_notifications 18.0.1'in kendi manifest'i hiçbir receiver bildirmiyor, bunlar uygulamanın manifest'inde olmak zorunda. `ScheduledNotificationReceiver` eksikti — alarm tetiklendiğinde broadcast'i alacak bileşen olmadığı için kurulan hiçbir hatırlatma görünmüyordu. `ScheduledNotificationBootReceiver` de eklendi: telefon yeniden başlayınca planlar geri kuruluyor (`RECEIVE_BOOT_COMPLETED` izni zaten vardı, karşılığı yoktu)
- **Bildirim saatleri düzeldi**: `tz.initializeTimeZones()` yalnız saat dilimi veritabanını yüklüyor; `setLocalLocation` çağrılmadığı için `tz.local` UTC kalıyordu ve 09:00'a kurulan hatırlatma TSİ'de 12:00'de düşüyordu. Cihazın saat dilimi `flutter_timezone` ile okunup bağlanıyor
- **Bildirimler 6 dilde**: servisin içindeki yalnız tr/en içeren metin tablosu kalktı, tüm metinler arayüzle aynı ARB kaynağından geliyor. Almanca, İspanyolca, Fransızca ve Rusça kullanıcı artık bildirimi de kendi dilinde alıyor
- **SCHEDULE_EXACT_ALARM izni kaldırıldı**: hatırlatmaların hepsi zaten `inexactAllowWhileIdle` ile kuruluyordu; kullanılmayan izin Play'de gerekçe formu istiyor
- **Paywall'da fiyatlar canlı**: ürün detayları mağazadan asenkron geldiği için ekran ürünler dönmeden açıldığında sabit tanıtım fiyatlarında (₺29/₺199) donuyor ve hiç güncellenmiyordu — kullanıcı mağaza ekranında başka rakam görebiliyordu. Fiyatlar artık yalnız mağazadan geliyor, gelene kadar kartta bekleme göstergesi var, mağaza ürün döndürmezse sebebi yazıyor
- **"Satın alımları geri yükle" sonucu söylüyor**: eskiden akış başlatılıp beklenmiyordu, geri yüklenecek bir şey yoksa ekranda hiçbir şey olmuyordu. Hem paywall'da hem ayarlarda ilerleme ve sonuç bildiriliyor
- **Deneme bitişi anında yansıyor**: `accessProvider` zamanın geçmesiyle tazelenmiyordu, 30. gün uygulama açıkken dolduğunda erişim yeniden başlatılana dek premium kalıyordu — periyodik tik ve arka plandan dönüşte tazeleniyor

## Yayınlanmamış — İllüstrasyonlar kaldırıldı (2026-07-24)

- **Ekran içi illüstrasyonlar kaldırıldı**: ana sayfadaki faz görseli, ruh hali başlığı, ayarlar profil başlığı, paywall kahraman görseli ve istatistik boş-durum görseli — hiçbiri arayüze yakışmıyordu, ekranlar kendi tipografi ve renk diline döndü
- **Art slot sistemi silindi**: `lib/core/art/` (kayıt defteri + yer tutucu widget'ı) ve `docs/asset-briefs.md` kalktı
- **16 kullanılmayan PNG silindi**: yalnız ikon ve açılış ekranını üreten `R1-logomark.png` ile `R2-splash.png` kaldı (~33 MB depo tasarrufu)
- **Görseller artık APK'ya paketlenmiyor**: `assets/art/` bundle listesinden çıktı — kalan iki dosya sadece derleme zamanında ikon/splash üretmek için okunuyor

## Yayınlanmamış — Telefon testi düzeltmeleri + 6 dil (2026-07-18)

- **Ring dokunuşu düzeltildi**: merkez dışındaki her dokunuş artık segment seçiyor (dar bant hedefini tutturmak zordu)
- **"Verimli Pencere" kartı**: uzun başlık kesilmek yerine sığacak kadar küçülüyor
- **Ana sayfa nefes düzeni**: tahmin kartlarından sonra bloklar arası eşit cömert boşluk; alt ölü boşluk kırpıldı
- **Takvim**: takvim ile faz şeridi arası açıldı; Spacer kalktı — uyarı lejantın hemen altında, sayfa küçük ekranda kaydırılabilir
- **Takip modu 2×2 kart ızgarası**: taşan chip'ler yerine ikon+etiketli mod kartları (onboarding diliyle)
- **İstatistik profesyonelleşti**: birleşik segmentli dönem seçici, bölüm başlıkları (GENEL BAKIŞ / GRAFİKLER / GEÇMİŞ VE TRENDLER), genel bakışta kahraman sayılar + küçük birimler
- **6 dil**: Türkçe, İngilizce, İspanyolca, Almanca, Fransızca, Rusça — tam çeviri (~470 anahtar/dil). Varsayılan: cihaz dili; ayarlarda "Sistem + 6 dil" açılır menüsü. Bildirim ve widget metinleri de 6 dilde. (Arapça bilinçli ertelendi: RTL ayrı düzen turu ister)
- **Tema**: varsayılan zaten sistem — üçlü seçici duruyor

## Yayınlanmamış — İkinci tasarım turu: 10 öneri (2026-07-18)

- **Aksiyonlar ringin dibinde**: "Reglim başladı / Kayıt ekle" artık ring'in hemen altında — bir numaralı iş başparmağın menzilinde, tahminler bilgi olarak aşağıda
- **Dokunulabilir ring**: segmente dokununca yay kalınlaşıyor, merkez o fazın adını + takvim tarih aralığını + süresini gösteriyor; ikinci dokunuş ya da 5 sn sonra normale dönüyor
- **7 günlük mini şerit**: ana ekranda dün/bugün/yarın bağlamı (gün, faz rengi bandı, kayıt noktası); geçmiş güne dokununca hızlı kayıt açılıyor
- **İkon durum dili**: ayarlardaki anahtar satırlarında ikon rozeti özellik kapalıyken soluklaşıyor — açık/kapalı hal switch'e bakmadan okunuyor
- **Desenli faz renkleri (erişilebilirlik)**: yeni ayar; ring, hafta şeridi ve ay şeridinde her faza renk + farklı doku (çapraz/noktalı/uzun çizgi) — renk körlüğünde turuncu ailesi artık ayırt edilebilir
- **Container transform**: günlük ekranında kategori kartı, açtığı takip ekranının kendisine büyüyerek dönüşüyor (hareket kısıtlıysa düz geçiş)
- **Hikâye cümleleri**: istatistik grafiklerinin altına veriden türetilen tek cümle ("Son 30 gün önceki döneme göre daha rahat geçti", "Bu dönemde 1,2 kg azalma var")
- **Takvimde uzun-bas önizleme**: güne uzun basınca hafif baloncukta tarih + durum çipleri, 2,5 sn sonra kendiliğinden kayboluyor — sheet açmadan hızlı tarama
- **Onboarding'de imza sahnesi**: karşılama sayfasında ring segment segment çiziliyor, damla glifi sona doğru beliriyor
- **4×2 geniş widget**: ikinci widget boyu — mini ring + sonraki regl / ovülasyon / verimli pencere tarihleri

## Yayınlanmamış — Görsel kimlik geçişi: 10 temel (2026-07-17)

- **Tek vurgu ailesi**: mor marka rengi olmaktan çıktı (yalnız ovülasyon fazı ve semptom kategorisinde yaşıyor); pembe ailesine bordo uç (primaryDeep) eklendi — gradyanlar, vurgu ikonları, ayar renkleri tek aileden
- **Yüzey merdiveni**: zemin → yüzey → yükseltilmiş yüzey tek kaynaktan; kartlardaki başıboş beyazlar ve gri form dolguları marka tonlarına bağlandı
- **Sayı tipografisi**: kahraman sayılar (ring günü, Yılım, sıcaklık, kilo, su, gebelik haftası) temadaki tabular metrik ölçeğinden — sayaç akarken genişlik zıplamıyor
- **Basılı his**: dokunulabilir kartlar basılıyken hafifçe küçülüyor (0.98) — ripple + ölçek birlikte
- **Faz glifleri**: damla/filiz/parıltı/hilal — dört özel çizim; ring merkezi, faz çipi ve koç satırı markanın kendi alfabesini konuşuyor
- **Boş durum dili**: yumuşak daire + ikon + başlık + yönlendirme kompozisyonu (istatistik ve ilaç boşlukları)
- **Kart perhizi**: koç bloğu kart kabuğundan çıktı — yalnız dokunulabilir olan kart
- **Faz-adaptif bugün**: takvimdeki "bugün" işareti güncel fazın rengini giyiyor
- **Gece sahnesi**: daha derin koyu zemin, dark'ta kısılmış ring ışıması
- **Markalı açılış**: pembe zemin + dört yaylı ring silueti (gece varyantıyla); gizli mod alias'ı nötr açılış kullanıyor — kılık ilk kareden korunuyor

## Yayınlanmamış — Yılım, tam kılık ve Premium (2026-07-17)

- **"Yılım" halkası**: istatistikte son 12 ay tek çember — gerçek regl günleri koyu, fazlar soluk tonlarda, ay etiketleri ve merkezde döngü sayısı; düzensizlik bir bakışta görünür
- **Tam kılık (decoy)**: gizli modda uygulama artık gerçekten çalışan bir "Notlar" defteri olarak açılıyor (not ekle/düzenle/sil, nötr tema); gerçek uygulamaya dönüş başlığa uzun basışla, kilit açıksa PIN sorulur; arka plana gidince kılık geri gelir, soğuk açılışta gerçek arayüz bir kare bile görünmez
- **Premium modeli**: ilk 30 gün her şey ücretsiz ve reklamsız; sonrasında aylık ₺29 veya yıllık ₺199 abonelik. Abonelik yoksa uygulama çekirdeğe döner: regl başlat/bitir, takvim, tahminler, hatırlatmalar ve yedekleme açık kalır; günlük takipler, istatistikler (Yılım dahil), kişisel içgörüler, dışa aktarma, Health Connect, gizli mod ve özel modlar Premium'da. Veri asla silinmez — abonelikte kaldığı yerden devam eder. Eski "reklamsız" alıcılarının hakkı korunur; gizli mod kapatma her zaman serbest (kimse kılıkta mahsur kalmaz)
- Paywall ekranı (mağaza fiyatlarıyla plan kartları, geri yükleme, "ücretsiz devam et") ve ana sayfada deneme sayacı / ücretsiz sürüm çipi
- 11 yeni test (125 toplam)

## Yayınlanmamış — Görsel imza ve akıllı özellikler (2026-07-17)

- **Faz haritası artık her yerde**: takvimde ayın altında ince faz şeridi (gerçek regl günleri + tahmin, "buradasın" noktasıyla); ana ekran widget'ında metnin yanında mini faz ring'i — uygulamanın imza görseli cebe taşındı (gizli modda ikisi de gizli)
- **Motion bütçesi doğru anda**: "Reglim başladı/bitti" artık dokunsal titreşimle ve ring'in yeni faza yumuşak renk geçişiyle yanıt veriyor; zemin gradyanı da faz değişiminde akıyor. Giriş animasyon korosu kısaltıldı (ana sayfa ~1,1 sn → ~0,65 sn)
- **Kişisel semptom tahmini**: faz-semptom motoru artık proaktif — ana sayfa koçu "kayıtlarına göre bu fazda en sık: X (%Y)" diyor ve luteal faz başlarken kendi geçmişinden gelen "faz ipucu" bildirimi geliyor (gizli modda kurulmaz)
- **"Son Döngün" kartı**: son döngü ve son regl, kendi ortalamanla kıyaslanıyor ("ortalamandan 2 gün uzun")
- **Kurulumun ilk sorusu mod seçimi**: Regl / Hamilelik / Hap / Bebek Planı kartları — hamile kullanıcı ilk dakikada doğru akışa giriyor (gebelikte girilen son regl tarihi hafta sayacını hemen doğru başlatıyor)
- 6 yeni birim testi (120 toplam)

## Yayınlanmamış — İnceleme düzeltmeleri: sağlamlaştırma beşlisi (2026-07-17)

- **Dışa aktarım artık gerçekten rapor**: CSV/PDF başlıkları ve değerler uygulama dilini izliyor (İngilizce'ye çakılıydı); semptomlar sayı yerine ad listesi olarak, ilaçlar da CSV'ye yazılıyor
- **İstatistik dürüstlüğü**: filtre çipleri kartın tamamına işliyor (önceden yarısına), semptom çubuklarında kalıcı sayı etiketi + tam adlar (4 harfe kırpılmıyor), trend grafiklerinde x ekseni gerçek zaman (seyrek ölçüm eğriyi çarpıtmıyor)
- **Bayrak kaybı artık veri kaybı değil**: yalnız şifreleme bayrağı kaybolduğunda (anahtar sağlamken) kutular karantinaya alınmadan önce normal şifreli açılış deneniyor — testler bu açığı yakaladı, düzeltildi
- **Tema tek üreticiden**: açık/koyu kopyası eritildi; ölü konfigürasyon (cardTheme, bottomNavigationBarTheme, kullanılmayan animasyon sabitleri) temizlendi; koyu temadaki yarı saydam yüzey kalıntıları opaklaştırıldı
- **Ortak TrackerScaffold**: 10 takip ekranının kopyala-yapıştır iskeleti tek bileşene indi; **kaydedilmemiş değişiklik koruması artık her ekranda** (önceden yalnız Notlar'da) — seçim yapıp kaydetmeden çıkan kullanıcıya soruluyor
- 5 yeni regresyon testi (114 toplam)

## Yayınlanmamış — İnceleme düzeltmeleri: yakın altılısı (2026-07-17)

- **Kilit artık geçici odak kayıplarında inmiyor**: bildirim çekmecesi, izin diyaloğu, paylaşım sayfası kilidi tetiklemiyor (yalnız arka plana geçişte); recents önizlemesi ve ekran görüntüsü FLAG_SECURE ile engelleniyor (kilit açıkken); kilit ekranı uygulamanın üstüne biniyor — yazılan not, kaydırma konumu kilitten dönüşte aynen duruyor
- **Kontrast taraması**: pastel/ring tonları metin ve buton zemini olarak temizlendi (ring merkezi, doğurganlık rozeti, takvim detay çipleri, profil kaydet butonu ve slider'lar, kurulum butonu, pasta yüzdeleri, hatırlatma saati) — açık temada AA metin tonları eklendi
- **Gizli mod bildirimleri de kapsıyor**: "Notlar" kılığındayken kilit ekranına düşen hatırlatmalar nötr metinle geliyor ("Adet Hatırlatması" yerine "Hatırlatma"); ilaç adları da gizleniyor
- **Tema artık sistemi izleyebiliyor**: Sistem/Açık/Koyu üçlü tercih (yeni kullanıcıda varsayılan sistem); mevcut kullanıcının seçimi korunuyor
- **Saatli + saatsiz ilaç karışımında** saatsiz ilaçlar için genel saat hatırlatması da kuruluyor (önceden sessizce kapsam dışıydı)
- **İngilizce gizlilik politikası** eklendi (arayüz dilini izliyor); iki politikada da üçüncü taraf bölümü gerçeğe çekildi (AdMob ve çökme raporlama şeffaf biçimde açıklandı)

## Yayınlanmamış — İnceleme düzeltmeleri: veri güvenliği dörtlüsü (2026-07-17)

Kapsamlı inceleme raporunun (docs/reviews/2026-07-16) "Hemen" öncelikli dört bulgusu:

- **Cihaz değişimi artık veri faciası değil**: sistem yedeği Hive dosyalarını yeni telefona taşıyor ama şifreleme anahtarı cihazda kalıyordu — Hive çözülemeyen kutuları sessizce boşaltıyordu. Yedekleme kapatıldı (`allowBackup=false`, taşıma yolu uygulama içi JSON yedeği); çözülemeyen kutu artık karantinaya alınıp temiz başlanıyor ve kurulum ekranında nedeni açıklanıyor (regresyon testli)
- **Düz metin sızıntısı kapatıldı**: şifreleme geçişinin güvenlik kopyası (`pre_encryption_backup.json`) tüm sağlık verisini şifresiz tutup hiç silinmiyordu; artık bir sonraki başarılı açılışta ve "tüm verileri sil"de siliniyor
- **PIN kaldırmak mevcut PIN'i soruyor** (açık unutulan telefonda tek dokunuşla koruma kalkamaz) ve PIN gidince biyometri de kapanıyor — yedeksiz biyometri kilidi kalıcı kilitlenme riskiydi
- **Regl kayıtları düzenlenebilir/silinebilir oldu**: istatistikteki döngü geçmişi satırına dokunup başlangıç/bitiş düzeltilebiliyor, kayıt silinebiliyor; profil tarihi en yeni kayıttan türetiliyor. Profilde son regl tarihini geriye çekmek kaydı kırpıp çift kayıt üretiyordu — düzeltildi (regresyon testli). "Reglim başladı/bitti"ye 6 saniyelik **Geri Al** eklendi; profil kaydetme hataları artık ekranda görünüyor

## Yayınlanmamış — Sayfa denetimi (2026-07-14)

Uygulamanın 18 ekranı + gezinme, servis ve veri katmanı tek tek UI/UX,
kod mimarisi ve backend açısından denetlendi. Öne çıkan düzeltmeler:
kurulumda girilen reglin kayda geçmemesi, akış/ruh hali silmenin çalışmaması,
ilaç saatlerinin kullanılmaması, su hedefinin veriyi kırpması, PIN'in tuzsuz
saklanması ve "tüm verileri sil"in bildirim/widget/PIN bırakması.

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

### Ayarlar + Profil
- **"Tüm verileri sil" arkasında iz bırakıyordu**: PIN kayıtlı kalıyor, bildirimler planlı kalıyor, ana ekran widget'ı döngü bilgisini göstermeye devam ediyordu — hepsi temizleniyor
- **Profilde son regl tarihini değiştirmek takvime yansımıyordu** (kayıt oluşmuyordu) — artık gerekiyorsa kayıt açılıyor/kapanıyor
- Yedekten geri yüklemede ilaç hatırlatmaları da yeniden kuruluyor
- Yedekleme/dışa aktarma hataları çeviri metniyle gösteriliyor (ham hata dizgisi yerine)
- Profil ekranındaki tarih alanı buton oldu, slider'lar değerlerini okuyor

### Kesişen katman (açılış, reklam, kart bileşeni)
- **Reklam rızası (Google UMP) eklendi**: AB/İngiltere'de kişiselleştirilmiş reklam için zorunlu; rıza akışı takılırsa uygulama kilitlenmeden devam ediyor
- Soğuk açılışta ilaç hatırlatmaları yeniden kuruluyordu ama ilaç listesi verilmiyordu — kendi saatleri kayboluyordu
- Kart bileşeni her kart için gereksiz bir kırpma katmanı oluşturuyordu (kaydırma maliyeti)
- TR/EN çeviri anahtarları birebir eşleşiyor (400/400); yinelenen `delete` anahtarı temizlendi

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
