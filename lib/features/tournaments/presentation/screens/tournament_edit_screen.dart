import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../../core/database/app_database.dart';
import '../../data/tournaments_repository.dart';
import '../../../teams/data/teams_repository.dart';

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
  final Set<int> _selectedTeamIds = {};
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _searchController.dispose();
    super.dispose();
  }



  Future<void> _updateTournament() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamIds.length < 2) {
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
        startDate: _startDate,
      );

      await repo.setTournamentTeams(widget.tournamentId, _selectedTeamIds.toList());

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

    // Initial data loading using a listener to avoid setState in build
    ref.listen(tournamentByIdProvider(widget.tournamentId), (previous, next) {
      if (next.hasValue && next.value != null && !_isInit) {
        final t = next.value!;
        _nameController.text = t.name;
        _locationController.text = t.location;
        _startDate = t.startDate ?? DateTime.now();
        setState(() {}); // Still need to refresh UI for the date string
      }
    });

    ref.listen(tournamentTeamsProvider(widget.tournamentId), (previous, next) {
      if (next.hasValue && next.value != null && !_isInit) {
        _selectedTeamIds.clear();
        _selectedTeamIds.addAll(next.value!.map((e) => e.team.id));
        _isInit = true; // Mark as initialized ONLY after teams are also loaded
        setState(() {});
      }
    });

    final tournamentAsync = ref.watch(tournamentByIdProvider(widget.tournamentId));
    final isReadOnly = tournamentAsync.value?.isReadOnly ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit), // Use translation for "Edit"
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
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
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
                    const SizedBox(height: 24),
                    _buildDateField(isReadOnly),
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

  Widget _buildTeamsSelection(AsyncValue<List<Team>> allTeamsAsync, bool isReadOnly) {
    return allTeamsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
      data: (teams) {
        final searchText = _searchController.text.toLowerCase();
        final filteredTeams = teams; 

        return Column(
          children: [
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

                return CheckboxListTile(
                  title: Text(team.name),
                  value: isSelected,
                  enabled: !isReadOnly,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
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
