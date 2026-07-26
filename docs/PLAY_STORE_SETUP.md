# Google Play Yayın Kurulumu — Adım Adım

Kod tarafı hazır. Aşağıdakiler **senin Play Console / AdMob hesabınla** yapılacak
web işleri. Her biri için tam değerler verildi — kopyala-yapıştır.

---

## 0. Yüklenecek dosya

- **`C:\Users\user\Desktop\regl-takip.aab`** (37,6 MB, release anahtarıyla imzalı)
- Paket adı: `com.regl.regl_takip`
- versionCode: 7 · versionName: 1.1.0
- Her yeni yüklemede `pubspec.yaml` içindeki `version: 1.1.0+7` → `+8` yap (code artmalı).

Codemagic Android iş akışı da AAB üretir; `key.properties` ve gerçek release
anahtarı bağlanmamış CI çıktısı yalnız derleme doğrulaması içindir. Play'e
yüklemeden önce AAB'nin aşağıdaki upload key ile imzalandığını doğrula.

## İmza anahtarı (KRİTİK — yedekle)

- Keystore: `C:\Users\user\regl-release.jks`
- Parola: `regl-keystore-PAROLA.txt` dosyasında
- Alias: `regl` · SHA-256: `37:DE:43:DD:08:E9:11:ED:67:24:CD:F1:83:D5:D9:B1:80:7B:2F:ED:C3:11:11:3E:2B:2B:FB:60:4A:24:DE:14`
- **`.jks` + parolayı buluta/şifre yöneticisine yedekle. Kaybedersen uygulamayı bir daha güncelleyemezsin.**
- Play Console uygulama oluştururken **Play App Signing**'i açık bırak (önerilen): Google
  dağıtım anahtarını yönetir, senin `.jks` "upload key" olur.

---

## 1. Gizlilik Politikası URL'si

1. GitHub → `dehbkoclugu-afk/regl-takip` → **Settings → Pages**
2. Source: **Deploy from a branch** → Branch: **main** → Folder: **/docs** → Save
3. 1-2 dakika sonra URL: **https://dehbkoclugu-afk.github.io/regl-takip/**
4. Play Console → **App content → Privacy policy** → bu URL'yi yapıştır.

---

## 2. Abonelik Ürünleri (Monetize → Subscriptions)

Kod tam olarak şu ID'leri bekliyor. Farklı yazarsan paywall boş gelir.

### Ürün 1 — Aylık
- Product ID: **`premium_monthly`**
- Ad: Premium (Aylık)
- Base plan ID: `monthly` · Billing period: **1 ay** · Auto-renewing
- Fiyat: **₺29,00** (TRY)

### Ürün 2 — Yıllık
- Product ID: **`premium_yearly`**
- Ad: Premium (Yıllık)
- Base plan ID: `yearly` · Billing period: **1 yıl** · Auto-renewing
- Fiyat: **₺199,00** (TRY)

> Not: Eski `premium_no_ads` ürününü SİLME — eski alıcıların hakkı kodda korunuyor.
> Deneme: uygulama 30 günü kendi yönetiyor (Play "free trial" eklemene gerek yok).

---

## 3. Data Safety Formu (App content → Data safety)

Uygulama tüm veriyi cihazda şifreli tutar, sunucuya GÖNDERMEZ. Cevaplar:

- **Veri topluyor/paylaşıyor musunuz?** → Uygulamanın kendisi sunucuya veri
  göndermiyor. Ancak **AdMob (ücretsiz sürüm)** cihaz tanımlayıcısı işler →
  bu yüzden aşağıdakini beyan et:
  - **Collected/Shared:** Device or other IDs → **Collected + Shared** (AdMob)
    - Amaç: Advertising or marketing
  - Sağlık, isim, döngü verisi → **Toplanmıyor** (cihazda kalıyor, "collection"
    Play tanımına göre = cihazdan çıkması; çıkmıyor).
- **Veri şifreleniyor mu (aktarımda)?** → Evet (AdMob HTTPS)
- **Kullanıcı silme isteyebilir mi?** → Evet, uygulamadan tüm veri silinebilir
  (Ayarlar → Tüm verileri sil) ve uygulama kaldırılınca da silinir.
- **Bağımsız güvenlik değerlendirmesi?** → Hayır (opsiyonel)

> Sağlık verisini "toplanıyor" işaretleme — çünkü hiçbir sunucuya gitmiyor.
> Cihazda kalan veri Play'in "data collection" tanımına girmez.

---

## 3.1 Health Connect / Sağlık uygulamaları beyanı

Play Console → **App content → Health apps** formunu ayrıca doldur:

- Sağlık özelliği: **Health and fitness → Period tracking**
- Veri kategorisi: **Reproductive and sexual health**
- İzinler:
  - `READ_MENSTRUATION`
  - `WRITE_MENSTRUATION`
- Açıklama:

  > Kullanıcı, uygulamadaki adet başlangıç ve bitiş günlerini kendi isteğiyle
  > Health Connect'e aktarabilir. Ayrıca başka bir uygulamada kayıtlı adet
  > günlerini kendi isteğiyle içe aktarabilir. Yalnız menstruation flow verisi
  > okunur/yazılır; veri geliştirici sunucusuna gönderilmez ve reklam amacıyla
  > kullanılmaz.

Formdaki gizlilik politikası, Store Listing'deki aynı URL olmalı. Yeni bir
Health Connect veri türü eklenirse beyanı yeniden gönder; mevcut kod yalnız
âdet akışı izinlerini istiyor.

---

## 4. İçerik Derecelendirme & Hedef Kitle

- **Content rating** anketi (App content → Content ratings): sağlık/tıbbi bilgi
  uygulaması; şiddet/cinsel içerik yok. Cinsel aktivite kaydı bir sağlık takip
  alanı — "sexual content" değil. Muhtemel sonuç: PEGI 3 / Everyone.
- **Target audience:** 18+ (ya da 13+ değil; regl uygulaması yetişkin kadın hedefli).
  13 altını hedefleme — kod zaten 13+ diyor.
- **Ads:** "Contains ads" → **Evet** (ücretsiz sürüm AdMob).

---

## 5. AdMob Kurulumu

- AdMob App ID (manifest'te zaten): `ca-app-pub-2554058432197193~6303013725`
- Interstitial birimi (kodda): `ca-app-pub-2554058432197193/8369610145`
- AdMob Console → uygulamayı **Play ile eşle** (App → Link to Play).
- **app-ads.txt:** GitHub Pages kök alanın yoksa şart değil; markanın
  varsa ekle. (Şimdilik atlanabilir.)
- **KENDİ REKLAMINA TIKLAMA = HESAP BANI.** Kendi telefonunu AdMob'da
  **test cihazı** olarak ekle (AdMob → Settings → Test devices), sonra dene.
- AdMob hesabında ödeme profili + vergi bilgisi dolu olmalı (yoksa ödeme kesilir).

---

## 6. Store Listing (gerekli alanlar)

- Uygulama adı, kısa açıklama (80 kr), tam açıklama (4000 kr)
- **Ekran görüntüleri:** en az 2 telefon görüntüsü (min 320px)
- **Feature graphic:** 1024×500 PNG/JPG
- **Uygulama ikonu:** 512×512 PNG
- Kategori: **Health & Fitness**
- İletişim e-postası: dehbkoclugu@gmail.com

---

## 7. Yükleme Sırası (özet)

1. Play Console → uygulama oluştur (paket `com.regl.regl_takip`)
2. App content: gizlilik URL'si, Data safety, içerik derecelendirme, hedef kitle, reklam beyanı
3. Monetize → abonelik ürünleri (2 ürün)
4. Testing → Internal testing → **`regl-takip.aab`** yükle → kendine test
5. Aboneliği test hesabıyla dene (License testing → test hesabı ekle, gerçek para gitmez)
6. Her şey yeşilse → Production → Release
