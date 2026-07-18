import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Regl Takip'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get calendar;

  /// No description provided for @log.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt'**
  String get log;

  /// No description provided for @statistics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistik'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @onboardingWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldin!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığını takip etmenin en kolay yolu'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingTitle1.
  ///
  /// In tr, this message translates to:
  /// **'Döngünüzü Takip Edin'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In tr, this message translates to:
  /// **'Adet döneminizi kolayca kaydedin ve bir sonraki döneminizi tahmin edin.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığınızı İzleyin'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In tr, this message translates to:
  /// **'Belirtiler, ruh hali, sıcaklık ve daha fazlasını takip edin.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In tr, this message translates to:
  /// **'Analizlerinizi Görün'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı grafikler ve istatistiklerle döngünüzü anlayın.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler Alın'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In tr, this message translates to:
  /// **'Adet ve ovulasyon günleriniz için hatırlatmalar alın.'**
  String get onboardingDesc4;

  /// No description provided for @getStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @maybeLater.
  ///
  /// In tr, this message translates to:
  /// **'Sonra ayarla'**
  String get maybeLater;

  /// No description provided for @enableBiometric.
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi / Yüz tanıma'**
  String get enableBiometric;

  /// No description provided for @enablePin.
  ///
  /// In tr, this message translates to:
  /// **'PIN ile kilitle'**
  String get enablePin;

  /// No description provided for @securitySetup.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik Ayarı'**
  String get securitySetup;

  /// No description provided for @securitySetupDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı kilitlemek ister misin?'**
  String get securitySetupDesc;

  /// No description provided for @enterName.
  ///
  /// In tr, this message translates to:
  /// **'Adınızı girin'**
  String get enterName;

  /// No description provided for @name.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get name;

  /// No description provided for @birthDate.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi'**
  String get birthDate;

  /// No description provided for @lastPeriodDate.
  ///
  /// In tr, this message translates to:
  /// **'Son Adet Tarihi'**
  String get lastPeriodDate;

  /// No description provided for @averageCycleLength.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Döngü Süresi'**
  String get averageCycleLength;

  /// No description provided for @averagePeriodLength.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama Adet Süresi'**
  String get averagePeriodLength;

  /// No description provided for @days.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get days;

  /// No description provided for @day.
  ///
  /// In tr, this message translates to:
  /// **'gün'**
  String get day;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @cycleDay.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Günü'**
  String get cycleDay;

  /// No description provided for @periodIn.
  ///
  /// In tr, this message translates to:
  /// **'Adet başlamasına'**
  String get periodIn;

  /// No description provided for @daysLeft.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün kaldı'**
  String daysLeft(int count);

  /// No description provided for @periodToday.
  ///
  /// In tr, this message translates to:
  /// **'Adetiniz bugün başlayabilir'**
  String get periodToday;

  /// No description provided for @periodOngoing.
  ///
  /// In tr, this message translates to:
  /// **'Adet dönemindesiniz'**
  String get periodOngoing;

  /// No description provided for @ovulationDay.
  ///
  /// In tr, this message translates to:
  /// **'Ovulasyon Günü'**
  String get ovulationDay;

  /// No description provided for @fertileWindow.
  ///
  /// In tr, this message translates to:
  /// **'Verimli Pencere'**
  String get fertileWindow;

  /// No description provided for @lutealPhase.
  ///
  /// In tr, this message translates to:
  /// **'Luteal Faz'**
  String get lutealPhase;

  /// No description provided for @follicularPhase.
  ///
  /// In tr, this message translates to:
  /// **'Foliküler Faz'**
  String get follicularPhase;

  /// No description provided for @periodPhase.
  ///
  /// In tr, this message translates to:
  /// **'Adet Fazı'**
  String get periodPhase;

  /// No description provided for @logPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Adet Kaydet'**
  String get logPeriod;

  /// No description provided for @periodStarted.
  ///
  /// In tr, this message translates to:
  /// **'Adet Başladı'**
  String get periodStarted;

  /// No description provided for @periodEnded.
  ///
  /// In tr, this message translates to:
  /// **'Adet Bitti'**
  String get periodEnded;

  /// No description provided for @flowIntensity.
  ///
  /// In tr, this message translates to:
  /// **'Akış Yoğunluğu'**
  String get flowIntensity;

  /// No description provided for @light.
  ///
  /// In tr, this message translates to:
  /// **'Hafif'**
  String get light;

  /// No description provided for @medium.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get medium;

  /// No description provided for @heavy.
  ///
  /// In tr, this message translates to:
  /// **'Yoğun'**
  String get heavy;

  /// No description provided for @veryHeavy.
  ///
  /// In tr, this message translates to:
  /// **'Çok Yoğun'**
  String get veryHeavy;

  /// No description provided for @spotting.
  ///
  /// In tr, this message translates to:
  /// **'Lekelenme'**
  String get spotting;

  /// No description provided for @symptoms.
  ///
  /// In tr, this message translates to:
  /// **'Belirtiler'**
  String get symptoms;

  /// No description provided for @mood.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali'**
  String get mood;

  /// No description provided for @temperature.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık'**
  String get temperature;

  /// No description provided for @weight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo'**
  String get weight;

  /// No description provided for @waterIntake.
  ///
  /// In tr, this message translates to:
  /// **'Su Tüketimi'**
  String get waterIntake;

  /// No description provided for @sleep.
  ///
  /// In tr, this message translates to:
  /// **'Uyku'**
  String get sleep;

  /// No description provided for @sexualActivity.
  ///
  /// In tr, this message translates to:
  /// **'Cinsel Aktivite'**
  String get sexualActivity;

  /// No description provided for @medication.
  ///
  /// In tr, this message translates to:
  /// **'İlaç'**
  String get medication;

  /// No description provided for @notes.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notes;

  /// No description provided for @cramps.
  ///
  /// In tr, this message translates to:
  /// **'Kramp'**
  String get cramps;

  /// No description provided for @headache.
  ///
  /// In tr, this message translates to:
  /// **'Baş Ağrısı'**
  String get headache;

  /// No description provided for @bloating.
  ///
  /// In tr, this message translates to:
  /// **'Şişkinlik'**
  String get bloating;

  /// No description provided for @breastTenderness.
  ///
  /// In tr, this message translates to:
  /// **'Göğüs Hassasiyeti'**
  String get breastTenderness;

  /// No description provided for @backPain.
  ///
  /// In tr, this message translates to:
  /// **'Bel Ağrısı'**
  String get backPain;

  /// No description provided for @fatigue.
  ///
  /// In tr, this message translates to:
  /// **'Yorgunluk'**
  String get fatigue;

  /// No description provided for @nausea.
  ///
  /// In tr, this message translates to:
  /// **'Mide Bulantısı'**
  String get nausea;

  /// No description provided for @dizziness.
  ///
  /// In tr, this message translates to:
  /// **'Baş Dönmesi'**
  String get dizziness;

  /// No description provided for @stress.
  ///
  /// In tr, this message translates to:
  /// **'Stres'**
  String get stress;

  /// No description provided for @anxiety.
  ///
  /// In tr, this message translates to:
  /// **'Anksiyete'**
  String get anxiety;

  /// No description provided for @irritability.
  ///
  /// In tr, this message translates to:
  /// **'Huzursuzluk'**
  String get irritability;

  /// No description provided for @crying.
  ///
  /// In tr, this message translates to:
  /// **'Ağlama'**
  String get crying;

  /// No description provided for @sensitivity.
  ///
  /// In tr, this message translates to:
  /// **'Hassasiyet'**
  String get sensitivity;

  /// No description provided for @acne.
  ///
  /// In tr, this message translates to:
  /// **'Akne'**
  String get acne;

  /// No description provided for @oilySkin.
  ///
  /// In tr, this message translates to:
  /// **'Yağlı Cilt'**
  String get oilySkin;

  /// No description provided for @drySkin.
  ///
  /// In tr, this message translates to:
  /// **'Kuru Cilt'**
  String get drySkin;

  /// No description provided for @constipation.
  ///
  /// In tr, this message translates to:
  /// **'Kabızlık'**
  String get constipation;

  /// No description provided for @diarrhea.
  ///
  /// In tr, this message translates to:
  /// **'İshal'**
  String get diarrhea;

  /// No description provided for @gas.
  ///
  /// In tr, this message translates to:
  /// **'Gaz'**
  String get gas;

  /// No description provided for @increasedAppetite.
  ///
  /// In tr, this message translates to:
  /// **'İştah Artışı'**
  String get increasedAppetite;

  /// No description provided for @decreasedAppetite.
  ///
  /// In tr, this message translates to:
  /// **'İştah Azalışı'**
  String get decreasedAppetite;

  /// No description provided for @insomnia.
  ///
  /// In tr, this message translates to:
  /// **'Uykusuzluk'**
  String get insomnia;

  /// No description provided for @hotFlash.
  ///
  /// In tr, this message translates to:
  /// **'Sıcak Basması'**
  String get hotFlash;

  /// No description provided for @swelling.
  ///
  /// In tr, this message translates to:
  /// **'Ödem'**
  String get swelling;

  /// No description provided for @hairLoss.
  ///
  /// In tr, this message translates to:
  /// **'Saç Dökülmesi'**
  String get hairLoss;

  /// No description provided for @happy.
  ///
  /// In tr, this message translates to:
  /// **'Mutlu'**
  String get happy;

  /// No description provided for @sad.
  ///
  /// In tr, this message translates to:
  /// **'Üzgün'**
  String get sad;

  /// No description provided for @angry.
  ///
  /// In tr, this message translates to:
  /// **'Sinirli'**
  String get angry;

  /// No description provided for @anxious.
  ///
  /// In tr, this message translates to:
  /// **'Endişeli'**
  String get anxious;

  /// No description provided for @calm.
  ///
  /// In tr, this message translates to:
  /// **'Sakin'**
  String get calm;

  /// No description provided for @energetic.
  ///
  /// In tr, this message translates to:
  /// **'Enerjik'**
  String get energetic;

  /// No description provided for @tired.
  ///
  /// In tr, this message translates to:
  /// **'Yorgun'**
  String get tired;

  /// No description provided for @romantic.
  ///
  /// In tr, this message translates to:
  /// **'Romantik'**
  String get romantic;

  /// No description provided for @confused.
  ///
  /// In tr, this message translates to:
  /// **'Kafası Karışık'**
  String get confused;

  /// No description provided for @confident.
  ///
  /// In tr, this message translates to:
  /// **'Özgüvenli'**
  String get confident;

  /// No description provided for @avgCycleLength.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Döngü Süresi'**
  String get avgCycleLength;

  /// No description provided for @avgPeriodLength.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Adet Süresi'**
  String get avgPeriodLength;

  /// No description provided for @cycleHistory.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Geçmişi'**
  String get cycleHistory;

  /// No description provided for @symptomFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Belirti Sıklığı'**
  String get symptomFrequency;

  /// No description provided for @moodDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Ruh Hali Dağılımı'**
  String get moodDistribution;

  /// No description provided for @temperatureTrend.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık Trendi'**
  String get temperatureTrend;

  /// No description provided for @weightTrend.
  ///
  /// In tr, this message translates to:
  /// **'Kilo Trendi'**
  String get weightTrend;

  /// No description provided for @last3Months.
  ///
  /// In tr, this message translates to:
  /// **'Son 3 Ay'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In tr, this message translates to:
  /// **'Son 6 Ay'**
  String get last6Months;

  /// No description provided for @last12Months.
  ///
  /// In tr, this message translates to:
  /// **'Son 12 Ay'**
  String get last12Months;

  /// No description provided for @exportData.
  ///
  /// In tr, this message translates to:
  /// **'Veri Dışa Aktar'**
  String get exportData;

  /// No description provided for @exportPdf.
  ///
  /// In tr, this message translates to:
  /// **'PDF Raporu'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In tr, this message translates to:
  /// **'CSV Dosyası'**
  String get exportCsv;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get darkTheme;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @periodReminder.
  ///
  /// In tr, this message translates to:
  /// **'Adet Hatırlatması'**
  String get periodReminder;

  /// No description provided for @ovulationReminder.
  ///
  /// In tr, this message translates to:
  /// **'Ovulasyon Hatırlatması'**
  String get ovulationReminder;

  /// No description provided for @medicationReminder.
  ///
  /// In tr, this message translates to:
  /// **'İlaç Hatırlatması'**
  String get medicationReminder;

  /// No description provided for @waterReminder.
  ///
  /// In tr, this message translates to:
  /// **'Su Hatırlatması'**
  String get waterReminder;

  /// No description provided for @security.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik'**
  String get security;

  /// No description provided for @pinLock.
  ///
  /// In tr, this message translates to:
  /// **'PIN Kilidi'**
  String get pinLock;

  /// No description provided for @biometricLock.
  ///
  /// In tr, this message translates to:
  /// **'Biyometrik Kilit'**
  String get biometricLock;

  /// No description provided for @dataBackup.
  ///
  /// In tr, this message translates to:
  /// **'Veri Yedekleme'**
  String get dataBackup;

  /// No description provided for @deleteAllData.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Verileri Sil'**
  String get deleteAllData;

  /// No description provided for @about.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get about;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Versiyon'**
  String get version;

  /// No description provided for @glasses.
  ///
  /// In tr, this message translates to:
  /// **'bardak'**
  String get glasses;

  /// No description provided for @dailyGoal.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Hedef'**
  String get dailyGoal;

  /// No description provided for @sleepQuality.
  ///
  /// In tr, this message translates to:
  /// **'Uyku Kalitesi'**
  String get sleepQuality;

  /// No description provided for @bedTime.
  ///
  /// In tr, this message translates to:
  /// **'Yatış Saati'**
  String get bedTime;

  /// No description provided for @wakeTime.
  ///
  /// In tr, this message translates to:
  /// **'Kalkış Saati'**
  String get wakeTime;

  /// No description provided for @totalSleep.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Uyku'**
  String get totalSleep;

  /// No description provided for @hours.
  ///
  /// In tr, this message translates to:
  /// **'saat'**
  String get hours;

  /// No description provided for @protection.
  ///
  /// In tr, this message translates to:
  /// **'Korunma'**
  String get protection;

  /// No description provided for @condom.
  ///
  /// In tr, this message translates to:
  /// **'Kondom'**
  String get condom;

  /// No description provided for @pill.
  ///
  /// In tr, this message translates to:
  /// **'Hap'**
  String get pill;

  /// No description provided for @iud.
  ///
  /// In tr, this message translates to:
  /// **'Spiral (IUD)'**
  String get iud;

  /// No description provided for @none.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get none;

  /// No description provided for @other.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get other;

  /// No description provided for @medicationName.
  ///
  /// In tr, this message translates to:
  /// **'İlaç Adı'**
  String get medicationName;

  /// No description provided for @dose.
  ///
  /// In tr, this message translates to:
  /// **'Doz'**
  String get dose;

  /// No description provided for @reminderTime.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatma Saati'**
  String get reminderTime;

  /// No description provided for @taken.
  ///
  /// In tr, this message translates to:
  /// **'Alındı'**
  String get taken;

  /// No description provided for @notTaken.
  ///
  /// In tr, this message translates to:
  /// **'Alınmadı'**
  String get notTaken;

  /// No description provided for @addNote.
  ///
  /// In tr, this message translates to:
  /// **'Not Ekle'**
  String get addNote;

  /// No description provided for @selectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seç'**
  String get selectDate;

  /// No description provided for @noDataYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz veri yok'**
  String get noDataYet;

  /// No description provided for @predictions.
  ///
  /// In tr, this message translates to:
  /// **'Tahminler'**
  String get predictions;

  /// No description provided for @nextPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Adet'**
  String get nextPeriod;

  /// No description provided for @nextOvulation.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Ovulasyon'**
  String get nextOvulation;

  /// No description provided for @cycleRegularity.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Düzenliliği'**
  String get cycleRegularity;

  /// No description provided for @regular.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli'**
  String get regular;

  /// No description provided for @irregular.
  ///
  /// In tr, this message translates to:
  /// **'Düzensiz'**
  String get irregular;

  /// No description provided for @setupComplete.
  ///
  /// In tr, this message translates to:
  /// **'Kurulum Tamamlandı!'**
  String get setupComplete;

  /// No description provided for @letsStart.
  ///
  /// In tr, this message translates to:
  /// **'Haydi Başlayalım'**
  String get letsStart;

  /// No description provided for @bmi.
  ///
  /// In tr, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @goalReached.
  ///
  /// In tr, this message translates to:
  /// **'Hedefe ulaşıldı!'**
  String get goalReached;

  /// No description provided for @helloGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba!'**
  String get helloGeneric;

  /// No description provided for @dayHasRecord.
  ///
  /// In tr, this message translates to:
  /// **'kayıt var'**
  String get dayHasRecord;

  /// No description provided for @increase.
  ///
  /// In tr, this message translates to:
  /// **'Artır'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In tr, this message translates to:
  /// **'Azalt'**
  String get decrease;

  /// No description provided for @bbtHint.
  ///
  /// In tr, this message translates to:
  /// **'En doğru sonuç için sabah uyanır uyanmaz, yataktan kalkmadan ve hep aynı saatte ölç. Ovülasyon teyidi bu ölçümlere dayanır.'**
  String get bbtHint;

  /// No description provided for @deleteMeasurement.
  ///
  /// In tr, this message translates to:
  /// **'Ölçümü sil'**
  String get deleteMeasurement;

  /// No description provided for @measurementDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Ölçüm silindi'**
  String get measurementDeleted;

  /// No description provided for @deleteRecord.
  ///
  /// In tr, this message translates to:
  /// **'Kaydı sil'**
  String get deleteRecord;

  /// No description provided for @recordDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt silindi'**
  String get recordDeleted;

  /// No description provided for @invalidWeight.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir kilo gir (20-300 kg)'**
  String get invalidWeight;

  /// No description provided for @discardChangesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilmemiş değişiklik'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In tr, this message translates to:
  /// **'Notun kaydedilmedi. Çıkarsan yazdıkların kaybolacak.'**
  String get discardChangesBody;

  /// No description provided for @discard.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get discard;

  /// No description provided for @severityLevel.
  ///
  /// In tr, this message translates to:
  /// **'şiddet {level}/5'**
  String severityLevel(int level);

  /// No description provided for @pregnancySetStartPrompt.
  ///
  /// In tr, this message translates to:
  /// **'Gebelik başlangıcını girmek için dokun'**
  String get pregnancySetStartPrompt;

  /// No description provided for @helloName.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name}!'**
  String helloName(String name);

  /// No description provided for @ovulationPhase.
  ///
  /// In tr, this message translates to:
  /// **'Ovülasyon Fazı'**
  String get ovulationPhase;

  /// No description provided for @menstrualPhase.
  ///
  /// In tr, this message translates to:
  /// **'Menstrüel Faz'**
  String get menstrualPhase;

  /// No description provided for @todaySummary.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Özeti'**
  String get todaySummary;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In tr, this message translates to:
  /// **'Bugün nasıl hissediyorsun?'**
  String get howAreYouFeeling;

  /// No description provided for @logMoodAndSymptoms.
  ///
  /// In tr, this message translates to:
  /// **'Ruh halini ve belirtilerini kaydet'**
  String get logMoodAndSymptoms;

  /// No description provided for @addRecord.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ekle'**
  String get addRecord;

  /// No description provided for @nSymptoms.
  ///
  /// In tr, this message translates to:
  /// **'{count} belirti'**
  String nSymptoms(int count);

  /// No description provided for @periodDayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adet günü'**
  String get periodDayLabel;

  /// No description provided for @predicted.
  ///
  /// In tr, this message translates to:
  /// **'Tahmini'**
  String get predicted;

  /// No description provided for @fertile.
  ///
  /// In tr, this message translates to:
  /// **'Verimli'**
  String get fertile;

  /// No description provided for @ovulation.
  ///
  /// In tr, this message translates to:
  /// **'Ovülasyon'**
  String get ovulation;

  /// No description provided for @moodLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ruh hali: {mood}'**
  String moodLabel(String mood);

  /// No description provided for @nGlassesWater.
  ///
  /// In tr, this message translates to:
  /// **'{count} bardak su'**
  String nGlassesWater(int count);

  /// No description provided for @noRecordForDay.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün için kayıt bulunmuyor.'**
  String get noRecordForDay;

  /// No description provided for @dailyLog.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Kayıt'**
  String get dailyLog;

  /// No description provided for @flow.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get flow;

  /// No description provided for @recorded.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get recorded;

  /// No description provided for @nMedications.
  ///
  /// In tr, this message translates to:
  /// **'{count} ilaç'**
  String nMedications(int count);

  /// No description provided for @nGlasses.
  ///
  /// In tr, this message translates to:
  /// **'{count} bardak'**
  String nGlasses(int count);

  /// No description provided for @flowTracking.
  ///
  /// In tr, this message translates to:
  /// **'Akış Takibi'**
  String get flowTracking;

  /// No description provided for @color.
  ///
  /// In tr, this message translates to:
  /// **'Renk'**
  String get color;

  /// No description provided for @lightRed.
  ///
  /// In tr, this message translates to:
  /// **'Açık Kırmızı'**
  String get lightRed;

  /// No description provided for @red.
  ///
  /// In tr, this message translates to:
  /// **'Kırmızı'**
  String get red;

  /// No description provided for @darkRed.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get darkRed;

  /// No description provided for @brown.
  ///
  /// In tr, this message translates to:
  /// **'Kahverengi'**
  String get brown;

  /// No description provided for @clots.
  ///
  /// In tr, this message translates to:
  /// **'Pıhtı'**
  String get clots;

  /// No description provided for @clotsQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Pıhtı var mı?'**
  String get clotsQuestion;

  /// No description provided for @padChange.
  ///
  /// In tr, this message translates to:
  /// **'Ped Değişimi'**
  String get padChange;

  /// No description provided for @flowSaved.
  ///
  /// In tr, this message translates to:
  /// **'Akış kaydedildi'**
  String get flowSaved;

  /// No description provided for @symptomTracking.
  ///
  /// In tr, this message translates to:
  /// **'Belirti Takibi'**
  String get symptomTracking;

  /// No description provided for @physical.
  ///
  /// In tr, this message translates to:
  /// **'Fiziksel'**
  String get physical;

  /// No description provided for @emotional.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal'**
  String get emotional;

  /// No description provided for @skinCategory.
  ///
  /// In tr, this message translates to:
  /// **'Cilt'**
  String get skinCategory;

  /// No description provided for @digestive.
  ///
  /// In tr, this message translates to:
  /// **'Sindirim'**
  String get digestive;

  /// No description provided for @otherCategory.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get otherCategory;

  /// No description provided for @glowingSkin.
  ///
  /// In tr, this message translates to:
  /// **'Parlak Cilt'**
  String get glowingSkin;

  /// No description provided for @saveNSymptoms.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet ({count} belirti)'**
  String saveNSymptoms(int count);

  /// No description provided for @nSymptomsSaved.
  ///
  /// In tr, this message translates to:
  /// **'{count} belirti kaydedildi'**
  String nSymptomsSaved(int count);

  /// No description provided for @addNoteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not ekle (opsiyonel)'**
  String get addNoteOptional;

  /// No description provided for @writeAboutToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün hakkında bir şeyler yaz...'**
  String get writeAboutToday;

  /// No description provided for @moodSaved.
  ///
  /// In tr, this message translates to:
  /// **'Ruh hali kaydedildi'**
  String get moodSaved;

  /// No description provided for @sensitiveM.
  ///
  /// In tr, this message translates to:
  /// **'Hassas'**
  String get sensitiveM;

  /// No description provided for @irritableM.
  ///
  /// In tr, this message translates to:
  /// **'Gergin'**
  String get irritableM;

  /// No description provided for @neutralM.
  ///
  /// In tr, this message translates to:
  /// **'Nötr'**
  String get neutralM;

  /// No description provided for @lowTemp.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get lowTemp;

  /// No description provided for @normalTemp.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get normalTemp;

  /// No description provided for @highTemp.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get highTemp;

  /// No description provided for @fever.
  ///
  /// In tr, this message translates to:
  /// **'Ateş'**
  String get fever;

  /// No description provided for @measurementTime.
  ///
  /// In tr, this message translates to:
  /// **'Ölçüm Saati'**
  String get measurementTime;

  /// No description provided for @temperatureSaved.
  ///
  /// In tr, this message translates to:
  /// **'Sıcaklık kaydedildi'**
  String get temperatureSaved;

  /// No description provided for @quickAdjust.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Ayar'**
  String get quickAdjust;

  /// No description provided for @manualEntry.
  ///
  /// In tr, this message translates to:
  /// **'Manuel Giriş'**
  String get manualEntry;

  /// No description provided for @weightSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kilo kaydedildi'**
  String get weightSaved;

  /// No description provided for @waterTracking.
  ///
  /// In tr, this message translates to:
  /// **'Su Takibi'**
  String get waterTracking;

  /// No description provided for @waterSaved.
  ///
  /// In tr, this message translates to:
  /// **'Su kaydedildi'**
  String get waterSaved;

  /// No description provided for @sleepTracking.
  ///
  /// In tr, this message translates to:
  /// **'Uyku Takibi'**
  String get sleepTracking;

  /// No description provided for @bedTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yatış'**
  String get bedTimeLabel;

  /// No description provided for @wakeTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kalkış'**
  String get wakeTimeLabel;

  /// No description provided for @veryBad.
  ///
  /// In tr, this message translates to:
  /// **'Çok Kötü'**
  String get veryBad;

  /// No description provided for @bad.
  ///
  /// In tr, this message translates to:
  /// **'Kötü'**
  String get bad;

  /// No description provided for @moderate.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get moderate;

  /// No description provided for @good.
  ///
  /// In tr, this message translates to:
  /// **'İyi'**
  String get good;

  /// No description provided for @great.
  ///
  /// In tr, this message translates to:
  /// **'Harika'**
  String get great;

  /// No description provided for @sleepSaved.
  ///
  /// In tr, this message translates to:
  /// **'Uyku kaydedildi'**
  String get sleepSaved;

  /// No description provided for @protectionMethod.
  ///
  /// In tr, this message translates to:
  /// **'Korunma Yöntemi'**
  String get protectionMethod;

  /// No description provided for @orgasm.
  ///
  /// In tr, this message translates to:
  /// **'Orgazm'**
  String get orgasm;

  /// No description provided for @noteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not (opsiyonel)'**
  String get noteOptional;

  /// No description provided for @addNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Not ekle...'**
  String get addNoteHint;

  /// No description provided for @savedGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get savedGeneric;

  /// No description provided for @medicationTracking.
  ///
  /// In tr, this message translates to:
  /// **'İlaç Takibi'**
  String get medicationTracking;

  /// No description provided for @addMedication.
  ///
  /// In tr, this message translates to:
  /// **'İlaç Ekle'**
  String get addMedication;

  /// No description provided for @noMedicationsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ilaç eklenmedi'**
  String get noMedicationsYet;

  /// No description provided for @tapToAdd.
  ///
  /// In tr, this message translates to:
  /// **'+ butonuna dokunarak ekleyin'**
  String get tapToAdd;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @dailyNote.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Not'**
  String get dailyNote;

  /// No description provided for @myNotes.
  ///
  /// In tr, this message translates to:
  /// **'Notlarım'**
  String get myNotes;

  /// No description provided for @notesHint.
  ///
  /// In tr, this message translates to:
  /// **'Bugün nasıl hissediyorsun? Notlarını buraya yaz...'**
  String get notesHint;

  /// No description provided for @noteSaved.
  ///
  /// In tr, this message translates to:
  /// **'Not kaydedildi'**
  String get noteSaved;

  /// No description provided for @cycleOverview.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Özeti'**
  String get cycleOverview;

  /// No description provided for @avgCycle.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Döngü'**
  String get avgCycle;

  /// No description provided for @avgPeriod.
  ///
  /// In tr, this message translates to:
  /// **'Ort. Adet'**
  String get avgPeriod;

  /// No description provided for @regularity.
  ///
  /// In tr, this message translates to:
  /// **'Düzenlilik'**
  String get regularity;

  /// No description provided for @insufficientData.
  ///
  /// In tr, this message translates to:
  /// **'Veri az'**
  String get insufficientData;

  /// No description provided for @noSymptomData.
  ///
  /// In tr, this message translates to:
  /// **'Henüz belirti verisi yok'**
  String get noSymptomData;

  /// No description provided for @noMoodData.
  ///
  /// In tr, this message translates to:
  /// **'Henüz ruh hali verisi yok'**
  String get noMoodData;

  /// No description provided for @noCycleData.
  ///
  /// In tr, this message translates to:
  /// **'Henüz döngü verisi yok'**
  String get noCycleData;

  /// No description provided for @ongoing.
  ///
  /// In tr, this message translates to:
  /// **'devam ediyor'**
  String get ongoing;

  /// No description provided for @nDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String nDays(int count);

  /// No description provided for @profileSection.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileSection;

  /// No description provided for @preferences.
  ///
  /// In tr, this message translates to:
  /// **'Tercihler'**
  String get preferences;

  /// No description provided for @age.
  ///
  /// In tr, this message translates to:
  /// **'Yaş'**
  String get age;

  /// No description provided for @nYearsOld.
  ///
  /// In tr, this message translates to:
  /// **'{count} yaş'**
  String nYearsOld(int count);

  /// No description provided for @cycleDuration.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Süresi'**
  String get cycleDuration;

  /// No description provided for @periodDuration.
  ///
  /// In tr, this message translates to:
  /// **'Adet Süresi'**
  String get periodDuration;

  /// No description provided for @dataSection.
  ///
  /// In tr, this message translates to:
  /// **'Veri'**
  String get dataSection;

  /// No description provided for @exportPdfReport.
  ///
  /// In tr, this message translates to:
  /// **'PDF Raporu Dışa Aktar'**
  String get exportPdfReport;

  /// No description provided for @exportCsvFile.
  ///
  /// In tr, this message translates to:
  /// **'CSV Dışa Aktar'**
  String get exportCsvFile;

  /// No description provided for @pdfExportSoon.
  ///
  /// In tr, this message translates to:
  /// **'PDF dışa aktarma yakında!'**
  String get pdfExportSoon;

  /// No description provided for @csvExportSoon.
  ///
  /// In tr, this message translates to:
  /// **'CSV dışa aktarma yakında!'**
  String get csvExportSoon;

  /// No description provided for @letsKnowYou.
  ///
  /// In tr, this message translates to:
  /// **'Seni Tanıyalım'**
  String get letsKnowYou;

  /// No description provided for @whatShouldWeCallYou.
  ///
  /// In tr, this message translates to:
  /// **'Sana nasıl hitap edelim?'**
  String get whatShouldWeCallYou;

  /// No description provided for @yourName.
  ///
  /// In tr, this message translates to:
  /// **'Adın'**
  String get yourName;

  /// No description provided for @yourBirthDate.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihin'**
  String get yourBirthDate;

  /// No description provided for @birthDateHelp.
  ///
  /// In tr, this message translates to:
  /// **'Yaşa uygun öneriler sunmamıza yardımcı olur.'**
  String get birthDateHelp;

  /// No description provided for @selectDateHint.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seç'**
  String get selectDateHint;

  /// No description provided for @selectDateToContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için bir tarih seç'**
  String get selectDateToContinue;

  /// No description provided for @stepOfSteps.
  ///
  /// In tr, this message translates to:
  /// **'Adım {current} / {total}'**
  String stepOfSteps(int current, int total);

  /// No description provided for @lastPeriodTitle.
  ///
  /// In tr, this message translates to:
  /// **'Son Regl Tarihin'**
  String get lastPeriodTitle;

  /// No description provided for @lastPeriodHelp.
  ///
  /// In tr, this message translates to:
  /// **'En son regl döngünün başlangıç tarihini seç.'**
  String get lastPeriodHelp;

  /// No description provided for @cycleLengthTitle.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Süresi'**
  String get cycleLengthTitle;

  /// No description provided for @cycleLengthHelp.
  ///
  /// In tr, this message translates to:
  /// **'Regl döngün ortalama kaç gün sürer?\n(Bir reglin ilk gününden sonraki reglin ilk gününe kadar)'**
  String get cycleLengthHelp;

  /// No description provided for @periodLengthTitle.
  ///
  /// In tr, this message translates to:
  /// **'Regl Süresi'**
  String get periodLengthTitle;

  /// No description provided for @periodLengthHelp.
  ///
  /// In tr, this message translates to:
  /// **'Reglin ortalama kaç gün sürer?'**
  String get periodLengthHelp;

  /// No description provided for @averageLabel.
  ///
  /// In tr, this message translates to:
  /// **'ortalama'**
  String get averageLabel;

  /// No description provided for @completeBtn.
  ///
  /// In tr, this message translates to:
  /// **'Tamamla'**
  String get completeBtn;

  /// No description provided for @continueBtn.
  ///
  /// In tr, this message translates to:
  /// **'Devam Et'**
  String get continueBtn;

  /// No description provided for @errorOccurred.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu: {error}'**
  String errorOccurred(String error);

  /// No description provided for @welcomeInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş Geldin!'**
  String get welcomeInfoTitle;

  /// No description provided for @welcomeInfoDesc.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığını takip etmenin en kolay ve en güzel yolu. Döngünün her anında yanındayız.'**
  String get welcomeInfoDesc;

  /// No description provided for @trackCycleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Döngünü Takip Et'**
  String get trackCycleTitle;

  /// No description provided for @trackCycleDesc.
  ///
  /// In tr, this message translates to:
  /// **'Regl tarihlerini, belirtilerini ve ruh halini kolayca kaydet. Tüm verilerin güvende.'**
  String get trackCycleDesc;

  /// No description provided for @getPredictionsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tahminler Al'**
  String get getPredictionsTitle;

  /// No description provided for @getPredictionsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir sonraki döngünü ve verimli günlerini akıllı tahminlerle öğren.'**
  String get getPredictionsDesc;

  /// No description provided for @startBtn.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get startBtn;

  /// No description provided for @daysLater.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün sonra'**
  String daysLater(int count);

  /// No description provided for @todayExclamation.
  ///
  /// In tr, this message translates to:
  /// **'Bugün!'**
  String get todayExclamation;

  /// No description provided for @spiral.
  ///
  /// In tr, this message translates to:
  /// **'Spiral'**
  String get spiral;

  /// No description provided for @enterPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN Girin'**
  String get enterPin;

  /// No description provided for @createPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN Oluşturun'**
  String get createPin;

  /// No description provided for @confirmPin.
  ///
  /// In tr, this message translates to:
  /// **'PIN Onaylayın'**
  String get confirmPin;

  /// No description provided for @pinMismatch.
  ///
  /// In tr, this message translates to:
  /// **'PIN\'ler eşleşmiyor, tekrar deneyin'**
  String get pinMismatch;

  /// No description provided for @verifyPinTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut PIN\'inizi girin'**
  String get verifyPinTitle;

  /// No description provided for @wrongPin.
  ///
  /// In tr, this message translates to:
  /// **'Yanlış PIN'**
  String get wrongPin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla yanlış deneme. {seconds} saniye bekleyin'**
  String tooManyAttempts(int seconds);

  /// No description provided for @coachMenstrual0.
  ///
  /// In tr, this message translates to:
  /// **'Kanama günlerinde demir kaybı olur — kırmızı et, mercimek ve koyu yeşil yapraklılar iyi gelir.'**
  String get coachMenstrual0;

  /// No description provided for @coachMenstrual1.
  ///
  /// In tr, this message translates to:
  /// **'Kramplar için sıcak uygulama ve hafif esneme, çoğu ağrı kesici kadar etkili olabilir.'**
  String get coachMenstrual1;

  /// No description provided for @coachMenstrual2.
  ///
  /// In tr, this message translates to:
  /// **'Enerjin düşükse bu normal — bugün yoğun antrenman yerine yürüyüş yeterli.'**
  String get coachMenstrual2;

  /// No description provided for @coachFollicular0.
  ///
  /// In tr, this message translates to:
  /// **'Östrojen yükselişte: enerji ve odak genelde bu fazda zirve yapar. Zor işleri bugünlere planla.'**
  String get coachFollicular0;

  /// No description provided for @coachFollicular1.
  ///
  /// In tr, this message translates to:
  /// **'Cilt bu fazda genelde en iyi halinde — yeni ürün denemek için uygun dönem.'**
  String get coachFollicular1;

  /// No description provided for @coachFollicular2.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek tempolu egzersizler için vücudun en hazır olduğu dönemdesin.'**
  String get coachFollicular2;

  /// No description provided for @coachOvulation0.
  ///
  /// In tr, this message translates to:
  /// **'Doğurgan penceredesin — korunma ya da gebelik planı ne ise ona göre davran.'**
  String get coachOvulation0;

  /// No description provided for @coachOvulation1.
  ///
  /// In tr, this message translates to:
  /// **'Bazı kadınlar ovülasyonda tek taraflı hafif ağrı hisseder (mittelschmerz) — normaldir.'**
  String get coachOvulation1;

  /// No description provided for @coachOvulation2.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal enerji bu günlerde genelde yüksek — önemli görüşmeler için iyi zamanlama.'**
  String get coachOvulation2;

  /// No description provided for @coachLuteal0.
  ///
  /// In tr, this message translates to:
  /// **'PMS belirtileri bu fazda başlayabilir — magnezyum ve düzenli uyku belirtileri hafifletebilir.'**
  String get coachLuteal0;

  /// No description provided for @coachLuteal1.
  ///
  /// In tr, this message translates to:
  /// **'Tatlı isteği artabilir: kan şekerini dengede tutmak için protein ağırlıklı ara öğün dene.'**
  String get coachLuteal1;

  /// No description provided for @coachLuteal2.
  ///
  /// In tr, this message translates to:
  /// **'Duygusal hassasiyet artabilir — kendine yüklenme, bu hormonal ve geçici.'**
  String get coachLuteal2;

  /// No description provided for @ovulationConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'Ovülasyon ✓'**
  String get ovulationConfirmed;

  /// No description provided for @ovulationConfirmedInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bu tarih tahmini değil: bazal vücut sıcaklığı ölçümlerinizdeki yükselişten teyit edildi (3-üstü-6 kuralı).'**
  String get ovulationConfirmedInfo;

  /// No description provided for @premiumSection.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premiumSection;

  /// No description provided for @removeAds.
  ///
  /// In tr, this message translates to:
  /// **'Reklamları Kaldır'**
  String get removeAds;

  /// No description provided for @restorePurchases.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımları Geri Yükle'**
  String get restorePurchases;

  /// No description provided for @premiumActive.
  ///
  /// In tr, this message translates to:
  /// **'Premium aktif — reklamlar kapalı'**
  String get premiumActive;

  /// No description provided for @storeUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Mağaza şu anda kullanılamıyor'**
  String get storeUnavailable;

  /// No description provided for @healthSync.
  ///
  /// In tr, this message translates to:
  /// **'Health Connect\'e Aktar'**
  String get healthSync;

  /// No description provided for @healthSyncSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Adet verileri aktarıldı'**
  String get healthSyncSuccess;

  /// No description provided for @healthSyncDenied.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık verisi izni verilmedi'**
  String get healthSyncDenied;

  /// No description provided for @healthSyncUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda sağlık servisi yok'**
  String get healthSyncUnavailable;

  /// No description provided for @healthSyncFailed.
  ///
  /// In tr, this message translates to:
  /// **'Aktarım başarısız oldu'**
  String get healthSyncFailed;

  /// No description provided for @trackingModeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takip Modu'**
  String get trackingModeTitle;

  /// No description provided for @modePeriod.
  ///
  /// In tr, this message translates to:
  /// **'Regl'**
  String get modePeriod;

  /// No description provided for @modePregnancy.
  ///
  /// In tr, this message translates to:
  /// **'Hamilelik'**
  String get modePregnancy;

  /// No description provided for @modePill.
  ///
  /// In tr, this message translates to:
  /// **'Hap'**
  String get modePill;

  /// No description provided for @modeTtc.
  ///
  /// In tr, this message translates to:
  /// **'Bebek Planı'**
  String get modeTtc;

  /// No description provided for @lhTestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ovülasyon (LH) Testi'**
  String get lhTestTitle;

  /// No description provided for @lhPositive.
  ///
  /// In tr, this message translates to:
  /// **'Pozitif'**
  String get lhPositive;

  /// No description provided for @lhNegative.
  ///
  /// In tr, this message translates to:
  /// **'Negatif'**
  String get lhNegative;

  /// No description provided for @fertilityToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü doğurganlık'**
  String get fertilityToday;

  /// No description provided for @fertilityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get fertilityHigh;

  /// No description provided for @fertilityMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get fertilityMedium;

  /// No description provided for @fertilityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get fertilityLow;

  /// No description provided for @pregnancyWeekLabel.
  ///
  /// In tr, this message translates to:
  /// **'{week}. hafta'**
  String pregnancyWeekLabel(int week);

  /// No description provided for @trimester1.
  ///
  /// In tr, this message translates to:
  /// **'1. Trimester'**
  String get trimester1;

  /// No description provided for @trimester2.
  ///
  /// In tr, this message translates to:
  /// **'2. Trimester'**
  String get trimester2;

  /// No description provided for @trimester3.
  ///
  /// In tr, this message translates to:
  /// **'3. Trimester'**
  String get trimester3;

  /// No description provided for @pregnancyStartLabel.
  ///
  /// In tr, this message translates to:
  /// **'Son adet tarihi (gebelik başlangıcı)'**
  String get pregnancyStartLabel;

  /// No description provided for @pregnancyModeInfo.
  ///
  /// In tr, this message translates to:
  /// **'Hamilelik modunda tahminler ve regl bildirimleri kapalıdır'**
  String get pregnancyModeInfo;

  /// No description provided for @pillPackStartLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hap paketi başlangıcı'**
  String get pillPackStartLabel;

  /// No description provided for @pillDayLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hap günü {day}/21'**
  String pillDayLabel(int day);

  /// No description provided for @pillBreakLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ara hafta • gün {day}'**
  String pillBreakLabel(int day);

  /// No description provided for @smartPrediction.
  ///
  /// In tr, this message translates to:
  /// **'Akıllı Tahmin'**
  String get smartPrediction;

  /// No description provided for @smartPredictionDesc.
  ///
  /// In tr, this message translates to:
  /// **'Tahminlerde geçmiş döngülerden öğrenilen ortalama kullanılır'**
  String get smartPredictionDesc;

  /// No description provided for @learnedCycleLength.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenilen: {days} gün'**
  String learnedCycleLength(int days);

  /// No description provided for @phaseInsights.
  ///
  /// In tr, this message translates to:
  /// **'Faz İçgörüleri'**
  String get phaseInsights;

  /// No description provided for @noInsightsYet.
  ///
  /// In tr, this message translates to:
  /// **'İçgörü için henüz yeterli veri yok. Semptom kaydettikçe burada faz bazlı desenler görünecek.'**
  String get noInsightsYet;

  /// No description provided for @insightLine.
  ///
  /// In tr, this message translates to:
  /// **'{symptom} en çok {phase} fazında görülüyor (%{percent})'**
  String insightLine(String symptom, String phase, int percent);

  /// No description provided for @notContraceptionWarning.
  ///
  /// In tr, this message translates to:
  /// **'Tahminler bilgilendirme amaçlıdır. Bu uygulama bir doğum kontrol yöntemi DEĞİLDİR ve gebelikten korunma amacıyla kullanılamaz.'**
  String get notContraceptionWarning;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @aboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get aboutSection;

  /// No description provided for @consentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz ve Gizlilik'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileriniz yalnızca bu cihazda, şifrelenmiş olarak saklanır; hiçbir sunucuya gönderilmez. Gizlilik politikasını Ayarlar > Hakkında bölümünden okuyabilirsiniz. Devam ederek verilerinizin cihazınızda bu şekilde işlenmesini kabul etmiş olursunuz.'**
  String get consentBody;

  /// No description provided for @consentAccept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul Ediyorum'**
  String get consentAccept;

  /// No description provided for @quickLog.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Kayıt'**
  String get quickLog;

  /// No description provided for @allTrackers.
  ///
  /// In tr, this message translates to:
  /// **'Tüm kayıt türleri'**
  String get allTrackers;

  /// No description provided for @disguiseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizli Mod'**
  String get disguiseTitle;

  /// No description provided for @disguiseDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama \"Notlar\" kılığına girer: ad, ikon, widget, bildirimler ve açılış nötrleşir. Dönüş: Notlar başlığına uzun basın.'**
  String get disguiseDesc;

  /// No description provided for @decoyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get decoyTitle;

  /// No description provided for @decoyEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz not yok'**
  String get decoyEmpty;

  /// No description provided for @decoyHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler yaz…'**
  String get decoyHint;

  /// No description provided for @backupData.
  ///
  /// In tr, this message translates to:
  /// **'Yedek Al (JSON)'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In tr, this message translates to:
  /// **'Yedekten Geri Yükle'**
  String get restoreData;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yedeği geri yükle?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut tüm veriler silinecek ve yedekteki {count} kayıt geri yüklenecek. Bu işlem geri alınamaz.'**
  String restoreConfirmBody(int count);

  /// No description provided for @restore.
  ///
  /// In tr, this message translates to:
  /// **'Geri Yükle'**
  String get restore;

  /// No description provided for @backupRestored.
  ///
  /// In tr, this message translates to:
  /// **'Yedek geri yüklendi'**
  String get backupRestored;

  /// No description provided for @invalidBackupFile.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz yedek dosyası'**
  String get invalidBackupFile;

  /// No description provided for @dateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get dateLabel;

  /// No description provided for @modeStepTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ne için kullanacaksın?'**
  String get modeStepTitle;

  /// No description provided for @modeStepSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Sonradan Ayarlar\'dan değiştirebilirsin'**
  String get modeStepSubtitle;

  /// No description provided for @modePeriodDesc.
  ///
  /// In tr, this message translates to:
  /// **'Döngü takibi ve tahminler'**
  String get modePeriodDesc;

  /// No description provided for @modePregnancyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hafta hafta gebelik'**
  String get modePregnancyDesc;

  /// No description provided for @modePillDesc.
  ///
  /// In tr, this message translates to:
  /// **'21+7 hap düzeni'**
  String get modePillDesc;

  /// No description provided for @modeTtcDesc.
  ///
  /// In tr, this message translates to:
  /// **'Doğurganlık odaklı takip'**
  String get modeTtcDesc;

  /// No description provided for @paywallTitle.
  ///
  /// In tr, this message translates to:
  /// **'Premium\'a Geç'**
  String get paywallTitle;

  /// No description provided for @paywallTrialSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Deneme süren devam ediyor: {days} gün kaldı. Premium\'la her şey açık kalır.'**
  String paywallTrialSubtitle(int days);

  /// No description provided for @paywallFreeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Deneme süren bitti. Ücretsiz sürümde regl takibi ve takvim açık; günlük takipler ve içgörüler Premium\'da.'**
  String get paywallFreeSubtitle;

  /// No description provided for @paywallFeatureTrackers.
  ///
  /// In tr, this message translates to:
  /// **'Tüm günlük takipler: semptom, ruh hali, su, uyku, kilo, sıcaklık, ilaç, not'**
  String get paywallFeatureTrackers;

  /// No description provided for @paywallFeatureStats.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler, trendler ve Yılım halkası'**
  String get paywallFeatureStats;

  /// No description provided for @paywallFeatureInsights.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel içgörüler ve faz ipucu bildirimleri'**
  String get paywallFeatureInsights;

  /// No description provided for @paywallFeatureExport.
  ///
  /// In tr, this message translates to:
  /// **'PDF / CSV dışa aktarma'**
  String get paywallFeatureExport;

  /// No description provided for @paywallFeatureHealth.
  ///
  /// In tr, this message translates to:
  /// **'Health Connect aktarımı'**
  String get paywallFeatureHealth;

  /// No description provided for @paywallFeatureDisguise.
  ///
  /// In tr, this message translates to:
  /// **'Gizli mod ve Notlar kılığı'**
  String get paywallFeatureDisguise;

  /// No description provided for @paywallFeatureNoAds.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız deneyim'**
  String get paywallFeatureNoAds;

  /// No description provided for @planMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get planYearly;

  /// No description provided for @perMonth.
  ///
  /// In tr, this message translates to:
  /// **'/ay'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In tr, this message translates to:
  /// **'/yıl'**
  String get perYear;

  /// No description provided for @bestValue.
  ///
  /// In tr, this message translates to:
  /// **'En avantajlı'**
  String get bestValue;

  /// No description provided for @continueFreeBtn.
  ///
  /// In tr, this message translates to:
  /// **'Şimdilik ücretsiz devam et'**
  String get continueFreeBtn;

  /// No description provided for @trialBadge.
  ///
  /// In tr, this message translates to:
  /// **'Deneme: {days} gün kaldı'**
  String trialBadge(int days);

  /// No description provided for @freeBadge.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz sürüm'**
  String get freeBadge;

  /// No description provided for @freeExplain.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz sürümde regl takibi, takvim ve tahminler açıktır. Günlük takipler, istatistikler, dışa aktarma, Health Connect, gizli mod ve modlar Premium\'dadır.'**
  String get freeExplain;

  /// No description provided for @seePlans.
  ///
  /// In tr, this message translates to:
  /// **'Planları Gör'**
  String get seePlans;

  /// No description provided for @premiumLockedTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler Premium\'da'**
  String get premiumLockedTitle;

  /// No description provided for @premiumLockedBody.
  ///
  /// In tr, this message translates to:
  /// **'Grafikler, trendler, faz içgörüleri ve Yılım halkası Premium ile açılır. Deneme süresinde girdiğin tüm veriler saklanıyor.'**
  String get premiumLockedBody;

  /// No description provided for @yearRingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yılım'**
  String get yearRingTitle;

  /// No description provided for @yearRingCycles.
  ///
  /// In tr, this message translates to:
  /// **'DÖNGÜ'**
  String get yearRingCycles;

  /// No description provided for @yearRingSummary.
  ///
  /// In tr, this message translates to:
  /// **'Son 12 ay: {count} döngü'**
  String yearRingSummary(int count);

  /// No description provided for @cycleComparison.
  ///
  /// In tr, this message translates to:
  /// **'Son Döngün'**
  String get cycleComparison;

  /// No description provided for @lastCycleLength.
  ///
  /// In tr, this message translates to:
  /// **'Son döngü: {days} gün'**
  String lastCycleLength(int days);

  /// No description provided for @lastPeriodLength.
  ///
  /// In tr, this message translates to:
  /// **'Son regl: {days} gün'**
  String lastPeriodLength(int days);

  /// No description provided for @vsAverageMore.
  ///
  /// In tr, this message translates to:
  /// **'ortalamandan {days} gün uzun'**
  String vsAverageMore(int days);

  /// No description provided for @vsAverageLess.
  ///
  /// In tr, this message translates to:
  /// **'ortalamandan {days} gün kısa'**
  String vsAverageLess(int days);

  /// No description provided for @vsAverageSame.
  ///
  /// In tr, this message translates to:
  /// **'ortalamanla aynı'**
  String get vsAverageSame;

  /// No description provided for @coachPersonalInsight.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlarına göre bu fazda en sık: {symptom} (%{percent})'**
  String coachPersonalInsight(String symptom, int percent);

  /// No description provided for @notificationInsightTitle.
  ///
  /// In tr, this message translates to:
  /// **'Faz ipucu'**
  String get notificationInsightTitle;

  /// No description provided for @notificationInsightBody.
  ///
  /// In tr, this message translates to:
  /// **'Luteal faz başlıyor. Kayıtlarına göre bu fazda en sık: {symptom}.'**
  String notificationInsightBody(String symptom);

  /// No description provided for @reportTitle.
  ///
  /// In tr, this message translates to:
  /// **'Döngü Sağlık Raporu'**
  String get reportTitle;

  /// No description provided for @reportGenerated.
  ///
  /// In tr, this message translates to:
  /// **'Oluşturma'**
  String get reportGenerated;

  /// No description provided for @profileSummary.
  ///
  /// In tr, this message translates to:
  /// **'Profil Özeti'**
  String get profileSummary;

  /// No description provided for @periodHistory.
  ///
  /// In tr, this message translates to:
  /// **'Regl Geçmişi'**
  String get periodHistory;

  /// No description provided for @last30DaysSummary.
  ///
  /// In tr, this message translates to:
  /// **'Son 30 Gün Özeti'**
  String get last30DaysSummary;

  /// No description provided for @durationDaysHeader.
  ///
  /// In tr, this message translates to:
  /// **'Süre (gün)'**
  String get durationDaysHeader;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @colorBlindPattern.
  ///
  /// In tr, this message translates to:
  /// **'Desenli faz renkleri'**
  String get colorBlindPattern;

  /// No description provided for @colorBlindPatternDesc.
  ///
  /// In tr, this message translates to:
  /// **'Faz bantlarına doku ekler — renkleri ayırt etmek zorsa'**
  String get colorBlindPatternDesc;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @periodMarkedStarted.
  ///
  /// In tr, this message translates to:
  /// **'Regl başlangıcı kaydedildi'**
  String get periodMarkedStarted;

  /// No description provided for @periodMarkedEnded.
  ///
  /// In tr, this message translates to:
  /// **'Regl bitişi kaydedildi'**
  String get periodMarkedEnded;

  /// No description provided for @editPeriodRecord.
  ///
  /// In tr, this message translates to:
  /// **'Regl kaydını düzenle'**
  String get editPeriodRecord;

  /// No description provided for @startDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş'**
  String get endDateLabel;

  /// No description provided for @recordUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt güncellendi'**
  String get recordUpdated;

  /// No description provided for @dataResetTitle.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz okunamadı'**
  String get dataResetTitle;

  /// No description provided for @dataResetBody.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama verileri bu cihazda çözülemedi. Bu genellikle telefon değişiminde veya sistem yedeğinden geri yüklemede olur: veriler cihaza özel bir anahtarla şifrelenir ve bu anahtar yeni cihaza taşınamaz. Uygulama sıfırdan başlatıldı.\n\nVerilerinizi cihazlar arasında taşımak için Ayarlar > Verileri Yedekle ile düzenli JSON yedeği alın.'**
  String get dataResetBody;

  /// No description provided for @pinSet.
  ///
  /// In tr, this message translates to:
  /// **'PIN başarıyla ayarlandı'**
  String get pinSet;

  /// No description provided for @pinRemoved.
  ///
  /// In tr, this message translates to:
  /// **'PIN kaldırıldı'**
  String get pinRemoved;

  /// No description provided for @unlockWithBiometric.
  ///
  /// In tr, this message translates to:
  /// **'Parmak izi veya yüz ile kilidi açın'**
  String get unlockWithBiometric;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Bu cihazda biyometrik doğrulama mevcut değil'**
  String get biometricNotAvailable;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @profileSaved.
  ///
  /// In tr, this message translates to:
  /// **'Profil kaydedildi'**
  String get profileSaved;

  /// No description provided for @sleepDurationShort.
  ///
  /// In tr, this message translates to:
  /// **'{hours}s {minutes}dk'**
  String sleepDurationShort(int hours, int minutes);

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Tüm verileri silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'**
  String get deleteAllDataConfirm;

  /// No description provided for @dataDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Tüm veriler silindi'**
  String get dataDeleted;

  /// No description provided for @doseHint.
  ///
  /// In tr, this message translates to:
  /// **'ör. 500mg'**
  String get doseHint;

  /// No description provided for @menstrualPhaseInfo.
  ///
  /// In tr, this message translates to:
  /// **'Adet kanamasının yaşandığı dönemdir. Genellikle 3-7 gün sürer. Vücut rahim iç tabakasını atar.'**
  String get menstrualPhaseInfo;

  /// No description provided for @follicularPhaseInfo.
  ///
  /// In tr, this message translates to:
  /// **'Adet sonrası yumurtalıkların yeni yumurta hazırladığı dönemdir. Östrojen yükselir, enerji seviyesi artar.'**
  String get follicularPhaseInfo;

  /// No description provided for @ovulationPhaseInfo.
  ///
  /// In tr, this message translates to:
  /// **'Yumurtanın yumurtalıktan serbest bırakıldığı dönemdir. Hamilelik olasılığı en yüksek seviyededir.'**
  String get ovulationPhaseInfo;

  /// No description provided for @lutealPhaseInfo.
  ///
  /// In tr, this message translates to:
  /// **'Ovulasyon sonrası bir sonraki adet dönemine kadar süren fazıdır. Progesteron yükselir, PMS belirtileri görülebilir.'**
  String get lutealPhaseInfo;

  /// No description provided for @fertileWindowInfo.
  ///
  /// In tr, this message translates to:
  /// **'Hamilelik olasılığının en yüksek olduğu dönemdir. Ovulasyondan 5 gün önce başlar ve 1 gün sonra sona erer.'**
  String get fertileWindowInfo;

  /// No description provided for @ovulationCardInfo.
  ///
  /// In tr, this message translates to:
  /// **'Yumurtalıktan yumurtanın serbest bırakılacağı tahmini gündür. Döngünün ortasına denk gelir.'**
  String get ovulationCardInfo;

  /// No description provided for @nextPeriodInfo.
  ///
  /// In tr, this message translates to:
  /// **'Bir sonraki adet kanamasının tahmini başlangıç tarihidir. Döngü sürenize göre hesaplanır.'**
  String get nextPeriodInfo;

  /// No description provided for @phaseInfoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu faz nedir?'**
  String get phaseInfoTitle;

  /// No description provided for @learnMore.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi'**
  String get learnMore;

  /// No description provided for @healthDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'Bu uygulama tıbbi tavsiye niteliğinde değildir. Sağlık sorunlarınız için lütfen bir sağlık uzmanına danışın.'**
  String get healthDisclaimer;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
