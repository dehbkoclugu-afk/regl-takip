# Parolalı Yedek Tasarımı

## Amaç

Tasarım önerisi 89'u tamamlamak: dışa aktarılan sağlık verisi cihazdan düz
JSON olarak çıkmamalı. Yeni yedekler kullanıcı parolasıyla şifrelenmeli,
dosya değişiklikleri algılanmalı ve başka bir cihazda yalnız aynı parolayla
geri yüklenebilmelidir.

Kurtarma anahtarı, cihazda parola saklama veya arka kapı olmayacaktır.
Parola unutulursa yedek geri getirilemez.

## Tehdit modeli

Korunan durumlar:

- paylaşılan, e-postalanan veya buluta yüklenen yedek dosyasının ele geçmesi,
- dosyanın içeriğinin değiştirilmesi,
- aynı parolanın farklı dosyalarda önceden hesaplanmış tablolarla denenmesi,
- kötü amaçlı bir yedek başlığının aşırı bellek/CPU kullandırması.

Kapsam dışı durumlar:

- uygulama açıkken cihazın veya kullanıcının parolasının ele geçirilmesi,
- zayıf parolanın çevrimdışı sözlük saldırısıyla tahmin edilmesi,
- ekran kaydı, tuş kaydedici veya değiştirilmiş işletim sistemi,
- unutulan parolayı kurtarma.

## Kriptografik yapı

Yeni bir `cryptography` bağımlılığı kullanılacaktır; şifreleme algoritması
elle uygulanmayacaktır.

### Anahtar türetme

- Algoritma: Argon2id
- Bellek: 19 MiB (`19456` adet 1 KiB blok)
- Tur: 2
- Paralellik: 1
- Çıktı: 32 bayt
- Salt: güvenli rastgele üretilmiş 16 bayt

Bu değerler dosya zarfına yazılır ancak geri yüklemede keyfî olarak kabul
edilmez. Yalnız desteklenen sürümün tam parametreleri kabul edilir. Böylece
saldırgan, başlığa aşırı bellek değeri yazarak uygulamayı kilitleyemez.

### Şifreleme

- Algoritma: AES-256-GCM
- Nonce: her yedek için güvenli rastgele 12 bayt
- Kimlik doğrulama etiketi: 16 bayt
- Düz metin: mevcut `buildBackupJson()` çıktısının UTF-8 baytları

GCM hem gizlilik hem bütünlük sağlar. AAD; `app`, `envelopeVersion`,
`createdAt`, KDF adı/parametreleri/salt ile şifre adı/nonce alanlarını bu
sırada taşıyan bir map'in `jsonEncode` UTF-8 çıktısıdır. Ciphertext ve MAC
AAD'ye girmez. Böylece zarf başlığı değişirse çözme başarısız olur ve
kanonikleştirme yoruma bırakılmaz.

## Dosya biçimi

Yeni uzantı `.rtbackup` olur. Dosya, ikili alanları Base64 taşıyan küçük bir
JSON zarfıdır:

```json
{
  "app": "regl_takip",
  "envelopeVersion": 1,
  "createdAt": "2026-07-26T12:00:00.000Z",
  "kdf": {
    "name": "argon2id",
    "memoryKiB": 19456,
    "iterations": 2,
    "parallelism": 1,
    "salt": "..."
  },
  "cipher": {
    "name": "aes-256-gcm",
    "nonce": "...",
    "ciphertext": "...",
    "mac": "..."
  }
}
```

`createdAt` kullanıcı verisi değildir; dosya adındaki zaman bilgisini
tekrarlar. Profil, kayıt sayısı, tarihler ve diğer sağlık verileri yalnız
şifreli yükte bulunur.

Zarf sürümü ile iç JSON yedek sürümü ayrıdır. Zarfın gelecekte algoritma
geçişi yapabilmesi, iç veri modelinin de bağımsız gelişebilmesi gerekir.

## Parola kuralları

- En az 10, en fazla 128 Unicode kod noktası.
- Boşluk ve Unicode karakterler kabul edilir.
- Baş/son boşluklar otomatik kırpılmaz; girilen değer aynen paroladır.
- Oluştururken parola ve doğrulama alanı eşleşmelidir.
- Parola kalıcılığa, loglara, analitiğe veya hata metnine yazılmaz.
- Alanlarda otomatik düzeltme ve öneri kapalı, metin gizlidir; kullanıcı
  isterse geçici olarak görünür yapabilir.

Arayüz, parola unutulursa yedeğin açılamayacağını oluşturma eyleminden önce
açıkça söyler. Güç ölçer, parola kurtarma sorusu veya cihaz anahtarı
eklenmez.

## Dışa aktarma akışı

1. Kullanıcı “Verileri yedekle”yi seçer.
2. Parolanın kurtarılamayacağını açıklayan sheet açılır.
3. Parola iki kez girilir; uzunluk ve eşleşme yerel olarak doğrulanır.
4. Mevcut JSON yükü bellekte oluşturulur.
5. Salt ve nonce güvenli rastgele üretilir; Argon2id anahtarı türetilir ve
   yük AES-256-GCM ile şifrelenir.
6. `.rtbackup` geçici dosyaya yazılır ve paylaşım sayfası açılır.
7. Başarılı paylaşım dönüşünden sonra mevcut “son yedek” zamanı güncellenir.

Kripto işlemi arayüzü dondurmamak için bir arka plan isolate'ında çalışır.
Parola dialog controller'ları sonuç alındıktan sonra kapatılır.

Yeni şifresiz JSON dışa aktarma sunulmaz. PDF, CSV ve ICS raporları açık
biçimler olarak kalır; bunlar yedek değil, kullanıcının bilinçli rapor
aktarımlarıdır.

## Geri yükleme akışı

Dosya seçici `.rtbackup` ve eski `.json` uzantılarını kabul eder.

### Şifreli yedek

1. Dosya boyutu ve JSON zarf yapısı sınırlı biçimde okunur.
2. Uygulama kimliği, zarf sürümü, algoritma adları, tam KDF parametreleri ve
   Base64 alan uzunlukları doğrulanır.
3. Kullanıcıdan parola istenir.
4. Anahtar türetilir; GCM etiketi ve AAD doğrulanarak yük çözülür.
5. Çözülen UTF-8 JSON mevcut `parseBackup()` doğrulamasından geçer.
6. Ancak bundan sonra kayıt sayısını gösteren mevcut geri yükleme onayı açılır.
7. Kullanıcı onaylarsa mevcut `restoreBackup()` çalışır.

Yanlış parola, değiştirilmiş dosya ve bozuk şifreli yük aynı kullanıcı
mesajını verir: “Parola yanlış veya yedek dosyası bozuk.” Mevcut veri
değişmez. Çözülmüş iç JSON geçersizse “Geçersiz yedek dosyası” gösterilir.

### Eski JSON

Mevcut `version: 1` düz JSON yedekleri salt-okunur geriye uyumluluk için
geri yüklenmeye devam eder. Kullanıcıya bunun eski ve şifresiz bir yedek
olduğu onay ekranında belirtilir. Uygulama artık bu biçimde yeni dosya
üretmez.

## Bileşenler

### `EncryptedBackupCodec`

Hive veya UI bilmez. Şu sorumluluklara sahiptir:

- JSON yükünü parola ile zarf biçimine şifrelemek,
- zarfı ve sınırlarını doğrulamak,
- parolayla çözmek,
- yanlış parola/değişiklik ile biçim hatasını türlendirmek.

Testlerde salt ve nonce üretimi enjekte edilebilir; üretimde güvenli rastgele
üretici kullanılır.

### `BackupService`

Mevcut veri toplama, iç JSON doğrulama ve restore sorumluluğunu korur.
Şifreli dosya yazma/okuma akışını codec'e yönlendirir. `restoreBackup()`
yalnız tamamen çözülmüş ve doğrulanmış `BackupData` alır.

### Ayarlar arayüzü

Parola oluşturma ve parola girme sheet'lerini yönetir. Kriptografik ayrıntı
göstermez; kurtarılamama, yükleniyor durumu ve anlaşılır hata mesajlarını
gösterir. İşlem sürerken eylemler devre dışı kalır, çift dışa/geri yükleme
başlatılamaz.

## Hata ve güvenlik sınırları

- Dosya boyutu yedek için makul bir üst sınırla, 50 MiB ile sınırlanır.
- Salt tam 16, nonce tam 12, MAC tam 16 bayt olmalıdır.
- Ciphertext boş olamaz ve zarf alanları beklenen türde olmalıdır.
- Bilinmeyen zarf sürümü veya algoritma reddedilir.
- KDF parametreleri zarf sürümünün sabit değerleriyle eşleşmelidir.
- Base64 çözme ve UTF-8/JSON hataları kontrollü `BackupException` türlerine
  çevrilir.
- Kimlik doğrulama geçmeden düz metin parse edilmez ve mevcut veri silinmez.
- Parola veya çözülmüş sağlık verisi hata/telemetri metnine eklenmez.
- UI tarafındaki başarısızlık ayrıntıları saldırgana parola doğruluğu hakkında
  ayrı bir sinyal vermez.

## Test stratejisi

Saf codec testleri:

1. Doğru parola ile şifrele/çöz round-trip.
2. Aynı veri ve parolada farklı salt/nonce ile farklı çıktı.
3. Yanlış parola reddi.
4. Ciphertext, MAC, nonce ve AAD başlığında tek bayt değişikliği reddi.
5. Bilinmeyen sürüm/algoritma ve sınır dışı KDF parametresi reddi.
6. Kısa/uzun salt, nonce ve MAC reddi.
7. Geçersiz Base64, bozuk JSON ve 50 MiB üstü dosya reddi.

Servis ve UI testleri:

1. Şifreli yedek iç JSON'a ve `BackupData`ya geri döner.
2. Eski düz JSON geri yüklenir fakat yeni dışa aktarım `.rtbackup` üretir.
3. Yanlış parola veya bozuk dosyada `restoreBackup()` çağrılmaz.
4. Parola eşleşmesi/uzunluk doğrulaması ve kurtarılamama metni.
5. Başarılı çözmeden sonra kayıt sayısı onayı ve mevcut restore akışı.

Testler sabit salt/nonce ile deterministik olur; üretim rastgeleliği taklit
edilmez. Algoritma çıktısını kendi implementasyonumuzla yeniden hesaplayan
test yazılmaz, paket round-trip ve değiştirme algısı doğrulanır.

## Kaynaklar

- OWASP Password Storage Cheat Sheet:
  https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
- Dart `Argon2id` API:
  https://pub.dev/documentation/cryptography/latest/cryptography/Argon2id-class.html
- Dart `AesGcm` API:
  https://pub.dev/documentation/cryptography/latest/cryptography/AesGcm-class.html
- NIST SP 800-38D:
  https://csrc.nist.gov/pubs/sp/800/38/d/final

## Kapsam dışı

- Kurtarma anahtarı veya cihazda parola saklama
- Bulut hesabı ve sunucu tarafı anahtar kurtarma
- Otomatik zamanlanmış yedek
- PDF, CSV veya ICS raporlarını şifreleme
- Üçüncü taraf uygulama yedeklerini içe aktarma

Bu işler parolalı yerel yedek hedefinden bağımsızdır.
