import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
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
    Locale('es'),
    Locale('fr'),
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
  /// **'Le mie squadre'**
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

  /// No description provided for @radar.
  ///
  /// In it, this message translates to:
  /// **'Radar'**
  String get radar;

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

  /// No description provided for @myCommunity.
  ///
  /// In it, this message translates to:
  /// **'La mia Community'**
  String get myCommunity;

  /// No description provided for @communityManagement.
  ///
  /// In it, this message translates to:
  /// **'Gestione Community'**
  String get communityManagement;

  /// No description provided for @manageBrandsLogos.
  ///
  /// In it, this message translates to:
  /// **'Gestisci brand'**
  String get manageBrandsLogos;

  /// No description provided for @joinCommunity.
  ///
  /// In it, this message translates to:
  /// **'Unisciti a una Community'**
  String get joinCommunity;

  /// No description provided for @scanQrInvitation.
  ///
  /// In it, this message translates to:
  /// **'Scansiona QR Invito'**
  String get scanQrInvitation;

  /// No description provided for @createNewGroup.
  ///
  /// In it, this message translates to:
  /// **'CREA NUOVA COMMUNITY'**
  String get createNewGroup;

  /// No description provided for @adminStatus.
  ///
  /// In it, this message translates to:
  /// **'Sei l\'amministratore di questa community.'**
  String get adminStatus;

  /// No description provided for @collaboratorStatus.
  ///
  /// In it, this message translates to:
  /// **'Sei un collaboratore di questa community.'**
  String get collaboratorStatus;

  /// No description provided for @shareInvitation.
  ///
  /// In it, this message translates to:
  /// **'Condividi Invito'**
  String get shareInvitation;

  /// No description provided for @scanQrInstructions.
  ///
  /// In it, this message translates to:
  /// **'Inquadra il QR Code fornito dall\'organizzatore'**
  String get scanQrInstructions;

  /// No description provided for @scanQrTitle.
  ///
  /// In it, this message translates to:
  /// **'Scansiona QR Community'**
  String get scanQrTitle;

  /// No description provided for @joinedCommunitySuccess.
  ///
  /// In it, this message translates to:
  /// **'Ti sei unito alla community! 🏀'**
  String get joinedCommunitySuccess;

  /// No description provided for @errorJoiningCommunity.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'unione. Riprova.'**
  String get errorJoiningCommunity;

  /// No description provided for @onlyAdminCanEdit.
  ///
  /// In it, this message translates to:
  /// **'Solo l\'amministratore può modificare l\'identità della community.'**
  String get onlyAdminCanEdit;

  /// No description provided for @communityIdentityDesc.
  ///
  /// In it, this message translates to:
  /// **'Crea la tua identità per organizzare tornei sotto il tuo brand, o scansiona il QR di un collega per collaborare.'**
  String get communityIdentityDesc;

  /// No description provided for @updateData.
  ///
  /// In it, this message translates to:
  /// **'AGGIORNA DATI'**
  String get updateData;

  /// No description provided for @saveCommunity.
  ///
  /// In it, this message translates to:
  /// **'COMMUNITY AGGIORNATA'**
  String get saveCommunity;

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

  /// No description provided for @radarSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Radar'**
  String get radarSubtitle;

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

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

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
  /// **'Campionato'**
  String get groupOnly;

  /// No description provided for @eliminationOnly.
  ///
  /// In it, this message translates to:
  /// **'Playoff'**
  String get eliminationOnly;

  /// No description provided for @groupAndElimination.
  ///
  /// In it, this message translates to:
  /// **'Campionato & Playoff'**
  String get groupAndElimination;

  /// No description provided for @madness.
  ///
  /// In it, this message translates to:
  /// **'Madness'**
  String get madness;

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
  /// **'PERIODO {period}'**
  String periodLabel(Object period);

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
  /// **'Campionato poi Playoff'**
  String get groupAndEliminationSubtitle;

  /// No description provided for @madnessSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Chi vince regna, alta intensità!'**
  String get madnessSubtitle;

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
  /// **'Data e orario inizio torneo'**
  String get tournamentDate;

  /// No description provided for @tournamentEndDate.
  ///
  /// In it, this message translates to:
  /// **'Data e orario fine torneo'**
  String get tournamentEndDate;

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
  /// **'Esempio: https://trnmnt.vercel.app'**
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
  /// **'Sincronizza sul Cloud'**
  String get publishToWeb;

  /// No description provided for @openInBrowser.
  ///
  /// In it, this message translates to:
  /// **'Apri nel Browser'**
  String get openInBrowser;

  /// No description provided for @teamOrder.
  ///
  /// In it, this message translates to:
  /// **'Ordine Squadre'**
  String get teamOrder;

  /// No description provided for @dragToReorder.
  ///
  /// In it, this message translates to:
  /// **'Trascina per spostare'**
  String get dragToReorder;

  /// No description provided for @madnessOrderSubtitle.
  ///
  /// In it, this message translates to:
  /// **'L\'ordine delle squadre determina il bracket Madness.'**
  String get madnessOrderSubtitle;

  /// No description provided for @live.
  ///
  /// In it, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @matchDetail.
  ///
  /// In it, this message translates to:
  /// **'Dettaglio Partita'**
  String get matchDetail;

  /// No description provided for @quit.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get quit;

  /// No description provided for @rules.
  ///
  /// In it, this message translates to:
  /// **'Regole'**
  String get rules;

  /// No description provided for @viewTournamentRules.
  ///
  /// In it, this message translates to:
  /// **'Vedi le regole del torneo'**
  String get viewTournamentRules;

  /// No description provided for @multiGroup.
  ///
  /// In it, this message translates to:
  /// **'Gironi Multipli'**
  String get multiGroup;

  /// No description provided for @groupCountLabel.
  ///
  /// In it, this message translates to:
  /// **'Numero di Gironi'**
  String get groupCountLabel;

  /// No description provided for @teamsPerGroup.
  ///
  /// In it, this message translates to:
  /// **'Squadre per Girone'**
  String get teamsPerGroup;

  /// No description provided for @randomDistribution.
  ///
  /// In it, this message translates to:
  /// **'Distribuzione Casuale'**
  String get randomDistribution;

  /// No description provided for @manualDistribution.
  ///
  /// In it, this message translates to:
  /// **'Distribuzione Manuale'**
  String get manualDistribution;

  /// No description provided for @qualifiersPerGroupLabel.
  ///
  /// In it, this message translates to:
  /// **'Qualificati per Girone'**
  String get qualifiersPerGroupLabel;

  /// No description provided for @hasPlayInLabel.
  ///
  /// In it, this message translates to:
  /// **'Includi Spareggi (Play-In)'**
  String get hasPlayInLabel;

  /// No description provided for @editGroups.
  ///
  /// In it, this message translates to:
  /// **'Gestisci i Gironi'**
  String get editGroups;

  /// No description provided for @distributeTeams.
  ///
  /// In it, this message translates to:
  /// **'Distribuisci le squadre nei gironi'**
  String get distributeTeams;

  /// No description provided for @groupNameHint.
  ///
  /// In it, this message translates to:
  /// **'Nome Girone (es. A, B...)'**
  String get groupNameHint;

  /// No description provided for @all.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get all;

  /// No description provided for @upcoming.
  ///
  /// In it, this message translates to:
  /// **'In programma'**
  String get upcoming;

  /// No description provided for @concluded.
  ///
  /// In it, this message translates to:
  /// **'Concluso'**
  String get concluded;

  /// No description provided for @playIn.
  ///
  /// In it, this message translates to:
  /// **'Spareggi'**
  String get playIn;

  /// No description provided for @modeLockedWarning.
  ///
  /// In it, this message translates to:
  /// **'La modalità non può essere cambiata perché il torneo è già iniziato.'**
  String get modeLockedWarning;

  /// No description provided for @cloudCollaboration.
  ///
  /// In it, this message translates to:
  /// **'Co-gestione Cloud'**
  String get cloudCollaboration;

  /// No description provided for @inviteAdmin.
  ///
  /// In it, this message translates to:
  /// **'Invita Organizzatore'**
  String get inviteAdmin;

  /// No description provided for @cloudSyncActive.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione Cloud attiva'**
  String get cloudSyncActive;

  /// No description provided for @tournamentImportedAndSynced.
  ///
  /// In it, this message translates to:
  /// **'Torneo importato e sincronizzato! 🤝🏀'**
  String get tournamentImportedAndSynced;

  /// No description provided for @cloudFetching.
  ///
  /// In it, this message translates to:
  /// **'Recupero dati dal Cloud...'**
  String get cloudFetching;

  /// No description provided for @syncError.
  ///
  /// In it, this message translates to:
  /// **'Errore di sincronizzazione'**
  String get syncError;

  /// No description provided for @cloudIdLabel.
  ///
  /// In it, this message translates to:
  /// **'ID Cloud: {id}'**
  String cloudIdLabel(String id);

  /// No description provided for @publishToCloud_title.
  ///
  /// In it, this message translates to:
  /// **'Pubblica sul Cloud'**
  String get publishToCloud_title;

  /// No description provided for @publishToCloud_desc.
  ///
  /// In it, this message translates to:
  /// **'Sincronizza il torneo per abilitare la Dashboard Web e la Co-Gestione.'**
  String get publishToCloud_desc;

  /// No description provided for @publishNow.
  ///
  /// In it, this message translates to:
  /// **'Pubblica Ora'**
  String get publishNow;

  /// No description provided for @manageYourBrand.
  ///
  /// In it, this message translates to:
  /// **'Gestisci il tuo Brand'**
  String get manageYourBrand;

  /// No description provided for @liveHighlights.
  ///
  /// In it, this message translates to:
  /// **'IN EVIDENZA'**
  String get liveHighlights;

  /// No description provided for @statsOverview.
  ///
  /// In it, this message translates to:
  /// **'STATISTICHE APP'**
  String get statsOverview;

  /// No description provided for @noTournamentsAtMoment.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono tornei al momento'**
  String get noTournamentsAtMoment;

  /// No description provided for @activeTournamentMatch.
  ///
  /// In it, this message translates to:
  /// **'PARTITA TORNEO LIVE'**
  String get activeTournamentMatch;

  /// No description provided for @future.
  ///
  /// In it, this message translates to:
  /// **'In programma'**
  String get future;

  /// No description provided for @past.
  ///
  /// In it, this message translates to:
  /// **'Passati'**
  String get past;

  /// No description provided for @syncSuccess.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzato sul Cloud! ☁️🏀'**
  String get syncSuccess;

  /// No description provided for @webResult.
  ///
  /// In it, this message translates to:
  /// **'Risultati Web'**
  String get webResult;

  /// No description provided for @coManagement.
  ///
  /// In it, this message translates to:
  /// **'Co-Gestione'**
  String get coManagement;

  /// No description provided for @publicDashboard.
  ///
  /// In it, this message translates to:
  /// **'DASHBOARD PUBBLICA'**
  String get publicDashboard;

  /// No description provided for @coManagementTitle.
  ///
  /// In it, this message translates to:
  /// **'CO-GESTIONE CLOUD'**
  String get coManagementTitle;

  /// No description provided for @publicDashboardDesc.
  ///
  /// In it, this message translates to:
  /// **'Chiunque può vedere i risultati live'**
  String get publicDashboardDesc;

  /// No description provided for @coManagementDesc.
  ///
  /// In it, this message translates to:
  /// **'Invita un altro organizzatore a gestire il torneo'**
  String get coManagementDesc;

  /// No description provided for @cloudSettings.
  ///
  /// In it, this message translates to:
  /// **'IMPOSTAZIONI CLOUD'**
  String get cloudSettings;

  /// No description provided for @liveLocationLabel.
  ///
  /// In it, this message translates to:
  /// **'LOCATION LIVE'**
  String get liveLocationLabel;

  /// No description provided for @locationHint.
  ///
  /// In it, this message translates to:
  /// **'Es: Playground San Alvise'**
  String get locationHint;

  /// No description provided for @twitchChannelLabel.
  ///
  /// In it, this message translates to:
  /// **'CANALE TWITCH'**
  String get twitchChannelLabel;

  /// No description provided for @twitchHint.
  ///
  /// In it, this message translates to:
  /// **'Es: venicestreetball'**
  String get twitchHint;

  /// No description provided for @youtubeVideoLabel.
  ///
  /// In it, this message translates to:
  /// **'ID VIDEO YOUTUBE'**
  String get youtubeVideoLabel;

  /// No description provided for @youtubeHint.
  ///
  /// In it, this message translates to:
  /// **'Es: dQw4w9WgXcQ'**
  String get youtubeHint;

  /// No description provided for @customTickerLabel.
  ///
  /// In it, this message translates to:
  /// **'TESTO SCORREVOLE (TICKER)'**
  String get customTickerLabel;

  /// No description provided for @tickerHint.
  ///
  /// In it, this message translates to:
  /// **'Sponsor, annunci community...'**
  String get tickerHint;

  /// No description provided for @tickerAutoDesc.
  ///
  /// In it, this message translates to:
  /// **'Lascia vuoto per utilizzare il testo generato dal sistema.'**
  String get tickerAutoDesc;

  /// No description provided for @copyLink.
  ///
  /// In it, this message translates to:
  /// **'Copia link'**
  String get copyLink;

  /// No description provided for @openPage.
  ///
  /// In it, this message translates to:
  /// **'Apri Pagina'**
  String get openPage;

  /// No description provided for @syncing.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione...'**
  String get syncing;

  /// No description provided for @syncCloud.
  ///
  /// In it, this message translates to:
  /// **'Sincronizza Cloud'**
  String get syncCloud;

  /// No description provided for @urlSlug.
  ///
  /// In it, this message translates to:
  /// **'URL Slug'**
  String get urlSlug;

  /// No description provided for @locationLabel.
  ///
  /// In it, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @instagramLabel.
  ///
  /// In it, this message translates to:
  /// **'Instagram'**
  String get instagramLabel;

  /// No description provided for @tiktokLabel.
  ///
  /// In it, this message translates to:
  /// **'TikTok'**
  String get tiktokLabel;

  /// No description provided for @invalidName.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un nome valido'**
  String get invalidName;

  /// No description provided for @invalidUrl.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un URL valido'**
  String get invalidUrl;

  /// No description provided for @noActiveInvite.
  ///
  /// In it, this message translates to:
  /// **'Nessun invito attivo o scaduto. Generane uno nuovo.'**
  String get noActiveInvite;

  /// No description provided for @expiryDate.
  ///
  /// In it, this message translates to:
  /// **'Scadenza: {time} del {date}'**
  String expiryDate(String time, String date);

  /// No description provided for @regenerateInvite.
  ///
  /// In it, this message translates to:
  /// **'RIGENERA'**
  String get regenerateInvite;

  /// No description provided for @generateInviteAction.
  ///
  /// In it, this message translates to:
  /// **'GENERA INVITO'**
  String get generateInviteAction;

  /// No description provided for @slugAlreadyExists.
  ///
  /// In it, this message translates to:
  /// **'Questo URL è già occupato da un\'altra community.'**
  String get slugAlreadyExists;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'CHIUDI'**
  String get close;

  /// No description provided for @registrations.
  ///
  /// In it, this message translates to:
  /// **'Iscrizioni'**
  String get registrations;

  /// No description provided for @manageRegistrations.
  ///
  /// In it, this message translates to:
  /// **'Gestisci Iscrizioni'**
  String get manageRegistrations;

  /// No description provided for @enableWebRegistrations.
  ///
  /// In it, this message translates to:
  /// **'Abilita Iscrizioni Online'**
  String get enableWebRegistrations;

  /// No description provided for @registrationsNotActive.
  ///
  /// In it, this message translates to:
  /// **'ISCRIZIONI NON ATTIVE'**
  String get registrationsNotActive;

  /// No description provided for @createPublicPageDesc.
  ///
  /// In it, this message translates to:
  /// **'Crea la pagina pubblica per permettere alle squadre di iscriversi online.'**
  String get createPublicPageDesc;

  /// No description provided for @activateNow.
  ///
  /// In it, this message translates to:
  /// **'ATTIVA ORA'**
  String get activateNow;

  /// No description provided for @configureRegistrations.
  ///
  /// In it, this message translates to:
  /// **'CONFIGURA ISCRIZIONI'**
  String get configureRegistrations;

  /// No description provided for @maxTeamsLabel.
  ///
  /// In it, this message translates to:
  /// **'Numero Massimo Squadre'**
  String get maxTeamsLabel;

  /// No description provided for @enableLunchChoice.
  ///
  /// In it, this message translates to:
  /// **'Abilita Scelta Pranzo'**
  String get enableLunchChoice;

  /// No description provided for @addOption.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi Opzione'**
  String get addOption;

  /// No description provided for @createPage.
  ///
  /// In it, this message translates to:
  /// **'CREA PAGINA'**
  String get createPage;

  /// No description provided for @onlineRegistrationsEnabled.
  ///
  /// In it, this message translates to:
  /// **'Iscrizioni Online Abilitate!'**
  String get onlineRegistrationsEnabled;

  /// No description provided for @registeredTeams.
  ///
  /// In it, this message translates to:
  /// **'SQUADRE ISCRITTE'**
  String get registeredTeams;

  /// No description provided for @registrationsClosed.
  ///
  /// In it, this message translates to:
  /// **'ISCRIZIONI CHIUSE'**
  String get registrationsClosed;

  /// No description provided for @closeNow.
  ///
  /// In it, this message translates to:
  /// **'CHIUDI ORA'**
  String get closeNow;

  /// No description provided for @noRegistrationsYet.
  ///
  /// In it, this message translates to:
  /// **'Ancora nessuna iscrizione ricevuta'**
  String get noRegistrationsYet;

  /// No description provided for @confirmed.
  ///
  /// In it, this message translates to:
  /// **'Confermato'**
  String get confirmed;

  /// No description provided for @players.
  ///
  /// In it, this message translates to:
  /// **'GIOCATORI'**
  String get players;

  /// No description provided for @lunchOptions.
  ///
  /// In it, this message translates to:
  /// **'Opzioni Pranzo'**
  String get lunchOptions;

  /// No description provided for @deleteRegistration.
  ///
  /// In it, this message translates to:
  /// **'Elimina Iscrizione'**
  String get deleteRegistration;

  /// No description provided for @confirmDeleteRegistration.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare l\'iscrizione di \"{team}\"?'**
  String confirmDeleteRegistration(String team);

  /// No description provided for @registrationDeleted.
  ///
  /// In it, this message translates to:
  /// **'Iscrizione eliminata'**
  String get registrationDeleted;

  /// No description provided for @linkCopied.
  ///
  /// In it, this message translates to:
  /// **'Link copiato negli appunti!'**
  String get linkCopied;

  /// No description provided for @newOption.
  ///
  /// In it, this message translates to:
  /// **'Nuova Opzione'**
  String get newOption;

  /// No description provided for @closeRegistrationsDesc.
  ///
  /// In it, this message translates to:
  /// **'Se chiudi le iscrizioni, non sarà più possibile per nuove squadre registrarsi via web. Il numero massimo di squadre verrà impostato a quello attuale.'**
  String get closeRegistrationsDesc;

  /// No description provided for @confirmDeleteRegGeneric.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare questa iscrizione?'**
  String get confirmDeleteRegGeneric;

  /// No description provided for @confirmAction.
  ///
  /// In it, this message translates to:
  /// **'SÌ, ELIMINA'**
  String get confirmAction;

  /// No description provided for @confirmImport.
  ///
  /// In it, this message translates to:
  /// **'CONFERMA E IMPORTA'**
  String get confirmImport;

  /// No description provided for @teamAlreadyRegistered.
  ///
  /// In it, this message translates to:
  /// **'Questa squadra è già iscritta al torneo!'**
  String get teamAlreadyRegistered;

  /// No description provided for @teamAdded.
  ///
  /// In it, this message translates to:
  /// **'Squadra {name} aggiunta!'**
  String teamAdded(String name);

  /// No description provided for @teamImported.
  ///
  /// In it, this message translates to:
  /// **'SQUADRE IMPORTATE'**
  String get teamImported;

  /// No description provided for @manualParticipants.
  ///
  /// In it, this message translates to:
  /// **'SQUADRE PARTECIPANTI'**
  String get manualParticipants;

  /// No description provided for @tournamentStages.
  ///
  /// In it, this message translates to:
  /// **'INFO'**
  String get tournamentStages;

  /// No description provided for @modeLegend.
  ///
  /// In it, this message translates to:
  /// **'Legenda Modalità'**
  String get modeLegend;

  /// No description provided for @finals.
  ///
  /// In it, this message translates to:
  /// **'Finali'**
  String get finals;

  /// No description provided for @finalSummary.
  ///
  /// In it, this message translates to:
  /// **'RIEPILOGO FINALE'**
  String get finalSummary;

  /// No description provided for @verifyAndCreate.
  ///
  /// In it, this message translates to:
  /// **'Verifica e crea'**
  String get verifyAndCreate;

  /// No description provided for @almostReady.
  ///
  /// In it, this message translates to:
  /// **'QUASI PRONTO!'**
  String get almostReady;

  /// No description provided for @readyToCreateDesc.
  ///
  /// In it, this message translates to:
  /// **'Tutto è configurato correttamente. Clicca su crea per iniziare il torneo.'**
  String get readyToCreateDesc;

  /// No description provided for @onlineRegistrations.
  ///
  /// In it, this message translates to:
  /// **'Iscrizioni Online'**
  String get onlineRegistrations;

  /// No description provided for @active.
  ///
  /// In it, this message translates to:
  /// **'ATTIVE'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In it, this message translates to:
  /// **'DISATTIVATE'**
  String get inactive;

  /// No description provided for @openWebRegistrations.
  ///
  /// In it, this message translates to:
  /// **'ISCRIZIONI ONLINE APERTE'**
  String get openWebRegistrations;

  /// No description provided for @openWebRegistrationsDesc.
  ///
  /// In it, this message translates to:
  /// **'Le squadre potranno registrarsi via web. Pubblicazione Cloud immediata.'**
  String get openWebRegistrationsDesc;

  /// No description provided for @selectTeamsOptional.
  ///
  /// In it, this message translates to:
  /// **'Seleziona squadre (Opzionale)'**
  String get selectTeamsOptional;

  /// No description provided for @publishToCloud_switch.
  ///
  /// In it, this message translates to:
  /// **'Pubblica su Cloud'**
  String get publishToCloud_switch;

  /// No description provided for @publishToCloud_subtitle.
  ///
  /// In it, this message translates to:
  /// **'Rendi il risultato visibile online in tempo reale e condividi il link!'**
  String get publishToCloud_subtitle;

  /// No description provided for @matchTitle_label.
  ///
  /// In it, this message translates to:
  /// **'Titolo Match (opzionale)'**
  String get matchTitle_label;

  /// No description provided for @matchTitle_hint.
  ///
  /// In it, this message translates to:
  /// **'es: Finale Regionale - Court 1'**
  String get matchTitle_hint;

  /// No description provided for @twitch_label.
  ///
  /// In it, this message translates to:
  /// **'Username Twitch (opzionale)'**
  String get twitch_label;

  /// No description provided for @twitch_hint.
  ///
  /// In it, this message translates to:
  /// **'es: trnmnt_official'**
  String get twitch_hint;

  /// No description provided for @explorer.
  ///
  /// In it, this message translates to:
  /// **'Esplora'**
  String get explorer;

  /// No description provided for @cloudHub.
  ///
  /// In it, this message translates to:
  /// **'TRNMNT Hub'**
  String get cloudHub;

  /// No description provided for @liveMatches.
  ///
  /// In it, this message translates to:
  /// **'Partite Live'**
  String get liveMatches;

  /// No description provided for @exploreHub.
  ///
  /// In it, this message translates to:
  /// **'Esplora tornei e partite live'**
  String get exploreHub;

  /// No description provided for @noLiveMatches.
  ///
  /// In it, this message translates to:
  /// **'Nessuna partita live in corso'**
  String get noLiveMatches;

  /// No description provided for @errorLoadingData.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento dei dati'**
  String get errorLoadingData;

  /// No description provided for @hubSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Hub aggiornamenti e risultati live'**
  String get hubSubtitle;

  /// No description provided for @defaultHomeScreen.
  ///
  /// In it, this message translates to:
  /// **'Schermata Iniziale'**
  String get defaultHomeScreen;

  /// No description provided for @dashboard.
  ///
  /// In it, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @hub.
  ///
  /// In it, this message translates to:
  /// **'HUB'**
  String get hub;

  /// No description provided for @radarSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni Radar'**
  String get radarSettings;

  /// No description provided for @enableOsmData.
  ///
  /// In it, this message translates to:
  /// **'Abilita dati OpenStreetMap'**
  String get enableOsmData;

  /// No description provided for @osmDataDesc.
  ///
  /// In it, this message translates to:
  /// **'Mostra i campetti pubblici censiti su OSM.'**
  String get osmDataDesc;

  /// No description provided for @radarDataSourceOsm.
  ///
  /// In it, this message translates to:
  /// **'Fonte OpenStreetMap'**
  String get radarDataSourceOsm;

  /// No description provided for @radarDataSourceLocal.
  ///
  /// In it, this message translates to:
  /// **'TRNMNT'**
  String get radarDataSourceLocal;

  /// No description provided for @syncOsm.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione OSM...'**
  String get syncOsm;

  /// No description provided for @searchInArea.
  ///
  /// In it, this message translates to:
  /// **'CERCA IN QUESTA ZONA'**
  String get searchInArea;

  /// No description provided for @tapMapToAdd.
  ///
  /// In it, this message translates to:
  /// **'TOCCA LA MAPPA PER AGGIUNGERE UN CAMPETTO'**
  String get tapMapToAdd;

  /// No description provided for @addressLabel.
  ///
  /// In it, this message translates to:
  /// **'INDIRIZZO:'**
  String get addressLabel;

  /// No description provided for @surfaceLabel.
  ///
  /// In it, this message translates to:
  /// **'SUPERFICIE:'**
  String get surfaceLabel;

  /// No description provided for @hoopsLabel.
  ///
  /// In it, this message translates to:
  /// **'CANESTRI:'**
  String get hoopsLabel;

  /// No description provided for @litLabel.
  ///
  /// In it, this message translates to:
  /// **'ILLUMINAZIONE:'**
  String get litLabel;

  /// No description provided for @accessLabel.
  ///
  /// In it, this message translates to:
  /// **'ACCESSO:'**
  String get accessLabel;

  /// No description provided for @otherSportsLabel.
  ///
  /// In it, this message translates to:
  /// **'ALTRI SPORT:'**
  String get otherSportsLabel;

  /// No description provided for @lastCheckLabel.
  ///
  /// In it, this message translates to:
  /// **'ULTIMO CONTROLLO:'**
  String get lastCheckLabel;

  /// No description provided for @osmSourceInfo.
  ///
  /// In it, this message translates to:
  /// **'FONTE: OpenStreetMap'**
  String get osmSourceInfo;

  /// No description provided for @addToMyCourts.
  ///
  /// In it, this message translates to:
  /// **'AGGIUNGI AI MIEI'**
  String get addToMyCourts;

  /// No description provided for @netsStatusLabel.
  ///
  /// In it, this message translates to:
  /// **'Stato reti'**
  String get netsStatusLabel;

  /// No description provided for @starsLabel.
  ///
  /// In it, this message translates to:
  /// **'Stelle:'**
  String get starsLabel;

  /// No description provided for @netsLabel.
  ///
  /// In it, this message translates to:
  /// **'Reti:'**
  String get netsLabel;

  /// No description provided for @osmFoundCount.
  ///
  /// In it, this message translates to:
  /// **'OSM: Trovati {count} campetti'**
  String osmFoundCount(int count);

  /// No description provided for @osmFoundCount_desc.
  ///
  /// In it, this message translates to:
  /// **'Messaggio di conferma dei risultati trovati su OSM'**
  String get osmFoundCount_desc;

  /// No description provided for @courtSaved.
  ///
  /// In it, this message translates to:
  /// **'Campetto salvato!'**
  String get courtSaved;

  /// No description provided for @searchingOsmNearby.
  ///
  /// In it, this message translates to:
  /// **'CERCO CAMPETTI OSM VICINI...'**
  String get searchingOsmNearby;

  /// No description provided for @noOsmCourtsFound.
  ///
  /// In it, this message translates to:
  /// **'NESSUN CAMPETTO OSM TROVATO IN QUESTA ZONA'**
  String get noOsmCourtsFound;

  /// No description provided for @osmResultsTitle.
  ///
  /// In it, this message translates to:
  /// **'RISULTATI OPENSTREETMAP'**
  String get osmResultsTitle;

  /// No description provided for @selectCourt.
  ///
  /// In it, this message translates to:
  /// **'Seleziona Campetto'**
  String get selectCourt;

  /// No description provided for @courtSelected.
  ///
  /// In it, this message translates to:
  /// **'Campetto: {name}'**
  String courtSelected(String name);

  /// No description provided for @optional.
  ///
  /// In it, this message translates to:
  /// **'Opzionale'**
  String get optional;

  /// No description provided for @radar_court_link.
  ///
  /// In it, this message translates to:
  /// **'COLLEGAMENTO RADAR'**
  String get radar_court_link;

  /// No description provided for @description.
  ///
  /// In it, this message translates to:
  /// **'Descrizione'**
  String get description;
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
      <String>['en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
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
