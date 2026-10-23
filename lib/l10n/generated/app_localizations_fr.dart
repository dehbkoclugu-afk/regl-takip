// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Suivi des Règles';

  @override
  String get home => 'Accueil';

  @override
  String get calendar => 'Calendrier';

  @override
  String get log => 'Journal';

  @override
  String get statistics => 'Statistiques';

  @override
  String get settings => 'Réglages';

  @override
  String get profile => 'Profil';

  @override
  String get onboardingWelcome => 'Bienvenue !';

  @override
  String get onboardingWelcomeDesc =>
      'La façon la plus simple de suivre votre santé';

  @override
  String get onboardingTitle1 => 'Suivez votre cycle';

  @override
  String get onboardingDesc1 =>
      'Notez facilement vos règles et prévoyez les prochaines.';

  @override
  String get onboardingTitle2 => 'Veillez sur votre santé';

  @override
  String get onboardingDesc2 =>
      'Suivez symptômes, humeur, température et plus encore.';

  @override
  String get onboardingTitle3 => 'Consultez vos analyses';

  @override
  String get onboardingDesc3 =>
      'Comprenez votre cycle grâce à des graphiques et statistiques détaillés.';

  @override
  String get onboardingTitle4 => 'Recevez des notifications';

  @override
  String get onboardingDesc4 =>
      'Rappels pour vos règles et vos jours d\'ovulation.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Passer';

  @override
  String get back => 'Retour';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get done => 'Terminé';

  @override
  String get maybeLater => 'Configurer plus tard';

  @override
  String get enableBiometric => 'Empreinte / reconnaissance faciale';

  @override
  String get enablePin => 'Verrouiller par code PIN';

  @override
  String get securitySetup => 'Configuration de sécurité';

  @override
  String get securitySetupDesc => 'Voulez-vous verrouiller l\'application ?';

  @override
  String get enterName => 'Saisissez votre prénom';

  @override
  String get name => 'Prénom';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get lastPeriodDate => 'Date des dernières règles';

  @override
  String get averageCycleLength => 'Durée moyenne du cycle';

  @override
  String get averagePeriodLength => 'Durée moyenne des règles';

  @override
  String get days => 'jours';

  @override
  String get day => 'jour';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get cycleDay => 'Jour du cycle';

  @override
  String get periodIn => 'Règles dans';

  @override
  String daysLeft(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString jours restants',
    );
    return '$_temp0';
  }

  @override
  String get periodToday => 'Vos règles peuvent commencer aujourd\'hui';

  @override
  String get periodOngoing => 'Vous avez vos règles';

  @override
  String get ovulationDay => 'Jour d\'ovulation';

  @override
  String get fertileWindow => 'Fenêtre fertile';

  @override
  String get lutealPhase => 'Phase lutéale';

  @override
  String get follicularPhase => 'Phase folliculaire';

  @override
  String get periodPhase => 'Phase menstruelle';

  @override
  String get logPeriod => 'Noter les règles';

  @override
  String get periodStarted => 'Règles commencées';

  @override
  String get periodEnded => 'Règles terminées';

  @override
  String get flowIntensity => 'Abondance du flux';

  @override
  String get light => 'Léger';

  @override
  String get medium => 'Moyen';

  @override
  String get heavy => 'Abondant';

  @override
  String get veryHeavy => 'Très abondant';

  @override
  String get spotting => 'Spotting';

  @override
  String get symptoms => 'Symptômes';

  @override
  String get mood => 'Humeur';

  @override
  String get temperature => 'Température';

  @override
  String get weight => 'Poids';

  @override
  String get waterIntake => 'Eau';

  @override
  String get sleep => 'Sommeil';

  @override
  String get sexualActivity => 'Activité sexuelle';

  @override
  String get medication => 'Médicaments';

  @override
  String get notes => 'Notes';

  @override
  String get cramps => 'Crampes';

  @override
  String get headache => 'Maux de tête';

  @override
  String get bloating => 'Ballonnements';

  @override
  String get breastTenderness => 'Seins sensibles';

  @override
  String get backPain => 'Mal de dos';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get nausea => 'Nausées';

  @override
  String get dizziness => 'Vertiges';

  @override
  String get stress => 'Stress';

  @override
  String get anxiety => 'Anxiété';

  @override
  String get irritability => 'Irritabilité';

  @override
  String get crying => 'Pleurs';

  @override
  String get sensitivity => 'Sensibilité';

  @override
  String get acne => 'Acné';

  @override
  String get oilySkin => 'Peau grasse';

  @override
  String get drySkin => 'Peau sèche';

  @override
  String get constipation => 'Constipation';

  @override
  String get diarrhea => 'Diarrhée';

  @override
  String get gas => 'Gaz';

  @override
  String get increasedAppetite => 'Appétit accru';

  @override
  String get decreasedAppetite => 'Appétit réduit';

  @override
  String get insomnia => 'Insomnie';

  @override
  String get hotFlash => 'Bouffées de chaleur';

  @override
  String get swelling => 'Rétention d\'eau';

  @override
  String get hairLoss => 'Chute de cheveux';

  @override
  String get happy => 'Heureuse';

  @override
  String get sad => 'Triste';

  @override
  String get angry => 'En colère';

  @override
  String get anxious => 'Anxieuse';

  @override
  String get calm => 'Calme';

  @override
  String get energetic => 'Énergique';

  @override
  String get tired => 'Fatiguée';

  @override
  String get romantic => 'Romantique';

  @override
  String get confused => 'Perdue';

  @override
  String get confident => 'Confiante';

  @override
  String get avgCycleLength => 'Cycle moyen';

  @override
  String get avgPeriodLength => 'Règles moyennes';

  @override
  String get cycleHistory => 'Historique des cycles';

  @override
  String get symptomFrequency => 'Fréquence des symptômes';

  @override
  String get moodDistribution => 'Répartition de l\'humeur';

  @override
  String get temperatureTrend => 'Courbe de température';

  @override
  String get weightTrend => 'Courbe de poids';

  @override
  String get last3Months => '3 derniers mois';

  @override
  String get last6Months => '6 derniers mois';

  @override
  String get last12Months => '12 derniers mois';

  @override
  String get exportData => 'Exporter les données';

  @override
  String get exportPdf => 'Rapport PDF';

  @override
  String get exportCsv => 'Fichier CSV';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get lightTheme => 'Thème clair';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get notifications => 'Notifications';

  @override
  String get periodReminder => 'Rappel des règles';

  @override
  String get ovulationReminder => 'Rappel d\'ovulation';

  @override
  String get medicationReminder => 'Rappel de médicaments';

  @override
  String get waterReminder => 'Rappel d\'hydratation';

  @override
  String get security => 'Sécurité';

  @override
  String get pinLock => 'Verrouillage PIN';

  @override
  String get biometricLock => 'Verrouillage biométrique';

  @override
  String get dataBackup => 'Sauvegarde des données';

  @override
  String get deleteAllData => 'Supprimer toutes les données';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get glasses => 'verres';

  @override
  String get dailyGoal => 'Objectif quotidien';

  @override
  String get sleepQuality => 'Qualité du sommeil';

  @override
  String get bedTime => 'Coucher';

  @override
  String get wakeTime => 'Réveil';

  @override
  String get totalSleep => 'Sommeil total';

  @override
  String get hours => 'heures';

  @override
  String get protection => 'Protection';

  @override
  String get condom => 'Préservatif';

  @override
  String get pill => 'Pilule';

  @override
  String get iud => 'Stérilet';

  @override
  String get none => 'Aucune';

  @override
  String get other => 'Autre';

  @override
  String get medicationName => 'Nom du médicament';

  @override
  String get dose => 'Dose';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String get taken => 'Pris';

  @override
  String get notTaken => 'Non pris';

  @override
  String get addNote => 'Ajouter une note';

  @override
  String get selectDate => 'Choisir une date';

  @override
  String get noDataYet => 'Pas encore de données';

  @override
  String get predictions => 'Prévisions';

  @override
  String get nextPeriod => 'Prochaines règles';

  @override
  String get nextOvulation => 'Prochaine ovulation';

  @override
  String get cycleRegularity => 'Régularité du cycle';

  @override
  String get regular => 'Régulier';

  @override
  String get irregular => 'Irrégulier';

  @override
  String get setupComplete => 'Configuration terminée !';

  @override
  String get letsStart => 'C\'est parti';

  @override
  String get bmi => 'IMC';

  @override
  String get goalReached => 'Objectif atteint !';

  @override
  String get helloGeneric => 'Bonjour !';

  @override
  String get dayHasRecord => 'contient un enregistrement';

  @override
  String get increase => 'Augmenter';

  @override
  String get decrease => 'Diminuer';

  @override
  String get bbtHint =>
      'Pour une mesure fiable, prenez votre température au réveil, avant de vous lever, à la même heure chaque jour. La confirmation de l\'ovulation repose sur ces mesures.';

  @override
  String get deleteMeasurement => 'Supprimer la mesure';

  @override
  String get measurementDeleted => 'Mesure supprimée';

  @override
  String get deleteRecord => 'Supprimer l\'enregistrement';

  @override
  String get recordDeleted => 'Enregistrement supprimé';

  @override
  String get invalidWeight => 'Saisissez un poids valide (20-300 kg)';

  @override
  String get invalidTemperature =>
      'Saisissez une température valide (35-40 °C)';

  @override
  String get discardChangesTitle => 'Modifications non enregistrées';

  @override
  String get discardChangesBody =>
      'Votre note n\'est pas enregistrée. Si vous quittez maintenant, elle sera perdue.';

  @override
  String get discard => 'Abandonner';

  @override
  String severityLevel(int level) {
    final intl.NumberFormat levelNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String levelString = levelNumberFormat.format(level);

    return 'intensité $levelString/5';
  }

  @override
  String get pregnancySetStartPrompt =>
      'Touchez pour définir le début de la grossesse';

  @override
  String helloName(String name) {
    return 'Bonjour, $name !';
  }

  @override
  String get ovulationPhase => 'Phase d\'ovulation';

  @override
  String get menstrualPhase => 'Phase menstruelle';

  @override
  String get todaySummary => 'Résumé du jour';

  @override
  String get howAreYouFeeling => 'Comment vous sentez-vous aujourd\'hui ?';

  @override
  String get logMoodAndSymptoms => 'Notez votre humeur et vos symptômes';

  @override
  String get addRecord => 'Ajouter';

  @override
  String nSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString symptômes',
    );
    return '$_temp0';
  }

  @override
  String get periodDayLabel => 'Jour de règles';

  @override
  String get predicted => 'Prévu';

  @override
  String get fertile => 'Fertile';

  @override
  String get ovulation => 'Ovulation';

  @override
  String moodLabel(String mood) {
    return 'Humeur : $mood';
  }

  @override
  String nGlassesWater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString verres d\'eau';
  }

  @override
  String get noRecordForDay => 'Aucun enregistrement pour ce jour.';

  @override
  String get dailyLog => 'Journal quotidien';

  @override
  String get dailyMeasurements => 'Mesures quotidiennes';

  @override
  String get flow => 'Flux';

  @override
  String get recorded => 'Enregistré';

  @override
  String nMedications(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString médicaments',
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
      other: '$countString verres',
    );
    return '$_temp0';
  }

  @override
  String get flowTracking => 'Suivi du flux';

  @override
  String get color => 'Couleur';

  @override
  String get lightRed => 'Rouge clair';

  @override
  String get red => 'Rouge';

  @override
  String get darkRed => 'Foncé';

  @override
  String get brown => 'Marron';

  @override
  String get clots => 'Caillots';

  @override
  String get clotsQuestion => 'Des caillots ?';

  @override
  String get padChange => 'Changements de protection';

  @override
  String get flowSaved => 'Flux enregistré';

  @override
  String get symptomTracking => 'Suivi des symptômes';

  @override
  String get physical => 'Physiques';

  @override
  String get emotional => 'Émotionnels';

  @override
  String get skinCategory => 'Peau';

  @override
  String get digestive => 'Digestifs';

  @override
  String get otherCategory => 'Autres';

  @override
  String get glowingSkin => 'Peau éclatante';

  @override
  String saveNSymptoms(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Enregistrer ($countString symptômes)';
  }

  @override
  String nSymptomsSaved(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString symptômes enregistrés';
  }

  @override
  String get addNoteOptional => 'Ajouter une note (facultatif)';

  @override
  String get writeAboutToday => 'Écrivez quelque chose sur aujourd\'hui...';

  @override
  String get moodSaved => 'Humeur enregistrée';

  @override
  String get sensitiveM => 'Sensible';

  @override
  String get irritableM => 'Irritable';

  @override
  String get neutralM => 'Neutre';

  @override
  String get lowTemp => 'Basse';

  @override
  String get normalTemp => 'Normale';

  @override
  String get highTemp => 'Élevée';

  @override
  String get fever => 'Fièvre';

  @override
  String get measurementTime => 'Heure de la mesure';

  @override
  String get temperatureSaved => 'Température enregistrée';

  @override
  String get quickAdjust => 'Réglage rapide';

  @override
  String get manualEntry => 'Saisie manuelle';

  @override
  String get weightSaved => 'Poids enregistré';

  @override
  String get waterTracking => 'Suivi de l\'eau';

  @override
  String get waterSaved => 'Eau enregistrée';

  @override
  String get sleepTracking => 'Suivi du sommeil';

  @override
  String get bedTimeLabel => 'Coucher';

  @override
  String get wakeTimeLabel => 'Réveil';

  @override
  String get veryBad => 'Très mauvais';

  @override
  String get bad => 'Mauvais';

  @override
  String get moderate => 'Moyen';

  @override
  String get good => 'Bon';

  @override
  String get great => 'Excellent';

  @override
  String get sleepSaved => 'Sommeil enregistré';

  @override
  String get protectionMethod => 'Méthode de protection';

  @override
  String get orgasm => 'Orgasme';

  @override
  String get noteOptional => 'Note (facultatif)';

  @override
  String get addNoteHint => 'Ajouter une note...';

  @override
  String get savedGeneric => 'Enregistré';

  @override
  String get medicationTracking => 'Suivi des médicaments';

  @override
  String get addMedication => 'Ajouter un médicament';

  @override
  String get noMedicationsYet => 'Aucun médicament pour l\'instant';

  @override
  String get medicationPlanHint =>
      'Ce plan s\'applique chaque jour. La case enregistre uniquement le jour sélectionné.';

  @override
  String get medicationAlreadyInPlan =>
      'Ce médicament figure déjà dans le plan';

  @override
  String get tapToAdd => 'Touchez + pour ajouter';

  @override
  String get add => 'Ajouter';

  @override
  String get dailyNote => 'Note du jour';

  @override
  String get myNotes => 'Mes notes';

  @override
  String get notesHint => 'Comment vous sentez-vous ? Écrivez vos notes ici...';

  @override
  String get noteSaved => 'Note enregistrée';

  @override
  String get cycleOverview => 'Aperçu du cycle';

  @override
  String get avgCycle => 'Cycle moyen';

  @override
  String get avgPeriod => 'Règles moyennes';

  @override
  String get regularity => 'Régularité';

  @override
  String get insufficientData => 'Données insuffisantes';

  @override
  String get noSymptomData => 'Pas encore de données de symptômes';

  @override
  String get noMoodData => 'Pas encore de données d\'humeur';

  @override
  String get noCycleData => 'Pas encore de données de cycle';

  @override
  String get ongoing => 'en cours';

  @override
  String nDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString jours',
    );
    return '$_temp0';
  }

  @override
  String get profileSection => 'Profil';

  @override
  String get preferences => 'Préférences';

  @override
  String get age => 'Âge';

  @override
  String nYearsOld(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ans',
    );
    return '$_temp0';
  }

  @override
  String get cycleDuration => 'Durée du cycle';

  @override
  String get periodDuration => 'Durée des règles';

  @override
  String get dataSection => 'Données';

  @override
  String get exportPdfReport => 'Exporter le rapport PDF';

  @override
  String get exportCsvFile => 'Exporter en CSV';

  @override
  String get pdfExportSoon => 'Export PDF bientôt disponible !';

  @override
  String get csvExportSoon => 'Export CSV bientôt disponible !';

  @override
  String get letsKnowYou => 'Faisons connaissance';

  @override
  String get whatShouldWeCallYou => 'Comment devons-nous vous appeler ?';

  @override
  String get yourName => 'Votre prénom';

  @override
  String get yourBirthDate => 'Votre date de naissance';

  @override
  String get birthDateHelp =>
      'Nous aide à proposer des conseils adaptés à votre âge.';

  @override
  String get selectDateHint => 'Choisir une date';

  @override
  String get selectDateToContinue => 'Choisissez une date pour continuer';

  @override
  String stepOfSteps(int current, int total) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Étape $currentString sur $totalString';
  }

  @override
  String get lastPeriodTitle => 'Vos dernières règles';

  @override
  String get lastPeriodHelp =>
      'Choisissez la date de début de vos dernières règles.';

  @override
  String get cycleLengthTitle => 'Durée du cycle';

  @override
  String get cycleLengthHelp =>
      'Combien de jours dure votre cycle en moyenne ?\n(Du premier jour des règles au premier jour des suivantes)';

  @override
  String get periodLengthTitle => 'Durée des règles';

  @override
  String get periodLengthHelp =>
      'Combien de jours durent vos règles habituellement ?';

  @override
  String get averageLabel => 'moyenne';

  @override
  String get completeBtn => 'Terminer';

  @override
  String get continueBtn => 'Continuer';

  @override
  String errorOccurred(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get welcomeInfoTitle => 'Bienvenue !';

  @override
  String get welcomeInfoDesc =>
      'La façon la plus simple et la plus agréable de suivre votre santé. Nous vous accompagnons à chaque étape de votre cycle.';

  @override
  String get trackCycleTitle => 'Suivez votre cycle';

  @override
  String get trackCycleDesc =>
      'Notez facilement vos dates de règles, symptômes et humeur. Toutes vos données sont en sécurité.';

  @override
  String get getPredictionsTitle => 'Recevez des prévisions';

  @override
  String get getPredictionsDesc =>
      'Découvrez votre prochain cycle et vos jours fertiles grâce aux prévisions intelligentes.';

  @override
  String get startBtn => 'Commencer';

  @override
  String daysLater(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'dans $countString jours';
  }

  @override
  String get todayExclamation => 'Aujourd\'hui !';

  @override
  String get spiral => 'Stérilet';

  @override
  String get enterPin => 'Saisir le code PIN';

  @override
  String get createPin => 'Créer un code PIN';

  @override
  String get confirmPin => 'Confirmer le code PIN';

  @override
  String get pinMismatch => 'Les codes PIN ne correspondent pas, réessayez';

  @override
  String get verifyPinTitle => 'Saisissez votre code PIN actuel';

  @override
  String get wrongPin => 'Code PIN incorrect';

  @override
  String tooManyAttempts(int seconds) {
    final intl.NumberFormat secondsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String secondsString = secondsNumberFormat.format(seconds);

    return 'Trop de tentatives. Attendez $secondsString secondes';
  }

  @override
  String get coachMenstrual0 =>
      'Vous pouvez enregistrer les saignements, la douleur et ce que vous ressentez. Demandez un avis médical pour les symptômes qui vous préoccupent.';

  @override
  String get coachMenstrual1 =>
      'Si cela est confortable, un mouvement doux ou de la chaleur peut vous aider à vous sentir mieux. Les expériences individuelles varient.';

  @override
  String get coachMenstrual2 =>
      'Choisissez le repos ou l’activité en fonction de ce que vous ressentez aujourd’hui.';

  @override
  String get coachFollicular0 =>
      'L\'énergie et les symptômes varient selon les personnes et les cycles. Utilisez vos propres enregistrements pour remarquer des tendances.';

  @override
  String get coachFollicular1 =>
      'Votre peau peut changer au cours du cycle. Enregistrez les changements plutôt que de supposer un modèle fixe.';

  @override
  String get coachFollicular2 =>
      'Choisissez l\'exercice en fonction de votre santé et de votre confort, et non d\'une phase de cycle prévue.';

  @override
  String get coachOvulation0 =>
      'Les jours fertiles sont des estimations. Cette application n\'est pas une méthode contraceptive.';

  @override
  String get coachOvulation1 =>
      'Consultez un médecin en cas de douleur nouvelle, intense ou persistante au lieu de l\'attribuer à l\'ovulation.';

  @override
  String get coachOvulation2 =>
      'L’humeur et l’énergie sociale varient. Une phase prévue ne peut pas déterminer ce que vous ressentirez.';

  @override
  String get coachLuteal0 =>
      'Le sommeil, le stress et bien d’autres facteurs peuvent affecter les symptômes. Enregistrez ce que vous remarquez.';

  @override
  String get coachLuteal1 =>
      'Choisissez des repas et des activités adaptés à vos besoins. Une phase prévue ne prescrit pas de régime.';

  @override
  String get coachLuteal2 =>
      'Les changements d’humeur ont de nombreuses causes possibles. Recherchez de l’aide pour les symptômes qui persistent ou vous préoccupent.';

  @override
  String get ovulationConfirmed => 'Possibilité d\'ovulation';

  @override
  String get ovulationConfirmedInfo =>
      'Un profil de température ou un test LH suggère une ovulation possible. La maladie, le sommeil et le moment des mesures affectent les résultats. Ceci n’est pas une confirmation clinique et ne doit pas être utilisé à des fins de contraception.';

  @override
  String get premiumSection => 'Premium';

  @override
  String get removeAds => 'Supprimer les publicités';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get premiumActive => 'Premium actif — publicités désactivées';

  @override
  String get storeUnavailable => 'Boutique momentanément indisponible';

  @override
  String get healthSync => 'Synchroniser avec Health Connect';

  @override
  String get healthSyncSuccess => 'Données de règles synchronisées';

  @override
  String get healthSyncDenied => 'Autorisation des données de santé refusée';

  @override
  String get healthSyncUnavailable => 'Aucun service de santé sur cet appareil';

  @override
  String get healthSyncFailed => 'Échec de la synchronisation';

  @override
  String get trackingModeTitle => 'Mode de suivi';

  @override
  String get modePeriod => 'Règles';

  @override
  String get modePregnancy => 'Grossesse';

  @override
  String get modePill => 'Pilule';

  @override
  String get modeTtc => 'Conception';

  @override
  String get lhTestTitle => 'Test d\'ovulation (LH)';

  @override
  String get lhPositive => 'Positif';

  @override
  String get lhNegative => 'Négatif';

  @override
  String get fertilityToday => 'Fertilité du jour';

  @override
  String get fertilityHigh => 'Élevée';

  @override
  String get fertilityMedium => 'Moyenne';

  @override
  String get fertilityLow => 'Faible';

  @override
  String pregnancyWeekLabel(int week) {
    final intl.NumberFormat weekNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String weekString = weekNumberFormat.format(week);

    return 'Semaine $weekString';
  }

  @override
  String get trimester1 => '1er trimestre';

  @override
  String get trimester2 => '2e trimestre';

  @override
  String get trimester3 => '3e trimestre';

  @override
  String get pregnancyDevelopmentTitle => 'Développement cette semaine';

  @override
  String get pregnancyDevelopment1 =>
      'Une période de développement rapide se poursuit pendant la formation des principaux organes et systèmes de votre bébé.';

  @override
  String get pregnancyDevelopment2 =>
      'Les mouvements de votre bébé deviennent plus coordonnés ; le moment où vous les ressentez varie selon les personnes.';

  @override
  String get pregnancyDevelopment3 =>
      'Votre bébé continue de grandir tandis que la préparation à la naissance prend de l\'importance.';

  @override
  String get pregnancyCheckupReminder =>
      'Suivez le calendrier de consultations recommandé par votre professionnel de santé.';

  @override
  String get pregnancyStartLabel => 'Dernières règles (début de grossesse)';

  @override
  String get pregnancyModeInfo =>
      'En mode grossesse, prévisions et rappels de règles sont désactivés';

  @override
  String get pillPackStartLabel => 'Début de la plaquette';

  @override
  String pillDayLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Pilule jour $dayString/21';
  }

  @override
  String pillBreakLabel(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Semaine de pause • jour $dayString';
  }

  @override
  String get smartPrediction => 'Prévision intelligente';

  @override
  String get smartPredictionDesc =>
      'Les prévisions utilisent la moyenne apprise de vos cycles passés';

  @override
  String learnedCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Appris : $daysString jours';
  }

  @override
  String get phaseInsights => 'Tendances par phase';

  @override
  String get noInsightsYet =>
      'Pas encore assez de données. En notant vos symptômes, des tendances par phase apparaîtront ici.';

  @override
  String insightLine(String symptom, String phase, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '$symptom survient surtout en phase $phase ($percentString%)';
  }

  @override
  String get notContraceptionWarning =>
      'Les prévisions sont fournies à titre informatif. Cette application n\'est PAS un moyen de contraception et ne doit pas être utilisée pour éviter une grossesse.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutSection => 'À propos';

  @override
  String get consentTitle => 'Vos données et votre vie privée';

  @override
  String get consentBody =>
      'Toutes vos données sont stockées chiffrées uniquement sur cet appareil ; rien n\'est envoyé à un serveur. La politique de confidentialité se trouve dans Réglages > À propos. En continuant, vous acceptez ce traitement sur votre appareil.';

  @override
  String get consentAccept => 'J\'accepte';

  @override
  String get quickLog => 'Saisie rapide';

  @override
  String get shortcutQuickLog => 'Saisie rapide';

  @override
  String get shortcutToday => 'Voir aujourd’hui';

  @override
  String get allTrackers => 'Tous les suivis';

  @override
  String get disguiseTitle => 'Mode camouflage';

  @override
  String get disguiseDesc =>
      'L\'application prend l\'identité « Notes » : nom, icône, widget, notifications et écran de démarrage deviennent neutres. Retour : appui long sur le titre Notes.';

  @override
  String get decoyTitle => 'Notes';

  @override
  String get decoyEmpty => 'Pas encore de notes';

  @override
  String get decoyHint => 'Écrivez quelque chose…';

  @override
  String get backupData => 'Créer une sauvegarde protégée';

  @override
  String get backupPassword => 'Mot de passe de sauvegarde';

  @override
  String get backupPasswordConfirm => 'Saisissez à nouveau le mot de passe';

  @override
  String get backupPasswordLength =>
      'Le mot de passe doit contenir entre 10 et 128 caractères';

  @override
  String get backupPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get backupNoRecovery =>
      'Ce mot de passe n’est pas stocké sur l’appareil et ne peut pas être récupéré. Si vous l’oubliez, vous ne pourrez pas ouvrir la sauvegarde.';

  @override
  String get unlockBackupTitle => 'Saisissez le mot de passe';

  @override
  String get unlockBackupBody =>
      'Cette sauvegarde ne peut être ouverte qu’avec le mot de passe utilisé lors de sa création.';

  @override
  String get backupPasswordOrFileInvalid =>
      'Le mot de passe est incorrect ou le fichier de sauvegarde est endommagé.';

  @override
  String get legacyBackupWarning =>
      'Cette ancienne sauvegarde n’est pas chiffrée. Après sa restauration, les nouvelles sauvegardes seront protégées par mot de passe.';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get restoreData => 'Restaurer une sauvegarde';

  @override
  String get restoreConfirmTitle => 'Restaurer la sauvegarde ?';

  @override
  String restoreConfirmBody(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Toutes les données actuelles seront supprimées et $countString enregistrements de la sauvegarde seront restaurés. Cette action est irréversible.';
  }

  @override
  String get restore => 'Restaurer';

  @override
  String get backupRestored => 'Sauvegarde restaurée';

  @override
  String get invalidBackupFile => 'Fichier de sauvegarde invalide';

  @override
  String get dateLabel => 'Date';

  @override
  String get modeStepTitle => 'Pour quel usage ?';

  @override
  String get modeStepSubtitle => 'Modifiable plus tard dans les Réglages';

  @override
  String get modePeriodDesc => 'Suivi du cycle et prévisions';

  @override
  String get modePregnancyDesc => 'Grossesse semaine par semaine';

  @override
  String get modePillDesc => 'Schéma pilule 21+7';

  @override
  String get modeTtcDesc => 'Suivi axé sur la fertilité';

  @override
  String get paywallTitle => 'Passer Premium';

  @override
  String paywallTrialSubtitle(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Votre essai est actif : $daysString jours restants. Premium garde tout débloqué.';
  }

  @override
  String get paywallFreeSubtitle =>
      'Votre essai est terminé. La version gratuite conserve le suivi des règles et le calendrier ; le journal quotidien et les analyses sont Premium.';

  @override
  String get paywallFeatureTrackers =>
      'Tous les suivis quotidiens : symptômes, humeur, eau, sommeil, poids, température, médicaments, notes';

  @override
  String get paywallFeatureStats =>
      'Statistiques, tendances et l\'anneau Mon Année';

  @override
  String get paywallFeatureInsights =>
      'Tendances personnelles et conseils par phase';

  @override
  String get paywallFeatureExport => 'Export PDF / CSV';

  @override
  String get paywallFeatureHealth => 'Synchronisation Health Connect';

  @override
  String get paywallFeatureDisguise => 'Mode camouflage avec l\'app Notes';

  @override
  String get paywallFeatureNoAds => 'Sans publicité';

  @override
  String get planMonthly => 'Mensuel';

  @override
  String get planYearly => 'Annuel';

  @override
  String get perMonth => '/mois';

  @override
  String get perYear => '/an';

  @override
  String get bestValue => 'Meilleure offre';

  @override
  String get continueFreeBtn => 'Continuer en gratuit pour l\'instant';

  @override
  String trialBadge(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Essai : $daysString jours restants';
  }

  @override
  String get freeBadge => 'Version gratuite';

  @override
  String get freeExplain =>
      'La version gratuite conserve le suivi des règles, le calendrier et les prévisions. Journal quotidien, statistiques, export, Health Connect, camouflage et modes sont Premium.';

  @override
  String get seePlans => 'Voir les offres';

  @override
  String get premiumLockedTitle => 'Les statistiques sont Premium';

  @override
  String get premiumLockedBody =>
      'Graphiques, tendances, analyses par phase et l\'anneau Mon Année se débloquent avec Premium. Tout ce que vous avez noté pendant l\'essai est conservé.';

  @override
  String get yearRingTitle => 'Mon Année';

  @override
  String get yearRingCycles => 'CYCLES';

  @override
  String yearRingSummary(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '12 derniers mois : $countString cycles';
  }

  @override
  String get cycleComparison => 'Votre dernier cycle';

  @override
  String lastCycleLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Dernier cycle : $daysString jours';
  }

  @override
  String lastPeriodLength(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Dernières règles : $daysString jours';
  }

  @override
  String vsAverageMore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString jours de plus que votre moyenne';
  }

  @override
  String vsAverageLess(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString jours de moins que votre moyenne';
  }

  @override
  String get vsAverageSame => 'identique à votre moyenne';

  @override
  String coachPersonalInsight(String symptom, int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'D\'après vos saisies, le plus fréquent dans cette phase : $symptom ($percentString%)';
  }

  @override
  String get notificationInsightTitle => 'Conseil de phase';

  @override
  String notificationInsightBody(String symptom) {
    return 'La phase lutéale commence. D\'après vos saisies, votre symptôme le plus fréquent dans cette phase : $symptom.';
  }

  @override
  String get notificationPeriodTitle => 'Rappel de règles';

  @override
  String get notificationPeriodTimingToday =>
      'Vos règles pourraient commencer aujourd\'hui.';

  @override
  String get notificationPeriodTimingTomorrow =>
      'Vos règles pourraient commencer demain.';

  @override
  String notificationPeriodTimingInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Vos règles pourraient commencer dans $daysString jours.';
  }

  @override
  String get notificationPeriodTip1 =>
      'Pensez à emporter une serviette ou un tampon.';

  @override
  String get notificationPeriodTip2 =>
      'Un peu de préparation facilite les choses.';

  @override
  String get notificationPeriodTip3 =>
      'Enregistrer le début améliore vos prédictions.';

  @override
  String get notificationPeriodChannel => 'Rappel de règles';

  @override
  String get notificationPeriodChannelDesc => 'Rappels du cycle menstruel';

  @override
  String get notificationOvulationTitle => 'Rappel d\'ovulation';

  @override
  String get notificationOvulationBody =>
      'C\'est votre jour d\'ovulation. Vous êtes dans votre fenêtre fertile !';

  @override
  String get notificationOvulationChannel => 'Rappel d\'ovulation';

  @override
  String get notificationOvulationChannelDesc => 'Rappels d\'ovulation';

  @override
  String get notificationMedicationTitle => 'Rappel de médicament';

  @override
  String get notificationMedicationBody =>
      'N\'oubliez pas de prendre votre médicament !';

  @override
  String get notificationMedicationChannel => 'Rappel de médicament';

  @override
  String get notificationMedicationChannelDesc => 'Rappels de médicaments';

  @override
  String get notificationDiscreetTitle => 'Rappel';

  @override
  String get notificationDiscreetBody =>
      'Vous avez un rappel pour aujourd\'hui';

  @override
  String get notificationFertileTitle => 'Votre fenêtre de fertilité commence';

  @override
  String get notificationFertileBody =>
      'À partir d\'aujourd\'hui, ce sont les jours les plus propices à la conception.';

  @override
  String get notificationChainEndTitle => 'Les rappels sont en pause';

  @override
  String get notificationChainEndBody =>
      'Les rappels programmés sont épuisés. Ouvrez l\'application pour en planifier de nouveaux.';

  @override
  String get noPurchasesToRestore => 'Aucun achat à restaurer';

  @override
  String get restoringPurchases => 'Restauration des achats…';

  @override
  String get backdateHint => 'Appui long pour choisir un autre jour';

  @override
  String get periodStartDateHelp => 'Quand vos règles ont-elles commencé ?';

  @override
  String get periodEndDateHelp => 'Quand vos règles se sont-elles terminées ?';

  @override
  String get headlinePeriodToday => 'Vos règles peuvent commencer aujourd’hui';

  @override
  String get headlinePeriodTomorrow => 'Vos règles peuvent commencer demain';

  @override
  String get headlineNoData => 'Ajoutez la date de vos dernières règles';

  @override
  String headlinePeriodInDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Vos règles dans $daysString jours';
  }

  @override
  String headlinePeriodDay(int day) {
    final intl.NumberFormat dayNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String dayString = dayNumberFormat.format(day);

    return 'Jour $dayString de vos règles';
  }

  @override
  String get headlineDelaySubtitle =>
      'Une variation est normale. Enregistrez-les si elles ont commencé.';

  @override
  String get notificationDelayTitle => 'La date prévue est passée';

  @override
  String get notificationDelayBody =>
      'Si vos règles ont commencé, pensez à les enregistrer. Une variation est normale.';

  @override
  String get notificationDelayBodyAlt1 =>
      'Aucune entrée pour l\'instant. Si elles ont commencé, un appui suffit.';

  @override
  String get notificationDelayBodyAlt2 =>
      'Un décalage de quelques jours est courant. Votre suivi est-il à jour ?';

  @override
  String get notificationDelayChannel => 'Rappel de retard';

  @override
  String get notificationDelayChannelDesc =>
      'Rappel lorsque la date prévue est passée';

  @override
  String headlineDelay(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Vos règles ont $daysString jours de retard';
  }

  @override
  String delayDays(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString jours de retard';
  }

  @override
  String get yourDataStays =>
      'Vos données restent sur votre appareil à la fin de l’essai.';

  @override
  String get periodStartedOnThisDay => 'Mes règles ont commencé ce jour';

  @override
  String nCyclesRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString cycles enregistrés';
  }

  @override
  String nLogsRecorded(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString journaux quotidiens';
  }

  @override
  String get notifPermissionTitle => 'Activer les rappels ?';

  @override
  String get notifPermissionBody =>
      'Nous vous prévenons à l’approche de vos règles, le jour de l’ovulation et quand la date prévue est passée. Les notifications ne quittent jamais votre appareil. Vous pouvez aussi les activer plus tard dans les réglages.';

  @override
  String get enableNotifications => 'Activer';

  @override
  String get notNow => 'Plus tard';

  @override
  String get optionalField => 'Facultatif';

  @override
  String get privacyAssurance =>
      'Vos données restent chiffrées sur cet appareil uniquement';

  @override
  String get privacySummary =>
      'Vos données principales sont chiffrées sur cet appareil; elles n\'en sortent que si vous les exportez ou activez Health Connect.';

  @override
  String get dontRememberExactly => 'Je ne sais plus exactement';

  @override
  String get approxTitle => 'C’était à peu près quand ?';

  @override
  String get approxSubtitle =>
      'Une date approximative suffit. Les prévisions s’ajustent au fil de vos saisies.';

  @override
  String get approxThisWeek => 'Cette semaine';

  @override
  String get approxLastWeek => 'La semaine dernière';

  @override
  String get approxTwoWeeks => 'Il y a environ 2 semaines';

  @override
  String get approxThreeWeeks => 'Il y a environ 3 semaines';

  @override
  String get approxMonthOrMore => 'Il y a un mois ou plus';

  @override
  String get cycleReminderTime => 'Heure des rappels de cycle';

  @override
  String get medicationReminderTime => 'Heure des rappels de médicament';

  @override
  String get periodReminderLead => 'Rappel de règles';

  @override
  String get notificationQuietChannelSuffix => 'silencieux';

  @override
  String get quietNotifications => 'Notifications silencieuses';

  @override
  String get quietNotificationsDesc =>
      'Sans son ni fenêtre contextuelle, uniquement dans le volet des notifications';

  @override
  String get leadSameDay => 'Le jour même';

  @override
  String leadNDaysBefore(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return '$daysString jours avant';
  }

  @override
  String get regularityInfoIrregular =>
      'Il y a 9 jours ou plus entre votre cycle le plus court et le plus long. Une durée de cycle variable est très courante ; le stress, le sommeil, la maladie et les changements de vie y contribuent. Ceci n’est pas un diagnostic.';

  @override
  String get regularityInfoRegular =>
      'L’écart entre votre cycle le plus court et le plus long est inférieur à 9 jours. Les prévisions sont plus fiables avec cette régularité.';

  @override
  String get regularityInfoSeeDoctor =>
      'Si votre cycle est constamment plus court que 21 jours ou plus long que 35, si vous n’avez pas eu de règles depuis plus de trois mois, ou si les saignements sont inhabituellement abondants, il vaut mieux consulter un professionnel de santé.';

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

    return 'Plage courante : cycle $minString–$maxString jours, règles jusqu’à $pmaxString jours. Ce n’est pas un seuil diagnostique.';
  }

  @override
  String lowConfidenceNote(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Ces moyennes proviennent de seulement $countString cycles ; elles s’affineront avec vos saisies.';
  }

  @override
  String regularityInfoInsufficient(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Il faut au moins $countString intervalles de cycle pour parler de régularité. En dessous, le jugement serait trompeur.';
  }

  @override
  String get backupNever => 'Vous n’avez encore jamais fait de sauvegarde.';

  @override
  String get backupStaleHint =>
      'Si vous perdez votre téléphone, les données seront irrécupérables.';

  @override
  String backupLastAt(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get durationsStepTitle => 'Vos données de cycle';

  @override
  String get durationsStepHelp =>
      'Pas sûre ? Laissez tel quel — vous pourrez les modifier dans les réglages.';

  @override
  String get lockTimeoutTitle => 'Délai de verrouillage';

  @override
  String get lockTimeoutDesc =>
      'Pas de code si vous revenez après un court instant';

  @override
  String get lockImmediately => 'Immédiatement';

  @override
  String get previousDay => 'Jour précédent';

  @override
  String get nextDay => 'Jour suivant';

  @override
  String get showLegend => 'Légende des couleurs';

  @override
  String get hideLegend => 'Masquer la légende';

  @override
  String get backToToday => 'Revenir à aujourd’hui';

  @override
  String get monthNoRecords => 'Aucune donnée ce mois-ci';

  @override
  String get doctorSummary => 'Exporter un résumé pour mon médecin';

  @override
  String get healthImport => 'Importer depuis Health Connect';

  @override
  String get healthImportAction => 'Importer';

  @override
  String get allTime => 'Tout';

  @override
  String get actionPeriodStarted => 'Mes règles ont commencé';

  @override
  String get actionMedicationTaken => 'Pris';

  @override
  String get pregnancyTestReady =>
      'Un test de grossesse peut désormais être fiable';

  @override
  String notLoggedToday(String what) {
    return 'Aucune saisie aujourd’hui : $what';
  }

  @override
  String pregnancyTestFrom(String date) {
    return 'Test fiable à partir du $date';
  }

  @override
  String pillBreakIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'La pause commence dans $daysString jours';
  }

  @override
  String pillNewPackIn(int days) {
    final intl.NumberFormat daysNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String daysString = daysNumberFormat.format(days);

    return 'Nouvelle plaquette dans $daysString jours';
  }

  @override
  String get healthImportNothingNew => 'Aucune nouvelle donnée à importer';

  @override
  String healthImportConfirm(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString périodes trouvées dans Health Connect et absentes de l’app. Les ajouter à vos données ? Vos données existantes ne changent pas.';
  }

  @override
  String healthImportDone(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString périodes importées';
  }

  @override
  String monthPeriodDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString jours de règles';
  }

  @override
  String monthLoggedDays(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString jours renseignés';
  }

  @override
  String get pinNoRecoveryWarning =>
      'Si vous oubliez votre code, il n’y a aucun moyen de le récupérer ; la seule issue est de supprimer toutes vos données. Choisissez un code dont vous vous souviendrez.';

  @override
  String lockAfterMinutes(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return 'Après $minutesString min';
  }

  @override
  String get reportTitle => 'Rapport de santé du cycle';

  @override
  String get reportGenerated => 'Généré';

  @override
  String get profileSummary => 'Résumé du profil';

  @override
  String get periodHistory => 'Historique des règles';

  @override
  String get last30DaysSummary => 'Résumé des 30 derniers jours';

  @override
  String get durationDaysHeader => 'Durée (jours)';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageSystem => 'Système';

  @override
  String get statsSectionOverview => 'APERÇU';

  @override
  String get statsSectionCharts => 'GRAPHIQUES';

  @override
  String get statsSectionHistory => 'HISTORIQUE ET TENDANCES';

  @override
  String storySymptomsMore(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'Les 30 derniers jours ont été plus difficiles que la période précédente ($recentString saisies contre $previousString).';
  }

  @override
  String storySymptomsLess(int recent, int previous) {
    final intl.NumberFormat recentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String recentString = recentNumberFormat.format(recent);
    final intl.NumberFormat previousNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String previousString = previousNumberFormat.format(previous);

    return 'Les 30 derniers jours ont été plus faciles que la période précédente ($recentString saisies contre $previousString).';
  }

  @override
  String get storySymptomsSame =>
      'L\'intensité des symptômes est restée similaire sur les deux dernières périodes.';

  @override
  String storyTrendUp(String delta, String unit) {
    return 'Hausse de $delta $unit sur cette période.';
  }

  @override
  String storyTrendDown(String delta, String unit) {
    return 'Baisse de $delta $unit sur cette période.';
  }

  @override
  String get storyTrendFlat =>
      'Pas de changement notable sur cette période — la tendance est stable.';

  @override
  String averageSeverity(String value) {
    return 'Moy. $value/5';
  }

  @override
  String get dataCoverage => 'Densité des données';

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

    return 'Données sur $loggedString jours sur $totalString ($percentString %)';
  }

  @override
  String get tapChartPointHint => 'Touchez un point pour ouvrir ce jour.';

  @override
  String get shareCalendarMonth => 'Partager le mois du calendrier';

  @override
  String get longPressDayHint =>
      'Appuyez longuement sur un jour pour un aperçu rapide.';

  @override
  String get markPeriodRange => 'Marquer la période des règles';

  @override
  String get periodRangeOverlap =>
      'Cette période chevauche un enregistrement existant.';

  @override
  String get periodRangeSaved => 'Période des règles enregistrée';

  @override
  String trackingStreak(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Série de $countString jours';
  }

  @override
  String weeklyTracking(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString/7 jours suivis';
  }

  @override
  String get exportCalendarFile => 'Exporter le calendrier (.ics)';

  @override
  String get ovulationMarkerHint =>
      'Ligne pointillée : ovulation estimée ou confirmée';

  @override
  String get addPastCycles => 'Ajouter des cycles passés';

  @override
  String get addPastCyclesHint =>
      'Sélectionnez jusqu’à 3 périodes de règles et enregistrez-les ensemble.';

  @override
  String get addPeriodRange => 'Ajouter une période de règles';

  @override
  String get cycleOverlayTitle => 'Comparaison des cycles';

  @override
  String get symptomLoadComparison =>
      'Intensité quotidienne des symptômes alignée sur le jour du cycle';

  @override
  String get currentCycleLabel => 'Ce cycle';

  @override
  String get previousCycleLabel => 'Cycle précédent';

  @override
  String get colorBlindPattern => 'Couleurs de phase texturées';

  @override
  String get colorBlindPatternDesc =>
      'Ajoute une texture aux bandes de phase — utile si les couleurs sont difficiles à distinguer';

  @override
  String get undo => 'Annuler';

  @override
  String get periodMarkedStarted => 'Début des règles enregistré';

  @override
  String get periodMarkedEnded => 'Fin des règles enregistrée';

  @override
  String get editPeriodRecord => 'Modifier l\'enregistrement des règles';

  @override
  String get startDateLabel => 'Début';

  @override
  String get endDateLabel => 'Fin';

  @override
  String get recordUpdated => 'Enregistrement mis à jour';

  @override
  String get dataResetTitle => 'Impossible de lire vos données';

  @override
  String get dataResetBody =>
      'Les données de l\'application n\'ont pas pu être déchiffrées sur cet appareil. Cela arrive souvent après un changement de téléphone ou une restauration système : les données sont chiffrées avec une clé propre à l\'appareil, qui ne peut pas être transférée. L\'application repart de zéro.\n\nPour transférer vos données entre appareils, exportez régulièrement une sauvegarde JSON via Réglages > Sauvegarder.';

  @override
  String get pinSet => 'Code PIN défini';

  @override
  String get pinRemoved => 'Code PIN supprimé';

  @override
  String get unlockWithBiometric => 'Déverrouiller par empreinte ou visage';

  @override
  String get biometricNotAvailable =>
      'Authentification biométrique indisponible sur cet appareil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get profileSaved => 'Profil enregistré';

  @override
  String sleepDurationShort(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString h $minutesString min';
  }

  @override
  String get deleteAllDataConfirm =>
      'Voulez-vous vraiment supprimer toutes les données ? Cette action est irréversible.';

  @override
  String get dataDeleted => 'Toutes les données supprimées';

  @override
  String get doseHint => 'ex. 500 mg';

  @override
  String get menstrualPhaseInfo =>
      'La période des saignements menstruels. Dure généralement 3 à 7 jours. Le corps évacue la muqueuse utérine.';

  @override
  String get follicularPhaseInfo =>
      'Après les règles, les ovaires préparent un nouvel ovule. Les œstrogènes montent, l\'énergie augmente.';

  @override
  String get ovulationPhaseInfo =>
      'La phase où un ovule est libéré par l\'ovaire. La probabilité de grossesse est à son maximum.';

  @override
  String get lutealPhaseInfo =>
      'La phase entre l\'ovulation et les règles suivantes. La progestérone monte, des symptômes de SPM peuvent apparaître.';

  @override
  String get fertileWindowInfo =>
      'La période où la probabilité de grossesse est la plus élevée. Commence 5 jours avant l\'ovulation et se termine 1 jour après.';

  @override
  String get ovulationCardInfo =>
      'Le jour estimé où un ovule est libéré par l\'ovaire. Survient vers le milieu du cycle.';

  @override
  String get nextPeriodInfo =>
      'La date estimée de début de vos prochaines règles. Calculée d\'après la durée de votre cycle.';

  @override
  String get phaseInfoTitle => 'Qu\'est-ce que cette phase ?';

  @override
  String get learnMore => 'Info';

  @override
  String get healthDisclaimer =>
      'Cette application ne remplace pas un avis médical. Pour toute question de santé, consultez un professionnel.';

  @override
  String get homePriority => 'Priorité de l’accueil';

  @override
  String get cycleFirst => 'Cycle d’abord';

  @override
  String get todayFirst => 'Aujourd’hui d’abord';

  @override
  String get planLifetime => 'À vie';

  @override
  String get planLifetimeDetail => 'Un paiement, premium pour toujours';

  @override
  String get cycleNotificationFrequency => 'Niveau des notifications du cycle';

  @override
  String get cycleNotificationFrequencyDesc =>
      'Les rappels de médicaments ne changent pas';

  @override
  String get notificationFrequencyEssential => 'Essentiel';

  @override
  String get notificationFrequencyBalanced => 'Équilibré';

  @override
  String get notificationFrequencyDetailed => 'Détaillé';

  @override
  String get readOnlyHistoryNotice =>
      'Vous pouvez consulter vos anciens suivis ; les nouveaux suivis et modifications nécessitent Premium.';

  @override
  String get screenProtectionTitle => 'Protection de l’écran';

  @override
  String get screenProtectionDescription =>
      'Bloque les captures et l’aperçu des applications récentes.';

  @override
  String get predictionUncertain => 'Phase de cycle incertaine';

  @override
  String get startupRecoveryBody =>
      'Vos données n\'ont pas pu être ouvertes en toute sécurité. Il a été préservé. Réessayez ou fermez l\'application et contactez l\'assistance. Ne réinstallez pas avant d\'avoir récupéré votre sauvegarde.';

  @override
  String get retry => 'Réessayer';

  @override
  String get adPrivacyOptions =>
      'Choix de confidentialité en matière de publicité';

  @override
  String get policyAvailableEnglish =>
      'Cette politique est disponible en anglais. Le texte original de la politique suit.';

  @override
  String get purchasePending => 'En attente de confirmation de paiement';

  @override
  String get purchaseVerifying => 'Vérifier votre achat';

  @override
  String get purchaseFailed =>
      'Votre achat n\'a pas pu être vérifié. Veuillez réessayer ou restaurer vos achats.';

  @override
  String get pillSchedule => 'Calendrier des pilules';

  @override
  String get pillContinuous => 'Continu (pas de pause)';

  @override
  String get predictionRange => 'Plage de dates estimée';

  @override
  String get analyticsChoice => 'Mesure d’utilisation (facultative)';

  @override
  String get analyticsChoiceDescription =>
      'Facultatif. Ne compte que les actions des applications sur cet appareil. Les données de santé, les notes, les dates et l\'identité sont exclues. Rien n\'est téléchargé sans un service configuré.';

  @override
  String get reportRange => 'Plage de dates du rapport';

  @override
  String get allHistory => 'Toute l\'histoire';

  @override
  String get pillActiveDaysTitle => 'Jours de pilule active (1 à 120)';

  @override
  String get pillBreakDaysTitle => 'Jours de pause ou de placebo (0 à 14)';

  @override
  String get pillPrescriptionNote =>
      'Utilisez uniquement le calendrier indiqué dans votre ordonnance ou dans les instructions du clinicien. Ce paramètre ne recommande pas de changer de médicament.';
}
