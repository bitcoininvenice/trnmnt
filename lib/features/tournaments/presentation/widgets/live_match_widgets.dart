import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/database/app_database.dart';
import '../../../game/providers/game_provider.dart';
import '../../../sharing/providers/live_sync_providers.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class LiveMatchBadge extends ConsumerWidget {
  final TournamentMatch match;
  final String? cloudId;
  final String? homeName;
  final String? awayName;

  const LiveMatchBadge({
    super.key,
    required this.match,
    required this.cloudId,
    this.homeName,
    this.awayName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGame = ref.watch(activeGameProvider);
    final isLocalLive = activeGame.matchId == match.id;
    final l10n = AppLocalizations.of(context)!;

    // Check cloud data if not local live
    final cloudData = ref.watch(cloudMatchLiveDataProviderV2((
      cloudId: cloudId, 
      homeName: homeName,
      awayName: awayName,
      phase: match.phase,
      round: match.round,
    )));
    final isCloudLive = cloudData != null && !cloudData.isStale;

    if (!isLocalLive && !isCloudLive) {
      return const Text(
        'vs',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      );
    }

    final String time = isLocalLive ? activeGame.formattedTime : (cloudData?.timer ?? '--:--');
    final int homeScore = isLocalLive ? activeGame.homeScore : (cloudData?.homeScore ?? 0);
    final int awayScore = isLocalLive ? activeGame.awayScore : (cloudData?.awayScore ?? 0);
    
    // For guests/cloud matches, use GreenAccent
    final Color badgeColor = isLocalLive ? Colors.orange : Colors.greenAccent;
    final String label = l10n.live.toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label, 
          style: TextStyle(
            color: badgeColor, 
            fontWeight: FontWeight.w900, 
            fontSize: 9, 
            letterSpacing: 1.0
          )
        ),
        Text(
          '$homeScore - $awayScore',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: badgeColor),
        ),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 10, 
            color: Colors.white.withValues(alpha: 0.7), 
            fontFamily: 'monospace'
          ),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}

class LiveMatchCard extends StatelessWidget {
  final String homeName;
  final String awayName;
  final TournamentMatch? match; // Made optional
  final String? cloudId;
  final bool isCompleted;
  final int? homeScoreOverride;
  final int? awayScoreOverride;
  final String? timerOverride;

  const LiveMatchCard({
    super.key,
    required this.homeName,
    required this.awayName,
    this.match,
    this.cloudId,
    this.isCompleted = false,
    this.homeScoreOverride,
    this.awayScoreOverride,
    this.timerOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: const Color(0xFF1E293B), // Dark blue/grey background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          children: [
            // Home team
            Expanded(
              child: Text(
                homeName,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Score / Badge
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCompleted
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${homeScoreOverride ?? match?.homeScore ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: (homeScoreOverride ?? match?.homeScore ?? 0) > (awayScoreOverride ?? match?.awayScore ?? 0) ? Colors.greenAccent : Colors.white,
                          ),
                        ),
                        const Text(' - ', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          '${awayScoreOverride ?? match?.awayScore ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: (awayScoreOverride ?? match?.awayScore ?? 0) > (homeScoreOverride ?? match?.homeScore ?? 0) ? Colors.greenAccent : Colors.white,
                          ),
                        ),
                      ],
                    )
                  : (match != null 
                      ? LiveMatchBadge(
                          match: match!,
                          cloudId: cloudId,
                          homeName: homeName,
                          awayName: awayName,
                        )
                      : _SimpleLiveBadge(
                          homeScore: homeScoreOverride ?? 0,
                          awayScore: awayScoreOverride ?? 0,
                          timer: timerOverride ?? '--:--',
                        )),
            ),
            
            // Away team
            Expanded(
              child: Text(
                awayName,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleLiveBadge extends StatelessWidget {
  final int homeScore;
  final int awayScore;
  final String timer;

  const _SimpleLiveBadge({
    required this.homeScore,
    required this.awayScore,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const Color badgeColor = Colors.greenAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.live.toUpperCase(), 
          style: const TextStyle(
            color: badgeColor, 
            fontWeight: FontWeight.w900, 
            fontSize: 10, 
            letterSpacing: 1.2
          )
        ),
        Text(
          '$homeScore - $awayScore',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: badgeColor),
        ),
        Text(
          timer,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 12, 
            color: Colors.white.withValues(alpha: 0.7), 
            fontFamily: 'monospace'
          ),
        ),
      ],
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}
