import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../game/providers/game_provider.dart';
import '../../../tournaments/presentation/widgets/court_picker_sheet.dart';
import '../../../../core/database/app_database.dart';

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
  String? _venueCourtId;
  String? _selectedCourtName;

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
                  const SizedBox(height: 16),
                  // Court Picker (Now core field)
                  InkWell(
                    onTap: () async {
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
                          _venueCourtId = selection.cloudId ?? selection.osmId ?? selection.localId?.toString();
                          _selectedCourtName = selection.name;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.location_on, color: Colors.orange, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.selectCourt,
                                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedCourtName ?? '${AppLocalizations.of(context)!.optional} - Radar Map',
                                  style: TextStyle(
                                    color: _selectedCourtName != null ? Colors.white : Colors.white38,
                                    fontSize: 14,
                                    fontWeight: _selectedCourtName != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedCourtName != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.white38),
                              onPressed: () => setState(() {
                                _selectedCourtName = null;
                                _venueCourtId = null;
                              }),
                            )
                          else
                            const Icon(Icons.chevron_right, color: Colors.white24),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.02)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cloud_upload, color: Colors.orange, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.publishToCloud_switch.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                            ),
                            const Spacer(),
                            Switch(
                              value: _isPublic,
                              activeColor: Colors.orange,
                              onChanged: (val) => setState(() => _isPublic = val),
                            ),
                          ],
                        ),
                        Text(
                          AppLocalizations.of(context)!.publishToCloud_subtitle,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                        ),
                        if (_isPublic) ...[
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.matchTitle_label,
                              hintText: AppLocalizations.of(context)!.matchTitle_hint,
                              prefixIcon: const Icon(Icons.title, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (val) => _matchTitle = val,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.twitch_label,
                              hintText: AppLocalizations.of(context)!.twitch_hint,
                              prefixIcon: const Icon(Icons.video_camera_front, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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
                          venueCourtId: _venueCourtId,
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
