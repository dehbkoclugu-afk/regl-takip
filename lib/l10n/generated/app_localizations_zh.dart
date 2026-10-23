// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '经期追踪';

  @override
  String get home => '首页';

  @override
  String get calendar => '日历';

  @override
  String get log => '记录';

  @override
  String get statistics => '统计数据';

  @override
  String get settings => '设置';

  @override
  String get profile => '个人资料';

  @override
  String get onboardingWelcome => '欢迎！';

  @override
  String get onboardingWelcomeDesc => '追踪您健康状况的最简单方法';

  @override
  String get onboardingTitle1 => '追踪月经周期';

  @override
  String get onboardingDesc1 => '轻松记录月经并查看下次经期预测。';

  @override
  String get onboardingTitle2 => '监测您的健康状况';

  @override
  String get onboardingDesc2 => '跟踪症状、情绪、体温等。';

  @override
  String get onboardingTitle3 => '查看您的分析';

  @override
  String get onboardingDesc3 => '通过详细的图表和统计数据了解您的周期。';

  @override
  String get onboardingTitle4 => '获取通知';

  @override
  String get onboardingDesc4 => '接收有关您的经期和排卵日的提醒。';

  @override
  String get getStarted => '开始使用';

  @override
  String get next => '下一步';

  @override
  String get skip => '跳过';

  @override
  String get back => '返回';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get done => '完成';

  @override
  String get maybeLater => '稍后设置';

  @override
  String get enableBiometric => '指纹/人脸识别';

  @override
  String get enablePin => '使用 PIN 码锁定';

  @override
  String get securitySetup => '安全设置';

  @override
  String get securitySetupDesc => '您想锁定该应用程序吗？';

  @override
  String get enterName => '输入你的名字';

  @override
  String get name => '姓名';

  @override
  String get birthDate => '出生日期';

  @override
  String get lastPeriodDate => '上次月经日期';

  @override
  String get averageCycleLength => '平均周期长度';

  @override
  String get averagePeriodLength => '平均经期天数';

  @override
  String get days => '天';

  @override
  String get day => '日';

  @override
  String get today => '今天';

  @override
  String get cycleDay => '月经周期日';

  @override
  String get periodIn => '距离下次月经';

  @override
  String daysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还剩 $countString 天',
    );
    return '$_temp0';
  }

  @override
  String get periodToday => '您的月经可能从今天开始';

  @override
  String get periodOngoing => '您正值经期';

  @override
  String get ovulationDay => '排卵日';

  @override
  String get fertileWindow => '易孕期';

  @override
  String get lutealPhase => '黄体期';

  @override
  String get follicularPhase => '卵泡期';

  @override
  String get periodPhase => '月经期';

  @override
  String get logPeriod => '记录月经';

  @override
  String get periodStarted => '月经开始';

  @override
  String get periodEnded => '月经结束';

  @override
  String get flowIntensity => '经血量';

  @override
  String get light => '少量';

  @override
  String get medium => '中等';

  @override
  String get heavy => '量多';

  @override
  String get veryHeavy => '量很多';

  @override
  String get spotting => '点滴出血';

  @override
  String get symptoms => '症状';

  @override
  String get mood => '心情';

  @override
  String get temperature => '体温';

  @override
  String get weight => '体重';

  @override
  String get waterIntake => '饮水量';

  @override
  String get sleep => '睡眠';

  @override
  String get sexualActivity => '性活动';

  @override
  String get medication => '药物治疗';

  @override
  String get notes => '笔记';

  @override
  String get cramps => '抽筋';

  @override
  String get headache => '头痛';

  @override
  String get bloating => '腹胀';

  @override
  String get breastTenderness => '乳房胀痛';

  @override
  String get backPain => '背痛';

  @override
  String get fatigue => '疲劳';

  @override
  String get nausea => '恶心';

  @override
  String get dizziness => '头晕';

  @override
  String get stress => '压力';

  @override
  String get anxiety => '焦虑';

  @override
  String get irritability => '烦躁';

  @override
  String get crying => '哭泣';

  @override
  String get sensitivity => '灵敏度';

  @override
  String get acne => '痤疮';

  @override
  String get oilySkin => '油性皮肤';

  @override
  String get drySkin => '干性皮肤';

  @override
  String get constipation => '便秘';

  @override
  String get diarrhea => '腹泻';

  @override
  String get gas => '肠胃胀气';

  @override
  String get increasedAppetite => '食欲增加';

  @override
  String get decreasedAppetite => '食欲减退';

  @override
  String get insomnia => '失眠';

  @override
  String get hotFlash => '潮热';

  @override
  String get swelling => '肿胀';

  @override
  String get hairLoss => '脱发';

  @override
  String get happy => '快乐';

  @override
  String get sad => '悲伤';

  @override
  String get angry => '生气';

  @override
  String get anxious => '着急';

  @override
  String get calm => '冷静';

  @override
  String get energetic => '精力充沛';

  @override
  String get tired => '累了';

  @override
  String get romantic => '浪漫';

  @override
  String get confused => '困惑';

  @override
  String get confident => '自信';

  @override
  String get avgCycleLength => '平均周期天数';

  @override
  String get avgPeriodLength => '平均经期天数';

  @override
  String get cycleHistory => '月经周期历史';

  @override
  String get symptomFrequency => '症状频率';

  @override
  String get moodDistribution => '情绪分布';

  @override
  String get temperatureTrend => '温度趋势';

  @override
  String get weightTrend => '体重趋势';

  @override
  String get last3Months => '过去 3 个月';

  @override
  String get last6Months => '过去 6 个月';

  @override
  String get last12Months => '过去 12 个月';

  @override
  String get exportData => '导出数据';

  @override
  String get exportPdf => 'PDF报告';

  @override
  String get exportCsv => 'CSV 文件';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get lightTheme => '浅色主题';

  @override
  String get darkTheme => '深色主题';

  @override
  String get notifications => '通知';

  @override
  String get periodReminder => '经期提醒';

  @override
  String get ovulationReminder => '排卵提醒';

  @override
  String get medicationReminder => '服药提醒';

  @override
  String get waterReminder => '喝水提醒';

  @override
  String get security => '安全';

  @override
  String get pinLock => '密码锁';

  @override
  String get biometricLock => '生物识别锁';

  @override
  String get dataBackup => '数据备份';

  @override
  String get deleteAllData => '删除所有数据';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get glasses => '杯';

  @override
  String get dailyGoal => '每日目标';

  @override
  String get sleepQuality => '睡眠质量';

  @override
  String get bedTime => '就寝时间';

  @override
  String get wakeTime => '起床时间';

  @override
  String get totalSleep => '总睡眠时间';

  @override
  String get hours => '小时';

  @override
  String get protection => '保护';

  @override
  String get condom => '避孕套';

  @override
  String get pill => '避孕药';

  @override
  String get iud => '宫内节育器';

  @override
  String get none => '无';

  @override
  String get other => '其他';

  @override
  String get medicationName => '药品名称';

  @override
  String get dose => '剂量';

  @override
  String get reminderTime => '提醒时间';

  @override
  String get taken => '已服用';

  @override
  String get notTaken => '未服用';

  @override
  String get addNote => '添加注释';

  @override
  String get selectDate => '选择日期';

  @override
  String get noDataYet => '还没有数据';

  @override
  String get predictions => '预测';

  @override
  String get nextPeriod => '下次月经';

  @override
  String get nextOvulation => '下次排卵';

  @override
  String get cycleRegularity => '周期规律性';

  @override
  String get regular => '常规';

  @override
  String get irregular => '不规则';

  @override
  String get setupComplete => '设置完成！';

  @override
  String get letsStart => '让我们开始吧';

  @override
  String get bmi => '体重指数';

  @override
  String get goalReached => '目标达到了！';

  @override
  String get helloGeneric => '你好！';

  @override
  String get dayHasRecord => '有记录';

  @override
  String get increase => '增加';

  @override
  String get decrease => '减少';

  @override
  String get bbtHint => '为了获得准确的读数，请在每天起床后、起床前的同一时间进行测量。排卵确认依赖于这些读数。';

  @override
  String get deleteMeasurement => '删除测量';

  @override
  String get measurementDeleted => '测量值已删除';

  @override
  String get deleteRecord => '删除记录';

  @override
  String get recordDeleted => '记录已删除';

  @override
  String get invalidWeight => '输入有效体重（20-300 公斤）';

  @override
  String get invalidTemperature => '输入有效温度 (35-40 °C)';

  @override
  String get discardChangesTitle => '未保存的更改';

  @override
  String get discardChangesBody => '您的笔记未保存。现在离开就丢弃它。';

  @override
  String get discard => '丢弃';

  @override
  String severityLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return '严重性 $levelString/5';
  }

  @override
  String get pregnancySetStartPrompt => '点击以设置您的怀孕开始时间';

  @override
  String helloName(String name) {
    return '你好，$name！';
  }

  @override
  String get ovulationPhase => '排卵期';

  @override
  String get menstrualPhase => '月经期';

  @override
  String get todaySummary => '今日总结';

  @override
  String get howAreYouFeeling => '你今天感觉怎么样？';

  @override
  String get logMoodAndSymptoms => '记录您的情绪和症状';

  @override
  String get addRecord => '添加记录';

  @override
  String nSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 症状',
    );
    return '$_temp0';
  }

  @override
  String get periodDayLabel => '经期日';

  @override
  String get predicted => '预测';

  @override
  String get fertile => '易孕期';

  @override
  String get ovulation => '排卵';

  @override
  String moodLabel(String mood) {
    return '心情：$mood';
  }

  @override
  String nGlassesWater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 杯水';
  }

  @override
  String get noRecordForDay => '这一天没有记录。';

  @override
  String get dailyLog => '每日日志';

  @override
  String get dailyMeasurements => '每日测量';

  @override
  String get flow => '经血量';

  @override
  String get recorded => '已录制';

  @override
  String nMedications(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 药物',
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
      other: '$countString 杯',
    );
    return '$_temp0';
  }

  @override
  String get flowTracking => '经血量记录';

  @override
  String get color => '颜色';

  @override
  String get lightRed => '浅红色';

  @override
  String get red => '红色';

  @override
  String get darkRed => '深红色';

  @override
  String get brown => '棕色';

  @override
  String get clots => '血块';

  @override
  String get clotsQuestion => '有血栓吗？';

  @override
  String get padChange => '卫生巾更换次数';

  @override
  String get flowSaved => '经血量已保存';

  @override
  String get symptomTracking => '症状追踪';

  @override
  String get physical => '身体素质';

  @override
  String get emotional => '情绪化';

  @override
  String get skinCategory => '皮肤';

  @override
  String get digestive => '消化';

  @override
  String get otherCategory => '其他';

  @override
  String get glowingSkin => '容光焕发的肌肤';

  @override
  String saveNSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '保存（$countString症状）';
  }

  @override
  String nSymptomsSaved(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 症状已保存';
  }

  @override
  String get addNoteOptional => '添加注释（可选）';

  @override
  String get writeAboutToday => '今天写点东西...';

  @override
  String get moodSaved => '心情得到拯救';

  @override
  String get sensitiveM => '敏感';

  @override
  String get irritableM => '烦躁';

  @override
  String get neutralM => '中性';

  @override
  String get lowTemp => '低';

  @override
  String get normalTemp => '正常';

  @override
  String get highTemp => '高';

  @override
  String get fever => '发烧';

  @override
  String get measurementTime => '测量时间';

  @override
  String get temperatureSaved => '保存温度';

  @override
  String get quickAdjust => '快速调整';

  @override
  String get manualEntry => '手动输入';

  @override
  String get weightSaved => '减轻重量';

  @override
  String get waterTracking => '水追踪';

  @override
  String get waterSaved => '节约用水';

  @override
  String get sleepTracking => '睡眠追踪';

  @override
  String get bedTimeLabel => '就寝时间';

  @override
  String get wakeTimeLabel => '起床时间';

  @override
  String get veryBad => '非常糟糕';

  @override
  String get bad => '不好';

  @override
  String get moderate => '中等';

  @override
  String get good => '好';

  @override
  String get great => '太棒了';

  @override
  String get sleepSaved => '睡眠已保存';

  @override
  String get protectionMethod => '保护方式';

  @override
  String get orgasm => '性高潮';

  @override
  String get noteOptional => '注意（可选）';

  @override
  String get addNoteHint => '添加注释...';

  @override
  String get savedGeneric => '已保存';

  @override
  String get medicationTracking => '药物追踪';

  @override
  String get addMedication => '添加药物';

  @override
  String get noMedicationsYet => '尚未添加任何药物';

  @override
  String get medicationPlanHint => '这个计划每天都适用。该复选框仅记录所选日期。';

  @override
  String get medicationAlreadyInPlan => '这种药物已经在计划中了';

  @override
  String get tapToAdd => '点击 + 添加';

  @override
  String get add => '添加';

  @override
  String get dailyNote => '每日笔记';

  @override
  String get myNotes => '我的笔记';

  @override
  String get notesHint => '你感觉怎么样？在这里写下你的笔记...';

  @override
  String get noteSaved => '注释已保存';

  @override
  String get cycleOverview => '月经周期概览';

  @override
  String get avgCycle => '平均周期';

  @override
  String get avgPeriod => '平均经期';

  @override
  String get regularity => '规律性';

  @override
  String get insufficientData => '数据不足';

  @override
  String get noSymptomData => '尚无症状数据';

  @override
  String get noMoodData => '还没有情绪数据';

  @override
  String get noCycleData => '尚无周期数据';

  @override
  String get ongoing => '正在进行的';

  @override
  String nDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString 天',
    );
    return '$_temp0';
  }

  @override
  String get profileSection => '个人资料';

  @override
  String get preferences => '偏好设置';

  @override
  String get age => '年龄';

  @override
  String nYearsOld(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString岁',
    );
    return '$_temp0';
  }

  @override
  String get cycleDuration => '月经周期天数';

  @override
  String get periodDuration => '经期天数';

  @override
  String get dataSection => '数据';

  @override
  String get exportPdfReport => '导出 PDF 报告';

  @override
  String get exportCsvFile => '导出 CSV';

  @override
  String get pdfExportSoon => 'PDF 导出即将推出！';

  @override
  String get csvExportSoon => 'CSV 导出即将推出！';

  @override
  String get letsKnowYou => '让我们来认识一下你';

  @override
  String get whatShouldWeCallYou => '我们应该怎么称呼你？';

  @override
  String get yourName => '你的名字';

  @override
  String get yourBirthDate => '你的出生日期';

  @override
  String get birthDateHelp => '帮助我们提供适合年龄的建议。';

  @override
  String get selectDateHint => '选择日期';

  @override
  String get selectDateToContinue => '选择继续的日期';

  @override
  String stepOfSteps(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$totalString 的步骤 $currentString';
  }

  @override
  String get lastPeriodTitle => '上次月经';

  @override
  String get lastPeriodHelp => '选择您上次经期的开始日期。';

  @override
  String get cycleLengthTitle => '周期长度';

  @override
  String get cycleLengthHelp => '您的平均周期是多少天？\n（从一个周期的第一天到下一个周期的第一天）';

  @override
  String get periodLengthTitle => '经期天数';

  @override
  String get periodLengthHelp => '您的经期通常持续几天？';

  @override
  String get averageLabel => '平均';

  @override
  String get completeBtn => '完成';

  @override
  String get continueBtn => '继续';

  @override
  String errorOccurred(String error) {
    return '发生错误：$error';
  }

  @override
  String get welcomeInfoTitle => '欢迎！';

  @override
  String get welcomeInfoDesc => '追踪您健康状况的最简单、最美观的方式。我们会陪伴您度过周期的每一步。';

  @override
  String get trackCycleTitle => '追踪月经周期';

  @override
  String get trackCycleDesc => '轻松记录您的经期日期、症状和情绪。您的所有数据都是安全的。';

  @override
  String get getPredictionsTitle => '获取预测';

  @override
  String get getPredictionsDesc => '通过智能预测了解您的下一个周期和受孕日。';

  @override
  String get startBtn => '开始';

  @override
  String daysLater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '在 $countString 天内';
  }

  @override
  String get todayExclamation => '今天！';

  @override
  String get spiral => '宫内节育器';

  @override
  String get enterPin => '输入密码';

  @override
  String get createPin => '创建 PIN 码';

  @override
  String get confirmPin => '确认密码';

  @override
  String get pinMismatch => 'PIN 码不匹配，请重试';

  @override
  String get verifyPinTitle => '输入您当前的 PIN 码';

  @override
  String get wrongPin => 'PIN 码错误';

  @override
  String tooManyAttempts(int seconds) {
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return '错误的尝试太多了。等待 $secondsString 秒';
  }

  @override
  String get coachMenstrual0 => '您可以记录出血、疼痛以及您的感受。针对您担心的症状寻求医疗建议。';

  @override
  String get coachMenstrual1 => '如果舒服的话，轻柔的动作或温暖可能会帮助您感觉更好。个人经历各有不同。';

  @override
  String get coachMenstrual2 => '根据您今天的感受选择休息或活动。';

  @override
  String get coachFollicular0 => '能量和症状因人和周期而异。使用您自己的记录来注意模式。';

  @override
  String get coachFollicular1 => '您的皮肤可能会在周期中发生变化。记录变化而不是假设固定模式。';

  @override
  String get coachFollicular2 => '根据您的健康和舒适度而不是预测的周期阶段来选择运动。';

  @override
  String get coachOvulation0 => '受孕日是估计值。这个应用程序不是避孕方法。';

  @override
  String get coachOvulation1 => '如果出现新的、严重的或持续性的疼痛，请寻求医疗建议，而不是将其归因于排卵。';

  @override
  String get coachOvulation2 => '情绪和社交能量各不相同。预测的阶段无法确定您的感受。';

  @override
  String get coachLuteal0 => '睡眠、压力和许多其他因素都会影响症状。记录你注意到的事情。';

  @override
  String get coachLuteal1 => '选择适合您需求的膳食和活动。预测阶段并不规定饮食。';

  @override
  String get coachLuteal2 => '情绪变化有很多可能的原因。针对持续存在或令您担心的症状寻求支持。';

  @override
  String get ovulationConfirmed => '可能排卵';

  @override
  String get ovulationConfirmedInfo =>
      '体温模式或 LH 测试表明可能排卵。疾病、睡眠和测量时间都会影响结果。这不是临床证实，不得用于避孕。';

  @override
  String get premiumSection => '高级版';

  @override
  String get removeAds => '删除广告';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get premiumActive => '高级活动 - 广告已关闭';

  @override
  String get storeUnavailable => '商店目前无法使用';

  @override
  String get healthSync => '同步到 Health Connect';

  @override
  String get healthSyncSuccess => '经期数据已同步';

  @override
  String get healthSyncDenied => '健康数据许可被拒绝';

  @override
  String get healthSyncUnavailable => '此设备上没有健康服务';

  @override
  String get healthSyncFailed => '同步失败';

  @override
  String get trackingModeTitle => '追踪模式';

  @override
  String get modePeriod => '经期';

  @override
  String get modePregnancy => '怀孕';

  @override
  String get modePill => '避孕药';

  @override
  String get modeTtc => '备孕';

  @override
  String get lhTestTitle => '排卵 (LH) 测试';

  @override
  String get lhPositive => '积极';

  @override
  String get lhNegative => '阴性';

  @override
  String get fertilityToday => '今天的生育能力';

  @override
  String get fertilityHigh => '高';

  @override
  String get fertilityMedium => '中等';

  @override
  String get fertilityLow => '低';

  @override
  String pregnancyWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return '周 $weekString';
  }

  @override
  String get trimester1 => '第一三个月';

  @override
  String get trimester2 => '第二个三个月';

  @override
  String get trimester3 => '第三个学期';

  @override
  String get pregnancyDevelopmentTitle => '本周发展';

  @override
  String get pregnancyDevelopment1 => '随着宝宝主要器官和身体系统的形成，快速发育期仍在继续。';

  @override
  String get pregnancyDevelopment2 => '宝宝的动作变得更加协调；当你觉得它们因人而异时。';

  @override
  String get pregnancyDevelopment3 => '随着分娩准备工作变得更加重要，您的宝宝会继续成长。';

  @override
  String get pregnancyCheckupReminder => '遵循您的医疗保健专业人员建议的检查时间表。';

  @override
  String get pregnancyStartLabel => '末次月经日期（怀孕开始）';

  @override
  String get pregnancyModeInfo => '怀孕模式下预测和经期提醒关闭';

  @override
  String get pillPackStartLabel => '药包开始';

  @override
  String pillDayLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return '丸日 $dayString/21';
  }

  @override
  String pillBreakLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return '休息周•日 $dayString';
  }

  @override
  String get smartPrediction => '智能预测';

  @override
  String get smartPredictionDesc => '预测使用从过去的周期中学到的平均值';

  @override
  String learnedCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '学到：$daysString天';
  }

  @override
  String get phaseInsights => '阶段见解';

  @override
  String get noInsightsYet => '还没有足够的数据来进行洞察。当您记录症状时，此处将出现基于阶段的模式。';

  @override
  String insightLine(String symptom, String phase, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$symptom主要发生在$phase阶段($percentString%)';
  }

  @override
  String get notContraceptionWarning => '预测仅供参考。此应用程序不是避孕方法，不得用于避孕。';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get aboutSection => '关于';

  @override
  String get consentTitle => '您的数据和隐私';

  @override
  String get consentBody =>
      '您的所有数据仅加密存储在此设备上；没有任何内容发送到任何服务器。您可以在“设置”>“关于”下阅读隐私政策。继续操作即表示您接受您的数据以这种方式在您的设备上处理。';

  @override
  String get consentAccept => '我接受';

  @override
  String get quickLog => '快速记录';

  @override
  String get shortcutQuickLog => '快速记录';

  @override
  String get shortcutToday => '查看今日';

  @override
  String get allTrackers => '所有追踪器类型';

  @override
  String get disguiseTitle => '伪装模式';

  @override
  String get disguiseDesc =>
      '该应用程序采用“Notes”身份：名称、图标、小部件、通知和启动屏幕保持中性。返回：长按笔记标题。';

  @override
  String get decoyTitle => '注释';

  @override
  String get decoyEmpty => '还没有笔记';

  @override
  String get decoyHint => '写点东西……';

  @override
  String get backupData => '创建密码备份';

  @override
  String get backupPassword => '备份密码';

  @override
  String get backupPasswordConfirm => '再次输入密码';

  @override
  String get backupPasswordLength => '密码必须为 10–128 个字符';

  @override
  String get backupPasswordsDoNotMatch => '密码不匹配';

  @override
  String get backupNoRecovery => '该密码不会存储在设备上且无法恢复。如果您忘记了，则无法打开备份。';

  @override
  String get unlockBackupTitle => '输入备份密码';

  @override
  String get unlockBackupBody => '该备份只能使用创建时使用的密码打开。';

  @override
  String get backupPasswordOrFileInvalid => '密码不正确或备份文件损坏。';

  @override
  String get legacyBackupWarning => '此较旧的备份未加密。恢复后，新的备份将受到密码保护。';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get restoreData => '从备份恢复';

  @override
  String get restoreConfirmTitle => '恢复备份？';

  @override
  String restoreConfirmBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '所有当前数据将被删除，并且备份中的 $countString 记录将被恢复。此操作无法撤消。';
  }

  @override
  String get restore => '恢复';

  @override
  String get backupRestored => '备份已恢复';

  @override
  String get invalidBackupFile => '备份文件无效';

  @override
  String get dateLabel => '日期';

  @override
  String get modeStepTitle => '你会用它做什么？';

  @override
  String get modeStepSubtitle => '您可以稍后在“设置”中更改此设置';

  @override
  String get modePeriodDesc => '周期跟踪和预测';

  @override
  String get modePregnancyDesc => '每周怀孕';

  @override
  String get modePillDesc => '21+7 服药时间表';

  @override
  String get modeTtcDesc => '以生育力为重点的追踪';

  @override
  String get paywallTitle => '升级至高级版';

  @override
  String paywallTrialSubtitle(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '您的试用期已生效：还剩 $daysString 天。高级版可让一切解锁。';
  }

  @override
  String get paywallFreeSubtitle => '您的审判已经结束。免费版本可以跟踪经期和日历；每日跟踪和见解都是高级的。';

  @override
  String get paywallFeatureTrackers => '所有日常追踪器：症状、情绪、饮水、睡眠、体重、体温、药物、笔记';

  @override
  String get paywallFeatureStats => '统计数据、趋势和“我的年份”戒指';

  @override
  String get paywallFeatureInsights => '个人见解和阶段提示通知';

  @override
  String get paywallFeatureExport => 'PDF/CSV 导出';

  @override
  String get paywallFeatureHealth => 'Health Connect 同步';

  @override
  String get paywallFeatureDisguise => '使用 Notes 诱饵进行伪装模式';

  @override
  String get paywallFeatureNoAds => '无广告体验';

  @override
  String get planMonthly => '每月';

  @override
  String get planYearly => '每年';

  @override
  String get perMonth => '/月';

  @override
  String get perYear => '/年';

  @override
  String get bestValue => '最超值';

  @override
  String get continueFreeBtn => '暂时继续免费';

  @override
  String trialBadge(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '试用：$daysString 还剩几天';
  }

  @override
  String get freeBadge => '免费版';

  @override
  String get freeExplain =>
      '免费版本保留经期跟踪、日历和预测。每日追踪器、统计、导出、Health Connect、伪装模式和模式均为高级。';

  @override
  String get seePlans => '查看计划';

  @override
  String get premiumLockedTitle => '统计数据是优质的';

  @override
  String get premiumLockedBody =>
      '图表、趋势、阶段见解和“我的一年”戒指可通过 Premium 解锁。您在试用期间记录的所有内容都会得到安全保存。';

  @override
  String get yearRingTitle => '我的一年';

  @override
  String get yearRingCycles => '循环';

  @override
  String yearRingSummary(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '过去 12 个月：$countString 周期';
  }

  @override
  String get cycleComparison => '你的最后一个周期';

  @override
  String lastCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '最后一个周期：$daysString 天';
  }

  @override
  String lastPeriodLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '末期：$daysString 天';
  }

  @override
  String vsAverageMore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString 天数比您的平均天数长';
  }

  @override
  String vsAverageLess(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString 天数比您的平均天数短';
  }

  @override
  String get vsAverageSame => '与你的平均水平相同';

  @override
  String coachPersonalInsight(String symptom, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '根据您的日志，此阶段最常见的是：$symptom ($percentString%)';
  }

  @override
  String get notificationInsightTitle => '相尖';

  @override
  String notificationInsightBody(String symptom) {
    return '黄体期开始。根据您的日志，您在此阶段最常见的症状：$symptom。';
  }

  @override
  String get notificationPeriodTitle => '经期提醒';

  @override
  String get notificationPeriodTimingToday => '您的月经可能从今天开始。';

  @override
  String get notificationPeriodTimingTomorrow => '您的月经可能明天开始。';

  @override
  String notificationPeriodTimingInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '您的月经可能会在 $daysString 天后开始。';
  }

  @override
  String get notificationPeriodTip1 => '记得带上卫生巾或卫生棉条。';

  @override
  String get notificationPeriodTip2 => '做一点准备会让事情变得更容易。';

  @override
  String get notificationPeriodTip3 => '记录开始可以改善您的预测。';

  @override
  String get notificationPeriodChannel => '经期提醒';

  @override
  String get notificationPeriodChannelDesc => '经期周期提醒';

  @override
  String get notificationOvulationTitle => '排卵提醒';

  @override
  String get notificationOvulationBody => '今天是预计排卵日，可能处于易孕期。';

  @override
  String get notificationOvulationChannel => '排卵提醒';

  @override
  String get notificationOvulationChannelDesc => '排卵提醒';

  @override
  String get notificationMedicationTitle => '服药提醒';

  @override
  String get notificationMedicationBody => '别忘了吃药！';

  @override
  String get notificationMedicationChannel => '服药提醒';

  @override
  String get notificationMedicationChannelDesc => '服药提醒';

  @override
  String get notificationDiscreetTitle => '提醒';

  @override
  String get notificationDiscreetBody => '今天有一个提醒';

  @override
  String get notificationFertileTitle => '您的受孕窗口开始了';

  @override
  String get notificationFertileBody => '从今天开始，您就进入了受孕机会最高的日子。';

  @override
  String get notificationChainEndTitle => '提醒已暂停';

  @override
  String get notificationChainEndBody => '预定的提醒已用完。打开应用程序以设置新的。';

  @override
  String get noPurchasesToRestore => '未找到可恢复的购买';

  @override
  String get restoringPurchases => '正在恢复购买...';

  @override
  String get backdateHint => '长按选择不同的一天';

  @override
  String get periodStartDateHelp => '你的月经是什么时候开始的？';

  @override
  String get periodEndDateHelp => '你的月经什么时候结束？';

  @override
  String get headlinePeriodToday => '您的月经可能从今天开始';

  @override
  String get headlinePeriodTomorrow => '您的月经可能明天开始';

  @override
  String get headlineNoData => '添加您的末次月经日期';

  @override
  String headlinePeriodInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '您的经期（$daysString 天）';
  }

  @override
  String headlinePeriodDay(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return '您的月经日 $dayString';
  }

  @override
  String get headlineDelaySubtitle => '有些变化是正常的。如果已启动，则将其记录下来。';

  @override
  String get notificationDelayTitle => '预计日期已过';

  @override
  String get notificationDelayBody => '如果您的经期已经开始，请记得记录下来。有些变化是正常的。';

  @override
  String get notificationDelayBodyAlt1 => '还没有条目。如果已启动，只需轻轻一按即可进行记录。';

  @override
  String get notificationDelayBodyAlt2 => '几天的轮班是很常见的。您的日志是最新的吗？';

  @override
  String get notificationDelayChannel => '延误提醒';

  @override
  String get notificationDelayChannelDesc => '预计日期已过时提醒';

  @override
  String headlineDelay(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '您的月经推迟了 $daysString 天';
  }

  @override
  String delayDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString 晚了几天';
  }

  @override
  String get yourDataStays => '试用结束后，您的记录仍保留在您的设备上。';

  @override
  String get periodStartedOnThisDay => '我的月经从这一天开始';

  @override
  String nCyclesRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '记录 $countString 循环';
  }

  @override
  String nLogsRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString每日日志';
  }

  @override
  String get notifPermissionTitle => '打开提醒？';

  @override
  String get notifPermissionBody =>
      '当您的经期临近、排卵日以及预计日期已过时，我们会通知您。通知永远不会离开您的设备。您也可以稍后在设置中将其打开。';

  @override
  String get enableNotifications => '打开';

  @override
  String get notNow => '现在不行';

  @override
  String get optionalField => '可选';

  @override
  String get privacyAssurance => '您的数据仅在此设备上保持加密状态';

  @override
  String get privacySummary =>
      '您的核心数据在此设备上已加密；仅当您导出或启用 Health Connect 时，它才会离开。';

  @override
  String get dontRememberExactly => '我记不太清楚了';

  @override
  String get approxTitle => '大概是什么时候的事？';

  @override
  String get approxSubtitle => '一个粗略的日期就足够了。当您记录时，预测会自行纠正。';

  @override
  String get approxThisWeek => '本周';

  @override
  String get approxLastWeek => '上周';

  @override
  String get approxTwoWeeks => '大约 2 周前';

  @override
  String get approxThreeWeeks => '大约 3 周前';

  @override
  String get approxMonthOrMore => '一个月或更长时间前';

  @override
  String get cycleReminderTime => '循环提醒时间';

  @override
  String get medicationReminderTime => '服药提醒时间';

  @override
  String get periodReminderLead => '经期提醒';

  @override
  String get notificationQuietChannelSuffix => '安静';

  @override
  String get quietNotifications => '安静的通知';

  @override
  String get quietNotificationsDesc => '没有声音或弹出窗口 - 他们在通知栏中默默等待';

  @override
  String get leadSameDay => '同一天';

  @override
  String leadNDaysBefore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString 天前';
  }

  @override
  String get regularityInfoIrregular =>
      '您的最短周期和最长周期之间有 9 天或更多天。周期长度变化很常见；压力、睡眠、疾病和生活变化都会影响它。这不是诊断。';

  @override
  String get regularityInfoRegular => '您的最短周期和最长周期之间的差异不到 9 天。通过这种一致性，预测会更加准确。';

  @override
  String get regularityInfoSeeDoctor =>
      '如果您的周期持续短于 21 天或长于 35 天，如果您没有月经超过三个月，或者出血异常严重，则值得咨询医疗保健专业人士。';

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

    return '常见参考范围：月经周期为 $minString–$maxString 天，经期最多 $pmaxString 天。这不是诊断标准。';
  }

  @override
  String lowConfidenceNote(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '这些平均值仅来自 $countString 循环；当您记录更多时，它们会变得锐利。';
  }

  @override
  String regularityInfoInsufficient(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '在规律性产生任何意义之前，至少需要 $countString 循环间隙。对较少的判断会产生误导。';
  }

  @override
  String get backupNever => '您从未进行过备份。';

  @override
  String get backupStaleHint => '如果您丢失了手机，记录将无法恢复。';

  @override
  String backupLastAt(String date) {
    return '最后备份：$date';
  }

  @override
  String get durationsStepTitle => '您的周期详细信息';

  @override
  String get durationsStepHelp => '不确定？让它们保持原样 - 您可以稍后在设置中更改它们。';

  @override
  String get lockTimeoutTitle => '锁定延迟';

  @override
  String get lockTimeoutDesc => '当您离开片刻后回来时，请跳过 PIN 码';

  @override
  String get lockImmediately => '立即';

  @override
  String get previousDay => '前一天';

  @override
  String get nextDay => '第二天';

  @override
  String get showLegend => '色键';

  @override
  String get hideLegend => '隐藏颜色键';

  @override
  String get backToToday => '回到今天';

  @override
  String get monthNoRecords => '本月无记录';

  @override
  String get doctorSummary => '为我的医生导出摘要';

  @override
  String get healthImport => '从 Health Connect 导入';

  @override
  String get healthImportAction => '进口';

  @override
  String get allTime => '所有时间';

  @override
  String get actionPeriodStarted => '我的经期开始了';

  @override
  String get actionMedicationTaken => '采取';

  @override
  String get pregnancyTestReady => '妊娠测试现在变得有意义';

  @override
  String notLoggedToday(String what) {
    return '今天没有记录 $what';
  }

  @override
  String pregnancyTestFrom(String date) {
    return '最早有用的测试：$date';
  }

  @override
  String pillBreakIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '休息时间从 $daysString 天开始';
  }

  @override
  String pillNewPackIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString天的新包';
  }

  @override
  String get healthImportNothingNew => '未找到可导入的新记录';

  @override
  String healthImportConfirm(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '在 Health Connect 中发现 $countString 周期跨度不在应用程序中。将它们添加到您的记录中？您现有的记录未受影响。';
  }

  @override
  String healthImportDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString时期进口';
  }

  @override
  String monthPeriodDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 期间天数';
  }

  @override
  String monthLoggedDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString 记录天数';
  }

  @override
  String get pinNoRecoveryWarning =>
      '如果您忘记了 PIN 码，则无法恢复；恢复的唯一方法是删除所有数据。选择一些你会记住的东西。';

  @override
  String lockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString 分钟后';
  }

  @override
  String get reportTitle => '周期健康报告';

  @override
  String get reportGenerated => '生成';

  @override
  String get profileSummary => '简介摘要';

  @override
  String get periodHistory => '时期历史';

  @override
  String get last30DaysSummary => '过去 30 天摘要';

  @override
  String get durationDaysHeader => '持续时间（天）';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '光';

  @override
  String get themeDark => '黑暗';

  @override
  String get languageSystem => '系统';

  @override
  String get statsSectionOverview => '概述';

  @override
  String get statsSectionCharts => '图表';

  @override
  String get statsSectionHistory => '历史与趋势';

  @override
  String storySymptomsMore(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return '过去 30 天比之前的时期更加艰难（$recentString 条目 vs $previousString）。';
  }

  @override
  String storySymptomsLess(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return '过去 30 天比之前的时期更容易（$recentString 条目 vs $previousString）。';
  }

  @override
  String get storySymptomsSame => '过去两个时期的症状强度保持相似。';

  @override
  String storyTrendUp(String delta, String unit) {
    return '在此期间上涨$delta $unit。';
  }

  @override
  String storyTrendDown(String delta, String unit) {
    return '在此期间下调$delta $unit。';
  }

  @override
  String get storyTrendFlat => '在此期间没有发生有意义的变化——趋势持平。';

  @override
  String averageSeverity(String value) {
    return '平均。 $value/5';
  }

  @override
  String get dataCoverage => '数据覆盖范围';

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

    return '$totalString 天数中 $loggedString 的数据 ($percentString%)';
  }

  @override
  String get tapChartPointHint => '点击一个点即可在当天打开。';

  @override
  String get shareCalendarMonth => '共享日历月份';

  @override
  String get longPressDayHint => '按住一天可快速预览。';

  @override
  String get markPeriodRange => '标记经期日期范围';

  @override
  String get periodRangeOverlap => '此日期范围与已有月经记录重叠。';

  @override
  String get periodRangeSaved => '经期日期已保存';

  @override
  String trackingStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '连续记录 $countString 天';
  }

  @override
  String weeklyTracking(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/7 天记录';
  }

  @override
  String get exportCalendarFile => '导出日历 (.ics)';

  @override
  String get ovulationMarkerHint => '虚线：估计或确认排卵';

  @override
  String get addPastCycles => '添加过去的周期';

  @override
  String get addPastCyclesHint => '最多选择 3 个期间日期范围并将它们保存在一起。';

  @override
  String get addPeriodRange => '添加经期日期';

  @override
  String get cycleOverlayTitle => '周期比较';

  @override
  String get symptomLoadComparison => '每日症状严重程度按周期日排列';

  @override
  String get currentCycleLabel => '本周期';

  @override
  String get previousCycleLabel => '上一个周期';

  @override
  String get colorBlindPattern => '图案相色';

  @override
  String get colorBlindPatternDesc => '为相带添加纹理 - 当颜色难以区分时很有用';

  @override
  String get undo => '撤消';

  @override
  String get periodMarkedStarted => '月经开始日期已保存';

  @override
  String get periodMarkedEnded => '月经结束日期已保存';

  @override
  String get editPeriodRecord => '编辑月经记录';

  @override
  String get startDateLabel => '开始';

  @override
  String get endDateLabel => '结束';

  @override
  String get recordUpdated => '记录已更新';

  @override
  String get dataResetTitle => '无法读取您的数据';

  @override
  String get dataResetBody =>
      '无法在此设备上解密应用数据。这通常发生在更换手机或恢复系统备份后：数据使用设备特定密钥加密，无法移动到新设备。该应用程序已重新启动。\n\n要在设备之间移动数据，请通过“设置”>“备份数据”定期导出 JSON 备份。';

  @override
  String get pinSet => 'PIN 设置成功';

  @override
  String get pinRemoved => 'PIN 码已删除';

  @override
  String get unlockWithBiometric => '通过指纹或人脸解锁';

  @override
  String get biometricNotAvailable => '此设备不支持生物识别身份验证';

  @override
  String get editProfile => '编辑个人资料';

  @override
  String get profileSaved => '个人资料已保存';

  @override
  String sleepDurationShort(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString小时$minutesString分钟';
  }

  @override
  String get deleteAllDataConfirm => '您确定要删除所有数据吗？此操作无法撤消。';

  @override
  String get dataDeleted => '所有数据已删除';

  @override
  String get doseHint => '例如500毫克';

  @override
  String get menstrualPhaseInfo => '月经出血的时期。通常持续3-7天。身体脱落子宫内膜。';

  @override
  String get follicularPhaseInfo => '月经结束后，卵巢会准备一个新的卵子。雌激素上升，能量水平增加。';

  @override
  String get ovulationPhaseInfo => '卵子从卵巢释放的阶段。怀孕的可能性最高。';

  @override
  String get lutealPhaseInfo => '从排卵到下一次月经的阶段。黄体酮升高，可能会出现经前综合症症状。';

  @override
  String get fertileWindowInfo => '怀孕机会最高的时期。排卵前 5 天开始，排卵后 1 天结束。';

  @override
  String get ovulationCardInfo => '卵子从卵巢排出的预计日期。发生在周期的中间。';

  @override
  String get nextPeriodInfo => '您下一个月经周期的预计开始日期。根据您的周期长度计算。';

  @override
  String get phaseInfoTitle => '这个阶段是什么？';

  @override
  String get learnMore => '信息';

  @override
  String get healthDisclaimer => '此应用程序不能替代医疗建议。如有健康问题，请咨询医疗保健专业人士。';

  @override
  String get homePriority => '主屏幕优先';

  @override
  String get cycleFirst => '优先显示月经周期';

  @override
  String get todayFirst => '今天先';

  @override
  String get planLifetime => '终身';

  @override
  String get planLifetimeDetail => '一次付款，永久享用高级版';

  @override
  String get cycleNotificationFrequency => '循环通知级别';

  @override
  String get cycleNotificationFrequencyDesc => '服药提醒不受影响';

  @override
  String get notificationFrequencyEssential => '必备';

  @override
  String get notificationFrequencyBalanced => '平衡';

  @override
  String get notificationFrequencyDetailed => '详细';

  @override
  String get readOnlyHistoryNotice => '您可以查看您过去的条目；新的每日条目和更改需要高级版。';

  @override
  String get screenProtectionTitle => '屏幕保护';

  @override
  String get screenProtectionDescription => '阻止截屏和最近使用的应用预览。';

  @override
  String get predictionUncertain => '周期阶段不确定';

  @override
  String get startupRecoveryBody =>
      '无法安全打开您的数据。它已被保存下来。重试，或关闭应用程序并联系支持人员。在恢复备份之前请勿重新安装。';

  @override
  String get retry => '重试';

  @override
  String get adPrivacyOptions => '广告隐私选择';

  @override
  String get policyAvailableEnglish => '该政策有英文版本。原始政策文本如下。';

  @override
  String get purchasePending => '等待付款确认';

  @override
  String get purchaseVerifying => '验证您的购买';

  @override
  String get purchaseFailed => '无法验证您的购买。请重试或恢复购买。';

  @override
  String get pillSchedule => '服药时间表';

  @override
  String get pillContinuous => '连续（无间断）';

  @override
  String get predictionRange => '预计日期范围';

  @override
  String get analyticsChoice => '使用情况统计（可选）';

  @override
  String get analyticsChoiceDescription =>
      '可选。仅计算此设备上的应用操作。健康数据、注释、日期和身份不包括在内。如果没有配置服务，则不会上传任何内容。';

  @override
  String get reportRange => '报告日期范围';

  @override
  String get allHistory => '所有历史';

  @override
  String get pillActiveDaysTitle => '有效服药天数 (1–120)';

  @override
  String get pillBreakDaysTitle => '休息日或安慰剂日 (0–14)';

  @override
  String get pillPrescriptionNote => '仅使用您的处方或临床医生说明中的时间表。此设置不建议更换药物。';
}
