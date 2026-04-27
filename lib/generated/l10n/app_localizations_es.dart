// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TRNMNT';

  @override
  String get teams => 'Mis Equipos';

  @override
  String get singleMatch => 'Partido Único';

  @override
  String get tournaments => 'Torneos';

  @override
  String get newTournament => 'Nuevo Torneo';

  @override
  String get radar => 'Radar';

  @override
  String get settings => 'Ajustes';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get appStatistics => 'Estadísticas App';

  @override
  String get myCommunity => 'Mi Comunidad';

  @override
  String get communityManagement => 'Gestión de Comunidad';

  @override
  String get manageBrandsLogos => 'Gestionar marcas';

  @override
  String get joinCommunity => 'Unirse a una Comunidad';

  @override
  String get scanQrInvitation => 'Escanear Invitación QR';

  @override
  String get createNewCommunity => 'CREAR NUEVA COMUNIDAD';

  @override
  String get adminStatus => 'Eres el administrador de esta comunidad.';

  @override
  String get collaboratorStatus => 'Eres un colaborador de esta comunidad.';

  @override
  String get shareInvitation => 'Compartir Invitación';

  @override
  String get scanQrInstructions =>
      'Encuadra el código QR proporcionado por el organizador';

  @override
  String get scanQrTitle => 'Escanear QR Comunidad';

  @override
  String get joinedCommunitySuccess => '¡Te has unido a la comunidad! 🏀';

  @override
  String get errorJoiningCommunity => 'Error al unirse. Inténtalo de nuevo.';

  @override
  String get onlyAdminCanEdit =>
      'Solo el administrador puede editar la identidad de la comunidad.';

  @override
  String get communityIdentityDesc =>
      'Crea tu identidad para organizar torneos bajo tu marca, o escanea el QR de un colega para colaborar.';

  @override
  String get updateData => 'ACTUALIZAR DATOS';

  @override
  String get saveCommunity => 'COMUNIDAD ACTUALIZADA';

  @override
  String get totalTeams => 'Equipos Totales';

  @override
  String get courts => 'Canchas';

  @override
  String get tournamentsCreated => 'Torneos Creados';

  @override
  String get inProgress => 'En Curso';

  @override
  String get matchesPlayed => 'Partidos Jugados';

  @override
  String get pointsScored => 'Puntos Anotados';

  @override
  String get hallOfFame => 'Salón de la Fama';

  @override
  String get noTournamentsRecorded =>
      'No hay torneos registrados en este momento.';

  @override
  String winner(String team) {
    return '🏆 Ganador: $team';
  }

  @override
  String get inProgressOrToBeDecided => '⏳ En Curso / Por decidir';

  @override
  String teamRecord(int wins, int losses) {
    return 'Récord equipo: $wins V - $losses D';
  }

  @override
  String points(int pf, int ps) {
    return 'Puntos: PF $pf / PC $ps';
  }

  @override
  String get appLanguage => 'Idioma App';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get developedBy => 'Desarrollado por';

  @override
  String get tapToVisitLinks => 'Toca para visitar los enlaces';

  @override
  String get appVersion => 'Versión App';

  @override
  String get followUsOnSocial => 'Síguenos en redes sociales';

  @override
  String get timer => 'Cronómetro';

  @override
  String get manageTeams => 'Gestionar equipos';

  @override
  String get manageSingleMatch => 'Gestionar partido único';

  @override
  String get createAndManage => 'Crear y gestionar';

  @override
  String get startNow => 'Empezar ahora';

  @override
  String get radarSubtitle => 'Radar';

  @override
  String get appOptions => 'Opciones app';

  @override
  String get dataAndNumbers => 'Datos y números';

  @override
  String get appSubtitle => 'Gestión de Torneos de Baloncesto';

  @override
  String courtStatus(String status) {
    return 'Estado cancha: $status';
  }

  @override
  String starsCount(int count) {
    return 'Nivel: $count/5';
  }

  @override
  String get wellMaintained => 'Bien mantenido';

  @override
  String get playable => 'Jugable';

  @override
  String get poorCondition => 'Mal estado';

  @override
  String get cloth => 'Tela';

  @override
  String get metal => 'Hierro';

  @override
  String get broken => 'Roto';

  @override
  String get notPresent => 'No presente';

  @override
  String get wellDefined => 'Bien definidas';

  @override
  String get visible => 'Visibles';

  @override
  String get damaged => 'Dañadas';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String hoopsCount(int count) {
    return 'Canastas: $count';
  }

  @override
  String get netsTitle => 'Redes';

  @override
  String get courtTitle => 'Cancha';

  @override
  String get linesTitle => 'Líneas';

  @override
  String get lightsTitle => 'Luces';

  @override
  String get saveAction => 'GUARDAR';

  @override
  String get newCourtTitle => 'Nueva Cancha';

  @override
  String get name => 'Nombre';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get descLabel => 'Descripción';

  @override
  String get tapMapInstruction => 'Toca el mapa para añadir';

  @override
  String get positionSaved => '¡Posición del mapa guardada!';

  @override
  String get addAction => 'Añadir';

  @override
  String get hoops => 'Canastas';

  @override
  String get rating => 'Valoración';

  @override
  String get edit => 'Editar';

  @override
  String get myTournaments => 'Mis Torneos';

  @override
  String get deleteTournament => 'Eliminar torneo';

  @override
  String confirmDeleteTournament(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get noTournaments => 'No hay torneos';

  @override
  String get createFirstTournament => 'Crea tu primer torneo de baloncesto';

  @override
  String get createTournament => 'Crear Torneo';

  @override
  String get groupOnly => 'Liga';

  @override
  String get eliminationOnly => 'Playoff';

  @override
  String get groupAndElimination => 'Liga y Playoff';

  @override
  String get madness => 'Madness';

  @override
  String get consolationFinals => 'Finales consolación';

  @override
  String location(String loc) {
    return '📍 $loc';
  }

  @override
  String teamsAndMode(int count, String mode) {
    return '🏀 $count equipos - $mode';
  }

  @override
  String get singleMatchSetup => 'Configuración Partido Único';

  @override
  String get noTeamsInDatabase => 'No hay equipos en la base de datos.';

  @override
  String get createTeam => 'Crear Equipo';

  @override
  String get selectTeamsForMatch =>
      'Selecciona los equipos para el partido único';

  @override
  String get homeTeam => 'Equipo Local';

  @override
  String get awayTeam => 'Equipo Visitante';

  @override
  String get selectATeam => 'Selecciona un equipo';

  @override
  String get selectDifferentTeams => 'Elige dos equipos diferentes';

  @override
  String get startMatch => 'Empezar Partido';

  @override
  String get theme => 'Tema';

  @override
  String get baseTheme => 'Tema Base (Vibrante)';

  @override
  String get darkTheme => 'Tema Oscuro (Puro)';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get developers => 'Desarrolladores';

  @override
  String get officialWebsite => 'Sitio Web Oficial';

  @override
  String unableToOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get matchInProgress => 'Partido en curso';

  @override
  String get resetMatch => 'Reiniciar partido';

  @override
  String get confirmResetMatch =>
      '¿Estás seguro de que quieres reiniciar el marcador y el periodo a 0?';

  @override
  String get durationMinutes => 'Duración (minutos)';

  @override
  String periodLabel(Object period) {
    return 'PERIODO $period';
  }

  @override
  String get selectAtLeastTwoTeams => 'Selecciona al menos 2 equipos';

  @override
  String get infoStep => 'Información';

  @override
  String get infoSubtitle => 'Nombre y lugar';

  @override
  String get configStep => 'Configuración';

  @override
  String get configSubtitle => 'Modalidad y puntuación';

  @override
  String get teamsStep => 'Equipos';

  @override
  String teamsSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get tournamentName => 'Nombre Torneo';

  @override
  String get tournamentLocation => 'Lugar';

  @override
  String get enterTournamentName => 'Introduce el nombre del torneo';

  @override
  String get enterTournamentLocation => 'Introduce el lugar del torneo';

  @override
  String get tournamentMode => 'Modalidad de Torneo';

  @override
  String get scoringSystem => 'Sistema de Puntuación';

  @override
  String get win => 'Victoria';

  @override
  String get draw => 'Empate';

  @override
  String get loss => 'Derrota';

  @override
  String get classicBasketball => 'Baloncesto Clásico';

  @override
  String get standardFootball => 'Fútbol Estándar';

  @override
  String get custom => 'Personalizado';

  @override
  String get setYourScores => 'Configura tus puntuaciones';

  @override
  String get consolationFinalsSubtitle => '3°/4° puesto, 5°/6°, etc.';

  @override
  String matchTimer(int min) {
    return 'Timer Partido: $min minutos';
  }

  @override
  String get searchTeam => 'Buscar Equipo';

  @override
  String get selectParticipatingTeams =>
      'Selecciona los equipos participantes (min. 2)';

  @override
  String get oddTeamsBye =>
      'Equipos impares: el descanso se gestionará automáticamente (BYE)';

  @override
  String get selectAll => 'Seleccionar todos';

  @override
  String get deselectAll => 'Deseleccionar todos';

  @override
  String get noTeamsFound => 'No se encontraron equipos';

  @override
  String get continueAction => 'Continuar';

  @override
  String get backAction => 'Atrás';

  @override
  String get groupOnlySubtitle => 'Round-robin, clasificación final';

  @override
  String get eliminationOnlySubtitle => 'Gana o vete a casa';

  @override
  String get groupAndEliminationSubtitle => 'Fase de grupos y luego Playoff';

  @override
  String get madnessSubtitle => '¡El que gana reina, alta intensidad!';

  @override
  String get error => 'Error';

  @override
  String get notFound => 'No encontrado';

  @override
  String get tournamentNotFound => 'Torneo no encontrado';

  @override
  String get participatingTeams => 'Equipos Participantes';

  @override
  String get tournamentManagement => 'Gestión de Torneo';

  @override
  String get calendar => 'Calendario';

  @override
  String get groupPhase => 'Fase de grupos';

  @override
  String get standings => 'Clasificación';

  @override
  String get pointsAndStats => 'Puntos y estadísticas';

  @override
  String get elimination => 'Eliminatoria';

  @override
  String get playoffBracket => 'Cuadro playoff';

  @override
  String get timerLabel => 'Timer';

  @override
  String minutesX(int count) {
    return '$count minutos';
  }

  @override
  String get tournamentDate => 'Fecha y hora inicio torneo';

  @override
  String get tournamentEndDate => 'Fecha y hora fin torneo';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTeams => 'Equipos';

  @override
  String get navTournaments => 'Torneos';

  @override
  String get navTimer => 'Timer';

  @override
  String get appIcon => 'Icono App';

  @override
  String get changeAppIcon => 'Cambiar Icono App';

  @override
  String get pickImageIcon => 'Seleccionar imagen';

  @override
  String get resetIcon => 'Restablecer icono predeterminado';

  @override
  String get viewWinners => 'Ver ganadores';

  @override
  String get share => 'Compartir';

  @override
  String get scanTournament => 'Escanear Torneo';

  @override
  String get syncFromScout => 'Sincronizar desde Scout';

  @override
  String get readOnlyTournament =>
      'Este torneo es de solo lectura porque ha sido importado.';

  @override
  String get apiSettings => 'Ajustes API';

  @override
  String get apiUrl => 'URL Servidor API';

  @override
  String get apiUrlHint => 'Ejemplo: https://trnmnt.vercel.app';

  @override
  String get testConnection => 'Probar Conexión';

  @override
  String get connectionWorking => '¡Conexión funcionando!';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get publishToWeb => 'Sincronizar en la Nube';

  @override
  String get openInBrowser => 'Abrir en el Navegador';

  @override
  String get teamOrder => 'Orden de Equipos';

  @override
  String get dragToReorder => 'Arrastra para mover';

  @override
  String get madnessOrderSubtitle =>
      'El orden de los equipos determina el cuadro Madness.';

  @override
  String get live => 'Live';

  @override
  String get matchDetail => 'Detalle del Partido';

  @override
  String get quit => 'Salir';

  @override
  String get rules => 'Reglas';

  @override
  String get viewTournamentRules => 'Ver las reglas del torneo';

  @override
  String get multiGroup => 'Grupos Múltiples';

  @override
  String get groupCountLabel => 'Número de Grupos';

  @override
  String get teamsPerGroup => 'Equipos por Grupo';

  @override
  String get randomDistribution => 'Distribución Aleatoria';

  @override
  String get manualDistribution => 'Distribución Manual';

  @override
  String get qualifiersPerGroupLabel => 'Clasificados por Grupo';

  @override
  String get hasPlayInLabel => 'Incluir Eliminatorias PRE (Play-In)';

  @override
  String get editGroups => 'Gestionar Grupos';

  @override
  String get distributeTeams => 'Distribuir equipos en los grupos';

  @override
  String get groupNameHint => 'Nombre Grupo (ej. A, B...)';

  @override
  String get all => 'Todos';

  @override
  String get upcoming => 'Programados';

  @override
  String get concluded => 'Concluido';

  @override
  String get playIn => 'Eliminatorias PRE';

  @override
  String get modeLockedWarning =>
      'La modalidad no se puede cambiar porque el torneo ya ha comenzado.';

  @override
  String get cloudCollaboration => 'Co-gestión Nube';

  @override
  String get inviteAdmin => 'Invitar Organizador';

  @override
  String get cloudSyncActive => 'Sincronización Nube activa';

  @override
  String get tournamentImportedAndSynced =>
      '¡Torneo importado y sincronizado! 🤝🏀';

  @override
  String get cloudFetching => 'Recuperando datos de la Nube...';

  @override
  String get syncError => 'Error de sincronización';

  @override
  String cloudIdLabel(String id) {
    return 'ID Nube: $id';
  }

  @override
  String get publishToCloud_title => 'Publicar en la Nube';

  @override
  String get publishToCloud_desc =>
      'Sincroniza el torneo para habilitar el Dashboard Web y la Co-Gestión.';

  @override
  String get publishNow => 'Publicar Ahora';

  @override
  String get manageYourBrand => 'Gestiona tu Marca';

  @override
  String get liveHighlights => 'DESTACADOS';

  @override
  String get statsOverview => 'RESUMEN APP';

  @override
  String get noTournamentsAtMoment => 'No hay torneos por el momento';

  @override
  String get activeTournamentMatch => 'PARTIDO TORNEO EN VIVO';

  @override
  String get future => 'Programados';

  @override
  String get past => 'Pasados';

  @override
  String get syncSuccess => '¡Sincronizado en la Nube! ☁️🏀';

  @override
  String get webResult => 'Resultados Web';

  @override
  String get coManagement => 'Co-Gestión';

  @override
  String get publicDashboard => 'DASHBOARD PÚBLICO';

  @override
  String get coManagementTitle => 'CO-GESTIÓN NUBE';

  @override
  String get publicDashboardDesc =>
      'Cualquiera puede ver los resultados en vivo';

  @override
  String get coManagementDesc =>
      'Invita a otro organizador a gestionar el torneo';

  @override
  String get cloudSettings => 'AJUSTES NUBE';

  @override
  String get liveLocationLabel => 'UBICACIÓN EN VIVO';

  @override
  String get locationHint => 'Ej: Parque del Retiro';

  @override
  String get twitchChannelLabel => 'CANAL TWITCH';

  @override
  String get twitchHint => 'Ej: trnmnt_oficial';

  @override
  String get youtubeVideoLabel => 'ID VIDEO YOUTUBE';

  @override
  String get youtubeHint => 'Ej: dQw4w9WgXcQ';

  @override
  String get customTickerLabel => 'TEXTO DESPLAZABLE (TICKER)';

  @override
  String get tickerHint => 'Patrocinadores, anuncios comunidad...';

  @override
  String get tickerAutoDesc =>
      'Deja vacío para usar el texto generado por el sistema.';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get openPage => 'Abrir Página';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get syncCloud => 'Sincronizar Nube';

  @override
  String get urlSlug => 'URL Slug';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get tiktokLabel => 'TikTok';

  @override
  String get invalidName => 'Introduce un nombre válido';

  @override
  String get invalidUrl => 'Introduce una URL válida';

  @override
  String get noActiveInvite =>
      'Sin invitación activa o caducada. Genera una nueva.';

  @override
  String expiryDate(String time, String date) {
    return 'Caducidad: $time del $date';
  }

  @override
  String get regenerateInvite => 'REGENERAR';

  @override
  String get generateInviteAction => 'GENERAR INVITACIÓN';

  @override
  String get slugAlreadyExists =>
      'Esta URL ya está siendo usada por otra comunidad.';

  @override
  String get close => 'CERRAR';

  @override
  String get registrations => 'Inscripciones';

  @override
  String get manageRegistrations => 'Gestionar Inscripciones';

  @override
  String get enableWebRegistrations => 'Habilitar Inscripciones Online';

  @override
  String get registrationsNotActive => 'INSCRIPCIONES NO ACTIVAS';

  @override
  String get createPublicPageDesc =>
      'Crea la página pública para permitir que los equipos se inscriban online.';

  @override
  String get activateNow => 'ACTIVAR AHORA';

  @override
  String get configureRegistrations => 'CONFIGURAR INSCRIPCIONES';

  @override
  String get maxTeamsLabel => 'Número Máximo de Equipos';

  @override
  String get enableLunchChoice => 'Habilitar Elección de Comida';

  @override
  String get addOption => 'Añadir Opción';

  @override
  String get createPage => 'CREAR PÁGINA';

  @override
  String get onlineRegistrationsEnabled => '¡Inscripciones Online Habilitadas!';

  @override
  String get registeredTeams => 'EQUIPOS INSCRITOS';

  @override
  String get registrationsClosed => 'INSCRIPCIONES CERRADAS';

  @override
  String get closeNow => 'CERRAR AHORA';

  @override
  String get noRegistrationsYet => 'Aún no se han recibido inscripciones';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get players => 'JUGADORES';

  @override
  String get lunchOptions => 'Opciones de Comida';

  @override
  String get deleteRegistration => 'Eliminar Inscripción';

  @override
  String confirmDeleteRegistration(String team) {
    return '¿Estás seguro de que quieres eliminar la inscripción de \"$team\"?';
  }

  @override
  String get registrationDeleted => 'Inscripción eliminada';

  @override
  String get linkCopied => '¡Enlace copiado al portapapeles!';

  @override
  String get newOption => 'Nueva Opción';

  @override
  String get closeRegistrationsDesc =>
      'Si cierras las inscripciones, ya no será posible que nuevos equipos se registren vía web. El número máximo de equipos se ajustará al actual.';

  @override
  String get confirmDeleteRegGeneric =>
      '¿Estás seguro de que quieres eliminar esta inscripción?';

  @override
  String get confirmAction => 'SÍ, ELIMINAR';

  @override
  String get confirmImport => 'CONFIRMAR E IMPORTAR';

  @override
  String get teamAlreadyRegistered =>
      '¡Este equipo ya está inscrito en el torneo!';

  @override
  String teamAdded(String name) {
    return '¡Equipo $name añadido!';
  }

  @override
  String get teamImported => 'EQUIPOS IMPORTADOS';

  @override
  String get manualParticipants => 'EQUIPOS PARTICIPANTES';

  @override
  String get tournamentStages => 'INFO';

  @override
  String get modeLegend => 'Leyenda de Modalidades';

  @override
  String get finals => 'Finales';

  @override
  String get finalSummary => 'RESUMEN FINAL';

  @override
  String get verifyAndCreate => 'Verificar y crear';

  @override
  String get almostReady => '¡CASI LISTO!';

  @override
  String get readyToCreateDesc =>
      'Todo está configurado correctamente. Haz clic en crear para comenzar el torneo.';

  @override
  String get onlineRegistrations => 'Inscripciones Online';

  @override
  String get active => 'ACTIVAS';

  @override
  String get inactive => 'DESACTIVADAS';

  @override
  String get openWebRegistrations => 'INSCRIPCIONES ONLINE ABIERTAS';

  @override
  String get openWebRegistrationsDesc =>
      'Los equipos podrán registrarse vía web. Publicación Nube inmediata.';

  @override
  String get selectTeamsOptional => 'Seleccionar equipos (Opcional)';

  @override
  String get publishToCloud_switch => 'Publicar en la Nube';

  @override
  String get publishToCloud_subtitle =>
      '¡Haz que el resultado sea visible online en tiempo real y comparte el enlace!';

  @override
  String get matchTitle_label => 'Título del Partido (opcional)';

  @override
  String get matchTitle_hint => 'ej: Final Regional - Court 1';

  @override
  String get twitch_label => 'Usuario de Twitch (opcional)';

  @override
  String get twitch_hint => 'ej: trnmnt_oficial';

  @override
  String get explorer => 'Explorar';

  @override
  String get cloudHub => 'TRNMNT Hub';

  @override
  String get liveMatches => 'Partidos Live';

  @override
  String get exploreHub => 'Explora torneos y partidos en vivo';

  @override
  String get noLiveMatches => 'No hay partidos en vivo en curso';

  @override
  String get errorLoadingData => 'Error al cargar los datos';

  @override
  String get hubSubtitle => 'Hub de actualizaciones y resultados en vivo';

  @override
  String get defaultHomeScreen => 'Pantalla de Inicio';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hub => 'HUB';

  @override
  String get radarSettings => 'Ajustes de Radar';

  @override
  String get enableOsmData => 'Habilitar datos de OpenStreetMap';

  @override
  String get osmDataDesc => 'Muestra las canchas públicas censadas en OSM.';

  @override
  String get radarDataSourceOsm => 'Fuente OpenStreetMap';

  @override
  String get radarDataSourceLocal => 'TRNMNT';

  @override
  String get syncOsm => 'Sincronizando OSM...';

  @override
  String get searchInArea => 'BUSCAR EN ESTA ZONA';

  @override
  String get tapMapToAdd => 'TOCA EL MAPA PARA AÑADIR UNA CANCHA';

  @override
  String get addressLabel => 'DIRECCIÓN:';

  @override
  String get surfaceLabel => 'SUPERFICIE:';

  @override
  String get hoopsLabel => 'CANASTAS:';

  @override
  String get litLabel => 'ILUMINACIÓN:';

  @override
  String get accessLabel => 'ACCESO:';

  @override
  String get otherSportsLabel => 'OTROS DEPORTES:';

  @override
  String get lastCheckLabel => 'ÚLTIMA COMPROBACIÓN:';

  @override
  String get osmSourceInfo => 'FUENTE: OpenStreetMap';

  @override
  String get addToMyCourts => 'AÑADIR A LAS MÍAS';

  @override
  String get netsStatusLabel => 'Estado de las redes';

  @override
  String get starsLabel => 'Estrellas:';

  @override
  String get netsLabel => 'Redes:';

  @override
  String osmFoundCount(int count) {
    return 'OSM: Se encontraron $count canchas';
  }

  @override
  String get osmFoundCount_desc =>
      'Mensaje de confirmación de los resultados encontrados en OSM';

  @override
  String get courtSaved => '¡Cancha guardada!';

  @override
  String get searchingOsmNearby => 'BUSCANDO CANCHAS OSM CERCANAS...';

  @override
  String get noOsmCourtsFound => 'NO SE ENCONTRARON CANCHAS OSM EN ESTA ZONA';

  @override
  String get osmResultsTitle => 'RESULTADOS OPENSTREETMAP';

  @override
  String get selectCourt => 'Seleccionar Cancha';

  @override
  String courtSelected(String name) {
    return 'Cancha: $name';
  }

  @override
  String get optional => 'Opcional';

  @override
  String get radar_court_link => 'ENLACE RADAR';

  @override
  String get description => 'Descripción';

  @override
  String get leaveCommunityTitle => 'Abandonar Comunidad';

  @override
  String get removeCommunityTitle => 'Eliminar del Dispositivo';

  @override
  String get leaveCommunityOwnerDesc =>
      'La comunidad permanecerá en el servidor sin propietario.\nPodrás reclamarla más tarde desde el panel de administración.\n\n⚠️ Todos los torneos y equipos locales vinculados serán eliminados de este dispositivo.';

  @override
  String get leaveCommunityMemberDesc =>
      'Esta comunidad y todos los torneos locales vinculados serán eliminados de este dispositivo.\n\nLos datos del servidor permanecen sin cambios.';

  @override
  String get leaveCommunityAction => 'Abandonar comunidad del dispositivo';

  @override
  String get removeCommunityAction => 'Eliminar comunidad del dispositivo';

  @override
  String get leaveAction => 'Abandonar';

  @override
  String get removeAction => 'Eliminar';

  @override
  String get rlsViolationError =>
      'Error de seguridad: ya tienes una comunidad activa en la nube o los permisos son insuficientes. Revisa las políticas RLS.';

  @override
  String get sessionError =>
      'Sesión caducada o no válida. Por favor, inicia sesión de nuevo.';

  @override
  String get liveStream => 'LIVE STREAM';

  @override
  String get watchTournamentLive => 'Ver el torneo en vivo';

  @override
  String get retry => 'REINTENTAR';
}
