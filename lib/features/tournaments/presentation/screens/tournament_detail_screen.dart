import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trnmnt/features/sharing/data/sync_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/features/sharing/data/share_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/features/community/data/community_repository.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen> {
  late SyncRepository _syncRepo;

  @override
  void initState() {
    super.initState();
    _syncRepo = ref.read(syncRepositoryProvider);
    _handleSubscription();
  }

  @override
  void dispose() {
    _syncRepo.unsubscribe();
    super.dispose();
  }

  void _handleSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
    if (!mounted) return;
    
    if (tournament != null && tournament.cloudId != null) {
      ref.read(syncRepositoryProvider).subscribeToTournament(
        tournament.cloudId!, 
        widget.tournamentId
      );
    }
  }

  Future<String?> _showSimpleInputDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller, 
          autofocus: true, 
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.name,
            hintStyle: const TextStyle(color: Colors.white24),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
          ),
          onSubmitted: (val) => Navigator.pop(context, val),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel.toUpperCase(), style: const TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(AppLocalizations.of(context)!.addAction.toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _enableWebRegistrations(String cloudId, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final maxTeamsController = TextEditingController(text: '16');
    bool showLunch = true;
    List<String> lunchOptions = ['Pranzo al Sacco', 'Chiosco Ambulante'];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.configureRegistrations, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: maxTeamsController,
                  decoration: InputDecoration(
                    labelText: l10n.maxTeamsLabel,
                    labelStyle: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(l10n.enableLunchChoice, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  value: showLunch,
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setDialogState(() => showLunch = v),
                ),
                if (showLunch) ...[
                  const Divider(color: Colors.white24),
                  ...lunchOptions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.value, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                          onPressed: () => setDialogState(() => lunchOptions.removeAt(entry.key)),
                        ),
                      ],
                    ),
                  )),
                  TextButton.icon(
                    onPressed: () async {
                      final name = await _showSimpleInputDialog(l10n.newOption);
                      if (name != null && name.trim().isNotEmpty) {
                        setDialogState(() => lunchOptions.add(name.trim()));
                      }
                    },
                    icon: const Icon(Icons.add, size: 16, color: Colors.orange),
                    label: Text(l10n.addOption, style: const TextStyle(color: Colors.orange, fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: Text(l10n.cancel.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(l10n.activateNow, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final shareRepo = ref.read(shareRepositoryProvider);
        await shareRepo.createRegistrationSettings(
          cloudId: cloudId,
          maxTeams: int.tryParse(maxTeamsController.text) ?? 16,
          showLunch: showLunch,
          lunchOptions: lunchOptions,
        );
        
        // Refresh the provider
        ref.invalidate(registrationSettingsProvider(cloudId));
        
        if (mounted) {
          // Navigate immediately. The management screen will show the state.
          context.push('/tournaments/${widget.tournamentId}/registrations?cloudId=$cloudId');
        }
      } catch (e) {
        debugPrint('DB ERROR: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournamentAsync = ref.watch(tournamentByIdProvider(widget.tournamentId));
    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));

    return tournamentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange))),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.error)),
        body: Center(child: Text('${AppLocalizations.of(context)!.error}: $error')),
      ),
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.notFound)),
            body: Center(child: Text(AppLocalizations.of(context)!.tournamentNotFound)),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF020617),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150,
                pinned: true,
                backgroundColor: const Color(0xFF0F172A),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(tournament.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (tournament.cloudId != null && tournament.isWebRegistrationEnabled)
                    Consumer(
                      builder: (context, ref, child) {
                        final settingsAsync = ref.watch(registrationSettingsProvider(tournament.cloudId!));
                        return settingsAsync.when(
                          loading: () => const SizedBox(width: 48, child: Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))),
                          error: (_, __) => IconButton(
                            icon: const Icon(Icons.add_task, color: Colors.grey),
                            onPressed: () => _enableWebRegistrations(tournament.cloudId!, tournament.name),
                          ),
                          data: (settings) {
                            if (settings == null) {
                              return IconButton(
                                icon: const Icon(Icons.add_task, color: Colors.orangeAccent),
                                tooltip: AppLocalizations.of(context)!.enableWebRegistrations,
                                onPressed: () => _enableWebRegistrations(tournament.cloudId!, tournament.name),
                              );
                            }
                            return IconButton(
                              icon: const Icon(Icons.how_to_reg, color: Colors.orangeAccent),
                              tooltip: AppLocalizations.of(context)!.manageRegistrations,
                              onPressed: () => context.push('/tournaments/${widget.tournamentId}/registrations?cloudId=${tournament.cloudId}'),
                            );
                          },
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => context.push('/share/${widget.tournamentId}?name=${tournament.name}'),
                  ),
                  if (!tournament.isReadOnly)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.go('/tournaments/${widget.tournamentId}/edit'),
                    ),
                ],
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
                              label: tournament.location, 
                              color: Colors.orange
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderBadge(
                            context, 
                            icon: Icons.calendar_today, 
                            label: tournament.startDate != null 
                              ? "${tournament.startDate!.day}/${tournament.startDate!.month}/${tournament.startDate!.year}"
                              : "${tournament.createdAt.day}/${tournament.createdAt.month}/${tournament.createdAt.year}", 
                            color: Colors.blue
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Status & Community Row
                      Row(
                        children: [
                          if (tournament.isPublished)
                             _buildStatusChip(context, "CLOUD", Colors.blue),
                          if (tournament.communityId != null) ...[
                            const SizedBox(width: 8),
                            _CommunityBadge(
                              communityId: tournament.communityId!,
                              communityName: tournament.communityName,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 32),
                      
                      if (tournament.cloudId != null && tournament.isWebRegistrationEnabled) ...[
                        Consumer(
                          builder: (context, ref, child) {
                            final settingsAsync = ref.watch(registrationSettingsProvider(tournament.cloudId!));
                            return settingsAsync.maybeWhen(
                              data: (settings) {
                                if (settings == null) {
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.public, color: Colors.orange, size: 32),
                                        const SizedBox(height: 12),
                                        Text(AppLocalizations.of(context)!.registrationsNotActive, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(AppLocalizations.of(context)!.createPublicPageDesc, 
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white70, fontSize: 11)
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () => _enableWebRegistrations(tournament.cloudId!, tournament.name),
                                          icon: const Icon(Icons.add_task),
                                          label: Text(AppLocalizations.of(context)!.activateNow),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
                                }
                                return const SizedBox.shrink();
                              },
                              orElse: () => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],

                      // Teams Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.manualParticipants,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                          ),
                          TextButton(
                            onPressed: () => context.push('/tournaments/${widget.tournamentId}/edit'),
                            child: Text(AppLocalizations.of(context)!.edit.toUpperCase(), style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      teamsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, s) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                        data: (teams) => teams.isEmpty 
                          ? Text(AppLocalizations.of(context)!.noTournaments, style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic))
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: teams.map((tt) {
                                  final groupLabel = (tournament.groupCount > 1) 
                                      ? ' (${String.fromCharCode(64 + tt.tournamentTeam.groupNumber)})' 
                                      : '';
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      backgroundColor: const Color(0xFF1E293B),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      label: Text('${tt.team.name}$groupLabel', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                      ),

                      const SizedBox(height: 32),
                      
                      // Action Grid
                      Text(
                        AppLocalizations.of(context)!.tournamentStages,
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

  Widget _buildActionCards(BuildContext context, dynamic tournament) {
    final mode = tournament.mode;
    final actions = <Widget>[];

    if (mode == 'group_only' || mode == 'group_and_elimination') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.calendar_month,
        title: AppLocalizations.of(context)!.calendar,
        subtitle: AppLocalizations.of(context)!.groupPhase,
        color: Colors.blue,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/calendar'),
      ));
      actions.add(_buildActionCard(
        context,
        icon: Icons.leaderboard,
        title: AppLocalizations.of(context)!.standings,
        subtitle: AppLocalizations.of(context)!.pointsAndStats,
        color: Colors.green,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/standings'),
      ));
    }

    final isEliminationMode = mode == 'elimination_only' || mode == 'group_and_elimination';
    final hasMultiGroups = (tournament.groupCount ?? 1) > 1;
    
    if (isEliminationMode || hasMultiGroups) {
      actions.add(_buildActionCard(
        context,
        icon: Icons.account_tree,
        title: AppLocalizations.of(context)!.elimination,
        subtitle: hasMultiGroups && !isEliminationMode ? AppLocalizations.of(context)!.finals : AppLocalizations.of(context)!.playoffBracket,
        color: Colors.orange,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/bracket'),
      ));
    }

    if (mode == 'madness') {
      actions.add(_buildActionCard(
        context,
        icon: Icons.flash_on,
        title: AppLocalizations.of(context)!.madness,
        subtitle: AppLocalizations.of(context)!.madnessSubtitle,
        color: Colors.deepPurple,
        onTap: () => context.go('/tournaments/${widget.tournamentId}/madness'),
      ));
    }

    actions.add(_buildActionCard(
      context,
      icon: Icons.gavel_outlined,
      title: AppLocalizations.of(context)!.rules,
      subtitle: AppLocalizations.of(context)!.modeLegend,
      color: Colors.brown,
      onTap: () => context.push('/settings/legend/$mode'),
    ));

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: actions.asMap().entries.map((entry) {
        return entry.value.animate().fadeIn(delay: Duration(milliseconds: 100 * entry.key)).scale(begin: const Offset(0.9, 0.9));
      }).toList(),
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
}

class _CommunityBadge extends ConsumerWidget {
  final String communityId;
  final String? communityName;
  const _CommunityBadge({required this.communityId, this.communityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityByIdProvider(communityId));
    return communityAsync.when(
      data: (community) {
        final name = community?.name ?? communityName;
        if (name == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(name, style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.w900)),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
