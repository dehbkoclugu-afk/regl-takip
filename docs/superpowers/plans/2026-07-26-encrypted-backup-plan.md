# Parolalı Yedek Uygulama Planı

1. `cryptography` bağımlılığını ekle; Argon2id ve AES-256-GCM kullanan,
   sürümlü zarfı sıkı alan/uzunluk/KDF sınırlarıyla doğrulayan saf
   `EncryptedBackupCodec` oluştur.
2. Parola doğrulamasını (10–128 Unicode kod noktası) saf yardımcı olarak
   codec yanında tut; parola, salt ve nonce dışında özel kripto yazma.
3. `BackupService` yeni dışa aktarımını `.rtbackup` üretecek şekilde codec'e
   bağla; 50 MiB dosya sınırı ve eski düz JSON salt-okunur içe aktarma
   uyumluluğunu koru.
4. Ayarlar yedek eylemini kurtarılamama açıklaması, çift parola ve yükleniyor
   durumu olan sheet'e; geri yüklemeyi dosya türü algılama ve tek parola
   sheet'ine bağla.
5. Yanlış parola/değiştirilmiş dosya ile biçim hatasını kullanıcıya ayrı
   hassas veri sızdırmadan anlaşılır mesajlarla göster.
6. Altı ARB dosyasına aynı mesaj anahtarlarını ekle ve bu repodaki mevcut
   üretilen yerelleştirme sınıflarını eşleştir.
7. Sabit salt/nonce ile round-trip, rastgelelik, yanlış parola, değiştirilmiş
   zarf/yük, sınır ihlali, eski JSON ve parola doğrulama testlerini ekle.
8. Tasarım önerisi 89'u ve changelog'u tamamlandı olarak güncelle.
9. Diff, Dart ayraçları, ARB eşliği ve bağımlılık kilidini doğrula; Flutter
   SDK yoksa çalıştırılamayan test/build doğrulamasını belirt.
