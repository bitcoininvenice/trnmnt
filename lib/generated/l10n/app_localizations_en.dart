// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TRNMNT';

  @override
  String get teams => 'Teams';

  @override
  String get singleMatch => 'Single Match';

  @override
  String get tournaments => 'Tournaments';

  @override
  String get newTournament => 'New Tournament';

  @override
  String get map => 'Map';

  @override
  String get settings => 'Settings';

  @override
  String get statistics => 'Statistics';

  @override
  String get appStatistics => 'App Statistics';

  @override
  String get myCommunity => 'My Community';

  @override
  String get communityManagement => 'Community Management';

  @override
  String get manageBrandsLogos => 'Manage brands, logos and teams';

  @override
  String get joinCommunity => 'Join a Community';

  @override
  String get scanQrInvitation => 'Scan QR Invitation';

  @override
  String get createNewGroup => 'CREATE NEW COMMUNITY';

  @override
  String get adminStatus => 'You are the admin of this community.';

  @override
  String get collaboratorStatus => 'You are a collaborator of this community.';

  @override
  String get shareInvitation => 'Share Invitation';

  @override
  String get scanQrInstructions => 'Scan the QR Code provided by the organizer';

  @override
  String get scanQrTitle => 'Scan Community QR';

  @override
  String get joinedCommunitySuccess => 'You\'ve joined the community! 🏀';

  @override
  String get errorJoiningCommunity => 'Error joining. Try again.';

  @override
  String get onlyAdminCanEdit =>
      'Only the administrator can edit the community identity.';

  @override
  String get communityIdentityDesc =>
      'Create your identity to host tournaments under your brand, or scan a colleague\'s QR to collaborate.';

  @override
  String get updateData => 'UPDATE DATA';

  @override
  String get saveCommunity => 'SAVE COMMUNITY';

  @override
  String get totalTeams => 'Total Teams';

  @override
  String get courts => 'Courts';

  @override
  String get tournamentsCreated => 'Created Tournaments';

  @override
  String get inProgress => 'In Progress';

  @override
  String get matchesPlayed => 'Matches Played';

  @override
  String get pointsScored => 'Points Scored';

  @override
  String get hallOfFame => 'Hall of Fame';

  @override
  String get noTournamentsRecorded => 'No tournaments recorded at the moment.';

  @override
  String winner(String team) {
    return '🏆 Winner: $team';
  }

  @override
  String get inProgressOrToBeDecided => '⏳ In Progress / To be decided';

  @override
  String teamRecord(int wins, int losses) {
    return 'Team Record: $wins W - $losses L';
  }

  @override
  String points(int pf, int ps) {
    return 'Points: PF $pf / PA $ps';
  }

  @override
  String get appLanguage => 'App Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get developedBy => 'Developed by';

  @override
  String get tapToVisitLinks => 'Tap to visit links';

  @override
  String get appVersion => 'App Version';

  @override
  String get followUsOnSocial => 'Follow us on social media';

  @override
  String get timer => 'Timer';

  @override
  String get manageTeams => 'Manage teams';

  @override
  String get manageSingleMatch => 'Manage a single match';

  @override
  String get createAndManage => 'Create and manage';

  @override
  String get startNow => 'Start now';

  @override
  String get courtsMap => 'Courts map';

  @override
  String get appOptions => 'App options';

  @override
  String get dataAndNumbers => 'Data and numbers';

  @override
  String get appSubtitle => 'Basketball Tournament Manager';

  @override
  String courtStatus(String status) {
    return 'Court status: $status';
  }

  @override
  String starsCount(int count) {
    return 'Level: $count/5';
  }

  @override
  String get wellMaintained => 'Well maintained';

  @override
  String get playable => 'Playable';

  @override
  String get poorCondition => 'Poor condition';

  @override
  String get cloth => 'Cloth';

  @override
  String get metal => 'Metal';

  @override
  String get broken => 'Broken';

  @override
  String get notPresent => 'Not present';

  @override
  String get wellDefined => 'Well defined';

  @override
  String get visible => 'Visible';

  @override
  String get damaged => 'Damaged';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String hoopsCount(int count) {
    return 'Hoops: $count';
  }

  @override
  String get netsTitle => 'Nets';

  @override
  String get courtTitle => 'Court';

  @override
  String get linesTitle => 'Lines';

  @override
  String get lightsTitle => 'Lights';

  @override
  String get saveAction => 'SAVE';

  @override
  String get newCourtTitle => 'New Court';

  @override
  String get nameLabel => 'Name';

  @override
  String get descLabel => 'Description';

  @override
  String get tapMapInstruction => 'Tap map to add a court';

  @override
  String get positionSaved => 'Map position saved!';

  @override
  String get addAction => 'Add';

  @override
  String get hoops => 'Hoops';

  @override
  String get rating => 'Rating';

  @override
  String get edit => 'Edit';

  @override
  String get myTournaments => 'My Tournaments';

  @override
  String get deleteTournament => 'Delete Tournament';

  @override
  String confirmDeleteTournament(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noTournaments => 'No Tournaments';

  @override
  String get createFirstTournament => 'Create your first basketball tournament';

  @override
  String get createTournament => 'Create Tournament';

  @override
  String get groupOnly => 'League';

  @override
  String get eliminationOnly => 'Playoff';

  @override
  String get groupAndElimination => 'League & Playoff';

  @override
  String get madness => 'Madness';

  @override
  String get consolationFinals => 'Consolation Finals';

  @override
  String location(String loc) {
    return '📍 $loc';
  }

  @override
  String teamsAndMode(int count, String mode) {
    return '🏀 $count teams - $mode';
  }

  @override
  String get singleMatchSetup => 'Single Match Setup';

  @override
  String get noTeamsInDatabase => 'No teams in the database.';

  @override
  String get createTeam => 'Create Team';

  @override
  String get selectTeamsForMatch => 'Select teams for the single match';

  @override
  String get homeTeam => 'Home Team';

  @override
  String get awayTeam => 'Away Team';

  @override
  String get selectATeam => 'Select a team';

  @override
  String get selectDifferentTeams => 'Select two different teams';

  @override
  String get startMatch => 'Start Match';

  @override
  String get theme => 'Theme';

  @override
  String get baseTheme => 'Base Theme (Vibrant)';

  @override
  String get darkTheme => 'Dark Theme (Pure)';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get developers => 'Developers';

  @override
  String get officialWebsite => 'Official Website';

  @override
  String unableToOpenUrl(String url) {
    return 'Unable to open $url';
  }

  @override
  String get matchInProgress => 'Match in Progress';

  @override
  String get resetMatch => 'Reset Match';

  @override
  String get confirmResetMatch =>
      'Are you sure you want to reset score and period to zero?';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get periodLabel => 'PERIOD';

  @override
  String get selectAtLeastTwoTeams => 'Select at least 2 teams';

  @override
  String get infoStep => 'Information';

  @override
  String get infoSubtitle => 'Name and location';

  @override
  String get configStep => 'Configuration';

  @override
  String get configSubtitle => 'Mode and scoring';

  @override
  String get teamsStep => 'Teams';

  @override
  String teamsSelected(int count) {
    return '$count selected';
  }

  @override
  String get tournamentName => 'Tournament Name';

  @override
  String get tournamentLocation => 'Location';

  @override
  String get enterTournamentName => 'Enter tournament name';

  @override
  String get enterTournamentLocation => 'Enter tournament location';

  @override
  String get tournamentMode => 'Tournament Mode';

  @override
  String get scoringSystem => 'Scoring System';

  @override
  String get win => 'Win';

  @override
  String get draw => 'Draw';

  @override
  String get loss => 'Loss';

  @override
  String get classicBasketball => 'Classic Basketball';

  @override
  String get standardFootball => 'Standard Football';

  @override
  String get custom => 'Custom';

  @override
  String get setYourScores => 'Set your own scores';

  @override
  String get consolationFinalsSubtitle => '3rd/4th place, 5th/6th, etc.';

  @override
  String matchTimer(int min) {
    return 'Match Timer: $min minutes';
  }

  @override
  String get searchTeam => 'Search Team';

  @override
  String get selectParticipatingTeams => 'Select participating teams (min. 2)';

  @override
  String get oddTeamsBye =>
      'Odd number of teams: a BYE will be automatically managed';

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get noTeamsFound => 'No teams found';

  @override
  String get continueAction => 'Continue';

  @override
  String get backAction => 'Back';

  @override
  String get groupOnlySubtitle => 'Round-robin, final standings';

  @override
  String get eliminationOnlySubtitle => 'Win or go home';

  @override
  String get groupAndEliminationSubtitle => 'Group stage then playoffs';

  @override
  String get madnessSubtitle => 'Winner stays, high intensity!';

  @override
  String get error => 'Error';

  @override
  String get notFound => 'Not found';

  @override
  String get tournamentNotFound => 'Tournament not found';

  @override
  String get participatingTeams => 'Participating Teams';

  @override
  String get tournamentManagement => 'Tournament Management';

  @override
  String get calendar => 'Calendar';

  @override
  String get groupPhase => 'Group Phase';

  @override
  String get standings => 'Standings';

  @override
  String get pointsAndStats => 'Points & Stats';

  @override
  String get elimination => 'Elimination';

  @override
  String get playoffBracket => 'Playoff Bracket';

  @override
  String get timerLabel => 'Timer';

  @override
  String minutesX(int count) {
    return '$count minutes';
  }

  @override
  String get tournamentDate => 'Tournament Date';

  @override
  String get navHome => 'Home';

  @override
  String get navTeams => 'Teams';

  @override
  String get navTournaments => 'Tournaments';

  @override
  String get navTimer => 'Timer';

  @override
  String get appIcon => 'App Icon';

  @override
  String get changeAppIcon => 'Change App Icon';

  @override
  String get pickImageIcon => 'Pick Image';

  @override
  String get resetIcon => 'Reset to default icon';

  @override
  String get viewWinners => 'View winners';

  @override
  String get share => 'Share';

  @override
  String get scanTournament => 'Scan Tournament';

  @override
  String get syncFromScout => 'Sync from Scout';

  @override
  String get readOnlyTournament =>
      'This tournament is read-only because it was imported.';

  @override
  String get apiSettings => 'API Settings';

  @override
  String get apiUrl => 'API Server URL';

  @override
  String get apiUrlHint => 'Example: https://trnmnt.vercel.app';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connectionWorking => 'Connection working!';

  @override
  String get connectionError => 'Connection error';

  @override
  String get publishToWeb => 'Publish to Web';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get teamOrder => 'Team Order';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get madnessOrderSubtitle =>
      'The team order determines the Madness bracket.';

  @override
  String get live => 'Live';

  @override
  String get matchDetail => 'Match Details';

  @override
  String get quit => 'Quit';

  @override
  String get rules => 'Rules';

  @override
  String get viewTournamentRules => 'View tournament rules';

  @override
  String get multiGroup => 'Multi-Group';

  @override
  String get groupCountLabel => 'Number of Groups';

  @override
  String get teamsPerGroup => 'Teams per Group';

  @override
  String get randomDistribution => 'Random Distribution';

  @override
  String get manualDistribution => 'Manual Distribution';

  @override
  String get qualifiersPerGroupLabel => 'Qualifiers per Group';

  @override
  String get hasPlayInLabel => 'Include Play-In (Spareggi)';

  @override
  String get editGroups => 'Manage Groups';

  @override
  String get distributeTeams => 'Distribute teams into groups';

  @override
  String get groupNameHint => 'Group Name (e.g. A, B...)';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get concluded => 'Concluded';

  @override
  String get playIn => 'Play-In';

  @override
  String get modeLockedWarning =>
      'The mode cannot be changed because the tournament has already started.';

  @override
  String get cloudCollaboration => 'Cloud Co-management';

  @override
  String get inviteAdmin => 'Invite Organizer';

  @override
  String get cloudSyncActive => 'Cloud Sync Active';

  @override
  String get tournamentImportedAndSynced =>
      'Tournament imported and synced! 🤝🏀';

  @override
  String get cloudFetching => 'Fetching Cloud data...';

  @override
  String get syncError => 'Sync error';

  @override
  String cloudIdLabel(String id) {
    return 'Cloud ID: $id';
  }

  @override
  String get publishToCloud_title => 'Publish to Cloud';

  @override
  String get publishToCloud_desc =>
      'Sync the tournament to enable Web Dashboard and Co-Management.';

  @override
  String get publishNow => 'Publish Now';

  @override
  String get manageYourBrand => 'Manage your Brand';

  @override
  String get liveHighlights => 'LIVE HIGHLIGHTS';

  @override
  String get noTournamentsAtMoment => 'No tournaments at the moment';

  @override
  String get activeTournamentMatch => 'LIVE TOURNAMENT MATCH';

  @override
  String get future => 'Future';

  @override
  String get past => 'Past';

  @override
  String get mapDataSourceLocal => 'Added in-app';

  @override
  String get mapDataSourcePickRoll => 'Pick&Roll Source';
}
