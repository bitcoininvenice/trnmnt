import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../../core/database/app_database.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../sharing/data/share_repository.dart';
import '../../../sharing/data/sync_repository.dart';
import '../../../tournaments/presentation/widgets/court_picker_sheet.dart';
import '../../domain/madness_logic.dart';
import 'standings_screen.dart';
import '../../../map/data/courts_repository.dart';

class TournamentEditScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const TournamentEditScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentEditScreen> createState() => _TournamentEditScreenState();
}

class _TournamentEditScreenState extends ConsumerState<TournamentEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  DateTime _startDate = DateTime.now();
  List<int> _selectedTeamIds = [];
  String _mode = 'group_only';
  String _scoringSystem = 'win2_loss1';
  
  final _winPointsController = TextEditingController(text: '2');
  final _drawPointsController = TextEditingController(text: '0');
  final _lossPointsController = TextEditingController(text: '1');
  final _timerMinutesController = TextEditingController(text: '10');
  
  Map<int, int> _teamToGroup = {};
  int _groupCount = 1;
  int _qualifiersPerGroup = 2;
  bool _hasPlayIn = false;
  bool _includeConsolationFinals = false;
  int _timerValue = 10;
  bool _isLoading = false;
  bool _isInit = false;
  bool _hasModifiedTeams = false;
  bool _isQueueReversed = false;
  bool _isWebRegistrationEnabled = false;
  DateTime? _endDate;
  int? _venueCourtId;
  String? _selectedCourtName;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _winPointsController.dispose();
    _drawPointsController.dispose();
    _lossPointsController.dispose();
    _timerMinutesController.dispose();
    super.dispose();
  }

  Future<void> _updateTournament() async {
    if (!_formKey.currentState!.validate()) return;
    
    final tournamentAsync = ref.read(tournamentByIdProvider(widget.tournamentId));
    final tournament = tournamentAsync.valueOrNull;
    final hasWebRegistration = tournament?.cloudId != null && tournament!.cloudId!.isNotEmpty;
    if (!hasWebRegistration && _selectedTeamIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectAtLeastTwoTeams), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final syncRepo = ref.read(syncRepositoryProvider);
    final shareRepo = ref.read(shareRepositoryProvider);
    syncRepo.blockSync(); // SHIELD ON: Prevent cloud updates from messing with local save

    try {
      final repo = ref.read(tournamentsRepositoryProvider);
      
      String ticker = tournament?.customTicker ?? "";
      if (_isQueueReversed && !ticker.contains('[REV_Q]')) {
        ticker = '[REV_Q] $ticker'.trim();
      } else if (!_isQueueReversed && ticker.contains('[REV_Q]')) {
        ticker = ticker.replaceAll('[REV_Q]', '').trim();
      }
      
      // If the user modified the teams, we mark the order as MANUAL to override standings
      if (_hasModifiedTeams && !ticker.contains('[MANUAL_Q]')) {
        ticker = '[MANUAL_Q] $ticker'.trim();
      }
      
      await repo.updateTournament(
        id: widget.tournamentId,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        mode: _mode,
        scoringSystem: _scoringSystem,
        winPoints: int.tryParse(_winPointsController.text) ?? 2,
        drawPoints: int.tryParse(_drawPointsController.text) ?? 0,
        lossPoints: int.tryParse(_lossPointsController.text) ?? 1,
        includeConsolationFinals: _includeConsolationFinals,
        timerMinutes: int.tryParse(_timerMinutesController.text) ?? 10,
        startDate: _startDate,
        groupCount: _groupCount,
        qualifiersPerGroup: _qualifiersPerGroup,
        hasPlayIn: _hasPlayIn,
        isWebRegistrationEnabled: _isWebRegistrationEnabled,
        endDate: _endDate,
        venueCourtId: _venueCourtId,
        description: _descriptionController.text.trim(),
        customTicker: ticker.isNotEmpty ? ticker : null,
      );

      await repo.setTournamentTeams(widget.tournamentId, _selectedTeamIds, teamToGroup: _groupCount > 1 ? _teamToGroup : null);
      
      // INVALIDATE: Force refresh of providers to ensure other screens see the new order
      // 3. Clear Madness matches if order was modified manually to avoid "pulling" teams back to old positions
      if (_hasModifiedTeams && (_mode == 'madness' || _mode == 'league_madness')) {
        final matches = await ref.read(tournamentMatchesProvider(widget.tournamentId).future);
        final madnessMatchIds = matches
            .where((m) => m.match.phase == 'madness')
            .map((m) => m.match.id)
            .toList();
        
        if (madnessMatchIds.isNotEmpty) {
          final matchesRepo = ref.read(matchesRepositoryProvider);
          for (final id in madnessMatchIds) {
            await matchesRepo.deleteMatch(id);
          }
        }
      }

      ref.invalidate(tournamentTeamsProvider(widget.tournamentId));
      ref.invalidate(standingsProvider(widget.tournamentId));
      ref.invalidate(tournamentMatchesProvider(widget.tournamentId));
      ref.invalidate(tournamentByIdProvider(widget.tournamentId));
      
      // AUTO-SYNC: If published, push to cloud immediately to reflect new order
      if (tournament?.isPublished == true) {
        shareRepo.publishToSupabase(widget.tournamentId).catchError((_) => null);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      syncRepo.unblockSync(); // SHIELD OFF
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTeamsAsync = ref.watch(teamsProvider);
    final tournamentAsync = ref.watch(tournamentByIdProvider(widget.tournamentId));
    final teamsAsync = ref.watch(tournamentTeamsProvider(widget.tournamentId));
    final matchesAsync = ref.watch(tournamentMatchesProvider(widget.tournamentId));
    final standingsAsync = ref.watch(standingsProvider(widget.tournamentId));

    return tournamentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (tournament) {
        if (tournament == null) return const Scaffold(body: Center(child: Text('Tournament not found')));

        return teamsAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
          data: (teams) {
            return standingsAsync.when(
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
              error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
              data: (standings) {
                final matches = matchesAsync.value ?? [];
            final bool isModeLocked = matches.any((m) => m.match.isCompleted || (m.match.homeScore ?? 0) > 0 || (m.match.awayScore ?? 0) > 0);

            // 1. INITIALIZATION: Only once when the screen opens
            if (!_isInit) {
              _nameController.text = tournament.name;
              _locationController.text = tournament.location;
              _descriptionController.text = tournament.description ?? '';
              _startDate = tournament.startDate ?? DateTime.now();
              _mode = tournament.mode;
              _scoringSystem = tournament.scoringSystem ?? 'standard';
              _winPointsController.text = tournament.winPoints.toString();
              _drawPointsController.text = tournament.drawPoints.toString();
              _lossPointsController.text = tournament.lossPoints.toString();
              _includeConsolationFinals = tournament.includeConsolationFinals;
              _timerMinutesController.text = tournament.timerMinutes.toString();
              _timerValue = tournament.timerMinutes;
              _groupCount = tournament.groupCount;
              _isWebRegistrationEnabled = tournament.isWebRegistrationEnabled;
              _endDate = tournament.endDate;
              _venueCourtId = tournament.venueCourtId;
              _isQueueReversed = tournament.customTicker?.contains('[REV_Q]') ?? false;

              // 2. INITIALIZE TEAM ORDER:
              // We use the EXACT SAME REASONING as MadnessScreen to get the current order
              if (_mode == 'madness' || _mode == 'league_madness') {
                // First get the sorted starting order (from seeds or standings)
                final sortedTeams = MadnessLogic.getSortedTeams(
                  teams: teams,
                  tournament: tournament,
                  standings: standings,
                );

                // Filter only completed madness matches to get the current state
                final madnessMatches = matches.where((m) => m.match.phase == 'madness' && m.match.isCompleted).toList();
                final actualState = MadnessLogic.calculateCurrentState(sortedTeams, madnessMatches);
                
                // The order is: King + Challenger + Remaining Queue
                final List<TournamentTeamWithTeam> currentOrder = [];
                if (actualState.king != null) currentOrder.add(actualState.king!);
                if (actualState.challenger != null) currentOrder.add(actualState.challenger!);
                currentOrder.addAll(actualState.queue);

                _selectedTeamIds = currentOrder.map((e) => e.team.id).toList();
              } else {
                // Otherwise, we use the standard order from the database (sorted by seed)
                _selectedTeamIds = teams.map((e) => e.team.id).toList();
              }
              _teamToGroup = { for (var e in teams) e.team.id : e.tournamentTeam.groupNumber };

              if (_venueCourtId != null) {
                ref.read(courtsRepositoryProvider).getCourtById(_venueCourtId!).then((c) {
                  if (mounted && c != null) setState(() => _selectedCourtName = c.name);
                });
              }
              _isInit = true;
            }

            final isReadOnly = tournament.isReadOnly;

                return Scaffold(
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context)!.edit),
                actions: [
                  if (!_isLoading && !isReadOnly)
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _updateTournament,
                    ),
                ],
              ),
              body: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReadOnly)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(child: Text(AppLocalizations.of(context)!.readOnlyTournament)),
                          ],
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isReadOnly,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.tournamentName,
                        prefixIcon: const Icon(Icons.emoji_events),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? AppLocalizations.of(context)!.enterTournamentName : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      enabled: !isReadOnly,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.tournamentLocation,
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? AppLocalizations.of(context)!.enterTournamentLocation : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCourtPicker(isReadOnly, context),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !isReadOnly,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrizione',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(isReadOnly, context),
                    const SizedBox(height: 16),
                    _buildEndDateField(isReadOnly, context),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.configStep,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildConfigFields(isReadOnly, isModeLocked, tournament),

                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.participatingTeams,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildTeamsSelection(allTeamsAsync, isReadOnly),
                    const SizedBox(height: 80), // Spacer for fab if needed
                  ],
                ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

  Widget _buildDateField(bool isReadOnly, BuildContext context) {
    return InkWell(
      onTap: isReadOnly ? null : () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_startDate),
          );
          if (time != null) {
            setState(() => _startDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              time.hour,
              time.minute,
            ));
          } else {
            setState(() => _startDate = picked);
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.tournamentDate,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          "${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year} ${_startDate.hour.toString().padLeft(2, '0')}:${_startDate.minute.toString().padLeft(2, '0')}",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isReadOnly ? Colors.grey : null,
          ),
        ),
      ),
    );
  }

  Widget _buildEndDateField(bool isReadOnly, BuildContext context) {
    final timeStr = _endDate == null 
        ? "NON DEFINITO" 
        : "${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year} ${_endDate!.hour.toString().padLeft(2, '0')}:${_endDate!.minute.toString().padLeft(2, '0')}";

    return InkWell(
      onTap: isReadOnly ? null : () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _endDate ?? _startDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_endDate ?? _startDate),
          );
          if (time != null) {
            final newEnd = DateTime(
              picked.year,
              picked.month,
              picked.day,
              time.hour,
              time.minute,
            );

            if (newEnd.isBefore(_startDate)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('L\'orario di fine deve essere successivo all\'inizio'), backgroundColor: Colors.red),
                );
              }
              return;
            }

            setState(() => _endDate = newEnd);
          } else {
            setState(() => _endDate = picked);
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.tournamentEndDate,
          prefixIcon: const Icon(Icons.access_time),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          timeStr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isReadOnly ? Colors.grey : (_endDate == null ? Colors.white24 : null),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigFields(bool isReadOnly, bool isModeLocked, Tournament tournament) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(AppLocalizations.of(context)!.tournamentMode, style: Theme.of(context).textTheme.titleSmall)),
            if (isModeLocked && !isReadOnly)
              const Tooltip(
                message: 'Modalità bloccata (partite iniziate)',
                child: Icon(Icons.lock_outline, size: 16, color: Colors.orange),
              ),
          ],
        ),
        if (isModeLocked && !isReadOnly)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              AppLocalizations.of(context)!.modeLockedWarning,
              style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 8),
        _buildModeSelector(isReadOnly || isModeLocked),
        const SizedBox(height: 24),
        
        Text(AppLocalizations.of(context)!.scoringSystem, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildScoringSelector(isReadOnly),
        
        if (_scoringSystem == 'custom') ...[
          const SizedBox(height: 16),
          _buildCustomScoringInputs(isReadOnly),
        ],
        
        const SizedBox(height: 24),
        if (_mode != 'group_only') ...[
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.consolationFinals),
            value: _includeConsolationFinals,
            onChanged: isReadOnly ? null : (value) => setState(() => _includeConsolationFinals = value),
          ),
        ],
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.matchTimer(_timerValue), style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: _timerValue.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          label: '$_timerValue min',
          onChanged: isReadOnly ? null : (value) {
            setState(() {
              _timerValue = value.round();
              _timerMinutesController.text = _timerValue.toString();
            });
          },
        ),
        if (tournament.isPublished) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: SwitchListTile(
              activeColor: Colors.blue,
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context)!.openWebRegistrations, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blueAccent)),
              subtitle: Text(AppLocalizations.of(context)!.openWebRegistrationsDesc),
              value: _isWebRegistrationEnabled,
              onChanged: isReadOnly ? null : (val) => setState(() => _isWebRegistrationEnabled = val),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildModeSelector(bool isDisabled) {
    return Column(
      children: [
        _buildModeOption('group_only', AppLocalizations.of(context)!.groupOnly, AppLocalizations.of(context)!.groupOnlySubtitle, Icons.table_chart, isDisabled),
        _buildModeOption('elimination_only', AppLocalizations.of(context)!.eliminationOnly, AppLocalizations.of(context)!.eliminationOnlySubtitle, Icons.account_tree, isDisabled),
        _buildModeOption('group_and_elimination', AppLocalizations.of(context)!.groupAndElimination, AppLocalizations.of(context)!.groupAndEliminationSubtitle, Icons.sports_basketball, isDisabled),
        _buildModeOption('madness', AppLocalizations.of(context)!.madness, AppLocalizations.of(context)!.madnessSubtitle, Icons.flash_on, isDisabled),
        _buildModeOption('league_madness', AppLocalizations.of(context)!.leagueMadness, AppLocalizations.of(context)!.leagueMadnessSubtitle, Icons.electric_bolt, isDisabled),
      ],
    );
  }

  Widget _buildModeOption(String value, String title, String subtitle, IconData icon, bool isDisabled) {
    final isSelected = _mode == value;
    return Opacity(
      opacity: (isDisabled && !isSelected) ? 0.5 : 1.0,
      child: Card(
        color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : null,
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : (isDisabled ? Colors.grey : null)),
          title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
          subtitle: Text(subtitle),
          trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
          onTap: isDisabled ? null : () => setState(() => _mode = value),
        ),
      ),
    );
  }

  Widget _buildScoringSelector(bool isReadOnly) {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.classicBasketball),
          subtitle: const Text('V=2, S=1'),
          value: 'win2_loss1',
          groupValue: _scoringSystem,
          onChanged: isReadOnly ? null : (value) => setState(() {
            _scoringSystem = value!;
            _winPointsController.text = '2';
            _drawPointsController.text = '0';
            _lossPointsController.text = '1';
          }),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.standardFootball),
          subtitle: const Text('V=3, P=1, S=0'),
          value: 'win3_draw1_loss0',
          groupValue: _scoringSystem,
          onChanged: isReadOnly ? null : (value) => setState(() {
            _scoringSystem = value!;
            _winPointsController.text = '3';
            _drawPointsController.text = '1';
            _lossPointsController.text = '0';
          }),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.custom),
          subtitle: Text(AppLocalizations.of(context)!.setYourScores),
          value: 'custom',
          groupValue: _scoringSystem,
          onChanged: isReadOnly ? null : (value) => setState(() => _scoringSystem = value!),
        ),
      ],
    );
  }

  Widget _buildCustomScoringInputs(bool isReadOnly) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _winPointsController,
            enabled: !isReadOnly,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.win),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _drawPointsController,
            enabled: !isReadOnly,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.draw),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _lossPointsController,
            enabled: !isReadOnly,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.loss),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsSelection(AsyncValue<List<Team>> allTeamsAsync, bool isReadOnly) {
    return allTeamsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
      data: (teams) {
        final selectedTeams = _selectedTeamIds.map((id) => teams.firstWhere((t) => t.id == id)).toList();

        final searchText = _searchController.text.toLowerCase();
        final filteredTeams = teams.where((t) => t.name.toLowerCase().contains(searchText)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((_mode == 'madness' || _mode == 'league_madness') && _selectedTeamIds.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${AppLocalizations.of(context)!.teamOrder} (${AppLocalizations.of(context)!.dragToReorder})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isReadOnly)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedTeamIds = _selectedTeamIds.reversed.toList();
                          _hasModifiedTeams = true;
                          if (_mode == 'league_madness') {
                            _isQueueReversed = !_isQueueReversed;
                          }
                        });
                      },
                      icon: const Icon(Icons.swap_vert, size: 16),
                      label: Text(AppLocalizations.of(context)!.invertAction, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: Colors.orange),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedTeams.length,
                  itemBuilder: (context, index) {
                    final team = selectedTeams[index];
                    return ListTile(
                      key: ValueKey('ordered_edit_${team.id}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: isReadOnly ? null : const Icon(Icons.drag_handle),
                    );
                  },
                  onReorder: isReadOnly ? (o, n) {} : (oldIndex, newIndex) {
                    setState(() {
                      _hasModifiedTeams = true;
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _selectedTeamIds.removeAt(oldIndex);
                      _selectedTeamIds.insert(newIndex, item);
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (!isReadOnly) ...[
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.searchTeam,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchController.clear())) 
                      : null,
                ),
                onChanged: (v) => setState(() {}),
              ),
              const SizedBox(height: 12),
            ],
            ...filteredTeams
              .where((t) => t.name.toLowerCase().contains(searchText))
              .map((team) {
                final isSelected = _selectedTeamIds.contains(team.id);
                if (isReadOnly && !isSelected) return const SizedBox.shrink();

                return Column(
                  children: [
                    CheckboxListTile(
                      title: Text(team.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
                      value: isSelected,
                      enabled: !isReadOnly,
                      onChanged: (val) {
                        setState(() {
                          _hasModifiedTeams = true;
                          if (val == true) {
                            if (!_selectedTeamIds.contains(team.id)) {
                              _selectedTeamIds.add(team.id);
                              _teamToGroup[team.id] = 1;
                            }
                          } else {
                            _selectedTeamIds.remove(team.id);
                            _teamToGroup.remove(team.id);
                          }
                        });
                      },
                    ),
                    if (isSelected && _groupCount > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
                        child: Row(
                          children: [
                            const Text('GIRONE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                            const SizedBox(width: 12),
                            ...List.generate(_groupCount, (i) {
                              final groupNum = i + 1;
                              final isCurrent = _teamToGroup[team.id] == groupNum;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(String.fromCharCode(65 + i), style: TextStyle(fontSize: 10, color: isCurrent ? Colors.white : Colors.orange)),
                                  selected: isCurrent,
                                  selectedColor: Colors.orange,
                                  onSelected: isReadOnly ? null : (selected) {
                                    if (selected) setState(() => _teamToGroup[team.id] = groupNum);
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                  ],
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildCourtPicker(bool isReadOnly, BuildContext context) {
    return InkWell(
      onTap: isReadOnly ? null : () async {
        final selection = await showModalBottomSheet<CourtSelection>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const FractionallySizedBox(
            heightFactor: 0.8,
            child: CourtPickerSheet(),
          ),
        );
        if (selection != null) {
          setState(() {
            _venueCourtId = selection.localId;
            _selectedCourtName = selection.name;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.radar_court_link,
                    style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedCourtName != null 
                      ? AppLocalizations.of(context)!.courtSelected(_selectedCourtName!)
                      : '${AppLocalizations.of(context)!.selectCourt} (${AppLocalizations.of(context)!.optional})',
                    style: TextStyle(
                      color: _selectedCourtName != null ? Colors.white : Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedCourtName != null && !isReadOnly)
              IconButton(
                icon: const Icon(Icons.clear, size: 18, color: Colors.white54),
                onPressed: () => setState(() {
                  _venueCourtId = null;
                  _selectedCourtName = null;
                }),
              ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
