import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../game/providers/game_provider.dart';

class SingleMatchSetupScreen extends ConsumerStatefulWidget {
  const SingleMatchSetupScreen({super.key});

  @override
  ConsumerState<SingleMatchSetupScreen> createState() => _SingleMatchSetupScreenState();
}

class _SingleMatchSetupScreenState extends ConsumerState<SingleMatchSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _homeTeamId;
  int? _awayTeamId;
  String _homeTeamName = '';
  String _awayTeamName = '';

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.singleMatchSetup),
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (teams) {
          if (teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noTeamsInDatabase),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/teams/new'),
                    child: Text(AppLocalizations.of(context)!.createTeam),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectTeamsForMatch,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.homeTeam),
                    value: _homeTeamId,
                    items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _homeTeamId = val;
                        _homeTeamName = teams.firstWhere((t) => t.id == val).name;
                      });
                    },
                    validator: (value) => value == null ? AppLocalizations.of(context)!.selectATeam : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.awayTeam),
                    value: _awayTeamId,
                    items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _awayTeamId = val;
                        _awayTeamName = teams.firstWhere((t) => t.id == val).name;
                      });
                    },
                    validator: (value) {
                      if (value == null) return AppLocalizations.of(context)!.selectATeam;
                      if (value == _homeTeamId) return AppLocalizations.of(context)!.selectDifferentTeams;
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(activeGameProvider.notifier).setupStandalone(_homeTeamName, _awayTeamName);
                        context.pushNamed(
                          'single-match-board',
                          extra: {
                            'homeTeamName': _homeTeamName,
                            'awayTeamName': _awayTeamName,
                          },
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.startMatch, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
