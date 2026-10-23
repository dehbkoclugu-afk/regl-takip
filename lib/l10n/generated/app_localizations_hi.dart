// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मासिक धर्म ट्रैकर';

  @override
  String get home => 'होम';

  @override
  String get calendar => 'कैलेंडर';

  @override
  String get log => 'दर्ज करें';

  @override
  String get statistics => 'सांख्यिकी';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get onboardingWelcome => 'स्वागत है!';

  @override
  String get onboardingWelcomeDesc =>
      'अपने स्वास्थ्य पर नज़र रखने का सबसे आसान तरीका';

  @override
  String get onboardingTitle1 => 'अपने मासिक चक्र पर नज़र रखें';

  @override
  String get onboardingDesc1 =>
      'मासिक धर्म दर्ज करें और अगले मासिक धर्म का अनुमान देखें।';

  @override
  String get onboardingTitle2 => 'अपने स्वास्थ्य की निगरानी करें';

  @override
  String get onboardingDesc2 => 'लक्षण, मनोदशा, तापमान और बहुत कुछ ट्रैक करें।';

  @override
  String get onboardingTitle3 => 'अपना विश्लेषण देखें';

  @override
  String get onboardingDesc3 =>
      'विस्तृत चार्ट और आँकड़ों से अपने चक्र को समझें।';

  @override
  String get onboardingTitle4 => 'सूचनाएं प्राप्त करें';

  @override
  String get onboardingDesc4 =>
      'अपने मासिक धर्म और ओव्यूलेशन दिनों के लिए अनुस्मारक प्राप्त करें।';

  @override
  String get getStarted => 'आरंभ करें';

  @override
  String get next => 'अगला';

  @override
  String get skip => 'छोड़ें';

  @override
  String get back => 'वापस';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get edit => 'संपादित करें';

  @override
  String get done => 'हो गया';

  @override
  String get maybeLater => 'बाद में सेट करें';

  @override
  String get enableBiometric => 'फ़िंगरप्रिंट/चेहरा पहचान';

  @override
  String get enablePin => 'पिन से लॉक करें';

  @override
  String get securitySetup => 'सुरक्षा सेटअप';

  @override
  String get securitySetupDesc => 'क्या आप ऐप को लॉक करना चाहेंगे?';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get name => 'नाम';

  @override
  String get birthDate => 'जन्मतिथि';

  @override
  String get lastPeriodDate => 'पिछले मासिक धर्म की तारीख';

  @override
  String get averageCycleLength => 'औसत चक्र लंबाई';

  @override
  String get averagePeriodLength => 'मासिक धर्म की औसत अवधि';

  @override
  String get days => 'दिन';

  @override
  String get day => 'दिन';

  @override
  String get today => 'आज';

  @override
  String get cycleDay => 'मासिक चक्र का दिन';

  @override
  String get periodIn => 'अगला मासिक धर्म';

  @override
  String daysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString दिन बाकी',
    );
    return '$_temp0';
  }

  @override
  String get periodToday => 'आपका मासिक धर्म आज से शुरू हो सकता है';

  @override
  String get periodOngoing => 'आप अपने मासिक धर्म पर हैं';

  @override
  String get ovulationDay => 'ओव्यूलेशन दिवस';

  @override
  String get fertileWindow => 'गर्भधारण की संभावित अवधि';

  @override
  String get lutealPhase => 'ल्यूटियल चरण';

  @override
  String get follicularPhase => 'कूपिक चरण';

  @override
  String get periodPhase => 'मासिक धर्म चरण';

  @override
  String get logPeriod => 'मासिक धर्म दर्ज करें';

  @override
  String get periodStarted => 'मासिक धर्म शुरू हुआ';

  @override
  String get periodEnded => 'मासिक धर्म समाप्त हुआ';

  @override
  String get flowIntensity => 'मासिक रक्तस्राव की तीव्रता';

  @override
  String get light => 'हल्का';

  @override
  String get medium => 'मध्यम';

  @override
  String get heavy => 'अधिक';

  @override
  String get veryHeavy => 'बहुत अधिक';

  @override
  String get spotting => 'हल्का धब्बेदार रक्तस्राव';

  @override
  String get symptoms => 'लक्षण';

  @override
  String get mood => 'मनोदशा';

  @override
  String get temperature => 'शरीर का तापमान';

  @override
  String get weight => 'वज़न';

  @override
  String get waterIntake => 'पानी का सेवन';

  @override
  String get sleep => 'नींद';

  @override
  String get sexualActivity => 'यौन गतिविधि';

  @override
  String get medication => 'दवा';

  @override
  String get notes => 'नोट्स';

  @override
  String get cramps => 'ऐंठन';

  @override
  String get headache => 'सिरदर्द';

  @override
  String get bloating => 'सूजन';

  @override
  String get breastTenderness => 'स्तनों में दर्द या संवेदनशीलता';

  @override
  String get backPain => 'पीठ दर्द';

  @override
  String get fatigue => 'थकान';

  @override
  String get nausea => 'मतली';

  @override
  String get dizziness => 'चक्कर आना';

  @override
  String get stress => 'तनाव';

  @override
  String get anxiety => 'चिंता';

  @override
  String get irritability => 'चिड़चिड़ापन';

  @override
  String get crying => 'रोना';

  @override
  String get sensitivity => 'संवेदनशीलता';

  @override
  String get acne => 'मुँहासा';

  @override
  String get oilySkin => 'तैलीय त्वचा';

  @override
  String get drySkin => 'शुष्क त्वचा';

  @override
  String get constipation => 'कब्ज';

  @override
  String get diarrhea => 'दस्त';

  @override
  String get gas => 'पेट में गैस';

  @override
  String get increasedAppetite => 'भूख में वृद्धि';

  @override
  String get decreasedAppetite => 'भूख कम होना';

  @override
  String get insomnia => 'अनिद्रा';

  @override
  String get hotFlash => 'अचानक गर्मी लगना';

  @override
  String get swelling => 'सूजन';

  @override
  String get hairLoss => 'बालों का झड़ना';

  @override
  String get happy => 'खुश';

  @override
  String get sad => 'दुखद';

  @override
  String get angry => 'क्रोधित';

  @override
  String get anxious => 'चिंतित';

  @override
  String get calm => 'शांत';

  @override
  String get energetic => 'ऊर्जावान';

  @override
  String get tired => 'थका हुआ';

  @override
  String get romantic => 'रोमांटिक';

  @override
  String get confused => 'भ्रमित';

  @override
  String get confident => 'आश्वस्त';

  @override
  String get avgCycleLength => 'मासिक चक्र की औसत अवधि';

  @override
  String get avgPeriodLength => 'मासिक धर्म की औसत अवधि';

  @override
  String get cycleHistory => 'मासिक चक्र का इतिहास';

  @override
  String get symptomFrequency => 'लक्षण आवृत्ति';

  @override
  String get moodDistribution => 'मूड वितरण';

  @override
  String get temperatureTrend => 'तापमान की प्रवृत्ति';

  @override
  String get weightTrend => 'वजन की प्रवृत्ति';

  @override
  String get last3Months => 'पिछले 3 महीने';

  @override
  String get last6Months => 'पिछले 6 महीने';

  @override
  String get last12Months => 'पिछले 12 महीने';

  @override
  String get exportData => 'डेटा निर्यात करें';

  @override
  String get exportPdf => 'पीडीएफ रिपोर्ट';

  @override
  String get exportCsv => 'सीएसवी फ़ाइल';

  @override
  String get language => 'भाषा';

  @override
  String get theme => 'थीम';

  @override
  String get lightTheme => 'हल्की थीम';

  @override
  String get darkTheme => 'गहरी थीम';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get periodReminder => 'मासिक धर्म का अनुस्मारक';

  @override
  String get ovulationReminder => 'ओव्यूलेशन अनुस्मारक';

  @override
  String get medicationReminder => 'दवा अनुस्मारक';

  @override
  String get waterReminder => 'जल अनुस्मारक';

  @override
  String get security => 'सुरक्षा';

  @override
  String get pinLock => 'पिन लॉक';

  @override
  String get biometricLock => 'बायोमेट्रिक लॉक';

  @override
  String get dataBackup => 'डेटा बैकअप';

  @override
  String get deleteAllData => 'सभी डेटा हटाएँ';

  @override
  String get about => 'के बारे में';

  @override
  String get version => 'संस्करण';

  @override
  String get glasses => 'गिलास';

  @override
  String get dailyGoal => 'दैनिक लक्ष्य';

  @override
  String get sleepQuality => 'नींद की गुणवत्ता';

  @override
  String get bedTime => 'सोने का समय';

  @override
  String get wakeTime => 'जागने का समय';

  @override
  String get totalSleep => 'पूरी नींद';

  @override
  String get hours => 'घंटे';

  @override
  String get protection => 'सुरक्षा';

  @override
  String get condom => 'कंडोम';

  @override
  String get pill => 'गर्भनिरोधक गोली';

  @override
  String get iud => 'आईयूडी';

  @override
  String get none => 'कोई नहीं';

  @override
  String get other => 'अन्य';

  @override
  String get medicationName => 'दवा का नाम';

  @override
  String get dose => 'खुराक';

  @override
  String get reminderTime => 'अनुस्मारक समय';

  @override
  String get taken => 'ले ली';

  @override
  String get notTaken => 'नहीं ली';

  @override
  String get addNote => 'नोट जोड़ें';

  @override
  String get selectDate => 'दिनांक चुनें';

  @override
  String get noDataYet => 'अभी तक कोई डेटा नहीं';

  @override
  String get predictions => 'भविष्यवाणियाँ';

  @override
  String get nextPeriod => 'अगला मासिक धर्म';

  @override
  String get nextOvulation => 'अगला ओव्यूलेशन';

  @override
  String get cycleRegularity => 'चक्र नियमितता';

  @override
  String get regular => 'नियमित';

  @override
  String get irregular => 'अनियमित';

  @override
  String get setupComplete => 'सेटअप पूर्ण!';

  @override
  String get letsStart => 'आइए शुरू करें';

  @override
  String get bmi => 'बीएमआई';

  @override
  String get goalReached => 'लक्ष्य पूरा हो गया!';

  @override
  String get helloGeneric => 'नमस्कार!';

  @override
  String get dayHasRecord => 'एक रिकॉर्ड है';

  @override
  String get increase => 'वृद्धि';

  @override
  String get decrease => 'कमी';

  @override
  String get bbtHint =>
      'सटीक रीडिंग के लिए, जागने के ठीक बाद, बिस्तर से उठने से पहले, हर दिन एक ही समय पर मापें। ओव्यूलेशन की पुष्टि इन रीडिंग पर निर्भर करती है।';

  @override
  String get deleteMeasurement => 'माप हटाएं';

  @override
  String get measurementDeleted => 'मापन हटा दिया गया';

  @override
  String get deleteRecord => 'रिकॉर्ड हटाएँ';

  @override
  String get recordDeleted => 'रिकॉर्ड हटा दिया गया';

  @override
  String get invalidWeight => 'वैध वजन दर्ज करें (20-300 किग्रा)';

  @override
  String get invalidTemperature =>
      'मान्य तापमान दर्ज करें (35-40 डिग्री सेल्सियस)';

  @override
  String get discardChangesTitle => 'सहेजे न गए परिवर्तन';

  @override
  String get discardChangesBody =>
      'आपका नोट सहेजा नहीं गया है. अब छोड़ना इसे त्याग देता है।';

  @override
  String get discard => 'त्यागें';

  @override
  String severityLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'गंभीरता $levelString/5';
  }

  @override
  String get pregnancySetStartPrompt =>
      'अपनी गर्भावस्था की शुरुआत निर्धारित करने के लिए टैप करें';

  @override
  String helloName(String name) {
    return 'नमस्ते, $name!';
  }

  @override
  String get ovulationPhase => 'ओव्यूलेशन चरण';

  @override
  String get menstrualPhase => 'मासिक धर्म चरण';

  @override
  String get todaySummary => 'आज का सारांश';

  @override
  String get howAreYouFeeling => 'आज आप कैसा महसूस कर रहे हैं?';

  @override
  String get logMoodAndSymptoms => 'अपना मूड और लक्षण लॉग करें';

  @override
  String get addRecord => 'रिकॉर्ड जोड़ें';

  @override
  String nSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString लक्षण',
    );
    return '$_temp0';
  }

  @override
  String get periodDayLabel => 'मासिक धर्म का दिन';

  @override
  String get predicted => 'भविष्यवाणी की गई';

  @override
  String get fertile => 'गर्भधारण की संभावना';

  @override
  String get ovulation => 'ओव्यूलेशन';

  @override
  String moodLabel(String mood) {
    return 'मूड: $mood';
  }

  @override
  String nGlassesWater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString गिलास पानी';
  }

  @override
  String get noRecordForDay => 'इस दिन का कोई रिकॉर्ड नहीं.';

  @override
  String get dailyLog => 'दैनिक लॉग';

  @override
  String get dailyMeasurements => 'दैनिक माप';

  @override
  String get flow => 'मासिक रक्तस्राव';

  @override
  String get recorded => 'रिकार्ड किया गया';

  @override
  String nMedications(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString दवाएं',
    );
    return '$_temp0';
  }

  @override
  String nGlasses(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString गिलास',
    );
    return '$_temp0';
  }

  @override
  String get flowTracking => 'मासिक रक्तस्राव दर्ज करें';

  @override
  String get color => 'रंग';

  @override
  String get lightRed => 'हल्का लाल';

  @override
  String get red => 'लाल';

  @override
  String get darkRed => 'गहरा लाल';

  @override
  String get brown => 'भूरा';

  @override
  String get clots => 'खून के थक्के';

  @override
  String get clotsQuestion => 'कोई थक्के?';

  @override
  String get padChange => 'पैड बदलना';

  @override
  String get flowSaved => 'मासिक रक्तस्राव सहेजा गया';

  @override
  String get symptomTracking => 'लक्षण ट्रैकिंग';

  @override
  String get physical => 'शारीरिक';

  @override
  String get emotional => 'भावुक';

  @override
  String get skinCategory => 'त्वचा';

  @override
  String get digestive => 'पाचन';

  @override
  String get otherCategory => 'अन्य';

  @override
  String get glowingSkin => 'चमकती त्वचा';

  @override
  String saveNSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'सहेजें ($countString लक्षण)';
  }

  @override
  String nSymptomsSaved(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString लक्षण सहेजे गए';
  }

  @override
  String get addNoteOptional => 'नोट जोड़ें (वैकल्पिक)';

  @override
  String get writeAboutToday => 'आज के बारे में कुछ लिखें...';

  @override
  String get moodSaved => 'मूड बच गया';

  @override
  String get sensitiveM => 'संवेदनशील';

  @override
  String get irritableM => 'चिड़चिड़ा';

  @override
  String get neutralM => 'तटस्थ';

  @override
  String get lowTemp => 'नीचा';

  @override
  String get normalTemp => 'सामान्य';

  @override
  String get highTemp => 'ऊँचा';

  @override
  String get fever => 'बुखार';

  @override
  String get measurementTime => 'मापन समय';

  @override
  String get temperatureSaved => 'तापमान बचाया गया';

  @override
  String get quickAdjust => 'त्वरित समायोजन';

  @override
  String get manualEntry => 'मैन्युअल प्रविष्टि';

  @override
  String get weightSaved => 'वजन बचाया';

  @override
  String get waterTracking => 'जल ट्रैकिंग';

  @override
  String get waterSaved => 'पानी बचाया';

  @override
  String get sleepTracking => 'नींद की ट्रैकिंग';

  @override
  String get bedTimeLabel => 'सोने का समय';

  @override
  String get wakeTimeLabel => 'जागने का समय';

  @override
  String get veryBad => 'बहुत बुरा';

  @override
  String get bad => 'ख़राब';

  @override
  String get moderate => 'मध्यम';

  @override
  String get good => 'अच्छा';

  @override
  String get great => 'बढ़िया';

  @override
  String get sleepSaved => 'नींद का रिकॉर्ड सहेजा गया';

  @override
  String get protectionMethod => 'सुरक्षा विधि';

  @override
  String get orgasm => 'कामोन्माद';

  @override
  String get noteOptional => 'नोट (वैकल्पिक)';

  @override
  String get addNoteHint => 'नोट जोड़ें...';

  @override
  String get savedGeneric => 'सहेजा गया';

  @override
  String get medicationTracking => 'दवा ट्रैकिंग';

  @override
  String get addMedication => 'दवा जोड़ें';

  @override
  String get noMedicationsYet => 'अभी तक कोई दवा नहीं जोड़ी गई';

  @override
  String get medicationPlanHint =>
      'यह योजना हर दिन लागू होती है. चेकबॉक्स केवल चयनित दिन को रिकॉर्ड करता है।';

  @override
  String get medicationAlreadyInPlan => 'यह दवा पहले से ही योजना में है';

  @override
  String get tapToAdd => 'जोड़ने के लिए + टैप करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get dailyNote => 'दैनिक नोट';

  @override
  String get myNotes => 'मेरे नोट्स';

  @override
  String get notesHint => 'आप कैसा महसूस कर रहे हैं? अपने नोट्स यहां लिखें...';

  @override
  String get noteSaved => 'नोट सहेजा गया';

  @override
  String get cycleOverview => 'मासिक चक्र का अवलोकन';

  @override
  String get avgCycle => 'औसत मासिक चक्र';

  @override
  String get avgPeriod => 'औसत मासिक धर्म अवधि';

  @override
  String get regularity => 'नियमितता';

  @override
  String get insufficientData => 'अपर्याप्त डेटा';

  @override
  String get noSymptomData => 'अभी तक कोई लक्षण डेटा नहीं';

  @override
  String get noMoodData => 'अभी तक कोई मूड डेटा नहीं';

  @override
  String get noCycleData => 'अभी तक कोई चक्र डेटा नहीं';

  @override
  String get ongoing => 'जारी है';

  @override
  String nDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString दिन',
    );
    return '$_temp0';
  }

  @override
  String get profileSection => 'प्रोफाइल';

  @override
  String get preferences => 'प्राथमिकताएँ';

  @override
  String get age => 'उम्र';

  @override
  String nYearsOld(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString वर्ष पुराना',
    );
    return '$_temp0';
  }

  @override
  String get cycleDuration => 'मासिक चक्र की अवधि';

  @override
  String get periodDuration => 'मासिक धर्म की अवधि';

  @override
  String get dataSection => 'डेटा';

  @override
  String get exportPdfReport => 'पीडीएफ रिपोर्ट निर्यात करें';

  @override
  String get exportCsvFile => 'सीएसवी निर्यात करें';

  @override
  String get pdfExportSoon => 'पीडीएफ निर्यात जल्द ही आ रहा है!';

  @override
  String get csvExportSoon => 'सीएसवी निर्यात जल्द ही आ रहा है!';

  @override
  String get letsKnowYou => 'आइये आपको जानते हैं';

  @override
  String get whatShouldWeCallYou => 'हमें आपको क्या कहकर पुकारना चाहिए?';

  @override
  String get yourName => 'आपका नाम';

  @override
  String get yourBirthDate => 'आपकी जन्मतिथि';

  @override
  String get birthDateHelp =>
      'हमें आयु-उपयुक्त सुझाव प्रदान करने में सहायता करता है।';

  @override
  String get selectDateHint => 'दिनांक चुनें';

  @override
  String get selectDateToContinue => 'जारी रखने के लिए एक तारीख चुनें';

  @override
  String stepOfSteps(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString का चरण $currentString';
  }

  @override
  String get lastPeriodTitle => 'आपका पिछला मासिक धर्म';

  @override
  String get lastPeriodHelp => 'अपनी अंतिम अवधि की आरंभ तिथि चुनें।';

  @override
  String get cycleLengthTitle => 'चक्र की लंबाई';

  @override
  String get cycleLengthHelp =>
      'आपका औसत चक्र कितने दिनों का है?\n(एक पीरियड के पहले दिन से अगले पीरियड के पहले दिन तक)';

  @override
  String get periodLengthTitle => 'मासिक धर्म की अवधि';

  @override
  String get periodLengthHelp =>
      'आपका मासिक धर्म आमतौर पर कितने दिनों तक चलता है?';

  @override
  String get averageLabel => 'औसत';

  @override
  String get completeBtn => 'पूर्ण';

  @override
  String get continueBtn => 'जारी रखें';

  @override
  String errorOccurred(String error) {
    return 'एक त्रुटि उत्पन्न हुई: $error';
  }

  @override
  String get welcomeInfoTitle => 'स्वागत है!';

  @override
  String get welcomeInfoDesc =>
      'अपने स्वास्थ्य पर नज़र रखने का सबसे आसान और सुंदर तरीका। हम आपके चक्र के हर कदम पर आपके साथ हैं।';

  @override
  String get trackCycleTitle => 'अपने मासिक चक्र पर नज़र रखें';

  @override
  String get trackCycleDesc =>
      'आसानी से अपनी माहवारी की तारीखें, लक्षण और मनोदशा लॉग करें। आपका सारा डेटा सुरक्षित है.';

  @override
  String get getPredictionsTitle => 'पूर्वानुमान प्राप्त करें';

  @override
  String get getPredictionsDesc =>
      'स्मार्ट भविष्यवाणियों के साथ अपने अगले चक्र और उपजाऊ दिनों के बारे में जानें।';

  @override
  String get startBtn => 'प्रारंभ करें';

  @override
  String daysLater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString दिनों में';
  }

  @override
  String get todayExclamation => 'आज!';

  @override
  String get spiral => 'आईयूडी';

  @override
  String get enterPin => 'पिन दर्ज करें';

  @override
  String get createPin => 'पिन बनाएं';

  @override
  String get confirmPin => 'पिन की पुष्टि करें';

  @override
  String get pinMismatch => 'पिन मेल नहीं खाते, पुनः प्रयास करें';

  @override
  String get verifyPinTitle => 'अपना वर्तमान पिन दर्ज करें';

  @override
  String get wrongPin => 'ग़लत पिन';

  @override
  String tooManyAttempts(int seconds) {
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'बहुत सारे ग़लत प्रयास. $secondsString सेकंड प्रतीक्षा करें';
  }

  @override
  String get coachMenstrual0 =>
      'आप रक्तस्राव, दर्द और आप कैसा महसूस करते हैं, इसे रिकॉर्ड कर सकते हैं। जिन लक्षणों से आप चिंतित हैं, उनके लिए चिकित्सीय सलाह लें।';

  @override
  String get coachMenstrual1 =>
      'यदि आरामदायक हो, तो कोमल हलचल या गर्माहट आपको बेहतर महसूस करने में मदद कर सकती है। व्यक्तिगत अनुभव अलग-अलग होते हैं।';

  @override
  String get coachMenstrual2 =>
      'आज आप कैसा महसूस करते हैं उसके अनुसार आराम या गतिविधि चुनें।';

  @override
  String get coachFollicular0 =>
      'लोगों और चक्रों के बीच ऊर्जा और लक्षण भिन्न-भिन्न होते हैं। पैटर्न पर ध्यान देने के लिए अपने स्वयं के रिकॉर्ड का उपयोग करें।';

  @override
  String get coachFollicular1 =>
      'चक्र के दौरान आपकी त्वचा बदल सकती है। एक निश्चित पैटर्न मानने के बजाय परिवर्तन रिकॉर्ड करें।';

  @override
  String get coachFollicular2 =>
      'अपने स्वास्थ्य और आराम के आधार पर व्यायाम चुनें, न कि अनुमानित चक्र चरण के आधार पर।';

  @override
  String get coachOvulation0 =>
      'उपजाऊ दिन अनुमानित हैं। यह ऐप कोई गर्भनिरोधक तरीका नहीं है.';

  @override
  String get coachOvulation1 =>
      'नए, गंभीर या लगातार दर्द के लिए ओव्यूलेशन को जिम्मेदार ठहराने के बजाय चिकित्सकीय सलाह लें।';

  @override
  String get coachOvulation2 =>
      'मनोदशा और सामाजिक ऊर्जा भिन्न-भिन्न होती है। एक पूर्वानुमानित चरण यह निर्धारित नहीं कर सकता कि आप कैसा महसूस करेंगे।';

  @override
  String get coachLuteal0 =>
      'नींद, तनाव और कई अन्य कारक लक्षणों को प्रभावित कर सकते हैं। आप जो नोटिस करते हैं उसे रिकॉर्ड करें.';

  @override
  String get coachLuteal1 =>
      'ऐसा भोजन और गतिविधि चुनें जो आपकी आवश्यकताओं के अनुरूप हो। एक पूर्वानुमानित चरण आहार निर्धारित नहीं करता है।';

  @override
  String get coachLuteal2 =>
      'मूड में बदलाव के कई संभावित कारण होते हैं। उन लक्षणों के लिए सहायता लें जो लगातार बने रहते हैं या आपको चिंतित करते हैं।';

  @override
  String get ovulationConfirmed => 'संभव ओव्यूलेशन';

  @override
  String get ovulationConfirmedInfo =>
      'तापमान पैटर्न या एलएच परीक्षण संभावित ओव्यूलेशन का सुझाव देता है। बीमारी, नींद और माप का समय परिणामों को प्रभावित करते हैं। यह नैदानिक ​​पुष्टि नहीं है और इसका उपयोग गर्भनिरोधक के लिए नहीं किया जाना चाहिए।';

  @override
  String get premiumSection => 'प्रीमियम';

  @override
  String get removeAds => 'विज्ञापन हटाएँ';

  @override
  String get restorePurchases => 'खरीदारी पुनर्स्थापित करें';

  @override
  String get premiumActive => 'प्रीमियम सक्रिय - विज्ञापन बंद हैं';

  @override
  String get storeUnavailable => 'स्टोर फिलहाल अनुपलब्ध है';

  @override
  String get healthSync => 'हेल्थ कनेक्ट से सिंक करें';

  @override
  String get healthSyncSuccess => 'अवधि डेटा सिंक किया गया';

  @override
  String get healthSyncDenied => 'स्वास्थ्य डेटा अनुमति अस्वीकृत';

  @override
  String get healthSyncUnavailable => 'इस उपकरण पर कोई स्वास्थ्य सेवा नहीं';

  @override
  String get healthSyncFailed => 'समन्वयन विफल';

  @override
  String get trackingModeTitle => 'ट्रैकिंग मोड';

  @override
  String get modePeriod => 'मासिक धर्म';

  @override
  String get modePregnancy => 'गर्भावस्था';

  @override
  String get modePill => 'गर्भनिरोधक गोली';

  @override
  String get modeTtc => 'गर्भधारण की कोशिश';

  @override
  String get lhTestTitle => 'ओव्यूलेशन (एलएच) टेस्ट';

  @override
  String get lhPositive => 'सकारात्मक';

  @override
  String get lhNegative => 'नकारात्मक';

  @override
  String get fertilityToday => 'आज की प्रजनन क्षमता';

  @override
  String get fertilityHigh => 'ऊँचा';

  @override
  String get fertilityMedium => 'मध्यम';

  @override
  String get fertilityLow => 'नीचा';

  @override
  String pregnancyWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'सप्ताह $weekString';
  }

  @override
  String get trimester1 => 'पहली तिमाही';

  @override
  String get trimester2 => 'दूसरी तिमाही';

  @override
  String get trimester3 => 'तीसरी तिमाही';

  @override
  String get pregnancyDevelopmentTitle => 'इस सप्ताह विकास';

  @override
  String get pregnancyDevelopment1 =>
      'आपके शिशु के प्रमुख अंगों और शारीरिक प्रणालियों के निर्माण के साथ-साथ तेजी से विकास की अवधि जारी रहती है।';

  @override
  String get pregnancyDevelopment2 =>
      'आपके शिशु की गतिविधियां अधिक समन्वित होती जा रही हैं; जब आपको लगता है कि वे एक व्यक्ति से दूसरे व्यक्ति में भिन्न हो सकते हैं।';

  @override
  String get pregnancyDevelopment3 =>
      'जैसे-जैसे जन्म की तैयारी अधिक महत्वपूर्ण होती जाती है, आपका शिशु बढ़ता रहता है।';

  @override
  String get pregnancyCheckupReminder =>
      'अपने स्वास्थ्य देखभाल पेशेवर द्वारा सुझाए गए चेकअप शेड्यूल का पालन करें।';

  @override
  String get pregnancyStartLabel =>
      'अंतिम मासिक धर्म की तारीख (गर्भावस्था प्रारंभ)';

  @override
  String get pregnancyModeInfo =>
      'गर्भावस्था मोड में पूर्वानुमान और अवधि अनुस्मारक बंद हैं';

  @override
  String get pillPackStartLabel => 'गोली पैक प्रारंभ';

  @override
  String pillDayLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'गोली दिन $dayString/21';
  }

  @override
  String pillBreakLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'ब्रेक सप्ताह • दिन $dayString';
  }

  @override
  String get smartPrediction => 'स्मार्ट भविष्यवाणी';

  @override
  String get smartPredictionDesc =>
      'भविष्यवाणियाँ आपके पिछले चक्रों से सीखे गए औसत का उपयोग करती हैं';

  @override
  String learnedCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'सीखा: $daysString दिन';
  }

  @override
  String get phaseInsights => 'चरण अंतर्दृष्टि';

  @override
  String get noInsightsYet =>
      'अंतर्दृष्टि के लिए अभी तक पर्याप्त डेटा नहीं है. जैसे ही आप लक्षण लॉग करेंगे, चरण-आधारित पैटर्न यहां दिखाई देंगे।';

  @override
  String insightLine(String symptom, String phase, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$symptom अधिकतर $phase चरण ($percentString%) में होता है';
  }

  @override
  String get notContraceptionWarning =>
      'भविष्यवाणियाँ केवल सूचनात्मक उद्देश्यों के लिए हैं। यह ऐप गर्भनिरोधक विधि नहीं है और गर्भावस्था को रोकने के लिए इसका उपयोग नहीं किया जाना चाहिए।';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get aboutSection => 'के बारे में';

  @override
  String get consentTitle => 'आपका डेटा और गोपनीयता';

  @override
  String get consentBody =>
      'आपका सारा डेटा केवल इस डिवाइस पर एन्क्रिप्टेड संग्रहीत है; किसी भी सर्वर पर कुछ भी नहीं भेजा जाता है. आप गोपनीयता नीति को सेटिंग्स > अबाउट के अंतर्गत पढ़ सकते हैं। जारी रखकर आप स्वीकार करते हैं कि आपका डेटा आपके डिवाइस पर इस प्रकार संसाधित होता है।';

  @override
  String get consentAccept => 'मैं स्वीकार करता हूँ';

  @override
  String get quickLog => 'त्वरित लॉग';

  @override
  String get shortcutQuickLog => 'त्वरित लॉग';

  @override
  String get shortcutToday => 'आज देखें';

  @override
  String get allTrackers => 'सभी ट्रैकर प्रकार';

  @override
  String get disguiseTitle => 'भेस मोड';

  @override
  String get disguiseDesc =>
      'ऐप एक \"नोट्स\" पहचान लेता है: नाम, आइकन, विजेट, सूचनाएं और लॉन्च स्क्रीन तटस्थ हो जाते हैं। वापसी: नोट्स शीर्षक को लंबे समय तक दबाकर रखें।';

  @override
  String get decoyTitle => 'टिप्पणियाँ';

  @override
  String get decoyEmpty => 'अभी तक कोई नोट नहीं';

  @override
  String get decoyHint => 'कुछ लिखो...';

  @override
  String get backupData => 'पासवर्ड बैकअप बनाएं';

  @override
  String get backupPassword => 'बैकअप पासवर्ड';

  @override
  String get backupPasswordConfirm => 'पासवर्ड दोबारा दर्ज करें';

  @override
  String get backupPasswordLength => 'पासवर्ड 10-128 अक्षर का होना चाहिए';

  @override
  String get backupPasswordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get backupNoRecovery =>
      'यह पासवर्ड डिवाइस पर संग्रहीत नहीं है और इसे पुनर्प्राप्त नहीं किया जा सकता है। यदि आप इसे भूल जाते हैं, तो आप बैकअप नहीं खोल सकते।';

  @override
  String get unlockBackupTitle => 'बैकअप पासवर्ड दर्ज करें';

  @override
  String get unlockBackupBody =>
      'यह बैकअप केवल उस पासवर्ड से खोला जा सकता है जिसका उपयोग इसे बनाते समय किया गया था।';

  @override
  String get backupPasswordOrFileInvalid =>
      'पासवर्ड ग़लत है या बैकअप फ़ाइल क्षतिग्रस्त है.';

  @override
  String get legacyBackupWarning =>
      'यह पुराना बैकअप एन्क्रिप्टेड नहीं है. इसे पुनर्स्थापित करने के बाद, नए बैकअप को पासवर्ड से सुरक्षित किया जाएगा।';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get restoreData => 'बैकअप से पुनर्स्थापित करें';

  @override
  String get restoreConfirmTitle => 'बैकअप पुनर्स्थापित करें?';

  @override
  String restoreConfirmBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'सभी मौजूदा डेटा हटा दिए जाएंगे और बैकअप से $countString रिकॉर्ड बहाल कर दिए जाएंगे। इसे असंपादित नहीं किया जा सकता है।';
  }

  @override
  String get restore => 'पुनर्स्थापित करें';

  @override
  String get backupRestored => 'बैकअप पुनर्स्थापित किया गया';

  @override
  String get invalidBackupFile => 'अमान्य बैकअप फ़ाइल';

  @override
  String get dateLabel => 'दिनांक';

  @override
  String get modeStepTitle => 'आप इसका उपयोग किस लिए करेंगे?';

  @override
  String get modeStepSubtitle => 'आप इसे बाद में सेटिंग में बदल सकते हैं';

  @override
  String get modePeriodDesc => 'मासिक चक्र की निगरानी और अनुमान';

  @override
  String get modePregnancyDesc => 'सप्ताह-दर-सप्ताह गर्भावस्था';

  @override
  String get modePillDesc => '21+7 गोली अनुसूची';

  @override
  String get modeTtcDesc => 'प्रजनन-केंद्रित ट्रैकिंग';

  @override
  String get paywallTitle => 'प्रीमियम जाओ';

  @override
  String paywallTrialSubtitle(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'आपका परीक्षण सक्रिय है: $daysString दिन शेष हैं। प्रीमियम सब कुछ अनलॉक रखता है।';
  }

  @override
  String get paywallFreeSubtitle =>
      'आपका परीक्षण समाप्त हो गया है. मुफ़्त संस्करण अवधि ट्रैकिंग और कैलेंडर रखता है; दैनिक ट्रैकिंग और अंतर्दृष्टि प्रीमियम हैं।';

  @override
  String get paywallFeatureTrackers =>
      'सभी दैनिक ट्रैकर: लक्षण, मनोदशा, पानी, नींद, वजन, तापमान, दवा, नोट्स';

  @override
  String get paywallFeatureStats => 'सांख्यिकी, रुझान, और मेरा वर्ष रिंग';

  @override
  String get paywallFeatureInsights =>
      'व्यक्तिगत अंतर्दृष्टि और चरण-टिप सूचनाएं';

  @override
  String get paywallFeatureExport => 'पीडीएफ/सीएसवी निर्यात';

  @override
  String get paywallFeatureHealth => 'हेल्थ कनेक्ट सिंक';

  @override
  String get paywallFeatureDisguise => 'नोट्स डिकॉय के साथ भेस मोड';

  @override
  String get paywallFeatureNoAds => 'विज्ञापन-मुक्त अनुभव';

  @override
  String get planMonthly => 'मासिक';

  @override
  String get planYearly => 'वार्षिक';

  @override
  String get perMonth => '/मो';

  @override
  String get perYear => '/वर्ष';

  @override
  String get bestValue => 'सर्वोत्तम मूल्य';

  @override
  String get continueFreeBtn => 'अभी निःशुल्क जारी रखें';

  @override
  String trialBadge(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'परीक्षण: $daysString दिन शेष हैं';
  }

  @override
  String get freeBadge => 'निःशुल्क संस्करण';

  @override
  String get freeExplain =>
      'मुफ़्त संस्करण अवधि ट्रैकिंग, कैलेंडर और भविष्यवाणियाँ रखता है। दैनिक ट्रैकर, सांख्यिकी, निर्यात, हेल्थ कनेक्ट, भेस मोड और मोड प्रीमियम हैं।';

  @override
  String get seePlans => 'योजनाएं देखें';

  @override
  String get premiumLockedTitle => 'सांख्यिकी प्रीमियम है';

  @override
  String get premiumLockedBody =>
      'प्रीमियम के साथ चार्ट, रुझान, चरण अंतर्दृष्टि और माई ईयर रिंग अनलॉक। परीक्षण के दौरान आपके द्वारा लॉग की गई सभी चीजें सुरक्षित रखी जाती हैं।';

  @override
  String get yearRingTitle => 'मेरा साल';

  @override
  String get yearRingCycles => 'चक्र';

  @override
  String yearRingSummary(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'पिछले 12 महीने: $countString चक्र';
  }

  @override
  String get cycleComparison => 'आपका अंतिम चक्र';

  @override
  String lastCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'अंतिम चक्र: $daysString दिन';
  }

  @override
  String lastPeriodLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'अंतिम अवधि: $daysString दिन';
  }

  @override
  String vsAverageMore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString दिन आपके औसत से अधिक लंबे हैं';
  }

  @override
  String vsAverageLess(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString दिन आपके औसत से कम हैं';
  }

  @override
  String get vsAverageSame => 'आपके औसत के समान';

  @override
  String coachPersonalInsight(String symptom, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'आपके लॉग के आधार पर, इस चरण में सबसे आम: $symptom ($percentString%)';
  }

  @override
  String get notificationInsightTitle => 'चरण टिप';

  @override
  String notificationInsightBody(String symptom) {
    return 'ल्यूटियल चरण शुरू हो रहा है। आपके लॉग के आधार पर, इस चरण में आपका सबसे आम लक्षण: $symptom।';
  }

  @override
  String get notificationPeriodTitle => 'अवधि अनुस्मारक';

  @override
  String get notificationPeriodTimingToday =>
      'आपका मासिक धर्म आज से शुरू हो सकता है.';

  @override
  String get notificationPeriodTimingTomorrow =>
      'आपकी अवधि कल से शुरू हो सकती है.';

  @override
  String notificationPeriodTimingInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'आपकी माहवारी $daysString दिनों में शुरू हो सकती है।';
  }

  @override
  String get notificationPeriodTip1 => 'पैड या टैम्पोन पैक करना याद रखें।';

  @override
  String get notificationPeriodTip2 => 'थोड़ी सी तैयारी इसे आसान बना देती है।';

  @override
  String get notificationPeriodTip3 =>
      'प्रारंभ को लॉग करने से आपकी भविष्यवाणियों में सुधार होता है।';

  @override
  String get notificationPeriodChannel => 'अवधि अनुस्मारक';

  @override
  String get notificationPeriodChannelDesc => 'अवधि चक्र अनुस्मारक';

  @override
  String get notificationOvulationTitle => 'ओव्यूलेशन अनुस्मारक';

  @override
  String get notificationOvulationBody =>
      'आज अंडोत्सर्जन का अनुमानित दिन है। यह गर्भधारण की संभावित अवधि हो सकती है।';

  @override
  String get notificationOvulationChannel => 'ओव्यूलेशन अनुस्मारक';

  @override
  String get notificationOvulationChannelDesc => 'ओव्यूलेशन अनुस्मारक';

  @override
  String get notificationMedicationTitle => 'दवा अनुस्मारक';

  @override
  String get notificationMedicationBody => 'अपनी दवा लेना न भूलें!';

  @override
  String get notificationMedicationChannel => 'दवा अनुस्मारक';

  @override
  String get notificationMedicationChannelDesc => 'दवा अनुस्मारक';

  @override
  String get notificationDiscreetTitle => 'अनुस्मारक';

  @override
  String get notificationDiscreetBody => 'आज के लिए आपके पास एक अनुस्मारक है';

  @override
  String get notificationFertileTitle =>
      'गर्भधारण की संभावित अवधि शुरू होती है';

  @override
  String get notificationFertileBody =>
      'आज से आप गर्भधारण की सबसे अधिक संभावना वाले दिनों में हैं।';

  @override
  String get notificationChainEndTitle => 'अनुस्मारक रुक रहे हैं';

  @override
  String get notificationChainEndBody =>
      'निर्धारित अनुस्मारक समाप्त हो गए हैं. नए सेट अप करने के लिए ऐप खोलें.';

  @override
  String get noPurchasesToRestore =>
      'पुनर्स्थापित करने के लिए कोई खरीदारी नहीं मिली';

  @override
  String get restoringPurchases => 'खरीदारी बहाल की जा रही है...';

  @override
  String get backdateHint => 'किसी भिन्न दिन के लिए देर तक दबाकर रखें';

  @override
  String get periodStartDateHelp => 'आपका मासिक धर्म कब शुरू हुआ?';

  @override
  String get periodEndDateHelp => 'आपकी अवधि कब समाप्त हुई?';

  @override
  String get headlinePeriodToday => 'आपका मासिक धर्म आज से शुरू हो सकता है';

  @override
  String get headlinePeriodTomorrow => 'आपकी अवधि कल से शुरू हो सकती है';

  @override
  String get headlineNoData => 'अपनी अंतिम अवधि की तारीख जोड़ें';

  @override
  String headlinePeriodInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'आपकी अवधि $daysString दिनों में';
  }

  @override
  String headlinePeriodDay(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'आपके मासिक धर्म का दिन $dayString';
  }

  @override
  String get headlineDelaySubtitle =>
      'कुछ भिन्नता सामान्य है. यदि यह प्रारंभ हो गया है तो इसे लॉग करें.';

  @override
  String get notificationDelayTitle => 'अनुमानित तिथि बीत चुकी है';

  @override
  String get notificationDelayBody =>
      'यदि आपकी अवधि शुरू हो गई है, तो इसे लॉग इन करना याद रखें। कुछ भिन्नता सामान्य है.';

  @override
  String get notificationDelayBodyAlt1 =>
      'अभी तक कोई प्रवेश नहीं. यदि यह प्रारंभ हो गया है, तो लॉगिंग में एक टैप लगता है।';

  @override
  String get notificationDelayBodyAlt2 =>
      'कुछ दिनों का बदलाव आम बात है. क्या आपका लॉग अप टू डेट है?';

  @override
  String get notificationDelayChannel => 'विलंब अनुस्मारक';

  @override
  String get notificationDelayChannelDesc =>
      'अनुमानित तिथि बीत जाने पर अनुस्मारक';

  @override
  String headlineDelay(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'आपकी माहवारी $daysString दिन देर से हुई है';
  }

  @override
  String delayDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString दिन देर से';
  }

  @override
  String get yourDataStays =>
      'परीक्षण समाप्त होने पर आपके रिकॉर्ड आपके डिवाइस पर रहते हैं।';

  @override
  String get periodStartedOnThisDay => 'इसी दिन मेरा मासिक धर्म शुरू हुआ था';

  @override
  String nCyclesRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString चक्र रिकॉर्ड किया गया';
  }

  @override
  String nLogsRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString दैनिक लॉग';
  }

  @override
  String get notifPermissionTitle => 'अनुस्मारक चालू करें?';

  @override
  String get notifPermissionBody =>
      'हम आपको बताते हैं कि आपकी अवधि कब करीब है, आपके ओव्यूलेशन का दिन क्या है, और अनुमानित तारीख कब बीत चुकी है। सूचनाएं आपके डिवाइस को कभी नहीं छोड़तीं। आप उन्हें बाद में सेटिंग में भी चालू कर सकते हैं.';

  @override
  String get enableNotifications => 'चालू करो';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get optionalField => 'वैकल्पिक';

  @override
  String get privacyAssurance =>
      'आपका डेटा केवल इसी डिवाइस पर एन्क्रिप्टेड रहता है';

  @override
  String get privacySummary =>
      'आपका मुख्य डेटा इस डिवाइस पर एन्क्रिप्ट किया गया है; यह तभी निकलता है जब आप इसे निर्यात करते हैं या हेल्थ कनेक्ट सक्षम करते हैं।';

  @override
  String get dontRememberExactly => 'मुझे ठीक से याद नहीं है';

  @override
  String get approxTitle => 'मोटे तौर पर यह कब था?';

  @override
  String get approxSubtitle =>
      'एक कठिन तारीख ही काफी है. जैसे ही आप लॉग इन करते हैं पूर्वानुमान स्वयं सही हो जाते हैं।';

  @override
  String get approxThisWeek => 'इस सप्ताह';

  @override
  String get approxLastWeek => 'पिछले सप्ताह';

  @override
  String get approxTwoWeeks => 'लगभग 2 सप्ताह पहले';

  @override
  String get approxThreeWeeks => 'लगभग 3 सप्ताह पहले';

  @override
  String get approxMonthOrMore => 'एक महीने या उससे अधिक पहले';

  @override
  String get cycleReminderTime => 'चक्र अनुस्मारक समय';

  @override
  String get medicationReminderTime => 'दवा अनुस्मारक समय';

  @override
  String get periodReminderLead => 'अवधि अनुस्मारक';

  @override
  String get notificationQuietChannelSuffix => 'शांत';

  @override
  String get quietNotifications => 'शांत सूचनाएं';

  @override
  String get quietNotificationsDesc =>
      'कोई आवाज़ या पॉप-अप नहीं - वे अधिसूचना शेड में चुपचाप प्रतीक्षा करते हैं';

  @override
  String get leadSameDay => 'उसी दिन';

  @override
  String leadNDaysBefore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString दिन पहले';
  }

  @override
  String get regularityInfoIrregular =>
      'आपके सबसे छोटे और सबसे लंबे चक्र के बीच 9 या अधिक दिन होते हैं। मासिक चक्र की लंबाई में भिन्नता बहुत आम है; तनाव, नींद, बीमारी और जीवन में बदलाव सभी इसे प्रभावित करते हैं। यह कोई निदान नहीं है.';

  @override
  String get regularityInfoRegular =>
      'आपके सबसे छोटे और सबसे लंबे चक्र के बीच का अंतर 9 दिनों से कम है। इस स्थिरता के साथ भविष्यवाणियाँ अधिक सटीक होती हैं।';

  @override
  String get regularityInfoSeeDoctor =>
      'यदि आपका चक्र लगातार 21 दिनों से छोटा या 35 दिनों से अधिक लंबा है, यदि आपको तीन महीने से अधिक समय तक कोई मासिक धर्म नहीं हुआ है, या यदि रक्तस्राव असामान्य रूप से भारी है, तो किसी स्वास्थ्य देखभाल पेशेवर से बात करना उचित है।';

  @override
  String typicalRangeNote(int min, int max, int pmax) {
    final intl.NumberFormat minNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String maxString = maxNumberFormat.format(max);
    final intl.NumberFormat pmaxNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String pmaxString = pmaxNumberFormat.format(pmax);

    return 'आम तौर पर स्वीकृत सीमा: चक्र $minString–$maxString दिन, $pmaxString दिनों तक की अवधि। निदान सीमा नहीं.';
  }

  @override
  String lowConfidenceNote(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'ये औसत केवल $countString चक्रों से आते हैं; जैसे-जैसे आप अधिक लॉग करेंगे, वे तेज़ होते जाएंगे।';
  }

  @override
  String regularityInfoInsufficient(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'नियमितता का कोई मतलब निकलने से पहले कम से कम $countString चक्र अंतराल की आवश्यकता होती है। कम पर निर्णय गुमराह करने वाला होगा।';
  }

  @override
  String get backupNever => 'आपने कभी बैकअप नहीं बनाया है.';

  @override
  String get backupStaleHint =>
      'यदि आप अपना फोन खो देते हैं, तो रिकॉर्ड पुनर्प्राप्त नहीं किया जा सकता है।';

  @override
  String backupLastAt(String date) {
    return 'अंतिम बैकअप: $date';
  }

  @override
  String get durationsStepTitle => 'आपके चक्र का विवरण';

  @override
  String get durationsStepHelp =>
      'निश्चित नहीं? उन्हें वैसे ही छोड़ दें जैसे वे हैं - आप इन्हें बाद में सेटिंग्स में बदल सकते हैं।';

  @override
  String get lockTimeoutTitle => 'लॉक में देरी';

  @override
  String get lockTimeoutDesc => 'थोड़ी देर बाद वापस आने पर पिन छोड़ दें';

  @override
  String get lockImmediately => 'तुरंत';

  @override
  String get previousDay => 'पिछला दिन';

  @override
  String get nextDay => 'अगले दिन';

  @override
  String get showLegend => 'रंग कुंजी';

  @override
  String get hideLegend => 'रंग कुंजी छिपाएँ';

  @override
  String get backToToday => 'आज पर वापस जाएँ';

  @override
  String get monthNoRecords => 'इस महीने कोई रिकॉर्ड नहीं';

  @override
  String get doctorSummary => 'मेरे डॉक्टर के लिए एक सारांश निर्यात करें';

  @override
  String get healthImport => 'हेल्थ कनेक्ट से आयात करें';

  @override
  String get healthImportAction => 'आयात करें';

  @override
  String get allTime => 'हर समय';

  @override
  String get actionPeriodStarted => 'मेरा मासिक धर्म शुरू हो गया';

  @override
  String get actionMedicationTaken => 'लिया गया';

  @override
  String get pregnancyTestReady => 'गर्भावस्था परीक्षण अब सार्थक हो सकता है';

  @override
  String notLoggedToday(String what) {
    return 'आज कोई $what लॉग नहीं किया गया';
  }

  @override
  String pregnancyTestFrom(String date) {
    return 'प्रारंभिक उपयोगी परीक्षण: $date';
  }

  @override
  String pillBreakIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'ब्रेक $daysString दिनों में शुरू होता है';
  }

  @override
  String pillNewPackIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString दिनों में नया पैक';
  }

  @override
  String get healthImportNothingNew =>
      'आयात करने के लिए कोई नया रिकॉर्ड नहीं मिला';

  @override
  String healthImportConfirm(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'हेल्थ कनेक्ट में $countString अवधि अवधि पाई गई जो ऐप में नहीं है। उन्हें अपने रिकॉर्ड में जोड़ें? आपके मौजूदा रिकॉर्ड अछूते हैं.';
  }

  @override
  String healthImportDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString अवधि आयातित';
  }

  @override
  String monthPeriodDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString अवधि के दिन';
  }

  @override
  String monthLoggedDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString दिन लॉग किए गए';
  }

  @override
  String get pinNoRecoveryWarning =>
      'यदि आप अपना पिन भूल जाते हैं तो इसे पुनर्प्राप्त करने का कोई तरीका नहीं है; वापस आने का एकमात्र तरीका आपके सभी डेटा को हटाना है। कुछ ऐसा चुनें जो आपको याद रहे.';

  @override
  String lockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString मिनट के बाद';
  }

  @override
  String get reportTitle => 'मासिक चक्र स्वास्थ्य रिपोर्ट';

  @override
  String get reportGenerated => 'उत्पन्न';

  @override
  String get profileSummary => 'प्रोफ़ाइल सारांश';

  @override
  String get periodHistory => 'काल इतिहास';

  @override
  String get last30DaysSummary => 'पिछले 30 दिनों का सारांश';

  @override
  String get durationDaysHeader => 'अवधि (दिन)';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'रोशनी';

  @override
  String get themeDark => 'अंधेरा';

  @override
  String get languageSystem => 'सिस्टम';

  @override
  String get statsSectionOverview => 'सिंहावलोकन';

  @override
  String get statsSectionCharts => 'चार्ट';

  @override
  String get statsSectionHistory => 'इतिहास और रुझान';

  @override
  String storySymptomsMore(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'पिछले 30 दिन पहले की अवधि ($recentString प्रविष्टियाँ बनाम $previousString) की तुलना में अधिक कठिन थे।';
  }

  @override
  String storySymptomsLess(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'पिछले 30 दिन पहले की अवधि ($recentString प्रविष्टियाँ बनाम $previousString) की तुलना में आसान थे।';
  }

  @override
  String get storySymptomsSame =>
      'पिछली दो अवधियों में लक्षण की तीव्रता समान रही।';

  @override
  String storyTrendUp(String delta, String unit) {
    return 'इस अवधि में $delta $unit बढ़ गया।';
  }

  @override
  String storyTrendDown(String delta, String unit) {
    return 'इस अवधि में $delta $unit नीचे।';
  }

  @override
  String get storyTrendFlat =>
      'इस अवधि में कोई सार्थक परिवर्तन नहीं - प्रवृत्ति सपाट है।';

  @override
  String averageSeverity(String value) {
    return 'औसत $value/5';
  }

  @override
  String get dataCoverage => 'डेटा कवरेज';

  @override
  String dataCoverageValue(int logged, int total, int percent) {
    final intl.NumberFormat loggedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String loggedString = loggedNumberFormat.format(logged);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$totalString दिनों का $loggedString पर डेटा ($percentString%)';
  }

  @override
  String get tapChartPointHint => 'उस दिन खोलने के लिए किसी बिंदु पर टैप करें.';

  @override
  String get shareCalendarMonth => 'कैलेंडर माह साझा करें';

  @override
  String get longPressDayHint => 'त्वरित पूर्वावलोकन के लिए एक दिन दबाकर रखें।';

  @override
  String get markPeriodRange => 'मासिक धर्म की तारीखें चुनें';

  @override
  String get periodRangeOverlap =>
      'ये तारीखें पहले से दर्ज मासिक धर्म से मेल खाती हैं।';

  @override
  String get periodRangeSaved => 'मासिक धर्म की तारीखें सहेजी गईं';

  @override
  String trackingStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'लगातार $countString दिन दर्ज किए';
  }

  @override
  String weeklyTracking(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/7 दिन लॉग किया गया';
  }

  @override
  String get exportCalendarFile => 'निर्यात कैलेंडर (.ics)';

  @override
  String get ovulationMarkerHint =>
      'धराशायी रेखा: अनुमानित या पुष्टि की गई ओव्यूलेशन';

  @override
  String get addPastCycles => 'पिछले चक्र जोड़ें';

  @override
  String get addPastCyclesHint =>
      'अधिकतम 3 अवधि दिनांक सीमाएँ चुनें और उन्हें एक साथ सहेजें।';

  @override
  String get addPeriodRange => 'मासिक धर्म की तारीखें जोड़ें';

  @override
  String get cycleOverlayTitle => 'चक्र तुलना';

  @override
  String get symptomLoadComparison =>
      'दैनिक लक्षण गंभीरता चक्र दिवस के अनुसार संरेखित होती है';

  @override
  String get currentCycleLabel => 'यह चक्र';

  @override
  String get previousCycleLabel => 'पिछला मासिक चक्र';

  @override
  String get colorBlindPattern => 'पैटर्नयुक्त चरण रंग';

  @override
  String get colorBlindPatternDesc =>
      'चरण बैंड में बनावट जोड़ता है - जब रंगों को अलग करना मुश्किल हो तो सहायक होता है';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get periodMarkedStarted => 'मासिक धर्म की शुरुआत सहेजी गई';

  @override
  String get periodMarkedEnded => 'मासिक धर्म की समाप्ति सहेजी गई';

  @override
  String get editPeriodRecord => 'मासिक धर्म का रिकॉर्ड बदलें';

  @override
  String get startDateLabel => 'प्रारंभ करें';

  @override
  String get endDateLabel => 'ख़त्म';

  @override
  String get recordUpdated => 'रिकॉर्ड अपडेट किया गया';

  @override
  String get dataResetTitle => 'आपका डेटा पढ़ा नहीं जा सका';

  @override
  String get dataResetBody =>
      'इस डिवाइस पर ऐप डेटा डिक्रिप्ट नहीं किया जा सका. यह आमतौर पर फोन स्विच करने या सिस्टम बैकअप बहाल करने के बाद होता है: डेटा को एक डिवाइस-विशिष्ट कुंजी के साथ एन्क्रिप्ट किया जाता है जो किसी नए डिवाइस पर नहीं जा सकता है। ऐप नए सिरे से शुरू हुआ है.\n\nअपने डेटा को डिवाइसों के बीच स्थानांतरित करने के लिए, सेटिंग्स > डेटा का बैकअप लें के माध्यम से नियमित रूप से JSON बैकअप निर्यात करें।';

  @override
  String get pinSet => 'पिन सफलतापूर्वक सेट हो गया';

  @override
  String get pinRemoved => 'पिन हटा दिया गया';

  @override
  String get unlockWithBiometric => 'फ़िंगरप्रिंट या चेहरे से अनलॉक करें';

  @override
  String get biometricNotAvailable =>
      'इस डिवाइस पर बायोमेट्रिक प्रमाणीकरण उपलब्ध नहीं है';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileSaved => 'प्रोफ़ाइल सहेजी गई';

  @override
  String sleepDurationShort(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString घंटे $minutesString मिनट';
  }

  @override
  String get deleteAllDataConfirm =>
      'क्या आप वाकई सारा डेटा हटाना चाहते हैं? इस एक्शन को वापस नहीं किया जा सकता।';

  @override
  String get dataDeleted => 'सारा डेटा मिटा दिया गया';

  @override
  String get doseHint => 'जैसे 500 मि.ग्रा';

  @override
  String get menstrualPhaseInfo =>
      'वह अवधि जब मासिक धर्म में रक्तस्राव होता है। आमतौर पर 3-7 दिनों तक रहता है. शरीर गर्भाशय की परत को त्याग देता है।';

  @override
  String get follicularPhaseInfo =>
      'आपके मासिक धर्म के बाद, अंडाशय एक नया अंडा तैयार करते हैं। एस्ट्रोजन बढ़ता है और ऊर्जा का स्तर बढ़ता है।';

  @override
  String get ovulationPhaseInfo =>
      'वह चरण जब अंडाशय से अंडा निकलता है। गर्भधारण की संभावना अपने उच्चतम स्तर पर है।';

  @override
  String get lutealPhaseInfo =>
      'ओव्यूलेशन से अगली अवधि तक का चरण। प्रोजेस्टेरोन बढ़ता है, पीएमएस के लक्षण हो सकते हैं।';

  @override
  String get fertileWindowInfo =>
      'वह अवधि जिसमें गर्भधारण की संभावना सबसे अधिक होती है। ओव्यूलेशन से 5 दिन पहले शुरू होता है और 1 दिन बाद समाप्त होता है।';

  @override
  String get ovulationCardInfo =>
      'अनुमानित दिन जब अंडाशय से अंडा निकलता है। चक्र के मध्य के आसपास घटित होता है।';

  @override
  String get nextPeriodInfo =>
      'आपकी अगली माहवारी की अनुमानित आरंभ तिथि. आपके चक्र की लंबाई के आधार पर गणना की गई।';

  @override
  String get phaseInfoTitle => 'यह चरण क्या है?';

  @override
  String get learnMore => 'जानकारी';

  @override
  String get healthDisclaimer =>
      'यह ऐप चिकित्सीय सलाह का विकल्प नहीं है। कृपया स्वास्थ्य संबंधी चिंताओं के लिए किसी स्वास्थ्य देखभाल पेशेवर से परामर्श लें।';

  @override
  String get homePriority => 'होम स्क्रीन प्राथमिकता';

  @override
  String get cycleFirst => 'मासिक चक्र पहले';

  @override
  String get todayFirst => 'आज सबसे पहले';

  @override
  String get planLifetime => 'जीवनकाल';

  @override
  String get planLifetimeDetail => 'एक बार भुगतान, हमेशा के लिए प्रीमियम';

  @override
  String get cycleNotificationFrequency => 'चक्र अधिसूचना स्तर';

  @override
  String get cycleNotificationFrequencyDesc =>
      'दवा अनुस्मारक प्रभावित नहीं होते हैं';

  @override
  String get notificationFrequencyEssential => 'आवश्यक';

  @override
  String get notificationFrequencyBalanced => 'संतुलित';

  @override
  String get notificationFrequencyDetailed => 'विस्तृत';

  @override
  String get readOnlyHistoryNotice =>
      'आप अपनी पिछली प्रविष्टियाँ देख सकते हैं; नई दैनिक प्रविष्टियों और परिवर्तनों के लिए प्रीमियम की आवश्यकता होती है।';

  @override
  String get screenProtectionTitle => 'स्क्रीन सुरक्षा';

  @override
  String get screenProtectionDescription =>
      'स्क्रीनशॉट और हाल के ऐप्स में पूर्वावलोकन को रोकती है।';

  @override
  String get predictionUncertain => 'चक्र चरण अनिश्चित';

  @override
  String get startupRecoveryBody =>
      'आपका डेटा सुरक्षित रूप से नहीं खोला जा सका. इसे संरक्षित कर लिया गया है. पुनः प्रयास करें, या ऐप बंद करें और सहायता से संपर्क करें। अपना बैकअप पुनर्प्राप्त करने से पहले पुनः इंस्टॉल न करें.';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get adPrivacyOptions => 'विज्ञापन गोपनीयता विकल्प';

  @override
  String get policyAvailableEnglish =>
      'यह नीति अंग्रेजी में उपलब्ध है. मूल नीति पाठ इस प्रकार है।';

  @override
  String get purchasePending => 'भुगतान की पुष्टि की प्रतीक्षा की जा रही है';

  @override
  String get purchaseVerifying => 'आपकी खरीदारी का सत्यापन किया जा रहा है';

  @override
  String get purchaseFailed =>
      'आपकी खरीदारी सत्यापित नहीं की जा सकी. कृपया पुनः प्रयास करें या खरीदारी पुनर्स्थापित करें।';

  @override
  String get pillSchedule => 'गोली अनुसूची';

  @override
  String get pillContinuous => 'निरंतर (कोई विराम नहीं)';

  @override
  String get predictionRange => 'अनुमानित तिथि सीमा';

  @override
  String get analyticsChoice => 'उपयोग मापन (वैकल्पिक)';

  @override
  String get analyticsChoiceDescription =>
      'वैकल्पिक. इस डिवाइस पर केवल ऐप क्रियाओं की गणना करता है। स्वास्थ्य डेटा, नोट्स, दिनांक और पहचान को बाहर रखा गया है। कॉन्फ़िगर की गई सेवा के बिना कुछ भी अपलोड नहीं किया जाता है.';

  @override
  String get reportRange => 'रिपोर्ट दिनांक सीमा';

  @override
  String get allHistory => 'सारा इतिहास';

  @override
  String get pillActiveDaysTitle => 'सक्रिय गोली दिन (1-120)';

  @override
  String get pillBreakDaysTitle => 'ब्रेक या प्लेसीबो दिन (0-14)';

  @override
  String get pillPrescriptionNote =>
      'अपने नुस्खे या चिकित्सक के निर्देशों में केवल शेड्यूल का उपयोग करें। यह सेटिंग दवा बदलने की अनुशंसा नहीं करती है।';
}
