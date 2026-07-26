# 100 kritik tasarım önerisi

> **Durum:** 1–18, 20–79 ve 81–100 uygulandı. 19 ve 80, incelemenin
> mevcut davranışı yanlış okuduğu doğrulanınca geri çekildi. Açık veya kısmi
> madde kalmadı; uygulama ayrıntıları için CHANGELOG'a bakın.

Uygulamanın mevcut hâli üzerinden yapılmış eleştirel bir okuma. Öneriler
gözlemden çıktı: her madde neyin sorun olduğunu söyler, sonra ne yapılacağını.
Dosya/satır referansları inceleme anındaki koda aittir.

Öncelik işaretleri: **🔴 kritik** (kullanıcıyı gerçekten engelliyor veya
yanlış bilgi veriyor), **🟠 yüksek**, **🟡 orta**, **🔵 iyileştirme**.

---

## A. Ücretsiz katman ve para (1–10)

**1. 🔴 Ücretsiz kullanıcının yanlış kaydı düzeltme yolu yok.** Ücretsiz
katmanda tek yazma eylemi "Reglim başladı/bitti" butonu ve düzeltme penceresi
6 saniyelik geri al. Regl kaydını düzenleyebileceğin tek ekran istatistik
geçmişi (`statistics_screen.dart:1158`), o da ücretsiz katmanda tamamen kilitli
(`statistics_screen.dart:41`). Yanlış güne basan kullanıcı kaydı bir daha
düzeltemiyor. Regl kaydı düzenleme ücretsiz katmana açılmalı — takibin
kendisi ücretsizse doğruluğu da ücretsiz olmalı.

**2. 🔴 Regl başlangıcı geriye dönük girilemiyor.** Buton her zaman
`DateTime.now()` yazıyor (`dashboard_screen.dart:371`). İki gün geç hatırlayan
kullanıcı — ki tipik senaryo bu — yanlış tarih girmek zorunda. Butona uzun
basınca tarih seçici açılmalı.

**3. 🟠 Deneme bitişi uçurum.** 30 gün her şey açık, 31. gün on takip ekranı
birden kapanıyor. Kullanıcı bir aydır girdiği veriye erişemez hale geliyor.
Bitişten 3 gün önce uyarı, bitişte de "verilerin duruyor, görüntüleme açık,
yeni kayıt premium" gibi yumuşak bir iniş daha az öfke üretir.

*Uygulandı:* ana ekrandaki erişim çipi son üç günde uyarı tonuna geçiyor.
Deneme gerçekten bittiğinde yalnız ilk ücretsiz açılışta hangi özelliklerin
açık kaldığını ve kayıtların cihazda silinmeden durduğunu anlatan bir geçiş
diyaloğu gösteriliyor. Kullanıcı ücretsiz devam edebiliyor veya planlara
gidebiliyor; açıklama tekrar çıkmıyor ve o ilk geçiş oturumunda açılış reklamı
gösterilmiyor.

*Tamamlandı:* denemesi biten kullanıcı günlük takip ekranlarını ve geçmiş
verisini artık açabiliyor. Ekranlar salt okunur; kaydetme, silme ve canlı
ilaç durumu gibi yazma eylemleri plan ekranına giderken regl başlangıcı,
bitişi ve geçmiş düzeltmesi ücretsiz kalıyor.

**4. 🟠 Deneme boyunca değer gösterilmiyor.** Paywall'a gelindiğinde
kullanıcının 30 günde ne biriktirdiği söylenmiyor. "38 kayıt, 2 döngü, 14
semptom girdisi — bunlar sende kalır" cümlesi soyut özellik listesinden
kat kat güçlü.

**5. 🟠 İstatistik kilidi boş.** Kilit ekranı ikon + metin + buton
(`statistics_screen.dart:52-78`). Kullanıcı neyi kaçırdığını görmüyor. Gerçek
grafiklerin bulanıklaştırılmış hâli arkada dursa, kilit somutlaşır.

**6. 🟡 Açılış reklamı her açılışta.** Ücretsiz katmanda uygulama her
açılışta tam ekran reklam gösteriyor (`app.dart:88-97`). Regl takibi
"gir-kaydet-çık" uygulaması; 3 saniyelik işe 5 saniyelik reklam ekliyor.
Günde bir kez sınırı ve ilk açılışta hiç göstermemek makul.

**7. 🟡 Reklam kayıt anını kesmemeli.** Reklamı açılışa değil, kaydet
sonrasına bağlamak hem daha az can sıkıcı hem dönüşümü yüksek: kullanıcı
işini bitirmiş oluyor.

*Uygulandı:* uygulama açılışı ve kilit açılışı artık reklam tetiklemiyor.
Reklam yalnız başarılı kullanıcı kaydından sonra; ücretsiz katman, 24 saat
sınırı, kılık/kilit ve oturumdaki tek gösterim koşulları yeniden doğrulanarak
geliyor. Geri Al penceresi kapanmadan gösterilmiyor ve geri alınan kayıt reklam
üretmiyor; widget hızlı kaydı reklamsız kalıyor.

**8. 🟡 İki plan arasındaki fark okunmuyor.** Yıllık kart "en iyi değer"
rozeti taşıyor ama tasarruf oranı yazmıyor. "Ayda ₺16,6 — %43 tasarruf"
karşılaştırmayı kullanıcı adına yapar.

*Uygulandı:* mağazadan iki ürünün de yerelleştirilmiş fiyatı geldiğinde yıllık
kart aylık karşılığını ve aylık plana göre gerçek tasarruf yüzdesini hesaplayıp
gösteriyor. Kur, ülke veya mağaza fiyatı değiştiğinde karşılaştırma da
kendiliğinden güncelleniyor.

**9. 🔵 Tek seferlik "ömür boyu" seçeneği yok.** Sağlık verisi gibi uzun
ömürlü bir şeyi abonelikle kiralamak bazı kullanıcıyı tümden uzaklaştırıyor.
Eski `premium_no_ads` alıcıları zaten var, kalıp tanıdık.

*Uygulandı:* mevcut `premium_no_ads` tek seferlik ürünü mağaza tarafından
döndürülürse paywall'da yerelleştirilmiş fiyatıyla “Ömür boyu” planı olarak
gösteriliyor. Ürün mağazada tanımlı değilse boş veya satın alınamaz kart
çizilmiyor; eski alıcıların geri yükleme hakkı korunuyor.

**10. 🔵 Ana ekrandaki erişim çipi sürekli görünür.** Deneme sayacı her
açılışta göz hizasında (`dashboard_screen.dart:231`). Son 7 güne kadar
gizlenmesi, kalan sürede uygulamanın kendi işine odaklanmasını sağlar.

*Uygulandı:* deneme çipi yalnız son 7 günde görünür; ücretsiz katman çipi
erişim durumunu açıklamak için görünmeye devam eder.

---

## B. Ana ekran (11–24)

**11. 🟠 En değerli piksel bir tercihe ayrılmış.** Sağ üstte tema değiştirme
düğmesi duruyor (`dashboard_screen.dart:170-209`). Tema ayarlarda zaten var ve
varsayılan sistem; kullanıcı bunu ayda bir kez bile kullanmıyor. O köşe
"bugün ne yapmalıyım" cevabına ait.

**12. 🟠 Ana ekran dokuz bloktan oluşuyor.** Selam, erişim çipi, faz butonu,
ring, hafta şeridi, aksiyonlar, tahmin kartları, koç kartı, durum kartları,
sorumluluk metni. Hepsi tek kaydırmada. Kullanıcının %90 sorusu tek: "ne
zaman?" Üstteki ekranda bu cevap, gerisi kaydırmanın altında olmalı.

**13. 🟠 Tek cümlelik cevap yok.** Ring döngü gününü gösteriyor ama "regl
tahminen 6 gün sonra, 12 Ağustos" cümlesi hiçbir yerde açıkça yazmıyor. Ring
görsel, cümle bilgi — ikisi birlikte olmalı.

**14. 🟡 Selamlama yer kaplıyor, bilgi vermiyor.** "Merhaba, Ayşe" 26 punto
ve tam genişlik. Tarih + döngü günüyle birleştirilirse aynı yer bilgi taşır.

**15. 🟡 Sorumluluk metni her açılışta.** Tıbbi uyarı ana ekranın dibinde
sabit (`dashboard_screen.dart:333`). Onboarding'de bir kez ve ayarlarda
kalıcı olması yeterli; her gün tekrarlanan uyarı okunmaz hale gelir.

*Uygulandı:* tekrarlanan iki uyarı ana ekrandan kaldırıldı. Tıbbi sorumluluk
metni ayarlarda ve sağlık verisi gösteren takvim/istatistik yüzeylerinde
erişilebilir kalıyor.

**16. 🟠 Faz gradyanı metin kontrastını düşürüyor.** Zemin fazın rengiyle
%35 alfa boyanıyor. İkincil metin (`textSecondary`) gradyanın üstünde
**dört fazın hepsinde** sınırın altına düşüyor.

*(Ölçüldü ve iddia genişledi: açık temada 3,47–4,29:1 — yalnız foliküler ve
luteal değil, en kötüsü ovülasyon. Koyu tema hiç değerlendirilmemişti:
orada 2,60–3,68:1 ile daha da kötü. Ayrıca önerdiğim çözüm — alfayı %20'ye
çekmek — açık temada işe yaramıyor: alfa %5'te bile 4,43:1'de kalıyor,
çünkü pastel tint zemini yalnız biraz açıyor.)*

**17. 🟡 Ring dolu döngüde ne söylüyor belirsiz.** Gün sayısı merkezde ama
"geciktin" durumu ayrı bir dil istiyor. 3 gün gecikmede ring rengi ve merkez
metni farklılaşmalı, yoksa kullanıcı gecikmeyi fark etmiyor.

**18. 🟡 Gecikme durumu hiç ele alınmamış.** Tahmini gün geçtiğinde
uygulamanın söyleyecek sözü yok. "5 gün gecikme — düzensizlik normal olabilir,
kaydını güncelle" gibi bir durum kartı hem işlevsel hem sakinleştirici.

**19. ✅ Koç kartı zaten kişisel.** Genel faz ipucunun üstünde kullanıcının
kendi kayıtlarından çıkan içgörü duruyor ("Kayıtlarına göre bu fazda en sık:
X (%Y)"), motoru istatistikle aynı (`topInsightForPhase`).

*(İlk yazımda "faz başına sabit ipucu dönüyor" demiştim, doğru değil —
kişisel içgörü katmanı zaten vardı. Yanlış bir eleştiriydi.)*

**20. 🔵 Hızlı durum kartları eylemsiz.** Hiçbir şey girilmemişken
yönlendirme var ama gün yarı doluyken eksik olan istenmiyor; dolu kartlar da
dokunulamıyor.

**21. 🔵 Hamilelik modunda ana ekran zayıflıyor.** Hafta sayacı + aksiyon
satırı kalıyor, gerisi düşüyor. Hamilelik haftasına göre bilgi kartı
(bebek gelişimi, kontrol randevusu hatırlatması) o boşluğu doldurur.

*Uygulandı:* hafta sayacının altına trimester grubuna göre değişen kısa
gelişim bilgisi ve sağlık uzmanının önerdiği kontrol planını izleme
hatırlatması eklendi. Başlangıç tarihi yoksa bilgi uydurulmuyor; mevcut tarih
girme yönlendirmesi korunuyor. Kart uzun çevirilerde doğal olarak büyüyor ve
gelişim ile kontrol metnini ekran okuyucuya tek anlamlı özet olarak aktarıyor.

**22. 🔵 Hap modu yalnız bir çip.** Hap paketi başlangıcı çip olarak
gösteriliyor (`dashboard_screen.dart:287`). Paketin kaçıncı günü, plasebo
dönemi ne zaman başlıyor — bu modun asıl sorusu bu.

**23. 🔵 TTC modunda "test zamanı" yok.** Gebelik testi için en erken
anlamlı gün (ovülasyon + 12) hesaplanabilir bir tarih ve TTC kullanıcısının
en beklediği bilgi.

**24. 🔵 Ana ekran sıralaması sabit.** Hangi bloğun üstte olacağı kullanıcıya
göre değişir (TTC ovülasyonu, hap kullanıcısı paketi ister). Ayarlarda basit
bir sıralama tercihi düşünülebilir.

*Uygulandı:* Ayarlar > Tercihler bölümündeki “Döngü önce / Bugün önce”
seçimi, günlük özet ile döngü içeriğinin ana ekrandaki sırasını değiştiriyor.
Varsayılan mevcut döngü odaklı düzen; seçim cihazda kalıcı. Seçici uzun
çevirilerde ve büyük metinde satır kırabilen iki chip kullanıyor.

---

## C. Kayıt akışı — uygulamanın asıl işi (25–38)

**25. 🔴 Kaydetmek en az üç dokunuş.** Ana ekran → "Kayıt ekle" → sheet →
seç → kaydet. Günlük tekrarlanan iş için fazla. Hafta şeridindeki güne uzun
basınca tek dokunuşla akış yoğunluğu girilebilmeli.

*Uygulandı:* hafta şeridindeki geçmiş veya bugünkü bir güne uzun basınca
doğrudan akış yoğunluğu seçicisi açılıyor; seçim aynı günün kaydına yazılıyor.

**26. 🟠 Hızlı kayıt sheet'i üç alanla sınırlı.** Akış, ruh hâli, semptom
(`quick_log_sheet.dart:154-190`). Sık kullanılan not ve ağrı kesici bilgisi
"tüm takipçiler"in arkasında. Sheet'in içeriği kullanıcının en çok kullandığı
üç alana göre uyarlanabilir.

**27. 🟠 Dünü kaydetmek zor.** Sheet hep seçili güne açılıyor ama sheet
içinde gün değiştirilemiyor. Başlıkta "dün / bugün" geçişi olmalı — akşam
uygulamayı açıp dünü girmek tipik davranış.

**28. 🟠 On ayrı takip ekranı ağır bir yapı.** Günlük ekranı on kategori
kartı listeliyor (`log_screen.dart:196-223`), her biri ayrı sayfa. Su, uyku,
kilo gibi sayısal olanlar tek "günlük ölçümler" sayfasında toplanabilirdi;
şu anki hâli on kere geri tuşu demek.

*Uygulandı:* su, uyku, kilo ve sıcaklık tek “Günlük Ölçümler” ekranında
toplandı. Günlük kayıt ızgarasındaki dört kart tek karta indi; girilmemiş
ölçümler varsayılan değerle hayalet kayıt oluşturmuyor. Birim tercihleri,
ölçüm saatleri ve uyku kalitesi korunuyor; eski ayrı ekran rotaları mevcut
bildirim ve derin bağlantılar için çalışmaya devam ediyor.

**29. 🟡 Kaydedilen şey geri bildirim vermiyor.** Kayıttan sonra "Kaydedildi"
snackbar'ı çıkıyor (`quick_log_sheet.dart:101`) ama ana ekranda ne değişti
görünmüyor. Hafta şeridindeki noktanın dolması gibi görünür bir iz gerekiyor.

*Zaten uygulanmış:* hafta şeridi günlük kaydı bulunan günlerin altında kalıcı
bir kayıt noktası gösteriyor ve provider değişikliğini anında izliyor.

**30. 🟡 Alışkanlık kurma mekaniği yok.** Seri (streak), haftalık doluluk
oranı gibi hafif bir geri bildirim, günlük kaydı sürdürmenin tek gerçek
motivasyonu. Sağlık uygulamasında agresif olmadan yapılabilir.

*Uygulandı:* bugünün özeti başlığında, yalnız kayıt bulunan kullanıcıya
günlük seri ile son yedi gündeki kayıt sayısını gösteren sakin bir rozet
eklendi. Bugün henüz kayıt yoksa dün biten seri gün içinde sıfırlanmıyor.

**31. 🟡 Semptom listesi uzun ve düzsüz.** Sık kullanılanlar öne alınmıyor.
Kullanıcının son 30 günde seçtiği semptomlar listenin başında olmalı.

**32. 🔵 Şiddet girilebiliyor ama görünürlüğü zayıf.** Semptom ekranında
1–5 arası şiddet seçilebiliyor; hızlı kayıt sayfası ise sabit 2 yazıyor ve
şiddet istatistiklerde kullanılmıyor.

*(İlk yazımda "semptom var/yok olarak kaydediliyor" demiştim, doğru değil —
`SymptomEntry.severity` var ve semptom ekranında beş noktalı seçici duruyor.
Şiddet hızlı kayda da taşındı: seçilen semptomun altında 1–5 noktalı seçici
açılıyor. İstatistikte en sık belirtilerin ortalama şiddeti de artık sıklık
grafiğinin altında gösteriliyor.)*

**33. 🟡 İlaç modeli günlük kayda bağlı.** İlaçlar günlük log içinde
tutuluyor ve hatırlatmalar en son ilaç içeren logdan okunuyor
(`main.dart:71-78`). Tekrarlayan bir ilaç aslında profile ait; bugünkü model
"dün girdiysem bugün de hatırlatılır" varsayımına yaslanıyor.

*Uygulandı:* ilaç adı, doz ve saat profil içindeki kalıcı plana taşındı;
“alındı” durumu günlük kayıtta kaldı. Eski kurulumlarda en yeni ilaçlı gün
plana yalnız bir kez aktarılıyor ve tarihsel kayıtlar değiştirilmeden
korunuyor. Ekleme/silme planı ve bildirimleri güncellerken onay kutusu yalnız
seçili günü yazar. Bildirimden “alındı” eylemi o gün kayıt yoksa planı temel
alarak günlük kayıt oluşturuyor. Kullanıcı planı tamamen sildikten sonra eski
günler ilaçları yeniden canlandıramıyor.

**34. 🟡 İlaç alındı bildirimden işaretlenemiyor.** Alındı kaydı tutuluyor
(`MedicationEntry.taken`, ilaç ekranında dokunulabilir) ama hatırlatma
geldiğinde uygulamayı açıp aynı işi elle yapmak gerekiyor.

*(İlk yazımda "alındı kaydı tutulmuyor" demiştim, doğru değil — alan da
ekrandaki geçiş de var. Eksik olan yalnız bildirim üzerinden işaretleme,
yani madde 69'un kapsamı.)*

**35. 🔵 Ölçümlerde birim tercihi yok.** Kilo ve sıcaklık tek birimde.
İngilizce/Almanca kullanıcı için lb ve °F beklentisi gerçek.

*Uygulandı:* ayarlara kg/lb ve °C/°F seçicileri eklendi. Kayıt ekranları ve
günlük özetler seçilen birimi gösteriyor; geçmiş veri ve hesaplamalar
etkilenmesin diye değerler içeride daima kg ve °C olarak saklanıyor. Tercihler
yedek JSON'una ve geriye uyumlu Hive alanlarına da eklendi.

**36. 🔵 Not alanı arama ve tarih filtresi istemiyor.** Notlar tek gün
üzerinden yazılıyor (`notes_screen.dart`), geçmiş notlarda arama yok.

*Uygulandı:* not ekranındaki arama eylemi, not bulunan bütün günleri
yeniden eskiye listeliyor. Metin araması büyük/küçük harften bağımsız;
takvim eylemiyle başlangıç ve bitiş tarihi birlikte daraltılabiliyor. Sonuca
dokununca o günün notu aynı düzenleyicide açılıyor.

**37. 🔵 Toplu giriş yok.** Uygulamayı yeni kuran kullanıcı geçmiş 3 döngüsünü
girmek istiyor; şu an tek tek tarih seçmek zorunda.

*Uygulandı:* takvim araç çubuğundaki toplu giriş akışından en fazla üç geçmiş
regl aralığı seçilip birlikte kaydedilebiliyor. Paket, mevcut kayıtlarla ve
kendi içinde çakışma açısından yazmadan önce doğrulanıyor; işlem tek eylemle
geri alınabiliyor.

**38. 🔵 Kayıt sonrası akış bitmiyor.** Kaydet sonrası ekranda kalınıyor.
Sheet kapanıp ana ekrana dönmek ve değişikliği orada göstermek daha temiz
bir kapanış.

*Zaten uygulanmış:* hızlı kayıt kaydedilince sheet kapanıyor, ana ekrandaki
hafta şeridi ve durum kartları güncellenen provider'ı anında yansıtıyor.

---

## D. Takvim (39–47)

**39. 🟠 Takvimden hiçbir şey işaretlenemiyor.** Güne dokununca gün özeti
sayfası herkese açılıyor ama içindeki tek eylem ("Hızlı kayıt") premium
kapısına çarpıyor. Ücretsiz kullanıcı için takvim salt okunur bir kartona
dönüşüyor; en azından regl günü işaretleme açık olmalı.

*(İlk yazımda "güne dokunmak premium kapısına çarpıyor" demiştim; gün özeti
sayfası aslında herkese açılıyor, kapalı olan içindeki eylem.)*

**40. 🟠 Efsane (legend) sürekli yer kaplıyor.** Renk anlamları her açılışta
gösteriliyor. İlk birkaç kullanımdan sonra kapatılabilir olmalı.

**41. 🟡 Ay geçişinde bağlam kayboluyor.** Önceki aya gidince "bu ay 2 gün
gecikme vardı" gibi özet yok. Ay başlığının altında tek satırlık ay özeti
takvimi okunur kılar.

**42. 🔵 Tahmin ile gerçek ayrımı güçlendirilebilir.** Tahmin günleri açık
dolgu + ince çerçeve, gerçek günler dolu zemin. Ayrım var ama kesikli çerçeve
"henüz olmamış" fikrini daha net söylerdi.

*(Önceliği düşürüldü: ilk yazımda "aynı doluluğa sahip" demiştim, doğru
değil — `calendar_screen.dart` tahmin günlerine hem daha açık dolgu hem
1,5 px çerçeve veriyor ve kodda bunun gerekçesi de yazılı. Kalan iş kesikli
çerçeveydi.)*

*Uygulandı:* tahmin hücrelerinin düz çerçevesi kesikli daireye çevrildi.
Gerçek regl günü dolu zeminle, tahmin günü açık zemin + kesikli sınırla
renkten bağımsız olarak ayrılıyor.

**43. 🟡 Yıl görünümü yok.** 12 aylık kuş bakışı, düzensizliği tek bakışta
gösteren en güçlü görünüm — istatistikte yıl halkası var ama takvimde yok.

*Uygulandı:* takvim araç çubuğundan açılan yıl görünümü 12 ayı aynı yüzeyde
gösteriyor. Gerçek regl günleri dolu, tahmin günleri içi boş işaretle renk
dışında da ayrılıyor; aya dokunmak aylık takvimi doğrudan o aya götürüyor.
Izgara telefon ve tablet genişliğine uyarlanıyor.

**44. 🔵 Uzun-bas önizlemesi keşfedilmiyor.** Güzel bir detay ama hiçbir yerde
öğretilmiyor. İlk kullanımda tek seferlik ipucu yeter.

*Uygulandı:* takvimin altında uzun-bas önizlemesini anlatan kısa ipucu ilk
kullanıma kadar gösteriliyor; hareket ilk kez yapıldığında kalıcı olarak
kapanıyor.

**45. 🔵 Bugüne dönüş butonu yok.** Üç ay geriye kaydıran kullanıcı bugüne
elle dönüyor.

**46. 🔵 Çoklu gün seçimi yok.** "12–16 arası regldim" demek beş ayrı dokunuş.

*Uygulandı:* gün ayrıntısından sistem tarih aralığı seçicisi açılıyor ve
başlangıç–bitiş tek kapalı regl kaydı olarak ekleniyor. Mevcut kayıtla
çakışan aralık reddediliyor; yeni kayıt 6 saniye içinde geri alınabiliyor.

**47. 🔵 Takvimden paylaşım yok.** Doktora göstermek için ay görünümünün
görüntüsünü almak yaygın bir ihtiyaç.

*Uygulandı:* takvim başlığındaki paylaş eylemi görünen ay kartını yüksek
çözünürlüklü PNG olarak yakalayıp sistem paylaşım menüsünü açıyor.

---

## E. İstatistik (48–57)

**48. 🟠 Sayılar yorumsuz.** Ortalama döngü 29,3 gün yazıyor ama bunun iyi mi
kötü mü olduğu söylenmiyor. "21–35 gün aralığı normal kabul edilir" referansı
sayıyı anlamlı kılar.

**49. 🟠 Düzensizlik etiketi tıbbi ağırlık taşıyor.** "Düzensiz"
(`statistics_screen.dart:506`) kullanıcıda kaygı yaratabilecek bir yargı.
Yanına ne anlama geldiği ve ne zaman hekime danışılması gerektiği yazmalı.

**50. 🟡 Az veriyle grafik gösteriliyor.** İki döngüyle ortalama hesaplamak
yanıltıcı. Güven düşükken bunu açıkça söylemek gerekir.

**51. 🟡 Doktor için çıktı yeterince görünür değil.** PDF dışa aktarma
ayarların derinliğinde. İstatistik ekranının başında "Doktoruma özet çıkar"
butonu, uygulamanın en somut faydası.

**52. 🟡 Dönem filtresi 3/6/12 ay sabit.** "Tüm zamanlar" ve "son 3 döngü"
daha doğal birimler — döngü uygulamasında zaman ayla değil döngüyle ölçülür.

**53. 🟡 Grafiklerde karşılaştırma yok.** Bu döngü ile önceki döngüyü üst üste
koymak, trend cümlelerinden daha okunur.

*Uygulandı:* son iki döngünün günlük toplam belirti şiddeti, döngü gününe göre
hizalanıp aynı çizgi grafikte gösteriliyor. Önceki döngü yalnız mevcut
döngünün ulaştığı güne kadar karşılaştırılıyor; düz/kesikli çizgi ayrımı renk
dışında ikinci bir görsel kanal sağlıyor.

**54. 🔵 Semptom-faz ilişkisi tek yönlü.** Faz içgörüleri var ama tersi yok:
"baş ağrısı en çok hangi günlerde" sorusu cevapsız.

*Uygulandı:* mevcut faz içgörüleri her belirtiyi en sık görüldüğü döngü fazı
ve o fazdaki yüzdesiyle gösteriyor; belge durumu gerçek davranışla eşitlendi.

**55. 🔵 Kilo ve sıcaklık grafikleri döngüyle ilişkilendirilmiyor.** Bazal
sıcaklığın asıl anlamı ovülasyonla birlikte okunmasında.

*Uygulandı:* sıcaklık ve kilo trendlerinde her döngünün tahmini ovülasyonu
kesikli dikey çizgiyle gösteriliyor; mevcut döngüde BBT/LH teyidi varsa
tahminin yerini teyitli tarih alıyor. Nokta araç ipucu ayrıca o günün döngü
fazını yazıyor.

**56. 🔵 Veri yoğunluğu göstergesi yok.** Hangi ayda ne kadar kayıt girildiği,
grafiklerin ne kadar güvenilir olduğunu anlatır.

*Uygulandı:* seçili dönemin toplam doluluk oranı ve son 12 aya kadar aylık
doluluk çubukları istatistik özetine eklendi; boş günlük nesneleri kayıt
sayılmıyor.

**57. 🔵 Grafikten güne gidilemiyor.** Bir noktaya dokununca o günün kaydına
inmek beklenen davranış.

*Uygulandı:* sıcaklık ve kilo trendlerinde bir noktaya dokunmak o tarihi seçip
günlük kayıt ekranını açıyor; davranış kartın altında kısa bir ipucuyla
görünür kılındı.

---

## F. Onboarding (58–66)

**58. 🟠 Değer görülmeden altı adım yürünüyor.** Mod, isim, doğum tarihi, son
regl, döngü uzunluğu, regl uzunluğu (`onboarding_screen.dart:35`). Kullanıcı
uygulamanın ne yaptığını görmeden form dolduruyor. Adımların tamamının
kurulumda olması gerekmiyor; döngü ve regl uzunluğu varsayılanla geçilip
sonra sorulabilir.

*(İlk yazımda "altı zorunlu soru" demiştim; kodda yalnız son regl tarihi
zorunlu — `_canContinue` yalnız 3. adımı kilitliyor. Sorun soruların
zorunluluğu değil, sayısı.)*

**59. 🟠 İsim ve doğum tarihinin isteğe bağlı olduğu söylenmiyor.** İkisi de
kodda atlanabilir ve ikisinin de bir gerekçe satırı var ("Sana nasıl hitap
edelim?", "Yaşa uygun öneriler sunmamıza yardımcı olur"). Ama hiçbir yerde
"isteğe bağlı" yazmıyor: sağlık uygulamasında kişisel veri isteyen her alan
zorunlu sanılıyor.

*(İlk yazımda "gerekçesiz isteniyor" demiştim; gerekçe var, eksik olan
atlanabilirliğin görünmesi.)*

**60. 🟡 "Bilmiyorum" seçeneği yok.** Son regl tarihini hatırlamayan kullanıcı
sıkışıyor. "Emin değilim" yolu, yanlış veri girmekten iyidir.

**61. 🟡 Bildirim izni gerekçesiz isteniyor.** Sistem dialogu soğuk açılışta
çıkıyor (`main.dart:67`), öncesinde açıklama yok. Reddedilirse bir daha
sorulamaz. Önce uygulama içi açıklama, sonra sistem izni.

**62. 🟡 Gizlilik vaadi öne çıkmıyor.** "Veriler yalnız cihazında" bu
kategoride en güçlü satış argümanı ve kurulumun ilk ekranında olmalı.

**63. 🔵 Kurulum sonrası ekran boş.** İlk açılışta tahmin var ama kayıt yok.
"İlk kaydını ekle" yönlendirmesi ilk günü boş geçirtmez.

*Zaten uygulanmış:* ana ekrandaki "Bugün özeti", bugüne ait ruh hâli veya
semptom yoksa tam genişlikte ilk kayıt yönlendirmesi gösteriyor ve günlük
kayıt ekranını açıyor.

**64. 🔵 Mod değişiminin sonucu anlatılmıyor.** Hamilelik moduna geçince
tahminlerin duracağı önceden söylenmiyor.

*Uygulandı:* ayarlarda mod değişmeden önce seçilen modun etkisini açıklayan
bir onay diyaloğu gösteriliyor. Hamilelik modu özellikle regl tahminleri ve
bildirimlerinin duracağını değişiklik kaydedilmeden önce söylüyor.

**65. 🔵 Geri dönüş yok.** Kurulum sırasında önceki adıma dönmek mümkün mü
belirsiz; adım göstergesi var ama geri hareketi net değil.

*Zaten uygulanmış:* her form adımında etiketli geri butonu var; Android sistem
geri hareketi de uygulamadan çıkmak yerine önceki onboarding adımına dönüyor.

**66. 🔵 Veri sıfırlama uyarısı korkutucu.** Kutular çözülemediğinde çıkan
uyarı (`onboarding_screen.dart:50`) teknik bir olayı kullanıcıya yüklüyor;
dili sadeleşmeli ve yedekten geri yükleme yolu aynı ekranda önerilmeli.

*Uygulandı:* uyarı nedenini sade dille açıklıyor ve aynı diyalogdan JSON
yedeği seçilip doğrulanabiliyor. Onaydan sonra profil, dönemler ve günlükler
geri yükleniyor; provider'lar, bildirimler ve ana ekran widget'ı yenileniyor.

---

## G. Bildirimler (67–74)

**67. 🟠 Tek bildirim saati var.** Regl, ovülasyon ve ilaç aynı saatte
(`notification_service.dart:372`). İlaç sabah, regl uyarısı akşam istenir.
Tür başına saat gerekir.

**68. 🟠 Hatırlatma penceresi sabit: 1 gün önce.** Kimi kullanıcı 3 gün önce
haber almak ister (`notification_service.dart:129`). Ayarlanabilir olmalı.

**69. 🟡 Bildirim aksiyon taşımıyor.** "Reglin başlayabilir" diyor ama
bildirim üzerinden "başladı" işaretlenemiyor. Uygulamanın en önemli kaydı
tek dokunuşla alınabilirdi.

**70. 🟡 Gecikme bildirimi yok.** Tahmini gün geçtiğinde hiçbir şey
gönderilmiyor; oysa kullanıcının en çok merak ettiği an tam orası.

**71. 🟡 Bildirim ayarları sınırlı.** Aç/kapa var, sıklık ve ton yok.
"Sessiz özet" tercihi gizlilik açısından da değerli.
*Uygulandı:* ton tarafında tek bir "sessiz bildirimler"
anahtarı bütün türleri sessize alıyor (ses yok, açılır baloncuk yok,
bildirim yalnız gölgelikte durur). Gizlilik faydası da bu: kilit ekranında
öne çıkmayan bildirim yandaki kişiye görünmüyor. Uygulanırken bir tuzak
çıktı: Android'de kanalın önem derecesi kanal **oluşturulurken** sabitlenir,
sonradan gönderilen `importance` yok sayılır — sessiz sürüm kendi kanal
kimliğini kullanıyor, yoksa anahtar hiçbir şey değiştirmezdi.
Sıklık “Temel / Dengeli / Ayrıntılı” yoğunluğuna somutlaştırıldı: temel
yalnız etkin regl uyarısını, dengeli etkin ovülasyonu da, ayrıntılı ise
gecikme/TTC pencere/faz içgörüsü/zincir sonu uyarılarını ekliyor. Tür başına
aç/kapa üst sınır; ilaç hatırlatmaları tedavi güvenliği için etkilenmiyor.

**72. 🔵 Üç döngü ileri planlama sessiz bir sınır.** Uygulama 3 ay açılmazsa
hatırlatma zinciri kopuyor (`notification_service.dart:43`). Kullanıcı bunu
bilmiyor; hiç değilse zincirin sonunda "uygulamayı aç" hatırlatması olmalı.
*Uygulandı:* zincirin bir döngü ardına tek bir "hatırlatmalar duraklıyor"
bildirimi kuruluyor. Uygulama her açıldığında zincir uzadığı ve bu bildirim
de ileri kaydığı için, düzenli kullanan onu hiç görmüyor.

**73. 🔵 Ovülasyon bildirimi hap modunda anlamsız ama TTC'de kritik.** Aynı
metin ikisine gidiyor; TTC kullanıcısı için "verimli pencere bugün başlıyor"
daha doğru.
*Düzeltme:* maddenin ilk yarısı yanlıştı — hap ve hamilelik modunda döngü
tahmini bildirimleri zaten hiç kurulmuyor (`cyclePredictionsActive`), yani
hap modunda ovülasyon bildirimi gitmiyordu. Geçerli olan ikinci yarısı:
*uygulandı*, ama gün seçimi düzeltilerek. Pencere ovülasyondan 5 gün önce
açılır ve asıl fırsat orada; TTC modunda bildirim ovülasyon gününe değil
pencerenin açıldığı güne kuruluyor, ovülasyon günü bildirimi de duruyor.

**74. 🔵 Bildirim metinleri tek tip.** Aynı cümle her ay tekrar ediyor.
Küçük bir varyasyon havuzu, bildirimin görünmez hale gelmesini geciktirir.
*Uygulandı, üstüne bir hata çıktı:* regl bildiriminin gövdesi "yarın
başlayabilir" diye sabitti. Madde 68 ile hatırlatma penceresi
ayarlanabilir olunca, 3 gün önce kurulan bildirim **yanlış gün**
söylüyordu. Gövde ikiye ayrıldı: zamanlama cümlesi pencereye göre
kuruluyor (bugün / yarın / N gün sonra), ardından üç ipuçlu havuzdan
biri ekleniyor. Gecikme bildiriminin de üç gövdesi var. Havuz seçimi
tahmini regl tarihinin ay numarasına bakıyor — döngü indeksi
kullanılsaydı her yeniden planlamada havuz başa dönerdi.

---

## H. Erişilebilirlik (75–84)

**75. 🔴 Pastel renkler metin rengi olarak kullanılıyor.** `app_colors.dart`
kendi kuralını yazmış: "pastel ve ring tonları YÜZEY/vurgu içindir, METİN
rengi olamaz". Ama kilo (`#80CBC4`), uyku (`#9FA8DA`), su (`#90CAF9`), ilaç
(`#A5D6A7`) ekranlarında bu tonlar doğrudan metin rengi. Beyaz zeminde
kontrast oranları 1,9:1 ile 2,9:1 arasında — WCAG AA sınırı 4,5:1. Faz
renklerinde yapıldığı gibi her kategoriye `*Text` varyantı gerekiyor.

**76. 🔴 Ruh hâli etiketleri seçilince okunmaz oluyor.** Seçili ruh hâlinin
etiketi kendi pastel rengine dönüyor (`mood_tracking_screen.dart:137-144`);
`moodHappy #FFE082` beyaz üstünde ~1,6:1. Seçim vurgusu çerçeve ve zeminle
verilmeli, metin okunur tonda kalmalı.

**77. 🟠 Metin ölçeklemesi hiç ele alınmamış.** Kod tabanında tek bir
`textScaler` kullanımı yok, ana ekranda tek bir `maxLines`/`TextOverflow`
koruması yok. Sistem yazı tipi büyütüldüğünde ana ekranın taşması bekleniyor.
Cihaz erişilebilirlik ayarı %200'e kadar çıkabiliyor.

*Uygulandı:* genel bir metin küçültme veya ölçeği sınırlama eklenmedi.
Etkin yazı ölçeğini kullanan ortak düzen hesabıyla ruh hâli, semptom, günlük
kategori, onboarding ve yıl görünümü ızgaraları dar ekranda sütun azaltıp
yükseklik kazanıyor. Ana ekran özetleri, eylemler, tahminler, ayarlar, ödeme
planları, uyku, su, akış, regl geçmişi ve istatistik satırları gerektiğinde
dikey akıyor; kilit ekranı kaydırılabiliyor. Birincil başlık ve eylemlerdeki
kesmeler kaldırıldı, 48 dp dokunma hedefleri korundu. Saf hesaplar ve yıl
görünümünün 320/600 dp ile 1×/2× yerleşimi test kapsamına alındı.

**78. 🟠 Dokunma hedefleri kontrol edilmemiş.** Tema düğmesi 10 px iç
boşluklu 22 px ikon = 42 px; Material'ın 48 px asgarisinin altında. Küçük
ikon butonlarının hepsi taranmalı.

**79. 🟡 Renk körlüğü desteği yalnız faz renklerinde.** Desen modu ring ve
şeritlerde çalışıyor ama akış yoğunluğu, ruh hâli ve semptom renklerinde
karşılığı yok.
*Düzeltme:* saydığım üç yer yanlış seçilmişti. Akış yoğunluğunda damla
sayısı (1–4) + etiket, ruh hâlinde emoji + etiket, semptomda ikon + etiket
var — renk hiçbirinde **tek** kanal değil, desen eklemek gürültü olurdu.
*Uygulandı:* renk gerçekten tek kanal olan iki yer bulundu ve düzeltildi.
**Takvim hücreleri**: desen modu açıkken bile düz kalıyorlardı (hücreler
ring tonlarını değil kendi pastel paletini kullanıyor, eşleme tablosunda
yoklardı) — ovülasyon moru ile regl pembesi deuteranopiada birbirine yakın
iki soluk tona düşüyordu. Artık aynı fazın takvim karşılığı ring'dekiyle
aynı dokuyu alıyor. **Ruh hâli pastası**: dilimi lejanttaki adına bağlayan
tek şey renkti; lejant artık yüzdeyi de yazıyor, dilimin içindeki "%38" ile
eşleşiyor.

*Bu maddeyi uygularken ayrı bir kontrast hatası çıktı:* takvim hücrelerinde
gün numarası pastel zeminde **beyaz** yazılıyordu — regl hücresinde 2,06:1,
ovülasyonda 2,66:1, seçili günde 2,06:1, tahmin hücresinde pembe metinle
2,50:1 (AA sınırı 4,5:1). Kod tabanının kendi kuralı zaten yazılıydı
("pastel primary beyazla 2.06:1, zemin olarak kullanılamaz"), takvimde
atlanmıştı. Dördü de koyu metne çevrildi (5,10–11,27:1).

**80. ✅ Grafiklerin metin alternatifi zaten var.** Üç grafiğin üçü de
(çubuk, pasta, çizgi) `Semantics` + `ExcludeSemantics` çiftiyle sarılı ve
veriyi metin olarak duyuruyor: çubukta "semptom: sayı" listesi, pastada
"ruh hâli: %", çizgide "son değer / min / maks". İstatistik ekranındaki
`CustomPaint` görseli de sarılı.

*(İlk yazımda "metin alternatifi yok" demiştim; kodda vardı ve benim
incelememden önce eklenmişti. Yanlış bir eleştiriydi.)*

**81. 🟡 Hareket azaltma kısmen uygulanmış.** `animateSafe` var ama
`animate()` doğrudan çağrılan yerler kalmış — kalıp her yerde aynı olmalı.
*Düzeltme:* gerekçe yanlıştı. Kod tabanındaki tek `.animate()` çağrısı
`animateSafe`'in kendi içinde; flutter_animate tarafı eksiksiz. Asıl boşluk
başka yerdeydi: **örtük animasyonlar** (AnimatedContainer, AnimatedSwitcher,
AnimatedScale, TweenAnimationBuilder) sistem ayarını kendiliğinden
dinlemiyor. 26 örtük animasyonun 19'unda hiçbir şey yoktu, 6'sında elle
`motionEnabled ? ... : Duration.zero` yazılmıştı. *Uygulandı:* maddenin asıl
sözü — "kalıp her yerde aynı olmalı" — yerine getirildi, hepsi tek bir
`context.motionDuration(...)` yardımcısından geçiyor.

**82. 🔵 Klavye gezinmesi test edilmemiş.** Tablet + klavye senaryosunda
odak sırası belirsiz.

*Uygulandı:* 212 etkileşim yüzeyi tarandı. Standart Material kontrollerinin
yerleşik Tab, Shift+Tab ve Enter/Space davranışı korundu; geniş ana ekran,
takvim ve yıl görünümündeki karmaşık sıralar açık odak gruplarında kaldı.
Yalnız dokunma koordinatıyla çalışan döngü halkası klavye odağı, Enter/Space
etkinleştirmesi ve görünür sınır aldı. Üçüncü taraf takvimdeki gün hücreleri
doğrudan odaklanıp klavyeyle açılabilen Material yüzeylerine dönüştürüldü.
Açık/koyu tema ortak yüksek kontrastlı odak rengi taşıyor. Tab/Shift+Tab
okuma sırası, özel yüzey etkinleştirmesi, Escape ile en üst diyaloğun
kapanması ve odağın açan kontrole dönmesi widget testleriyle kapsandı.

**83. 🔵 Ekran okuyucu etiketleri değer taşımıyor.** Ring "döngü haritası"
diyor ama kaçıncı gün olduğunu söylemiyor.
*Düzeltme:* örnek yanlıştı — ring'in etiketi zaten "Döngü günü: 12 / 28. 16
gün sonra" diyor, gün numarası duyuruluyordu. Ama etiketi okuyunca iki
gerçek eksik çıktı: **faz adı hiç duyurulmuyordu** (ring'in ortasındaki
glif ve renk göreni bilgilendiriyor, görmeyeni değil) ve **gecikmede
"Bugün!" deniyordu** — görünen rozet "3 gün gecikme" yazarken ekran okuyucu
üç gündür bekleyen kullanıcıya yanlış bilgi veriyordu. *Uygulandı:* etiket
artık gördüğünün aynısını söylüyor (faz + gün + durum).

Faz adı için ana ekran ve istatistik ekranı aynı switch'i birebir
kopyalamıştı; üçüncü kopya yerine `EnumLabels.phase` eklendi.

**84. 🔵 Dil ve bölge ayrımı yok.** Dil seçilebiliyor ama tarih biçimi ve
haftanın ilk günü sistem yerelinden geliyor; Rusça seçen ama ABD yerelinde
olan kullanıcıda hafta pazar başlıyor.

*Uygulandı:* tarih biçimleri zaten seçilen uygulama dilini izliyordu; takvim
hafta başlangıcı da sabit pazartesi olmaktan çıkarılıp aynı Material
yerelleştirmesinin pazar/pazartesi/cumartesi kuralına bağlandı.

---

## I. Gizlilik, gizli mod, güvenlik (85–91)

**85. 🔵 Gizli mod keşfedilmiyor.** Uygulamanın en ayırt edici özelliği
ayarların içinde.

*(Önceliği düşürüldü: ayarlardaki satırın zaten açıklayıcı bir alt metni var
ve özellik paywall listesinde de geçiyor — "hiç anlatılmıyor" demek doğru
değildi. Kurulumda ayrı bir tanıtım adımı ise madde 58'in tersi yönde
çalışıyor. Gerçek çözüm kurulum akışının yeniden kurgulanmasıyla birlikte
düşünülmeli.)*

*Uygulandı:* ayrı bir onboarding adımı ekleyip akışı uzatmadan, gizli mod
Güvenlik kartının ilk sırasına taşındı. Ayrıntılı açıklaması ve paywall
özellik listesi korunuyor.

**86. 🟠 Kilit ekranı zaman aşımı yok.** Kilit yalnız arka plana alınınca
devreye giriyor (`app.dart:120-133`). "5 dakika sonra kilitle" seçeneği
beklenen davranış.

**87. 🟡 PIN kurtarma yolu yok.** PIN unutulursa tek çıkış verinin silinmesi;
bu, kurulum sırasında açıkça söylenmeli.

**88. 🟡 Sahte (decoy) ekran inandırıcı değilse riskli.** Not defteri kılığı
gerçek not tutabiliyor mu, boşsa şüphe çeker. Kılık modu birkaç örnek notla
gelmeli.

*Uygulandı:* sahte ekran zaten not ekleme, düzenleme ve silmeyi destekliyordu.
İlk açılışta arayüz diline göre iki sıradan başlangıç notu ekleniyor. Kullanıcı
notları silerse boş liste tercih olarak korunuyor ve örnekler geri gelmiyor.

**89. 🔵 Yedek dosyası şifresiz.** Hive kutuları cihazda şifreli ama dışa
aktarılan yedek düz JSON. En hassas veri en korumasız hâlde cihazdan çıkıyor;
parolalı yedek seçeneği gerekiyor.

*Uygulandı:* yeni yedekler 10–128 karakterlik, cihazda saklanmayan kullanıcı
parolasından Argon2id ile türetilen anahtar ve AES-256-GCM ile şifrelenmiş
`.rtbackup` dosyalarıdır. Her dosyada yeni salt/nonce kullanılır; başlık ve
yük değişiklikleri doğrulanır. Yanlış parola ile bozuk dosya aynı güvenli
mesajı verir ve doğrulama tamamlanmadan mevcut veri silinmez. Eski düz JSON
yedekleri yalnız geriye uyumlu geri yükleme için açıkça uyarılarak kabul
edilir; artık yeni şifresiz JSON yedeği üretilmez. Kurtarma anahtarı yoktur:
parola unutulursa yedek açılamaz.*

**90. 🔵 Ekran görüntüsü koruması yalnız kilitliyken.** `FLAG_SECURE` kilit
gerektiğinde açılıyor; kilit kullanmayan kullanıcı da bu korumayı isteyebilir.

*Uygulandı:* Android güvenlik ayarlarına kilitten bağımsız ekran görüntüsü
koruması eklendi. Açıldığında ekran görüntülerini ve son uygulamalar
önizlemesini `FLAG_SECURE` ile engelliyor; PIN/biyometri kapalı olsa da çalışıyor.
Tercih cihazda saklanıyor ve değişiklik uygulama köküne anında yansıyor.

**91. 🔵 Veri silme geri alınamaz ama tek onaylı.** Yazarak onay
(ör. "SİL" yazmak) bu ağırlıktaki işlem için standart.

*Uygulandı:* silme düğmesi, kullanıcı arayüz dilindeki "Sil" sözcüğünü
yazmadıkça etkinleşmiyor. Büyük/küçük harf farkı kabul ediliyor; iptal ve
geri hareketi hiçbir veriye dokunmuyor.

---

## J. Veri sahipliği ve güven (92–96)

**92. 🟠 Yedekleme kullanıcıya bırakılmış.** Otomatik yedek yok, hatırlatma
yok. Telefon kaybında yılların verisi gidiyor. En azından "30 gündür yedek
almadın" hatırlatması olmalı.

**93. 🟡 Health Connect tek yönlü.** Yalnız yazma izni var
(`health_sync_service.dart:17`). Başka uygulamadan gelen veriyi okumak,
uygulamayı değiştiren kullanıcı için giriş kapısı olurdu.

**94. 🟡 Başka uygulamadan içe aktarma yok.** Flo/Clue'dan geçen kullanıcı
geçmişini getiremiyor; en büyük geçiş engeli bu.

**95. 🔵 Dışa aktarma biçimleri sınırlı.** CSV ve PDF var; takvim (.ics)
çıktısı da doğal bir talep.

*Uygulandı:* veri bölümüne standart `.ics` dışa aktarımı eklendi. Her regl
kaydı tüm gün etkinliği olarak, iCalendar'ın kapsayıcı olmayan `DTEND`
kuralına uygun biçimde sistem paylaşım menüsüne veriliyor.

**96. 🔵 Veri politikası uygulama içinde özetlenmemiş.** Gizlilik metni tam
sayfa; "hiçbir veri cihazdan çıkmaz" cümlesi ayarların en üstünde tek satır
olarak durmalı.

*Uygulandı:* ayarların en üstünde, yasal metne girmeden görülen kısa bir
gizlilik özeti var. Cihazdaki ana verinin şifreli olduğunu söylerken dışa
aktarma ve Health Connect'in kullanıcı tarafından açılan iki çıkış yolu
olduğunu da saklamıyor.

---

## K. Sistem entegrasyonu ve bitirme (97–100)

**97. 🟡 Widget'tan kayıt yapılamıyor.** İki widget boyu da salt görüntüleme.
"Reglim başladı" widget üzerinden tek dokunuşla girilebilse, uygulamanın en
sık işi uygulamayı açmadan biterdi.

*Uygulandı:* iki Android widget boyuna yerelleştirilmiş “Reglim başladı”
eylemi eklendi. Dokunuş uygulamayı açıyor; varsa PIN/biyometri çözüldükten
sonra güncel kılık, onboarding, takip modu ve devam eden kayıt durumu yeniden
doğrulanarak bugünün başlangıcı kaydediliyor. Altı saniyelik geri alma mevcut
kayıt akışını izliyor ve amaçlı widget açılışı reklamla kesilmiyor. Eylem
uygun olmadığında gizleniyor; küçük widget'ta halkayla yer değiştirerek metin
alanını, geniş widget'ta ayrı 48 dp hedef olarak tahminleri koruyor.

**98. 🟡 Kısayol menüsü yok.** Uygulama ikonuna uzun basınca "hızlı kayıt" ve
"bugünü gör" kısayolları (Android shortcuts / iOS quick actions) düşük
maliyetli, yüksek kullanımlı.

*Uygulandı:* Android ve iOS ikon menüsüne yerelleştirilmiş “Hızlı Kayıt” ve
“Bugünü Gör” eylemleri eklendi. Hızlı kayıt mevcut günlük sheet'ini açıyor,
ücretsiz erişimde mevcut paywall kuralını izliyor ve PIN/biyometri açıksa
kilit çözülene kadar bekliyor. Kılık modu açıldığında sağlık kısayolları
tamamen kaldırılıyor; kısayolla başlatılan iş de açılış reklamıyla kesilmiyor.

**99. 🔵 Tablet düzeni yalnız gezinme çubuğunda ele alınmış.** 600 px üstünde
yan rail'e geçiliyor (`app_shell.dart:47`) ama içerik hâlâ tek kolon; geniş
ekranda ana ekran ve takvim yan yana durabilirdi.

*Uygulandı:* gezinme rail'ine ek olarak ana ekran geniş içerikte döngü/eylem
ve tahmin/içgörü kümelerini iki kolona ayırıyor. Takvim de aylık ızgarayı
faz şeridi, ay özeti ve legend paneliyle yan yana gösteriyor. Her iki ekran
çok geniş masaüstünde gerilmemek için 1180 px ile sınırlandırıldı; dar
ekranda mevcut tek kolon sırası korunuyor.

**100. 🔵 Boş durum dili ekranlar arasında tutarsız.** `EmptyState` bileşeni
var ama her ekran kullanmıyor — istatistikteki boş kartlar kendi metnini
yazıyor. Tek bileşene bağlanması hem tutarlılık hem bakım kolaylığı.

*Uygulandı:* istatistikteki genel boş durum ve kart içi boşluklar, dönem
geçmişi, ilaç listesi ve not arama sonucu aynı `EmptyState` kompozisyonunu
kullanıyor. Eylem isteyen ana ekran yönlendirmesi ile gün özeti gibi bağlamsal
satırlar ayrı bırakıldı; onlar boş durum değil, doğrudan işlem çağrısı.

---

## Nereden başlamalı

Sırayla üç şey, gerisi bekleyebilir:

1. **Madde 1 ve 2** — ücretsiz kullanıcının kaydını düzeltebilmesi ve geriye
   dönük tarih girebilmesi. Bunlar olmadan uygulamanın temel işi güvenilmez.
2. **Madde 75, 76, 77** — kontrast ve metin ölçekleme. Erişilebilirlik
   kusuru hem kullanıcı kaybı hem mağaza incelemesinde risk.
3. **Madde 11, 12, 13** — ana ekranın "ne zaman?" sorusuna tek bakışta cevap
   verecek şekilde sadeleşmesi.
