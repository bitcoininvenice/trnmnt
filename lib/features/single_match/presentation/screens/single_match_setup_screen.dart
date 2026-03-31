import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teams/data/teams_repository.dart';

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
        title: const Text('Setup Partita Singola'),
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Errore: $err')),
        data: (teams) {
          if (teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nessuna squadra presente nel database.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/teams/new'),
                    child: const Text('Crea Squadra'),
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
                  const Text(
                    'Seleziona le squadre per la partita singola',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Squadra in casa'),
                    value: _homeTeamId,
                    items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _homeTeamId = val;
                        _homeTeamName = teams.firstWhere((t) => t.id == val).name;
                      });
                    },
                    validator: (value) => value == null ? 'Seleziona una squadra' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Squadra in trasferta'),
                    value: _awayTeamId,
                    items: teams.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _awayTeamId = val;
                        _awayTeamName = teams.firstWhere((t) => t.id == val).name;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Seleziona una squadra';
                      if (value == _homeTeamId) return 'Scegli due squadre diverse';
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
                        context.pushNamed(
                          'single-match-board',
                          extra: {
                            'homeTeamName': _homeTeamName,
                            'awayTeamName': _awayTeamName,
                          },
                        );
                      }
                    },
                    child: const Text('Inizia Partita', style: TextStyle(fontSize: 18)),
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
