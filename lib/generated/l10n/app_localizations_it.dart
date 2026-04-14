// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'TRNMNT';

  @override
  String get teams => 'Squadre';

  @override
  String get singleMatch => 'Partita Singola';

  @override
  String get tournaments => 'Tornei';

  @override
  String get newTournament => 'Nuovo Torneo';

  @override
  String get map => 'Mappa';

  @override
  String get settings => 'Impostazioni';

  @override
  String get statistics => 'Statistiche';

  @override
  String get appStatistics => 'Statistiche App';

  @override
  String get totalTeams => 'Squadre Totali';

  @override
  String get courts => 'Campetti';

  @override
  String get tournamentsCreated => 'Tornei Creati';

  @override
  String get inProgress => 'In Corso';

  @override
  String get matchesPlayed => 'Partite Giocate';

  @override
  String get pointsScored => 'Punti Segnati';

  @override
  String get hallOfFame => 'Albo d\'Oro';

  @override
  String get noTournamentsRecorded => 'Nessun torneo registrato al momento.';

  @override
  String winner(String team) {
    return '🏆 Vincitore: $team';
  }

  @override
  String get inProgressOrToBeDecided => '⏳ In Corso / Da decidere';

  @override
  String teamRecord(int wins, int losses) {
    return 'Record squadra: $wins V - $losses S';
  }

  @override
  String points(int pf, int ps) {
    return 'Punti: PF $pf / PS $ps';
  }

  @override
  String get appLanguage => 'Lingua App';

  @override
  String get selectLanguage => 'Seleziona la lingua';

  @override
  String get developedBy => 'Sviluppato da';

  @override
  String get tapToVisitLinks => 'Tocca per visitare i link';

  @override
  String get appVersion => 'Versione App';

  @override
  String get followUsOnSocial => 'Seguici sui social';

  @override
  String get timer => 'Cronometro';

  @override
  String get manageTeams => 'Gestisci le squadre';

  @override
  String get manageSingleMatch => 'Gestisci una partita singola';

  @override
  String get createAndManage => 'Crea e gestisci';

  @override
  String get startNow => 'Inizia subito';

  @override
  String get courtsMap => 'La mappa dei campetti';

  @override
  String get appOptions => 'Opzioni app';

  @override
  String get dataAndNumbers => 'Dati e numeri';

  @override
  String get appSubtitle => 'Gestione Tornei di Basket';

  @override
  String courtStatus(String status) {
    return 'Stato campo: $status';
  }

  @override
  String starsCount(int count) {
    return 'Livello: $count/5';
  }

  @override
  String get wellMaintained => 'Ben mantenuto';

  @override
  String get playable => 'Giocabile';

  @override
  String get poorCondition => 'Preso male';

  @override
  String get cloth => 'Stoffa';

  @override
  String get metal => 'Ferro';

  @override
  String get broken => 'Rotte';

  @override
  String get notPresent => 'Non presenti';

  @override
  String get wellDefined => 'Ben definite';

  @override
  String get visible => 'Visibili';

  @override
  String get damaged => 'Rovinate';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String hoopsCount(int count) {
    return 'Canestri: $count';
  }

  @override
  String get netsTitle => 'Retine';

  @override
  String get courtTitle => 'Campo';

  @override
  String get linesTitle => 'Linee';

  @override
  String get lightsTitle => 'Luci';

  @override
  String get saveAction => 'SALVA';

  @override
  String get newCourtTitle => 'Nuovo Campetto';

  @override
  String get nameLabel => 'Nome';

  @override
  String get descLabel => 'Descrizione';

  @override
  String get tapMapInstruction => 'Tocca la mappa per aggiungere';

  @override
  String get positionSaved => 'Posizione mappa salvata!';

  @override
  String get addAction => 'Aggiungi';

  @override
  String get hoops => 'Canestri';

  @override
  String get rating => 'Valutazione';

  @override
  String get edit => 'Modifica';

  @override
  String get myTournaments => 'I Miei Tornei';

  @override
  String get deleteTournament => 'Elimina torneo';

  @override
  String confirmDeleteTournament(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get noTournaments => 'Nessun torneo';

  @override
  String get createFirstTournament => 'Crea il tuo primo torneo di basket';

  @override
  String get createTournament => 'Crea Torneo';

  @override
  String get groupOnly => 'Campionato';

  @override
  String get eliminationOnly => 'Playoff';

  @override
  String get groupAndElimination => 'Campionato & Playoff';

  @override
  String get madness => 'Madness';

  @override
  String get consolationFinals => 'Finali consolazione';

  @override
  String location(String loc) {
    return '📍 $loc';
  }

  @override
  String teamsAndMode(int count, String mode) {
    return '🏀 $count squadre - $mode';
  }

  @override
  String get singleMatchSetup => 'Setup Partita Singola';

  @override
  String get noTeamsInDatabase => 'Nessuna squadra presente nel database.';

  @override
  String get createTeam => 'Crea Squadra';

  @override
  String get selectTeamsForMatch =>
      'Seleziona le squadre per la partita singola';

  @override
  String get homeTeam => 'Squadra in casa';

  @override
  String get awayTeam => 'Squadra in trasferta';

  @override
  String get selectATeam => 'Seleziona una squadra';

  @override
  String get selectDifferentTeams => 'Scegli due squadre diverse';

  @override
  String get startMatch => 'Inizia Partita';

  @override
  String get theme => 'Tema';

  @override
  String get baseTheme => 'Tema Base (Vibrante)';

  @override
  String get darkTheme => 'Tema Scuro (Puro)';

  @override
  String get lightTheme => 'Tema Chiaro';

  @override
  String get developers => 'Sviluppatori';

  @override
  String get officialWebsite => 'Sito Ufficiale';

  @override
  String unableToOpenUrl(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String get matchInProgress => 'Partita in corso';

  @override
  String get resetMatch => 'Azzera partita';

  @override
  String get confirmResetMatch =>
      'Sei sicuro di voler riportare il punteggio e il periodo a 0?';

  @override
  String get durationMinutes => 'Durata (minuti)';

  @override
  String get periodLabel => 'PERIODO';

  @override
  String get selectAtLeastTwoTeams => 'Seleziona almeno 2 squadre';

  @override
  String get infoStep => 'Informazioni';

  @override
  String get infoSubtitle => 'Nome e luogo';

  @override
  String get configStep => 'Configurazione';

  @override
  String get configSubtitle => 'Modalità e punteggio';

  @override
  String get teamsStep => 'Squadre';

  @override
  String teamsSelected(int count) {
    return '$count selezionate';
  }

  @override
  String get tournamentName => 'Nome Torneo';

  @override
  String get tournamentLocation => 'Luogo';

  @override
  String get enterTournamentName => 'Inserisci il nome del torneo';

  @override
  String get enterTournamentLocation => 'Inserisci il luogo del torneo';

  @override
  String get tournamentMode => 'Modalità Torneo';

  @override
  String get scoringSystem => 'Sistema Punteggio';

  @override
  String get win => 'Vittoria';

  @override
  String get draw => 'Pareggio';

  @override
  String get loss => 'Sconfitta';

  @override
  String get classicBasketball => 'Basket Classico';

  @override
  String get standardFootball => 'Calcio Standard';

  @override
  String get custom => 'Personalizzato';

  @override
  String get setYourScores => 'Imposta i tuoi punteggi';

  @override
  String get consolationFinalsSubtitle => '3°/4° posto, 5°/6°, etc.';

  @override
  String matchTimer(int min) {
    return 'Timer Partita: $min minuti';
  }

  @override
  String get searchTeam => 'Cerca Squadra';

  @override
  String get selectParticipatingTeams =>
      'Seleziona le squadre partecipanti (min. 2)';

  @override
  String get oddTeamsBye =>
      'Squadre dispari: verrà gestito automaticamente il riposo (BYE)';

  @override
  String get selectAll => 'Seleziona tutti';

  @override
  String get deselectAll => 'Deseleziona tutti';

  @override
  String get noTeamsFound => 'Nessuna squadra trovata';

  @override
  String get continueAction => 'Continua';

  @override
  String get backAction => 'Indietro';

  @override
  String get groupOnlySubtitle => 'Round-robin, classifica finale';

  @override
  String get eliminationOnlySubtitle => 'Vinci o vai a casa';

  @override
  String get groupAndEliminationSubtitle => 'Campionato poi Playoff';

  @override
  String get madnessSubtitle => 'Chi vince regna, alta intensità!';

  @override
  String get error => 'Errore';

  @override
  String get notFound => 'Non trovato';

  @override
  String get tournamentNotFound => 'Torneo non trovato';

  @override
  String get participatingTeams => 'Squadre Partecipanti';

  @override
  String get tournamentManagement => 'Gestione Torneo';

  @override
  String get calendar => 'Calendario';

  @override
  String get groupPhase => 'Fase a gironi';

  @override
  String get standings => 'Classifica';

  @override
  String get pointsAndStats => 'Punti e statistiche';

  @override
  String get elimination => 'Eliminatoria';

  @override
  String get playoffBracket => 'Bracket playoff';

  @override
  String get timerLabel => 'Timer';

  @override
  String minutesX(int count) {
    return '$count minuti';
  }

  @override
  String get tournamentDate => 'Data Torneo';

  @override
  String get navHome => 'Home';

  @override
  String get navTeams => 'Squadre';

  @override
  String get navTournaments => 'Tornei';

  @override
  String get navTimer => 'Timer';

  @override
  String get appIcon => 'Icona App';

  @override
  String get changeAppIcon => 'Cambia Icona App';

  @override
  String get pickImageIcon => 'Seleziona immagine';

  @override
  String get resetIcon => 'Ripristina icona predefinita';

  @override
  String get viewWinners => 'Vedi i vincitori';

  @override
  String get share => 'Condividi';

  @override
  String get scanTournament => 'Scansiona Torneo';

  @override
  String get syncFromScout => 'Sincronizza da Scout';

  @override
  String get readOnlyTournament =>
      'Questo torneo è in sola lettura perché è stato importato.';

  @override
  String get apiSettings => 'Impostazioni API';

  @override
  String get apiUrl => 'URL Server API';

  @override
  String get apiUrlHint => 'Esempio: https://trnmnt.vercel.app';

  @override
  String get testConnection => 'Testa Connessione';

  @override
  String get connectionWorking => 'Connessione funzionante!';

  @override
  String get connectionError => 'Errore di connessione';

  @override
  String get publishToWeb => 'Sincronizza sul Cloud';

  @override
  String get openInBrowser => 'Apri nel Browser';

  @override
  String get teamOrder => 'Ordine Squadre';

  @override
  String get dragToReorder => 'Trascina per spostare';

  @override
  String get madnessOrderSubtitle =>
      'L\'ordine delle squadre determina il bracket Madness.';

  @override
  String get live => 'Live';

  @override
  String get matchDetail => 'Dettaglio Partita';

  @override
  String get quit => 'Esci';

  @override
  String get rules => 'Regole';

  @override
  String get viewTournamentRules => 'Vedi le regole del torneo';

  @override
  String get multiGroup => 'Gironi Multipli';

  @override
  String get groupCountLabel => 'Numero di Gironi';

  @override
  String get teamsPerGroup => 'Squadre per Girone';

  @override
  String get randomDistribution => 'Distribuzione Casuale';

  @override
  String get manualDistribution => 'Distribuzione Manuale';

  @override
  String get qualifiersPerGroupLabel => 'Qualificati per Girone';

  @override
  String get hasPlayInLabel => 'Includi Spareggi (Play-In)';

  @override
  String get editGroups => 'Gestisci i Gironi';

  @override
  String get distributeTeams => 'Distribuisci le squadre nei gironi';

  @override
  String get groupNameHint => 'Nome Girone (es. A, B...)';

  @override
  String get upcoming => 'Prossimamente';

  @override
  String get concluded => 'Concluso';

  @override
  String get playIn => 'Spareggi';

  @override
  String get modeLockedWarning =>
      'La modalità non può essere cambiata perché il torneo è già iniziato.';

  @override
  String get cloudCollaboration => 'Co-gestione Cloud';

  @override
  String get inviteAdmin => 'Invita Organizzatore';

  @override
  String get cloudSyncActive => 'Sincronizzazione Cloud attiva';

  @override
  String get tournamentImportedAndSynced =>
      'Torneo importato e sincronizzato! 🤝🏀';

  @override
  String get cloudFetching => 'Recupero dati dal Cloud...';

  @override
  String get syncError => 'Errore di sincronizzazione';

  @override
  String cloudIdLabel(String id) {
    return 'ID Cloud: $id';
  }

  @override
  String get publishToCloud_title => 'Pubblica sul Cloud';

  @override
  String get publishToCloud_desc =>
      'Sincronizza il torneo per abilitare la Dashboard Web e la Co-Gestione.';

  @override
  String get publishNow => 'Pubblica Ora';

  @override
  String get myCommunity => 'La mia Community';

  @override
  String get manageYourBrand => 'Gestisci il tuo Brand';

  @override
  String get liveHighlights => 'LIVE HIGHLIGHTS';

  @override
  String get noTournamentsAtMoment => 'Non ci sono tornei al momento';

  @override
  String get activeTournamentMatch => 'PARTITA TORNEO LIVE';

  @override
  String get future => 'Futuri';

  @override
  String get past => 'Passati';

  @override
  String get mapDataSourceLocal => 'Aggiunti in app';

  @override
  String get mapDataSourcePickRoll => 'Fonte Pick&Roll';
}
