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
  String get teams => 'My Teams';

  @override
  String get singleMatch => 'Single Match';

  @override
  String get tournaments => 'Tournaments';

  @override
  String get newTournament => 'New Tournament';

  @override
  String get radar => 'Radar';

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
  String get createNewCommunity => 'CREATE NEW COMMUNITY';

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
  String get saveCommunity => 'COMMUNITY UPDATED';

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
  String get radarSubtitle => 'Radar';

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
  String get name => 'Name';

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
  String get leagueMadness => 'League + Madness';

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
  String periodLabel(Object period) {
    return 'PERIOD $period';
  }

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
  String get leagueMadnessSubtitle => 'Group stage then Winner Stays On';

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
  String get tournamentDate => 'Start Date & Time';

  @override
  String get tournamentEndDate => 'End Date & Time';

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
  String get all => 'All';

  @override
  String get upcoming => 'Scheduled';

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
  String get liveHighlights => 'FEATURED';

  @override
  String get statsOverview => 'APP OVERVIEW';

  @override
  String get noTournamentsAtMoment => 'No tournaments at the moment';

  @override
  String get activeTournamentMatch => 'LIVE TOURNAMENT MATCH';

  @override
  String get future => 'Scheduled';

  @override
  String get past => 'Past';

  @override
  String get syncSuccess => 'Synced to Cloud! ☁️🏀';

  @override
  String get webResult => 'Web Results';

  @override
  String get coManagement => 'Co-Management';

  @override
  String get publicDashboard => 'PUBLIC DASHBOARD';

  @override
  String get coManagementTitle => 'CLOUD CO-MANAGEMENT';

  @override
  String get publicDashboardDesc => 'Anyone can view live results';

  @override
  String get coManagementDesc =>
      'Invite another organizer to manage the tournament';

  @override
  String get cloudSettings => 'CLOUD SETTINGS';

  @override
  String get liveLocationLabel => 'LIVE LOCATION';

  @override
  String get locationHint => 'Ex: Venice Beach Courts';

  @override
  String get twitchChannelLabel => 'TWITCH CHANNEL';

  @override
  String get twitchHint => 'Ex: venicestreetball';

  @override
  String get youtubeVideoLabel => 'YOUTUBE VIDEO ID';

  @override
  String get youtubeHint => 'Ex: dQw4w9WgXcQ';

  @override
  String get customTickerLabel => 'CUSTOM TICKER TEXT';

  @override
  String get tickerHint => 'Sponsors, community announcements...';

  @override
  String get tickerAutoDesc => 'Leave empty to use system-generated text.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get openPage => 'Open Page';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncCloud => 'Sync Cloud';

  @override
  String get urlSlug => 'URL Slug';

  @override
  String get locationLabel => 'Location';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get tiktokLabel => 'TikTok';

  @override
  String get invalidName => 'Enter a valid name';

  @override
  String get invalidUrl => 'Enter a valid URL';

  @override
  String get noActiveInvite =>
      'No active or expired invitation. Generate a new one.';

  @override
  String expiryDate(String time, String date) {
    return 'Expires: $time on $date';
  }

  @override
  String get regenerateInvite => 'REGENERATE';

  @override
  String get generateInviteAction => 'GENERATE INVITE';

  @override
  String get slugAlreadyExists =>
      'This URL is already taken by another community.';

  @override
  String get close => 'CLOSE';

  @override
  String get registrations => 'Registrations';

  @override
  String get manageRegistrations => 'Manage Registrations';

  @override
  String get enableWebRegistrations => 'Enable Online Registrations';

  @override
  String get registrationsNotActive => 'REGISTRATIONS NOT ACTIVE';

  @override
  String get createPublicPageDesc =>
      'Create the public page to allow teams to register online.';

  @override
  String get activateNow => 'ACTIVATE NOW';

  @override
  String get configureRegistrations => 'CONFIGURE REGISTRATIONS';

  @override
  String get maxTeamsLabel => 'Maximum Number of Teams';

  @override
  String get enableLunchChoice => 'Enable Lunch Choice';

  @override
  String get addOption => 'Add Option';

  @override
  String get createPage => 'CREATE PAGE';

  @override
  String get onlineRegistrationsEnabled => 'Online Registrations Enabled!';

  @override
  String get registeredTeams => 'REGISTERED TEAMS';

  @override
  String get registrationsClosed => 'REGISTRATIONS CLOSED';

  @override
  String get closeNow => 'CLOSE NOW';

  @override
  String get noRegistrationsYet => 'No registrations received yet';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get players => 'PLAYERS';

  @override
  String get lunchOptions => 'Lunch Options';

  @override
  String get deleteRegistration => 'Delete Registration';

  @override
  String confirmDeleteRegistration(String team) {
    return 'Are you sure you want to delete the registration for \"$team\"?';
  }

  @override
  String get registrationDeleted => 'Registration deleted';

  @override
  String get linkCopied => 'Link copied to clipboard!';

  @override
  String get newOption => 'New Option';

  @override
  String get closeRegistrationsDesc =>
      'If you close registrations, it will no longer be possible for new teams to register via web. The maximum number of teams will be set to the current number.';

  @override
  String get confirmDeleteRegGeneric =>
      'Are you sure you want to delete this registration?';

  @override
  String get confirmAction => 'YES, DELETE';

  @override
  String get confirmImport => 'CONFIRM AND IMPORT';

  @override
  String get teamAlreadyRegistered =>
      'This team is already registered for this tournament!';

  @override
  String teamAdded(String name) {
    return 'Team $name added!';
  }

  @override
  String get teamImported => 'TEAM IMPORTED';

  @override
  String get manualParticipants => 'TEAMS';

  @override
  String get tournamentStages => 'INFO';

  @override
  String get modeLegend => 'Mode Legend';

  @override
  String get finals => 'Finals';

  @override
  String get finalSummary => 'FINAL SUMMARY';

  @override
  String get verifyAndCreate => 'Verify and create';

  @override
  String get almostReady => 'ALMOST READY!';

  @override
  String get readyToCreateDesc =>
      'Everything is configured correctly. Click create to start the tournament.';

  @override
  String get onlineRegistrations => 'Online Registrations';

  @override
  String get active => 'ACTIVE';

  @override
  String get inactive => 'INACTIVE';

  @override
  String get openWebRegistrations => 'OPEN ONLINE REGISTRATIONS';

  @override
  String get openWebRegistrationsDesc =>
      'Teams will be able to register via web. Immediate Cloud publishing.';

  @override
  String get selectTeamsOptional => 'Select Teams (Optional)';

  @override
  String get publishToCloud_switch => 'Publish to Cloud';

  @override
  String get publishToCloud_subtitle =>
      'Make the result visible online in real time and share the link!';

  @override
  String get matchTitle_label => 'Match Title (optional)';

  @override
  String get matchTitle_hint => 'e.g.: Regional Final - Court 1';

  @override
  String get twitch_label => 'Twitch Username (optional)';

  @override
  String get twitch_hint => 'e.g.: trnmnt_official';

  @override
  String get explorer => 'Explorer';

  @override
  String get cloudHub => 'TRNMNT Hub';

  @override
  String get liveMatches => 'Live Matches';

  @override
  String get exploreHub => 'Explore tournaments and live matches';

  @override
  String get noLiveMatches => 'No matches live at the moment';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get hubSubtitle => 'Hub updates and live results';

  @override
  String get defaultHomeScreen => 'Default Home Screen';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hub => 'HUB';

  @override
  String get radarSettings => 'Radar Settings';

  @override
  String get enableOsmData => 'Enable OpenStreetMap data';

  @override
  String get osmDataDesc => 'Show public street courts from OSM.';

  @override
  String get radarDataSourceOsm => 'OpenStreetMap Source';

  @override
  String get radarDataSourceLocal => 'TRNMNT';

  @override
  String get syncOsm => 'Syncing OSM...';

  @override
  String get searchInArea => 'SEARCH IN THIS AREA';

  @override
  String get tapMapToAdd => 'TAP THE MAP TO ADD A COURT';

  @override
  String get addressLabel => 'ADDRESS:';

  @override
  String get surfaceLabel => 'SURFACE:';

  @override
  String get hoopsLabel => 'HOOPS:';

  @override
  String get litLabel => 'LIGHTING:';

  @override
  String get accessLabel => 'ACCESS:';

  @override
  String get otherSportsLabel => 'OTHER SPORTS:';

  @override
  String get lastCheckLabel => 'LAST CHECK:';

  @override
  String get osmSourceInfo => 'SOURCE: OpenStreetMap';

  @override
  String get addToMyCourts => 'ADD TO MINE';

  @override
  String get netsStatusLabel => 'Nets Status';

  @override
  String get starsLabel => 'Stars:';

  @override
  String get netsLabel => 'Nets:';

  @override
  String osmFoundCount(int count) {
    return 'OSM: Found $count courts';
  }

  @override
  String get osmFoundCount_desc =>
      'Confirmation message for OSM search results';

  @override
  String get courtSaved => 'Court saved!';

  @override
  String get searchingOsmNearby => 'SEARCHING FOR NEARBY OSM COURTS...';

  @override
  String get noOsmCourtsFound => 'NO OSM COURTS FOUND IN THIS AREA';

  @override
  String get osmResultsTitle => 'OPENSTREETMAP RESULTS';

  @override
  String get selectCourt => 'Select Court';

  @override
  String courtSelected(String name) {
    return 'Court: $name';
  }

  @override
  String get optional => 'Optional';

  @override
  String get radar_court_link => 'RADAR LINK';

  @override
  String get description => 'Description';

  @override
  String get leaveCommunityTitle => 'Leave Community';

  @override
  String get removeCommunityTitle => 'Remove from Device';

  @override
  String get leaveCommunityOwnerDesc =>
      'The community will remain on the server without an owner.\nYou can reclaim it later from the admin panel.\n\n⚠️ All locally linked tournaments and teams will be deleted from this device.';

  @override
  String get leaveCommunityMemberDesc =>
      'This community and all locally linked tournaments will be removed from this device.\n\nServer data remains unchanged.';

  @override
  String get leaveCommunityAction => 'Leave community from device';

  @override
  String get removeCommunityAction => 'Remove community from device';

  @override
  String get leaveAction => 'Leave';

  @override
  String get removeAction => 'Remove';

  @override
  String get rlsViolationError =>
      'Security error: you already have an active community on the cloud or permissions are insufficient. Check RLS policies.';

  @override
  String get sessionError =>
      'Session expired or invalid. Please sign in again.';

  @override
  String get liveStream => 'LIVE STREAM';

  @override
  String get watchTournamentLive => 'Watch the tournament live';

  @override
  String get retry => 'RETRY';

  @override
  String get invertAction => 'INVERT';

  @override
  String get startMadnessPhase => 'START MADNESS PHASE';

  @override
  String get nextChallengers => 'Next Challengers';

  @override
  String get kingOfTheCourt => 'KING OF THE COURT';

  @override
  String get enterResult => 'ENTER RESULT';

  @override
  String get finalize => 'FINALIZE';

  @override
  String get recentMatches => 'Recent Matches';

  @override
  String get playbackMatch => 'Playback Match';

  @override
  String get grandFinal => 'Grand Final';

  @override
  String get winnerTitle => 'WINNER';

  @override
  String get playoffsTitle => 'PLAYOFFS';

  @override
  String get playAction => 'PLAY';

  @override
  String get madnessMinTeamsError => 'Need at least 2 teams for Madness!';

  @override
  String matchesSelected(int count) {
    return '$count selected';
  }

  @override
  String get addMatch => 'Add match';

  @override
  String get generateAutomatic => 'Generate automatic';

  @override
  String get generateCalendar => 'Generate Calendar';

  @override
  String get generateCalendarPrompt =>
      'Do you want to generate only the first round or both home and away?';

  @override
  String get onlyOneWay => 'First Round Only';

  @override
  String get roundTrip => 'Home and Away';

  @override
  String get deleteSelected => 'Delete selected';

  @override
  String get deleteCalendar => 'Delete calendar';

  @override
  String get deleteMatches => 'Delete matches';

  @override
  String get deleteAllMatchesConfirm =>
      'This will delete EVERYTHING in the current calendar. Continue?';

  @override
  String deleteSelectedMatchesConfirm(int count) {
    return 'Do you want to delete the $count selected matches?';
  }

  @override
  String get deleteAll => 'Delete all';

  @override
  String get finalizeTournamentTitle => 'Finalize Tournament';

  @override
  String get finalizeTournamentConfirm =>
      'Are you sure you want to close the tournament?';

  @override
  String get currentWinnerLabel => 'CURRENT WINNER:';

  @override
  String get readOnlyWarning => 'The tournament will become read-only.';

  @override
  String get confirmAndFinalize => 'CONFIRM AND FINALIZE';

  @override
  String matchDayX(int round) {
    return 'Round $round';
  }

  @override
  String get guestCalendar => 'Calendar (Guest)';

  @override
  String get noMatchesFound => 'No matches';

  @override
  String get generateCalendarToStart => 'Generate the calendar to start';

  @override
  String get deleteMatch => 'Delete match';

  @override
  String get deleteMatchConfirm =>
      'Do you want to delete this match from the calendar?';

  @override
  String get noStandingsToFinalize =>
      'No teams in standings. Impossible to finalize.';

  @override
  String get noWinnerFound => 'No winner found.';

  @override
  String get matchRoundLabel => 'Round';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get differentTeamsRequired => 'The two teams must be different';

  @override
  String get enterValidScores => 'Enter valid scores';

  @override
  String get matchNotFound => 'Match not found';

  @override
  String get matchNotAvailable => 'Match not available';

  @override
  String get cloudDataNotReady => 'Cloud data not ready';

  @override
  String get period => 'Period';

  @override
  String get guestMatchDetail => 'Match Details (Guest)';

  @override
  String get tournamentLabel => 'TOURNAMENT';

  @override
  String get liveStreamLabel => 'LIVE STREAM';

  @override
  String get spectators => 'SPECTATORS';

  @override
  String get finalScore => 'FINAL';

  @override
  String get updateScores => 'UPDATE SCORES';

  @override
  String get editScore => 'Edit Score';

  @override
  String get finishMatchTitle => 'Close Match';

  @override
  String get finishMatchConfirm =>
      'Are you sure you want to permanently close this match and update the standings?';

  @override
  String get closeAndSave => 'CLOSE AND SAVE';

  @override
  String get syncWithCloud => 'SYNC WITH CLOUD';

  @override
  String get scoreSynced => 'SCORE SYNCED';

  @override
  String get scoreSyncError => 'SYNC ERROR';

  @override
  String get syncFromScoutLabel => 'SYNC FROM SCOUT';

  @override
  String get syncCompleted => 'SYNC COMPLETED';

  @override
  String get home => 'Home';

  @override
  String get away => 'Away';

  @override
  String get playLiveMatch => 'PLAY LIVE MATCH';

  @override
  String get saveOnlyResult => 'SAVE ONLY RESULT';

  @override
  String get liveNow => '🔴 LIVE NOW';

  @override
  String get dataNotAvailable => 'Data not available';

  @override
  String get threePointer => '3-Pointer';

  @override
  String get confirm => 'Confirm';

  @override
  String get setTimer => 'SET TIMER';

  @override
  String get min => 'MIN';

  @override
  String get sec => 'SEC';

  @override
  String get madnessMode => 'Madness Mode';

  @override
  String get syncWeb => 'Sync Web';

  @override
  String get tbd => 'TBD';

  @override
  String get syncSuccessMadness => 'Data and Queue synced on Web! 🚀';

  @override
  String syncErrorMsg(String error) {
    return 'Sync error: $error';
  }

  @override
  String get liveStandingsBaskets => 'LIVE STANDINGS (Baskets count as points)';

  @override
  String get pts => 'pts';

  @override
  String get finalizeSeason => 'Finalize Season';

  @override
  String playbackMatchNeeded(String team1, String team2) {
    return 'Playback match needed between $team1 and $team2 for the final spot!';
  }

  @override
  String finalMatchWillBe(String team1, String team2) {
    return 'Final Match will be: $team1 vs $team2';
  }

  @override
  String get proceed => 'PROCEED';

  @override
  String get matchesGenerated => 'Matches generated!';

  @override
  String get madnessModeGuest => 'Madness Mode (Guest)';

  @override
  String get team => 'Team';

  @override
  String get king => 'KING';

  @override
  String get challenger => 'CHALLENGER';

  @override
  String get unknown => '???';

  @override
  String get winsShort => 'W';

  @override
  String get pointsForShort => 'PF';

  @override
  String get pointsAgainstShort => 'PA';

  @override
  String get matchManagedByOther =>
      'This match is already being managed by another device.';

  @override
  String get ok => 'OK';

  @override
  String get liveOther => 'LIVE (OTHERS)';
}
