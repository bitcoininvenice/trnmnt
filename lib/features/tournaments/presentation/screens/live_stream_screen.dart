import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../data/tournaments_repository.dart';
import '../widgets/live_match_widgets.dart';
import '../../../sharing/providers/live_sync_providers.dart';
import 'package:trnmnt/core/widgets/scrolling_ticker.dart';

class LiveStreamScreen extends ConsumerStatefulWidget {
  final String cloudId;
  const LiveStreamScreen({super.key, required this.cloudId});

  @override
  ConsumerState<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends ConsumerState<LiveStreamScreen> {
  Map<String, dynamic>? _mergedData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tournamentAsync = ref.watch(cloudTournamentDetailProvider(widget.cloudId));

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(l10n.liveStream, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        elevation: 0,
      ),
      body: tournamentAsync.when(
        loading: () => _mergedData == null 
            ? _buildSkeletonLoader(context)
            : _buildContent(context, _mergedData!),
        error: (err, stack) => _mergedData == null
            ? Center(child: Text('${l10n.error}: $err', style: const TextStyle(color: Colors.white)))
            : _buildContent(context, _mergedData!),
        data: (rawData) {
          if (rawData == null) {
            setState(() => _mergedData = null);
            return Center(child: Text(l10n.notFound, style: const TextStyle(color: Colors.white)));
          }
          if (_mergedData == null) {
            _mergedData = Map<String, dynamic>.from(rawData);
          } else {
              // LOGICA APPEND / MERGE
              rawData.forEach((key, value) {
                if (value != null) {
                  // Se arriva un campo 'data' (JSONB), controlliamo che non sia vuoto
                  if (key == 'data' && value is Map && value.isEmpty) return;
                  _mergedData![key] = value;
                }
            });
          }

          if (_mergedData == null) {
            return Center(child: Text(l10n.notFound, style: const TextStyle(color: Colors.white)));
          }

          return _buildContent(context, _mergedData!);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> rawData) {
    final l10n = AppLocalizations.of(context)!;
    
    // Estrazione dati resiliente
    final Map<String, dynamic> dataJson = (rawData['data'] is Map) 
        ? Map<String, dynamic>.from(rawData['data'] as Map) 
        : <String, dynamic>{};

    final Map<String, dynamic> tournament = dataJson['tournament'] != null 
        ? Map<String, dynamic>.from(dataJson['tournament'] as Map) 
        : <String, dynamic>{};

    final twitchChannel = tournament['twitchChannel']?.toString() ?? rawData['twitchChannel']?.toString();
    final youtubeVideoId = tournament['youtubeVideoId']?.toString() ?? rawData['youtubeVideoId']?.toString();
    
    if ((twitchChannel == null || twitchChannel.isEmpty) && (youtubeVideoId == null || youtubeVideoId.isEmpty)) {
       return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(l10n.noTournamentsAtMoment, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cloudTournamentDetailProvider(widget.cloudId));
        ref.invalidate(liveMatchesStreamProvider(widget.cloudId));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: Colors.orange,
      backgroundColor: const Color(0xFF1E293B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        key: PageStorageKey('live-scroll-${widget.cloudId}'),
        child: Column(
          children: [
          _LivestreamSection(
            key: ValueKey('live-video-${widget.cloudId}-${twitchChannel ?? youtubeVideoId}'),
            twitchChannel: twitchChannel,
            youtubeVideoId: youtubeVideoId,
            cloudId: widget.cloudId,
          ),
          ScrollingTicker(
            text: (tournament['customTicker']?.toString() ?? 
                  tournament['name']?.toString().toUpperCase() ?? 
                  l10n.liveStream).replaceAll('[REV_Q]', '').trim(),
            // backgroundColor: Colors.orange,
            height: 20,
          ),
          const SizedBox(height: 16),
          _LiveMatchesList(cloudId: widget.cloudId),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _buildSkeletonLoader(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Video Player Skeleton
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                // Header Skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6))),
                      const SizedBox(width: 12),
                      Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
                // Player Area Skeleton
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: Center(
                      child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white.withOpacity(0.03)),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.03)),
          
          const SizedBox(height: 12),
          
          // Ticker Skeleton
          Container(
            height: 32,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1.seconds),
        ],
      ),
    );
  }
}

class _LivestreamSection extends StatefulWidget {
  final String? twitchChannel;
  final String? youtubeVideoId;
  final String cloudId;

  const _LivestreamSection({super.key, this.twitchChannel, this.youtubeVideoId, required this.cloudId});

  @override
  State<_LivestreamSection> createState() => _LivestreamSectionState();
}

class _LivestreamSectionState extends State<_LivestreamSection> {
  WebViewController? _controller;
  bool _isExpanded = true;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(_LivestreamSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.twitchChannel != widget.twitchChannel || 
        oldWidget.youtubeVideoId != widget.youtubeVideoId) {
      _initController();
    }
  }

  void _initController() {
    String url = '';
    if (widget.youtubeVideoId != null && widget.youtubeVideoId!.isNotEmpty) {
      url = 'https://www.youtube.com/embed/${widget.youtubeVideoId}?autoplay=1&mute=0&playsinline=1';
    } else if (widget.twitchChannel != null && widget.twitchChannel!.isNotEmpty) {
      url = 'https://player.twitch.tv/?channel=${widget.twitchChannel}&parent=trnmnt.vercel.app&autoplay=true&muted=false';
    }

    if (url.isEmpty) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF020617))
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
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
    if (_controller == null) return const SizedBox.shrink();

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
                  const Expanded(
                    child: Text(
                      'LIVE STREAM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _hasError 
                    ? Container(
                        color: Colors.black45,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.signal_wifi_off, color: Colors.white24, size: 40),
                              SizedBox(height: 8),
                              Text('STREAM NON DISPONIBILE', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )
                    : WebViewWidget(controller: _controller!),
                ),
                if (_isLoading && !_hasError)
                  const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LiveMatchesList extends ConsumerWidget {
  final String cloudId;
  const _LiveMatchesList({required this.cloudId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveMatchesAsync = ref.watch(liveMatchesStreamProvider(cloudId));
    final l10n = AppLocalizations.of(context)!;

    return liveMatchesAsync.when(
      data: (matches) {
        // Deduplicate by team names to avoid "ghost" doubles
        final Map<String, CloudLiveMatch> uniqueMatches = {};
        for (final m in matches) {
          final key = '${m.homeTeamName}_${m.awayTeamName}'.toLowerCase();
          // Keep the one with the most recent update
          if (!uniqueMatches.containsKey(key) || 
              m.lastUpdate.isAfter(uniqueMatches[key]!.lastUpdate)) {
            uniqueMatches[key] = m;
          }
        }
        
        final displayMatches = uniqueMatches.values.toList()
          ..sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate)); // Show newest first

        if (displayMatches.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.scoreboard_outlined, color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'PARTITE IN CORSO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: displayMatches.length,
              itemBuilder: (context, index) {
                final m = displayMatches[index];
                return LiveMatchCard(
                  homeName: m.homeTeamName ?? 'Home',
                  awayName: m.awayTeamName ?? 'Away',
                  homeScoreOverride: m.homeScore,
                  awayScoreOverride: m.awayScore,
                  timerOverride: m.timer,
                  cloudId: cloudId,
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
