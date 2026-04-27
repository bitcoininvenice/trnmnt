import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/features/tournaments/presentation/widgets/tournament_status_badge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data/tournaments_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../sharing/data/share_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter/foundation.dart';
import '../../../map/data/courts_repository.dart';

class CloudTournamentDetailScreen extends ConsumerStatefulWidget {
  final String cloudId;
  const CloudTournamentDetailScreen({super.key, required this.cloudId});

  @override
  ConsumerState<CloudTournamentDetailScreen> createState() => _CloudTournamentDetailScreenState();
}

class _CloudTournamentDetailScreenState extends ConsumerState<CloudTournamentDetailScreen> {
  RealtimeChannel? _presenceChannel;
  RealtimeChannel? _globalChannel;
  int _spectatorCount = 0;
  String? _currentDbId;
  String? _sessionKey;
  bool _hasRecordedHit = false;
  late ShareRepository _shareRepo;
  
  // STATO PERSISTENTE: Facciamo il merge qui per evitare scatti
  Map<String, dynamic>? _mergedData;

  @override
  void initState() {
    super.initState();
    _shareRepo = ref.read(shareRepositoryProvider);
    
    // Record visit immediately when screen is opened
    _sessionKey = 'app-${DateTime.now().millisecondsSinceEpoch}-${widget.cloudId}';
    _shareRepo.recordTournamentHit(
      widget.cloudId,
      liveCount: 1,
      sessionId: _sessionKey,
    );
    _hasRecordedHit = true;
  }

  void _setupPresence(String dbId) {
    // Unsubscribe from previous if any
    _presenceChannel?.unsubscribe();
    _globalChannel?.unsubscribe();

    final supabase = Supabase.instance.client;
    final channelId = 'live-tournament-$dbId';
    
    // Use a unique session key for the app instance
    _sessionKey = 'app-${DateTime.now().millisecondsSinceEpoch}-${widget.cloudId}';
    
    _presenceChannel = supabase.channel(channelId);
    _globalChannel = supabase.channel('live-tournament-global', opts: RealtimeChannelConfig(
      key: _sessionKey!,
    ));

    void updateCount() {
      if (!mounted) return;
      final channel = _presenceChannel;
      if (channel == null) return;

      try {
        final state = channel.presenceState();
        int total = 0;
        for (final item in state) {
          total += item.presences.length;
        }

        if (mounted) {
          setState(() {
            _spectatorCount = total;
          });
        }
      } catch (e) {
      }
    }

    _presenceChannel!
      .onPresenceSync((payload) => updateCount())
      .onPresenceJoin((payload) => updateCount())
      .onPresenceLeave((payload) => updateCount())
      .subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _presenceChannel!.track({
            'platform': 'app',
            'online_at': DateTime.now().toIso8601String(),
            'session_id': _sessionKey,
          });
          updateCount();
        }
      });

    // Track globally for admin
    _globalChannel!.subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _globalChannel!.track({
          't_id': dbId,
          'platform': 'app',
          'online_at': DateTime.now().toIso8601String(),
          'session_id': _sessionKey,
        });
      }
    });
  }

  @override
  void dispose() {
    if (_sessionKey != null) {
      _shareRepo.endTournamentHit(_sessionKey!);
    }
    _presenceChannel?.unsubscribe();
    _globalChannel?.unsubscribe();
    _presenceChannel = null;
    _globalChannel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(cloudTournamentDetailProvider(widget.cloudId));
    
    return tournamentAsync.when(
      loading: () => _mergedData != null 
          ? _buildMainContent(context, _mergedData!) 
          : _buildSkeletonLoader(context),
      error: (e, s) => Scaffold(backgroundColor: const Color(0xFF020617), body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white)))),
      data: (rawData) {
        if (rawData == null) {
          if (_mergedData != null) return _buildMainContent(context, _mergedData!);
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(backgroundColor: const Color(0xFF020617), body: Center(child: Text(l10n.notFound, style: const TextStyle(color: Colors.white))));
        }

        // LOGICA DI MERGE (APPEND): Non perdiamo mai i dati vecchi
        if (_mergedData == null) {
          _mergedData = Map<String, dynamic>.from(rawData);
        } else {
          // Fondiamo i nuovi dati con quelli vecchi
          rawData.forEach((key, value) {
            if (value != null) {
              // Se arriva un campo 'data' (JSONB), controlliamo che non sia vuoto
              if (key == 'data' && value is Map && value.isEmpty) {
                // Se il nuovo data è vuoto, manteniamo quello vecchio
                return;
              }
              _mergedData![key] = value;
            }
          });
        }

        return _buildMainContent(context, _mergedData!);
      },
    );
  }

  Widget _buildMainContent(BuildContext context, Map<String, dynamic> rawData) {
    final l10n = AppLocalizations.of(context)!;

    // Estrazione dati resiliente (coerente con Calendar e altri)
    final Map<String, dynamic> data = (rawData['data'] is Map 
        ? Map<String, dynamic>.from(rawData['data'] as Map) 
        : Map<String, dynamic>.from(rawData));

    final views = ((rawData['app_views'] as num? ?? 0) + (rawData['web_views'] as num? ?? 0)).toInt();
    final spectators = _spectatorCount > 0 ? _spectatorCount : (rawData['spectators'] as num? ?? 0).toInt();
    
    final dbId = data['id']?.toString() ?? widget.cloudId;
    if (dbId != _currentDbId && dbId.isNotEmpty) {
      _currentDbId = dbId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _setupPresence(dbId));
    }

    final Map<String, dynamic> tournament = data['tournament'] != null 
        ? Map<String, dynamic>.from(data['tournament'] as Map) 
        : <String, dynamic>{};
    final teams = data['teams'] as List? ?? [];
    
    // Recupero descrizione (dalla colonna o dal JSON)
    final effectiveDescription = rawData['description']?.toString() ?? tournament['description']?.toString();

    final twitchChannel = tournament['twitchChannel']?.toString();
    final youtubeVideoId = tournament['youtubeVideoId']?.toString();
    final hasVideo = (twitchChannel != null && twitchChannel.isNotEmpty) || 
                     (youtubeVideoId != null && youtubeVideoId.isNotEmpty);

    // 1. Resolve Location and Coordinates
    String locationText = tournament['location']?.toString() ?? '';
    double? lat = (tournament['latitude'] as num?)?.toDouble();
    double? lon = (tournament['longitude'] as num?)?.toDouble();
    
    final venueCourtId = data['venue_court_id']?.toString() ?? 
                         tournament['venue_court_id']?.toString() ?? 
                         tournament['venueCourtId']?.toString();
    
    if (venueCourtId != null && venueCourtId.isNotEmpty) {
      final courtsAsync = ref.watch(mergedCourtsProvider);
      final match = courtsAsync.when(
        data: (courts) => courts.where((c) {
          final courtCloudId = c.cloudId?.toString();
          final courtSourceId = c.sourceId?.toString();
          return courtCloudId == venueCourtId || courtSourceId == venueCourtId;
        }).firstOrNull,
        loading: () => null,
        error: (_, __) => null,
      );
      
      if (match != null) {
        locationText = match.name;
        lat = match.latitude;
        lon = match.longitude;
      }
    }

    if (locationText.isEmpty) {
      locationText = l10n.noTournamentsAtMoment;
      if (locationText.contains('moment')) locationText = 'Posizione non specificata';
    }

    void openMap() {
      Uri uri;
      if (lat != null && lon != null) {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
      } else if (locationText.isNotEmpty && locationText != 'Posizione non specificata') {
        uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationText)}');
      } else {
        return;
      }
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    void addToCalendar() {
      final startDateVal = tournament['startDate'];
      DateTime? startDt;
      if (startDateVal is String) startDt = DateTime.tryParse(startDateVal);
      else if (startDateVal is int) startDt = DateTime.fromMillisecondsSinceEpoch(startDateVal);

      if (startDt == null) return;

      final endDt = startDt.add(const Duration(hours: 4));
      
      String formatGDate(DateTime dt) {
        final u = dt.toUtc();
        return '${u.year}${u.month.toString().padLeft(2, '0')}${u.day.toString().padLeft(2, '0')}T${u.hour.toString().padLeft(2, '0')}${u.minute.toString().padLeft(2, '0')}${u.second.toString().padLeft(2, '0')}Z';
      }

      final title = Uri.encodeComponent(tournament['name']?.toString() ?? 'Torneo Basket');
      final location = Uri.encodeComponent(locationText);
      final dates = '${formatGDate(startDt)}/${formatGDate(endDt)}';
      
      final url = 'https://www.google.com/calendar/render?action=TEMPLATE&text=$title&location=$location&dates=$dates';
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                icon: const Icon(Icons.public, color: Colors.white70),
                onPressed: () {
                  final effectiveId = dbId ?? widget.cloudId;
                  String? webUrl = rawData['webUrl']?.toString();
                  if ((webUrl == null || webUrl.isEmpty)) {
                    webUrl = 'https://trnmnt.vercel.app/it/tournaments/$effectiveId';
                  }
                  launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
                },
                tooltip: 'Apri nel Browser',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(tournament['name']?.toString() ?? 'TOURNAMENT', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.8),
                      Colors.orange.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.cloud_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderBadge(
                          context, 
                          icon: Icons.stadium, 
                          label: locationText, 
                          color: Colors.orange,
                          onTap: openMap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildHeaderBadge(
                        context, 
                        icon: Icons.calendar_today, 
                        label: _formatDate(tournament['startDate']),
                        color: Colors.blue,
                        onTap: addToCalendar,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Community Branding
                  if (tournament['communityName'] != null || rawData['community_slug'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hub_outlined, size: 12, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              (tournament['communityName'] ?? rawData['community_slug'] ?? '').toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // STATS ROW
                  Row(
                    children: [
                       _buildStatBadge(context, label: 'VIEWS', value: '$views', icon: Icons.remove_red_eye_outlined, color: Colors.blueGrey),
                       const SizedBox(width: 12),
                       _buildStatBadge(context, label: 'LIVE', value: '$spectators', icon: Icons.sensors, color: Colors.redAccent),
                       const Spacer(),
                       TournamentStatusBadge(data: data),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),
                  
                  // Teams Section
                  Text(
                    l10n.participatingTeams.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  if (teams.isEmpty)
                    Text(l10n.noTournaments, style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: teams.map((t) {
                          final team = Map<String, dynamic>.from(t);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              backgroundColor: const Color(0xFF1E293B),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              label: Text(team['name']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 32),
                  
                  // Action Grid
                  Text(
                    l10n.tournamentStages.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                  ),
                  _buildActionCards(context, tournament, hasVideo: hasVideo),
                  
                  if (effectiveDescription != null && effectiveDescription.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      l10n.description.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Text(
                        effectiveDescription,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            backgroundColor: const Color(0xFF0F172A),
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.emoji_events, size: 80, color: Colors.white.withOpacity(0.05)),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.05)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Skeleton
                  Container(
                    height: 32,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds),
                  const SizedBox(height: 16),
                  
                  // Stats Row Skeleton
                  Row(
                    children: [
                      Container(width: 80, height: 24, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12))),
                      const SizedBox(width: 12),
                      Container(width: 80, height: 24, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12))),
                    ],
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds, delay: 200.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Action Grid Header Skeleton
                  Container(width: 120, height: 16, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 16),
                  
                  // Action Grid Skeleton
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: List.generate(4, (index) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, delay: (index * 100).ms)),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Description Header Skeleton
                  Container(width: 100, height: 16, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds, delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(BuildContext context, {required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label, 
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, {required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context, Map<String, dynamic> tournament, {bool hasVideo = false}) {
    final mode = tournament['mode']?.toString() ?? 'group_only';
    final l10n = AppLocalizations.of(context)!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        if (hasVideo)
          _buildActionCard(
            context,
            icon: Icons.live_tv,
            title: l10n.liveStream,
            subtitle: l10n.watchTournamentLive,
            color: Colors.red,
            onTap: () => context.push('/tournaments/${widget.cloudId}/live'),
          ),
        _buildActionCard(
          context,
          icon: Icons.calendar_month,
          title: l10n.calendar,
          subtitle: l10n.groupPhase,
          color: Colors.blue,
          onTap: () => context.push('/tournaments/${widget.cloudId}/calendar'),
        ),
         _buildActionCard(
          context,
          icon: Icons.leaderboard,
          title: l10n.standings,
          subtitle: l10n.pointsAndStats,
          color: Colors.green,
          onTap: () => context.push('/tournaments/${widget.cloudId}/standings'),
        ),
        if (mode != 'group_only' && mode != 'madness')
          _buildActionCard(
            context,
            icon: Icons.account_tree,
            title: l10n.elimination,
            subtitle: l10n.playoffBracket,
            color: Colors.orange,
            onTap: () => context.push('/tournaments/${widget.cloudId}/bracket'),
          ),
        if (mode == 'madness')
          _buildActionCard(
            context,
            icon: Icons.flash_on,
            title: l10n.madness,
            subtitle: l10n.madnessSubtitle,
            color: Colors.deepPurple,
            onTap: () => context.push('/tournaments/${widget.cloudId}/madness'),
          ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(subtitle, 
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
     if (value == null) return '';
     if (value is String) {
       final dt = DateTime.tryParse(value);
       if (dt != null) {
         final dateStr = "${dt.day}/${dt.month}/${dt.year}";
         final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
         return "$dateStr $timeStr";
       }
     }
     if (value is int) {
       final dt = DateTime.fromMillisecondsSinceEpoch(value);
       final dateStr = "${dt.day}/${dt.month}/${dt.year}";
       final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
       return "$dateStr $timeStr";
     }
     return value.toString();
  }
}

