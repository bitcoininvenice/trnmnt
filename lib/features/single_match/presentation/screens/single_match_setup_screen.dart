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
  bool _isPublic = false;
  String _twitchUsername = '';
  String _matchTitle = '';

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
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(AppLocalizations.of(context)!.publishToCloud_switch, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(AppLocalizations.of(context)!.publishToCloud_subtitle, style: const TextStyle(fontSize: 11)),
                          value: _isPublic,
                          activeColor: Colors.orange,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) => setState(() => _isPublic = val),
                        ),
                        if (_isPublic) ...[
                          const Divider(height: 24),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.matchTitle_label,
                              hintText: AppLocalizations.of(context)!.matchTitle_hint,
                              prefixIcon: const Icon(Icons.title, size: 20),
                              labelStyle: const TextStyle(fontSize: 12),
                            ),
                            style: const TextStyle(fontSize: 14),
                            onChanged: (val) => _matchTitle = val,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.twitch_label,
                              hintText: AppLocalizations.of(context)!.twitch_hint,
                              prefixIcon: const Icon(Icons.video_camera_front, size: 20),
                              labelStyle: const TextStyle(fontSize: 12),
                            ),
                            style: const TextStyle(fontSize: 14),
                            onChanged: (val) => _twitchUsername = val,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(activeGameProvider.notifier).setupStandalone(
                          _homeTeamName, 
                          _awayTeamName,
                          isPublic: _isPublic,
                          matchTitle: _matchTitle,
                          twitchUsername: _twitchUsername,
                        );
                        context.pushNamed(
                          'single-match-board',
                          extra: {
                            'homeTeamName': _homeTeamName,
                            'awayTeamName': _awayTeamName,
                          },
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.startMatch, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
