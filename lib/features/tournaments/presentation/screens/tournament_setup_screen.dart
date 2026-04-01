import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/tournaments_repository.dart';
import '../../../teams/data/teams_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../map/data/courts_repository.dart';
import '../../../../core/services/geocoding_service.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TournamentSetupScreen extends ConsumerStatefulWidget {
  const TournamentSetupScreen({super.key});

  @override
  ConsumerState<TournamentSetupScreen> createState() => _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends ConsumerState<TournamentSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _searchController = TextEditingController(); 
  
  DateTime _startDate = DateTime.now();
  String _mode = 'group_only';
  String _scoringSystem = 'win2_loss1';
  int _winPoints = 2;
  int _drawPoints = 0;
  int _lossPoints = 1;
  bool _includeConsolationFinals = false;
  int _timerMinutes = 10;
  
  final Set<int> _selectedTeamIds = {};
  int _currentStep = 0;
  bool _isLoading = false;

  // Realtime search location
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isSearchingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _searchController.dispose(); // Dispose
    super.dispose();
  }

  Future<void> _createTournament() async {
    if (_selectedTeamIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectAtLeastTwoTeams), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(tournamentsRepositoryProvider);
      
      final tournamentId = await repo.createTournament(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        mode: _mode,
        scoringSystem: _scoringSystem,
        winPoints: _winPoints,
        drawPoints: _drawPoints,
        lossPoints: _lossPoints,
        includeConsolationFinals: _includeConsolationFinals,
        timerMinutes: _timerMinutes,
        startDate: _startDate,
      );

      await repo.setTournamentTeams(tournamentId, _selectedTeamIds.toList());

      if (mounted) {
        context.go('/tournaments/$tournamentId');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newTournament),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/tournaments'),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_formKey.currentState!.validate()) {
              setState(() => _currentStep = 1);
            }
          } else if (_currentStep == 1) {
            setState(() => _currentStep = 2);
          } else if (_currentStep == 2) {
            _createTournament();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.go('/tournaments');
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : details.onStepContinue,
                  child: _isLoading && _currentStep == 2
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_currentStep == 2 ? AppLocalizations.of(context)!.createTournament : AppLocalizations.of(context)!.continueAction),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.backAction),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text(AppLocalizations.of(context)!.infoStep),
            subtitle: Text(AppLocalizations.of(context)!.infoSubtitle),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildInfoStep(),
          ),
          Step(
            title: Text(AppLocalizations.of(context)!.configStep),
            subtitle: Text(AppLocalizations.of(context)!.configSubtitle),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildConfigStep(),
          ),
          Step(
            title: Text(AppLocalizations.of(context)!.teamsStep),
            subtitle: Text(AppLocalizations.of(context)!.teamsSelected(_selectedTeamIds.length)),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: _buildTeamsStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.tournamentName,
              hintText: 'Es. Torneo Estivo 2024',
              prefixIcon: const Icon(Icons.emoji_events),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.enterTournamentName;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildEnhancedLocationField(),
          const SizedBox(height: 24),
          _buildDateField(),
        ],
      ),
    );
  }

  Widget _buildEnhancedLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.tournamentLocation,
            hintText: 'Cerca indirizzo o campetto...',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: IconButton(
              icon: const Icon(Icons.map_outlined, color: Colors.orange),
              tooltip: 'Scegli dai campetti salvati',
              onPressed: _showCourtsPicker,
            ),
          ),
          onChanged: _onLocationChanged,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizations.of(context)!.enterTournamentLocation;
            }
            return null;
          },
        ),
        if (_isSearchingLocation)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, size: 18, color: Colors.blue),
                  title: Text(suggestion.displayName, style: const TextStyle(fontSize: 13)),
                  onTap: () {
                    setState(() {
                      _locationController.text = suggestion.displayName;
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _onLocationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() => _suggestions = []);
        return;
      }
      
      setState(() => _isSearchingLocation = true);
      try {
        final results = await ref.read(geocodingServiceProvider).searchAddress(query);
        setState(() => _suggestions = results);
      } finally {
        setState(() => _isSearchingLocation = false);
      }
    });
  }

  void _showCourtsPicker() {
    final courtsAsync = ref.read(courtsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.basketball, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Text('SCEGLI UN CAMPETTO', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: courtsAsync.when(
                data: (courts) {
                  if (courts.isEmpty) {
                    return Center(child: Text('Nessun campetto salvato sulla mappa.'));
                  }
                  return ListView.builder(
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.sports_basketball, size: 16, color: Colors.white)),
                        title: Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Valutazione: ${"⭐" * court.stars}', style: const TextStyle(fontSize: 12)),
                        onTap: () {
                          setState(() => _locationController.text = court.name);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Errore nel caricamento campetti')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final dateStr = "${_startDate.day}/${_startDate.month}/${_startDate.year}";
    return InkWell(
      onTap: () async {
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
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildConfigStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.tournamentMode, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildModeSelector(),
        const SizedBox(height: 24),
        
        Text(AppLocalizations.of(context)!.scoringSystem, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildScoringSelector(),
        
        if (_scoringSystem == 'custom') ...[
          const SizedBox(height: 16),
          _buildCustomScoringInputs(),
        ],
        
        const SizedBox(height: 24),
        if (_mode != 'group_only') ...[
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.consolationFinals),
            subtitle: Text(AppLocalizations.of(context)!.consolationFinalsSubtitle),
            value: _includeConsolationFinals,
            onChanged: (value) => setState(() => _includeConsolationFinals = value),
          ),
        ],
        
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.matchTimer(_timerMinutes), style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: _timerMinutes.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          label: '${_timerMinutes} min',
          onChanged: (value) => setState(() => _timerMinutes = value.round()),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Column(
      children: [
        _buildModeOption('group_only', AppLocalizations.of(context)!.groupOnly, AppLocalizations.of(context)!.groupOnlySubtitle, Icons.table_chart),
        _buildModeOption('elimination_only', AppLocalizations.of(context)!.eliminationOnly, AppLocalizations.of(context)!.eliminationOnlySubtitle, Icons.account_tree),
        _buildModeOption('group_and_elimination', AppLocalizations.of(context)!.groupAndElimination, AppLocalizations.of(context)!.groupAndEliminationSubtitle, Icons.sports_basketball),
        _buildModeOption('madness', AppLocalizations.of(context)!.madness, AppLocalizations.of(context)!.madnessSubtitle, Icons.flash_on),
      ],
    );
  }

  Widget _buildModeOption(String value, String title, String subtitle, IconData icon) {
    final isSelected = _mode == value;
    return Card(
      color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : null,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null)),
        subtitle: Text(subtitle),
        trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
        onTap: () => setState(() => _mode = value),
      ),
    );
  }

  Widget _buildScoringSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.classicBasketball),
          subtitle: const Text('V=2, S=1'),
          value: 'win2_loss1',
          groupValue: _scoringSystem,
          onChanged: (value) => setState(() {
            _scoringSystem = value!;
            _winPoints = 2;
            _drawPoints = 0;
            _lossPoints = 1;
          }),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.standardFootball),
          subtitle: const Text('V=3, P=1, S=0'),
          value: 'win3_draw1_loss0',
          groupValue: _scoringSystem,
          onChanged: (value) => setState(() {
            _scoringSystem = value!;
            _winPoints = 3;
            _drawPoints = 1;
            _lossPoints = 0;
          }),
        ),
        RadioListTile<String>(
          title: Text(AppLocalizations.of(context)!.custom),
          subtitle: Text(AppLocalizations.of(context)!.setYourScores),
          value: 'custom',
          groupValue: _scoringSystem,
          onChanged: (value) => setState(() => _scoringSystem = value!),
        ),
      ],
    );
  }

  Widget _buildCustomScoringInputs() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _winPoints.toString(),
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.win),
            keyboardType: TextInputType.number,
            onChanged: (value) => _winPoints = int.tryParse(value) ?? _winPoints,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: _drawPoints.toString(),
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.draw),
            keyboardType: TextInputType.number,
            onChanged: (value) => _drawPoints = int.tryParse(value) ?? _drawPoints,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: _lossPoints.toString(),
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.loss),
            keyboardType: TextInputType.number,
            onChanged: (value) => _lossPoints = int.tryParse(value) ?? _lossPoints,
          ),
        ),
      ],
    );
  }



  // ... (existing code omitted)

  Widget _buildTeamsStep() {
    final teamsAsync = ref.watch(teamsProvider);

    return teamsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('${AppLocalizations.of(context)!.error}: $error'),
      data: (teams) {
        if (teams.isEmpty) {
          return Column(
            children: [
              Text(AppLocalizations.of(context)!.noTeamsInDatabase),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/teams/new'),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createTeam),
              ),
            ],
          );
        }

        // Filter teams based on search text
        final searchText = _searchController.text.toLowerCase();
        final filteredTeams = teams.where((team) => 
          team.name.toLowerCase().contains(searchText)
        ).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.selectParticipatingTeams,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchTeam,
                hintText: 'Nome squadra...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchController.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            if (_selectedTeamIds.length % 2 != 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.oddTeamsBye,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Select All / Deselect All (optional but good ux)
            if (searchText.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                         if (_selectedTeamIds.containsAll(filteredTeams.map((t) => t.id))) {
                           _selectedTeamIds.clear();
                         } else {
                           _selectedTeamIds.addAll(filteredTeams.map((t) => t.id));
                         }
                      });
                    }, 
                    child: Text(_selectedTeamIds.containsAll(filteredTeams.map((t) => t.id)) 
                      ? AppLocalizations.of(context)!.deselectAll 
                      : AppLocalizations.of(context)!.selectAll),
                  ),
                ],
              ),

            if (filteredTeams.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(AppLocalizations.of(context)!.noTeamsFound)),
              )
            else
              ...filteredTeams.map((team) {
                final isSelected = _selectedTeamIds.contains(team.id);
                return CheckboxListTile(
                  title: Text(team.name),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedTeamIds.add(team.id);
                      } else {
                        _selectedTeamIds.remove(team.id);
                      }
                    });
                  },
                );
              }),
          ],
        );
      },
    );
  }
}
