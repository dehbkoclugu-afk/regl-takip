# 100 kritik tasarım önerisi

> **Durum:** 1, 2, 4, 6, 11, 12, 13, 14, 17, 18, 39, 48, 49, 50, 58, 59, 60,
> 61, 62, 67, 68, 70, 75, 76, 77, 86, 87 ve 92 uygulandı; 5, 26, 27 (hızlı
> kayıt), 16, 20, 22, 23, 31, 34, 40, 41, 45 (takvim), 51, 52, 69, 72, 73,
> 74, 78, 79, 81, 83, 84 ve 93 de. Madde 80 geri çekildi (zaten yapılmıştı);
> madde 82 cihaz olmadan doğrulanamadığı için açık bırakıldı.
> Kısmi olanlar:
> 3 (yalnız uyarı tarafı — salt-okunur katman yapılmadı), 71 (ton yapıldı,
> sıklık ayarının somut karşılığı yok), 77 (ana ekran ve
> paylaşılan bileşenler; diğer ekranlarda taşma taraması sürüyor) ve 89
> (uyarı eklendi, parolalı yedek yapılmadı). Madde 7 (reklamın yerini kaydet
> sonrasına almak) bilinçli olarak açık: gelir etkisi olan bir ürün kararı.
> Ayrıntı için CHANGELOG'a bakın.

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

**8. 🟡 İki plan arasındaki fark okunmuyor.** Yıllık kart "en iyi değer"
rozeti taşıyor ama tasarruf oranı yazmıyor. "Ayda ₺16,6 — %43 tasarruf"
karşılaştırmayı kullanıcı adına yapar.

**9. 🔵 Tek seferlik "ömür boyu" seçeneği yok.** Sağlık verisi gibi uzun
ömürlü bir şeyi abonelikle kiralamak bazı kullanıcıyı tümden uzaklaştırıyor.
Eski `premium_no_ads` alıcıları zaten var, kalıp tanıdık.

**10. 🔵 Ana ekrandaki erişim çipi sürekli görünür.** Deneme sayacı her
açılışta göz hizasında (`dashboard_screen.dart:231`). Son 7 güne kadar
gizlenmesi, kalan sürede uygulamanın kendi işine odaklanmasını sağlar.

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

**22. 🔵 Hap modu yalnız bir çip.** Hap paketi başlangıcı çip olarak
gösteriliyor (`dashboard_screen.dart:287`). Paketin kaçıncı günü, plasebo
dönemi ne zaman başlıyor — bu modun asıl sorusu bu.

**23. 🔵 TTC modunda "test zamanı" yok.** Gebelik testi için en erken
anlamlı gün (ovülasyon + 12) hesaplanabilir bir tarih ve TTC kullanıcısının
en beklediği bilgi.

**24. 🔵 Ana ekran sıralaması sabit.** Hangi bloğun üstte olacağı kullanıcıya
göre değişir (TTC ovülasyonu, hap kullanıcısı paketi ister). Ayarlarda basit
bir sıralama tercihi düşünülebilir.

---

## C. Kayıt akışı — uygulamanın asıl işi (25–38)

**25. 🔴 Kaydetmek en az üç dokunuş.** Ana ekran → "Kayıt ekle" → sheet →
seç → kaydet. Günlük tekrarlanan iş için fazla. Hafta şeridindeki güne uzun
basınca tek dokunuşla akış yoğunluğu girilebilmeli.

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

**29. 🟡 Kaydedilen şey geri bildirim vermiyor.** Kayıttan sonra "Kaydedildi"
snackbar'ı çıkıyor (`quick_log_sheet.dart:101`) ama ana ekranda ne değişti
görünmüyor. Hafta şeridindeki noktanın dolması gibi görünür bir iz gerekiyor.

**30. 🟡 Alışkanlık kurma mekaniği yok.** Seri (streak), haftalık doluluk
oranı gibi hafif bir geri bildirim, günlük kaydı sürdürmenin tek gerçek
motivasyonu. Sağlık uygulamasında agresif olmadan yapılabilir.

**31. 🟡 Semptom listesi uzun ve düzsüz.** Sık kullanılanlar öne alınmıyor.
Kullanıcının son 30 günde seçtiği semptomlar listenin başında olmalı.

**32. 🔵 Şiddet girilebiliyor ama görünürlüğü zayıf.** Semptom ekranında
1–5 arası şiddet seçilebiliyor; hızlı kayıt sayfası ise sabit 2 yazıyor ve
şiddet istatistiklerde kullanılmıyor.

*(İlk yazımda "semptom var/yok olarak kaydediliyor" demiştim, doğru değil —
`SymptomEntry.severity` var ve semptom ekranında beş noktalı seçici duruyor.
Kalan iş şiddeti hızlı kayda ve istatistiğe taşımak.)*

**33. 🟡 İlaç modeli günlük kayda bağlı.** İlaçlar günlük log içinde
tutuluyor ve hatırlatmalar en son ilaç içeren logdan okunuyor
(`main.dart:71-78`). Tekrarlayan bir ilaç aslında profile ait; bugünkü model
"dün girdiysem bugün de hatırlatılır" varsayımına yaslanıyor.

**34. 🟡 İlaç alındı bildirimden işaretlenemiyor.** Alındı kaydı tutuluyor
(`MedicationEntry.taken`, ilaç ekranında dokunulabilir) ama hatırlatma
geldiğinde uygulamayı açıp aynı işi elle yapmak gerekiyor.

*(İlk yazımda "alındı kaydı tutulmuyor" demiştim, doğru değil — alan da
ekrandaki geçiş de var. Eksik olan yalnız bildirim üzerinden işaretleme,
yani madde 69'un kapsamı.)*

**35. 🔵 Ölçümlerde birim tercihi yok.** Kilo ve sıcaklık tek birimde.
İngilizce/Almanca kullanıcı için lb ve °F beklentisi gerçek.

**36. 🔵 Not alanı arama ve tarih filtresi istemiyor.** Notlar tek gün
üzerinden yazılıyor (`notes_screen.dart`), geçmiş notlarda arama yok.

**37. 🔵 Toplu giriş yok.** Uygulamayı yeni kuran kullanıcı geçmiş 3 döngüsünü
girmek istiyor; şu an tek tek tarih seçmek zorunda.

**38. 🔵 Kayıt sonrası akış bitmiyor.** Kaydet sonrası ekranda kalınıyor.
Sheet kapanıp ana ekrana dönmek ve değişikliği orada göstermek daha temiz
bir kapanış.

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
çerçeve, o da CustomPainter istiyor.)*

**43. 🟡 Yıl görünümü yok.** 12 aylık kuş bakışı, düzensizliği tek bakışta
gösteren en güçlü görünüm — istatistikte yıl halkası var ama takvimde yok.

**44. 🔵 Uzun-bas önizlemesi keşfedilmiyor.** Güzel bir detay ama hiçbir yerde
öğretilmiyor. İlk kullanımda tek seferlik ipucu yeter.

**45. 🔵 Bugüne dönüş butonu yok.** Üç ay geriye kaydıran kullanıcı bugüne
elle dönüyor.

**46. 🔵 Çoklu gün seçimi yok.** "12–16 arası regldim" demek beş ayrı dokunuş.

**47. 🔵 Takvimden paylaşım yok.** Doktora göstermek için ay görünümünün
görüntüsünü almak yaygın bir ihtiyaç.

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

**54. 🔵 Semptom-faz ilişkisi tek yönlü.** Faz içgörüleri var ama tersi yok:
"baş ağrısı en çok hangi günlerde" sorusu cevapsız.

**55. 🔵 Kilo ve sıcaklık grafikleri döngüyle ilişkilendirilmiyor.** Bazal
sıcaklığın asıl anlamı ovülasyonla birlikte okunmasında.

**56. 🔵 Veri yoğunluğu göstergesi yok.** Hangi ayda ne kadar kayıt girildiği,
grafiklerin ne kadar güvenilir olduğunu anlatır.

**57. 🔵 Grafikten güne gidilemiyor.** Bir noktaya dokununca o günün kaydına
inmek beklenen davranış.

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

**64. 🔵 Mod değişiminin sonucu anlatılmıyor.** Hamilelik moduna geçince
tahminlerin duracağı önceden söylenmiyor.

**65. 🔵 Geri dönüş yok.** Kurulum sırasında önceki adıma dönmek mümkün mü
belirsiz; adım göstergesi var ama geri hareketi net değil.

**66. 🔵 Veri sıfırlama uyarısı korkutucu.** Kutular çözülemediğinde çıkan
uyarı (`onboarding_screen.dart:50`) teknik bir olayı kullanıcıya yüklüyor;
dili sadeleşmeli ve yedekten geri yükleme yolu aynı ekranda önerilmeli.

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
*Kısmen uygulandı:* ton tarafı yapıldı — tek bir "sessiz bildirimler"
anahtarı bütün türleri sessize alıyor (ses yok, açılır baloncuk yok,
bildirim yalnız gölgelikte durur). Gizlilik faydası da bu: kilit ekranında
öne çıkmayan bildirim yandaki kişiye görünmüyor. Uygulanırken bir tuzak
çıktı: Android'de kanalın önem derecesi kanal **oluşturulurken** sabitlenir,
sonradan gönderilen `importance` yok sayılır — sessiz sürüm kendi kanal
kimliğini kullanıyor, yoksa anahtar hiçbir şey değiştirmezdi.
*Yapılmayan:* sıklık ayarı. Bildirim türleri zaten ayrı ayrı açılıp
kapanabiliyor ve her tür döngüde bir kez gidiyor; "sıklık" burada
somut bir karşılığı olmayan bir istek. Somutlaşırsa yeniden bakılır.

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
*Bakıldı, yapılmadı:* bu maddeyi cihaz olmadan doğrulamak mümkün değil,
o yüzden tahmine dayalı bir "düzeltme" yazmadım. Yapısal bir engel de
bulamadım: kod tabanında yalnız iki `GestureDetector` var ve ikisi de
bilinçli — biri gizli moddan çıkış kapısı (klavyeyle erişilebilir
**olmamalı**), diğeri ring'in segment seçimi (aynı bilgi merkez içerikte
ve takvimde zaten var). Geri kalan her etkileşim `InkWell` ya da Material
butonu, yani odaklanabilir ve Enter/Space ile çalışır; odak sırası da
widget ağacı sırasını izliyor, o da görsel sırayla örtüşüyor. Gerçek
yargı için tablet + klavye gerekiyor.

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
*Düzeltme:* iki iddia da yanlıştı. **Tarih biçimi** sistem yerelinden
gelmiyor: her `DateFormat` uygulamanın etkin yerelini alıyor, o da profildeki
dil seçimini izliyor (`localeProvider` → `MaterialApp.locale`). Zaten
doğruydu. **Haftanın ilk günü** de sistem yerelinden gelmiyordu — sabit
pazartesiydi, yani verdiğim örneğin tersi oluyordu: hafta hiçbir zaman
pazar başlamıyordu. *Uygulandı:* gerçek eksik buydu ve düzeltildi —
İngilizce seçen kullanıcı ay adlarını kendi dilinde görürken takvim yine
pazartesiyle başlıyordu. Artık seçilen dilin kendi kuralı geçerli
(`MaterialLocalizations.firstDayOfWeekIndex`): İngilizcede pazar, Türkçe /
Almanca / İspanyolca / Fransızca / Rusçada pazartesi.

---

## I. Gizlilik, gizli mod, güvenlik (85–91)

**85. 🔵 Gizli mod keşfedilmiyor.** Uygulamanın en ayırt edici özelliği
ayarların içinde.

*(Önceliği düşürüldü: ayarlardaki satırın zaten açıklayıcı bir alt metni var
ve özellik paywall listesinde de geçiyor — "hiç anlatılmıyor" demek doğru
değildi. Kurulumda ayrı bir tanıtım adımı ise madde 58'in tersi yönde
çalışıyor. Gerçek çözüm kurulum akışının yeniden kurgulanmasıyla birlikte
düşünülmeli.)*

**86. 🟠 Kilit ekranı zaman aşımı yok.** Kilit yalnız arka plana alınınca
devreye giriyor (`app.dart:120-133`). "5 dakika sonra kilitle" seçeneği
beklenen davranış.

**87. 🟡 PIN kurtarma yolu yok.** PIN unutulursa tek çıkış verinin silinmesi;
bu, kurulum sırasında açıkça söylenmeli.

**88. 🟡 Sahte (decoy) ekran inandırıcı değilse riskli.** Not defteri kılığı
gerçek not tutabiliyor mu, boşsa şüphe çeker. Kılık modu birkaç örnek notla
gelmeli.

**89. 🟡 Yedek dosyası şifresiz.** Hive kutuları cihazda şifreli ama dışa
aktarılan yedek düz JSON. En hassas veri en korumasız hâlde cihazdan çıkıyor;
parolalı yedek seçeneği gerekiyor.

*(Kısmen ele alındı: dışa aktarmadan önce dosyanın şifresiz olduğunu ve
içeriğini söyleyen bir onay adımı eklendi. Parolalı yedeğin kendisi
yapılmadı — kriptografi derlenemeyen ve test edilemeyen bir ortamda
yazılacak son şey; ayrı, gözden geçirilebilir bir tur istiyor.)*

**90. 🔵 Ekran görüntüsü koruması yalnız kilitliyken.** `FLAG_SECURE` kilit
gerektiğinde açılıyor; kilit kullanmayan kullanıcı da bu korumayı isteyebilir.

**91. 🔵 Veri silme geri alınamaz ama tek onaylı.** Yazarak onay
(ör. "SİL" yazmak) bu ağırlıktaki işlem için standart.

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

**96. 🔵 Veri politikası uygulama içinde özetlenmemiş.** Gizlilik metni tam
sayfa; "hiçbir veri cihazdan çıkmaz" cümlesi ayarların en üstünde tek satır
olarak durmalı.

---

## K. Sistem entegrasyonu ve bitirme (97–100)

**97. 🟡 Widget'tan kayıt yapılamıyor.** İki widget boyu da salt görüntüleme.
"Reglim başladı" widget üzerinden tek dokunuşla girilebilse, uygulamanın en
sık işi uygulamayı açmadan biterdi.

**98. 🟡 Kısayol menüsü yok.** Uygulama ikonuna uzun basınca "hızlı kayıt" ve
"bugünü gör" kısayolları (Android shortcuts / iOS quick actions) düşük
maliyetli, yüksek kullanımlı.

**99. 🔵 Tablet düzeni yalnız gezinme çubuğunda ele alınmış.** 600 px üstünde
yan rail'e geçiliyor (`app_shell.dart:47`) ama içerik hâlâ tek kolon; geniş
ekranda ana ekran ve takvim yan yana durabilirdi.

**100. 🔵 Boş durum dili ekranlar arasında tutarsız.** `EmptyState` bileşeni
var ama her ekran kullanmıyor — istatistikteki boş kartlar kendi metnini
yazıyor. Tek bileşene bağlanması hem tutarlılık hem bakım kolaylığı.

---

## Nereden başlamalı

Sırayla üç şey, gerisi bekleyebilir:

1. **Madde 1 ve 2** — ücretsiz kullanıcının kaydını düzeltebilmesi ve geriye
   dönük tarih girebilmesi. Bunlar olmadan uygulamanın temel işi güvenilmez.
2. **Madde 75, 76, 77** — kontrast ve metin ölçekleme. Erişilebilirlik
   kusuru hem kullanıcı kaybı hem mağaza incelemesinde risk.
3. **Madde 11, 12, 13** — ana ekranın "ne zaman?" sorusuna tek bakışta cevap
   verecek şekilde sadeleşmesi.
