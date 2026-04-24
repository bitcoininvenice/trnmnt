import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class TournamentStatusBadge extends ConsumerWidget {
  final Map<String, dynamic> data;
  final bool? isLiveOverride;

  const TournamentStatusBadge({
    super.key,
    required this.data,
    this.isLiveOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournament = Map<String, dynamic>.from(data['tournament'] ?? {});
    final tournamentId = tournament['id'] ?? data['id'] ?? data['tournament_id'];
    
    // Parse dates
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

    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    String label = '';
    Color color = Colors.blue;
    IconData icon = Icons.calendar_today;

    if (startDate == null) {
      label = l10n.upcoming;
    } else if (now.isBefore(startDate)) {
      // 1. Upcoming
      label = l10n.upcoming;
      color = Colors.blue;
      icon = Icons.calendar_today;
    } else {
      // Check if concluded
      bool isConcluded = false;
      if (endDate != null) {
        if (now.isAfter(endDate)) {
          isConcluded = true;
        }
      } else {
        // No end date, check 24h from start
        final twentyFourHoursAfterStart = startDate.add(const Duration(hours: 24));
        if (now.isAfter(twentyFourHoursAfterStart)) {
          isConcluded = true;
        }
      }

      if (isConcluded) {
        // 2. Concluded
        label = l10n.concluded;
        color = Colors.grey;
        icon = Icons.check_circle_outline;
      } else {
        // 3. Live
        label = 'LIVE';
        color = Colors.green;
        icon = Icons.sensors;
      }
    }

    // Explicit overrides still take precedence for manual control
    if (isLiveOverride == true) {
      label = 'LIVE';
      color = Colors.green;
      icon = Icons.sensors;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TournamentModeBadge extends StatelessWidget {
  final String mode;

  const TournamentModeBadge({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == 'group_only') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        getTranslatedMode(context, mode),
        style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }

  static String getTranslatedMode(BuildContext context, String mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case 'group_only':
        return l10n.groupOnly;
      case 'brackets_only':
      case 'elimination_only':
        return l10n.eliminationOnly;
      case 'group_and_brackets':
      case 'group_and_elimination':
        return l10n.groupAndElimination;
      case 'madness':
        return l10n.madness;
      default:
        return mode;
    }
  }
}
