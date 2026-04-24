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

  @override
  void initState() {
    super.initState();
    _shareRepo = ref.read(shareRepositoryProvider);
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
          
          // Record hit ONLY ONCE after successful subscription to capture real count
          if (!_hasRecordedHit) {
             _hasRecordedHit = true;
             // Use a short delay to let sync complete
             Future.delayed(const Duration(milliseconds: 500), () {
               if (mounted) {
                 ref.read(shareRepositoryProvider).recordTournamentHit(
                   widget.cloudId, 
                   liveCount: _spectatorCount > 0 ? _spectatorCount : 1,
                   sessionId: _sessionKey,
                 );
               }
             });
          }
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
    // Use ref.listen to handle presence setup when data arrives/changes
    ref.listen(cloudTournamentDetailProvider(widget.cloudId), (previous, next) {
      if (next.hasValue && next.value != null) {
        final data = next.value!['data'] as Map<String, dynamic>?;
        if (data != null) {
          final dbId = data['id']?.toString() ?? widget.cloudId;
          if (dbId != _currentDbId) {
            _currentDbId = dbId;
            _setupPresence(dbId);
          }
        }
      }
    });

    final tournamentAsync = ref.watch(cloudTournamentDetailProvider(widget.cloudId));
    final l10n = AppLocalizations.of(context)!;

    return tournamentAsync.when(
      loading: () => const Scaffold(backgroundColor: Color(0xFF020617), body: Center(child: CircularProgressIndicator(color: Colors.orange))),
      error: (e, s) => Scaffold(backgroundColor: Color(0xFF020617), body: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white)))),
      data: (rawData) {
        if (rawData == null) {
          return Scaffold(backgroundColor: Color(0xFF020617), body: Center(child: Text(l10n.notFound, style: const TextStyle(color: Colors.white))));
        }

        final data = rawData['data'] as Map<String, dynamic>?;
        if (data == null) return const Scaffold(body: Center(child: Text('Invalid Data')));

        final views = (rawData['views'] as num? ?? 0).toInt();
        final spectators = _spectatorCount > 0 ? _spectatorCount : (rawData['spectators'] as num? ?? 0).toInt();
        final dbId = data['id']?.toString() ?? widget.cloudId;

        final tournament = data['tournament'] as Map<String, dynamic>? ?? {};
        final teams = data['teams'] as List? ?? [];
        final matches = data['matches'] as List? ?? [];

        final twitchChannel = tournament['twitchChannel']?.toString();
        final youtubeVideoId = tournament['youtubeVideoId']?.toString();
        final hasVideo = (twitchChannel != null && twitchChannel.isNotEmpty) || 
                         (youtubeVideoId != null && youtubeVideoId.isNotEmpty);

        // 1. Resolve Location Name
        String locationText = tournament['location']?.toString() ?? '';
        
        // Check both levels for venue_court_id
        final venueCourtId = data['venue_court_id']?.toString() ?? 
                             tournament['venue_court_id']?.toString() ?? 
                             tournament['venueCourtId']?.toString();
        
        if (venueCourtId != null && venueCourtId.isNotEmpty) {
          final courtsAsync = ref.watch(mergedCourtsProvider);
          final resolvedName = courtsAsync.when(
            data: (courts) {
              final match = courts.where((c) {
                final courtCloudId = c.cloudId?.toString();
                final courtSourceId = c.sourceId?.toString();
                return courtCloudId == venueCourtId || courtSourceId == venueCourtId;
              }).firstOrNull;
              return match?.name;
            },
            loading: () => '...',
            error: (_, __) => null,
          );
          if (resolvedName != null) {
            locationText = resolvedName;
          }
        }

        if (locationText.isEmpty) {
          locationText = l10n.noTournamentsAtMoment; // Or any generic fallback
          if (locationText.contains('moment')) locationText = 'Posizione non specificata';
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
                      String? webUrl = data['webUrl']?.toString();
                      
                      if ((webUrl == null || webUrl.isEmpty)) {
                        webUrl = 'https://trnmnt.vercel.app/it/tournaments/$effectiveId';
                      }

                      final Uri url = Uri.parse(webUrl);
                      launchUrl(url, mode: LaunchMode.externalApplication);
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
              if (hasVideo)
                SliverToBoxAdapter(
                  child: _LivestreamSection(
                    twitchChannel: twitchChannel,
                    youtubeVideoId: youtubeVideoId,
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
                              color: Colors.orange
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderBadge(
                            context, 
                            icon: Icons.calendar_today, 
                            label: _formatDate(tournament['startDate']),
                            color: Colors.blue
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
                        ).animate().fadeIn(delay: 100.ms),

                      // STATS ROW: Views and Live Spectators
                      Row(
                        children: [
                           _buildStatBadge(context, label: 'VIEWS', value: '$views', icon: Icons.remove_red_eye_outlined, color: Colors.blueGrey),
                           const SizedBox(width: 12),
                           _buildStatBadge(context, label: 'LIVE', value: '$spectators', icon: Icons.sensors, color: Colors.redAccent),
                           if (kDebugMode) ...[
                             const SizedBox(width: 8),
                             Text('ID: ${dbId?.substring(0, 5)}...', style: const TextStyle(color: Colors.white24, fontSize: 8)),
                           ],
                           const Spacer(),
                           TournamentStatusBadge(data: data),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

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
                      
                      // Action Grid (Limited for spectator)
                      Text(
                        l10n.tournamentStages.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                      ),
                      _buildActionCards(context, tournament),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderBadge(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
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

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildActionCards(BuildContext context, Map<String, dynamic> tournament) {
    final mode = tournament['mode']?.toString() ?? 'group_only';
    final actions = <Widget>[];
    final l10n = AppLocalizations.of(context)!;

    if (mode == 'group_only' || mode == 'group_and_elimination') {
       // We'll need cloud versions of these screens too, or make them generic
       // For now, let's keep them as action placeholders
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
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

class _LivestreamSection extends StatefulWidget {
  final String? twitchChannel;
  final String? youtubeVideoId;

  const _LivestreamSection({this.twitchChannel, this.youtubeVideoId});

  @override
  State<_LivestreamSection> createState() => _LivestreamSectionState();
}

class _LivestreamSectionState extends State<_LivestreamSection> {
  late final WebViewController _controller;
  bool _isExpanded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    String url = '';
    if (widget.youtubeVideoId != null && widget.youtubeVideoId!.isNotEmpty) {
      url = 'https://www.youtube.com/embed/${widget.youtubeVideoId}?autoplay=0&mute=1&playsinline=1';
    } else if (widget.twitchChannel != null && widget.twitchChannel!.isNotEmpty) {
      url = 'https://player.twitch.tv/?channel=${widget.twitchChannel}&parent=trnmnt.vercel.app&autoplay=false&muted=true';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF020617))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            // Only show error UI if it's the main frame failing
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() => _hasError = true);
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(url),
        headers: url.contains('twitch.tv') 
          ? {'Referer': 'https://trnmnt.vercel.app/'} 
          : {},
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.live_tv, color: Colors.red, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'LIVE STREAM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 600.ms).fadeOut(duration: 600.ms),
                  const SizedBox(width: 12),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _hasError 
                ? Container(
                    color: Colors.black45,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.signal_wifi_off, color: Colors.white24, size: 40),
                          const SizedBox(height: 8),
                          const Text('STREAM NON DISPONIBILE', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _hasError = false;
                                });
                                _controller.reload();
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 14, color: Colors.orange),
                            label: const Text('RIPROVA', style: TextStyle(color: Colors.orange, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  )
                : WebViewWidget(controller: _controller),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
