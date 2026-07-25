// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Трекер Цикла';

  @override
  String get home => 'Главная';

  @override
  String get calendar => 'Календарь';

  @override
  String get log => 'Дневник';

  @override
  String get statistics => 'Статистика';

  @override
  String get settings => 'Настройки';

  @override
  String get profile => 'Профиль';

  @override
  String get onboardingWelcome => 'Добро пожаловать!';

  @override
  String get onboardingWelcomeDesc => 'Самый простой способ следить за здоровьем';

  @override
  String get onboardingTitle1 => 'Отслеживайте цикл';

  @override
  String get onboardingDesc1 => 'Легко отмечайте месячные и получайте прогноз следующих.';

  @override
  String get onboardingTitle2 => 'Следите за здоровьем';

  @override
  String get onboardingDesc2 => 'Отмечайте симптомы, настроение, температуру и не только.';

  @override
  String get onboardingTitle3 => 'Смотрите аналитику';

  @override
  String get onboardingDesc3 => 'Понимайте свой цикл с подробными графиками и статистикой.';

  @override
  String get onboardingTitle4 => 'Получайте уведомления';

  @override
  String get onboardingDesc4 => 'Напоминания о месячных и днях овуляции.';

  @override
  String get getStarted => 'Начать';

  @override
  String get next => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get back => 'Назад';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get done => 'Готово';

  @override
  String get maybeLater => 'Настроить позже';

  @override
  String get enableBiometric => 'Отпечаток / распознавание лица';

  @override
  String get enablePin => 'Заблокировать PIN-кодом';

  @override
  String get securitySetup => 'Настройка безопасности';

  @override
  String get securitySetupDesc => 'Хотите заблокировать приложение?';

  @override
  String get enterName => 'Введите имя';

  @override
  String get name => 'Имя';

  @override
  String get birthDate => 'Дата рождения';

  @override
  String get lastPeriodDate => 'Дата последних месячных';

  @override
  String get averageCycleLength => 'Средняя длина цикла';

  @override
  String get averagePeriodLength => 'Средняя длительность месячных';

  @override
  String get days => 'дней';

  @override
  String get day => 'день';

  @override
  String get today => 'Сегодня';

  @override
  String get cycleDay => 'День цикла';

  @override
  String get periodIn => 'Месячные через';

  @override
  String daysLeft(int count) {
    return 'Осталось $count дн.';
  }

  @override
  String get periodToday => 'Месячные могут начаться сегодня';

  @override
  String get periodOngoing => 'У вас месячные';

  @override
  String get ovulationDay => 'День овуляции';

  @override
  String get fertileWindow => 'Фертильное окно';

  @override
  String get lutealPhase => 'Лютеиновая фаза';

  @override
  String get follicularPhase => 'Фолликулярная фаза';

  @override
  String get periodPhase => 'Менструальная фаза';

  @override
  String get logPeriod => 'Отметить месячные';

  @override
  String get periodStarted => 'Месячные начались';

  @override
  String get periodEnded => 'Месячные закончились';

  @override
  String get flowIntensity => 'Интенсивность выделений';

  @override
  String get light => 'Слабые';

  @override
  String get medium => 'Средние';

  @override
  String get heavy => 'Обильные';

  @override
  String get veryHeavy => 'Очень обильные';

  @override
  String get spotting => 'Мажущие';

  @override
  String get symptoms => 'Симптомы';

  @override
  String get mood => 'Настроение';

  @override
  String get temperature => 'Температура';

  @override
  String get weight => 'Вес';

  @override
  String get waterIntake => 'Вода';

  @override
  String get sleep => 'Сон';

  @override
  String get sexualActivity => 'Половая активность';

  @override
  String get medication => 'Лекарства';

  @override
  String get notes => 'Заметки';

  @override
  String get cramps => 'Спазмы';

  @override
  String get headache => 'Головная боль';

  @override
  String get bloating => 'Вздутие';

  @override
  String get breastTenderness => 'Чувствительность груди';

  @override
  String get backPain => 'Боль в спине';

  @override
  String get fatigue => 'Усталость';

  @override
  String get nausea => 'Тошнота';

  @override
  String get dizziness => 'Головокружение';

  @override
  String get stress => 'Стресс';

  @override
  String get anxiety => 'Тревожность';

  @override
  String get irritability => 'Раздражительность';

  @override
  String get crying => 'Плаксивость';

  @override
  String get sensitivity => 'Чувствительность';

  @override
  String get acne => 'Акне';

  @override
  String get oilySkin => 'Жирная кожа';

  @override
  String get drySkin => 'Сухая кожа';

  @override
  String get constipation => 'Запор';

  @override
  String get diarrhea => 'Диарея';

  @override
  String get gas => 'Газы';

  @override
  String get increasedAppetite => 'Повышенный аппетит';

  @override
  String get decreasedAppetite => 'Пониженный аппетит';

  @override
  String get insomnia => 'Бессонница';

  @override
  String get hotFlash => 'Приливы';

  @override
  String get swelling => 'Отёки';

  @override
  String get hairLoss => 'Выпадение волос';

  @override
  String get happy => 'Счастливая';

  @override
  String get sad => 'Грустная';

  @override
  String get angry => 'Злая';

  @override
  String get anxious => 'Тревожная';

  @override
  String get calm => 'Спокойная';

  @override
  String get energetic => 'Энергичная';

  @override
  String get tired => 'Уставшая';

  @override
  String get romantic => 'Романтичная';

  @override
  String get confused => 'Растерянная';

  @override
  String get confident => 'Уверенная';

  @override
  String get avgCycleLength => 'Средний цикл';

  @override
  String get avgPeriodLength => 'Средние месячные';

  @override
  String get cycleHistory => 'История циклов';

  @override
  String get symptomFrequency => 'Частота симптомов';

  @override
  String get moodDistribution => 'Распределение настроения';

  @override
  String get temperatureTrend => 'Динамика температуры';

  @override
  String get weightTrend => 'Динамика веса';

  @override
  String get last3Months => '3 месяца';

  @override
  String get last6Months => '6 месяцев';

  @override
  String get last12Months => '12 месяцев';

  @override
  String get exportData => 'Экспорт данных';

  @override
  String get exportPdf => 'Отчёт PDF';

  @override
  String get exportCsv => 'Файл CSV';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get notifications => 'Уведомления';

  @override
  String get periodReminder => 'Напоминание о месячных';

  @override
  String get ovulationReminder => 'Напоминание об овуляции';

  @override
  String get medicationReminder => 'Напоминание о лекарствах';

  @override
  String get waterReminder => 'Напоминание о воде';

  @override
  String get security => 'Безопасность';

  @override
  String get pinLock => 'Блокировка PIN-кодом';

  @override
  String get biometricLock => 'Биометрическая блокировка';

  @override
  String get dataBackup => 'Резервная копия';

  @override
  String get deleteAllData => 'Удалить все данные';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get glasses => 'стаканов';

  @override
  String get dailyGoal => 'Дневная цель';

  @override
  String get sleepQuality => 'Качество сна';

  @override
  String get bedTime => 'Отход ко сну';

  @override
  String get wakeTime => 'Пробуждение';

  @override
  String get totalSleep => 'Всего сна';

  @override
  String get hours => 'часов';

  @override
  String get protection => 'Контрацепция';

  @override
  String get condom => 'Презерватив';

  @override
  String get pill => 'Таблетки';

  @override
  String get iud => 'Спираль';

  @override
  String get none => 'Нет';

  @override
  String get other => 'Другое';

  @override
  String get medicationName => 'Название лекарства';

  @override
  String get dose => 'Доза';

  @override
  String get reminderTime => 'Время напоминания';

  @override
  String get taken => 'Принято';

  @override
  String get notTaken => 'Не принято';

  @override
  String get addNote => 'Добавить заметку';

  @override
  String get selectDate => 'Выбрать дату';

  @override
  String get noDataYet => 'Данных пока нет';

  @override
  String get predictions => 'Прогнозы';

  @override
  String get nextPeriod => 'Следующие месячные';

  @override
  String get nextOvulation => 'Следующая овуляция';

  @override
  String get cycleRegularity => 'Регулярность цикла';

  @override
  String get regular => 'Регулярный';

  @override
  String get irregular => 'Нерегулярный';

  @override
  String get setupComplete => 'Настройка завершена!';

  @override
  String get letsStart => 'Начнём';

  @override
  String get bmi => 'ИМТ';

  @override
  String get goalReached => 'Цель достигнута!';

  @override
  String get helloGeneric => 'Привет!';

  @override
  String get dayHasRecord => 'есть запись';

  @override
  String get increase => 'Увеличить';

  @override
  String get decrease => 'Уменьшить';

  @override
  String get bbtHint => 'Для точного результата измеряйте сразу после пробуждения, не вставая с кровати, каждый день в одно время. Подтверждение овуляции опирается на эти измерения.';

  @override
  String get deleteMeasurement => 'Удалить измерение';

  @override
  String get measurementDeleted => 'Измерение удалено';

  @override
  String get deleteRecord => 'Удалить запись';

  @override
  String get recordDeleted => 'Запись удалена';

  @override
  String get invalidWeight => 'Введите корректный вес (20-300 кг)';

  @override
  String get invalidTemperature =>
      'Введите корректную температуру (35-40 °C)';

  @override
  String get discardChangesTitle => 'Несохранённые изменения';

  @override
  String get discardChangesBody => 'Заметка не сохранена. Если выйти сейчас, она будет потеряна.';

  @override
  String get discard => 'Не сохранять';

  @override
  String severityLevel(int level) {
    return 'интенсивность $level/5';
  }

  @override
  String get pregnancySetStartPrompt => 'Нажмите, чтобы указать начало беременности';

  @override
  String helloName(String name) {
    return 'Привет, $name!';
  }

  @override
  String get ovulationPhase => 'Фаза овуляции';

  @override
  String get menstrualPhase => 'Менструальная фаза';

  @override
  String get todaySummary => 'Сводка за сегодня';

  @override
  String get howAreYouFeeling => 'Как вы себя чувствуете сегодня?';

  @override
  String get logMoodAndSymptoms => 'Отметьте настроение и симптомы';

  @override
  String get addRecord => 'Добавить запись';

  @override
  String nSymptoms(int count) {
    return '$count симптомов';
  }

  @override
  String get periodDayLabel => 'День месячных';

  @override
  String get predicted => 'Прогноз';

  @override
  String get fertile => 'Фертильный';

  @override
  String get ovulation => 'Овуляция';

  @override
  String moodLabel(String mood) {
    return 'Настроение: $mood';
  }

  @override
  String nGlassesWater(int count) {
    return '$count стаканов воды';
  }

  @override
  String get noRecordForDay => 'Записей за этот день нет.';

  @override
  String get dailyLog => 'Дневник';

  @override
  String get dailyMeasurements => 'Ежедневные измерения';

  @override
  String get flow => 'Выделения';

  @override
  String get recorded => 'Записано';

  @override
  String nMedications(int count) {
    return '$count лекарств';
  }

  @override
  String nGlasses(int count) {
    return '$count стаканов';
  }

  @override
  String get flowTracking => 'Отслеживание выделений';

  @override
  String get color => 'Цвет';

  @override
  String get lightRed => 'Светло-красный';

  @override
  String get red => 'Красный';

  @override
  String get darkRed => 'Тёмный';

  @override
  String get brown => 'Коричневый';

  @override
  String get clots => 'Сгустки';

  @override
  String get clotsQuestion => 'Есть сгустки?';

  @override
  String get padChange => 'Смены прокладок';

  @override
  String get flowSaved => 'Выделения сохранены';

  @override
  String get symptomTracking => 'Отслеживание симптомов';

  @override
  String get physical => 'Физические';

  @override
  String get emotional => 'Эмоциональные';

  @override
  String get skinCategory => 'Кожа';

  @override
  String get digestive => 'Пищеварение';

  @override
  String get otherCategory => 'Другое';

  @override
  String get glowingSkin => 'Сияющая кожа';

  @override
  String saveNSymptoms(int count) {
    return 'Сохранить ($count симптомов)';
  }

  @override
  String nSymptomsSaved(int count) {
    return 'Сохранено симптомов: $count';
  }

  @override
  String get addNoteOptional => 'Добавить заметку (необязательно)';

  @override
  String get writeAboutToday => 'Напишите что-нибудь о сегодняшнем дне...';

  @override
  String get moodSaved => 'Настроение сохранено';

  @override
  String get sensitiveM => 'Чувствительная';

  @override
  String get irritableM => 'Раздражённая';

  @override
  String get neutralM => 'Нейтральное';

  @override
  String get lowTemp => 'Низкая';

  @override
  String get normalTemp => 'Нормальная';

  @override
  String get highTemp => 'Высокая';

  @override
  String get fever => 'Жар';

  @override
  String get measurementTime => 'Время измерения';

  @override
  String get temperatureSaved => 'Температура сохранена';

  @override
  String get quickAdjust => 'Быстрая настройка';

  @override
  String get manualEntry => 'Ввод вручную';

  @override
  String get weightSaved => 'Вес сохранён';

  @override
  String get waterTracking => 'Отслеживание воды';

  @override
  String get waterSaved => 'Вода сохранена';

  @override
  String get sleepTracking => 'Отслеживание сна';

  @override
  String get bedTimeLabel => 'Отход ко сну';

  @override
  String get wakeTimeLabel => 'Пробуждение';

  @override
  String get veryBad => 'Очень плохо';

  @override
  String get bad => 'Плохо';

  @override
  String get moderate => 'Средне';

  @override
  String get good => 'Хорошо';

  @override
  String get great => 'Отлично';

  @override
  String get sleepSaved => 'Сон сохранён';

  @override
  String get protectionMethod => 'Метод контрацепции';

  @override
  String get orgasm => 'Оргазм';

  @override
  String get noteOptional => 'Заметка (необязательно)';

  @override
  String get addNoteHint => 'Добавить заметку...';

  @override
  String get savedGeneric => 'Сохранено';

  @override
  String get medicationTracking => 'Отслеживание лекарств';

  @override
  String get addMedication => 'Добавить лекарство';

  @override
  String get noMedicationsYet => 'Лекарств пока нет';

  @override
  String get medicationPlanHint =>
      'Этот план действует каждый день. Флажок отмечает приём только за выбранный день.';

  @override
  String get medicationAlreadyInPlan => 'Это лекарство уже есть в плане';

  @override
  String get tapToAdd => 'Нажмите +, чтобы добавить';

  @override
  String get add => 'Добавить';

  @override
  String get dailyNote => 'Заметка дня';

  @override
  String get myNotes => 'Мои заметки';

  @override
  String get notesHint => 'Как вы себя чувствуете? Пишите заметки здесь...';

  @override
  String get noteSaved => 'Заметка сохранена';

  @override
  String get cycleOverview => 'Обзор цикла';

  @override
  String get avgCycle => 'Средний цикл';

  @override
  String get avgPeriod => 'Средние месячные';

  @override
  String get regularity => 'Регулярность';

  @override
  String get insufficientData => 'Недостаточно данных';

  @override
  String get noSymptomData => 'Данных о симптомах пока нет';

  @override
  String get noMoodData => 'Данных о настроении пока нет';

  @override
  String get noCycleData => 'Данных о циклах пока нет';

  @override
  String get ongoing => 'идут';

  @override
  String nDays(int count) {
    return '$count дн.';
  }

  @override
  String get profileSection => 'Профиль';

  @override
  String get preferences => 'Предпочтения';

  @override
  String get age => 'Возраст';

  @override
  String nYearsOld(int count) {
    return '$count лет';
  }

  @override
  String get cycleDuration => 'Длина цикла';

  @override
  String get periodDuration => 'Длительность месячных';

  @override
  String get dataSection => 'Данные';

  @override
  String get exportPdfReport => 'Экспорт отчёта PDF';

  @override
  String get exportCsvFile => 'Экспорт CSV';

  @override
  String get pdfExportSoon => 'Экспорт PDF скоро появится!';

  @override
  String get csvExportSoon => 'Экспорт CSV скоро появится!';

  @override
  String get letsKnowYou => 'Давайте познакомимся';

  @override
  String get whatShouldWeCallYou => 'Как к вам обращаться?';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get yourBirthDate => 'Дата рождения';

  @override
  String get birthDateHelp => 'Помогает давать советы с учётом возраста.';

  @override
  String get selectDateHint => 'Выбрать дату';

  @override
  String get selectDateToContinue => 'Выберите дату, чтобы продолжить';

  @override
  String stepOfSteps(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get lastPeriodTitle => 'Последние месячные';

  @override
  String get lastPeriodHelp => 'Выберите дату начала последних месячных.';

  @override
  String get cycleLengthTitle => 'Длина цикла';

  @override
  String get cycleLengthHelp => 'Сколько дней длится ваш цикл в среднем?\n(От первого дня одних месячных до первого дня следующих)';

  @override
  String get periodLengthTitle => 'Длительность месячных';

  @override
  String get periodLengthHelp => 'Сколько дней обычно длятся месячные?';

  @override
  String get averageLabel => 'в среднем';

  @override
  String get completeBtn => 'Завершить';

  @override
  String get continueBtn => 'Продолжить';

  @override
  String errorOccurred(String error) {
    return 'Произошла ошибка: $error';
  }

  @override
  String get welcomeInfoTitle => 'Добро пожаловать!';

  @override
  String get welcomeInfoDesc => 'Самый простой и приятный способ следить за здоровьем. Мы рядом на каждом шаге вашего цикла.';

  @override
  String get trackCycleTitle => 'Отслеживайте цикл';

  @override
  String get trackCycleDesc => 'Легко отмечайте даты месячных, симптомы и настроение. Все данные в безопасности.';

  @override
  String get getPredictionsTitle => 'Получайте прогнозы';

  @override
  String get getPredictionsDesc => 'Узнавайте следующий цикл и фертильные дни с умными прогнозами.';

  @override
  String get startBtn => 'Начать';

  @override
  String daysLater(int count) {
    return 'через $count дн.';
  }

  @override
  String get todayExclamation => 'Сегодня!';

  @override
  String get spiral => 'Спираль';

  @override
  String get enterPin => 'Введите PIN-код';

  @override
  String get createPin => 'Создайте PIN-код';

  @override
  String get confirmPin => 'Подтвердите PIN-код';

  @override
  String get pinMismatch => 'PIN-коды не совпадают, попробуйте снова';

  @override
  String get verifyPinTitle => 'Введите текущий PIN-код';

  @override
  String get wrongPin => 'Неверный PIN-код';

  @override
  String tooManyAttempts(int seconds) {
    return 'Слишком много попыток. Подождите $seconds сек.';
  }

  @override
  String get coachMenstrual0 => 'В дни кровотечения теряется железо — помогут красное мясо, чечевица и тёмная листовая зелень.';

  @override
  String get coachMenstrual1 => 'От спазмов тепло и мягкая растяжка часто работают не хуже обезболивающих.';

  @override
  String get coachMenstrual2 => 'Низкая энергия сегодня — это нормально. Прогулка лучше интенсивной тренировки.';

  @override
  String get coachFollicular0 => 'Эстроген растёт: энергия и концентрация в этой фазе обычно на пике. Планируйте сложные задачи сейчас.';

  @override
  String get coachFollicular1 => 'Кожа в этой фазе обычно в лучшем состоянии — хорошее время пробовать новые средства.';

  @override
  String get coachFollicular2 => 'Сейчас организм лучше всего готов к интенсивным тренировкам.';

  @override
  String get coachOvulation0 => 'Вы в фертильном окне — действуйте по своему плану, будь то контрацепция или зачатие.';

  @override
  String get coachOvulation1 => 'Некоторые женщины чувствуют лёгкую боль с одной стороны при овуляции — это нормально.';

  @override
  String get coachOvulation2 => 'Социальная энергия в эти дни обычно высока — хорошее время для важных разговоров.';

  @override
  String get coachLuteal0 => 'В этой фазе могут начаться симптомы ПМС — магний и регулярный сон облегчают их.';

  @override
  String get coachLuteal1 => 'Тяга к сладкому может усилиться: белковые перекусы помогут держать сахар в норме.';

  @override
  String get coachLuteal2 => 'Эмоциональная чувствительность может вырасти — будьте к себе мягче, это гормонально и временно.';

  @override
  String get ovulationConfirmed => 'Овуляция ✓';

  @override
  String get ovulationConfirmedInfo => 'Эта дата не оценка: она подтверждена ростом базальной температуры (правило 3 над 6).';

  @override
  String get premiumSection => 'Премиум';

  @override
  String get removeAds => 'Убрать рекламу';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get premiumActive => 'Премиум активен — рекламы нет';

  @override
  String get storeUnavailable => 'Магазин сейчас недоступен';

  @override
  String get healthSync => 'Синхронизация с Health Connect';

  @override
  String get healthSyncSuccess => 'Данные о месячных синхронизированы';

  @override
  String get healthSyncDenied => 'Доступ к данным о здоровье отклонён';

  @override
  String get healthSyncUnavailable => 'На этом устройстве нет сервиса здоровья';

  @override
  String get healthSyncFailed => 'Ошибка синхронизации';

  @override
  String get trackingModeTitle => 'Режим отслеживания';

  @override
  String get modePeriod => 'Месячные';

  @override
  String get modePregnancy => 'Беременность';

  @override
  String get modePill => 'Таблетки';

  @override
  String get modeTtc => 'Зачатие';

  @override
  String get lhTestTitle => 'Тест на овуляцию (ЛГ)';

  @override
  String get lhPositive => 'Положительный';

  @override
  String get lhNegative => 'Отрицательный';

  @override
  String get fertilityToday => 'Фертильность сегодня';

  @override
  String get fertilityHigh => 'Высокая';

  @override
  String get fertilityMedium => 'Средняя';

  @override
  String get fertilityLow => 'Низкая';

  @override
  String pregnancyWeekLabel(int week) {
    return 'Неделя $week';
  }

  @override
  String get trimester1 => '1-й триместр';

  @override
  String get trimester2 => '2-й триместр';

  @override
  String get trimester3 => '3-й триместр';

  @override
  String get pregnancyDevelopmentTitle => 'Развитие на этой неделе';

  @override
  String get pregnancyDevelopment1 =>
      'Продолжается период быстрого развития: формируются основные органы и системы организма ребёнка.';

  @override
  String get pregnancyDevelopment2 =>
      'Движения ребёнка становятся более скоординированными; время, когда вы их почувствуете, у всех разное.';

  @override
  String get pregnancyDevelopment3 =>
      'Ребёнок продолжает расти, а подготовка к родам выходит на первый план.';

  @override
  String get pregnancyCheckupReminder =>
      'Следуйте графику осмотров, рекомендованному вашим медицинским специалистом.';

  @override
  String get pregnancyStartLabel => 'Последние месячные (начало беременности)';

  @override
  String get pregnancyModeInfo => 'В режиме беременности прогнозы и напоминания о месячных отключены';

  @override
  String get pillPackStartLabel => 'Начало упаковки';

  @override
  String pillDayLabel(int day) {
    return 'Таблетка, день $day/21';
  }

  @override
  String pillBreakLabel(int day) {
    return 'Неделя перерыва • день $day';
  }

  @override
  String get smartPrediction => 'Умный прогноз';

  @override
  String get smartPredictionDesc => 'Прогнозы используют среднее, вычисленное по вашим прошлым циклам';

  @override
  String learnedCycleLength(int days) {
    return 'Вычислено: $days дн.';
  }

  @override
  String get phaseInsights => 'Закономерности по фазам';

  @override
  String get noInsightsYet => 'Пока недостаточно данных. По мере записи симптомов здесь появятся закономерности по фазам.';

  @override
  String insightLine(String symptom, String phase, int percent) {
    return '$symptom чаще всего встречается в фазе «$phase» ($percent%)';
  }

  @override
  String get notContraceptionWarning => 'Прогнозы носят информационный характер. Это приложение НЕ является средством контрацепции и не должно использоваться для предотвращения беременности.';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get aboutSection => 'О приложении';

  @override
  String get consentTitle => 'Ваши данные и конфиденциальность';

  @override
  String get consentBody => 'Все данные хранятся в зашифрованном виде только на этом устройстве; ничего не отправляется на серверы. Политику конфиденциальности можно прочитать в Настройки > О приложении. Продолжая, вы соглашаетесь с такой обработкой данных на устройстве.';

  @override
  String get consentAccept => 'Принимаю';

  @override
  String get quickLog => 'Быстрая запись';

  @override
  String get shortcutQuickLog => 'Быстрая запись';

  @override
  String get shortcutToday => 'Сегодня';

  @override
  String get allTrackers => 'Все трекеры';

  @override
  String get disguiseTitle => 'Режим маскировки';

  @override
  String get disguiseDesc => 'Приложение принимает облик «Заметок»: название, значок, виджет, уведомления и экран запуска становятся нейтральными. Возврат: долгое нажатие на заголовок Заметок.';

  @override
  String get decoyTitle => 'Заметки';

  @override
  String get decoyEmpty => 'Заметок пока нет';

  @override
  String get decoyHint => 'Напишите что-нибудь…';

  @override
  String get backupData => 'Создать копию с паролем';

  @override
  String get backupPassword => 'Пароль резервной копии';

  @override
  String get backupPasswordConfirm => 'Введите пароль ещё раз';

  @override
  String get backupPasswordLength =>
      'Пароль должен содержать от 10 до 128 символов';

  @override
  String get backupPasswordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get backupNoRecovery =>
      'Пароль не хранится на устройстве и не может быть восстановлен. Если вы его забудете, открыть копию будет невозможно.';

  @override
  String get unlockBackupTitle => 'Введите пароль резервной копии';

  @override
  String get unlockBackupBody =>
      'Эту копию можно открыть только паролем, заданным при её создании.';

  @override
  String get backupPasswordOrFileInvalid =>
      'Неверный пароль или повреждённый файл резервной копии.';

  @override
  String get legacyBackupWarning =>
      'Эта старая копия не зашифрована. После восстановления новые копии будут защищены паролем.';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get restoreData => 'Восстановить из копии';

  @override
  String get restoreConfirmTitle => 'Восстановить копию?';

  @override
  String restoreConfirmBody(int count) {
    return 'Все текущие данные будут удалены, из копии будет восстановлено записей: $count. Это нельзя отменить.';
  }

  @override
  String get restore => 'Восстановить';

  @override
  String get backupRestored => 'Копия восстановлена';

  @override
  String get invalidBackupFile => 'Недопустимый файл копии';

  @override
  String get dateLabel => 'Дата';

  @override
  String get modeStepTitle => 'Для чего будете использовать?';

  @override
  String get modeStepSubtitle => 'Это можно изменить позже в настройках';

  @override
  String get modePeriodDesc => 'Отслеживание цикла и прогнозы';

  @override
  String get modePregnancyDesc => 'Беременность неделя за неделей';

  @override
  String get modePillDesc => 'Схема таблеток 21+7';

  @override
  String get modeTtcDesc => 'Отслеживание с упором на фертильность';

  @override
  String get paywallTitle => 'Перейти на Премиум';

  @override
  String paywallTrialSubtitle(int days) {
    return 'Пробный период активен: осталось $days дн. Премиум сохранит полный доступ.';
  }

  @override
  String get paywallFreeSubtitle => 'Пробный период закончился. В бесплатной версии остаются отслеживание месячных и календарь; дневник и аналитика — в Премиуме.';

  @override
  String get paywallFeatureTrackers => 'Все ежедневные трекеры: симптомы, настроение, вода, сон, вес, температура, лекарства, заметки';

  @override
  String get paywallFeatureStats => 'Статистика, тренды и кольцо «Мой год»';

  @override
  String get paywallFeatureInsights => 'Личные закономерности и подсказки по фазам';

  @override
  String get paywallFeatureExport => 'Экспорт PDF / CSV';

  @override
  String get paywallFeatureHealth => 'Синхронизация с Health Connect';

  @override
  String get paywallFeatureDisguise => 'Режим маскировки с приложением «Заметки»';

  @override
  String get paywallFeatureNoAds => 'Без рекламы';

  @override
  String get planMonthly => 'Ежемесячно';

  @override
  String get planYearly => 'Ежегодно';

  @override
  String get perMonth => '/мес.';

  @override
  String get perYear => '/год';

  @override
  String get bestValue => 'Выгоднее всего';

  @override
  String get continueFreeBtn => 'Пока продолжить бесплатно';

  @override
  String trialBadge(int days) {
    return 'Проба: осталось $days дн.';
  }

  @override
  String get freeBadge => 'Бесплатная версия';

  @override
  String get freeExplain => 'В бесплатной версии остаются отслеживание месячных, календарь и прогнозы. Дневник, статистика, экспорт, Health Connect, маскировка и режимы — в Премиуме.';

  @override
  String get seePlans => 'Смотреть планы';

  @override
  String get premiumLockedTitle => 'Статистика — в Премиуме';

  @override
  String get premiumLockedBody => 'Графики, тренды, закономерности по фазам и кольцо «Мой год» открываются с Премиумом. Всё записанное в пробный период сохранено.';

  @override
  String get yearRingTitle => 'Мой год';

  @override
  String get yearRingCycles => 'ЦИКЛОВ';

  @override
  String yearRingSummary(int count) {
    return 'За 12 месяцев: $count циклов';
  }

  @override
  String get cycleComparison => 'Ваш последний цикл';

  @override
  String lastCycleLength(int days) {
    return 'Последний цикл: $days дн.';
  }

  @override
  String lastPeriodLength(int days) {
    return 'Последние месячные: $days дн.';
  }

  @override
  String vsAverageMore(int days) {
    return 'на $days дн. длиннее вашего среднего';
  }

  @override
  String vsAverageLess(int days) {
    return 'на $days дн. короче вашего среднего';
  }

  @override
  String get vsAverageSame => 'как ваш средний';

  @override
  String coachPersonalInsight(String symptom, int percent) {
    return 'По вашим записям, чаще всего в этой фазе: $symptom ($percent%)';
  }

  @override
  String get notificationInsightTitle => 'Подсказка по фазе';

  @override
  String notificationInsightBody(String symptom) {
    return 'Начинается лютеиновая фаза. По вашим записям, самый частый симптом в этой фазе: $symptom.';
  }

  @override
  String get notificationPeriodTitle => 'Напоминание о месячных';

  @override
  String get notificationPeriodTimingToday => 'Месячные могут начаться сегодня.';

  @override
  String get notificationPeriodTimingTomorrow => 'Месячные могут начаться завтра.';

  @override
  String notificationPeriodTimingInDays(int days) {
    return 'Месячные могут начаться через $days дн.';
  }

  @override
  String get notificationPeriodTip1 => 'Не забудьте взять с собой прокладку или тампон.';

  @override
  String get notificationPeriodTip2 => 'Небольшая подготовка всё упрощает.';

  @override
  String get notificationPeriodTip3 => 'Отметка начала улучшает прогнозы.';

  @override
  String get notificationPeriodChannel => 'Напоминание о месячных';

  @override
  String get notificationPeriodChannelDesc => 'Напоминания о менструальном цикле';

  @override
  String get notificationOvulationTitle => 'Напоминание об овуляции';

  @override
  String get notificationOvulationBody => 'Сегодня день овуляции. Вы в фертильном окне!';

  @override
  String get notificationOvulationChannel => 'Напоминание об овуляции';

  @override
  String get notificationOvulationChannelDesc => 'Напоминания об овуляции';

  @override
  String get notificationMedicationTitle => 'Напоминание о лекарстве';

  @override
  String get notificationMedicationBody => 'Не забудьте принять лекарство!';

  @override
  String get notificationMedicationChannel => 'Напоминание о лекарстве';

  @override
  String get notificationMedicationChannelDesc => 'Напоминания о лекарствах';

  @override
  String get notificationDiscreetTitle => 'Напоминание';

  @override
  String get notificationDiscreetBody => 'У вас есть напоминание на сегодня';

  @override
  String get notificationFertileTitle => 'Начинается фертильное окно';

  @override
  String get notificationFertileBody => 'С сегодняшнего дня — самые благоприятные для зачатия дни.';

  @override
  String get notificationChainEndTitle => 'Напоминания приостанавливаются';

  @override
  String get notificationChainEndBody => 'Запланированные напоминания закончились. Откройте приложение, чтобы создать новые.';

  @override
  String get noPurchasesToRestore => 'Покупки для восстановления не найдены';

  @override
  String get restoringPurchases => 'Восстановление покупок…';

  @override
  String get backdateHint => 'Долгое нажатие — выбрать другой день';

  @override
  String get periodStartDateHelp => 'Когда начались месячные?';

  @override
  String get periodEndDateHelp => 'Когда закончились месячные?';

  @override
  String get headlinePeriodToday => 'Месячные могут начаться сегодня';

  @override
  String get headlinePeriodTomorrow => 'Месячные могут начаться завтра';

  @override
  String get headlineNoData => 'Добавьте дату последних месячных';

  @override
  String headlinePeriodInDays(int days) {
    return 'Месячные через $days дн.';
  }

  @override
  String headlinePeriodDay(int day) {
    return '$day-й день месячных';
  }

  @override
  String get headlineDelaySubtitle => 'Небольшие отклонения — это нормально. Отметьте, если начались.';

  @override
  String get notificationDelayTitle => 'Предполагаемая дата прошла';

  @override
  String get notificationDelayBody => 'Если месячные начались, не забудьте отметить. Отклонения — это нормально.';

  @override
  String get notificationDelayBodyAlt1 => 'Записи пока нет. Если началось, отметить можно одним касанием.';

  @override
  String get notificationDelayBodyAlt2 => 'Сдвиг на несколько дней — обычное дело. Ваши записи актуальны?';

  @override
  String get notificationDelayChannel => 'Напоминание о задержке';

  @override
  String get notificationDelayChannelDesc => 'Напоминание, когда предполагаемая дата прошла';

  @override
  String headlineDelay(int days) {
    return 'Задержка $days дн.';
  }

  @override
  String delayDays(int days) {
    return 'задержка $days дн.';
  }

  @override
  String get yourDataStays => 'Ваши записи останутся на устройстве после окончания пробного периода.';

  @override
  String get periodStartedOnThisDay => 'Месячные начались в этот день';

  @override
  String nCyclesRecorded(int count) {
    return 'записано циклов: $count';
  }

  @override
  String nLogsRecorded(int count) {
    return 'дневных записей: $count';
  }

  @override
  String get notifPermissionTitle => 'Включить напоминания?';

  @override
  String get notifPermissionBody => 'Сообщим, когда месячные близко, в день овуляции и когда предполагаемая дата прошла. Уведомления не покидают устройство. Включить можно и позже в настройках.';

  @override
  String get enableNotifications => 'Включить';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get optionalField => 'Необязательно';

  @override
  String get privacyAssurance => 'Ваши данные хранятся в зашифрованном виде только на этом устройстве';

  @override
  String get privacySummary =>
      'Основные данные зашифрованы на этом устройстве; они покидают его только при экспорте или включении Health Connect.';

  @override
  String get dontRememberExactly => 'Точно не помню';

  @override
  String get approxTitle => 'Примерно когда это было?';

  @override
  String get approxSubtitle => 'Достаточно примерной даты. Прогнозы уточняются по мере записей.';

  @override
  String get approxThisWeek => 'На этой неделе';

  @override
  String get approxLastWeek => 'На прошлой неделе';

  @override
  String get approxTwoWeeks => 'Около 2 недель назад';

  @override
  String get approxThreeWeeks => 'Около 3 недель назад';

  @override
  String get approxMonthOrMore => 'Месяц назад или раньше';

  @override
  String get cycleReminderTime => 'Время напоминаний о цикле';

  @override
  String get medicationReminderTime => 'Время напоминаний о лекарствах';

  @override
  String get periodReminderLead => 'Напоминание о месячных';

  @override
  String get notificationQuietChannelSuffix => 'тихо';

  @override
  String get quietNotifications => 'Тихие уведомления';

  @override
  String get quietNotificationsDesc => 'Без звука и всплывающего окна — только в шторке уведомлений';

  @override
  String get leadSameDay => 'В тот же день';

  @override
  String leadNDaysBefore(int days) {
    return 'за $days дн.';
  }

  @override
  String get regularityInfoIrregular => 'Между самым коротким и самым длинным циклом 9 дней или больше. Колебания длины цикла очень распространены: влияют стресс, сон, болезни и перемены в жизни. Это не диагноз.';

  @override
  String get regularityInfoRegular => 'Разница между самым коротким и самым длинным циклом меньше 9 дней. При такой стабильности прогнозы точнее.';

  @override
  String get regularityInfoSeeDoctor => 'Если цикл постоянно короче 21 дня или длиннее 35, если месячных нет более трёх месяцев или кровотечение необычно обильное, стоит обратиться к врачу.';

  @override
  String typicalRangeNote(int min, int max, int pmax) {
    return 'Обычный диапазон: цикл $min–$max дней, месячные до $pmax дней. Это не диагностический критерий.';
  }

  @override
  String lowConfidenceNote(int count) {
    return 'Эти средние рассчитаны всего по $count циклам и уточнятся с новыми записями.';
  }

  @override
  String regularityInfoInsufficient(int count) {
    return 'Чтобы говорить о регулярности, нужно минимум $count интервалов цикла. Меньше — вывод будет вводить в заблуждение.';
  }

  @override
  String get backupNever => 'Вы ещё ни разу не делали резервную копию.';

  @override
  String get backupStaleHint => 'Если вы потеряете телефон, записи восстановить не удастся.';

  @override
  String backupLastAt(String date) {
    return 'Последняя копия: $date';
  }

  @override
  String get durationsStepTitle => 'Данные вашего цикла';

  @override
  String get durationsStepHelp => 'Не уверены? Оставьте как есть — это можно изменить в настройках.';

  @override
  String get lockTimeoutTitle => 'Задержка блокировки';

  @override
  String get lockTimeoutDesc => 'Не спрашивать PIN, если вы вернулись быстро';

  @override
  String get lockImmediately => 'Сразу';

  @override
  String get previousDay => 'Предыдущий день';

  @override
  String get nextDay => 'Следующий день';

  @override
  String get showLegend => 'Обозначения цветов';

  @override
  String get hideLegend => 'Скрыть обозначения';

  @override
  String get backToToday => 'К сегодня';

  @override
  String get monthNoRecords => 'В этом месяце записей нет';

  @override
  String get doctorSummary => 'Выгрузить сводку для врача';

  @override
  String get healthImport => 'Импорт из Health Connect';

  @override
  String get healthImportAction => 'Импортировать';

  @override
  String get allTime => 'Всё время';

  @override
  String get actionPeriodStarted => 'Месячные начались';

  @override
  String get actionMedicationTaken => 'Принято';

  @override
  String get pregnancyTestReady => 'Тест на беременность уже может быть информативным';

  @override
  String notLoggedToday(String what) {
    return 'Сегодня не отмечено: $what';
  }

  @override
  String pregnancyTestFrom(String date) {
    return 'Тест имеет смысл с $date';
  }

  @override
  String pillBreakIn(int days) {
    return 'Перерыв через $days дн.';
  }

  @override
  String pillNewPackIn(int days) {
    return 'Новая упаковка через $days дн.';
  }

  @override
  String get healthImportNothingNew => 'Новых записей для импорта не найдено';

  @override
  String healthImportConfirm(int count) {
    return 'В Health Connect найдено периодов, которых нет в приложении: $count. Добавить их к вашим записям? Существующие записи не изменятся.';
  }

  @override
  String healthImportDone(int count) {
    return 'Импортировано периодов: $count';
  }

  @override
  String monthPeriodDays(int count) {
    return 'дней месячных: $count';
  }

  @override
  String monthLoggedDays(int count) {
    return 'дней с записями: $count';
  }

  @override
  String get pinNoRecoveryWarning => 'Если вы забудете PIN, восстановить его нельзя — останется только удалить все данные. Выберите то, что запомните.';

  @override
  String lockAfterMinutes(int minutes) {
    return 'Через $minutes мин';
  }

  @override
  String get reportTitle => 'Отчёт о здоровье цикла';

  @override
  String get reportGenerated => 'Создан';

  @override
  String get profileSummary => 'Сводка профиля';

  @override
  String get periodHistory => 'История месячных';

  @override
  String get last30DaysSummary => 'Сводка за 30 дней';

  @override
  String get durationDaysHeader => 'Длительность (дни)';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get languageSystem => 'Система';

  @override
  String get statsSectionOverview => 'ОБЗОР';

  @override
  String get statsSectionCharts => 'ГРАФИКИ';

  @override
  String get statsSectionHistory => 'ИСТОРИЯ И ТРЕНДЫ';

  @override
  String storySymptomsMore(int recent, int previous) {
    return 'Последние 30 дней были тяжелее предыдущего периода ($recent записей против $previous).';
  }

  @override
  String storySymptomsLess(int recent, int previous) {
    return 'Последние 30 дней были легче предыдущего периода ($recent записей против $previous).';
  }

  @override
  String get storySymptomsSame => 'Интенсивность симптомов за последние два периода почти не изменилась.';

  @override
  String storyTrendUp(String delta, String unit) {
    return 'Рост на $delta $unit за этот период.';
  }

  @override
  String storyTrendDown(String delta, String unit) {
    return 'Снижение на $delta $unit за этот период.';
  }

  @override
  String get storyTrendFlat => 'Заметных изменений за этот период нет — тренд ровный.';

  @override
  String averageSeverity(String value) {
    return 'Сред. $value/5';
  }

  @override
  String get dataCoverage => 'Плотность данных';

  @override
  String dataCoverageValue(int logged, int total, int percent) {
    return 'Записи за $logged из $total дней ($percent %)';
  }

  @override
  String get tapChartPointHint => 'Нажмите на точку, чтобы открыть этот день.';

  @override
  String get shareCalendarMonth => 'Поделиться месяцем календаря';

  @override
  String get longPressDayHint => 'Нажмите и удерживайте день для быстрого просмотра.';

  @override
  String get markPeriodRange => 'Отметить диапазон менструации';

  @override
  String get periodRangeOverlap => 'Этот диапазон пересекается с существующей записью.';

  @override
  String get periodRangeSaved => 'Диапазон менструации сохранён';

  @override
  String trackingStreak(int count) {
    return 'Серия: $count дн.';
  }

  @override
  String weeklyTracking(int count) {
    return 'Записи за $count из 7 дней';
  }

  @override
  String get exportCalendarFile => 'Экспорт календаря (.ics)';

  @override
  String get ovulationMarkerHint => 'Пунктир: предполагаемая или подтверждённая овуляция';

  @override
  String get addPastCycles => 'Добавить прошлые циклы';

  @override
  String get addPastCyclesHint => 'Выберите до 3 диапазонов менструации и сохраните их вместе.';

  @override
  String get addPeriodRange => 'Добавить диапазон менструации';

  @override
  String get cycleOverlayTitle => 'Сравнение циклов';

  @override
  String get symptomLoadComparison => 'Дневная выраженность симптомов по дням цикла';

  @override
  String get currentCycleLabel => 'Этот цикл';

  @override
  String get previousCycleLabel => 'Предыдущий цикл';

  @override
  String get colorBlindPattern => 'Узорные цвета фаз';

  @override
  String get colorBlindPatternDesc => 'Добавляет текстуру полосам фаз — полезно, если цвета трудно различать';

  @override
  String get undo => 'Отменить';

  @override
  String get periodMarkedStarted => 'Начало месячных сохранено';

  @override
  String get periodMarkedEnded => 'Окончание месячных сохранено';

  @override
  String get editPeriodRecord => 'Изменить запись месячных';

  @override
  String get startDateLabel => 'Начало';

  @override
  String get endDateLabel => 'Конец';

  @override
  String get recordUpdated => 'Запись обновлена';

  @override
  String get dataResetTitle => 'Не удалось прочитать данные';

  @override
  String get dataResetBody => 'Данные приложения не удалось расшифровать на этом устройстве. Обычно так бывает после смены телефона или восстановления системной копии: данные зашифрованы ключом, привязанным к устройству, и он не переносится. Приложение начало работу заново.\n\nЧтобы переносить данные между устройствами, регулярно экспортируйте JSON-копию в Настройки > Резервная копия.';

  @override
  String get pinSet => 'PIN-код установлен';

  @override
  String get pinRemoved => 'PIN-код удалён';

  @override
  String get unlockWithBiometric => 'Разблокировать отпечатком или лицом';

  @override
  String get biometricNotAvailable => 'Биометрия недоступна на этом устройстве';

  @override
  String get editProfile => 'Изменить профиль';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String sleepDurationShort(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get deleteAllDataConfirm => 'Точно удалить все данные? Это действие нельзя отменить.';

  @override
  String get dataDeleted => 'Все данные удалены';

  @override
  String get doseHint => 'напр. 500 мг';

  @override
  String get menstrualPhaseInfo => 'Период менструального кровотечения. Обычно длится 3-7 дней. Организм отторгает слизистую матки.';

  @override
  String get follicularPhaseInfo => 'После месячных яичники готовят новую яйцеклетку. Эстроген растёт, энергии становится больше.';

  @override
  String get ovulationPhaseInfo => 'Фаза, когда яйцеклетка выходит из яичника. Вероятность беременности максимальна.';

  @override
  String get lutealPhaseInfo => 'Фаза от овуляции до следующих месячных. Прогестерон растёт, возможны симптомы ПМС.';

  @override
  String get fertileWindowInfo => 'Период с наибольшей вероятностью беременности. Начинается за 5 дней до овуляции и заканчивается через 1 день после.';

  @override
  String get ovulationCardInfo => 'Примерный день выхода яйцеклетки из яичника. Приходится примерно на середину цикла.';

  @override
  String get nextPeriodInfo => 'Примерная дата начала следующих месячных. Рассчитывается по длине вашего цикла.';

  @override
  String get phaseInfoTitle => 'Что это за фаза?';

  @override
  String get learnMore => 'Инфо';

  @override
  String get healthDisclaimer => 'Это приложение не заменяет консультацию врача. По вопросам здоровья обращайтесь к специалисту.';

  @override
  String get homePriority => 'Приоритет главного экрана';

  @override
  String get cycleFirst => 'Сначала цикл';

  @override
  String get todayFirst => 'Сначала сегодня';

  @override
  String get planLifetime => 'Навсегда';
  @override
  String get planLifetimeDetail => 'Один платёж, премиум навсегда';
  @override
  String get cycleNotificationFrequency => 'Уровень уведомлений о цикле';
  @override
  String get cycleNotificationFrequencyDesc => 'Не влияет на напоминания о лекарствах';
  @override
  String get notificationFrequencyEssential => 'Основные';
  @override
  String get notificationFrequencyBalanced => 'Сбалансированные';
  @override
  String get notificationFrequencyDetailed => 'Подробные';
  @override
  String get readOnlyHistoryNotice => 'Прошлые записи доступны для просмотра; новые записи и изменения требуют Premium.';
}
