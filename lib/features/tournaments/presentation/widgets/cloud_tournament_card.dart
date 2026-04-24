import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../map/data/courts_repository.dart';
import 'tournament_status_badge.dart';

enum CloudTournamentCardStyle { compact, wide }

class CloudTournamentCard extends ConsumerWidget {
  final Map<String, dynamic> data;
  final CloudTournamentCardStyle style;
  final String? translatedMode; // Optional, for Home screen compatibility

  const CloudTournamentCard({
    super.key,
    required this.data,
    this.style = CloudTournamentCardStyle.wide,
    this.translatedMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tournamentMap = Map<String, dynamic>.from(data['tournament'] ?? {});
    final id = data['id']?.toString() ?? tournamentMap['id']?.toString();
    
    // 1. Resolve Location Name
    String locationText = tournamentMap['location']?.toString() ?? '';
    
    // Check both levels for venue_court_id
    final venueCourtId = data['venue_court_id']?.toString() ?? 
                         tournamentMap['venue_court_id']?.toString() ?? 
                         tournamentMap['venueCourtId']?.toString();
    
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

    // 2. Render based on style
    if (style == CloudTournamentCardStyle.compact) {
      return _buildCompactCard(context, id, tournamentMap, locationText, venueCourtId);
    } else {
      return _buildWideCard(context, id, tournamentMap, locationText, venueCourtId);
    }
  }

  Widget _buildCompactCard(BuildContext context, String? id, Map<String, dynamic> tournament, String locationText, String? venueCourtId) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.orange.withOpacity(0.1),
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.sports_basketball, size: 120, color: Colors.orange.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TournamentStatusBadge(data: data), // Pass full data to check all levels
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isConcluded(tournament) && 
                            ((tournament['twitchChannel']?.toString().isNotEmpty ?? false) || 
                             (tournament['youtubeVideoId']?.toString().isNotEmpty ?? false)))
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.live_tv, color: Colors.red, size: 14),
                          ),
                        const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                if (tournament['startDate'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(tournament['startDate']),
                          style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          translatedMode ?? TournamentModeBadge.getTranslatedMode(context, tournament['mode']?.toString() ?? 'group_only'),
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                Text(
                  (tournament['name']?.toString() ?? 'TOURNAMENT').toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, height: 1.1),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (kDebugMode && venueCourtId != null && venueCourtId.isNotEmpty && locationText == 'Posizione non specificata') 
                            Text("ID: $venueCourtId", style: const TextStyle(color: Colors.red, fontSize: 8)),
                          Text(
                            locationText,
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: () => _handleOnTap(context, id)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideCard(BuildContext context, String? id, Map<String, dynamic> tournament, String locationText, String? venueCourtId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E293B),
      child: InkWell(
        onTap: () => _handleOnTap(context, id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TournamentStatusBadge(data: data),
                  const Spacer(),
                  if (!_isConcluded(tournament) && 
                      ((tournament['twitchChannel']?.toString().isNotEmpty ?? false) || 
                       (tournament['youtubeVideoId']?.toString().isNotEmpty ?? false)))
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.live_tv, color: Colors.red, size: 16),
                    ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                tournament['name']?.toString().toUpperCase() ?? 'TOURNAMENT',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   const Icon(Icons.location_on, size: 14, color: Colors.orange),
                   const SizedBox(width: 4),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         if (kDebugMode && venueCourtId != null && venueCourtId.isNotEmpty && locationText == 'Posizione non specificata') 
                           Text("ID: $venueCourtId", style: const TextStyle(color: Colors.red, fontSize: 8)),
                         Text(
                           locationText, 
                           style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(width: 8),
                   TournamentModeBadge(mode: tournament['mode']?.toString() ?? 'group_only'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOnTap(BuildContext context, String? id) {
    if (id != null) {
      context.push('/hub/tournament/$id');
    }
  }

  bool _isConcluded(Map<String, dynamic> tournament) {
    final dateVal = tournament['startDate'] ?? tournament['start_date'];
    DateTime? startDate;
    if (dateVal is String) {
      startDate = DateTime.tryParse(dateVal);
    } else if (dateVal is int) {
      startDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
    }

    final endDateVal = tournament['endDate'] ?? tournament['end_date'];
    DateTime? endDate;
    if (endDateVal is String) {
      endDate = DateTime.tryParse(endDateVal);
    } else if (endDateVal is int) {
      endDate = DateTime.fromMillisecondsSinceEpoch(endDateVal);
    }

    if (startDate == null) return false;
    final now = DateTime.now();

    if (endDate != null) {
      return now.isAfter(endDate);
    } else {
      final twentyFourHoursAfterStart = startDate.add(const Duration(hours: 24));
      return now.isAfter(twentyFourHoursAfterStart);
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    DateTime? dt;
    if (value is String) dt = DateTime.tryParse(value);
    if (value is int) dt = DateTime.fromMillisecondsSinceEpoch(value);
    if (dt == null) return value.toString();
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
