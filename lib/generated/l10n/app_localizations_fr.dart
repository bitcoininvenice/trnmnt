// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TRNMNT';

  @override
  String get teams => 'Mes Équipes';

  @override
  String get singleMatch => 'Match Simple';

  @override
  String get tournaments => 'Tournois';

  @override
  String get newTournament => 'Nouveau Tournoi';

  @override
  String get radar => 'Radar';

  @override
  String get settings => 'Paramètres';

  @override
  String get statistics => 'Statistiques';

  @override
  String get appStatistics => 'Statistiques App';

  @override
  String get myCommunity => 'Ma Communauté';

  @override
  String get communityManagement => 'Gestion Communauté';

  @override
  String get manageBrandsLogos => 'Gérer les marques';

  @override
  String get joinCommunity => 'Rejoindre une Communauté';

  @override
  String get scanQrInvitation => 'Scanner Invitation QR';

  @override
  String get createNewCommunity => 'CRÉER NOUVELLE COMMUNAUTÉ';

  @override
  String get adminStatus => 'Vous êtes l\'administrateur de cette communauté.';

  @override
  String get collaboratorStatus =>
      'Vous êtes un collaborateur de cette communauté.';

  @override
  String get shareInvitation => 'Partager l\'Invitation';

  @override
  String get scanQrInstructions =>
      'Cadrez le code QR fourni par l\'organisateur';

  @override
  String get scanQrTitle => 'Scanner QR Communauté';

  @override
  String get joinedCommunitySuccess => 'Vous avez rejoint la communauté ! 🏀';

  @override
  String get errorJoiningCommunity => 'Erreur lors de la jointure. Réessayez.';

  @override
  String get onlyAdminCanEdit =>
      'Seul l\'administrateur peut modifier l\'identité de la communauté.';

  @override
  String get communityIdentityDesc =>
      'Créez votre identité pour organiser des tournois sous votre marque, ou scannez le QR d\'un collègue pour collaborer.';

  @override
  String get updateData => 'METTRE À JOUR LES DONNÉES';

  @override
  String get saveCommunity => 'COMMUNAUTÉ MISE À JOUR';

  @override
  String get totalTeams => 'Équipes Totales';

  @override
  String get courts => 'Terrains';

  @override
  String get tournamentsCreated => 'Tournois Créés';

  @override
  String get inProgress => 'En Cours';

  @override
  String get matchesPlayed => 'Matchs Joués';

  @override
  String get pointsScored => 'Points Marqués';

  @override
  String get hallOfFame => 'Temple de la Renommée';

  @override
  String get noTournamentsRecorded =>
      'Aucun tournoi enregistré pour le moment.';

  @override
  String winner(String team) {
    return '🏆 Vainqueur : $team';
  }

  @override
  String get inProgressOrToBeDecided => '⏳ En Cours / À décider';

  @override
  String teamRecord(int wins, int losses) {
    return 'Record équipe : $wins V - $losses D';
  }

  @override
  String points(int pf, int ps) {
    return 'Points : PM $pf / PE $ps';
  }

  @override
  String get appLanguage => 'Langue App';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get developedBy => 'Développé par';

  @override
  String get tapToVisitLinks => 'Appuyez pour visiter les liens';

  @override
  String get appVersion => 'Version App';

  @override
  String get followUsOnSocial => 'Suivez-nous sur les réseaux sociaux';

  @override
  String get timer => 'Chronomètre';

  @override
  String get manageTeams => 'Gérer les équipes';

  @override
  String get manageSingleMatch => 'Gérer un match simple';

  @override
  String get createAndManage => 'Créer et gérer';

  @override
  String get startNow => 'Commencer maintenant';

  @override
  String get radarSubtitle => 'Radar';

  @override
  String get appOptions => 'Options app';

  @override
  String get dataAndNumbers => 'Données et chiffres';

  @override
  String get appSubtitle => 'Gestion de Tournois de Basket';

  @override
  String courtStatus(String status) {
    return 'État terrain : $status';
  }

  @override
  String starsCount(int count) {
    return 'Niveau : $count/5';
  }

  @override
  String get wellMaintained => 'Bien entretenu';

  @override
  String get playable => 'Jouable';

  @override
  String get poorCondition => 'Mauvais état';

  @override
  String get cloth => 'Tissu';

  @override
  String get metal => 'Fer';

  @override
  String get broken => 'Cassé';

  @override
  String get notPresent => 'Absent';

  @override
  String get wellDefined => 'Bien définies';

  @override
  String get visible => 'Visibles';

  @override
  String get damaged => 'Abîmées';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String hoopsCount(int count) {
    return 'Paniers : $count';
  }

  @override
  String get netsTitle => 'Filets';

  @override
  String get courtTitle => 'Terrain';

  @override
  String get linesTitle => 'Lignes';

  @override
  String get lightsTitle => 'Lumières';

  @override
  String get saveAction => 'ENREGISTRER';

  @override
  String get newCourtTitle => 'Nouveau Terrain';

  @override
  String get name => 'Nom';

  @override
  String get nameLabel => 'Nom';

  @override
  String get descLabel => 'Description';

  @override
  String get tapMapInstruction => 'Appuyez sur la carte pour ajouter';

  @override
  String get positionSaved => 'Position carte enregistrée !';

  @override
  String get addAction => 'Ajouter';

  @override
  String get hoops => 'Paniers';

  @override
  String get rating => 'Évaluation';

  @override
  String get edit => 'Modifier';

  @override
  String get myTournaments => 'Mes Tournois';

  @override
  String get deleteTournament => 'Supprimer tournoi';

  @override
  String confirmDeleteTournament(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get noTournaments => 'Aucun tournoi';

  @override
  String get createFirstTournament => 'Créez votre premier tournoi de basket';

  @override
  String get createTournament => 'Créer Tournoi';

  @override
  String get groupOnly => 'Ligue';

  @override
  String get eliminationOnly => 'Playoff';

  @override
  String get groupAndElimination => 'Ligue & Playoff';

  @override
  String get leagueMadness => 'Ligue + Madness';

  @override
  String get madness => 'Madness';

  @override
  String get consolationFinals => 'Finales consolation';

  @override
  String location(String loc) {
    return '📍 $loc';
  }

  @override
  String teamsAndMode(int count, String mode) {
    return '🏀 $count équipes - $mode';
  }

  @override
  String get singleMatchSetup => 'Configuration Match Simple';

  @override
  String get noTeamsInDatabase => 'Aucune équipe dans la base de données.';

  @override
  String get createTeam => 'Créer Équipe';

  @override
  String get selectTeamsForMatch =>
      'Sélectionnez les équipes pour le match simple';

  @override
  String get homeTeam => 'Équipe Domicile';

  @override
  String get awayTeam => 'Équipe Extérieur';

  @override
  String get selectATeam => 'Sélectionnez une équipe';

  @override
  String get selectDifferentTeams => 'Choisissez deux équipes différentes';

  @override
  String get startMatch => 'Commencer Match';

  @override
  String get theme => 'Thème';

  @override
  String get baseTheme => 'Thème Base (Vibrant)';

  @override
  String get darkTheme => 'Thème Sombre (Pur)';

  @override
  String get lightTheme => 'Thème Clair';

  @override
  String get developers => 'Développeurs';

  @override
  String get officialWebsite => 'Site Officiel';

  @override
  String unableToOpenUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get matchInProgress => 'Match en cours';

  @override
  String get resetMatch => 'Réinitialiser match';

  @override
  String get confirmResetMatch =>
      'Êtes-vous sûr de vouloir remettre le score et la période à 0 ?';

  @override
  String get durationMinutes => 'Durée (minutes)';

  @override
  String periodLabel(Object period) {
    return 'PÉRIODE $period';
  }

  @override
  String get selectAtLeastTwoTeams => 'Sélectionnez au moins 2 équipes';

  @override
  String get infoStep => 'Informations';

  @override
  String get infoSubtitle => 'Nom et lieu';

  @override
  String get configStep => 'Configuration';

  @override
  String get configSubtitle => 'Mode et score';

  @override
  String get teamsStep => 'Équipes';

  @override
  String teamsSelected(int count) {
    return '$count sélectionnées';
  }

  @override
  String get tournamentName => 'Nom Tournoi';

  @override
  String get tournamentLocation => 'Lieu';

  @override
  String get enterTournamentName => 'Entrez le nom du tournoi';

  @override
  String get enterTournamentLocation => 'Entrez le lieu du tournoi';

  @override
  String get tournamentMode => 'Mode Tournoi';

  @override
  String get scoringSystem => 'Système de Score';

  @override
  String get win => 'Victoire';

  @override
  String get draw => 'Égalité';

  @override
  String get loss => 'Défaite';

  @override
  String get classicBasketball => 'Basket Classique';

  @override
  String get standardFootball => 'Calcio Standard';

  @override
  String get custom => 'Personnalisé';

  @override
  String get setYourScores => 'Définissez vos scores';

  @override
  String get consolationFinalsSubtitle => '3°/4° place, 5°/6°, etc.';

  @override
  String matchTimer(int min) {
    return 'Timer Match : $min minutes';
  }

  @override
  String get searchTeam => 'Rechercher Équipe';

  @override
  String get selectParticipatingTeams =>
      'Sélectionnez les équipes participantes (min. 2)';

  @override
  String get oddTeamsBye =>
      'Équipes impaires : le repos sera géré automatiquement (BYE)';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get noTeamsFound => 'Aucune équipe trouvée';

  @override
  String get continueAction => 'Continuer';

  @override
  String get backAction => 'Retour';

  @override
  String get groupOnlySubtitle => 'Round-robin, classement final';

  @override
  String get eliminationOnlySubtitle => 'Gagne ou rentre chez toi';

  @override
  String get groupAndEliminationSubtitle => 'Phase de groupes puis Playoff';

  @override
  String get leagueMadnessSubtitle => 'Phase de groupes puis Winner Stays On';

  @override
  String get madnessSubtitle => 'Le gagnant reste, haute intensité !';

  @override
  String get error => 'Erreur';

  @override
  String get notFound => 'Non trouvé';

  @override
  String get tournamentNotFound => 'Tournoi non trouvé';

  @override
  String get participatingTeams => 'Équipes Participantes';

  @override
  String get tournamentManagement => 'Gestion Tournoi';

  @override
  String get calendar => 'Calendrier';

  @override
  String get groupPhase => 'Phase de groupes';

  @override
  String get standings => 'Classement';

  @override
  String get pointsAndStats => 'Points et statistiques';

  @override
  String get elimination => 'Élimination';

  @override
  String get playoffBracket => 'Bracket playoff';

  @override
  String get timerLabel => 'Timer';

  @override
  String minutesX(int count) {
    return '$count minutes';
  }

  @override
  String get tournamentDate => 'Date et heure début tournoi';

  @override
  String get tournamentEndDate => 'Date et heure fin tournoi';

  @override
  String get navHome => 'Accueil';

  @override
  String get navTeams => 'Équipes';

  @override
  String get navTournaments => 'Tournois';

  @override
  String get navTimer => 'Timer';

  @override
  String get appIcon => 'Icône App';

  @override
  String get changeAppIcon => 'Changer l\'Icône App';

  @override
  String get pickImageIcon => 'Sélectionner image';

  @override
  String get resetIcon => 'Réinitialiser l\'icône par défaut';

  @override
  String get viewWinners => 'Voir les vainqueurs';

  @override
  String get share => 'Partager';

  @override
  String get scanTournament => 'Scanner Tournoi';

  @override
  String get syncFromScout => 'Synchroniser depuis Scout';

  @override
  String get readOnlyTournament =>
      'Ce tournoi est en lecture seule car il a été importé.';

  @override
  String get apiSettings => 'Paramètres API';

  @override
  String get apiUrl => 'URL Serveur API';

  @override
  String get apiUrlHint => 'Exemple : https://trnmnt.vercel.app';

  @override
  String get testConnection => 'Tester Connexion';

  @override
  String get connectionWorking => 'Connexion fonctionnelle !';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get publishToWeb => 'Synchroniser sur le Cloud';

  @override
  String get openInBrowser => 'Ouvrir dans le Navigateur';

  @override
  String get teamOrder => 'Ordre Équipes';

  @override
  String get dragToReorder => 'Glisser per déplacer';

  @override
  String get madnessOrderSubtitle =>
      'L\'ordre des équipes détermine le bracket Madness.';

  @override
  String get live => 'Live';

  @override
  String get matchDetail => 'Détail Match';

  @override
  String get quit => 'Quitter';

  @override
  String get rules => 'Règles';

  @override
  String get viewTournamentRules => 'Voir les règles du tournoi';

  @override
  String get multiGroup => 'Groupes Multiples';

  @override
  String get groupCountLabel => 'Nombre de Groupes';

  @override
  String get teamsPerGroup => 'Équipes par Groupe';

  @override
  String get randomDistribution => 'Distribution Aléatoire';

  @override
  String get manualDistribution => 'Distribution Manuelle';

  @override
  String get qualifiersPerGroupLabel => 'Qualifiés par Groupe';

  @override
  String get hasPlayInLabel => 'Inclure Barrages (Play-In)';

  @override
  String get editGroups => 'Gérer les Groupes';

  @override
  String get distributeTeams => 'Distribuer les équipes dans les groupes';

  @override
  String get groupNameHint => 'Nom Groupe (ex. A, B...)';

  @override
  String get all => 'Tous';

  @override
  String get upcoming => 'Programmé';

  @override
  String get concluded => 'Terminé';

  @override
  String get playIn => 'Barrages';

  @override
  String get modeLockedWarning =>
      'Le mode ne peut pas être changé car le tournoi a déjà commencé.';

  @override
  String get cloudCollaboration => 'Co-gestion Cloud';

  @override
  String get inviteAdmin => 'Inviter Organisateur';

  @override
  String get cloudSyncActive => 'Synchronisation Cloud active';

  @override
  String get tournamentImportedAndSynced =>
      'Tournoi importé et synchronisé ! 🤝🏀';

  @override
  String get cloudFetching => 'Récupération des données du Cloud...';

  @override
  String get syncError => 'Erreur de synchronisation';

  @override
  String cloudIdLabel(String id) {
    return 'ID Cloud : $id';
  }

  @override
  String get publishToCloud_title => 'Publier sur le Cloud';

  @override
  String get publishToCloud_desc =>
      'Synchronisez le tournoi pour activer le Dashboard Web et la Co-Gestion.';

  @override
  String get publishNow => 'Publier Maintenant';

  @override
  String get manageYourBrand => 'Gérer votre Marque';

  @override
  String get liveHighlights => 'EN VEDETTE';

  @override
  String get statsOverview => 'APERÇU APP';

  @override
  String get noTournamentsAtMoment => 'Aucun tournoi pour le moment';

  @override
  String get activeTournamentMatch => 'MATCH TORNOI LIVE';

  @override
  String get future => 'Programmé';

  @override
  String get past => 'Passés';

  @override
  String get syncSuccess => 'Synchronisé sur le Cloud ! ☁️🏀';

  @override
  String get webResult => 'Résultats Web';

  @override
  String get coManagement => 'Co-Gestion';

  @override
  String get publicDashboard => 'DASHBOARD PUBLIC';

  @override
  String get coManagementTitle => 'CO-GESTION CLOUD';

  @override
  String get publicDashboardDesc =>
      'Tout le monde peut voir les résultats en direct';

  @override
  String get coManagementDesc =>
      'Invitez un autre organisateur à gérer le tournoi';

  @override
  String get cloudSettings => 'PARAMÈTRES CLOUD';

  @override
  String get liveLocationLabel => 'LOCATION LIVE';

  @override
  String get locationHint => 'Ex : Playground San Alvise';

  @override
  String get twitchChannelLabel => 'CHAÎNE TWITCH';

  @override
  String get twitchHint => 'Ex : venicestreetball';

  @override
  String get youtubeVideoLabel => 'ID VIDÉO YOUTUBE';

  @override
  String get youtubeHint => 'Ex : dQw4w9WgXcQ';

  @override
  String get customTickerLabel => 'TEXTE DÉFILANT (TICKER)';

  @override
  String get tickerHint => 'Sponsors, annonces communauté...';

  @override
  String get tickerAutoDesc =>
      'Laissez vide pour utiliser le texte généré par le système.';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get openPage => 'Ouvrir Page';

  @override
  String get syncing => 'Synchronisation...';

  @override
  String get syncCloud => 'Sincroniser Cloud';

  @override
  String get urlSlug => 'URL Slug';

  @override
  String get locationLabel => 'Lieu';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get tiktokLabel => 'TikTok';

  @override
  String get invalidName => 'Entrez un nom valide';

  @override
  String get invalidUrl => 'Entrez un URL valide';

  @override
  String get noActiveInvite =>
      'Aucune invitation active ou expirée. Générez-en une nouvelle.';

  @override
  String expiryDate(String time, String date) {
    return 'Expiration : $time du $date';
  }

  @override
  String get regenerateInvite => 'RÉGÉNÉRER';

  @override
  String get generateInviteAction => 'GÉNÉRER INVITATION';

  @override
  String get slugAlreadyExists =>
      'Cet URL est déjà occupé par une autre communauté.';

  @override
  String get close => 'FERMER';

  @override
  String get registrations => 'Inscriptions';

  @override
  String get manageRegistrations => 'Gérer Inscriptions';

  @override
  String get enableWebRegistrations => 'Activer Inscriptions en Ligne';

  @override
  String get registrationsNotActive => 'INSCRIPTIONS PAS ACTIVES';

  @override
  String get createPublicPageDesc =>
      'Créez la page publique pour permettre aux équipes de s\'inscrire en ligne.';

  @override
  String get activateNow => 'ACTIVER MAINTENANT';

  @override
  String get configureRegistrations => 'CONFIGURER INSCRIPTIONS';

  @override
  String get maxTeamsLabel => 'Nombre Maximum d\'Équipes';

  @override
  String get enableLunchChoice => 'Activer le Choix du Repas';

  @override
  String get addOption => 'Ajouter Option';

  @override
  String get createPage => 'CRÉER PAGE';

  @override
  String get onlineRegistrationsEnabled => 'Inscriptions en Ligne Activées !';

  @override
  String get registeredTeams => 'ÉQUIPES INSCRITES';

  @override
  String get registrationsClosed => 'INSCRIPTIONS FERMÉES';

  @override
  String get closeNow => 'FERMER MAINTENANT';

  @override
  String get noRegistrationsYet => 'Aucune inscription reçue pour le moment';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get players => 'JOUEURS';

  @override
  String get lunchOptions => 'Options Repas';

  @override
  String get deleteRegistration => 'Supprimer Inscription';

  @override
  String confirmDeleteRegistration(String team) {
    return 'Êtes-vous sûr de vouloir supprimer l\'inscription de \"$team\" ?';
  }

  @override
  String get registrationDeleted => 'Inscription supprimée';

  @override
  String get linkCopied => 'Lien copié dans le presse-papiers !';

  @override
  String get newOption => 'Nouvelle Option';

  @override
  String get closeRegistrationsDesc =>
      'Si vous fermez les inscriptions, il ne sera plus possible pour de nouvelles équipes de s\'inscrire via le web. Le nombre maximum d\'équipes sera défini sur le nombre actuel.';

  @override
  String get confirmDeleteRegGeneric =>
      'Êtes-vous sûr de vouloir supprimer cette inscription ?';

  @override
  String get confirmAction => 'OUI, SUPPRIMER';

  @override
  String get confirmImport => 'CONFIRMER ET IMPORTER';

  @override
  String get teamAlreadyRegistered =>
      'Cette équipe est déjà inscrite au tournoi !';

  @override
  String teamAdded(String name) {
    return 'Équipe $name ajoutée !';
  }

  @override
  String get teamImported => 'ÉQUIPES IMPORTÉES';

  @override
  String get manualParticipants => 'ÉQUIPES PARTICIPANTES';

  @override
  String get tournamentStages => 'INFO';

  @override
  String get modeLegend => 'Légende des Modes';

  @override
  String get finals => 'Finales';

  @override
  String get finalSummary => 'RÉSUMÉ FINAL';

  @override
  String get verifyAndCreate => 'Vérifier et créer';

  @override
  String get almostReady => 'PRESQUE PRÊT !';

  @override
  String get readyToCreateDesc =>
      'Tout est configuré correctement. Cliquez sur créer pour commencer le tournoi.';

  @override
  String get onlineRegistrations => 'Inscriptions en Ligne';

  @override
  String get active => 'ACTIVES';

  @override
  String get inactive => 'DÉSACTIVÉES';

  @override
  String get openWebRegistrations => 'INSCRIPTIONS EN LIGNE OUVERTES';

  @override
  String get openWebRegistrationsDesc =>
      'Les équipes pourront s\'inscrire via web. Publication Cloud immédiate.';

  @override
  String get selectTeamsOptional => 'Sélectionner équipes (Optionnel)';

  @override
  String get publishToCloud_switch => 'Publier sur Cloud';

  @override
  String get publishToCloud_subtitle =>
      'Rendez le résultat visible en ligne en temps réel et partagez le lien !';

  @override
  String get matchTitle_label => 'Titre Match (optionnel)';

  @override
  String get matchTitle_hint => 'ex : Finale Régionale - Court 1';

  @override
  String get twitch_label => 'Username Twitch (optionnel)';

  @override
  String get twitch_hint => 'ex : trnmnt_official';

  @override
  String get explorer => 'Explorer';

  @override
  String get cloudHub => 'TRNMNT Hub';

  @override
  String get liveMatches => 'Matchs Live';

  @override
  String get exploreHub => 'Explorez tournois et matchs en direct';

  @override
  String get noLiveMatches => 'Aucun match live en cours';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get hubSubtitle => 'Hub de mises à jour et résultats live';

  @override
  String get defaultHomeScreen => 'Écran Initial';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hub => 'HUB';

  @override
  String get radarSettings => 'Paramètres Radar';

  @override
  String get enableOsmData => 'Activer les données OpenStreetMap';

  @override
  String get osmDataDesc => 'Afficher les terrains publics recensés sur OSM.';

  @override
  String get radarDataSourceOsm => 'Source OpenStreetMap';

  @override
  String get radarDataSourceLocal => 'TRNMNT';

  @override
  String get syncOsm => 'Synchronisation OSM...';

  @override
  String get searchInArea => 'RECHERCHER DANS CETTE ZONE';

  @override
  String get tapMapToAdd => 'APPUYEZ SUR LA CARTE POUR AJOUTER UN TERRAIN';

  @override
  String get addressLabel => 'ADRESSE :';

  @override
  String get surfaceLabel => 'SURFACE :';

  @override
  String get hoopsLabel => 'PANIERS :';

  @override
  String get litLabel => 'ÉCLAIRAGE :';

  @override
  String get accessLabel => 'ACCÈS :';

  @override
  String get otherSportsLabel => 'AUTRES SPORTS :';

  @override
  String get lastCheckLabel => 'DERNIER CONTRÔLE :';

  @override
  String get osmSourceInfo => 'SOURCE : OpenStreetMap';

  @override
  String get addToMyCourts => 'AJOUTER AUX MIENS';

  @override
  String get netsStatusLabel => 'État des filets';

  @override
  String get starsLabel => 'Étoiles :';

  @override
  String get netsLabel => 'Filets :';

  @override
  String osmFoundCount(int count) {
    return 'OSM : $count terrains trouvés';
  }

  @override
  String get osmFoundCount_desc =>
      'Message de confirmation des résultats trouvés sur OSM';

  @override
  String get courtSaved => 'Terrain enregistré !';

  @override
  String get searchingOsmNearby => 'RECHERCHE DE TERRAINS OSM À PROXIMITÉ...';

  @override
  String get noOsmCourtsFound => 'AUCUN TERRAIN OSM TROUVÉ DANS CETTE ZONE';

  @override
  String get osmResultsTitle => 'RÉSULTATS OPENSTREETMAP';

  @override
  String get selectCourt => 'Sélectionner Terrain';

  @override
  String courtSelected(String name) {
    return 'Terrain : $name';
  }

  @override
  String get optional => 'Optionnel';

  @override
  String get radar_court_link => 'LIEN RADAR';

  @override
  String get description => 'Description';

  @override
  String get leaveCommunityTitle => 'Quitter la Communauté';

  @override
  String get removeCommunityTitle => 'Supprimer de l\'Appareil';

  @override
  String get leaveCommunityOwnerDesc =>
      'La communauté restera sur le serveur sans propriétaire.\nVous pourrez la réclamer plus tard depuis le panneau d\'administration.\n\n⚠️ Tous les tournois et équipes locaux liés seront supprimés de cet appareil.';

  @override
  String get leaveCommunityMemberDesc =>
      'Cette communauté et tous les tournois locaux liés seront supprimés de cet appareil.\n\nLes données sur le serveur restent inchangées.';

  @override
  String get leaveCommunityAction => 'Quitter la communauté de l\'appareil';

  @override
  String get removeCommunityAction => 'Supprimer la communauté de l\'appareil';

  @override
  String get leaveAction => 'Quitter';

  @override
  String get removeAction => 'Supprimer';

  @override
  String get rlsViolationError =>
      'Erreur de sécurité : vous avez déjà une communauté active sur le cloud ou les permissions sont insuffisantes. Vérifiez les politiques RLS.';

  @override
  String get sessionError =>
      'Session expirée ou invalide. Veuillez vous reconnecter.';

  @override
  String get liveStream => 'LIVE STREAM';

  @override
  String get watchTournamentLive => 'Regarder le tournoi en direct';

  @override
  String get retry => 'RÉESSAYER';

  @override
  String get invertAction => 'INVERSER';

  @override
  String get startMadnessPhase => 'LANCER LA PHASE MADNESS';

  @override
  String get nextChallengers => 'Prochains Challengers';

  @override
  String get kingOfTheCourt => 'ROI DU TERRAIN';

  @override
  String get enterResult => 'SAISIR RÉSULTAT';

  @override
  String get finalize => 'FINALISER';

  @override
  String get recentMatches => 'Matchs Récents';

  @override
  String get playbackMatch => 'Match d\'Appui';

  @override
  String get grandFinal => 'Grande Finale';

  @override
  String get winnerTitle => 'VAINQUEUR';

  @override
  String get playoffsTitle => 'PLAYOFFS';

  @override
  String get playAction => 'JOUER';

  @override
  String get madnessMinTeamsError =>
      'Il faut au moins 2 équipes pour la Madness !';
}
