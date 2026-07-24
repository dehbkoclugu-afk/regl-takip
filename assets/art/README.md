# assets/art

Marka görselleri. Bunlar uygulama içinde `Image.asset` ile yüklenmez —
yalnız derleme zamanında ikon ve açılış ekranı üretmek için okunur
(`pubspec.yaml` içindeki `flutter_launcher_icons` ve
`flutter_native_splash` bölümleri). Bu yüzden `flutter: assets:` listesinde
yer almazlar ve APK'ya paketlenmezler.

- `R1-logomark.png` — uygulama ikonu + açılış ekranı logosu
- `R2-splash.png` — açılış ekranı arka planı

Değiştirdikten sonra yeniden üret:

    dart run flutter_launcher_icons
    dart run flutter_native_splash:create
