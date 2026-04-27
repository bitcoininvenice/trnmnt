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
  String get teams => 'Le mie squadre';

  @override
  String get singleMatch => 'Partita Singola';

  @override
  String get tournaments => 'Tornei';

  @override
  String get newTournament => 'Nuovo Torneo';

  @override
  String get radar => 'Radar';

  @override
  String get settings => 'Impostazioni';

  @override
  String get statistics => 'Statistiche';

  @override
  String get appStatistics => 'Statistiche App';

  @override
  String get myCommunity => 'La mia Community';

  @override
  String get communityManagement => 'Gestione Community';

  @override
  String get manageBrandsLogos => 'Gestisci brand';

  @override
  String get joinCommunity => 'Unisciti a una Community';

  @override
  String get scanQrInvitation => 'Scansiona QR Invito';

  @override
  String get createNewCommunity => 'CREA NUOVA COMMUNITY';

  @override
  String get adminStatus => 'Sei l\'amministratore di questa community.';

  @override
  String get collaboratorStatus => 'Sei un collaboratore di questa community.';

  @override
  String get shareInvitation => 'Condividi Invito';

  @override
  String get scanQrInstructions =>
      'Inquadra il QR Code fornito dall\'organizzatore';

  @override
  String get scanQrTitle => 'Scansiona QR Community';

  @override
  String get joinedCommunitySuccess => 'Ti sei unito alla community! 🏀';

  @override
  String get errorJoiningCommunity => 'Errore durante l\'unione. Riprova.';

  @override
  String get onlyAdminCanEdit =>
      'Solo l\'amministratore può modificare l\'identità della community.';

  @override
  String get communityIdentityDesc =>
      'Crea la tua identità per organizzare tornei sotto il tuo brand, o scansiona il QR di un collega per collaborare.';

  @override
  String get updateData => 'AGGIORNA DATI';

  @override
  String get saveCommunity => 'COMMUNITY AGGIORNATA';

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
  String get radarSubtitle => 'Radar';

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
  String get name => 'Nome';

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
  String periodLabel(Object period) {
    return 'PERIODO $period';
  }

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
  String get tournamentDate => 'Data e orario inizio torneo';

  @override
  String get tournamentEndDate => 'Data e orario fine torneo';

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
  String get all => 'Tutti';

  @override
  String get upcoming => 'In programma';

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
  String get manageYourBrand => 'Gestisci il tuo Brand';

  @override
  String get liveHighlights => 'IN EVIDENZA';

  @override
  String get statsOverview => 'STATISTICHE APP';

  @override
  String get noTournamentsAtMoment => 'Non ci sono tornei al momento';

  @override
  String get activeTournamentMatch => 'PARTITA TORNEO LIVE';

  @override
  String get future => 'In programma';

  @override
  String get past => 'Passati';

  @override
  String get syncSuccess => 'Sincronizzato sul Cloud! ☁️🏀';

  @override
  String get webResult => 'Risultati Web';

  @override
  String get coManagement => 'Co-Gestione';

  @override
  String get publicDashboard => 'DASHBOARD PUBBLICA';

  @override
  String get coManagementTitle => 'CO-GESTIONE CLOUD';

  @override
  String get publicDashboardDesc => 'Chiunque può vedere i risultati live';

  @override
  String get coManagementDesc =>
      'Invita un altro organizzatore a gestire il torneo';

  @override
  String get cloudSettings => 'IMPOSTAZIONI CLOUD';

  @override
  String get liveLocationLabel => 'LOCATION LIVE';

  @override
  String get locationHint => 'Es: Playground San Alvise';

  @override
  String get twitchChannelLabel => 'CANALE TWITCH';

  @override
  String get twitchHint => 'Es: venicestreetball';

  @override
  String get youtubeVideoLabel => 'ID VIDEO YOUTUBE';

  @override
  String get youtubeHint => 'Es: dQw4w9WgXcQ';

  @override
  String get customTickerLabel => 'TESTO SCORREVOLE (TICKER)';

  @override
  String get tickerHint => 'Sponsor, annunci community...';

  @override
  String get tickerAutoDesc =>
      'Lascia vuoto per utilizzare il testo generato dal sistema.';

  @override
  String get copyLink => 'Copia link';

  @override
  String get openPage => 'Apri Pagina';

  @override
  String get syncing => 'Sincronizzazione...';

  @override
  String get syncCloud => 'Sincronizza Cloud';

  @override
  String get urlSlug => 'URL Slug';

  @override
  String get locationLabel => 'Location';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get tiktokLabel => 'TikTok';

  @override
  String get invalidName => 'Inserisci un nome valido';

  @override
  String get invalidUrl => 'Inserisci un URL valido';

  @override
  String get noActiveInvite =>
      'Nessun invito attivo o scaduto. Generane uno nuovo.';

  @override
  String expiryDate(String time, String date) {
    return 'Scadenza: $time del $date';
  }

  @override
  String get regenerateInvite => 'RIGENERA';

  @override
  String get generateInviteAction => 'GENERA INVITO';

  @override
  String get slugAlreadyExists =>
      'Questo URL è già occupato da un\'altra community.';

  @override
  String get close => 'CHIUDI';

  @override
  String get registrations => 'Iscrizioni';

  @override
  String get manageRegistrations => 'Gestisci Iscrizioni';

  @override
  String get enableWebRegistrations => 'Abilita Iscrizioni Online';

  @override
  String get registrationsNotActive => 'ISCRIZIONI NON ATTIVE';

  @override
  String get createPublicPageDesc =>
      'Crea la pagina pubblica per permettere alle squadre di iscriversi online.';

  @override
  String get activateNow => 'ATTIVA ORA';

  @override
  String get configureRegistrations => 'CONFIGURA ISCRIZIONI';

  @override
  String get maxTeamsLabel => 'Numero Massimo Squadre';

  @override
  String get enableLunchChoice => 'Abilita Scelta Pranzo';

  @override
  String get addOption => 'Aggiungi Opzione';

  @override
  String get createPage => 'CREA PAGINA';

  @override
  String get onlineRegistrationsEnabled => 'Iscrizioni Online Abilitate!';

  @override
  String get registeredTeams => 'SQUADRE ISCRITTE';

  @override
  String get registrationsClosed => 'ISCRIZIONI CHIUSE';

  @override
  String get closeNow => 'CHIUDI ORA';

  @override
  String get noRegistrationsYet => 'Ancora nessuna iscrizione ricevuta';

  @override
  String get confirmed => 'Confermato';

  @override
  String get players => 'GIOCATORI';

  @override
  String get lunchOptions => 'Opzioni Pranzo';

  @override
  String get deleteRegistration => 'Elimina Iscrizione';

  @override
  String confirmDeleteRegistration(String team) {
    return 'Sei sicuro di voler eliminare l\'iscrizione di \"$team\"?';
  }

  @override
  String get registrationDeleted => 'Iscrizione eliminata';

  @override
  String get linkCopied => 'Link copiato negli appunti!';

  @override
  String get newOption => 'Nuova Opzione';

  @override
  String get closeRegistrationsDesc =>
      'Se chiudi le iscrizioni, non sarà più possibile per nuove squadre registrarsi via web. Il numero massimo di squadre verrà impostato a quello attuale.';

  @override
  String get confirmDeleteRegGeneric =>
      'Sei sicuro di voler eliminare questa iscrizione?';

  @override
  String get confirmAction => 'SÌ, ELIMINA';

  @override
  String get confirmImport => 'CONFERMA E IMPORTA';

  @override
  String get teamAlreadyRegistered =>
      'Questa squadra è già iscritta al torneo!';

  @override
  String teamAdded(String name) {
    return 'Squadra $name aggiunta!';
  }

  @override
  String get teamImported => 'SQUADRE IMPORTATE';

  @override
  String get manualParticipants => 'SQUADRE PARTECIPANTI';

  @override
  String get tournamentStages => 'INFO';

  @override
  String get modeLegend => 'Legenda Modalità';

  @override
  String get finals => 'Finali';

  @override
  String get finalSummary => 'RIEPILOGO FINALE';

  @override
  String get verifyAndCreate => 'Verifica e crea';

  @override
  String get almostReady => 'QUASI PRONTO!';

  @override
  String get readyToCreateDesc =>
      'Tutto è configurato correttamente. Clicca su crea per iniziare il torneo.';

  @override
  String get onlineRegistrations => 'Iscrizioni Online';

  @override
  String get active => 'ATTIVE';

  @override
  String get inactive => 'DISATTIVATE';

  @override
  String get openWebRegistrations => 'ISCRIZIONI ONLINE APERTE';

  @override
  String get openWebRegistrationsDesc =>
      'Le squadre potranno registrarsi via web. Pubblicazione Cloud immediata.';

  @override
  String get selectTeamsOptional => 'Seleziona squadre (Opzionale)';

  @override
  String get publishToCloud_switch => 'Pubblica su Cloud';

  @override
  String get publishToCloud_subtitle =>
      'Rendi il risultato visibile online in tempo reale e condividi il link!';

  @override
  String get matchTitle_label => 'Titolo Match (opzionale)';

  @override
  String get matchTitle_hint => 'es: Finale Regionale - Court 1';

  @override
  String get twitch_label => 'Username Twitch (opzionale)';

  @override
  String get twitch_hint => 'es: trnmnt_official';

  @override
  String get explorer => 'Esplora';

  @override
  String get cloudHub => 'TRNMNT Hub';

  @override
  String get liveMatches => 'Partite Live';

  @override
  String get exploreHub => 'Esplora tornei e partite live';

  @override
  String get noLiveMatches => 'Nessuna partita live in corso';

  @override
  String get errorLoadingData => 'Errore nel caricamento dei dati';

  @override
  String get hubSubtitle => 'Hub aggiornamenti e risultati live';

  @override
  String get defaultHomeScreen => 'Schermata Iniziale';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hub => 'HUB';

  @override
  String get radarSettings => 'Impostazioni Radar';

  @override
  String get enableOsmData => 'Abilita dati OpenStreetMap';

  @override
  String get osmDataDesc => 'Mostra i campetti pubblici censiti su OSM.';

  @override
  String get radarDataSourceOsm => 'Fonte OpenStreetMap';

  @override
  String get radarDataSourceLocal => 'TRNMNT';

  @override
  String get syncOsm => 'Sincronizzazione OSM...';

  @override
  String get searchInArea => 'CERCA IN QUESTA ZONA';

  @override
  String get tapMapToAdd => 'TOCCA LA MAPPA PER AGGIUNGERE UN CAMPETTO';

  @override
  String get addressLabel => 'INDIRIZZO:';

  @override
  String get surfaceLabel => 'SUPERFICIE:';

  @override
  String get hoopsLabel => 'CANESTRI:';

  @override
  String get litLabel => 'ILLUMINAZIONE:';

  @override
  String get accessLabel => 'ACCESSO:';

  @override
  String get otherSportsLabel => 'ALTRI SPORT:';

  @override
  String get lastCheckLabel => 'ULTIMO CONTROLLO:';

  @override
  String get osmSourceInfo => 'FONTE: OpenStreetMap';

  @override
  String get addToMyCourts => 'AGGIUNGI AI MIEI';

  @override
  String get netsStatusLabel => 'Stato reti';

  @override
  String get starsLabel => 'Stelle:';

  @override
  String get netsLabel => 'Reti:';

  @override
  String osmFoundCount(int count) {
    return 'OSM: Trovati $count campetti';
  }

  @override
  String get osmFoundCount_desc =>
      'Messaggio di conferma dei risultati trovati su OSM';

  @override
  String get courtSaved => 'Campetto salvato!';

  @override
  String get searchingOsmNearby => 'CERCO CAMPETTI OSM VICINI...';

  @override
  String get noOsmCourtsFound => 'NESSUN CAMPETTO OSM TROVATO IN QUESTA ZONA';

  @override
  String get osmResultsTitle => 'RISULTATI OPENSTREETMAP';

  @override
  String get selectCourt => 'Seleziona Campetto';

  @override
  String courtSelected(String name) {
    return 'Campetto: $name';
  }

  @override
  String get optional => 'Opzionale';

  @override
  String get radar_court_link => 'COLLEGAMENTO RADAR';

  @override
  String get description => 'Descrizione';

  @override
  String get leaveCommunityTitle => 'Abbandona Community';

  @override
  String get removeCommunityTitle => 'Rimuovi dal Dispositivo';

  @override
  String get leaveCommunityOwnerDesc =>
      'La community rimarrà sul server senza proprietario.\nPotrai rivendicarla in seguito tramite il pannello admin.\n\n⚠️ Tutti i tornei e i team locali collegati verranno eliminati dal dispositivo.';

  @override
  String get leaveCommunityMemberDesc =>
      'Questa community e tutti i tornei locali collegati verranno rimossi dal dispositivo.\n\nI dati sul server restano invariati.';

  @override
  String get leaveCommunityAction => 'Abbandona community dal dispositivo';

  @override
  String get removeCommunityAction => 'Rimuovi community dal dispositivo';

  @override
  String get leaveAction => 'Abbandona';

  @override
  String get removeAction => 'Rimuovi';

  @override
  String get rlsViolationError =>
      'Errore di sicurezza: hai già una community attiva sul cloud o i permessi sono insufficienti. Controlla le policy RLS.';

  @override
  String get sessionError =>
      'Sessione scaduta o non valida. Effettua nuovamente l\'accesso.';

  @override
  String get liveStream => 'LIVE STREAM';

  @override
  String get watchTournamentLive => 'Guarda il torneo live';

  @override
  String get retry => 'RIPROVA';
}
