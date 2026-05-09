import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trnmnt/features/sharing/data/share_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/features/teams/data/teams_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class RegistrationManagementScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  final String cloudId;

  const RegistrationManagementScreen({
    super.key,
    required this.tournamentId,
    required this.cloudId,
  });

  @override
  ConsumerState<RegistrationManagementScreen> createState() => _RegistrationManagementScreenState();
}

class _RegistrationManagementScreenState extends ConsumerState<RegistrationManagementScreen> {
  bool _isLoading = true;
  bool _isFetchingData = false; // re-entrancy guard
  List<Map<String, dynamic>> _registrations = [];
  Map<String, dynamic>? _settings;
  List<String> _confirmedTeamNames = [];
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted || _isFetchingData) return;
    _isFetchingData = true;
    try {
      final currentRef = ref;
      setState(() => _isLoading = true);
      
      
      final settings = await currentRef.refresh(registrationSettingsProvider(widget.cloudId).future);
      if (!mounted) return;
      
      
      final repo = currentRef.read(shareRepositoryProvider);
      final regs = await repo.fetchTournamentRegistrations(widget.cloudId);
      if (!mounted) return;
      
      // Fetch local confirmed teams to improve status check
      final tournamentTeams = await currentRef.read(tournamentTeamsProvider(widget.tournamentId).future);
      if (!mounted) return;
      
      final confirmedNames = tournamentTeams.map((tt) => tt.team.name.trim().toLowerCase()).toList();
      
      setState(() {
        _settings = settings;
        _registrations = regs;
        _confirmedTeamNames = confirmedNames;
        _isLoading = false;
      });
    } catch (e, stack) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } finally {
      _isFetchingData = false;
    }
  }

  Future<void> _createSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final maxTeamsController = TextEditingController(text: '16');
    final minPlayersController = TextEditingController(text: '3');
    final maxPlayersController = TextEditingController(text: '5');
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPlayersController,
                        decoration: const InputDecoration(
                          labelText: 'Min Players / Team',
                          labelStyle: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: maxPlayersController,
                        decoration: const InputDecoration(
                          labelText: 'Max Players / Team',
                          labelStyle: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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
              child: Text(l10n.createPage, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        await ref.read(shareRepositoryProvider).createRegistrationSettings(
          cloudId: widget.cloudId,
          maxTeams: int.tryParse(maxTeamsController.text) ?? 16,
          playerCountMin: int.tryParse(minPlayersController.text) ?? 3,
          playerCountMax: int.tryParse(maxPlayersController.text) ?? 5,
          showLunch: showLunch,
          lunchOptions: lunchOptions,
        );
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
          );
        }
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editSettings() async {
    if (_settings == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final maxTeamsController = TextEditingController(text: _settings!['max_teams'].toString());
    final minPlayersController = TextEditingController(text: (_settings!['player_count_min'] ?? 3).toString());
    final maxPlayersController = TextEditingController(text: (_settings!['player_count_max'] ?? 5).toString());
    bool showLunch = _settings!['show_lunch_options'] ?? true;
    List<String> lunchOptions = List<String>.from(_settings!['lunch_options'] ?? []);

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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minPlayersController,
                        decoration: const InputDecoration(
                          labelText: 'Min Players / Team',
                          labelStyle: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: maxPlayersController,
                        decoration: const InputDecoration(
                          labelText: 'Max Players / Team',
                          labelStyle: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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
              child: Text(l10n.saveAction.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        setState(() => _isLoading = true);
        await ref.read(shareRepositoryProvider).createRegistrationSettings(
          cloudId: widget.cloudId,
          maxTeams: int.tryParse(maxTeamsController.text) ?? 16,
          playerCountMin: int.tryParse(minPlayersController.text) ?? 3,
          playerCountMax: int.tryParse(maxPlayersController.text) ?? 5,
          showLunch: showLunch,
          lunchOptions: lunchOptions,
        );
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
          );
        }
        if (mounted) setState(() => _isLoading = false);
      }
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

  Future<void> _deleteRegistration(Map<String, dynamic> reg) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    bool? confirmed;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(l10n.deleteRegistration.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Text(l10n.confirmDeleteRegGeneric, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.no.toUpperCase()),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.confirmAction, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        setState(() => _isLoading = true);
        final shareRepo = ref.read(shareRepositoryProvider);
        final teamsRepo = ref.read(teamsRepositoryProvider);
        final tournamentsRepo = ref.read(tournamentsRepositoryProvider);

        // If the registration was confirmed, also remove the team from the tournament
        final teamName = reg['team_name']?.toString().trim().toLowerCase() ?? '';
        final wasConfirmed = reg['status']?.toString().toLowerCase() == 'confirmed' ||
            _confirmedTeamNames.contains(teamName);

        if (wasConfirmed && teamName.isNotEmpty) {
          final allTeams = await teamsRepo.getAllTeams();
          final team = allTeams.where((t) =>
            t.name.trim().toLowerCase() == teamName
          ).firstOrNull;

          if (team != null) {
            await tournamentsRepo.removeTeamFromTournament(widget.tournamentId, team.id);
            // Re-sync cloud
            final tournament = await tournamentsRepo.getTournamentById(widget.tournamentId);
            if (tournament != null && tournament.isPublished) {
              await shareRepo.publishToSupabaseFull(widget.tournamentId);
            }
          }
        }

        // Delete the registration from Supabase
        await shareRepo.deleteRegistration(reg['id']);
        if (mounted) _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
          );
        }
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _closeRegistrations() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(l10n.registrationsClosed.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Text(
          l10n.closeRegistrationsDesc,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel.toUpperCase())),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(l10n.closeNow, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        await ref.read(shareRepositoryProvider).closeRegistrations(widget.cloudId, _registrations.length);
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
          );
        }
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmTeam(Map<String, dynamic> reg) async {
    final l10n = AppLocalizations.of(context)!;
    if (_isConfirming) return;

    try {
      setState(() => _isConfirming = true);
      
      final teamsRepo = ref.read(teamsRepositoryProvider);
      final tournamentsRepo = ref.read(tournamentsRepositoryProvider);
      final shareRepo = ref.read(shareRepositoryProvider);

      final allTeams = await teamsRepo.getAllTeams();
      final existingTeam = allTeams.where((t) => 
        t.name.trim().toLowerCase() == reg['team_name'].toString().trim().toLowerCase()
      ).firstOrNull;

      int teamId;
      if (existingTeam != null) {
        teamId = existingTeam.id;
      } else {
        teamId = await teamsRepo.createTeam(name: reg['team_name']);
      }

      final tournamentTeams = await ref.read(tournamentTeamsProvider(widget.tournamentId).future);
      final alreadyIn = tournamentTeams.any((tt) => tt.team.id == teamId);

      if (alreadyIn) {
        if (mounted) {
          setState(() => _isConfirming = false);
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l10n.teamAlreadyRegistered)));
        }
        return;
      }

      await tournamentsRepo.addTeamToTournament(widget.tournamentId, teamId);
      
      // SYNC WITH CLOUD if tournament is already published
      final tournament = await tournamentsRepo.getTournamentById(widget.tournamentId);
      if (tournament != null && tournament.isPublished) {
        await shareRepo.publishToSupabaseFull(widget.tournamentId);
      }

      if (!mounted) return;
      await shareRepo.updateRegistrationStatus(reg['id'], 'confirmed');

      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l10n.teamAdded(reg['team_name']))));
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isConfirming = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: Text(l10n.manageRegistrations.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_settings != null)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.orangeAccent),
              tooltip: l10n.configureRegistrations,
              onPressed: _editSettings,
            ),
          IconButton(
            icon: const Icon(Icons.copy_all, color: Colors.blueAccent),
            tooltip: l10n.copyLink,
            onPressed: () {
              if (_settings == null || !context.mounted) return;
              final locale = Localizations.localeOf(context).languageCode;
              final registrationId = _settings!['id'];
              final url = 'https://trnmnt.vercel.app/$locale/register/$registrationId';
              
              Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(content: Text(l10n.linkCopied), backgroundColor: Colors.blue),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _settings == null
              ? _buildNoSettingsView()
              : _buildRegistrationsListView(),
    );
  }

  Widget _buildNoSettingsView() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.public, size: 64, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            Text(l10n.registrationsNotActive, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(
              l10n.createPublicPageDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(l10n.enableWebRegistrations.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationsListView() {
    final l10n = AppLocalizations.of(context)!;
    final maxTeams = _settings?['max_teams'] ?? 0;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange.shade800, Colors.orange.shade600]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(l10n.registeredTeams, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                     const SizedBox(height: 4),
                     Text('${_registrations.length} / $maxTeams', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                     const SizedBox(height: 8),
                     if (_settings?['is_active'] == false)
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                         child: Text(l10n.registrationsClosed, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                       )
                     else
                       GestureDetector(
                         onTap: _closeRegistrations,
                         child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                           child: Text(l10n.closeNow, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                         ),
                       ),
                  ],
                ),
              ),
              const Icon(Icons.app_registration, color: Colors.white24, size: 48),
            ],
          ),
        ),
        Expanded(
          child: _registrations.isEmpty
              ? Center(child: Text(l10n.noRegistrationsYet, style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _registrations.length,
                  itemBuilder: (context, index) {
                    final reg = _registrations[index];
                    final regStatus = reg['status']?.toString().toLowerCase() == 'confirmed';
                    final isConfirmed = regStatus || _confirmedTeamNames.contains(reg['team_name'].toString().trim().toLowerCase());
                    final lunchChoices = List<String>.from(reg['lunch_choices'] ?? []);
                    
                    final summary = <String, int>{};
                    for (var choice in lunchChoices) {
                      summary[choice] = (summary[choice] ?? 0) + 1;
                    }
                    final summaryStr = summary.entries.map((e) => '${e.value}x ${e.key}').join(', ');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isConfirmed ? Colors.green.withOpacity(0.3) : Colors.white10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(reg['team_name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
                                      if (isConfirmed) 
                                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.group_outlined, size: 14, color: Colors.orange),
                                      const SizedBox(width: 6),
                                      Text('${reg['player_count']} ${l10n.players}', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (summaryStr.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.restaurant_outlined, size: 14, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Expanded(child: Text(summaryStr, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (reg['phone_number'] != null && reg['phone_number'].toString().isNotEmpty) ...[
                                        const Icon(Icons.phone_outlined, size: 14, color: Colors.blue),
                                        const SizedBox(width: 6),
                                        Text(reg['phone_number'], style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 12),
                                      ],
                                      if (reg['instagram_username'] != null && reg['instagram_username'].toString().isNotEmpty) ...[
                                        const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.pink),
                                        const SizedBox(width: 6),
                                        Text('@${reg['instagram_username']}', style: const TextStyle(color: Colors.pink, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.black26,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _deleteRegistration(reg),
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Spacer(),
                                  if (!isConfirmed)
                                    _isConfirming 
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)),
                                        )
                                      : TextButton.icon(
                                          onPressed: () => _confirmTeam(reg),
                                          icon: const Icon(Icons.add, size: 18),
                                          label: Text(l10n.confirmImport, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                                          style: TextButton.styleFrom(foregroundColor: Colors.orange),
                                        )
                                  else
                                    Text(l10n.teamImported, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
