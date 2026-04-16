import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../../core/database/app_database.dart';
import '../../data/tournaments_repository.dart';
import '../../data/matches_repository.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../sharing/data/share_repository.dart';

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
  bool _includeConsolationFinals = false;
  int _timerValue = 10;
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _searchController.dispose();
    _winPointsController.dispose();
    _drawPointsController.dispose();
    _lossPointsController.dispose();
    _timerMinutesController.dispose();
    super.dispose();
  }

  Future<void> _updateTournament() async {
    if (!_formKey.currentState!.validate()) return;
    // Skip team validation for tournaments using web registration (teams come via web form)
    final tournament = ref.read(tournamentByIdProvider(widget.tournamentId)).valueOrNull;
    final hasWebRegistration = tournament?.cloudId != null && tournament!.cloudId!.isNotEmpty;
    if (!hasWebRegistration && _selectedTeamIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectAtLeastTwoTeams), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(tournamentsRepositoryProvider);
      
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
      );

      await repo.setTournamentTeams(widget.tournamentId, _selectedTeamIds, teamToGroup: _groupCount > 1 ? _teamToGroup : null);
      
      // Auto-sync after edit if published
      final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
      if (tournament != null && tournament.isPublished) {
        ref.read(shareRepositoryProvider).publishToSupabase(widget.tournamentId).catchError((_) => null);
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

    return tournamentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (tournament) {
        if (tournament == null) return const Scaffold(body: Center(child: Text('Tournament not found')));

        return teamsAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
          data: (teams) {
            final matches = matchesAsync.value ?? [];
            final bool isModeLocked = matches.any((m) => m.match.isCompleted || (m.match.homeScore ?? 0) > 0 || (m.match.awayScore ?? 0) > 0);

            if (!_isInit) {
              _nameController.text = tournament.name;
              _locationController.text = tournament.location;
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
              _selectedTeamIds = teams.map((e) => e.team.id).toList();
              _teamToGroup = { for (var e in teams) e.team.id : e.tournamentTeam.groupNumber };
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
                    _buildDateField(isReadOnly),
                    
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.configStep,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildConfigFields(isReadOnly, isModeLocked),

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
  }

  Widget _buildDateField(bool isReadOnly) {
    final dateStr = "${_startDate.day}/${_startDate.month}/${_startDate.year}";
    return InkWell(
      onTap: isReadOnly ? null : () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _startDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.tournamentDate,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          dateStr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isReadOnly ? Colors.grey : null,
          ),
        ),
      ),
    );
  }

  Widget _buildConfigFields(bool isReadOnly, bool isModeLocked) {
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
            if (_mode == 'madness' && _selectedTeamIds.isNotEmpty) ...[
              Text(
                '${AppLocalizations.of(context)!.teamOrder} (${AppLocalizations.of(context)!.dragToReorder})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
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
}
