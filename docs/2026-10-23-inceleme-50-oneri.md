# Regl Takip — ayrıntılı inceleme ve 50 öneri

> Sonraki uygulama çalışmasının madde madde durumu: [50 önerinin düzeltme durumu](2026-10-23-duzeltme-durumu.md). Aşağıdaki ilk inceleme, başlangıç bulgularını ve o aşamadaki dil çalışmasını tarihsel olarak korur.

23 Ekim 2026. İncelenen başlangıç sürümü: `ba87786cce2f256604180e009d846fdbbfab90d1` (`main`).

Bu rapor kaynak kodu, veri modelleri, Android/iOS yapılandırmaları ve otomatik testler üzerinden hazırlanmıştır. “Bulgu” mevcut kodda görülen davranışı, “geliştirme” ürün fırsatını, “doğrulama” gerçek cihaz veya mağaza ortamında sınanması gereken durumu belirtir. Bunların tamamı cihazda yeniden üretilmiş 50 hata değildir. Gerçek Play/App Store satın alımı, OEM pil yönetimi, Health Connect/HealthKit izin ekranları ve iOS görsel davranışları burada uçtan uca doğrulanmadı.

P0: veri güvenliği/veri kaybı açısından önce ele alınmalı. P1: sonraki sürüm önceliği. P2: sonraki iyileştirme. “Bu değişiklikte” yalnız aşağıda açıkça belirtilen dil çalışması ve bağlantılı düzeltmeler uygulanmıştır.

Uygulamanın güçlü tarafları: cihazda şifreli Hive depolama, Argon2id + AES-GCM yedekleme, PIN deneme sınırlaması, sistem teması, azaltılmış hareket desteği, geri alma akışları, salt okunur geçmiş ve kapsamlı birim/widget testleri mevcut. Öneriler bu altyapının üzerine kuruludur.

## 1–10: Gizlilik ve veri bütünlüğü

1. **P0 · Bulgu — Şifreleme geçişini atomik yap.** `lib/services/hive_service.dart::_migrateToEncrypted` eski kutuları silip yenilerini dolduruyor; `_writeSafetySnapshot` hatası yalnız loglanıyor. Disk dolduğunda güvenlik kopyası alınamasa da silme devam edebilir. Yeni şifreli kutuları ayrı adlarla yaz, kayıt sayılarını doğrula ve en son geçiş yap. Kabul: her yazma aşamasında hata enjekte edildiğinde eski veriler açılabilsin.

2. **P0 · Bulgu — Şifreleme başarısızlığını kullanıcıya görünür kıl.** Aynı serviste migration hatası `_openPlainBoxes` yoluna düşüyor. Uygulama çalışır görünürken sağlık verileri şifresiz kalabilir. Güvenli bir kurtarma ekranı ve yeniden deneme sun; sessizce düz metinle çalışmayı sürdürme. Kabul: şifreleme durumu açıkça bilinsin, şifresiz kutuların varlığı otomatik testte yakalansın.

3. **P0 · Bulgu — Kurtarma başarısızlığında özgün dosyayı koru.** `HiveService._quarantineBoxes`, yeniden adlandırma başarısız olduğunda `Hive.deleteBoxFromDisk` çağırıyor. Son kurtarma yolu da `crashRecovery: true`. Okunamayan dosyanın bir kopyası alınmadan silme/budama yapma. Kabul: kilitli dosya ve yanlış anahtar senaryolarında özgün baytlar korunabilsin.

4. **P0 · Bulgu — Yedek geri yüklemeye işlem bütünlüğü ekle.** `lib/services/backup_service.dart::restoreBackup` önce `clearAll`, sonra tek tek yazma yapıyor. İşlem yarıda kesilirse mevcut ve geri yüklenen veriler eksilebilir. Hazırlık alanı + doğrulama + tek geçiş veya geri dönüşlü kurtarma kaydı kullan. Kabul: yarıda kapanma sonrası ya eski ya tam yeni veri açılsın.

5. **P0 · Bulgu — Yedeklerde sayısal alanları da doğrula.** `UserProfile.fromJson` döngü uzunluğu, su hedefi ve saat alanlarını tip açısından okuyor ama geçerli aralıklara bakmıyor. `cycleLength=0`, `dayInCycleFor` gibi modulo hesaplarını bozabilir. Şema doğrulamasını veri silinmeden önce yap. Kabul: sıfır/negatif döngü, saat 99 ve uygunsuz ölçümler mevcut veriye dokunmadan reddedilsin.

6. **P1 · Bulgu — Çakışan ve tekrarlanan yedek kayıtlarını raporla.** `BackupService.parseBackup` kayıt kimliklerini, aynı tarihli günlükleri ve çakışan regl aralıklarını topluca kontrol etmiyor; Hive anahtarları bazı kayıtları ezebilir. İçe aktarma önizlemesinde korunacak/atlanacak kayıt sayılarını göster. Kabul: aynı kimlikli iki kayıt sessizce veri kaybettirmesin.

7. **P0 · Bulgu — Bildirim eylemlerinde kilit ve gizli mod kontrolünü ortaklaştır.** `lib/app.dart::_onNotificationAction`, widget ve hızlı eylem yollarındaki kilit/kurulum/gizli mod denetimlerini yapmadan yazabiliyor. Eylemi kilit açılana kadar sırada tut. Kabul: kilitliyken “Reglim başladı” veya “Aldım” hiçbir sağlık kaydını değiştirmesin.

8. **P1 · Bulgu — Geçici dışa aktarım dosyalarını temizle.** `ExportService` ve `BackupService.exportBackup` geçici dosya oluşturuyor; uygulamaya ait eski çıktılar için süreli temizlik görünmüyor. Özellikle CSV/PDF düz metin sağlık içeriği taşır. Kabul: paylaşım tamamlandıktan güvenli bir süre sonra uygulamanın eski çıktıları temizlensin; açık paylaşım dosyası erken silinmesin.

9. **P1 · Geliştirme — iOS uygulama değiştirici önizlemesini ayrıca koru.** `PrivacyScreenService.isSupported` yalnız Android'i kapsıyor. iOS için arka plan örtüsü ekle ve ayarlarda platformun gerçekten sağladığı korumayı açıkla. Kabul: arka plana geçiş videosunda hassas ekran görünmesin; ekran görüntüsü engelleme konusunda tutulamayacak vaat verilmesin.

10. **P1 · Bulgu — PIN kaydındaki işlem maliyetini sınırla.** `lib/core/utils/pin_utils.dart::verifyPin`, saklanan PBKDF2 tur sayısına yalnız `>0` kontrolü yapıyor. Bozuk/çok büyük tur değeri doğrulama isolate'ını uzun süre meşgul edebilir. Desteklenen sürüm, tuz/hash uzunlukları ve makul tur üst sınırı denetlensin. Kabul: aşırı büyük tur sayısı hızla reddedilsin; eski PIN geçişi çalışmaya devam etsin.

## 11–20: Abonelik, reklam ve bildirimler

11. **P0 · Bulgu — Satın alma hakkını güvenilir sunucuda doğrula.** `lib/services/premium_service.dart::_onPurchaseUpdates`, `purchased/restored` olayını alınca doğrudan premium açıyor; makbuz/token doğrulaması yok. Google Play Developer API/App Store doğrulaması veya bu işi yapan bir servis ekle. Kabul: sahte, iptal veya iade edilmiş satın alma premium vermesin.

12. **P1 · Bulgu — 35 günlük tahmini abonelik kontrolünü gerçek hak durumuyla değiştir.** `PremiumService.init` son doğrulama zamanına ve 10 saniyelik beklemeye dayanıyor. Yıllık/ömür boyu hak, ağ kesintisi ve gecikmiş mağaza yanıtı aynı heuristikle ele alınıyor. Ürün türü, bitiş, iade ve grace period ayrı yönetilsin. Kabul: yıllık abone çevrimdışı kalınca yanlışlıkla ücretsiz sayılmasın.

13. **P1 · Bulgu — Satın alma için tek bir durum makinesi kullan.** Paywall `_buy` mağaza akışını başlatınca `_busy` temizliyor; servis pending/error/canceled durumlarını arayüze taşımıyor. Başlatılıyor, bekliyor, doğrulanıyor, başarılı ve iptal durumlarını yayınla. Kabul: bekleyen ödeme ikinci satın almayı başlatmasın; hata anlaşılır şekilde görülsün.

14. **P0 · Bulgu — Reklam isteğinden önce `canRequestAds()` kontrolü yap.** `lib/services/ad_service.dart` rıza akışındaki hata/zaman aşımından sonra da initialize/load yoluna devam edebiliyor. UMP sonucunu reklam yükleme kapısında doğrula. Kabul: rıza durumu uygun değilken reklam isteği oluşmasın; uygulama reklamsız çalışsın.

15. **P1 · Geliştirme — Reklam gizlilik tercihlerini yeniden açma seçeneği ekle.** Ayarlar ekranında UMP gizlilik seçenekleri girişi görünmüyor. UMP'nin gerektirdiği durumda görünür bir giriş sun. Kabul: kullanıcı önceki reklam tercihini değiştirebilsin ve sonraki istekler yeni duruma uysun.

16. **P1 · Bulgu — Eski ilaç bildirimini bugüne yazma.** `_onNotificationAction`, ilaç eyleminde `DateTime.now()` kullanıyor ve payload yalnız isim. Dünkü bildirime bugün basılması bugünün kaydını değiştirebilir. Payload'a plan kimliği ve hedef gün ekle. Kabul: gece yarısı sonrası eski bildirim doğru güne uygulansın veya kullanıcıdan seçim istensin.

17. **P1 · Bulgu — Aynı adlı farklı ilaçları ayır.** Aynı eylemde ad eşleşen tüm ilaçlar alınmış işaretleniyor. `MedicationEntry` için kalıcı kimlik ve doz/zaman bazlı tek hedef kullan. Kabul: aynı isimli sabah ve akşam dozundan yalnız seçilen doz işaretlensin.

18. **P1 · Bulgu — Dil değişiminde bildirimleri yeniden planla.** `UserProfileNotifier.saveProfile` koşullarında dil yoktu; eski bildirim metinleri kalabiliyordu. **Bu değişiklikte düzeltildi:** dil ve dakika alanları yeniden planlamayı tetikliyor; yeniden planlama kişisel içgörü günlüklerini de taşıyor. Kabul: dil değişiminden sonraki kurulu bildirimler yeni dili kullansın.

19. **P1 · Geliştirme — Cihaz dili ve saat dilimi değişimini canlı izle.** `NotificationService.init` saat dilimini bir kez kuruyor; uygulama kökünde cihaz dili değişimi için servisleri yenileyen bir akış görünmüyor. Sistem tercihi kullanan profilde dil/saat dilimi değişince widget ve bildirimleri yenile. Kabul: uygulamayı yeniden kurmadan seyahat ve dil değişimi doğru saatte/doğru dilde sonuç versin.

20. **P1 · Doğrulama — Yeniden başlatma ve pil kısıtı test matrisi oluştur.** Manifestte boot receiver var; planlamalar `inexactAllowWhileIdle`. Bunun Samsung/Xiaomi gibi cihazlarda gerçekten çalışması cihaz testi gerektirir. Kabul: yeniden başlatma, izin reddi, zorla durdurma ve pil kısıtı durumlarında beklenen davranış belgelenmiş olsun; kesin dakika vaadi verilmesin.

## 21–30: Tahminler ve sağlık verilerinin anlamı

21. **P1 · Bulgu — Gecikmiş döngüyü otomatik yeni döngü gibi sunma.** `CycleUtils.wrappedCycleDay` süre dolunca günü başa sarıyor; `getCurrentPhase` de bunu kullanıyor. Kayıtlı yeni regl yokken faz “yeniden başladı” izlenimi verebilir. Gecikme/azalan güven durumunu ayrı göster. Kabul: 28 günlük profil 40. günde kayıtsızsa kesin yeni faz gösterilmesin.

22. **P1 · Bulgu — Takvim günü hesaplarını yaz saati geçişlerinden ayır.** `currentCycleDay`, `validCycleGaps`, `PeriodRecord.durationDays` ve benzeri yerler yerel tarih farkında `inDays` kullanıyor. 23 saatlik bir gün bir gün eksik hesaplanabilir. Takvim farkını UTC yıl/ay/gün üzerinden hesaplayan ortak yardımcı kullan. Kabul: Avrupa yaz saati başlangıç/bitiş testleri doğru gün sayısını versin.

23. **P1 · Bulgu — BBT sonucunu “kesin doğrulama” diye sunma.** `detectOvulationFromBBT` bir sıcaklık örüntüsü buluyor; `ovulationConfirmedInfo` ise “tahmin değil” diyor. Ölçüm, ateş, uyku ve örnekleme sınırlamalarını açıkça belirt; “örüntüyle uyumlu” gibi daha doğru bir sunum kullan. Kabul: kullanıcı bunu klinik tanı veya korunma garantisi sanmasın.

24. **P1 · Bulgu — BBT algoritmasına ölçüm kalitesi ekle.** Yükselen üç günün ardışıklığı denetleniyor ama önceki altı ölçümün gün aralıkları ve hastalık/uyku gibi bozucu etkenler değerlendirilmeden kullanılıyor. Ölçüm kalite işaretleri ve örneklem yeterliliği sun. Kabul: aralıklı veya ateşli günlerden otomatik güçlü sonuç üretilmesin.

25. **P1 · Bulgu — Faz tavsiyelerini tıbbi editörle gözden geçir.** ARB'lerde ağrı kesicilerle eşdeğerlik, hormonlara bağlı kesin ruh hâli/performans ve ovülasyon penceresine göre korunma çağrışımlı metinler var. Kaynak, gözden geçirme tarihi ve bireysel farklılık ekle. Kabul: tavsiyeler uygulamanın “korunma yöntemi değildir” uyarısıyla çelişmesin.

26. **P1 · Geliştirme — Hap planını 21+7 ile sınırlama.** `CycleUtils.pillDayInPack` 28 gün, `pillIsBreak` 21 aktif gün varsayıyor. Kullanıcının gerçek reçetesine göre 24+4, sürekli kullanım ve özel plan seçimi sun; plan değişikliği sağlık tavsiyesi vermesin. Kabul: plan açıkça kullanıcı tarafından seçilsin, yanlış otomatik ara önerilmesin.

27. **P1 · Bulgu — Sağlık platformuna yazmanın sonucunu denetle.** `HealthSyncService.syncPeriods`, `writeMenstruationFlow` dönüşünü kontrol etmeden son aktarım gününü ilerletiyor. Başarısız yazma başarı sayılabilir. Başarısız günleri sakla ve yeniden dene. Kabul: sahte servisten `false` döndüğünde başarı bildirimi/ilerleyen watermark oluşmasın.

28. **P1 · Bulgu — Health Connect'e her günü orta akış olarak yazma.** Aynı metot tüm günler için `MenstrualFlow.medium` kullanıyor; günlükteki gerçek yoğunlukları almıyor. Mevcut akış verisini eşle, bilgi yoksa bunu koruyan bir temsil kullan. Kabul: hafif veya çok yoğun kaydedilen gün başka uygulamada orta akışa dönüşmesin.

29. **P1 · Bulgu — Sağlık senkronizasyonunda geçmiş düzeltmelerini destekle.** Tek `health_last_synced_day` değeri, bu tarihten eski eklenen/düzeltilen kayıtları atlıyor. Kayıt kimliği/sürümüne dayalı senkronizasyon ve silme politikası kullan. Kabul: geçmiş aya eklenen regl bir sonraki aktarımda kaybolmasın; tekrarlar oluşmasın.

30. **P2 · Geliştirme — Kullanıcıya tahmin hatasını göster.** Akıllı döngü hesabı son altı geçerli aralığın ortalamasını kullanıyor; tek tarih yerine geçmiş tahmin/gerçekleşme farkına dayalı belirsizlik aralığı sunulabilir. Kabul: yeterli veri yokken geniş aralık/az güven gösterilsin; kişisel başarı ölçümü en az birkaç döngüye dayansın.

## 31–40: Raporlama ve çok dillilik

31. **P1 · Bulgu — Dışa aktarımlara ölçü birimi ekle.** `ExportService` sıcaklık ve kiloyu çıplak sayı yazıyor; `usePounds/useFahrenheit` tercihi raporda açık birime dönüşmüyor. Kaydedilen temel birimi veya dönüştürülmüş birimi başlığa yaz. Kabul: 60,0 değerinin kg mı lb mi olduğu çıktıdan anlaşılabilsin.

32. **P1 · Bulgu — Doktor raporunda notları sessizce kesme.** `_buildDailyLogTable` notları 30 karakterde kesiyor. Tıbbi görüşmede en gerekli ayrıntı eksilebilir. Tam metni ek bölümde veya sarılan hücrede koru. Kabul: uzun ve emoji içeren notlar tam ve bozulmadan dışa çıksın.

33. **P1 · Bulgu — CSV'ye regl kayıtlarını da dahil et.** `exportCsv` `periods` parametresini alıyor ama kullanmıyor; yalnız günlükleri yazıyor. Günlük tutulmamış gerçek regl tarihleri CSV'de kaybolabilir. Ayrı kayıt bölümü/dosyası veya açık tür sütunu kullan. Kabul: sadece regl başlangıcı/bitişi kaydetmiş kullanıcının CSV'si boş veri içermesin.

34. **P2 · Geliştirme — Rapor aralığını ekrandaki filtreyle tutarlı yap.** PDF tüm regl geçmişini ve yalnız son 30 gün günlüklerini kullanıyor. İstatistik ekranında farklı aralık seçen kullanıcı için rapor kapsamı şaşırtıcı olabilir. Rapor önizlemesinde aralık ve dahil edilen alanları seçtir. Kabul: 6 aylık seçimin hangi verilere uygulandığı açıkça görülsün.

35. **P1 · Geliştirme — Uzun rapor ve uzun not sınırlarını test et.** PDF tek `MultiPage` ve uzun tablolarla üretiliyor. Çok yıllı veri, uzun ilaç adları ve az bellekli telefonlarda süre/sayfa sınırları ölçülmeli. Kabul: 10 yıllık sentetik geçmiş çıktı verebilsin veya kullanıcıya anlaşılır parçalara bölme seçeneği sunulsun.

36. **P1 · Bulgu — Hedef sekiz dilin tüm kaynaklarını tamamla.** Başlangıçta TR/EN/ES/DE/FR/RU vardı; PT/AR/HI/ZH yoktu. **Bu değişiklikte eklendi:** her yeni dilde 637 mesaj, dil seçimi, bildirimlerin ortak çeviri kaynağı, widget metinleri ve iOS dil listesi. Türkçe/Rusça korundu; toplam 10 dil var. Çince basitleştirilmiş, Portekizce ağırlıkla Brezilya kullanımındadır; bu seçim kesin bir dünya “ilk sekiz” sıralaması iddiası değildir.

37. **P1 · Bulgu — Desteklenmeyen cihaz dilini İngilizceye tutarlı düşür.** Üretilen locale listesi alfabetik; Arapça eklenince varsayılan ilk dil Arapça olabilir, servisler ise İngilizce kullanır. **Bu değişiklikte düzeltildi:** arayüz ve servisler ortak, sıralı dil tercihi çözümleyicisi kullanıyor. Kabul: Japonca cihazda uygun ikinci tercih yoksa İngilizce açılsın.

38. **P1 · Bulgu — Yeni alfabeler için çevrimdışı font ve RTL desteği ekle.** Nunito tek başına Arapça/Devanagari/Çince kapsamıyor. **Bu değişiklikte:** lisanslarıyla gömülü Noto fontları, PDF font yedekleri, Arapça PDF yönü ve temel yönsel hizalamalar eklendi. Kabul: internet olmadan harfler görülsün. Hindi PDF'de birleşik harf şekillendirmesi ve karışık yönlü metin gerçek çıktıdan ayrıca görsel kontrol gerektirir; font bulunması tek başına tipografik doğruluk kanıtı değildir.

39. **P1 · Geliştirme — Yeni dilleri ana dil editörüne denetlet.** Çeviriler otomatik üretildi; 76 bağlama duyarlı metin/dil ve ek bildirim metinleri elle düzeltildi. Sağlık, ödeme, gizlilik ve geri yükleme ifadelerinde uzman ana dil kontrolü hâlâ gerekir. Kabul: tutarlı terim sözlüğü, ekran görüntüsüyle editör onayı ve taşma düzeltmeleri tamamlansın.

40. **P1 · Bulgu — Çoğul, sayı ve yasal içerik kapsamını tamamla.** ARB'lerde pek çok sayaç düz `{count}` metni; hizmetler ve ekranlarda elle sayı birleştirme var. ICU çoğul kuralları ve yerel sayı biçimi kullan; TR/EN ile sınırlı gizlilik politikasını hedef dillere profesyonelce yerelleştir. Kabul: Arapça 0/1/2/3/11 ve Hindi/Çince sayıları anlamlı olsun; kullanıcı politikanın hangi dilde olduğunu önceden bilsin.

## 41–50: Kullanım deneyimi, performans ve kalite

41. **P1 · Geliştirme — Açılış hatalarında kurtarma ekranı göster.** `main.dart::_run`, Hive/QuickAction/Widget/Preferences hazırlığını `runApp` öncesinde bekliyor. Başlangıç eklentisi veya secure storage hatası için ortak görünür kurtarma akışı ekle. Kabul: depolama erişimi engellendiğinde beyaz ekran/sonsuz splash yerine anlaşılır yeniden deneme ve veri kurtarma seçeneği olsun.

42. **P1 · Doğrulama — Eşzamanlı günlük kayıtlarını sınırla.** Günlük modelinin alanları değiştirilebilir; provider güncellemeleri aynı gün nesnesini birden fazla ekrandan/bildirimden değiştirebilir. Gün başına seri yazma veya değişmez kopya yaklaşımı kullan. Kabul: su artırımı ile ilaç bildirimi aynı anda geldiğinde iki değişiklik de saklansın; bunu hata enjekte edilen testle göster.

43. **P2 · Geliştirme — Uzun geçmişte hesaplamaları profil çıkararak iyileştir.** Hive tüm günlükleri listeye alıyor; istatistikler ve içgörüler tekrar tarıyor. Önce 10 yıllık sentetik veriyle açılış, filtre değiştirme ve çizim süresini ölç; pahalı özetleri aralık bazlı önbellekle. Kabul: hedef düşük donanımlı telefonda ana etkileşimler akıcı kalsın; iyileştirme ölçüme dayansın.

44. **P1 · Bulgu — PR'larda kalite kontrolünü otomatik çalıştır.** `.github/workflows/android-apk.yml` benzeri APK akışı manuel veya belirli eski dal push'uyla çalışıyor; genel `pull_request` tetikleyicisi yok. Release oluşturmayan ayrı analiz/test kontrolü ekle. Kabul: herhangi bir PR'ın yerelleştirme üretimi, analiz ve test sonucu görünür olsun.

45. **P1 · Bulgu — Analiz uyarılarını gerçekten kapı yap.** APK akışında `--no-fatal-infos --no-fatal-warnings` kullanılıyor. Yeni uyarıların sessiz birikmesini engellemek için temiz analiz veya kontrollü bir mevcut-bulgu listesi kullan. Kabul: eklenen geçersiz kullanım ve uyarılar PR kontrolünü düşürsün.

46. **P1 · Bulgu — SDK gereksinimini gerçek minimumla hizala.** `pubspec.yaml` Dart `^3.0.0` diyor; kilitli bağımlılıklar en az Dart 3.10/Flutter 3.35 istiyor, CI Flutter 3.44.8 kullanıyor. Minimum SDK'yı açıkça belirt ve geliştirici kurulumuna sürüm sabitle. Kabul: eski SDK'da anlaşılır sürüm hatası alınsın; CI ile yerel üretim aynı sonucu versin.

47. **P1 · Doğrulama — Mağaza yaşam döngüsü testlerini ekle.** Test klasöründe yardımcı ve widget testleri var; gerçek satın alma/yenileme/iade süreci uçtan uca kapsanmıyor. Play lisans testçisi ve StoreKit sandbox ile pending, iptal, yenileme, iade ve cihaz değişimi senaryolarını çalıştır. Kabul: ödeme ve hak durumu her senaryoda uyuşsun.

48. **P1 · Doğrulama — Ekran okuyucuda grafik anlamını test et.** Bazı `Semantics` etiketleri mevcut ama özel ring/çizimler ve takvim işaretleri yalnız renkle anlam taşıyabilir. TalkBack/VoiceOver'da gün, gerçek/tahmin, seçili durum ve eğilim için metinsel karşılık sağla. Kabul: ekran görünmeden aynı temel takip işi tamamlanabilsin.

49. **P1 · Doğrulama — Dil × dar ekran × büyük yazı matrisi oluştur.** Mevcut adaptif yerleşim testlerine Arapça, uzun Almanca, Hindi, 320 px genişlik, %200 yazı ve klavye açık durumunu ekle. Özellikle dil seçici, onboarding ve üç tahmin kartı kontrol edilsin. Kabul: hiçbir temel düğme kırpılmasın, erişilemez kalmasın veya başka içerikle üst üste binmesin.

50. **P2 · Geliştirme — Premium dönüşümünü hassas veri toplamadan ölç.** 30 günlük deneme ve sonrasında günlük kayıt kapısı var. Kullanıcıların nerede bırakıp nerede satın aldığını yalnız toplu ürün olaylarıyla ölç; semptom, regl tarihi, not, ilaç ve kimlik bilgisi gönderme. Kabul: açık tercih ve veri minimizasyonuyla onboarding tamamlama, deneme kullanımı, paywall görüntüleme ve doğrulanmış satın alma dönüşümü görülebilsin; fiyat/teklif kararları bu veriye dayansın.

## Uygulanan değişikliklerin kapsamı

- Önceden bulunan altı dil korundu; Portekizce, Arapça, Hintçe ve basitleştirilmiş Çince eklendi. Böylece hedeflenen EN/ES/FR/DE/PT/AR/HI/ZH yanında TR ve RU da bulunuyor.
- Ekran korumasının kod içinde ayrı tutulan başlık/açıklaması ortak ARB kaynaklarına taşındı. Her dilde 637 mesaj var.
- Desteklenmeyen cihaz dili için İngilizce geri dönüşü arayüz/servisler arasında ortaklaştırıldı. Uygulama içi pencere başlığı yerelleştirildi.
- Dil ve bildirim dakikası değişimleri yeniden planlamayı tetikliyor; içgörü günlükleri korunuyor.
- Widget metinleri, iOS dil bildirimi, çevrimdışı fontlar ve temel RTL hizalamaları genişletildi.
- Mesaj/placeholder kapsamı ve yeni dört dilin platform çevirileri/yönü için otomatik kontroller eklendi.

Bu çalışma 50 önerinin tamamını uygulamış değildir. İlk sırada 1, 3, 4, 5, 7, 11 ve 14 ele alınmalı; ardından abonelik durumları ve Health senkronizasyonu düzeltilmelidir.

## Teknik kaynaklar

- Flutter yerelleştirme: https://docs.flutter.dev/ui/internationalization
- Google Play satın alma güvenliği: https://developer.android.com/google/play/billing/security
- Google Play test ortamı: https://developer.android.com/google/play/billing/test
- AdMob UMP ve canRequestAds: https://developers.google.com/admob/flutter/privacy
- ACOG, fertilite farkındalığı: https://www.acog.org/womens-health/faqs/fertility-awareness-based-methods-of-family-planning

Yukarıdaki kaynaklar teknik/sağlık metinlerinin değerlendirilmesine dayanak sağlar; uygulamanın klinik veya hukuki uygunluk onayı anlamına gelmez.

## Doğrulama sonuçları

- Flutter 3.44.8 ile yerelleştirme kaynakları yeniden üretildi.
- Mevcut testler ve yeni dil kapsamı/yön testleri: 279/279 başarılı.
- Dört yeni dilde çevrimdışı fontlarla PDF dosyası üretimi: 4/4 başarılı. Toplam 283 başarılı kontrol.
- Statik analiz: No issues found.
- git diff --check: temiz.
- PDF testleri dosyanın üretilebildiğini doğrular; birleşik harflerin ve karışık yönlü satırların görsel doğruluğunu kanıtlamaz.
- Gerçek cihaz ve gerçek mağaza uçtan uca kontrolleri yapılmadı.
