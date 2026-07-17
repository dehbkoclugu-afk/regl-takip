# Regl Takip — Kapsamlı İnceleme Raporu

**Tarih:** 2026-07-16/17 · **İncelenen sürüm:** `58114d4` (v1.1.0+7, sayfa denetimi sonrası)
**Mercekler:** taste-skill (Leonxlnx, aktarılabilir prensipler) · impeccable critique (product register + Android/M3) · Emil Kowalski motion prensipleri · karpathy-guidelines (kod zevki)
**Yöntem şerhi:** impeccable'ın deterministik dedektörü (`detect.mjs`) ve tarayıcı overlay'i web-only; bu Flutter projesinde uygulanamaz. Yerine `flutter analyze` + 100 birim test + satır satır sistematik okuma kullanıldı (tek bağlam, alt-ajan yok). taste-skill kendi kapsamını landing page/portfolio olarak tanımlar ve "native mobile"ı kapsam dışı bırakır; buradan yalnız aktarılabilir prensipleri (tutarlılık kilitleri, AI-tell denetimi, motion gerekçesi, copy denetimi, durum döngüleri) uygulandı.
**Kural:** Bu rapor yorum içindir — hiçbir bulgu bu geçişte düzeltilmedi. Dünkü sayfa denetiminde (14 commit) düzeltilen konular yeniden bulgu yazılmadı; ama o denetimin eklediği kodun kendisi eleştiriye tabi tutuldu.

**Önem tanımları:** **P0** veri kaybı / güvenlik / çökme · **P1** işlev bozukluğu · **P2** UX sürtünmesi veya mimari borç · **P3** cila

---

## 1. Yönetici özeti

**Genel sağlık: İyi (Nielsen 29/40).** Dünkü sayfa denetiminden geçmiş UI katmanı temiz, erişilebilir ve tutarlı; uygulamanın gerçek riskleri artık görünen katmanda değil, **veri yaşam döngüsünde**: yedekten dönüş, tarih düzeltme, kilit davranışı ve geri-alınamazlık. 1 P0, 6 P1, ~25 P2, ~20 P3 bulgu.

**En kritik 5 bulgu:**

| # | Bulgu | Neden kritik |
|---|---|---|
| **S-1 (P0)** | `allowBackup` varsayılanı + Keystore'a bağlı AES anahtarı: cihaz değişiminde uygulama **açılmaz çökme döngüsüne** giriyor | Telefon değiştiren her kullanıcı; kurtuluş = tüm veriyi silmek |
| **S-2 (P1)** | Şifreleme migrasyonunun düz metin anlık görüntüsü (`pre_encryption_backup.json`) **süresiz diskte** | AES şifrelemesinin vaadini tek dosya boşa düşürüyor; auto-backup ile buluta da gidiyor |
| **B-1 (P1)** | Kilit `inactive`'te tetikleniyor VE ekran ağacını söküyor: bildirim çekmecesine bakmak = PIN + yazılan her şeyin kaybı | PIN kullanan herkesin günde onlarca kez yaşadığı sürtünme |
| **B-8 (P1)** | Son regl tarihini geriye düzeltmek kayıtları bozuyor (kırpılmış/çift kayıt); regl kayıtları hiçbir yerden düzenlenemiyor/silinemiyor | Yanlış veri kalıcılaşıyor; tahmin motoru bozuk girdiyle çalışıyor |
| **U-4 (P1)** | "Reglim başladı" onaysız, geri alınamaz; yanlış dokunuş geçmişi ve ortalamaları bozuyor | En değerli veri, en korunmasız etkileşimin arkasında |

**Eksen karneleri (tek cümle):**
- **Kod mimarisi:** Katman yönleri doğru, sınıflandırma net; borç kopyalarda (tema ×2, tracker iskeleti ×10, üç renk kaynağı) ve DI ikiliğinde.
- **Bug:** Çekirdek matematik testli ve sağlam; hatalar birleşim noktalarında (profil↔kayıt senkronu, kilit×yaşam döngüsü, yedek×Keystore).
- **UI/UX:** 29/40 — anlatım ve tanıma güçlü (4), kontrol/önleme/kurtarma zayıf (2); kontrastta tek desenli sistematik açık (pastel token = metin).
- **Frontend:** Rebuild disiplini kabul edilebilir, motion altyapısı örnek; ring painter'ın bayat raster'ı tek gerçek teknik hata.
- **Backend:** En zayıf eksen — şifreleme hattının kenar durumları (S-1/S-2), bildirim kapsam boşlukları (S-4/S-9), dışa aktarım fidelity kaybı (S-6).

**Tek cümlelik verdik:** Bu uygulama "özenli jenerik" ile "güvenilir ürün" arasındaki çizgide; çizgiyi geçirecek olan yeni özellik değil, veri güvenliği dörtlüsü (S-1, S-2, B-8+U-4, B-9) ve kontrast taramasıdır.

---

## 2. Metrikler

| Metrik | Değer |
|---|---|
| Kaynak Dart dosyası (üretilen hariç) | 35 |
| Kaynak satır (lib/, üretilen hariç) | ~11.500 |
| En büyük 5 dosya | settings_screen 838 · statistics_screen 776 · onboarding_screen 732 · dashboard_screen 708 · providers 495 |
| Üretilen kod | l10n 3.820 sat. · Hive adapters ~830 sat. |
| Test | **100/100 yeşil** (cycle_utils 30+, smart prediction, tracking mode, pin_utils 7, input_parsing 5, daily_log provider 3, hive migration, 1 smoke) |
| flutter analyze | **No issues found** (83,7 sn) |
| l10n | TR/EN anahtar eşliği 400/400 (önceki denetimde doğrulandı) |

**Test kapsamı boşlukları (önem sırasıyla):** (1) `HiveService.init` hata yolları — S-1'deki çökme döngüsü tam da test edilmeyen dalda; (2) `startPeriod/endPeriod` akış kombinasyonları — B-8'deki geriye-tarih tuzağını bir birim test yakalardı; (3) bildirim planlama mantığı (`rescheduleAll` mod/tarih matrisi) hiç testsiz; (4) yedek geri yükleme round-trip'i (parse→restore→okuma eşitliği); (5) ekran widget testleri — 1 smoke test dışında UI regresyonu korumasız (dünkü 30+ UI düzeltmesinin hiçbirinin regresyon testi yok, çünkü widget-test altyapısı kurulmamış).

---

## 3. Kod mimarisi

### Katman haritası

```
main.dart ──► HiveService().init() ──► ProviderScope(overrides) ──► ReglTakipApp
app.dart  ──► MaterialApp.router(builder: kilit örtüsü) ──► GoRouter (routerProvider)
router    ──► StatefulShellRoute [dashboard│calendar│statistics│settings] + 12 tam ekran rota
ekranlar ──► providers.dart (tek dosya: profil, kayıtlar, günlükler, tema, dil)
providers ──► HiveService (AES box'lar) + NotificationService + WidgetService yan etkileri
```

Katman yönleri genel olarak doğru: ekran → provider → servis → model; ters bağımlılık görülmedi. Sorunlar yön değil, tekillik ve kopya üzerine.

- **[P2] M-1 Light/dark tema %85 kopya** — `core/theme/app_theme.dart:10-326`. `elevatedButtonTheme` blokları birebir aynı (86-101 ↔ 244-259), buton/diyalog/snackbar tanımları iki kez. Bir padding değişikliği iki yerde yapılmak zorunda; drift kaçınılmaz. Öneri: `_base(Brightness)` üretici + yalnız renk farkları parametre.
- **[P2] M-2 Üç ayrı renk doğruluk kaynağı** — `ColorScheme.fromSeed` rolleri, `TextTheme` içine gömülü sabit renkler (`app_theme.dart:23-66`) ve `AppColors.tp/ts/sf/dv(context)` helper'ları (`app_colors.dart:7-21`) aynı anda yaşıyor. Ekranlar ağırlıkla üçüncü yolu kullanıyor; M3 rolleri (`onSurface`, `surfaceContainerHighest`…) fiilen ölü. Bu, Material You dynamic color kapısını kapatıyor ve her yeni rengin üç yerden hangisine gireceği belirsiz. Helper adları (`tp`, `ts`, `dv`) kriptik. Öneri: tek kaynak `ColorScheme` + `ThemeExtension` (faz/mood renkleri için); helper'ları geçiş katmanı ilan edip eritme planı.
- **[P2] M-3 DI ikiliği** — `main.dart:44-78` doğrudan singleton çağrıları (`HiveService()`, `PremiumService()`, `NotificationService()`, `WidgetService.update`) ile Riverpod provider'ları aynı kod tabanında. Ekranlar provider'dan, bootstrap ve bazı servisler global tekil örnekten konuşuyor. Test edilebilirliği düşürüyor (`daily_log_provider_test` HiveService'i elle kurmak zorunda kalmış) ve "kim kimi başlatır" sorusunu dağıtıyor.
- **[P2] M-4 Saat enjeksiyonu tutarsız** — `core/utils/cycle_utils.dart` içinde 6 fonksiyon `DateTime.now()`'u gövdede çağırıyor (`currentCycleDay:36`, `nextFuturePeriod:318-319`, `daysUntilNextPeriod:331`, `pregnancyWeek:252`, `pillDayInPack:264`), oysa aynı dosyadaki `completedPeriodEnd:72` doğru tasarımla `today` parametresi alıyor. İki API felsefesi yan yana; now() tabanlılar deterministik test edilemiyor (mevcut testler `DateTime.now()` etrafında dolanmak zorunda kalmış, `cycle_utils_test.dart:120-131` yorumları bunun kanıtı).
- **[P3] M-5 `GlassCard` mirası** — `core/widgets/glass_card.dart:15` `opacity` alanı hiçbir yerde okunmuyor (ölü API); bileşen adı "Glass" ama varsayılan görünüm opak (yorumda kabul edilmiş borç); light zemin `Colors.white` hardcoded (41) — temanın `surface`'ı (FFFBFE) ile ayrışık ikinci bir "beyaz".
- **[P3] M-6 Ölü tema konfigürasyonu** — `bottomNavigationBarTheme` (app_theme:125-131, 283-289) tanımlı ama uygulama M3 `NavigationBar` kullanıyor (onun teması yok); `cardTheme` tanımlı ama gerçek kart bileşeni `GlassCard`. Okuyana yanlış harita çiziyor.
- **[P2] M-8 Yazım başına tam yeniden yükleme, izleme başına tam rebuild** — `providers.dart:193-206` her kayıt işlemi `_load()` ile bütün box'ı yeniden okuyup TÜM listeyi state yapıyor; ekranlar `dailyLogProvider`/`periodRecordsProvider`'ın bütününü izliyor (`select` hiç kullanılmamış). Tek bardak su +1 → o map'i izleyen her ekran rebuild. Bugünkü veri boyutunda hissedilmez; 2+ yıllık veride takvim kaydırması bundan yer.
- **[P3] M-9 `saveProfile` 20 parametreli ayna** — `providers.dart:86-161` modelin `copyWith`'inin birebir passthrough kopyası; yeni profil alanı üç yerde elle eklenmek zorunda (alan, copyWith, saveProfile). Bir `UserProfile Function(UserProfile)` mutator parametresi üçünü teke indirir.
- **[P3] M-10 İkiz güvenlik-anlık-görüntüsü implementasyonu** — `hive_service.dart:210-231` ile `backup_service.dart:69-75` aynı dosyayı yazan iki ayrı kod (DRY; davranış farkı çıkarsa hangisi doğru?).
- **[P2] M-11 Tracker ekranları kopyala-yapıştır iskeleti** — 10 takip ekranı (flow/symptoms/mood/temperature/medication/water/sleep/weight/notes/sexual_activity, toplam ~2.800 satır) aynı yapıyı her dosyada yeniden kuruyor: Scaffold + AppBar + renk temalı başlık + GlassCard seçim alanları + altta tam genişlik Kaydet + snackbar + pop. Ortak bir `TrackerScaffold`/`SaveBar` bileşeni yok. Kanıt: dünkü denetimde aynı hata sınıfları (küçük dokunma hedefi, hayalet kayıt, silinemeyen değer) 6-7 ekranda **ayrı ayrı** düzeltilmek zorunda kaldı — kalıp tek yerde olsaydı tek düzeltmeydi. Yeni tracker eklemenin maliyeti bugün ~300 satır kopya.
- **[P3] M-12 `ref.read` build içinde** — `statistics_screen.dart:466` ve `calendar_screen.dart:193` `effectiveCycleLengthProvider`'ı build sırasında `read` ile alıyor (watch değil); değer değişince bu hesaplar bir sonraki tesadüfi rebuild'e kadar bayat kalabilir. Riverpod'un kendi lint'inin yakaladığı desen.
- **[P3] M-7 Router tekrarları + sessiz yutma** — `app_router.dart:117-176` 12 birebir GoRoute bloğu (veri listesinden üretilebilir); `onException` (55) her tür rota hatasını sessizce dashboard'a düşürüyor — üründe doğru, geliştirmede gerçek hatayı gizler (`kDebugMode`'da log önerilir).

---

## 4. Bug avı

- **[P1] B-1 Kilit `inactive`'te tetikleniyor ve tüm ekran state'ini yok ediyor** — `app.dart:68-79` + `app.dart:127-133`. İki sorunun bileşimi: (a) `AppLifecycleState.inactive` geçici odak kayıplarında da gelir — bildirim çekmecesini aşağı çekmek, sistem izin diyaloğu, paylaşım sayfası, bölünmüş ekran sürüklemesi. PIN'li kullanıcıda bunların her biri kilidi indiriyor. (b) Kilit, `MaterialApp.builder` içinde child'ın YERİNE dönüyor; Navigator alt ağacı unmount oluyor. Sonuç: not ekranında yazılan metin, açık sheet, kaydırma konumu — hepsi gidiyor; bildirim çekmecesine bir bakış "PIN gir + baştan başla" demek. Öneri: yalnız `paused`/`hidden`'da kilitle; recents önizleme sızıntısı (yorumdaki gerekçe) `FLAG_SECURE` ile çözülür; kilit ekranını `Stack`'te child'ın ÜSTÜNE koy ki alt ağaç yaşasın.
- **[P2] B-2 DST off-by-one ailesi** — `cycle_utils.dart` gün hesapları yerel `DateTime.difference().inDays` üzerine kurulu (36-41, 187, 288). Yaz saati geçiş günü fark 23 saat → `inDays` 0'a kırpılır → döngü günü/tahmin bir gün kayar. `add(Duration(days:))` tabanlı tahminler (10, 17) aynı aileden. Türkiye'de DST yok; ama uygulama EN yereli ile AB/ABD kullanıcısına da satılıyor — yılda iki gün yanlış "bugün X. günün" mümkün. Öneri: gün matematiğini UTC-normalize tarih (`DateTime.utc(y,m,d)`) üzerinden yap.
- **[P2] B-3 Bildirim izni bağlamsız isteniyor** — `main.dart:57`. Soğuk açılışta, kullanıcı daha hiçbir değer görmeden Android 13+ izin diyaloğu düşüyor. İlk saniyede gelen izin istemlerinin ret oranı yüksektir ve iki ret kalıcıdır. Öneri: istemi bildirimlerin anlatıldığı ana taşı (onboarding bildirim adımı veya ayardan açarken).
- **[P2] B-5 `startPeriod` ham tarihi saklıyor** — `providers.dart:225-228`: karşılaştırma için normalize edilen `date`, kayda saat bileşeniyle yazılıyor (`startDate: date`). Tarih hijyeni yazım sınırında değil okuma sınırlarında sağlanıyor; her okuyan yeniden normalize etmek zorunda ve B-2'deki DST ailesini besliyor. Öneri: tüm tarihler tek noktada (yazımda) `DateTime(y,m,d)`'ye indirgensin.
- **[P3] B-6 Regl bitiş gününde faz erken dönüyor** — `providers.dart:494` `normalizedNow.compareTo(normalizedEnd) >= 0`: endDate bugünse menstrual bastırılıyor; oysa `durationDays` bitiş gününü regl günü SAYIYOR — kullanıcı "bugün bitti" der, uygulama aynı gün "folliküler" gösterir.
- **[P3] B-7 `selectedDateProvider` açılış anının now()'u** — `providers.dart:21-23`: gece yarısını geçen oturumda "bugün" bir gün eski kalır (takvim/günlük varsayılan seçimi).
- **[P1] B-8 Son regl tarihini geriye düzeltmek veriyi tutarsızlaştırıyor** — `profile_edit_screen.dart:100-118` + `providers.dart:208-234`. Kullanıcı yanlış girilmiş tarihi (ör. ayın 5'i) gerçeğine (ayın 1'i) çekince: `startPeriod(1)` süren kaydın başlangıcından (5) önce olduğu için **yeni kayıt açmaz, mevcut kaydı döndürür** (same-day guard `!isAfter`), ardından `endPeriod` o kaydı 1+periodLen-1 gününe kırpar → kayıt 5-5 olur, profil `lastPeriodStart=1` der. Takvim 5'i boyar, tahminler 1'den sayar. Kayıt zaten kapalıysa bu kez 1-5 VE 5-9 diye **çakışan çift regl** oluşur. Kök neden: regl kayıtlarını düzenleme/silme UI'ı hiç yok — profil tarihi düzeltme, kayıt düzeltme işini dolaylı ve yanlış yapıyor. U-4'teki onaysız "Reglim başladı" ile birleşince yanlış veri kalıcı. Öneri: istatistik/takvimde kayıt düzenle-sil akışı; profil tarih alanını kayıtların türevi yap (elle çift tutma).
- **[P1] B-9 PIN kaldırılınca biyometri öksüz kalıyor** — `settings_screen.dart:229-244`: biyometri kurulurken PIN zorunlu tutuluyor (266-273, doğru: fallback), ama PIN kapatılırken hash silinip `biometricEnabled` DOKUNULMUYOR. Sonuç: biyometri-tek kilit; sensör arızası/ıslak parmak/tekrar limitinde fallback yok — kalıcı kilitlenme riski geri geldi (dünkü denetimin çözdüğü sınıf, başka kapıdan). Ayrıca PIN'i kapatmak **mevcut PIN'i sormuyor** — kilidi açık unutulan telefonda tek dokunuşla koruma kalkıyor.
- **[P2] B-10 `profile_edit._save` hatayı yutmadan düşürüyor** — `profile_edit_screen.dart:90-141`: try/finally var, **catch yok**; Hive/bildirim istisnası kullanıcıya hiç görünmez (onboarding'deki catch+snackbar deseni burada unutulmuş).
- **[P3] B-4 `_needsLock` senkron dansı** — `app.dart:58-65` initState içinde gereksiz `setState`; 92-107 türetilebilir bir değeri (profil→kilit gerekli mi) local state'e kopyalayıp postFrameCallback ile eşitliyor. Karpathy testi: her build'de hesaplanan tek satırlık türetme, ~25 satırlık durum makinesine dönüşmüş. Davranışsal pencere: `_pendingLockUpdate` true iken profil ikinci kez değişirse güncelleme bir frame gecikir (pratik etkisi düşük).

---

## 5. UI/UX (impeccable critique)

### 5.1 Nielsen heuristik karnesi

| # | Heuristik | Puan | Anahtar bulgu |
|---|---|---|---|
| 1 | Sistem durumu görünürlüğü | 3 | Kaydet spinner'ları/snackbar'lar var; uzun işlemler sessiz (U-25), bildirim kurulumunun sessiz ölümü (S-8) |
| 2 | Sistem ↔ gerçek dünya uyumu | 4 | Dil doğal, jargon açıklanıyor, faz diyaloğu öğretici |
| 3 | Kullanıcı kontrolü ve özgürlük | 2 | Geri alma hiçbir yerde yok (U-4), regl kaydı düzenleme/silme yok (B-8), dirty-guard tek ekranda (U-20), PIN unutma çıkışsız (U-8) |
| 4 | Tutarlılık ve standartlar | 3 | Köşe/boşluk dili disiplinli; istatistik filtresi yarım işliyor (U-12), iki "beyaz", vurgu-metin deseni (U-22) |
| 5 | Hata önleme | 2 | "Reglim başladı" onaysız (U-4), tarih düzeltme tuzağı (B-8), PIN kapatma doğrulamasız (B-9) |
| 6 | Hatırlama değil tanıma | 4 | Her şey görünür, gizli hareket yok, ikon+etiket her yerde |
| 7 | Esneklik ve verimlilik | 3 | Hızlı Kayıt gerçek bir hızlandırıcı ✅; tracker'larda 3 aşamalı tören (U-21), toplu/geçmiş düzenleme yok |
| 8 | Estetik ve minimalist tasarım | 3 | Temiz ve odaklı; giriş-fade refleksi ve 10-kart günlük listesi gürültü |
| 9 | Hata tanıma ve kurtarma | 2 | S-1 çökme döngüsü kurtarmasız, hata metinleri çoğunlukla ham `e.toString()`, profil kaydetme hatası hiç görünmüyor (B-10) |
| 10 | Yardım ve dokümantasyon | 3 | Faz bilgisi, BBT ipucu, disclaimerlar bağlamsal ✅; PIN/yedek gibi kritik akışlarda "ne olur?" açıklaması yok |
| **Toplam** | | **29/40** | **İyi bant (28-35): sağlam temel, zayıf alanlar belli** |

Puanın anatomisi: görsel/anlatım katmanı 3.5-4 bandında, **veri güvenliği ve geri-alınabilirlik katmanı 2 bandında**. Uygulamayı bir sonraki lige taşıyacak olan renk paleti değil, #3/#5/#9 sütunu.

### 5.2 Bulgular

**Çekirdek/tema düzeyi:**

- **[P2] U-1 Faz renkleri renk-tek ve renk körlüğüne kapalı** — `app_colors.dart:43-45`: `ringFollicular` (E8944A) ile `ringLuteal` (E8A830) aynı turuncu ailesinden; deuteranopia'da pratikte aynı renk. Ring'de segment KONUMU ikinci ipucu veriyor (faz sırası sabit) ama legend/rozet gibi bağlamlarda renk tek başına. Öneri: faz çifti arasına doku/ikon farkı veya luteal'i ayrı bir aileye (ör. mavi-gri) taşımak.
- **[P3] U-2 `warning` = `luteal` birebir aynı renk** (FFD9A0, `app_colors.dart:39,123`) — "uyarı" ile "luteal faz" aynı sarıyı giyiyor; bir uyarı rozeti faz rozetiyle karışabilir. Semantik tokenlar faz paletinden ayrılmalı.
**Ekran grubu A (kurulum, kilit, kabuk, ana sayfa):**

- **[P1] U-4 "Reglim başladı" tek dokunuş, onaysız ve geri alınamaz** — `dashboard_screen.dart:276-301`. Yanlış dokunuş anında: yeni PeriodRecord açılır, süren kayıt bir gün öncesiyle KAPATILIR, `lastPeriodStart` ezilir, bildirimler yeniden kurulur. Ne onay var ne "Geri al" snackbar'ı. Regl geçmişi uygulamanın en değerli verisi; tek yanlış dokunuşla ortalama hesapları bozulur. (Nielsen #3 kullanıcı kontrolü + #5 hata önleme.) Öneri: 5 sn'lik "Geri al" aksiyonlu snackbar — onay diyaloğundan daha akıcı.
- **[P2] U-5 Uygulama sistem temasını hiç izlemiyor** — `app.dart:114` `themeMode: isDarkMode ? dark : light`; `ThemeMode.system` seçeneği yok, varsayılan light. Sistemi koyu kullanan kullanıcı ilk açılışta parlak beyaz ekran alır ve ayarı kendisi bulmak zorunda (M3 "dark theme is a first-class scheme"). Öneri: üç durumlu tercih (sistem/açık/koyu), varsayılan sistem.
- **[P2] U-6 TTC doğurganlık rozeti ve ring merkezi kontrast altında** — `dashboard_screen.dart:367-370`: `fertilityHigh` metni `AppColors.success` (soluk yeşil, ~2.2:1), `fertilityMedium` metni `warning` (soluk amber, ~1.8:1) renginde 13px yazılıyor — AA (4.5:1) uzağında. Aynı desen ring merkezinde: `cycle_progress_ring.dart:163-171` gün sayısı `_ringColor` ile; folliküler (E8944A ~2.6:1) ve luteal (E8A830 ~2.1:1) fazlarda 48px büyük metin için bile 3:1 sınırının altında; 12px'lik alt rozet aynı renkle daha da kötü. Öneri: metinde `ring*` yerine koyulaştırılmış metin tonları (fertileWindowText deseni zaten var).
- **[P2] U-7 LH testi toggle'ı hayalet kayıt bırakabiliyor** — `dashboard_screen.dart:425-441`: pozitif/negatif seçimi kaldırmak `updateOvulationTest(today, null)` yazar; gün başka veri içermiyorsa geriye tüm alanları null bir DailyLog kalır → takvimde sahte "kayıt var" noktası. Ekranlara eklenen phantom-guard deseni bu yoldan eksik.
- **[P2] U-8 Unutulan PIN çıkmaz sokak** — kilit ekranında "PIN'imi unuttum" yolu yok; biyometri kapalıysa tek kurtuluş uygulama verisini silmek, ama bunu ekran söylemiyor. Veri-yerel mimaride sıfırlama = veri kaybı meşru; sorun seçeneğin ve sonucunun anlatılmaması (Nielsen #9). Öneri: kilitte "PIN'i sıfırla (tüm veriler silinir)" akışı + net uyarı.
- **[P2] U-9 Kurulumda isteğe bağlı adımlar isteğe bağlı olduğunu söylemiyor** — `onboarding_screen.dart:550-618`: isim ve doğum tarihi adımlarında "isteğe bağlı" etiketi ya da "Atla" düğmesi yok; kullanıcı boş "Devam"ın çalışacağını bilemez (Jordan persona: sağlık uygulamasına isim vermek istemeyen kullanıcı ilk adımda duraklar). Zorunlu tek alan (son regl) 5 adımın 3.'sü — en değerli soru en önde olsa akış daha hızlı biterdi.
- **[P3] U-10 Karanlık mod düğmesi ana sayfanın en değerli köşesinde** — `dashboard_screen.dart:148-183`: günde bir kez bile kullanılmayan bir ayar, her gün bakılan ekranın sağ üstünde; ayarlar sekmesinde zaten var (tekrar). Yerine bugünkü tarih/bugüne dön gibi güncel bilgi taşınabilir.
- **[P3] U-11 Hamilelik istemi ayarlar köküne atıyor** — `dashboard_screen.dart:536`: "başlangıç tarihini gir" kartı `/settings`'e gidiyor; kullanıcı tarihi ayarların içinde nerede arayacağını bilmek zorunda. Doğrudan `/profile-edit`'e (alan odaklanmış) gitmeli.
**Ekran grubu B (takvim, istatistik, günlük):**

- **[P2] U-12 İstatistik filtresi kartın yarısına işliyor** — `statistics_screen.dart:41-45,72,166`: "Son 3/6/12 ay" çipleri seçiliyken **Ort. Döngü** ve **Düzenlilik** TÜM kayıtlardan (`records`), **Ort. Regl** ise filtrelenmiş kayıtlardan hesaplanıyor — aynı kartın içinde. Kullanıcı filtreyi değiştirir, üç sayıdan biri değişir: hangi sayının neye baktığı belirsiz (Nielsen #4 tutarlılık). Karar verilmeli: ya kart tamamen filtreye uyar ya çipler yalnız grafikleri etkilediğini söyler.
- **[P2] U-13 Semptom grafiği değer göstermiyor, etiketleri 4 harfe kırpıyor** — `statistics_screen.dart:281` `barTouchData: enabled(false)` → dokununca değer yok; çubuk üzerinde sayı da yok — gören kullanıcı yalnız göreli yükseklik görüyor (ekran okuyucu özeti sayıları alıyor; görene daha az bilgi!). Etiketler `substring(0,4)` (294): "Baş ağrısı"→"Baş ", "Kramp"→"Kram" — TR'de dört harf ayırt etmiyor. Öneri: yatay çubuk grafik (uzun kategorik etiketlerin doğru formu) + çubuk ucunda değer.
- **[P2] U-14 Pasta yüzdeleri soluk dilimlerde beyaz** — `statistics_screen.dart:399-404`: %11px beyaz metin `moodHappy` (FFE082) gibi pastel dilimlerin üstünde ~1.4:1. Ayrıca alt lejant yalnız 10px renk noktası + ad — renk körü kullanıcı dilimi lejanta eşleyemez (yüzde lejantta yok). Takvim gün-detay sheet'i aynı hastalığa sahip: `calendar_screen.dart:397-421` chip metinleri token renginin kendisiyle (`moodHappy` sarısı, `warning` amber'i) yazılıyor — U-6'daki "vurgu rengi = metin rengi" ailesinin iki örneği daha.
- **[P2] U-15 Trend grafiklerinde x ekseni zaman değil sıra** — `statistics_screen.dart:648-650` `FlSpot(x = liste indeksi)`: ölçümler düzensiz aralıklarla girilmişken (gerçek kullanım) eşit aralıklı çiziliyor — bir haftada 3 ölçüm + iki ay boşluk, düz bir eğilim gibi görünür. Kilo/BBT eğrisinin biçimi yanıltıcı. Öneri: x = başlangıçtan gün sayısı.
- **[P2] U-16 Takvimde "bugün" her renge yeniliyor** — `calendar_screen.dart:208-224` öncelik sırası period > predicted > ovulation > fertile > today: bugün fertil pencerede ya da regldeyse **bugün göstergesi tamamen kayboluyor** — kullanıcının takvimdeki çapası yok. Öneri: bugüne renkten bağımsız kalıcı bir halka.
- **[P3] U-17 Takvim lejantı eksik ve aya hapsolmuş** — lejantta günlük-kayıt noktasının (5px mor nokta) açıklaması yok (141-146); aylar arası gezindikten sonra "bugüne dön" affordance'ı yok; her gün dokunuşu anında modal sheet açıyor (81) — karşılaştırmalı gezinme sheet kapata kapata yapılıyor.
- **[P3] U-18 İstatistik "Döngü Geçmişi" ilk 10'da kesiliyor** — `statistics_screen.dart:588` `.take(10)`, "tümünü gör" yolu yok; 10+ döngüsü olan kullanıcı eski verisine hiçbir ekrandan liste halinde ulaşamıyor.
- **[P3] U-19 Günlük ekranı 10 eş ağırlıklı kategori kartı** — akış/ruh hali gibi her gün kullanılanlarla cinsel aktivite/kilo gibi seyrekler aynı görsel ağırlıkta tek uzun liste; her veri tipi ayrı tam ekrana götürüyor (veri başına 3+ dokunuş). Hızlı Kayıt bunu kısmen telafi ediyor; yine de kullanım sıklığına göre hiyerarşi yok.
**Ekran grubu D (ayarlar + profil):**

- **[P2] U-22 "Vurgu rengi = metin rengi" deseni uygulama geneli** — U-6'nın tam envanteri: ring merkez sayısı ve rozeti (folliküler/luteal), TTC doğurganlık rozeti, takvim gün-detay chip'leri (`moodHappy` sarısı metin), profil kaydet butonu (`profile_edit_screen.dart:411` pastel `primary` zemin + beyaz metin — `app_colors.dart:28`'deki yorumun kendisinin yasakladığı 2.06:1 kombinasyon!), profil slider değeri (22px pastel pembe). Token dosyası `primaryStrong`'u tam bu iş için tanımlamış; ekranların yarısı kullanmıyor. Tek geçişlik "pastel token'lar asla metin/CTA zemini olamaz" taraması gerekli.
- **[P2] U-23 Ayar satırının tamamı değil yalnız anahtar dokunulabilir** — `settings_screen.dart:714-740` `_switchTile` ListTile'a `onTap` vermiyor; kullanıcı alışkanlıkla satıra dokunuyor, hiçbir şey olmuyor. `SwitchListTile` bunu bedava verir (48dp'lik gerçek hedef + doğru semantics).
- **[P2] U-24 Gizlilik politikası her dilde Türkçe** — `settings_screen.dart:509` `privacy_policy_tr.md` sabit; EN arayüz kullanan kullanıcıya (ve Play denetçisine) Türkçe yasal metin. EN sürümü eklenmeli ya da politika dili seçime bağlanmalı.
- **[P3] U-25 Uzun işlemlerde durum geri bildirimi yok** — Health Connect aktarımı, PDF üretimi, yedek geri yükleme: dokunuştan snackbar'a kadar ekran sessiz (Nielsen #1). Satın alma geri yükle (`restore()`) hiç sonuç mesajı vermiyor. Öneri: tile'larda geçici spinner/disable durumu.
- **[P3] U-26 "Tüm verileri sil" sıradan bir tile** — yedekle/dışa aktar ile aynı kartta, aynı görsel dilde (yalnız ikon kırmızı). Yıkıcı eylem M3'te görsel+mekânsal ayrılık ister: kendi bölümü, boşluk, dolgu-kırmızı stil. Onay diyaloğu var (iyi) ama yazarak-onayla veya geri-al penceresi yok. Ayrıca silme sonrası `pre_encryption_backup.json` (S-2) ve Health Connect verisi/watermark'ı yerinde kalıyor — "tüm veriler" tam değil.
- **[P3] U-27 Sürüm elle '1.1.0'** — `settings_screen.dart:472`; pubspec 1.1.0+7. `package_info_plus` ile gerçek sürüm+build okunmalı; şimdiden drift etmiş (build no görünmüyor).

**Ekran grubu C (10 takip ekranı):**

- **[P2] U-20 Kaydetmeden çıkış koruması yalnız Notlar'da** — notes_screen'e eklenen dirty-guard (PopScope + "vazgeç?" diyaloğu) diğer 9 tracker'da yok: akış/semptom/ruh hali ekranında seçim yapıp Kaydet'e basmadan geri dönen kullanıcı sessizce kaybediyor. Kalıp M-11'deki ortak iskelette olsaydı hepsine bedavaya gelirdi (Nielsen #5 hata önleme).
- **[P3] U-21 "Seç → Kaydet → geri dön" akış maliyeti** — her tracker'da veri girişi üç aşamalı tören: seçim, alttaki Kaydet, geri. Kategori lideri kayıt akışları (tek dokunuş = kayıt + geri alma) girdiyi yarı maliyete indiriyor. Hızlı Kayıt sheet'i doğru yönde; tam ekran tracker'lar hâlâ form-modeli. Ürün kararı — ama mevcut modelde en azından Kaydet sonrası otomatik geri dönüş tutarlılığı korunmalı (bazı ekranlar pop ediyor, bazıları kalıyor).
- **[P2] U-3 Kategori refleksi (taste birinci-derece tell)** — palet "regl uygulaması → pastel pembe" refleksinin tam kendisi (`primary` E8A0BF). Flo ile aynı raf görünümü; Clue'nun klinik-nötr dili gibi ikinci-derece bir ayrışma hiç denenmemiş. Bilinçli pazar kararıysa meşru — ama karar verilmiş değil, varsayılan alınmış görünüyor. (Ayrıntı §9 Taste eki.)

---

## 6. Frontend (Flutter özgü)

- **[P2] F-1 Yarı saydam dark yüzeyler** — `app_theme.dart:276` dark `cardTheme` rengi `surfaceDark.withValues(alpha: .7)`, input dolgusu `cardDark.withValues(alpha: .6)` (297). v1.1.0'ın ilan ettiği "opak yüzeyler" kararına aykırı kalıntılar: yarı saydam yüzeyde metin kontrastı altta ne olduğuna bağlı — garanti verilemez, blend maliyeti de bedava değil.
- **[P3] F-2 `AppConstants` animasyon sabitleri ölü kod** — `app_constants.dart:33-35` `quickAnimation`/`normalAnimation`/`slowAnimation` hiçbir yerde kullanılmıyor (tüm süreler ekranlara gömülü `.ms` değerleri). Sabitler ya silinmeli ya da gerçekten tek kaynak yapılmalı — mevcut hali okuyana yanlış "merkezî motion sistemi var" izlenimi veriyor.
- **[P2] F-4 `_SegmentedRingPainter.shouldRepaint` eksik alan karşılaştırıyor** — `cycle_progress_ring.dart:287-290`: yalnız `todayDay`, `cycleLength`, `trackColor` kıyaslanıyor; `segments` ve `ovulationDay` yok. Kullanıcı ayarlardan regl süresini değiştirirse (cycleLength aynı kalır) segment haritası değişir ama ring **eski rasterini** göstermeye devam eder. Öneri: segments/ovulationDay/periodLength'i karşılaştırmaya ekle.
- **[P3] F-5 Alt gezinme pill'inin 112px boşluğu ekranlara elle dağıtılmış** — dashboard `fromLTRB(20,0,20,112)`, takvimde `fromLTRB(20,12,20,112)`; pill yüksekliği değişse her ekran tek tek bozulur. Paylaşılan bir `kBottomNavClearance` sabiti yok.
- **[P3] F-3 `GlassCard` her build'de yeni gölge listesi kuruyor** — `glass_card.dart:56-63`; const edilebilir. Liste hücrelerinde (takvim, günlük şeridi) toplanınca küçük ama bedava olmayan çöp üretimi.

---

## 7. Backend (yerel veri + servisler)

- **[P0] S-1 Cihaz yedeğinden dönüş = açılış çökme döngüsü.** `AndroidManifest.xml`'de `android:allowBackup` hiç set edilmemiş → varsayılan **true**: Android auto-backup Hive kutu dosyalarını yeni cihaza taşır, ama AES anahtarı Keystore'a bağlı `flutter_secure_storage`'dadır ve **taşınmaz**. Yeni cihazda `init` akışı (`hive_service.dart:53-84`): anahtar bulunamaz → yenisi üretilir; `hive_encrypted` bayrağı da kayıp → `_plainBoxesExistOnDisk()` true → `_migrateToEncrypted` şifreli dosyayı düz kutu olarak açmaya çalışır → HiveError → catch → `_openPlainBoxes()` **aynı bozuk dosyada tekrar patlar** → istisna `main()`'de yakalanmıyor → uygulama açılmaz. Kullanıcının tek çıkışı "verileri sil". Öneri: (a) dürüst çözüm — `allowBackup=false` + `dataExtractionRules` (anahtar cihaza bağlıyken kutuları yedeklemek anlamsız; JSON yedeği zaten var), ve/veya (b) açılışta kutu açma hatasını yakala → bozuk kutuları karantina dizinine taşı → boş başlat + kullanıcıya tek seferlik açıklama göster.
- **[P1] S-2 Düz metin `pre_encryption_backup.json` sonsuza dek diskte.** `hive_service.dart:210-231`: şifreleme migrasyonundan önce TÜM sağlık verisi (regl geçmişi, semptomlar, cinsel aktivite, notlar) belgeler dizinine şifresiz JSON yazılıyor ve migrasyon başarılı olsa da **hiç silinmiyor**. AES şifrelemesinin vaadini tek dosyayla boşa düşürür; S-1'deki `allowBackup=true` ile bu düz metin buluta da gider. Öneri: başarılı şifreli açılıştan bir açılış sonrasında dosyayı sil; `backup_service.dart:69-75`'teki ikiz `writeSafetySnapshot` da aynı kaderi paylaşıyor.
- **[P2] S-3 Geri yükleme atomik değil** — `backup_service.dart:119-138`: `clearAll()` sonra tek tek `put`. Ortada bir istisna eski veriyi silmiş, yenisini yarım bırakmış olur. Parse aşaması dosyayı önceden doğruluyor (iyi), ama yazım aşaması korumasız. Öneri: restore öncesi mevcut veriyi otomatik iç yedeğe al, ya da geçici kutulara yazıp takas et.
- **[P2] S-4 Saatli + saatsiz ilaç karışımında saatsizler hatırlatılmıyor** — `notification_service.dart:266-274`: `withTime` boş değilse fallback (genel saat) hiç kurulmuyor; saat girilmemiş ilaç sessizce kapsam dışı kalıyor. İki ilaçtan birine saat verip diğerine vermeyen kullanıcı, ikincisinin hatırlatmasını kaybettiğini fark etmez.
- **[P2] S-5 Health Connect aktarımı geriye dönük düzenlemeleri kaçırıyor** — `health_sync_service.dart:55`: watermark (`lastSynced`) sonrası günler yazılıyor; kullanıcı watermark ÖNCESİNE eski bir regl eklerse/düzeltirse o günler bir daha asla aktarılmaz; silinen kayıtlar Health tarafından silinmez. Ayrıca her gün sabit `MenstrualFlow.medium` yazılıyor (57-63) — günlükte gün-gün gerçek akış şiddeti dururken.
- **[P2] S-6 PDF/CSV dışa aktarım İngilizce'ye çakılı ve veri kaybediyor** — `export_service.dart:24-28, 74-79`: iki metod da `locale` parametresi alıyor ama **hiç kullanmıyor**; başlıklar, tablolar, "Ongoing" hep İngilizce — TR kullanıcının doktora götüreceği çıktı İngilizce. Semptomlar yalnız adet olarak yazılıyor (`log.symptoms.length`, satır 54 ve 212) — hangi semptomlar olduğu çıktıda yok; ilaçlar ve uyku saatleri hiçbir dışa aktarımda yok. "Doktorla paylaş" senaryosunun değerini ciddi düşürüyor.
- **[P3] S-7 Mini-l10n kopyaları** — `notification_service.dart:35-64` ve `widget_service.dart:18-35` kendi TR/EN map'lerini taşıyor; arb hattının dışında iki paralel çeviri kaynağı daha (M-2'deki çok-kaynaklılık deseninin servis katmanı hali). Gerekçe (context'siz erişim) meşru; ama `lookupAppLocalizations(Locale)` context'siz de çalışır.
- **[P3] S-8 Küçükler**: bildirim kanal adları kurulum anındaki dile çakılı kalıyor (Android kanalı ID ile önbellekler, dil değişince güncellenmez); `PremiumService.isPremiumNotifier` ValueNotifier'ı Riverpod'un yanında üçüncü state mekanizması; IAP `PurchaseStatus.error` durumunda kullanıcıya geri bildirim yolu yok; "app-open" reklamı aslında `InterstitialAd` formatı (`ad_service.dart:80`) — gerçek `AppOpenAd` formatı açılış senaryosu için tasarlanmış, daha hafif algılanır; `rescheduleAll` hataları yalnız `debugPrint` — Sentry aktifken bile çekirdek özellik (hatırlatma) sessiz ölür.
- **[P2] S-9 Gizli mod bildirimleri kapsamıyor** — disguise açıkken launcher "Notlar", widget nötr; ama planlanmış bildirimler "Adet Hatırlatması / Adetiniz yarın başlayabilir" başlığıyla kilit ekranına düşmeye devam ediyor. Kılığın tek amacı üçüncü kişilerin telefona bakışı; bildirim tam o anda deşifre ediyor. Öneri: disguise açılırken döngü bildirimlerini iptal et ya da metinleri nötrleştir ("Hatırlatma").
- **Bilinçli sınır (bulgu değil, not):** PIN saklama PBKDF2-HMAC-SHA256 (50k tur, tuzlu, sabit-zaman karşılaştırma) — doğru yön. Ama 4 haneli PIN uzayı 10⁴; kutuyu ele geçiren offline saldırgan için saniyeler. Veri ayrıca Keystore-bağlı AES ile şifreli olduğundan PIN pratikte yalnız UI kapısı; yine de 6 hane seçeneği ucuz bir kazanım olur.

---

## 8. Motion karnesi (Emil Kowalski eki)

Değerlendirme ölçütleri: amaç (neden-sonuç), hız hissi (~200-300 ms, giriş ease-out), kesilebilirlik, mekânsal süreklilik (origin-aware), doz (sık akışta yorgunluk yok), reduced-motion saygısı.

| Yüzey | Mevcut davranış | Değerlendirme |
|---|---|---|
| Sekme geçişi | `NavigationBar` 250 ms, reduced-motion'da 0 (`app_shell.dart:117-119`) | ✅ Doğru süre, doğru istisna. Örnek uygulama. |
| Ring girişi | scale 0.9→1 + fade, 500 ms, `easeOutQuart` (`cycle_progress_ring.dart:146-154`) | ✅ Ease-out doğru; 500 ms hero için kabul edilebilir; IndexedStack sayesinde sekme dönüşlerinde tekrarlamıyor. |
| Dashboard giriş korosu | selam 500 ms → faz çipi +200 → kartlar +420/450 → aksiyonlar +500+600 = son öge ~1.1 sn'de oturuyor | ⚠️ Product register "sayfa yükleme koreografisi yok" der. İlk açılışta hoş; ama her cold start'ta 1.1 sn'lik perde. Delay merdivenini ~yarıya indirmek (maks ~500 ms'de tamam) hissi korur, bekletmez. |
| İstatistik kartları | 5 kart kademeli fade+slide, delay 100-500 ms | ⚠️ Aynı "tek tip giriş refleksi" — her kart aynı hareket. Doz yüksek değil ama anlam da taşımıyor (hangi kart önemli?). İlk karta tek vurgu yeter. |
| Onboarding form adımları | PageView 350 ms `easeInOut` | ⚠️ Giriş için ease-out (`easeOutCubic/Quart`) daha doğru; easeInOut girişte yavaş başlar, "tutuk" hisseder. Küçük ayar. |
| Sheet/diyaloglar | Sistem varsayılanları (modal bottom sheet, dialog) | ✅ Platform hareketi; origin-aware (alttan sheet) doğru. |
| Chip/kart seçimleri | InkWell ripple (denetimde eklendi), state değişimi anında | ✅ Dokunma geri bildirimi var; anlık state doğru (form ekranında animasyon gereksiz). |
| Takvim ay geçişi | table_calendar varsayılanı | ✅ Sorunsuz. |
| Tracker ekran girişleri | Çoğunda kart fade/slide girişleri (aynı refleks) | ⚠️ Günde 3-5 kez girilen ekranlarda giriş animasyonu yorgunluk sınıfı; süreler kısa olduğundan P3. |
| Kesilebilirlik | flutter_animate girişleri dokunmayı bloklamıyor; kilit/reklam overlay'leri hariç girdi hiç kilitlenmiyor | ✅ |
| Reduced-motion | `animateSafe` + `motionEnabled` deseni tutarlı; `value:1` hilesi fadeIn'li içeriği görünür bırakıyor (`motion.dart:13-16`) | ✅ Örnek merkezî çözüm — birçok üretim uygulamasından iyi. |
| Rota geçişleri (tracker'lara) | Flutter M3 varsayılan (`ZoomPageTransitions`) + predictive back etkin (manifest) | ✅ Platform uyumlu. |

**Özet:** Motion altyapısı (animateSafe, reduced-motion, süre disiplini) ortalamanın üstü. Tek gerçek eleştiri **tek tip giriş-fade refleksi**: her yüzey aynı fade+slide'ı yapıyor, hiçbiri anlam taşımıyor; ve dashboard korosunun toplam süresi. Eksik olan "hangi an animasyonu hak ediyor" seçiciliği — ör. "Reglim başladı" gibi önemli bir veri anında hiçbir kutlama/teyit hareketi yok (motion bütçesi asıl oraya harcanmalı), ama beş istatistik kartı sırayla süzülüyor.

---

## 9. Taste eki — ürün eleştirisi

*(taste-skill'in aktarılabilir prensipleri — tutarlılık kilitleri, AI-tell denetimi, copy denetimi — Flutter yüzeyine uygulanmıştır; skill'in kendi kapsam beyanı gereği web'e özgü kuralları [Tailwind/GSAP/bento] atlanmıştır.)*

**Renk kimliği: birinci refleks, sorgulanmamış.** "Regl uygulaması → pastel pembe + mor + yumuşak köşeler" kombinasyonu kategorinin eğitim-verisi varsayılanıdır; Flo, Period Calendar ve düzinelerce klonla aynı raftadır. taste-skill'in kategori-refleks testi burada birebir düşer: paleti markadan değil kategoriden tahmin edebiliyorsanız karar verilmemiş, miras alınmıştır. Clue'nun (klinik nötr + tek canlı kırmızı) ya da Apple Health'in (nötr zemin + semantik renk) yaptığı ikinci-derece ayrışma hiç denenmemiş. Bu bir "değiştir" emri değil: pembe bilinçli bir pazar konumu OLABİLİR — ama o zaman geri kalanın (ikon dili, illüstrasyon, ses tonu) bu kararı sahiplenmesi gerekir; şu an palet varsayılan, gerisi jenerik-temiz.

**Tutarlılık kilitleri: yarım.** Shape lock büyük ölçüde tutuyor (12/16/20/28 radius merdiveni gerçekten disiplinli — nadir görülür). Color lock tutmuyor: iki farklı "beyaz" (surface FFFBFE vs hardcoded white), pastel token'ların metin olarak kullanımı (U-22), `warning`=`luteal` çakışması. Tip ölçeği (12-28, iki ağırlık ekseni w500/w800) sade ve doğru — Nunito'nun yuvarlak karakteri ürün tonuyla uyumlu, tek aile kararı (product register önerisinin kendisi) isabetli.

**Copy denetimi:** Ton TR'de doğal ve sıcak ("Reglim başladı", "Bugün nasılsın"), tıbbi jargon yok — iyi. İki gözlem: (1) coach kartı mesajları günde bir sabit — iyi fikir, ama kaynak belirtilmeyen sağlık tavsiyeleri ("demir açısından zengin beslen") disclaimera yaslanıyor; hassas kategoride tavsiye cümlelerinin "genel bilgidir" çerçevesi metnin İÇİNDE olmalı. (2) Bildirim metinleri ünlemli ve buyurgan ("Hazırlıklı olun!", "unutmayın!") — kilit ekranı görünür bildirimlerinde regl bilgisinin görünmesi ayrıca bir mahremiyet sorusu (disguise modu widget'ı gizliyor ama bildirim metnini gizlemiyor — "Adet Hatırlatması" başlığı kilit ekranında düşer!). Bu son nokta bulgu değeri taşıyor: **gizli mod bildirimleri kapsamıyor** (S-9 olarak yol haritasına eklendi).
 
**Monetizasyon hissi.** Sağlık-mahremiyet ürününde her cold start'ta tam ekran interstitial (2 sn gecikmeli) "ücretsiz aracın bedeli" olarak sert bir ilk an; Premium'un tek görünürlüğü ayarlardaki bir tile. Kategori lideri davranışı: reklamı içerik akışına (native/banner) alıp açılışı temiz bırakmak, premium'u değer anında (istatistik derinliği, dışa aktarım) teklif etmek. Mevcut kurgu, kullanıcı başına gelir ile bırakma oranını aynı anda yukarı itme riskinde.

**Genel his.** Uygulama "özenli jenerik": temiz, tutarlı boşluk ritmi, gerçek boş-durumlar, disiplinli köşe dili — AI-slop testinin kaba tell'lerinden (gradyan metin, cam istifi, emoji ikonlar) arınmış. Eksik olan imza: bir kullanıcı ekran görüntüsüne bakıp "bu Regl Takip" diyemez. Ring bileşeni imza adayı en güçlü öge — segmentli faz haritası + "buradasın" noktası gerçekten iyi düşünülmüş; marka bu bileşenin görsel dilinden (segment estetiği, renk kodu, nokta işaretçisi) türetilip diğer yüzeylere yayılabilir (takvim, istatistik, widget). İmza oradan çıkar.

## 9b. Bilişsel yük + persona notları (impeccable critique)

**Bilişsel yük listesi (8 madde):** 6/8 geçer. Takılanlar: **chunking** (günlük ekranı 10 eş kart — ≤4 kuralının 2.5 katı) ve **karar noktası** (kurulumda mod seçimi yok ama ayarlarda 4 mod + 12 ayar tile'ı tek listede). Genel yük düşük-orta: her ekran tek iş yapıyor (iyi), gezinme sığ (iyi).

**Casey (dikkati dağınık mobil kullanıcı):** Ana aksiyonlar başparmak bölgesinde ✅; ama B-1 kilit davranışı Casey'nin baş düşmanı — bildirim çekip döndüğünde PIN + kaybolmuş form. Kesintiye dayanıklılık sınıfta kalıyor.
**Jordan (ilk kez kullanan):** Kurulum akıcı, ama U-9 (opsiyonellik belirsiz) ilk 30 saniyede duraksatıyor; "Akış/Luteal" gibi terimler faz diyaloğunda açıklanıyor ✅.
**Sam (erişilebilirlik):** Denetim sonrası Semantics kapsamı gerçekten iyi (ring özeti, grafik metin özetleri, gün hücresi durumları — kategori ortalamasının üstünde). Kalan engeller: U-6/U-22 kontrast ailesi ve U-16 bugün çapası. TalkBack akışı tamamlanabilir; düşük görme + renk körlüğü kombinasyonu en çok ringde zorlanır.
**Riley (stres testçisi):** En zengin av alanı backend'de çıktı: S-1 (yedekten dönüş), B-8 (tarih düzeltme), U-7 (LH toggle hayaleti). UI katmanı edge-case'lere denetim sonrası büyük ölçüde dayanıklı.

---

## 10. Güçlü yönler

Dürüst denge — bu kod tabanında kategori ortalamasının belirgin üstünde olan şeyler:

1. **Erişilebilirlik yatırımı gerçek.** Ring'in tek-cümle Semantics özeti, grafiklerin metin özetleri, takvim hücrelerinin durum anonsu, `animateSafe`'in reduced-motion çözümü — bunlar çoğu yayınlanmış sağlık uygulamasında yok. Sam personası için temel akış tamamlanabilir durumda.
2. **Veri modeli ileriye dönük düşünülmüş.** `defaultValue` anotasyonları, bilinmeyen enum'da null dönüp kaydı atlayan `fromJson`'lar, sürümlü yedek formatı, JSON-aracılığıyla şifreleme migrasyonu: şema evrimi bilinçle kurgulanmış.
3. **Döngü matematiği tek kaynaklı ve testli.** `ovulationDayNumber` tek doğru; tarih-bazlı ve gün-bazlı hesapların tutarlılığı testle sabitlenmiş; BBT 3-üstü-6 kuralı ardışık-takvim-günü şartıyla doğru daraltılmış.
4. **Tasarım dili disiplini.** Köşe merdiveni (12/16/20/28), iki-ağırlık tipografi ekseni (w500/w800), opak yüzey kararı ve bunların yorum satırlarında gerekçeli olması — "neden böyle" kurumsal hafızaya yazılmış.
5. **Ring bileşeni imza adayı.** Segmentli faz haritası + ovülasyon noktası + "buradasın" işaretçisi: kategori klişesi ilerleme halkasından gerçekten daha bilgilendirici bir tasarım.
6. **Yorum kültürü.** Kod yorumları "ne"yi değil "neden"i anlatıyor (pastel kontrast yasağı, inactive-kilit gerekçesi, migrasyon öncelik kararı). Eleştirilen kararların bile gerekçesi okunabiliyor — bu incelemeyi mümkün kılan şey buydu.

---

## 11. Öncelikli yol haritası

Düzeltme istenirse sıra bu (bağımlılık ve etki sırasıyla):

**Hemen (veri güvenliği):**
1. **S-1** `allowBackup=false` + bozuk kutu karantinası — yeni cihaza geçen her kullanıcı şu an çökme döngüsüne aday
2. **S-2** `pre_encryption_backup.json` temizliği (+ "verileri sil"e dahil et)
3. **B-9** PIN kaldırınca biyometriyi de kapat + kaldırırken PIN doğrula
4. **B-8 + U-4** Regl kayıt düzenleme/silme akışı + "Reglim başladı"ya geri-al — ikisi tek iş paketi (veri düzeltilebilirliği)

**Yakın (güven ve kullanılabilirlik):**
5. **B-1** Kilidi paused'a al + FLAG_SECURE + Stack örtüsü (state kaybını bitirir)
6. **U-22/U-6/U-14** Kontrast taraması: pastel token'ları metin/CTA'dan sür (tek geçiş, çok dosya)
7. **S-9** Disguise'a bildirim kapsamı
8. **U-5** ThemeMode.system
9. **S-4** Saatsiz ilaçlara fallback bildirimi
10. **U-24** EN gizlilik politikası

**Sonra (sağlamlaştırma + parlatma):**
11. **M-11** TrackerScaffold çıkarımı (U-20 dirty-guard'ı herkese bedava getirir)
12. **S-6** Dışa aktarım l10n + semptom detayı
13. **U-12/U-13/U-15** İstatistik dürüstlüğü (filtre kapsamı, değer etiketleri, zaman ekseni)
14. **M-1/M-2** Tema tekilleştirme (ThemeExtension'a geçiş)
15. Test boşlukları: HiveService init dalları + startPeriod matrisi + rescheduleAll

**Kapsam dışı hatırlatma:** Görev listesindeki #19 (release APK build — TLS 1.2 fix'inin ilk gerçek testi + telefonda deneme) hâlâ açık; bu inceleme onu kapsamıyor.
