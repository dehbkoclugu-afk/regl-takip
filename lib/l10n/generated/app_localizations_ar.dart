// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع الدورة الشهرية';

  @override
  String get home => 'الرئيسية';

  @override
  String get calendar => 'التقويم';

  @override
  String get log => 'تسجيل';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get onboardingWelcome => 'مرحبًا!';

  @override
  String get onboardingWelcomeDesc => 'أسهل طريقة لتتبع صحتك';

  @override
  String get onboardingTitle1 => 'تابعي دورتك الشهرية';

  @override
  String get onboardingDesc1 =>
      'سجلي دورتك الشهرية واطلعي على الموعد المتوقع للدورة التالية.';

  @override
  String get onboardingTitle2 => 'مراقبة صحتك';

  @override
  String get onboardingDesc2 => 'تتبع الأعراض والمزاج ودرجة الحرارة والمزيد.';

  @override
  String get onboardingTitle3 => 'عرض التحليل الخاص بك';

  @override
  String get onboardingDesc3 =>
      'افهم دورتك من خلال الرسوم البيانية والإحصائيات التفصيلية.';

  @override
  String get onboardingTitle4 => 'احصل على الإخطارات';

  @override
  String get onboardingDesc4 => 'تلقي تذكيرات للدورة الشهرية وأيام الإباضة.';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get back => 'العودة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تحرير';

  @override
  String get done => 'تم';

  @override
  String get maybeLater => 'قم بالإعداد لاحقًا';

  @override
  String get enableBiometric => 'بصمة الإصبع / التعرف على الوجه';

  @override
  String get enablePin => 'القفل باستخدام رقم التعريف الشخصي';

  @override
  String get securitySetup => 'إعداد الأمان';

  @override
  String get securitySetupDesc => 'هل ترغب في قفل التطبيق؟';

  @override
  String get enterName => 'أدخل اسمك';

  @override
  String get name => 'الاسم';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get lastPeriodDate => 'تاريخ آخر دورة شهرية';

  @override
  String get averageCycleLength => 'متوسط طول الدورة';

  @override
  String get averagePeriodLength => 'متوسط مدة الحيض';

  @override
  String get days => 'أيام';

  @override
  String get day => 'يوم';

  @override
  String get today => 'اليوم';

  @override
  String get cycleDay => 'يوم الدورة';

  @override
  String get periodIn => 'موعد الحيض بعد';

  @override
  String daysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'باقي $countString يوم',
      many: 'باقي $countString يومًا',
      few: 'باقي $countString أيام',
      two: 'باقي يومان',
      one: 'باقي يوم واحد',
      zero: 'باقي $countString أيام',
    );
    return '$_temp0';
  }

  @override
  String get periodToday => 'قد تبدأ دورتك الشهرية اليوم';

  @override
  String get periodOngoing => 'أنت في دورتك الشهرية';

  @override
  String get ovulationDay => 'يوم الإباضة';

  @override
  String get fertileWindow => 'فترة الخصوبة';

  @override
  String get lutealPhase => 'المرحلة الأصفرية';

  @override
  String get follicularPhase => 'المرحلة الجريبية';

  @override
  String get periodPhase => 'مرحلة الحيض';

  @override
  String get logPeriod => 'تسجيل الحيض';

  @override
  String get periodStarted => 'بدأ الحيض';

  @override
  String get periodEnded => 'انتهى الحيض';

  @override
  String get flowIntensity => 'شدة تدفق الحيض';

  @override
  String get light => 'خفيف';

  @override
  String get medium => 'متوسط';

  @override
  String get heavy => 'غزير';

  @override
  String get veryHeavy => 'غزير جداً';

  @override
  String get spotting => 'تبقيع دموي';

  @override
  String get symptoms => 'الأعراض';

  @override
  String get mood => 'المزاج';

  @override
  String get temperature => 'درجة حرارة الجسم';

  @override
  String get weight => 'الوزن';

  @override
  String get waterIntake => 'كمية المياه';

  @override
  String get sleep => 'النوم';

  @override
  String get sexualActivity => 'النشاط الجنسي';

  @override
  String get medication => 'الدواء';

  @override
  String get notes => 'ملاحظات';

  @override
  String get cramps => 'تشنجات';

  @override
  String get headache => 'الصداع';

  @override
  String get bloating => 'الانتفاخ';

  @override
  String get breastTenderness => 'ألم الثدي عند اللمس';

  @override
  String get backPain => 'آلام الظهر';

  @override
  String get fatigue => 'التعب';

  @override
  String get nausea => 'غثيان';

  @override
  String get dizziness => 'الدوخة';

  @override
  String get stress => 'الإجهاد';

  @override
  String get anxiety => 'القلق';

  @override
  String get irritability => 'التهيج';

  @override
  String get crying => 'البكاء';

  @override
  String get sensitivity => 'الحساسية';

  @override
  String get acne => 'حب الشباب';

  @override
  String get oilySkin => 'البشرة الدهنية';

  @override
  String get drySkin => 'البشرة الجافة';

  @override
  String get constipation => 'الإمساك';

  @override
  String get diarrhea => 'الإسهال';

  @override
  String get gas => 'غازات البطن';

  @override
  String get increasedAppetite => 'زيادة الشهية';

  @override
  String get decreasedAppetite => 'انخفاض الشهية';

  @override
  String get insomnia => 'الأرق';

  @override
  String get hotFlash => 'هبات ساخنة';

  @override
  String get swelling => 'تورم';

  @override
  String get hairLoss => 'تساقط الشعر';

  @override
  String get happy => 'سعيد';

  @override
  String get sad => 'حزين';

  @override
  String get angry => 'غاضب';

  @override
  String get anxious => 'قلق';

  @override
  String get calm => 'الهدوء';

  @override
  String get energetic => 'نشيط';

  @override
  String get tired => 'متعب';

  @override
  String get romantic => 'رومانسي';

  @override
  String get confused => 'مرتبك';

  @override
  String get confident => 'واثق';

  @override
  String get avgCycleLength => 'متوسط طول الدورة';

  @override
  String get avgPeriodLength => 'متوسط مدة الحيض';

  @override
  String get cycleHistory => 'سجل الدورات';

  @override
  String get symptomFrequency => 'تردد الأعراض';

  @override
  String get moodDistribution => 'توزيع المزاج';

  @override
  String get temperatureTrend => 'اتجاه درجة الحرارة';

  @override
  String get weightTrend => 'اتجاه الوزن';

  @override
  String get last3Months => 'آخر 3 أشهر';

  @override
  String get last6Months => 'آخر 6 أشهر';

  @override
  String get last12Months => 'آخر 12 شهرًا';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get exportPdf => 'تقرير بصيغة PDF';

  @override
  String get exportCsv => 'ملف CSV';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get lightTheme => 'المظهر الفاتح';

  @override
  String get darkTheme => 'المظهر الداكن';

  @override
  String get notifications => 'الإخطارات';

  @override
  String get periodReminder => 'تذكير بالحيض';

  @override
  String get ovulationReminder => 'تذكير الإباضة';

  @override
  String get medicationReminder => 'تذكير الدواء';

  @override
  String get waterReminder => 'تذكير بالمياه';

  @override
  String get security => 'الأمن';

  @override
  String get pinLock => 'قفل رقم التعريف الشخصي';

  @override
  String get biometricLock => 'قفل البيومترية';

  @override
  String get dataBackup => 'النسخ الاحتياطي للبيانات';

  @override
  String get deleteAllData => 'حذف كافة البيانات';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get glasses => 'أكواب';

  @override
  String get dailyGoal => 'الهدف اليومي';

  @override
  String get sleepQuality => 'جودة النوم';

  @override
  String get bedTime => 'وقت النوم';

  @override
  String get wakeTime => 'وقت الاستيقاظ';

  @override
  String get totalSleep => 'النوم التام';

  @override
  String get hours => 'ساعات';

  @override
  String get protection => 'الحماية';

  @override
  String get condom => 'الواقي الذكري';

  @override
  String get pill => 'حبوب منع الحمل';

  @override
  String get iud => 'اللولب';

  @override
  String get none => 'لا شيء';

  @override
  String get other => 'أخرى';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get dose => 'جرعة';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get taken => 'تم التناول';

  @override
  String get notTaken => 'لم يتم التناول';

  @override
  String get addNote => 'أضف ملاحظة';

  @override
  String get selectDate => 'حدد التاريخ';

  @override
  String get noDataYet => 'لا توجد بيانات حتى الآن';

  @override
  String get predictions => 'التنبؤات';

  @override
  String get nextPeriod => 'الدورة الشهرية القادمة';

  @override
  String get nextOvulation => 'التبويض التالي';

  @override
  String get cycleRegularity => 'انتظام الدورة';

  @override
  String get regular => 'منتظم';

  @override
  String get irregular => 'غير منتظم';

  @override
  String get setupComplete => 'اكتمل الإعداد!';

  @override
  String get letsStart => 'لنبدأ';

  @override
  String get bmi => 'مؤشر كتلة الجسم';

  @override
  String get goalReached => 'تم الوصول للهدف!';

  @override
  String get helloGeneric => 'مرحبا!';

  @override
  String get dayHasRecord => 'لديه سجل';

  @override
  String get increase => 'زيادة';

  @override
  String get decrease => 'إنقاص';

  @override
  String get bbtHint =>
      'للحصول على قراءة دقيقة، قم بالقياس مباشرة بعد الاستيقاظ، وقبل النهوض من السرير، في نفس الوقت كل يوم. يعتمد تأكيد الإباضة على هذه القراءات.';

  @override
  String get deleteMeasurement => 'حذف القياس';

  @override
  String get measurementDeleted => 'تم حذف القياس';

  @override
  String get deleteRecord => 'حذف السجل';

  @override
  String get recordDeleted => 'تم حذف السجل';

  @override
  String get invalidWeight => 'أدخل وزنًا صالحًا (20-300 كجم)';

  @override
  String get invalidTemperature => 'أدخل درجة حرارة صالحة (35-40 درجة مئوية)';

  @override
  String get discardChangesTitle => 'التغييرات غير المحفوظة';

  @override
  String get discardChangesBody => 'لم يتم حفظ ملاحظتك. ترك الآن يتجاهل ذلك.';

  @override
  String get discard => 'تجاهل';

  @override
  String severityLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'خطورة $levelString/5';
  }

  @override
  String get pregnancySetStartPrompt => 'انقر لتعيين بداية الحمل';

  @override
  String helloName(String name) {
    return 'مرحبًا، $name!';
  }

  @override
  String get ovulationPhase => 'مرحلة التبويض';

  @override
  String get menstrualPhase => 'مرحلة الحيض';

  @override
  String get todaySummary => 'ملخص اليوم';

  @override
  String get howAreYouFeeling => 'كيف تشعر اليوم؟';

  @override
  String get logMoodAndSymptoms => 'سجل حالتك المزاجية والأعراض';

  @override
  String get addRecord => 'إضافة سجل';

  @override
  String nSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString عرض',
      many: '$countString عرضًا',
      few: '$countString أعراض',
      two: 'عرضان',
      one: 'عرض واحد',
      zero: 'أعراض $countString',
    );
    return '$_temp0';
  }

  @override
  String get periodDayLabel => 'يوم الحيض';

  @override
  String get predicted => 'توقع';

  @override
  String get fertile => 'فترة الخصوبة';

  @override
  String get ovulation => 'الإباضة';

  @override
  String moodLabel(String mood) {
    return 'المزاج: $mood';
  }

  @override
  String nGlassesWater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString أكواب ماء';
  }

  @override
  String get noRecordForDay => 'لا يوجد سجل لهذا اليوم.';

  @override
  String get dailyLog => 'السجل اليومي';

  @override
  String get dailyMeasurements => 'القياسات اليومية';

  @override
  String get flow => 'تدفق الحيض';

  @override
  String get recorded => 'مسجلة';

  @override
  String nMedications(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString دواء',
      many: '$countString دواءً',
      few: '$countString أدوية',
      two: 'دواءان',
      one: 'دواء واحد',
      zero: 'أدوية $countString',
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
      other: '$countString كوب',
      many: '$countString كوبًا',
      few: '$countString أكواب',
      two: 'كوبان',
      one: 'كوب واحد',
      zero: '$countString أكواب',
    );
    return '$_temp0';
  }

  @override
  String get flowTracking => 'تتبع تدفق الحيض';

  @override
  String get color => 'اللون';

  @override
  String get lightRed => 'أحمر فاتح';

  @override
  String get red => 'أحمر';

  @override
  String get darkRed => 'أحمر داكن';

  @override
  String get brown => 'براون';

  @override
  String get clots => 'جلطات دموية';

  @override
  String get clotsQuestion => 'أي جلطات؟';

  @override
  String get padChange => 'تغييرات الفوط الصحية';

  @override
  String get flowSaved => 'تم حفظ تدفق الحيض';

  @override
  String get symptomTracking => 'تتبع الأعراض';

  @override
  String get physical => 'جسدية';

  @override
  String get emotional => 'عاطفية';

  @override
  String get skinCategory => 'الجلد';

  @override
  String get digestive => 'الجهاز الهضمي';

  @override
  String get otherCategory => 'أخرى';

  @override
  String get glowingSkin => 'بشرة متوهجة';

  @override
  String saveNSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'حفظ (أعراض $countString)';
  }

  @override
  String nSymptomsSaved(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'تم حفظ أعراض $countString';
  }

  @override
  String get addNoteOptional => 'إضافة ملاحظة (اختياري)';

  @override
  String get writeAboutToday => 'أكتب شيئا عن اليوم...';

  @override
  String get moodSaved => 'تم حفظ المزاج';

  @override
  String get sensitiveM => 'حساسة';

  @override
  String get irritableM => 'سريع الانفعال';

  @override
  String get neutralM => 'محايد';

  @override
  String get lowTemp => 'منخفض';

  @override
  String get normalTemp => 'عادي';

  @override
  String get highTemp => 'عالية';

  @override
  String get fever => 'حمى';

  @override
  String get measurementTime => 'وقت القياس';

  @override
  String get temperatureSaved => 'تم حفظ درجة الحرارة';

  @override
  String get quickAdjust => 'ضبط سريع';

  @override
  String get manualEntry => 'الإدخال اليدوي';

  @override
  String get weightSaved => 'تم حفظ الوزن';

  @override
  String get waterTracking => 'تتبع المياه';

  @override
  String get waterSaved => 'حفظ المياه';

  @override
  String get sleepTracking => 'تتبع النوم';

  @override
  String get bedTimeLabel => 'وقت النوم';

  @override
  String get wakeTimeLabel => 'وقت الاستيقاظ';

  @override
  String get veryBad => 'سيء جدًا';

  @override
  String get bad => 'سيئة';

  @override
  String get moderate => 'معتدل';

  @override
  String get good => 'جيد';

  @override
  String get great => 'عظيم';

  @override
  String get sleepSaved => 'تم حفظ النوم';

  @override
  String get protectionMethod => 'طريقة الحماية';

  @override
  String get orgasm => 'هزة الجماع';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get addNoteHint => 'إضافة ملاحظة...';

  @override
  String get savedGeneric => 'تم الحفظ';

  @override
  String get medicationTracking => 'تتبع الدواء';

  @override
  String get addMedication => 'أضف الدواء';

  @override
  String get noMedicationsYet => 'لم تتم إضافة أي أدوية حتى الآن';

  @override
  String get medicationPlanHint =>
      'تنطبق هذه الخطة كل يوم. يسجل مربع الاختيار اليوم المحدد فقط.';

  @override
  String get medicationAlreadyInPlan => 'هذا الدواء موجود بالفعل في الخطة';

  @override
  String get tapToAdd => 'اضغط على + للإضافة';

  @override
  String get add => 'أضف';

  @override
  String get dailyNote => 'ملاحظة يومية';

  @override
  String get myNotes => 'ملاحظاتي';

  @override
  String get notesHint => 'كيف تشعر؟ أكتب ملاحظاتك هنا...';

  @override
  String get noteSaved => 'تم حفظ الملاحظة';

  @override
  String get cycleOverview => 'نظرة عامة على الدورة';

  @override
  String get avgCycle => 'متوسط الدورة';

  @override
  String get avgPeriod => 'متوسط مدة الحيض';

  @override
  String get regularity => 'الانتظام';

  @override
  String get insufficientData => 'بيانات غير كافية';

  @override
  String get noSymptomData => 'لا توجد بيانات الأعراض حتى الآن';

  @override
  String get noMoodData => 'لا توجد بيانات الحالة المزاجية حتى الآن';

  @override
  String get noCycleData => 'لا توجد بيانات دورة حتى الآن';

  @override
  String get ongoing => 'مستمر';

  @override
  String nDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString يوم',
      many: '$countString يومًا',
      few: '$countString أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'أيام $countString',
    );
    return '$_temp0';
  }

  @override
  String get profileSection => 'الملف الشخصي';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get age => 'العمر';

  @override
  String nYearsOld(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString سنة',
      many: '$countString سنة',
      few: '$countString سنوات',
      two: 'سنتان',
      one: 'سنة واحدة',
      zero: '$countString سنة',
    );
    return '$_temp0';
  }

  @override
  String get cycleDuration => 'طول الدورة الشهرية';

  @override
  String get periodDuration => 'مدة الحيض';

  @override
  String get dataSection => 'البيانات';

  @override
  String get exportPdfReport => 'تصدير تقرير PDF';

  @override
  String get exportCsvFile => 'تصدير CSV';

  @override
  String get pdfExportSoon => 'تصدير PDF قريبا!';

  @override
  String get csvExportSoon => 'تصدير CSV قريبا!';

  @override
  String get letsKnowYou => 'دعونا نتعرف عليك';

  @override
  String get whatShouldWeCallYou => 'ماذا يجب أن نسميك؟';

  @override
  String get yourName => 'اسمك';

  @override
  String get yourBirthDate => 'تاريخ ميلادك';

  @override
  String get birthDateHelp => 'يساعدنا على تقديم اقتراحات مناسبة للعمر.';

  @override
  String get selectDateHint => 'اختر التاريخ';

  @override
  String get selectDateToContinue => 'حدد تاريخًا للمتابعة';

  @override
  String stepOfSteps(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'الخطوة $currentString من $totalString';
  }

  @override
  String get lastPeriodTitle => 'آخر دورة شهرية';

  @override
  String get lastPeriodHelp => 'اختاري تاريخ بدء دورتك الشهرية الأخيرة.';

  @override
  String get cycleLengthTitle => 'طول الدورة';

  @override
  String get cycleLengthHelp =>
      'كم عدد أيام دورتك المتوسطة؟\n(من أول يوم للدورة إلى أول يوم للدورة التالية)';

  @override
  String get periodLengthTitle => 'مدة الحيض';

  @override
  String get periodLengthHelp => 'كم يوما تستمر دورتك الشهرية عادة؟';

  @override
  String get averageLabel => 'متوسط';

  @override
  String get completeBtn => 'كامل';

  @override
  String get continueBtn => 'متابعة';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get welcomeInfoTitle => 'مرحبًا!';

  @override
  String get welcomeInfoDesc =>
      'الطريقة الأسهل والأجمل لمتابعة صحتك. نحن معك في كل خطوة من دورتك.';

  @override
  String get trackCycleTitle => 'تابعي دورتك الشهرية';

  @override
  String get trackCycleDesc =>
      'سجلي مواعيد دورتك الشهرية وأعراضها وحالتك المزاجية بسهولة. جميع البيانات الخاصة بك آمنة.';

  @override
  String get getPredictionsTitle => 'احصل على التوقعات';

  @override
  String get getPredictionsDesc =>
      'تعرفي على دورتك القادمة وأيام خصوبتك من خلال التنبؤات الذكية.';

  @override
  String get startBtn => 'ابدأ';

  @override
  String daysLater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'في أيام $countString';
  }

  @override
  String get todayExclamation => 'اليوم!';

  @override
  String get spiral => 'اللولب';

  @override
  String get enterPin => 'أدخل رقم التعريف الشخصي';

  @override
  String get createPin => 'إنشاء رقم التعريف الشخصي';

  @override
  String get confirmPin => 'تأكيد رقم التعريف الشخصي';

  @override
  String get pinMismatch => 'أرقام التعريف الشخصية غير متطابقة، حاول مرة أخرى';

  @override
  String get verifyPinTitle => 'أدخل رقم التعريف الشخصي الحالي الخاص بك';

  @override
  String get wrongPin => 'رقم تعريف شخصي خاطئ';

  @override
  String tooManyAttempts(int seconds) {
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'الكثير من المحاولات الخاطئة. انتظر ثواني $secondsString';
  }

  @override
  String get coachMenstrual0 =>
      'يمكنك تسجيل النزيف والألم وما تشعر به. اطلب المشورة الطبية بشأن الأعراض التي تقلقك.';

  @override
  String get coachMenstrual1 =>
      'إذا كنت تشعر بالراحة، فقد تساعدك الحركة اللطيفة أو الدفء على الشعور بالتحسن. تختلف التجارب الفردية.';

  @override
  String get coachMenstrual2 =>
      'اختر الراحة أو النشاط وفقًا لما تشعر به اليوم.';

  @override
  String get coachFollicular0 =>
      'تختلف الطاقة والأعراض بين الأشخاص والدورات. استخدم سجلاتك الخاصة لملاحظة الأنماط.';

  @override
  String get coachFollicular1 =>
      'قد تتغير بشرتك خلال الدورة. قم بتسجيل التغييرات بدلاً من افتراض نمط ثابت.';

  @override
  String get coachFollicular2 =>
      'اختر التمرين بناءً على صحتك وراحتك، وليس على مرحلة الدورة المتوقعة.';

  @override
  String get coachOvulation0 =>
      'أيام الخصوبة هي تقديرات. هذا التطبيق ليس وسيلة لمنع الحمل.';

  @override
  String get coachOvulation1 =>
      'اطلبي المشورة الطبية في حالة الألم الجديد أو الشديد أو المستمر بدلاً من نسبته إلى الإباضة.';

  @override
  String get coachOvulation2 =>
      'يختلف المزاج والطاقة الاجتماعية. لا يمكن للمرحلة المتوقعة أن تحدد ما ستشعر به.';

  @override
  String get coachLuteal0 =>
      'النوم والتوتر والعديد من العوامل الأخرى يمكن أن تؤثر على الأعراض. سجل ما لاحظته.';

  @override
  String get coachLuteal1 =>
      'اختر الوجبات والأنشطة التي تناسب احتياجاتك. المرحلة المتوقعة لا تصف نظامًا غذائيًا.';

  @override
  String get coachLuteal2 =>
      'التغيرات المزاجية لها العديد من الأسباب المحتملة. اطلب الدعم للأعراض المستمرة أو التي تقلقك.';

  @override
  String get ovulationConfirmed => 'احتمالية التبويض';

  @override
  String get ovulationConfirmedInfo =>
      'يشير نمط درجة الحرارة أو اختبار LH إلى إمكانية الإباضة. يؤثر المرض والنوم وتوقيت القياس على النتائج. هذا ليس تأكيدًا سريريًا ويجب عدم استخدامه لمنع الحمل.';

  @override
  String get premiumSection => 'قسط';

  @override
  String get removeAds => 'إزالة الإعلانات';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get premiumActive => 'الإصدار المميز نشط — الإعلانات متوقفة';

  @override
  String get storeUnavailable => 'المتجر غير متوفر حاليا';

  @override
  String get healthSync => 'المزامنة مع الصحة الاتصال';

  @override
  String get healthSyncSuccess => 'تمت مزامنة بيانات الفترة';

  @override
  String get healthSyncDenied => 'تم رفض إذن البيانات الصحية';

  @override
  String get healthSyncUnavailable => 'لا توجد خدمة صحية على هذا الجهاز';

  @override
  String get healthSyncFailed => 'فشلت المزامنة';

  @override
  String get trackingModeTitle => 'وضع التتبع';

  @override
  String get modePeriod => 'الحيض';

  @override
  String get modePregnancy => 'الحمل';

  @override
  String get modePill => 'حبوب منع الحمل';

  @override
  String get modeTtc => 'محاولة الحمل';

  @override
  String get lhTestTitle => 'اختبار الإباضة (LH).';

  @override
  String get lhPositive => 'إيجابي';

  @override
  String get lhNegative => 'سلبي';

  @override
  String get fertilityToday => 'الخصوبة اليوم';

  @override
  String get fertilityHigh => 'عالية';

  @override
  String get fertilityMedium => 'متوسط';

  @override
  String get fertilityLow => 'منخفض';

  @override
  String pregnancyWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'الأسبوع $weekString';
  }

  @override
  String get trimester1 => 'الفصل الأول';

  @override
  String get trimester2 => 'الفصل الثاني';

  @override
  String get trimester3 => 'الفصل الثالث';

  @override
  String get pregnancyDevelopmentTitle => 'التطوير هذا الاسبوع';

  @override
  String get pregnancyDevelopment1 =>
      'تستمر فترة التطور السريع حيث تتشكل أعضاء طفلك الرئيسية وأنظمة جسمه.';

  @override
  String get pregnancyDevelopment2 =>
      'أصبحت حركات طفلك أكثر تنسيقاً؛ عندما تشعر بها يمكن أن تختلف من شخص لآخر.';

  @override
  String get pregnancyDevelopment3 =>
      'يستمر طفلك في النمو حيث يصبح الاستعداد للولادة أكثر بروزًا.';

  @override
  String get pregnancyCheckupReminder =>
      'اتبع جدول الفحص الموصى به من قبل أخصائي الرعاية الصحية الخاص بك.';

  @override
  String get pregnancyStartLabel => 'تاريخ آخر دورة (بداية الحمل)';

  @override
  String get pregnancyModeInfo =>
      'يتم إيقاف التنبؤات وتذكيرات الدورة الشهرية في وضع الحمل';

  @override
  String get pillPackStartLabel => 'تبدأ حزمة حبوب منع الحمل';

  @override
  String pillDayLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'يوم حبوب منع الحمل $dayString/21';
  }

  @override
  String pillBreakLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'استراحة الأسبوع • اليوم $dayString';
  }

  @override
  String get smartPrediction => 'التنبؤ الذكي';

  @override
  String get smartPredictionDesc =>
      'تستخدم التوقعات المتوسط الذي تعلمته من دوراتك السابقة';

  @override
  String learnedCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'تعلمت: أيام $daysString';
  }

  @override
  String get phaseInsights => 'رؤى المرحلة';

  @override
  String get noInsightsYet =>
      'لا توجد بيانات كافية للرؤى حتى الآن. أثناء قيامك بتسجيل الأعراض، ستظهر هنا الأنماط المستندة إلى المرحلة.';

  @override
  String insightLine(String symptom, String phase, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'يحدث $symptom غالبًا في الطور $phase ($percentString%)';
  }

  @override
  String get notContraceptionWarning =>
      'التوقعات هي لأغراض إعلامية فقط. هذا التطبيق ليس وسيلة لمنع الحمل ويجب عدم استخدامه لمنع الحمل.';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutSection => 'حول';

  @override
  String get consentTitle => 'بياناتك وخصوصيتك';

  @override
  String get consentBody =>
      'يتم تخزين جميع بياناتك مشفرة على هذا الجهاز فقط؛ لا يتم إرسال أي شيء إلى أي خادم. يمكنك قراءة سياسة الخصوصية ضمن الإعدادات > حول. من خلال المتابعة فإنك توافق على معالجة بياناتك على جهازك بهذه الطريقة.';

  @override
  String get consentAccept => 'أنا أقبل';

  @override
  String get quickLog => 'سجل سريع';

  @override
  String get shortcutQuickLog => 'سجل سريع';

  @override
  String get shortcutToday => 'عرض اليوم';

  @override
  String get allTrackers => 'جميع أنواع التتبع';

  @override
  String get disguiseTitle => 'وضع تمويه';

  @override
  String get disguiseDesc =>
      'يأخذ التطبيق هوية \"الملاحظات\": يصبح الاسم والرمز والأداة والإشعارات وشاشة التشغيل محايدة. العودة: اضغط لفترة طويلة على عنوان الملاحظات.';

  @override
  String get decoyTitle => 'ملاحظات';

  @override
  String get decoyEmpty => 'لا توجد ملاحظات حتى الآن';

  @override
  String get decoyHint => 'أكتب شيئا...';

  @override
  String get backupData => 'إنشاء نسخة احتياطية لكلمة المرور';

  @override
  String get backupPassword => 'كلمة المرور الاحتياطية';

  @override
  String get backupPasswordConfirm => 'أدخل كلمة المرور مرة أخرى';

  @override
  String get backupPasswordLength =>
      'يجب أن تتكون كلمة المرور من 10 إلى 128 حرفًا';

  @override
  String get backupPasswordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get backupNoRecovery =>
      'لا يتم تخزين كلمة المرور هذه على الجهاز ولا يمكن استعادتها. إذا نسيت ذلك، لا يمكنك فتح النسخة الاحتياطية.';

  @override
  String get unlockBackupTitle => 'أدخل كلمة المرور الاحتياطية';

  @override
  String get unlockBackupBody =>
      'لا يمكن فتح هذه النسخة الاحتياطية إلا باستخدام كلمة المرور المستخدمة عند إنشائها.';

  @override
  String get backupPasswordOrFileInvalid =>
      'كلمة المرور غير صحيحة أو ملف النسخ الاحتياطي تالف.';

  @override
  String get legacyBackupWarning =>
      'هذه النسخة الاحتياطية الأقدم غير مشفرة. وبعد استعادتها، ستكون النسخ الاحتياطية الجديدة محمية بكلمة مرور.';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get restoreData => 'استعادة من النسخة الاحتياطية';

  @override
  String get restoreConfirmTitle => 'استعادة النسخة الاحتياطية؟';

  @override
  String restoreConfirmBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'سيتم حذف جميع البيانات الحالية وستتم استعادة سجلات $countString من النسخة الاحتياطية. لا يمكن التراجع عن هذا.';
  }

  @override
  String get restore => 'استعادة';

  @override
  String get backupRestored => 'تمت استعادة النسخة الاحتياطية';

  @override
  String get invalidBackupFile => 'ملف النسخ الاحتياطي غير صالح';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get modeStepTitle => 'ما الذي ستستخدمه من أجله؟';

  @override
  String get modeStepSubtitle => 'يمكنك تغيير هذا لاحقًا في الإعدادات';

  @override
  String get modePeriodDesc => 'تتبع الدورة والتنبؤات';

  @override
  String get modePregnancyDesc => 'الحمل اسبوع بعد اسبوع';

  @override
  String get modePillDesc => '21+7 جدول حبوب منع الحمل';

  @override
  String get modeTtcDesc => 'تتبع يركز على الخصوبة';

  @override
  String get paywallTitle => 'اذهب إلى الإصدار المميز';

  @override
  String paywallTrialSubtitle(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'الإصدار التجريبي الخاص بك نشط: $daysString من الأيام المتبقية. Premium يبقي كل شيء مفتوحًا.';
  }

  @override
  String get paywallFreeSubtitle =>
      'انتهت محاكمتك. النسخة المجانية تحافظ على تتبع الدورة الشهرية والتقويم. التتبع اليومي والرؤى مميزة.';

  @override
  String get paywallFeatureTrackers =>
      'جميع أجهزة التتبع اليومية: الأعراض، الحالة المزاجية، الماء، النوم، الوزن، درجة الحرارة، الدواء، الملاحظات';

  @override
  String get paywallFeatureStats => 'الإحصائيات والاتجاهات وخاتم My Year';

  @override
  String get paywallFeatureInsights => 'الرؤى الشخصية وإخطارات تلميح المرحلة';

  @override
  String get paywallFeatureExport => 'تصدير PDF / CSV';

  @override
  String get paywallFeatureHealth => 'مزامنة الصحة الاتصال';

  @override
  String get paywallFeatureDisguise => 'وضع التنكر مع شرك الملاحظات';

  @override
  String get paywallFeatureNoAds => 'تجربة خالية من الإعلانات';

  @override
  String get planMonthly => 'شهريا';

  @override
  String get planYearly => 'سنويا';

  @override
  String get perMonth => '/ مو';

  @override
  String get perYear => '/ سنة';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get continueFreeBtn => 'تواصل مع مجانا في الوقت الراهن';

  @override
  String trialBadge(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'المحاكمة: $daysString أيام متبقية';
  }

  @override
  String get freeBadge => 'نسخة مجانية';

  @override
  String get freeExplain =>
      'النسخة المجانية تحافظ على تتبع الدورة الشهرية والتقويم والتنبؤات. تعد أدوات التتبع اليومية والإحصائيات والتصدير والاتصال الصحي ووضع التنكر والأوضاع مميزة.';

  @override
  String get seePlans => 'انظر الخطط';

  @override
  String get premiumLockedTitle => 'الإحصائيات ممتازة';

  @override
  String get premiumLockedBody =>
      'يتم فتح الرسوم البيانية والاتجاهات ورؤى المرحلة وخاتم My Year مع Premium. كل ما قمت بتسجيله أثناء التجربة يظل آمنًا.';

  @override
  String get yearRingTitle => 'سنتي';

  @override
  String get yearRingCycles => 'دورات';

  @override
  String yearRingSummary(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'آخر 12 شهرًا: دورات $countString';
  }

  @override
  String get cycleComparison => 'دورتك الأخيرة';

  @override
  String lastCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'الدورة الأخيرة: أيام $daysString';
  }

  @override
  String lastPeriodLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'الفترة الأخيرة: أيام $daysString';
  }

  @override
  String vsAverageMore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString أيام أطول من المتوسط الخاص بك';
  }

  @override
  String vsAverageLess(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'أيام $daysString أقصر من المتوسط';
  }

  @override
  String get vsAverageSame => 'نفس متوسطك';

  @override
  String coachPersonalInsight(String symptom, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'بناءً على سجلاتك، الأكثر شيوعًا في هذه المرحلة: $symptom ($percentString%)';
  }

  @override
  String get notificationInsightTitle => 'نصيحة المرحلة';

  @override
  String notificationInsightBody(String symptom) {
    return 'تبدأ المرحلة الأصفرية. بناءً على سجلاتك، فإن الأعراض الأكثر شيوعًا في هذه المرحلة هي: $symptom.';
  }

  @override
  String get notificationPeriodTitle => 'تذكير الفترة';

  @override
  String get notificationPeriodTimingToday => 'قد تبدأ دورتك الشهرية اليوم.';

  @override
  String get notificationPeriodTimingTomorrow => 'قد تبدأ دورتك الشهرية غدًا.';

  @override
  String notificationPeriodTimingInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'قد تبدأ الدورة الشهرية بعد أيام $daysString.';
  }

  @override
  String get notificationPeriodTip1 => 'تذكري أن تحزمي فوطة أو سدادة قطنية.';

  @override
  String get notificationPeriodTip2 => 'القليل من التحضير يجعل الأمر أسهل.';

  @override
  String get notificationPeriodTip3 => 'يؤدي تسجيل البداية إلى تحسين توقعاتك.';

  @override
  String get notificationPeriodChannel => 'تذكير الفترة';

  @override
  String get notificationPeriodChannelDesc => 'تذكير دورة الدورة الشهرية';

  @override
  String get notificationOvulationTitle => 'تذكير الإباضة';

  @override
  String get notificationOvulationBody =>
      'اليوم هو موعد الإباضة المتوقع. قد تكونين في فترة الخصوبة.';

  @override
  String get notificationOvulationChannel => 'تذكير الإباضة';

  @override
  String get notificationOvulationChannelDesc => 'تذكيرات الإباضة';

  @override
  String get notificationMedicationTitle => 'تذكير الدواء';

  @override
  String get notificationMedicationBody => 'لا تنس أن تتناول أدويتك!';

  @override
  String get notificationMedicationChannel => 'تذكير الدواء';

  @override
  String get notificationMedicationChannelDesc => 'تذكيرات الدواء';

  @override
  String get notificationDiscreetTitle => 'تذكير';

  @override
  String get notificationDiscreetBody => 'لديك تذكير لهذا اليوم';

  @override
  String get notificationFertileTitle => 'تبدأ نافذتك الخصبة';

  @override
  String get notificationFertileBody =>
      'من اليوم أنتِ في الأيام التي تتمتع بأعلى فرصة للحمل.';

  @override
  String get notificationChainEndTitle => 'التذكيرات متوقفة مؤقتًا';

  @override
  String get notificationChainEndBody =>
      'لقد نفدت التذكيرات المجدولة. افتح التطبيق لإعداد تطبيقات جديدة.';

  @override
  String get noPurchasesToRestore => 'لم يتم العثور على مشتريات لاستعادتها';

  @override
  String get restoringPurchases => 'جارٍ استعادة عمليات الشراء...';

  @override
  String get backdateHint => 'اضغط لفترة طويلة ليوم مختلف';

  @override
  String get periodStartDateHelp => 'متى بدأت دورتك الشهرية؟';

  @override
  String get periodEndDateHelp => 'متى انتهت دورتك الشهرية؟';

  @override
  String get headlinePeriodToday => 'قد تبدأ دورتك الشهرية اليوم';

  @override
  String get headlinePeriodTomorrow => 'قد تبدأ دورتك الشهرية غدًا';

  @override
  String get headlineNoData => 'أضف تاريخ الدورة الشهرية الأخيرة';

  @override
  String headlinePeriodInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'دورتك الشهرية بالأيام $daysString';
  }

  @override
  String headlinePeriodDay(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'اليوم $dayString من الدورة الشهرية';
  }

  @override
  String get headlineDelaySubtitle =>
      'بعض الاختلاف أمر طبيعي. قم بتسجيله إذا كان قد بدأ.';

  @override
  String get notificationDelayTitle => 'لقد مر التاريخ المتوقع';

  @override
  String get notificationDelayBody =>
      'إذا بدأت دورتك الشهرية، فتذكري تسجيلها. بعض الاختلاف أمر طبيعي.';

  @override
  String get notificationDelayBodyAlt1 =>
      'لا يوجد دخول بعد. إذا بدأ، فإن التسجيل يستغرق نقرة واحدة.';

  @override
  String get notificationDelayBodyAlt2 =>
      'التحول لبضعة أيام أمر شائع. هل السجل الخاص بك محدث؟';

  @override
  String get notificationDelayChannel => 'تذكير بالتأخير';

  @override
  String get notificationDelayChannelDesc => 'تذكير عند مرور التاريخ المتوقع';

  @override
  String headlineDelay(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'تأخرت الدورة الشهرية $daysString أيامًا';
  }

  @override
  String delayDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString متأخرا بأيام';
  }

  @override
  String get yourDataStays =>
      'تبقى سجلاتك على جهازك عند انتهاء النسخة التجريبية.';

  @override
  String get periodStartedOnThisDay => 'بدأت دورتي الشهرية في هذا اليوم';

  @override
  String nCyclesRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'دورات $countString المسجلة';
  }

  @override
  String nLogsRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString السجلات اليومية';
  }

  @override
  String get notifPermissionTitle => 'هل تريد تفعيل التذكيرات؟';

  @override
  String get notifPermissionBody =>
      'نخبرك بموعد اقتراب الدورة الشهرية، وفي يوم الإباضة، ومتى انقضى التاريخ المتوقع. الإخطارات لا تترك جهازك أبدًا. ويمكنك أيضًا تشغيلها لاحقًا في الإعدادات.';

  @override
  String get enableNotifications => 'تشغيل';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get optionalField => 'اختياري';

  @override
  String get privacyAssurance => 'تظل بياناتك مشفرة على هذا الجهاز فقط';

  @override
  String get privacySummary =>
      'يتم تشفير بياناتك الأساسية على هذا الجهاز؛ يتم تركه فقط عند تصديره أو تمكين Health Connect.';

  @override
  String get dontRememberExactly => 'لا أتذكر بالضبط';

  @override
  String get approxTitle => 'تقريبا متى كان؟';

  @override
  String get approxSubtitle =>
      'موعد تقريبي يكفي. تصحح التوقعات نفسها أثناء تسجيل الدخول.';

  @override
  String get approxThisWeek => 'هذا الاسبوع';

  @override
  String get approxLastWeek => 'الاسبوع الماضي';

  @override
  String get approxTwoWeeks => 'منذ حوالي 2 أسابيع';

  @override
  String get approxThreeWeeks => 'منذ حوالي 3 أسابيع';

  @override
  String get approxMonthOrMore => 'منذ شهر أو أكثر';

  @override
  String get cycleReminderTime => 'وقت تذكير الدورة';

  @override
  String get medicationReminderTime => 'وقت تذكير الدواء';

  @override
  String get periodReminderLead => 'تذكير الفترة';

  @override
  String get notificationQuietChannelSuffix => 'هادئ';

  @override
  String get quietNotifications => 'إشعارات هادئة';

  @override
  String get quietNotificationsDesc =>
      'لا يوجد صوت أو نافذة منبثقة - ينتظرون بصمت في مركز الإشعارات';

  @override
  String get leadSameDay => 'نفس اليوم';

  @override
  String leadNDaysBefore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString قبل أيام';
  }

  @override
  String get regularityInfoIrregular =>
      'هناك 9 أيام أو أكثر بين أقصر وأطول دورة. يعد تغيير طول الدورة أمرًا شائعًا جدًا؛ الإجهاد والنوم والمرض وتغيرات الحياة كلها تؤثر عليه. هذا ليس تشخيصا.';

  @override
  String get regularityInfoRegular =>
      'الفرق بين أقصر وأطول دورة لديك هو أقل من 9 أيام. التوقعات أكثر دقة مع هذا الاتساق.';

  @override
  String get regularityInfoSeeDoctor =>
      'إذا كانت دورتك الشهرية باستمرار أقل من 21 يومًا أو أطول من 35 يومًا، أو إذا لم تأتيك الدورة الشهرية لأكثر من ثلاثة أشهر، أو إذا كان النزيف غزيرًا على غير العادة، فمن المفيد التحدث إلى أخصائي الرعاية الصحية.';

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

    return 'النطاق المقبول عمومًا: دورة $minString – $maxString أيام، فترة تصل إلى $pmaxString أيام. ليس عتبة التشخيص.';
  }

  @override
  String lowConfidenceNote(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'تأتي هذه المتوسطات من دورات $countString فقط؛ سوف تزداد حدة كلما قمت بتسجيل المزيد.';
  }

  @override
  String regularityInfoInsufficient(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'هناك حاجة على الأقل إلى فجوات دورة $countString قبل أن يعني الانتظام أي شيء. الحكم على أقل من شأنه أن يكون مضللاً.';
  }

  @override
  String get backupNever => 'لم تقم بعمل نسخة احتياطية مطلقًا.';

  @override
  String get backupStaleHint => 'إذا فقدت هاتفك، فلن تتمكن من استعادة السجلات.';

  @override
  String backupLastAt(String date) {
    return 'آخر نسخة احتياطية: $date';
  }

  @override
  String get durationsStepTitle => 'تفاصيل دورتك';

  @override
  String get durationsStepHelp =>
      'لست متأكدا؟ اتركها كما هي — ويمكنك تغييرها في الإعدادات لاحقًا.';

  @override
  String get lockTimeoutTitle => 'تأخير القفل';

  @override
  String get lockTimeoutDesc =>
      'تخطي رقم التعريف الشخصي عندما تعود بعد لحظة قصيرة';

  @override
  String get lockImmediately => 'على الفور';

  @override
  String get previousDay => 'اليوم السابق';

  @override
  String get nextDay => 'في اليوم التالي';

  @override
  String get showLegend => 'مفتاح اللون';

  @override
  String get hideLegend => 'إخفاء مفتاح اللون';

  @override
  String get backToToday => 'العودة إلى اليوم';

  @override
  String get monthNoRecords => 'لا توجد سجلات هذا الشهر';

  @override
  String get doctorSummary => 'تصدير ملخص لطبيبي';

  @override
  String get healthImport => 'الاستيراد من الصحة الاتصال';

  @override
  String get healthImportAction => 'استيراد';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get actionPeriodStarted => 'بدأت دورتي الشهرية';

  @override
  String get actionMedicationTaken => 'مأخوذ';

  @override
  String get pregnancyTestReady => 'اختبار الحمل يمكن أن يكون ذا معنى الآن';

  @override
  String notLoggedToday(String what) {
    return 'لم يتم تسجيل $what اليوم';
  }

  @override
  String pregnancyTestFrom(String date) {
    return 'أول اختبار مفيد: $date';
  }

  @override
  String pillBreakIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'تبدأ الاستراحة خلال أيام $daysString';
  }

  @override
  String pillNewPackIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'حزمة جديدة في أيام $daysString';
  }

  @override
  String get healthImportNothingNew =>
      'لم يتم العثور على سجلات جديدة للاستيراد';

  @override
  String healthImportConfirm(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'تم العثور على فترات زمنية $countString في Health Connect غير موجودة في التطبيق. إضافتها إلى السجلات الخاصة بك؟ السجلات الموجودة لديك لم تمس.';
  }

  @override
  String healthImportDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'تم استيراد فترات $countString';
  }

  @override
  String monthPeriodDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'أيام الفترة $countString';
  }

  @override
  String monthLoggedDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'تم تسجيل أيام $countString';
  }

  @override
  String get pinNoRecoveryWarning =>
      'إذا نسيت رقم التعريف الشخصي (PIN) الخاص بك، فلا توجد طريقة لاستعادته؛ الطريقة الوحيدة للعودة هي حذف جميع بياناتك. اختر شيئًا سوف تتذكره.';

  @override
  String lockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'بعد $minutesString دقيقة';
  }

  @override
  String get reportTitle => 'تقرير صحة الدورة';

  @override
  String get reportGenerated => 'تم إنشاؤها';

  @override
  String get profileSummary => 'ملخص الملف الشخصي';

  @override
  String get periodHistory => 'تاريخ الفترة';

  @override
  String get last30DaysSummary => 'ملخص آخر 30 يومًا';

  @override
  String get durationDaysHeader => 'المدة (أيام)';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'ضوء';

  @override
  String get themeDark => 'الظلام';

  @override
  String get languageSystem => 'النظام';

  @override
  String get statsSectionOverview => 'نظرة عامة';

  @override
  String get statsSectionCharts => 'الرسوم البيانية';

  @override
  String get statsSectionHistory => 'التاريخ والاتجاهات';

  @override
  String storySymptomsMore(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'كانت آخر 30 يومًا أكثر قسوة من الفترة السابقة (إدخالات $recentString مقابل $previousString).';
  }

  @override
  String storySymptomsLess(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'كانت آخر 30 يومًا أسهل من الفترة السابقة (إدخالات $recentString مقابل $previousString).';
  }

  @override
  String get storySymptomsSame =>
      'وظلت شدة الأعراض مماثلة خلال الفترتين الأخيرتين.';

  @override
  String storyTrendUp(String delta, String unit) {
    return 'يصل $delta $unit خلال هذه الفترة.';
  }

  @override
  String storyTrendDown(String delta, String unit) {
    return 'أسفل $delta $unit خلال هذه الفترة.';
  }

  @override
  String get storyTrendFlat =>
      'لا يوجد تغيير ملموس خلال هذه الفترة – الاتجاه ثابت.';

  @override
  String averageSeverity(String value) {
    return 'متوسط $value/5';
  }

  @override
  String get dataCoverage => 'تغطية البيانات';

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

    return 'بيانات عن $loggedString لأيام $totalString ($percentString%)';
  }

  @override
  String get tapChartPointHint => 'اضغط على نقطة لفتح ذلك اليوم.';

  @override
  String get shareCalendarMonth => 'مشاركة الشهر التقويمي';

  @override
  String get longPressDayHint =>
      'اضغط مع الاستمرار على يوم واحد لمعاينة سريعة.';

  @override
  String get markPeriodRange => 'تحديد نطاق تواريخ الحيض';

  @override
  String get periodRangeOverlap => 'تتداخل هذه التواريخ مع سجل حيض موجود.';

  @override
  String get periodRangeSaved => 'تم حفظ تواريخ الحيض';

  @override
  String trackingStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString أيام متتالية من التسجيل';
  }

  @override
  String weeklyTracking(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/7 أيام مسجلة';
  }

  @override
  String get exportCalendarFile => 'تصدير التقويم (.ics)';

  @override
  String get ovulationMarkerHint => 'الخط المتقطع: الإباضة المقدرة أو المؤكدة';

  @override
  String get addPastCycles => 'إضافة الدورات الماضية';

  @override
  String get addPastCyclesHint =>
      'حدد ما يصل إلى 3 نطاقات زمنية للفترات واحفظها معًا.';

  @override
  String get addPeriodRange => 'إضافة تواريخ الحيض';

  @override
  String get cycleOverlayTitle => 'مقارنة الدورة';

  @override
  String get symptomLoadComparison =>
      'شدة الأعراض اليومية تتماشى مع يوم الدورة';

  @override
  String get currentCycleLabel => 'هذه الدورة';

  @override
  String get previousCycleLabel => 'الدورة السابقة';

  @override
  String get colorBlindPattern => 'ألوان المرحلة منقوشة';

  @override
  String get colorBlindPatternDesc =>
      'يضيف نسيجًا إلى نطاقات الطور - وهو أمر مفيد عندما يصعب التمييز بين الألوان';

  @override
  String get undo => 'تراجع';

  @override
  String get periodMarkedStarted => 'تم حفظ بداية الحيض';

  @override
  String get periodMarkedEnded => 'تم حفظ نهاية الحيض';

  @override
  String get editPeriodRecord => 'تعديل سجل الحيض';

  @override
  String get startDateLabel => 'ابدأ';

  @override
  String get endDateLabel => 'نهاية';

  @override
  String get recordUpdated => 'تم تحديث السجل';

  @override
  String get dataResetTitle => 'لا يمكن قراءة البيانات الخاصة بك';

  @override
  String get dataResetBody =>
      'لا يمكن فك تشفير بيانات التطبيق على هذا الجهاز. يحدث هذا عادةً بعد تبديل الهواتف أو استعادة نسخة احتياطية للنظام: يتم تشفير البيانات بمفتاح خاص بالجهاز لا يمكن نقله إلى جهاز جديد. بدأ التطبيق جديدًا.\n\nلنقل بياناتك بين الأجهزة، قم بتصدير نسخة احتياطية من JSON بانتظام عبر الإعدادات > النسخ الاحتياطي للبيانات.';

  @override
  String get pinSet => 'تم تعيين رقم التعريف الشخصي بنجاح';

  @override
  String get pinRemoved => 'تمت إزالة رقم التعريف الشخصي';

  @override
  String get unlockWithBiometric => 'فتح القفل ببصمة الإصبع أو الوجه';

  @override
  String get biometricNotAvailable =>
      'المصادقة البيومترية غير متوفرة على هذا الجهاز';

  @override
  String get editProfile => 'تحرير الملف الشخصي';

  @override
  String get profileSaved => 'تم حفظ الملف الشخصي';

  @override
  String sleepDurationShort(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString س $minutesString د';
  }

  @override
  String get deleteAllDataConfirm =>
      'هل أنت متأكد أنك تريد حذف كافة البيانات؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get dataDeleted => 'تم حذف كافة البيانات';

  @override
  String get doseHint => 'على سبيل المثال 500 ملغ';

  @override
  String get menstrualPhaseInfo =>
      'الفترة التي يحدث فيها نزيف الدورة الشهرية. يستمر عادة 3-7 أيام. يتخلص الجسم من بطانة الرحم.';

  @override
  String get follicularPhaseInfo =>
      'بعد الدورة الشهرية، يقوم المبيضان بإعداد بويضة جديدة. يرتفع هرمون الاستروجين وترتفع مستويات الطاقة.';

  @override
  String get ovulationPhaseInfo =>
      'المرحلة التي يتم فيها إطلاق البويضة من المبيض. احتمالية الحمل في أعلى مستوياتها.';

  @override
  String get lutealPhaseInfo =>
      'المرحلة من الإباضة حتى الدورة التالية. يرتفع هرمون البروجسترون، وقد تظهر أعراض الدورة الشهرية.';

  @override
  String get fertileWindowInfo =>
      'الفترة التي لديها أعلى فرصة للحمل. يبدأ قبل 5 أيام من الإباضة وينتهي بعد يوم واحد.';

  @override
  String get ovulationCardInfo =>
      'اليوم المقدر لخروج البويضة من المبيض. يحدث في منتصف الدورة.';

  @override
  String get nextPeriodInfo =>
      'التاريخ المتوقع لبدء دورتك الشهرية التالية. يتم حسابه بناءً على طول دورتك.';

  @override
  String get phaseInfoTitle => 'ما هي هذه المرحلة؟';

  @override
  String get learnMore => 'معلومات';

  @override
  String get healthDisclaimer =>
      'هذا التطبيق ليس بديلا عن المشورة الطبية. يرجى استشارة أخصائي الرعاية الصحية للمخاوف الصحية.';

  @override
  String get homePriority => 'أولوية الشاشة الرئيسية';

  @override
  String get cycleFirst => 'الدورة أولاً';

  @override
  String get todayFirst => 'اليوم أولا';

  @override
  String get planLifetime => 'مدى الحياة';

  @override
  String get planLifetimeDetail => 'دفعة واحدة، ومزايا Premium مدى الحياة';

  @override
  String get cycleNotificationFrequency => 'مستوى الإخطار دورة';

  @override
  String get cycleNotificationFrequencyDesc => 'لا تتأثر تذكيرات الدواء';

  @override
  String get notificationFrequencyEssential => 'ضروري';

  @override
  String get notificationFrequencyBalanced => 'متوازن';

  @override
  String get notificationFrequencyDetailed => 'مفصلة';

  @override
  String get readOnlyHistoryNotice =>
      'يمكنك عرض إدخالاتك السابقة. الإدخالات والتغييرات اليومية الجديدة تتطلب Premium.';

  @override
  String get screenProtectionTitle => 'حماية الشاشة';

  @override
  String get screenProtectionDescription =>
      'تمنع لقطات الشاشة ومعاينة التطبيق في قائمة التطبيقات الأخيرة.';

  @override
  String get predictionUncertain => 'مرحلة الدورة غير مؤكدة';

  @override
  String get startupRecoveryBody =>
      'لا يمكن فتح بياناتك بأمان. لقد تم الحفاظ عليه. أعد المحاولة، أو أغلق التطبيق واتصل بالدعم. لا تقم بإعادة التثبيت قبل استعادة النسخة الاحتياطية الخاصة بك.';

  @override
  String get retry => 'أعد المحاولة';

  @override
  String get adPrivacyOptions => 'خيارات خصوصية الإعلان';

  @override
  String get policyAvailableEnglish =>
      'هذه السياسة متاحة باللغة الإنجليزية. فيما يلي نص السياسة الأصلي.';

  @override
  String get purchasePending => 'في انتظار تأكيد الدفع';

  @override
  String get purchaseVerifying => 'التحقق من عملية الشراء';

  @override
  String get purchaseFailed =>
      'لا يمكن التحقق من عملية الشراء الخاصة بك. الرجاء إعادة المحاولة أو استعادة المشتريات.';

  @override
  String get pillSchedule => 'جدول حبوب منع الحمل';

  @override
  String get pillContinuous => 'مستمر (بدون انقطاع)';

  @override
  String get predictionRange => 'النطاق الزمني المقدر';

  @override
  String get analyticsChoice => 'قياس الاستخدام (اختياري)';

  @override
  String get analyticsChoiceDescription =>
      'اختياري. يتم احتساب إجراءات التطبيق فقط على هذا الجهاز. يتم استبعاد البيانات الصحية والملاحظات والتواريخ والهوية. لا يتم تحميل أي شيء بدون خدمة مكونة.';

  @override
  String get reportRange => 'تقرير النطاق الزمني';

  @override
  String get allHistory => 'كل التاريخ';

  @override
  String get pillActiveDaysTitle => 'أيام حبوب منع الحمل النشطة (1-120)';

  @override
  String get pillBreakDaysTitle => 'أيام الراحة أو العلاج الوهمي (0-14)';

  @override
  String get pillPrescriptionNote =>
      'استخدم فقط الجدول الزمني في وصفتك الطبية أو تعليمات الطبيب. لا ينصح هذا الإعداد بتغيير الدواء.';
}
