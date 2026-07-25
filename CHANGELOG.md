# Changelog

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
- **Şifresiz yedek uyarısı** (madde 89, kısmi): dışa aktarmadan önce dosyanın tüm döngü ve sağlık kayıtlarını okunabilir biçimde içerdiği, cihazdaki verinin şifreli ama bu dosyanın şifresiz olduğu söyleniyor. Kullanıcı onaylamadan dosya oluşmuyor. **Parolalı yedeğin kendisi yapılmadı** — kriptografi derlenemeyen ve test edilemeyen bir ortamda yazılacak son şey; ayrı bir tur istiyor
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
