import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'TRNMNT'**
  String get appTitle;

  /// No description provided for @teams.
  ///
  /// In it, this message translates to:
  /// **'Squadre'**
  String get teams;

  /// No description provided for @singleMatch.
  ///
  /// In it, this message translates to:
  /// **'Partita Singola'**
  String get singleMatch;

  /// No description provided for @tournaments.
  ///
  /// In it, this message translates to:
  /// **'Tornei'**
  String get tournaments;

  /// No description provided for @newTournament.
  ///
  /// In it, this message translates to:
  /// **'Nuovo Torneo'**
  String get newTournament;

  /// No description provided for @map.
  ///
  /// In it, this message translates to:
  /// **'Mappa'**
  String get map;

  /// No description provided for @settings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settings;

  /// No description provided for @statistics.
  ///
  /// In it, this message translates to:
  /// **'Statistiche'**
  String get statistics;

  /// No description provided for @appStatistics.
  ///
  /// In it, this message translates to:
  /// **'Statistiche App'**
  String get appStatistics;

  /// No description provided for @totalTeams.
  ///
  /// In it, this message translates to:
  /// **'Squadre Totali'**
  String get totalTeams;

  /// No description provided for @courts.
  ///
  /// In it, this message translates to:
  /// **'Campetti'**
  String get courts;

  /// No description provided for @tournamentsCreated.
  ///
  /// In it, this message translates to:
  /// **'Tornei Creati'**
  String get tournamentsCreated;

  /// No description provided for @inProgress.
  ///
  /// In it, this message translates to:
  /// **'In Corso'**
  String get inProgress;

  /// No description provided for @matchesPlayed.
  ///
  /// In it, this message translates to:
  /// **'Partite Giocate'**
  String get matchesPlayed;

  /// No description provided for @pointsScored.
  ///
  /// In it, this message translates to:
  /// **'Punti Segnati'**
  String get pointsScored;

  /// No description provided for @hallOfFame.
  ///
  /// In it, this message translates to:
  /// **'Albo d\'Oro'**
  String get hallOfFame;

  /// No description provided for @noTournamentsRecorded.
  ///
  /// In it, this message translates to:
  /// **'Nessun torneo registrato al momento.'**
  String get noTournamentsRecorded;

  /// No description provided for @winner.
  ///
  /// In it, this message translates to:
  /// **'🏆 Vincitore: {team}'**
  String winner(String team);

  /// No description provided for @inProgressOrToBeDecided.
  ///
  /// In it, this message translates to:
  /// **'⏳ In Corso / Da decidere'**
  String get inProgressOrToBeDecided;

  /// No description provided for @teamRecord.
  ///
  /// In it, this message translates to:
  /// **'Record squadra: {wins} V - {losses} S'**
  String teamRecord(int wins, int losses);

  /// No description provided for @points.
  ///
  /// In it, this message translates to:
  /// **'Punti: PF {pf} / PS {ps}'**
  String points(int pf, int ps);

  /// No description provided for @appLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua App'**
  String get appLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In it, this message translates to:
  /// **'Seleziona la lingua'**
  String get selectLanguage;

  /// No description provided for @developedBy.
  ///
  /// In it, this message translates to:
  /// **'Sviluppato da'**
  String get developedBy;

  /// No description provided for @tapToVisitLinks.
  ///
  /// In it, this message translates to:
  /// **'Tocca per visitare i link'**
  String get tapToVisitLinks;

  /// No description provided for @appVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione App'**
  String get appVersion;

  /// No description provided for @followUsOnSocial.
  ///
  /// In it, this message translates to:
  /// **'Seguici sui social'**
  String get followUsOnSocial;

  /// No description provided for @timer.
  ///
  /// In it, this message translates to:
  /// **'Cronometro'**
  String get timer;

  /// No description provided for @manageTeams.
  ///
  /// In it, this message translates to:
  /// **'Gestisci le squadre'**
  String get manageTeams;

  /// No description provided for @manageSingleMatch.
  ///
  /// In it, this message translates to:
  /// **'Gestisci una partita singola'**
  String get manageSingleMatch;

  /// No description provided for @createAndManage.
  ///
  /// In it, this message translates to:
  /// **'Crea e gestisci'**
  String get createAndManage;

  /// No description provided for @startNow.
  ///
  /// In it, this message translates to:
  /// **'Inizia subito'**
  String get startNow;

  /// No description provided for @courtsMap.
  ///
  /// In it, this message translates to:
  /// **'La mappa dei campetti'**
  String get courtsMap;

  /// No description provided for @appOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni app'**
  String get appOptions;

  /// No description provided for @dataAndNumbers.
  ///
  /// In it, this message translates to:
  /// **'Dati e numeri'**
  String get dataAndNumbers;

  /// No description provided for @appSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Gestione Tornei di Basket'**
  String get appSubtitle;

  /// No description provided for @courtStatus.
  ///
  /// In it, this message translates to:
  /// **'Stato campo: {status}'**
  String courtStatus(String status);

  /// No description provided for @starsCount.
  ///
  /// In it, this message translates to:
  /// **'Livello: {count}/5'**
  String starsCount(int count);

  /// No description provided for @wellMaintained.
  ///
  /// In it, this message translates to:
  /// **'Ben mantenuto'**
  String get wellMaintained;

  /// No description provided for @playable.
  ///
  /// In it, this message translates to:
  /// **'Giocabile'**
  String get playable;

  /// No description provided for @poorCondition.
  ///
  /// In it, this message translates to:
  /// **'Preso male'**
  String get poorCondition;

  /// No description provided for @cloth.
  ///
  /// In it, this message translates to:
  /// **'Stoffa'**
  String get cloth;

  /// No description provided for @metal.
  ///
  /// In it, this message translates to:
  /// **'Ferro'**
  String get metal;

  /// No description provided for @broken.
  ///
  /// In it, this message translates to:
  /// **'Rotte'**
  String get broken;

  /// No description provided for @notPresent.
  ///
  /// In it, this message translates to:
  /// **'Non presenti'**
  String get notPresent;

  /// No description provided for @wellDefined.
  ///
  /// In it, this message translates to:
  /// **'Ben definite'**
  String get wellDefined;

  /// No description provided for @visible.
  ///
  /// In it, this message translates to:
  /// **'Visibili'**
  String get visible;

  /// No description provided for @damaged.
  ///
  /// In it, this message translates to:
  /// **'Rovinate'**
  String get damaged;

  /// No description provided for @yes.
  ///
  /// In it, this message translates to:
  /// **'Sì'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In it, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @hoopsCount.
  ///
  /// In it, this message translates to:
  /// **'Canestri: {count}'**
  String hoopsCount(int count);

  /// No description provided for @netsTitle.
  ///
  /// In it, this message translates to:
  /// **'Retine'**
  String get netsTitle;

  /// No description provided for @courtTitle.
  ///
  /// In it, this message translates to:
  /// **'Campo'**
  String get courtTitle;

  /// No description provided for @linesTitle.
  ///
  /// In it, this message translates to:
  /// **'Linee'**
  String get linesTitle;

  /// No description provided for @lightsTitle.
  ///
  /// In it, this message translates to:
  /// **'Luci'**
  String get lightsTitle;

  /// No description provided for @saveAction.
  ///
  /// In it, this message translates to:
  /// **'SALVA'**
  String get saveAction;

  /// No description provided for @newCourtTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo Campetto'**
  String get newCourtTitle;

  /// No description provided for @nameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get nameLabel;

  /// No description provided for @descLabel.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get descLabel;

  /// No description provided for @tapMapInstruction.
  ///
  /// In it, this message translates to:
  /// **'Tocca la mappa per aggiungere'**
  String get tapMapInstruction;

  /// No description provided for @positionSaved.
  ///
  /// In it, this message translates to:
  /// **'Posizione mappa salvata!'**
  String get positionSaved;

  /// No description provided for @addAction.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get addAction;

  /// No description provided for @hoops.
  ///
  /// In it, this message translates to:
  /// **'Canestri'**
  String get hoops;

  /// No description provided for @rating.
  ///
  /// In it, this message translates to:
  /// **'Valutazione'**
  String get rating;

  /// No description provided for @edit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get edit;

  /// No description provided for @myTournaments.
  ///
  /// In it, this message translates to:
  /// **'I Miei Tornei'**
  String get myTournaments;

  /// No description provided for @deleteTournament.
  ///
  /// In it, this message translates to:
  /// **'Elimina torneo'**
  String get deleteTournament;

  /// No description provided for @confirmDeleteTournament.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare \"{name}\"?'**
  String confirmDeleteTournament(String name);

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @noTournaments.
  ///
  /// In it, this message translates to:
  /// **'Nessun torneo'**
  String get noTournaments;

  /// No description provided for @createFirstTournament.
  ///
  /// In it, this message translates to:
  /// **'Crea il tuo primo torneo di basket'**
  String get createFirstTournament;

  /// No description provided for @createTournament.
  ///
  /// In it, this message translates to:
  /// **'Crea Torneo'**
  String get createTournament;

  /// No description provided for @groupOnly.
  ///
  /// In it, this message translates to:
  /// **'Solo Girone'**
  String get groupOnly;

  /// No description provided for @eliminationOnly.
  ///
  /// In it, this message translates to:
  /// **'Solo Eliminatoria'**
  String get eliminationOnly;

  /// No description provided for @groupAndElimination.
  ///
  /// In it, this message translates to:
  /// **'Girone + Playoff'**
  String get groupAndElimination;

  /// No description provided for @consolationFinals.
  ///
  /// In it, this message translates to:
  /// **'Finali consolazione'**
  String get consolationFinals;

  /// No description provided for @location.
  ///
  /// In it, this message translates to:
  /// **'📍 {loc}'**
  String location(String loc);

  /// No description provided for @teamsAndMode.
  ///
  /// In it, this message translates to:
  /// **'🏀 {count} squadre - {mode}'**
  String teamsAndMode(int count, String mode);

  /// No description provided for @singleMatchSetup.
  ///
  /// In it, this message translates to:
  /// **'Setup Partita Singola'**
  String get singleMatchSetup;

  /// No description provided for @noTeamsInDatabase.
  ///
  /// In it, this message translates to:
  /// **'Nessuna squadra presente nel database.'**
  String get noTeamsInDatabase;

  /// No description provided for @createTeam.
  ///
  /// In it, this message translates to:
  /// **'Crea Squadra'**
  String get createTeam;

  /// No description provided for @selectTeamsForMatch.
  ///
  /// In it, this message translates to:
  /// **'Seleziona le squadre per la partita singola'**
  String get selectTeamsForMatch;

  /// No description provided for @homeTeam.
  ///
  /// In it, this message translates to:
  /// **'Squadra in casa'**
  String get homeTeam;

  /// No description provided for @awayTeam.
  ///
  /// In it, this message translates to:
  /// **'Squadra in trasferta'**
  String get awayTeam;

  /// No description provided for @selectATeam.
  ///
  /// In it, this message translates to:
  /// **'Seleziona una squadra'**
  String get selectATeam;

  /// No description provided for @selectDifferentTeams.
  ///
  /// In it, this message translates to:
  /// **'Scegli due squadre diverse'**
  String get selectDifferentTeams;

  /// No description provided for @startMatch.
  ///
  /// In it, this message translates to:
  /// **'Inizia Partita'**
  String get startMatch;

  /// No description provided for @theme.
  ///
  /// In it, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @baseTheme.
  ///
  /// In it, this message translates to:
  /// **'Tema Base (Vibrante)'**
  String get baseTheme;

  /// No description provided for @darkTheme.
  ///
  /// In it, this message translates to:
  /// **'Tema Scuro (Puro)'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In it, this message translates to:
  /// **'Tema Chiaro'**
  String get lightTheme;

  /// No description provided for @developers.
  ///
  /// In it, this message translates to:
  /// **'Sviluppatori'**
  String get developers;

  /// No description provided for @officialWebsite.
  ///
  /// In it, this message translates to:
  /// **'Sito Ufficiale'**
  String get officialWebsite;

  /// No description provided for @unableToOpenUrl.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire {url}'**
  String unableToOpenUrl(String url);

  /// No description provided for @matchInProgress.
  ///
  /// In it, this message translates to:
  /// **'Partita in corso'**
  String get matchInProgress;

  /// No description provided for @resetMatch.
  ///
  /// In it, this message translates to:
  /// **'Azzera partita'**
  String get resetMatch;

  /// No description provided for @confirmResetMatch.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler riportare il punteggio e il periodo a 0?'**
  String get confirmResetMatch;

  /// No description provided for @durationMinutes.
  ///
  /// In it, this message translates to:
  /// **'Durata (minuti)'**
  String get durationMinutes;

  /// No description provided for @periodLabel.
  ///
  /// In it, this message translates to:
  /// **'PERIODO'**
  String get periodLabel;

  /// No description provided for @selectAtLeastTwoTeams.
  ///
  /// In it, this message translates to:
  /// **'Seleziona almeno 2 squadre'**
  String get selectAtLeastTwoTeams;

  /// No description provided for @infoStep.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get infoStep;

  /// No description provided for @infoSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Nome e luogo'**
  String get infoSubtitle;

  /// No description provided for @configStep.
  ///
  /// In it, this message translates to:
  /// **'Configurazione'**
  String get configStep;

  /// No description provided for @configSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Modalità e punteggio'**
  String get configSubtitle;

  /// No description provided for @teamsStep.
  ///
  /// In it, this message translates to:
  /// **'Squadre'**
  String get teamsStep;

  /// No description provided for @teamsSelected.
  ///
  /// In it, this message translates to:
  /// **'{count} selezionate'**
  String teamsSelected(int count);

  /// No description provided for @tournamentName.
  ///
  /// In it, this message translates to:
  /// **'Nome Torneo'**
  String get tournamentName;

  /// No description provided for @tournamentLocation.
  ///
  /// In it, this message translates to:
  /// **'Luogo'**
  String get tournamentLocation;

  /// No description provided for @enterTournamentName.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il nome del torneo'**
  String get enterTournamentName;

  /// No description provided for @enterTournamentLocation.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il luogo del torneo'**
  String get enterTournamentLocation;

  /// No description provided for @tournamentMode.
  ///
  /// In it, this message translates to:
  /// **'Modalità Torneo'**
  String get tournamentMode;

  /// No description provided for @scoringSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema Punteggio'**
  String get scoringSystem;

  /// No description provided for @win.
  ///
  /// In it, this message translates to:
  /// **'Vittoria'**
  String get win;

  /// No description provided for @draw.
  ///
  /// In it, this message translates to:
  /// **'Pareggio'**
  String get draw;

  /// No description provided for @loss.
  ///
  /// In it, this message translates to:
  /// **'Sconfitta'**
  String get loss;

  /// No description provided for @classicBasketball.
  ///
  /// In it, this message translates to:
  /// **'Basket Classico'**
  String get classicBasketball;

  /// No description provided for @standardFootball.
  ///
  /// In it, this message translates to:
  /// **'Calcio Standard'**
  String get standardFootball;

  /// No description provided for @custom.
  ///
  /// In it, this message translates to:
  /// **'Personalizzato'**
  String get custom;

  /// No description provided for @setYourScores.
  ///
  /// In it, this message translates to:
  /// **'Imposta i tuoi punteggi'**
  String get setYourScores;

  /// No description provided for @consolationFinalsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'3°/4° posto, 5°/6°, etc.'**
  String get consolationFinalsSubtitle;

  /// No description provided for @matchTimer.
  ///
  /// In it, this message translates to:
  /// **'Timer Partita: {min} minuti'**
  String matchTimer(int min);

  /// No description provided for @searchTeam.
  ///
  /// In it, this message translates to:
  /// **'Cerca Squadra'**
  String get searchTeam;

  /// No description provided for @selectParticipatingTeams.
  ///
  /// In it, this message translates to:
  /// **'Seleziona le squadre partecipanti (min. 2)'**
  String get selectParticipatingTeams;

  /// No description provided for @oddTeamsBye.
  ///
  /// In it, this message translates to:
  /// **'Squadre dispari: verrà gestito automaticamente il riposo (BYE)'**
  String get oddTeamsBye;

  /// No description provided for @selectAll.
  ///
  /// In it, this message translates to:
  /// **'Seleziona tutti'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In it, this message translates to:
  /// **'Deseleziona tutti'**
  String get deselectAll;

  /// No description provided for @noTeamsFound.
  ///
  /// In it, this message translates to:
  /// **'Nessuna squadra trovata'**
  String get noTeamsFound;

  /// No description provided for @continueAction.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get continueAction;

  /// No description provided for @backAction.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get backAction;

  /// No description provided for @groupOnlySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Round-robin, classifica finale'**
  String get groupOnlySubtitle;

  /// No description provided for @eliminationOnlySubtitle.
  ///
  /// In it, this message translates to:
  /// **'Vinci o vai a casa'**
  String get eliminationOnlySubtitle;

  /// No description provided for @groupAndEliminationSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Fase a gironi poi eliminatoria'**
  String get groupAndEliminationSubtitle;

  /// No description provided for @error.
  ///
  /// In it, this message translates to:
  /// **'Errore'**
  String get error;

  /// No description provided for @notFound.
  ///
  /// In it, this message translates to:
  /// **'Non trovato'**
  String get notFound;

  /// No description provided for @tournamentNotFound.
  ///
  /// In it, this message translates to:
  /// **'Torneo non trovato'**
  String get tournamentNotFound;

  /// No description provided for @participatingTeams.
  ///
  /// In it, this message translates to:
  /// **'Squadre Partecipanti'**
  String get participatingTeams;

  /// No description provided for @tournamentManagement.
  ///
  /// In it, this message translates to:
  /// **'Gestione Torneo'**
  String get tournamentManagement;

  /// No description provided for @calendar.
  ///
  /// In it, this message translates to:
  /// **'Calendario'**
  String get calendar;

  /// No description provided for @groupPhase.
  ///
  /// In it, this message translates to:
  /// **'Fase a gironi'**
  String get groupPhase;

  /// No description provided for @standings.
  ///
  /// In it, this message translates to:
  /// **'Classifica'**
  String get standings;

  /// No description provided for @pointsAndStats.
  ///
  /// In it, this message translates to:
  /// **'Punti e statistiche'**
  String get pointsAndStats;

  /// No description provided for @elimination.
  ///
  /// In it, this message translates to:
  /// **'Eliminatoria'**
  String get elimination;

  /// No description provided for @playoffBracket.
  ///
  /// In it, this message translates to:
  /// **'Bracket playoff'**
  String get playoffBracket;

  /// No description provided for @timerLabel.
  ///
  /// In it, this message translates to:
  /// **'Timer'**
  String get timerLabel;

  /// No description provided for @minutesX.
  ///
  /// In it, this message translates to:
  /// **'{count} minuti'**
  String minutesX(int count);

  /// No description provided for @tournamentDate.
  ///
  /// In it, this message translates to:
  /// **'Data Torneo'**
  String get tournamentDate;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTeams.
  ///
  /// In it, this message translates to:
  /// **'Squadre'**
  String get navTeams;

  /// No description provided for @navTournaments.
  ///
  /// In it, this message translates to:
  /// **'Tornei'**
  String get navTournaments;

  /// No description provided for @navTimer.
  ///
  /// In it, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// No description provided for @appIcon.
  ///
  /// In it, this message translates to:
  /// **'Icona App'**
  String get appIcon;

  /// No description provided for @changeAppIcon.
  ///
  /// In it, this message translates to:
  /// **'Cambia Icona App'**
  String get changeAppIcon;

  /// No description provided for @pickImageIcon.
  ///
  /// In it, this message translates to:
  /// **'Seleziona immagine'**
  String get pickImageIcon;

  /// No description provided for @resetIcon.
  ///
  /// In it, this message translates to:
  /// **'Ripristina icona predefinita'**
  String get resetIcon;

  /// No description provided for @viewWinners.
  ///
  /// In it, this message translates to:
  /// **'Vedi i vincitori'**
  String get viewWinners;

  /// No description provided for @share.
  ///
  /// In it, this message translates to:
  /// **'Condividi'**
  String get share;

  /// No description provided for @scanTournament.
  ///
  /// In it, this message translates to:
  /// **'Scansiona Torneo'**
  String get scanTournament;

  /// No description provided for @syncFromScout.
  ///
  /// In it, this message translates to:
  /// **'Sincronizza da Scout'**
  String get syncFromScout;

  /// No description provided for @readOnlyTournament.
  ///
  /// In it, this message translates to:
  /// **'Questo torneo è in sola lettura perché è stato importato.'**
  String get readOnlyTournament;

  /// No description provided for @apiSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni API'**
  String get apiSettings;

  /// No description provided for @apiUrl.
  ///
  /// In it, this message translates to:
  /// **'URL Server API'**
  String get apiUrl;

  /// No description provided for @apiUrlHint.
  ///
  /// In it, this message translates to:
  /// **'Esempio: https://vesb.vercel.app'**
  String get apiUrlHint;

  /// No description provided for @testConnection.
  ///
  /// In it, this message translates to:
  /// **'Testa Connessione'**
  String get testConnection;

  /// No description provided for @connectionWorking.
  ///
  /// In it, this message translates to:
  /// **'Connessione funzionante!'**
  String get connectionWorking;

  /// No description provided for @connectionError.
  ///
  /// In it, this message translates to:
  /// **'Errore di connessione'**
  String get connectionError;

  /// No description provided for @publishToWeb.
  ///
  /// In it, this message translates to:
  /// **'Pubblica sul Web'**
  String get publishToWeb;

  /// No description provided for @openInBrowser.
  ///
  /// In it, this message translates to:
  /// **'Apri nel Browser'**
  String get openInBrowser;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
