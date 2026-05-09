import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/features/sharing/data/share_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';
import 'package:trnmnt/features/teams/data/teams_repository.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/features/community/data/selected_community_provider.dart';
import 'package:trnmnt/features/map/data/courts_repository.dart';
import 'package:trnmnt/core/services/geocoding_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:trnmnt/features/map/data/osm_repository.dart';
import 'package:trnmnt/core/providers/osm_settings_provider.dart';
import 'package:trnmnt/features/tournaments/presentation/widgets/court_picker_sheet.dart';

class TournamentSetupScreen extends ConsumerStatefulWidget {
  const TournamentSetupScreen({super.key});

  @override
  ConsumerState<TournamentSetupScreen> createState() => _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends ConsumerState<TournamentSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController(); 
  
  DateTime _startDate = DateTime.now();
  String _mode = 'group_only';
  String _scoringSystem = 'win2_loss1';
  int _winPoints = 2;
  int _drawPoints = 0;
  int _lossPoints = 1;
  bool _includeConsolationFinals = false;
  int _timerMinutes = 10;
  int _courtCount = 1;
  int _lunchDuration = 0;
  DateTime? _endDate;
  
  List<int> _selectedTeamIds = [];
  int _currentStep = 0;
  bool _isLoading = false;

  // Multi-group state
  bool _isMultiGroup = false;
  int _groupCount = 2;
  int _qualifiersPerGroup = 2;
  bool _hasPlayIn = false;
  Map<int, int> _teamToGroup = {}; // teamId -> groupNumber (1-based)
  List<String> _groupNames = [];

  // Online Registration state
  bool _enableOpenRegistrations = false;
  int _maxTeams = 16;
  bool _showLunch = true;
  List<String> _lunchOptions = ['Pranzo al Sacco', 'Chiosco Ambulante'];

  // Realtime search location
  List<LocationSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isSearchingLocation = false;
  List<OsmCourt> _nearbyOsmCourts = [];
  bool _isSearchingOsm = false;
  String? _lastOsmError;
  int? _selectedVenueCourtId; // Official DB association

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _searchController.dispose(); // Dispose
    super.dispose();
  }

  Future<void> _createTournament() async {
    if (!_enableOpenRegistrations && _selectedTeamIds.length < 2) {
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
        groupCount: _isMultiGroup ? _groupCount : 1,
        qualifiersPerGroup: _isMultiGroup ? _qualifiersPerGroup : 2,
        hasPlayIn: _isMultiGroup ? _hasPlayIn : false,
        groupNames: _isMultiGroup ? jsonEncode(_groupNames) : null,
        communityId: ref.read(selectedCommunityIdProvider),
        isWebRegistrationEnabled: _enableOpenRegistrations,
        courtCount: _courtCount,
        lunchDuration: _lunchDuration,
        endDate: _endDate,
        venueCourtId: _selectedVenueCourtId,
        description: _descriptionController.text.trim(),
      );

      await repo.setTournamentTeams(tournamentId, _selectedTeamIds, teamToGroup: _isMultiGroup ? _teamToGroup : null);

      if (_enableOpenRegistrations) {
        final shareRepo = ref.read(shareRepositoryProvider);
        // Publish to cloud to get ID, but DON'T create registration settings yet
        await shareRepo.publishToSupabaseFull(tournamentId);
      }

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

  DateTime _calculateSuggestedEnd() {
    const int matchInterval = 2;
    final int slotDuration = _timerMinutes + matchInterval;
    
    int groupMatchesCount = 0;
    final int effectiveGroupCount = _isMultiGroup ? _groupCount : 1;
    final int teamsPerGroup = (_selectedTeamIds.length / effectiveGroupCount).ceil();
    if (teamsPerGroup > 1) {
      groupMatchesCount = ((teamsPerGroup * (teamsPerGroup - 1)) ~/ 2) * effectiveGroupCount;
    }

    int playoffTime = 0;
    if (_mode == 'group_and_elimination' || _mode == 'elimination_only') {
      final int qualifiers = _mode == 'elimination_only' 
          ? _selectedTeamIds.length 
          : (effectiveGroupCount * _qualifiersPerGroup);
      
      if (qualifiers > 1) {
        final int roundsCount = (math.log(qualifiers.toDouble()) / math.log(2)).ceil();
        playoffTime = (roundsCount * (qualifiers ~/ 2) * slotDuration);
      }
    } else if (_mode == 'madness' || _mode == 'league_madness') {
      const int madnessBaseMinutes = 120;
      const int qualifiers = 2; // Only 2 finalists for Madness mode
      int totalPlayoffSlots = 0;
      int currentTeams = qualifiers;
      while (currentTeams > 1) {
        final int matchesInRound = currentTeams ~/ 2;
        totalPlayoffSlots += (matchesInRound / _courtCount).ceil();
        currentTeams = matchesInRound;
      }
      playoffTime = (totalPlayoffSlots * slotDuration) + madnessBaseMinutes;
      if (_mode == 'madness') {
        groupMatchesCount = 0;
      }
    }

    final int groupSlots = (groupMatchesCount / _courtCount).ceil();
    final int groupTime = groupSlots * slotDuration;
    final int totalMinutes = groupTime + _lunchDuration + playoffTime;

    final DateTime estimatedEnd = _startDate.add(Duration(minutes: totalMinutes));
    
    // Round UP to next 15/30/45/00
    int minutes = estimatedEnd.minute;
    int remainder = minutes % 15;
    if (remainder == 0) return estimatedEnd.subtract(Duration(seconds: estimatedEnd.second));
    return estimatedEnd.add(Duration(minutes: 15 - remainder)).subtract(Duration(seconds: estimatedEnd.second, milliseconds: estimatedEnd.millisecond));
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
      body: Stack(
        children: [
          Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 0) {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep = 1);
                }
              } else if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
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
                      onPressed: details.onStepContinue,
                      child: Text(_currentStep == 3 ? AppLocalizations.of(context)!.createTournament : AppLocalizations.of(context)!.continueAction),
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
                title: Text(_enableOpenRegistrations 
                    ? AppLocalizations.of(context)!.selectTeamsOptional 
                    : AppLocalizations.of(context)!.selectParticipatingTeams),
                subtitle: Text(AppLocalizations.of(context)!.teamsSelected(_selectedTeamIds.length)),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                content: _buildTeamsStep(),
              ),
              Step(
                title: Text(_isMultiGroup ? AppLocalizations.of(context)!.editGroups : AppLocalizations.of(context)!.finalSummary),
                subtitle: Text(_isMultiGroup ? AppLocalizations.of(context)!.distributeTeams : AppLocalizations.of(context)!.verifyAndCreate),
                isActive: _currentStep >= 3,
                state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                content: _isMultiGroup ? _buildGroupsStep() : _buildSummaryStep(),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    final l10n = AppLocalizations.of(context)!;
    String modeLabel = _mode;
    if (_mode == 'madness') modeLabel = l10n.madness;
    if (_mode == 'group_only') modeLabel = l10n.groupOnly;
    if (_mode == 'elimination_only') modeLabel = l10n.eliminationOnly;
    if (_mode == 'group_and_elimination') modeLabel = l10n.groupAndElimination;
    if (_mode == 'league_madness') modeLabel = l10n.leagueMadness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.almostReady, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.orange)),
        const SizedBox(height: 8),
        Text(l10n.readyToCreateDesc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        _buildInfoCard(Icons.emoji_events, l10n.tournamentMode, modeLabel.toUpperCase()),
        _buildInfoCard(Icons.public, l10n.onlineRegistrations, _enableOpenRegistrations ? l10n.active : l10n.inactive),
        if (!_enableOpenRegistrations)
          _buildInfoCard(Icons.group, l10n.teams, l10n.teamsSelected(_selectedTeamIds.length)),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white24),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGroupsStep() {
    final teamsAsync = ref.watch(teamsProvider);
    return teamsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error'),
      data: (teams) {
        final selectedTeams = _selectedTeamIds.map((id) => teams.firstWhere((t) => t.id == id)).toList();
        
        return Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.shuffle),
              label: Text(AppLocalizations.of(context)!.randomDistribution),
              onPressed: () {
                setState(() {
                  final shuffled = [..._selectedTeamIds]..shuffle();
                  for (var i = 0; i < shuffled.length; i++) {
                    _teamToGroup[shuffled[i]] = (i % _groupCount) + 1;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            ...List.generate(_groupCount, (groupIndex) {
              final groupNumber = groupIndex + 1;
              final teamsInGroup = selectedTeams.where((t) => _teamToGroup[t.id] == groupNumber).toList();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    title: TextFormField(
                        initialValue: groupIndex < _groupNames.length ? _groupNames[groupIndex] : '${AppLocalizations.of(context)!.groupPhase} ${String.fromCharCode(65 + groupIndex)}',
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.groupNameHint,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        onChanged: (val) {
                          if (groupIndex < _groupNames.length) {
                             _groupNames[groupIndex] = val;
                          }
                        },
                      ),
                      trailing: Text('${teamsInGroup.length} teams', style: const TextStyle(fontSize: 10)),
                    ),
                    ...selectedTeams.map((team) => RadioListTile<int>(
                      title: Text(team.name, style: const TextStyle(fontSize: 13)),
                      value: groupNumber,
                      groupValue: _teamToGroup[team.id],
                      onChanged: (val) => setState(() => _teamToGroup[team.id] = val!),
                      dense: true,
                    )),
                  ],
                ),
              );
            }),
          ],
        );
      }
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
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.descLabel,
              hintText: 'Inserisci dettagli sul torneo...',
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),
          _buildEnhancedLocationField(),
          const SizedBox(height: 24),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildEndDatePicker(),
        ],
      ),
    );
  }

  Widget _buildEnhancedLocationField() {
    final osmEnabled = ref.watch(osmSettingsProvider);
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
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, size: 18, color: Colors.blue),
                  title: Text(suggestion.displayName, style: const TextStyle(fontSize: 13)),
                  onTap: () async {
                    setState(() {
                      _locationController.text = suggestion.displayName;
                      _suggestions = [];
                    });

                    if (osmEnabled) {
                      setState(() {
                        _isSearchingOsm = true;
                        _nearbyOsmCourts = [];
                      });

                      try {
                        final osmRepo = ref.read(osmRepositoryProvider);
                        final courts = await osmRepo.fetchNearbyCourts(suggestion.lat, suggestion.lon, radius: 10000);
                        if (mounted) setState(() => _nearbyOsmCourts = courts);
                      } catch (e) {
                        _lastOsmError = e.toString();
                      } finally {
                        if (mounted) setState(() => _isSearchingOsm = false);
                      }
                    }
                  },
                );
              },
            ),
          ),
        if (osmEnabled && _isSearchingOsm)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                const LinearProgressIndicator(minHeight: 2, color: Colors.blue),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context)!.searchingOsmNearby, 
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
        if (osmEnabled && !_isSearchingOsm && _nearbyOsmCourts.isEmpty && _locationController.text.length > 5 && _suggestions.isEmpty)
           Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(AppLocalizations.of(context)!.noOsmCourtsFound, 
              style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        if (osmEnabled && _nearbyOsmCourts.isNotEmpty && _suggestions.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(AppLocalizations.of(context)!.osmResultsTitle, 
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold, 
                          color: Colors.blue,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 14),
                      onPressed: () => setState(() => _nearbyOsmCourts = []),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _nearbyOsmCourts.length,
                    itemBuilder: (context, index) {
                      final court = _nearbyOsmCourts[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        leading: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.sports_basketball, size: 12, color: Colors.white),
                        ),
                        title: Text(court.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: Text(court.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        onTap: () {
                          setState(() {
                            _locationController.text = court.name;
                            _nearbyOsmCourts = [];
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _onLocationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 3) {
        setState(() {
          _suggestions = [];
        });
        return;
      }
      
      setState(() => _isSearchingLocation = true);
      try {
        final results = await ref.read(geocodingServiceProvider).searchAddress(query);
        if (mounted) setState(() => _suggestions = results);
      } finally {
        if (mounted) setState(() => _isSearchingLocation = false);
      }
    });
  }

  void _showCourtsPicker() async {
    final selection = await showModalBottomSheet<CourtSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FractionallySizedBox(
        heightFactor: 0.8,
        child: CourtPickerSheet(),
      ),
    );

    if (selection != null && mounted) {
      setState(() {
        _locationController.text = selection.name;
        _selectedVenueCourtId = selection.localId;
        _suggestions = [];
        _nearbyOsmCourts = [];
      });
    }
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
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
        
        if (_mode != 'group_only' && _mode != 'madness' && _mode != 'league_madness') ...[
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.consolationFinals),
            subtitle: Text(AppLocalizations.of(context)!.consolationFinalsSubtitle),
            contentPadding: EdgeInsets.zero,
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
          activeColor: Colors.orange,
          divisions: 19,
          label: '${_timerMinutes} min',
          onChanged: (value) => setState(() => _timerMinutes = value.round()),
        ),
        
        const SizedBox(height: 16),
        // _buildEndDatePicker(), // MOVED TO INFO STEP
        
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NUMERO CANESTRI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _courtCount,
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
              items: [1, 2, 3, 4, 6, 8].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
              onChanged: (val) => setState(() => _courtCount = val!),
            ),
          ],
        ),

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
            value: _enableOpenRegistrations,
            onChanged: (val) => setState(() => _enableOpenRegistrations = val),
          ),
        ),

        if (_mode == 'group_only' || _mode == 'group_and_elimination' || _mode == 'league_madness') ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.multiGroup, 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Switch(
                      activeColor: Colors.orange,
                      value: _isMultiGroup,
                      onChanged: (val) => setState(() {
                        _isMultiGroup = val;
                        if (!val && _currentStep == 3) {
                          _currentStep = 2;
                        }
                        if (val && _groupNames.isEmpty) {
                          _groupNames = List.generate(_groupCount, (i) => 'Gruppo ${String.fromCharCode(65 + i)}');
                        }
                      }),
                    ),
                  ],
                ),
                if (_isMultiGroup) ...[
                  const Divider(height: 32),
                  _buildGroupSettings(),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.groupCountLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  DropdownButton<int>(
                    value: _groupCount,
                    isExpanded: true,
                    items: [2, 3, 4, 6, 8].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                    onChanged: (val) => setState(() {
                      _groupCount = val!;
                      // Update group names preserving existing ones
                      final oldNames = List<String>.from(_groupNames);
                      _groupNames = List.generate(_groupCount, (i) => i < oldNames.length ? oldNames[i] : 'Gruppo ${String.fromCharCode(65 + i)}');
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(AppLocalizations.of(context)!.qualifiersPerGroupLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                   DropdownButton<int>(
                    value: _qualifiersPerGroup,
                    isExpanded: true,
                    items: [1, 2, 3, 4].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                    onChanged: (val) => setState(() => _qualifiersPerGroup = val!),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_mode == 'group_and_elimination')
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(AppLocalizations.of(context)!.hasPlayInLabel, style: const TextStyle(fontSize: 14)),
            value: _hasPlayIn,
            onChanged: (val) => setState(() => _hasPlayIn = val),
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
        _buildModeOption('league_madness', AppLocalizations.of(context)!.leagueMadness, AppLocalizations.of(context)!.leagueMadnessSubtitle, Icons.electric_bolt),
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

  Widget _buildEndDatePicker() {
    final suggested = _calculateSuggestedEnd();
    final timeStr = _endDate == null 
      ? "NON DEFINITO" 
      : "${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year} ${_endDate!.hour.toString().padLeft(2, '0')}:${_endDate!.minute.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.tournamentEndDate, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? suggested,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked == null) return;

            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_endDate ?? suggested),
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

              setState(() {
                _endDate = newEnd;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.access_time),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'SUGGERITO: ${suggested.hour.toString().padLeft(2, '0')}:${suggested.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.orange.withOpacity(0.8),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => setState(() => _endDate = suggested),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text('USA QUESTO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
            ),
          ],
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

        final selectedTeams = _selectedTeamIds.map((id) => teams.firstWhere((t) => t.id == id)).toList();

        // Filter teams based on search text for the selection list
        final searchText = _searchController.text.toLowerCase();
        final filteredTeams = teams.where((team) => 
          team.name.toLowerCase().contains(searchText)
        ).toList();

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
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTeamIds = _selectedTeamIds.reversed.toList();
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
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedTeams.length,
                  itemBuilder: (context, index) {
                    final team = selectedTeams[index];
                    return ListTile(
                      key: ValueKey('ordered_${team.id}'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.drag_handle),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
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
                  color: Colors.orange.withOpacity(0.2),
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

            // Select All / Deselect All
            if (searchText.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        final allFilteredIds = filteredTeams.map((t) => t.id).toList();
                        bool allSelected = allFilteredIds.every((id) => _selectedTeamIds.contains(id));
                        
                        if (allSelected) {
                          for (var id in allFilteredIds) {
                            _selectedTeamIds.remove(id);
                          }
                        } else {
                          for (var id in allFilteredIds) {
                            if (!_selectedTeamIds.contains(id)) {
                              _selectedTeamIds.add(id);
                            }
                          }
                        }
                      });
                    }, 
                    child: Text(filteredTeams.every((t) => _selectedTeamIds.contains(t.id)) 
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
                        if (!_selectedTeamIds.contains(team.id)) {
                          _selectedTeamIds.add(team.id);
                        }
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
