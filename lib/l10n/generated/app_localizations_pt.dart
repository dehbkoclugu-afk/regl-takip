// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Calendário Menstrual';

  @override
  String get home => 'Início';

  @override
  String get calendar => 'Calendário';

  @override
  String get log => 'Registrar';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get settings => 'Configurações';

  @override
  String get profile => 'Perfil';

  @override
  String get onboardingWelcome => 'Bem-vindo!';

  @override
  String get onboardingWelcomeDesc =>
      'A maneira mais fácil de monitorar sua saúde';

  @override
  String get onboardingTitle1 => 'Acompanhe seu ciclo menstrual';

  @override
  String get onboardingDesc1 =>
      'Registre sua menstruação e veja a previsão da próxima.';

  @override
  String get onboardingTitle2 => 'Monitore sua saúde';

  @override
  String get onboardingDesc2 =>
      'Acompanhe sintomas, humor, temperatura e muito mais.';

  @override
  String get onboardingTitle3 => 'Veja sua análise';

  @override
  String get onboardingDesc3 =>
      'Entenda seu ciclo com gráficos e estatísticas detalhadas.';

  @override
  String get onboardingTitle4 => 'Receba notificações';

  @override
  String get onboardingDesc4 =>
      'Receba lembretes sobre sua menstruação e dias de ovulação.';

  @override
  String get getStarted => 'Comece';

  @override
  String get next => 'Próximo';

  @override
  String get skip => 'Pular';

  @override
  String get back => 'Voltar';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Concluído';

  @override
  String get maybeLater => 'Configurar mais tarde';

  @override
  String get enableBiometric => 'Impressão digital/reconhecimento facial';

  @override
  String get enablePin => 'Bloquear com PIN';

  @override
  String get securitySetup => 'Configuração de segurança';

  @override
  String get securitySetupDesc => 'Gostaria de bloquear o aplicativo?';

  @override
  String get enterName => 'Digite seu nome';

  @override
  String get name => 'Nome';

  @override
  String get birthDate => 'Data de Nascimento';

  @override
  String get lastPeriodDate => 'Data da última menstruação';

  @override
  String get averageCycleLength => 'Duração média do ciclo';

  @override
  String get averagePeriodLength => 'Duração média da menstruação';

  @override
  String get days => 'dias';

  @override
  String get day => 'dia';

  @override
  String get today => 'Hoje';

  @override
  String get cycleDay => 'Dia do ciclo';

  @override
  String get periodIn => 'Menstruação em';

  @override
  String daysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $countString dias',
    );
    return '$_temp0';
  }

  @override
  String get periodToday => 'Sua menstruação pode começar hoje';

  @override
  String get periodOngoing => 'Você está menstruada';

  @override
  String get ovulationDay => 'Dia da Ovulação';

  @override
  String get fertileWindow => 'Janela fértil';

  @override
  String get lutealPhase => 'Fase Lútea';

  @override
  String get follicularPhase => 'Fase Folicular';

  @override
  String get periodPhase => 'Fase menstrual';

  @override
  String get logPeriod => 'Registrar menstruação';

  @override
  String get periodStarted => 'Menstruação começou';

  @override
  String get periodEnded => 'Menstruação terminou';

  @override
  String get flowIntensity => 'Intensidade do fluxo menstrual';

  @override
  String get light => 'Leve';

  @override
  String get medium => 'Médio';

  @override
  String get heavy => 'Intenso';

  @override
  String get veryHeavy => 'Muito intenso';

  @override
  String get spotting => 'Sangramento de escape';

  @override
  String get symptoms => 'Sintomas';

  @override
  String get mood => 'Humor';

  @override
  String get temperature => 'Temperatura corporal';

  @override
  String get weight => 'Peso';

  @override
  String get waterIntake => 'Ingestão de água';

  @override
  String get sleep => 'Sono';

  @override
  String get sexualActivity => 'Atividade Sexual';

  @override
  String get medication => 'Medicação';

  @override
  String get notes => 'Notas';

  @override
  String get cramps => 'Cólicas';

  @override
  String get headache => 'Dor de cabeça';

  @override
  String get bloating => 'Inchaço';

  @override
  String get breastTenderness => 'Sensibilidade nas mamas';

  @override
  String get backPain => 'Dor nas costas';

  @override
  String get fatigue => 'Fadiga';

  @override
  String get nausea => 'Náusea';

  @override
  String get dizziness => 'Tontura';

  @override
  String get stress => 'Estresse';

  @override
  String get anxiety => 'Ansiedade';

  @override
  String get irritability => 'Irritabilidade';

  @override
  String get crying => 'Chorando';

  @override
  String get sensitivity => 'Sensibilidade';

  @override
  String get acne => 'Acne';

  @override
  String get oilySkin => 'Pele oleosa';

  @override
  String get drySkin => 'Pele seca';

  @override
  String get constipation => 'Constipação';

  @override
  String get diarrhea => 'Diarréia';

  @override
  String get gas => 'Gases';

  @override
  String get increasedAppetite => 'Aumento do apetite';

  @override
  String get decreasedAppetite => 'Diminuição do apetite';

  @override
  String get insomnia => 'Insônia';

  @override
  String get hotFlash => 'Ondas de calor';

  @override
  String get swelling => 'Inchaço';

  @override
  String get hairLoss => 'Perda de cabelo';

  @override
  String get happy => 'Feliz';

  @override
  String get sad => 'Triste';

  @override
  String get angry => 'Irritado';

  @override
  String get anxious => 'Ansioso';

  @override
  String get calm => 'Calma';

  @override
  String get energetic => 'Energético';

  @override
  String get tired => 'Cansado';

  @override
  String get romantic => 'Romântico';

  @override
  String get confused => 'Confuso';

  @override
  String get confident => 'Confiante';

  @override
  String get avgCycleLength => 'Duração média do ciclo';

  @override
  String get avgPeriodLength => 'Duração média da menstruação';

  @override
  String get cycleHistory => 'Histórico dos ciclos';

  @override
  String get symptomFrequency => 'Frequência dos sintomas';

  @override
  String get moodDistribution => 'Distribuição de humor';

  @override
  String get temperatureTrend => 'Tendência de temperatura';

  @override
  String get weightTrend => 'Tendência de peso';

  @override
  String get last3Months => 'Últimos 3 meses';

  @override
  String get last6Months => 'Últimos 6 meses';

  @override
  String get last12Months => 'Últimos 12 meses';

  @override
  String get exportData => 'Exportar dados';

  @override
  String get exportPdf => 'Relatório PDF';

  @override
  String get exportCsv => 'Arquivo CSV';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Tema claro';

  @override
  String get darkTheme => 'Tema escuro';

  @override
  String get notifications => 'Notificações';

  @override
  String get periodReminder => 'Lembrete de menstruação';

  @override
  String get ovulationReminder => 'Lembrete de ovulação';

  @override
  String get medicationReminder => 'Lembrete de medicação';

  @override
  String get waterReminder => 'Lembrete de água';

  @override
  String get security => 'Segurança';

  @override
  String get pinLock => 'Bloqueio de PIN';

  @override
  String get biometricLock => 'Bloqueio Biométrico';

  @override
  String get dataBackup => 'Backup de dados';

  @override
  String get deleteAllData => 'Excluir todos os dados';

  @override
  String get about => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get glasses => 'copos';

  @override
  String get dailyGoal => 'Meta diária';

  @override
  String get sleepQuality => 'Qualidade do sono';

  @override
  String get bedTime => 'Hora de dormir';

  @override
  String get wakeTime => 'Hora de acordar';

  @override
  String get totalSleep => 'Sono Total';

  @override
  String get hours => 'horas';

  @override
  String get protection => 'Proteção';

  @override
  String get condom => 'Preservativo';

  @override
  String get pill => 'Pílula';

  @override
  String get iud => 'DIU';

  @override
  String get none => 'Nenhum';

  @override
  String get other => 'Outro';

  @override
  String get medicationName => 'Nome do medicamento';

  @override
  String get dose => 'Dose';

  @override
  String get reminderTime => 'Hora do lembrete';

  @override
  String get taken => 'Tomado';

  @override
  String get notTaken => 'Não tomado';

  @override
  String get addNote => 'Adicionar nota';

  @override
  String get selectDate => 'Selecione a data';

  @override
  String get noDataYet => 'Ainda não há dados';

  @override
  String get predictions => 'Previsões';

  @override
  String get nextPeriod => 'Próxima menstruação';

  @override
  String get nextOvulation => 'Próxima ovulação';

  @override
  String get cycleRegularity => 'Regularidade do Ciclo';

  @override
  String get regular => 'Normal';

  @override
  String get irregular => 'Irregular';

  @override
  String get setupComplete => 'Configuração concluída!';

  @override
  String get letsStart => 'Vamos começar';

  @override
  String get bmi => 'IMC';

  @override
  String get goalReached => 'Meta alcançada!';

  @override
  String get helloGeneric => 'Olá!';

  @override
  String get dayHasRecord => 'tem um registro';

  @override
  String get increase => 'Aumentar';

  @override
  String get decrease => 'Diminuir';

  @override
  String get bbtHint =>
      'Para uma leitura precisa, meça logo ao acordar, antes de sair da cama, no mesmo horário todos os dias. A confirmação da ovulação depende dessas leituras.';

  @override
  String get deleteMeasurement => 'Excluir medição';

  @override
  String get measurementDeleted => 'Medição excluída';

  @override
  String get deleteRecord => 'Excluir registro';

  @override
  String get recordDeleted => 'Registro excluído';

  @override
  String get invalidWeight => 'Insira um peso válido (20-300 kg)';

  @override
  String get invalidTemperature => 'Insira uma temperatura válida (35-40 °C)';

  @override
  String get discardChangesTitle => 'Alterações não salvas';

  @override
  String get discardChangesBody =>
      'Sua nota não foi salva. Sair agora descarta isso.';

  @override
  String get discard => 'Descartar';

  @override
  String severityLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'gravidade $levelString/5';
  }

  @override
  String get pregnancySetStartPrompt =>
      'Toque para definir o início da gravidez';

  @override
  String helloName(String name) {
    return 'Olá, $name!';
  }

  @override
  String get ovulationPhase => 'Fase de ovulação';

  @override
  String get menstrualPhase => 'Fase menstrual';

  @override
  String get todaySummary => 'Resumo de hoje';

  @override
  String get howAreYouFeeling => 'Como você está se sentindo hoje?';

  @override
  String get logMoodAndSymptoms => 'Registre seu humor e sintomas';

  @override
  String get addRecord => 'Adicionar registro';

  @override
  String nSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sintomas $countString',
    );
    return '$_temp0';
  }

  @override
  String get periodDayLabel => 'Dia de menstruação';

  @override
  String get predicted => 'Previsto';

  @override
  String get fertile => 'Fértil';

  @override
  String get ovulation => 'Ovulação';

  @override
  String moodLabel(String mood) {
    return 'Humor: $mood';
  }

  @override
  String nGlassesWater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString copos de água';
  }

  @override
  String get noRecordForDay => 'Nenhum registro para este dia.';

  @override
  String get dailyLog => 'Registro Diário';

  @override
  String get dailyMeasurements => 'Medições Diárias';

  @override
  String get flow => 'Fluxo menstrual';

  @override
  String get recorded => 'Gravado';

  @override
  String nMedications(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Medicamentos $countString',
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
      other: '$countString copos',
    );
    return '$_temp0';
  }

  @override
  String get flowTracking => 'Acompanhar fluxo menstrual';

  @override
  String get color => 'Cor';

  @override
  String get lightRed => 'Vermelho claro';

  @override
  String get red => 'Vermelho';

  @override
  String get darkRed => 'Vermelho escuro';

  @override
  String get brown => 'Marrom';

  @override
  String get clots => 'Coágulos';

  @override
  String get clotsQuestion => 'Algum coágulo?';

  @override
  String get padChange => 'Trocas de absorvente';

  @override
  String get flowSaved => 'Fluxo menstrual salvo';

  @override
  String get symptomTracking => 'Rastreamento de sintomas';

  @override
  String get physical => 'Físico';

  @override
  String get emotional => 'Emocional';

  @override
  String get skinCategory => 'Pele';

  @override
  String get digestive => 'Digestivo';

  @override
  String get otherCategory => 'Outro';

  @override
  String get glowingSkin => 'Pele brilhante';

  @override
  String saveNSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Salvar (sintomas $countString)';
  }

  @override
  String nSymptomsSaved(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Sintomas $countString salvos';
  }

  @override
  String get addNoteOptional => 'Adicionar nota (opcional)';

  @override
  String get writeAboutToday => 'Escreva algo sobre hoje...';

  @override
  String get moodSaved => 'Humor salvo';

  @override
  String get sensitiveM => 'Sensível';

  @override
  String get irritableM => 'Irritável';

  @override
  String get neutralM => 'Neutro';

  @override
  String get lowTemp => 'Baixo';

  @override
  String get normalTemp => 'Normais';

  @override
  String get highTemp => 'Alto';

  @override
  String get fever => 'Febre';

  @override
  String get measurementTime => 'Tempo de medição';

  @override
  String get temperatureSaved => 'Temperatura salva';

  @override
  String get quickAdjust => 'Ajuste rápido';

  @override
  String get manualEntry => 'Entrada manual';

  @override
  String get weightSaved => 'Peso economizado';

  @override
  String get waterTracking => 'Rastreamento de Água';

  @override
  String get waterSaved => 'Água economizada';

  @override
  String get sleepTracking => 'Rastreamento do sono';

  @override
  String get bedTimeLabel => 'Hora de dormir';

  @override
  String get wakeTimeLabel => 'Hora de acordar';

  @override
  String get veryBad => 'Muito ruim';

  @override
  String get bad => 'Ruim';

  @override
  String get moderate => 'Moderado';

  @override
  String get good => 'Bom';

  @override
  String get great => 'Ótimo';

  @override
  String get sleepSaved => 'Sono salvo';

  @override
  String get protectionMethod => 'Método de proteção';

  @override
  String get orgasm => 'Orgasmo';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get addNoteHint => 'Adicionar nota...';

  @override
  String get savedGeneric => 'Salvo';

  @override
  String get medicationTracking => 'Rastreamento de Medicamentos';

  @override
  String get addMedication => 'Adicionar medicação';

  @override
  String get noMedicationsYet => 'Nenhum medicamento adicionado ainda';

  @override
  String get medicationPlanHint =>
      'Este plano se aplica todos os dias. A caixa de seleção registra apenas o dia selecionado.';

  @override
  String get medicationAlreadyInPlan => 'Este medicamento já está no plano';

  @override
  String get tapToAdd => 'Toque em + para adicionar';

  @override
  String get add => 'Adicionar';

  @override
  String get dailyNote => 'Nota Diária';

  @override
  String get myNotes => 'Minhas notas';

  @override
  String get notesHint =>
      'Como você está se sentindo? Escreva suas anotações aqui...';

  @override
  String get noteSaved => 'Nota salva';

  @override
  String get cycleOverview => 'Visão geral do ciclo';

  @override
  String get avgCycle => 'Ciclo médio';

  @override
  String get avgPeriod => 'Média da menstruação';

  @override
  String get regularity => 'Regularidade';

  @override
  String get insufficientData => 'Dados insuficientes';

  @override
  String get noSymptomData => 'Ainda não há dados de sintomas';

  @override
  String get noMoodData => 'Ainda não há dados de humor';

  @override
  String get noCycleData => 'Ainda não há dados de ciclo';

  @override
  String get ongoing => 'em andamento';

  @override
  String nDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dias',
    );
    return '$_temp0';
  }

  @override
  String get profileSection => 'Perfil';

  @override
  String get preferences => 'Preferências';

  @override
  String get age => 'Idade';

  @override
  String nYearsOld(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString anos',
    );
    return '$_temp0';
  }

  @override
  String get cycleDuration => 'Duração do ciclo menstrual';

  @override
  String get periodDuration => 'Duração da menstruação';

  @override
  String get dataSection => 'Dados';

  @override
  String get exportPdfReport => 'Exportar relatório em PDF';

  @override
  String get exportCsvFile => 'Exportar CSV';

  @override
  String get pdfExportSoon => 'Exportação de PDF em breve!';

  @override
  String get csvExportSoon => 'Exportação de CSV em breve!';

  @override
  String get letsKnowYou => 'Vamos conhecer você';

  @override
  String get whatShouldWeCallYou => 'Como devemos chamá-lo?';

  @override
  String get yourName => 'Seu nome';

  @override
  String get yourBirthDate => 'Sua data de nascimento';

  @override
  String get birthDateHelp =>
      'Ajuda-nos a fornecer sugestões adequadas à idade.';

  @override
  String get selectDateHint => 'Selecione a data';

  @override
  String get selectDateToContinue => 'Selecione uma data para continuar';

  @override
  String stepOfSteps(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Etapa $currentString de $totalString';
  }

  @override
  String get lastPeriodTitle => 'Sua última menstruação';

  @override
  String get lastPeriodHelp =>
      'Selecione a data de início da sua última menstruação.';

  @override
  String get cycleLengthTitle => 'Duração do ciclo';

  @override
  String get cycleLengthHelp =>
      'Quantos dias é o seu ciclo médio?\n(Do primeiro dia de uma menstruação até o primeiro dia da próxima)';

  @override
  String get periodLengthTitle => 'Duração da menstruação';

  @override
  String get periodLengthHelp =>
      'Quantos dias normalmente dura a sua menstruação?';

  @override
  String get averageLabel => 'média';

  @override
  String get completeBtn => 'Completo';

  @override
  String get continueBtn => 'Continuar';

  @override
  String errorOccurred(String error) {
    return 'Ocorreu um erro: $error';
  }

  @override
  String get welcomeInfoTitle => 'Bem-vindo!';

  @override
  String get welcomeInfoDesc =>
      'A maneira mais fácil e bonita de monitorar sua saúde. Estamos com você em cada etapa do seu ciclo.';

  @override
  String get trackCycleTitle => 'Acompanhe seu ciclo menstrual';

  @override
  String get trackCycleDesc =>
      'Registre facilmente as datas da menstruação, sintomas e humor. Todos os seus dados estão seguros.';

  @override
  String get getPredictionsTitle => 'Obtenha previsões';

  @override
  String get getPredictionsDesc =>
      'Aprenda seu próximo ciclo e dias férteis com previsões inteligentes.';

  @override
  String get startBtn => 'Começar';

  @override
  String daysLater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'em dias $countString';
  }

  @override
  String get todayExclamation => 'Hoje!';

  @override
  String get spiral => 'DIU';

  @override
  String get enterPin => 'Insira o PIN';

  @override
  String get createPin => 'Criar PIN';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get pinMismatch => 'Os PINs não correspondem. Tente novamente';

  @override
  String get verifyPinTitle => 'Insira seu PIN atual';

  @override
  String get wrongPin => 'PIN errado';

  @override
  String tooManyAttempts(int seconds) {
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Muitas tentativas erradas. Aguarde $secondsString segundos';
  }

  @override
  String get coachMenstrual0 =>
      'Você pode registrar sangramento, dor e como se sente. Procure orientação médica para sintomas que o preocupam.';

  @override
  String get coachMenstrual1 =>
      'Se for confortável, movimentos suaves ou calor podem ajudá-lo a se sentir melhor. As experiências individuais variam.';

  @override
  String get coachMenstrual2 =>
      'Escolha descanso ou atividade de acordo com como você se sente hoje.';

  @override
  String get coachFollicular0 =>
      'A energia e os sintomas variam entre as pessoas e os ciclos. Use seus próprios registros para perceber padrões.';

  @override
  String get coachFollicular1 =>
      'Sua pele pode mudar durante o ciclo. Registre as alterações em vez de assumir um padrão fixo.';

  @override
  String get coachFollicular2 =>
      'Escolha exercícios com base na sua saúde e conforto, não em uma fase prevista do ciclo.';

  @override
  String get coachOvulation0 =>
      'Os dias férteis são estimativas. Este aplicativo não é um método contraceptivo.';

  @override
  String get coachOvulation1 =>
      'Procure aconselhamento médico para dores novas, intensas ou persistentes, em vez de atribuí-las à ovulação.';

  @override
  String get coachOvulation2 =>
      'O humor e a energia social variam. Uma fase prevista não pode determinar como você se sentirá.';

  @override
  String get coachLuteal0 =>
      'Sono, estresse e muitos outros fatores podem afetar os sintomas. Registre o que você percebe.';

  @override
  String get coachLuteal1 =>
      'Escolha refeições e atividades que atendam às suas necessidades. Uma fase prevista não prescreve uma dieta.';

  @override
  String get coachLuteal2 =>
      'As mudanças de humor têm muitas causas possíveis. Procure apoio para sintomas que persistem ou que o preocupam.';

  @override
  String get ovulationConfirmed => 'Possível ovulação';

  @override
  String get ovulationConfirmedInfo =>
      'Um padrão de temperatura ou teste de LH sugere uma possível ovulação. Doença, sono e tempo de medição afetam os resultados. Isto não é uma confirmação clínica e não deve ser usado como contracepção.';

  @override
  String get premiumSection => 'Prêmio';

  @override
  String get removeAds => 'Remover anúncios';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get premiumActive => 'Premium ativo – os anúncios estão desativados';

  @override
  String get storeUnavailable => 'A loja está indisponível no momento';

  @override
  String get healthSync => 'Sincronizar com o Health Connect';

  @override
  String get healthSyncSuccess => 'Dados do período sincronizados';

  @override
  String get healthSyncDenied => 'Permissão de dados de saúde negada';

  @override
  String get healthSyncUnavailable =>
      'Nenhum serviço de saúde neste dispositivo';

  @override
  String get healthSyncFailed => 'Falha na sincronização';

  @override
  String get trackingModeTitle => 'Modo de rastreamento';

  @override
  String get modePeriod => 'Menstruação';

  @override
  String get modePregnancy => 'Gravidez';

  @override
  String get modePill => 'Pílula';

  @override
  String get modeTtc => 'Tentar engravidar';

  @override
  String get lhTestTitle => 'Teste de ovulação (LH)';

  @override
  String get lhPositive => 'Positivo';

  @override
  String get lhNegative => 'Negativo';

  @override
  String get fertilityToday => 'A fertilidade de hoje';

  @override
  String get fertilityHigh => 'Alto';

  @override
  String get fertilityMedium => 'Médio';

  @override
  String get fertilityLow => 'Baixo';

  @override
  String pregnancyWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'Semana $weekString';
  }

  @override
  String get trimester1 => '1º Trimestre';

  @override
  String get trimester2 => '2º Trimestre';

  @override
  String get trimester3 => '3º Trimestre';

  @override
  String get pregnancyDevelopmentTitle => 'Desenvolvimento esta semana';

  @override
  String get pregnancyDevelopment1 =>
      'Um período de rápido desenvolvimento continua à medida que os principais órgãos e sistemas do corpo do seu bebê se formam.';

  @override
  String get pregnancyDevelopment2 =>
      'Os movimentos do seu bebê estão se tornando mais coordenados; quando você os sente pode variar de pessoa para pessoa.';

  @override
  String get pregnancyDevelopment3 =>
      'Seu bebê continua a crescer à medida que a preparação para o nascimento se torna mais proeminente.';

  @override
  String get pregnancyCheckupReminder =>
      'Siga o cronograma de check-up recomendado pelo seu profissional de saúde.';

  @override
  String get pregnancyStartLabel =>
      'Data da última menstruação (início da gravidez)';

  @override
  String get pregnancyModeInfo =>
      'As previsões e lembretes de menstruação estão desativados no modo gravidez';

  @override
  String get pillPackStartLabel => 'Início da embalagem de comprimidos';

  @override
  String pillDayLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Dia da pílula $dayString/21';
  }

  @override
  String pillBreakLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Semana de folga • dia $dayString';
  }

  @override
  String get smartPrediction => 'Previsão Inteligente';

  @override
  String get smartPredictionDesc =>
      'As previsões usam a média aprendida em seus ciclos anteriores';

  @override
  String learnedCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Aprendido: dias $daysString';
  }

  @override
  String get phaseInsights => 'Insights de fase';

  @override
  String get noInsightsYet =>
      'Ainda não há dados suficientes para insights. À medida que você registra os sintomas, padrões baseados em fases aparecerão aqui.';

  @override
  String insightLine(String symptom, String phase, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$symptom ocorre principalmente na fase $phase ($percentString%)';
  }

  @override
  String get notContraceptionWarning =>
      'As previsões são apenas para fins informativos. Este aplicativo NÃO é um método contraceptivo e não deve ser usado para prevenir a gravidez.';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get aboutSection => 'Sobre';

  @override
  String get consentTitle => 'Seus dados e privacidade';

  @override
  String get consentBody =>
      'Todos os seus dados são armazenados criptografados apenas neste dispositivo; nada é enviado para nenhum servidor. Você pode ler a política de privacidade em Configurações > Sobre. Ao continuar você aceita que seus dados sejam processados ​​em seu dispositivo desta forma.';

  @override
  String get consentAccept => 'Eu aceito';

  @override
  String get quickLog => 'Registro rápido';

  @override
  String get shortcutQuickLog => 'Registro rápido';

  @override
  String get shortcutToday => 'Ver hoje';

  @override
  String get allTrackers => 'Todos os tipos de rastreadores';

  @override
  String get disguiseTitle => 'Modo de disfarce';

  @override
  String get disguiseDesc =>
      'O aplicativo assume uma identidade de “Notas”: nome, ícone, widget, notificações e tela de inicialização ficam neutros. Retorno: mantenha pressionado o título das Notas.';

  @override
  String get decoyTitle => 'Notas';

  @override
  String get decoyEmpty => 'Ainda não há notas';

  @override
  String get decoyHint => 'Escreva algo…';

  @override
  String get backupData => 'Criar backup de senha';

  @override
  String get backupPassword => 'Senha de backup';

  @override
  String get backupPasswordConfirm => 'Digite a senha novamente';

  @override
  String get backupPasswordLength => 'A senha deve ter de 10 a 128 caracteres';

  @override
  String get backupPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get backupNoRecovery =>
      'Esta senha não é armazenada no dispositivo e não pode ser recuperada. Se você esquecer, não poderá abrir o backup.';

  @override
  String get unlockBackupTitle => 'Digite a senha de backup';

  @override
  String get unlockBackupBody =>
      'Este backup só pode ser aberto com a senha utilizada quando foi criado.';

  @override
  String get backupPasswordOrFileInvalid =>
      'A senha está incorreta ou o arquivo de backup está danificado.';

  @override
  String get legacyBackupWarning =>
      'Este backup mais antigo não está criptografado. Após restaurá-lo, os novos backups serão protegidos por senha.';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get restoreData => 'Restaurar do backup';

  @override
  String get restoreConfirmTitle => 'Restaurar cópia de segurança?';

  @override
  String restoreConfirmBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Todos os dados atuais serão excluídos e os registros $countString do backup serão restaurados. Isto não pode ser desfeito.';
  }

  @override
  String get restore => 'Restaurar';

  @override
  String get backupRestored => 'Backup restaurado';

  @override
  String get invalidBackupFile => 'Arquivo de backup inválido';

  @override
  String get dateLabel => 'Data';

  @override
  String get modeStepTitle => 'Para que você vai usá-lo?';

  @override
  String get modeStepSubtitle =>
      'Você pode alterar isso mais tarde em Configurações';

  @override
  String get modePeriodDesc => 'Acompanhamento de ciclo e previsões';

  @override
  String get modePregnancyDesc => 'Gravidez semana a semana';

  @override
  String get modePillDesc => 'Cronograma de 21+7 pílulas';

  @override
  String get modeTtcDesc => 'Rastreamento focado na fertilidade';

  @override
  String get paywallTitle => 'Torne-se Premium';

  @override
  String paywallTrialSubtitle(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Sua avaliação está ativa: faltam $daysString dias. Premium mantém tudo desbloqueado.';
  }

  @override
  String get paywallFreeSubtitle =>
      'Seu teste terminou. A versão gratuita mantém o acompanhamento do período e o calendário; rastreamento diário e insights são Premium.';

  @override
  String get paywallFeatureTrackers =>
      'Todos os rastreadores diários: sintomas, humor, água, sono, peso, temperatura, medicação, notas';

  @override
  String get paywallFeatureStats => 'Estatísticas, tendências e o anel Meu Ano';

  @override
  String get paywallFeatureInsights =>
      'Insights pessoais e notificações de dicas de fase';

  @override
  String get paywallFeatureExport => 'Exportação de PDF/CSV';

  @override
  String get paywallFeatureHealth => 'Sincronização do Conexão Saúde';

  @override
  String get paywallFeatureDisguise =>
      'Modo de disfarce com o chamariz de Notas';

  @override
  String get paywallFeatureNoAds => 'Experiência sem anúncios';

  @override
  String get planMonthly => 'Mensalmente';

  @override
  String get planYearly => 'Anualmente';

  @override
  String get perMonth => '/ mês';

  @override
  String get perYear => '/ano';

  @override
  String get bestValue => 'Melhor valor';

  @override
  String get continueFreeBtn => 'Continue com grátis por enquanto';

  @override
  String trialBadge(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Avaliação: $daysString dias restantes';
  }

  @override
  String get freeBadge => 'Versão gratuita';

  @override
  String get freeExplain =>
      'A versão gratuita mantém o acompanhamento do período, o calendário e as previsões. Rastreadores diários, estatísticas, exportação, Health Connect, modo de disfarce e modos são Premium.';

  @override
  String get seePlans => 'Ver Planos';

  @override
  String get premiumLockedTitle => 'Estatísticas são Premium';

  @override
  String get premiumLockedBody =>
      'Gráficos, tendências, insights de fase e o anel My Year são desbloqueados com Premium. Tudo o que você registrou durante o teste é mantido em segurança.';

  @override
  String get yearRingTitle => 'Meu ano';

  @override
  String get yearRingCycles => 'CICLOS';

  @override
  String yearRingSummary(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Últimos 12 meses: ciclos $countString';
  }

  @override
  String get cycleComparison => 'Seu último ciclo';

  @override
  String lastCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Último ciclo: dias $daysString';
  }

  @override
  String lastPeriodLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Último período: dias $daysString';
  }

  @override
  String vsAverageMore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString dias a mais que a média';
  }

  @override
  String vsAverageLess(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString dias mais curtos que a média';
  }

  @override
  String get vsAverageSame => 'igual à sua média';

  @override
  String coachPersonalInsight(String symptom, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Com base nos seus registros, mais comum nesta fase: $symptom ($percentString%)';
  }

  @override
  String get notificationInsightTitle => 'Dica de fase';

  @override
  String notificationInsightBody(String symptom) {
    return 'A fase lútea está começando. Com base nos seus registros, seu sintoma mais comum nesta fase: $symptom.';
  }

  @override
  String get notificationPeriodTitle => 'Lembrete de Período';

  @override
  String get notificationPeriodTimingToday =>
      'Sua menstruação pode começar hoje.';

  @override
  String get notificationPeriodTimingTomorrow =>
      'Sua menstruação pode começar amanhã.';

  @override
  String notificationPeriodTimingInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Sua menstruação pode começar em dias $daysString.';
  }

  @override
  String get notificationPeriodTip1 =>
      'Lembre-se de levar um absorvente ou absorvente interno.';

  @override
  String get notificationPeriodTip2 =>
      'Um pouco de preparação torna tudo mais fácil.';

  @override
  String get notificationPeriodTip3 =>
      'Registrar o início melhora suas previsões.';

  @override
  String get notificationPeriodChannel => 'Lembrete de Período';

  @override
  String get notificationPeriodChannelDesc => 'Lembretes do ciclo menstrual';

  @override
  String get notificationOvulationTitle => 'Lembrete de ovulação';

  @override
  String get notificationOvulationBody =>
      'Hoje é o dia da sua ovulação. Você está na sua janela fértil!';

  @override
  String get notificationOvulationChannel => 'Lembrete de ovulação';

  @override
  String get notificationOvulationChannelDesc => 'Lembretes de ovulação';

  @override
  String get notificationMedicationTitle => 'Lembrete de medicação';

  @override
  String get notificationMedicationBody => 'Não esqueça de tomar seu remédio!';

  @override
  String get notificationMedicationChannel => 'Lembrete de medicação';

  @override
  String get notificationMedicationChannelDesc => 'Lembretes de medicação';

  @override
  String get notificationDiscreetTitle => 'Lembrete';

  @override
  String get notificationDiscreetBody => 'Você tem um lembrete para hoje';

  @override
  String get notificationFertileTitle => 'Sua janela fértil começa';

  @override
  String get notificationFertileBody =>
      'A partir de hoje você está nos dias com maior chance de engravidar.';

  @override
  String get notificationChainEndTitle => 'Os lembretes estão pausando';

  @override
  String get notificationChainEndBody =>
      'Os lembretes programados acabaram. Abra o aplicativo para configurar novos.';

  @override
  String get noPurchasesToRestore => 'Nenhuma compra encontrada para restaurar';

  @override
  String get restoringPurchases => 'Restaurando compras…';

  @override
  String get backdateHint => 'Pressione longamente para um dia diferente';

  @override
  String get periodStartDateHelp => 'Quando começou sua menstruação?';

  @override
  String get periodEndDateHelp => 'Quando terminou sua menstruação?';

  @override
  String get headlinePeriodToday => 'Sua menstruação pode começar hoje';

  @override
  String get headlinePeriodTomorrow => 'Sua menstruação pode começar amanhã';

  @override
  String get headlineNoData => 'Adicione a data da sua última menstruação';

  @override
  String headlinePeriodInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Sua menstruação em dias $daysString';
  }

  @override
  String headlinePeriodDay(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Dia $dayString da sua menstruação';
  }

  @override
  String get headlineDelaySubtitle =>
      'Alguma variação é normal. Registre-o se tiver iniciado.';

  @override
  String get notificationDelayTitle => 'A data prevista já passou';

  @override
  String get notificationDelayBody =>
      'Se a sua menstruação já começou, lembre-se de registrá-la. Alguma variação é normal.';

  @override
  String get notificationDelayBodyAlt1 =>
      'Nenhuma entrada ainda. Se tiver iniciado, o registro leva um toque.';

  @override
  String get notificationDelayBodyAlt2 =>
      'Uma mudança de alguns dias é comum. Seu registro está atualizado?';

  @override
  String get notificationDelayChannel => 'Lembrete de atraso';

  @override
  String get notificationDelayChannelDesc =>
      'Lembrete quando a data prevista tiver passado';

  @override
  String headlineDelay(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Sua menstruação está com $daysString dias atrasada';
  }

  @override
  String delayDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString dias atrasado';
  }

  @override
  String get yourDataStays =>
      'Seus registros permanecerão no seu dispositivo quando a avaliação terminar.';

  @override
  String get periodStartedOnThisDay => 'Minha menstruação começou neste dia';

  @override
  String nCyclesRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Ciclos $countString registrados';
  }

  @override
  String nLogsRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Registros diários $countString';
  }

  @override
  String get notifPermissionTitle => 'Ativar lembretes?';

  @override
  String get notifPermissionBody =>
      'Avisamos quando sua menstruação está próxima, no dia da ovulação e quando a data prevista já passou. As notificações nunca saem do seu dispositivo. Você também pode ativá-los posteriormente nas configurações.';

  @override
  String get enableNotifications => 'Ligar';

  @override
  String get notNow => 'Agora não';

  @override
  String get optionalField => 'Opcional';

  @override
  String get privacyAssurance =>
      'Seus dados permanecem criptografados apenas neste dispositivo';

  @override
  String get privacySummary =>
      'Seus dados principais são criptografados neste dispositivo; ele sai apenas quando você o exporta ou ativa o Health Connect.';

  @override
  String get dontRememberExactly => 'não me lembro exatamente';

  @override
  String get approxTitle => 'Aproximadamente quando foi isso?';

  @override
  String get approxSubtitle =>
      'Uma data difícil é suficiente. As previsões se corrigem automaticamente conforme você registra.';

  @override
  String get approxThisWeek => 'Esta semana';

  @override
  String get approxLastWeek => 'Semana passada';

  @override
  String get approxTwoWeeks => 'Cerca de 2 semanas atrás';

  @override
  String get approxThreeWeeks => 'Cerca de 3 semanas atrás';

  @override
  String get approxMonthOrMore => 'Há um mês ou mais';

  @override
  String get cycleReminderTime => 'Hora do lembrete do ciclo';

  @override
  String get medicationReminderTime => 'Hora do lembrete de medicação';

  @override
  String get periodReminderLead => 'Lembrete de período';

  @override
  String get notificationQuietChannelSuffix => 'quieto';

  @override
  String get quietNotifications => 'Notificações silenciosas';

  @override
  String get quietNotificationsDesc =>
      'Nenhum som ou pop-up – eles esperam silenciosamente na aba de notificações';

  @override
  String get leadSameDay => 'Mesmo dia';

  @override
  String leadNDaysBefore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString dias antes';
  }

  @override
  String get regularityInfoIrregular =>
      'Existem 9 ou mais dias entre o ciclo mais curto e o mais longo. A variação da duração do ciclo é muito comum; estresse, sono, doenças e mudanças na vida afetam isso. Isto não é um diagnóstico.';

  @override
  String get regularityInfoRegular =>
      'A diferença entre o ciclo mais curto e o mais longo é inferior a 9 dias. As previsões são mais precisas com essa consistência.';

  @override
  String get regularityInfoSeeDoctor =>
      'Se o seu ciclo for consistentemente inferior a 21 dias ou superior a 35, se não tiver menstruado durante mais de três meses ou se a hemorragia for invulgarmente intensa, vale a pena falar com um profissional de saúde.';

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

    return 'Faixa comumente aceita: ciclo $minString–$maxString dias, período até $pmaxString dias. Não é um limite de diagnóstico.';
  }

  @override
  String lowConfidenceNote(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Essas médias vêm apenas dos ciclos $countString; eles ficarão mais nítidos à medida que você registrar mais.';
  }

  @override
  String regularityInfoInsufficient(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Pelo menos lacunas no ciclo $countString são necessárias antes que a regularidade signifique alguma coisa. Um julgamento sobre menos seria enganoso.';
  }

  @override
  String get backupNever => 'Você nunca fez um backup.';

  @override
  String get backupStaleHint =>
      'Se você perder seu telefone, os registros não poderão ser recuperados.';

  @override
  String backupLastAt(String date) {
    return 'Último backup: $date';
  }

  @override
  String get durationsStepTitle => 'Detalhes do seu ciclo';

  @override
  String get durationsStepHelp =>
      'Não tenho certeza? Deixe-os como estão – você pode alterá-los nas configurações mais tarde.';

  @override
  String get lockTimeoutTitle => 'Atraso de bloqueio';

  @override
  String get lockTimeoutDesc =>
      'Ignore o PIN quando você voltar após um breve momento de ausência';

  @override
  String get lockImmediately => 'Imediatamente';

  @override
  String get previousDay => 'Dia anterior';

  @override
  String get nextDay => 'Dia seguinte';

  @override
  String get showLegend => 'Chave de cor';

  @override
  String get hideLegend => 'Ocultar chave de cor';

  @override
  String get backToToday => 'De volta a hoje';

  @override
  String get monthNoRecords => 'Nenhum registro neste mês';

  @override
  String get doctorSummary => 'Exportar um resumo para meu médico';

  @override
  String get healthImport => 'Importar do Health Connect';

  @override
  String get healthImportAction => 'Importar';

  @override
  String get allTime => 'Todo o tempo';

  @override
  String get actionPeriodStarted => 'Minha menstruação começou';

  @override
  String get actionMedicationTaken => 'Levado';

  @override
  String get pregnancyTestReady =>
      'Um teste de gravidez pode ser significativo agora';

  @override
  String notLoggedToday(String what) {
    return 'Nenhum $what registrado hoje';
  }

  @override
  String pregnancyTestFrom(String date) {
    return 'Teste útil mais antigo: $date';
  }

  @override
  String pillBreakIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'O intervalo começa em dias $daysString';
  }

  @override
  String pillNewPackIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Novo pacote em dias $daysString';
  }

  @override
  String get healthImportNothingNew =>
      'Nenhum novo registro encontrado para importar';

  @override
  String healthImportConfirm(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Foram encontrados períodos de período $countString no Health Connect que não estão no aplicativo. Adicioná-los aos seus registros? Seus registros existentes permanecem intactos.';
  }

  @override
  String healthImportDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Períodos $countString importados';
  }

  @override
  String monthPeriodDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Dias do período $countString';
  }

  @override
  String monthLoggedDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString dias registrados';
  }

  @override
  String get pinNoRecoveryWarning =>
      'Se você esquecer seu PIN, não há como recuperá-lo; a única maneira de voltar é excluindo todos os seus dados. Escolha algo que você vai lembrar.';

  @override
  String lockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Após $minutesString min';
  }

  @override
  String get reportTitle => 'Relatório de saúde do ciclo';

  @override
  String get reportGenerated => 'Gerado';

  @override
  String get profileSummary => 'Resumo do perfil';

  @override
  String get periodHistory => 'Histórico do período';

  @override
  String get last30DaysSummary => 'Resumo dos últimos 30 dias';

  @override
  String get durationDaysHeader => 'Duração (dias)';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Luz';

  @override
  String get themeDark => 'Escuro';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get statsSectionOverview => 'VISÃO GERAL';

  @override
  String get statsSectionCharts => 'GRÁFICOS';

  @override
  String get statsSectionHistory => 'HISTÓRIA E TENDÊNCIAS';

  @override
  String storySymptomsMore(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'Os últimos 30 dias foram mais difíceis do que o período anterior (entradas $recentString vs $previousString).';
  }

  @override
  String storySymptomsLess(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'Os últimos 30 dias foram mais fáceis do que o período anterior (entradas $recentString vs $previousString).';
  }

  @override
  String get storySymptomsSame =>
      'A intensidade dos sintomas permaneceu semelhante nos dois últimos períodos.';

  @override
  String storyTrendUp(String delta, String unit) {
    return 'Aumentou $delta $unit durante este período.';
  }

  @override
  String storyTrendDown(String delta, String unit) {
    return 'Down $delta $unit durante este período.';
  }

  @override
  String get storyTrendFlat =>
      'Nenhuma mudança significativa durante este período – a tendência é plana.';

  @override
  String averageSeverity(String value) {
    return 'Média $value/5';
  }

  @override
  String get dataCoverage => 'Cobertura de dados';

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

    return 'Dados em $loggedString de dias $totalString ($percentString%)';
  }

  @override
  String get tapChartPointHint => 'Toque em um ponto para abrir naquele dia.';

  @override
  String get shareCalendarMonth => 'Compartilhe o mês do calendário';

  @override
  String get longPressDayHint =>
      'Pressione e segure um dia para uma visualização rápida.';

  @override
  String get markPeriodRange => 'Marcar datas da menstruação';

  @override
  String get periodRangeOverlap =>
      'Estas datas se sobrepõem a uma menstruação registrada.';

  @override
  String get periodRangeSaved => 'Datas da menstruação salvas';

  @override
  String trackingStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString dias seguidos de registros';
  }

  @override
  String weeklyTracking(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/7 dias registrados';
  }

  @override
  String get exportCalendarFile => 'Exportar calendário (.ics)';

  @override
  String get ovulationMarkerHint =>
      'Linha tracejada: ovulação estimada ou confirmada';

  @override
  String get addPastCycles => 'Adicionar ciclos anteriores';

  @override
  String get addPastCyclesHint =>
      'Selecione até 3 intervalos de datas da menstruação e salve-os juntos.';

  @override
  String get addPeriodRange => 'Adicionar datas da menstruação';

  @override
  String get cycleOverlayTitle => 'Comparação de ciclo';

  @override
  String get symptomLoadComparison =>
      'Gravidade diária dos sintomas alinhada por dia do ciclo';

  @override
  String get currentCycleLabel => 'Este ciclo';

  @override
  String get previousCycleLabel => 'Ciclo anterior';

  @override
  String get colorBlindPattern => 'Cores de fase padronizadas';

  @override
  String get colorBlindPatternDesc =>
      'Adiciona textura às faixas de fase – útil quando as cores são difíceis de distinguir';

  @override
  String get undo => 'Desfazer';

  @override
  String get periodMarkedStarted => 'Início da menstruação salvo';

  @override
  String get periodMarkedEnded => 'Fim da menstruação salvo';

  @override
  String get editPeriodRecord => 'Editar registro menstrual';

  @override
  String get startDateLabel => 'Começar';

  @override
  String get endDateLabel => 'Fim';

  @override
  String get recordUpdated => 'Registro atualizado';

  @override
  String get dataResetTitle => 'Não foi possível ler seus dados';

  @override
  String get dataResetBody =>
      'Não foi possível descriptografar os dados do app neste dispositivo. Isso geralmente acontece após trocar de telefone ou restaurar um backup do sistema: os dados são criptografados com uma chave específica do dispositivo que não pode ser movida para um novo dispositivo. O aplicativo começou do zero.\n\nPara mover seus dados entre dispositivos, exporte um backup JSON regularmente em Configurações > Fazer backup de dados.';

  @override
  String get pinSet => 'PIN definido com sucesso';

  @override
  String get pinRemoved => 'PIN removido';

  @override
  String get unlockWithBiometric =>
      'Desbloquear com impressão digital ou rosto';

  @override
  String get biometricNotAvailable =>
      'Autenticação biométrica não disponível neste dispositivo';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get profileSaved => 'Perfil salvo';

  @override
  String sleepDurationShort(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '${hoursString}h ${minutesString}min';
  }

  @override
  String get deleteAllDataConfirm =>
      'Tem certeza de que deseja excluir todos os dados? Esta ação não pode ser desfeita.';

  @override
  String get dataDeleted => 'Todos os dados excluídos';

  @override
  String get doseHint => 'por exemplo 500mg';

  @override
  String get menstrualPhaseInfo =>
      'O período em que ocorre o sangramento menstrual. Geralmente dura de 3 a 7 dias. O corpo elimina o revestimento uterino.';

  @override
  String get follicularPhaseInfo =>
      'Após a menstruação, os ovários preparam um novo óvulo. O estrogênio aumenta e os níveis de energia aumentam.';

  @override
  String get ovulationPhaseInfo =>
      'A fase em que um óvulo é liberado do ovário. A probabilidade de gravidez é máxima.';

  @override
  String get lutealPhaseInfo =>
      'A fase da ovulação até a próxima menstruação. A progesterona aumenta, podem ocorrer sintomas de TPM.';

  @override
  String get fertileWindowInfo =>
      'O período com maior chance de gravidez. Começa 5 dias antes da ovulação e termina 1 dia depois.';

  @override
  String get ovulationCardInfo =>
      'O dia estimado em que um óvulo é liberado do ovário. Ocorre no meio do ciclo.';

  @override
  String get nextPeriodInfo =>
      'A data estimada de início da sua próxima menstruação. Calculado com base na duração do seu ciclo.';

  @override
  String get phaseInfoTitle => 'O que é essa fase?';

  @override
  String get learnMore => 'Informações';

  @override
  String get healthDisclaimer =>
      'Este aplicativo não substitui o aconselhamento médico. Consulte um profissional de saúde para questões de saúde.';

  @override
  String get homePriority => 'Prioridade da tela inicial';

  @override
  String get cycleFirst => 'Priorizar o ciclo';

  @override
  String get todayFirst => 'Hoje primeiro';

  @override
  String get planLifetime => 'Vitalício';

  @override
  String get planLifetimeDetail => 'Um pagamento, Premium para sempre';

  @override
  String get cycleNotificationFrequency => 'Nível de notificação de ciclo';

  @override
  String get cycleNotificationFrequencyDesc =>
      'Lembretes de medicação não são afetados';

  @override
  String get notificationFrequencyEssential => 'Essencial';

  @override
  String get notificationFrequencyBalanced => 'Equilibrado';

  @override
  String get notificationFrequencyDetailed => 'Detalhado';

  @override
  String get readOnlyHistoryNotice =>
      'Você pode ver suas entradas anteriores; novas entradas e alterações diárias exigem Premium.';

  @override
  String get screenProtectionTitle => 'Proteção de tela';

  @override
  String get screenProtectionDescription =>
      'Bloqueia capturas de tela e a prévia dos aplicativos recentes.';

  @override
  String get predictionUncertain => 'Fase do ciclo incerta';

  @override
  String get startupRecoveryBody =>
      'Seus dados não puderam ser abertos com segurança. Foi preservado. Tente novamente ou feche o aplicativo e entre em contato com o suporte. Não reinstale antes de recuperar seu backup.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get adPrivacyOptions => 'Opções de privacidade de publicidade';

  @override
  String get policyAvailableEnglish =>
      'Esta política está disponível em inglês. Segue o texto original da política.';

  @override
  String get purchasePending => 'Aguardando confirmação de pagamento';

  @override
  String get purchaseVerifying => 'Verificando sua compra';

  @override
  String get purchaseFailed =>
      'Não foi possível verificar sua compra. Tente novamente ou restaure as compras.';

  @override
  String get pillSchedule => 'Cronograma de pílulas';

  @override
  String get pillContinuous => 'Contínuo (sem interrupção)';

  @override
  String get predictionRange => 'Período estimado';

  @override
  String get analyticsChoice => 'Medição de uso (opcional)';

  @override
  String get analyticsChoiceDescription =>
      'Opcional. Conta apenas ações de aplicativos neste dispositivo. Dados de saúde, notas, datas e identidade estão excluídos. Nada é carregado sem um serviço configurado.';

  @override
  String get reportRange => 'Período do relatório';

  @override
  String get allHistory => 'Toda a história';

  @override
  String get pillActiveDaysTitle => 'Dias de pílula ativa (1–120)';

  @override
  String get pillBreakDaysTitle => 'Dias de intervalo ou placebo (0–14)';

  @override
  String get pillPrescriptionNote =>
      'Use apenas o cronograma de sua prescrição ou instruções do médico. Esta configuração não recomenda a troca de medicação.';
}
