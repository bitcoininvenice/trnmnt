import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/teams_repository.dart';

class TeamFormScreen extends ConsumerStatefulWidget {
  final int? teamId;

  const TeamFormScreen({super.key, this.teamId});

  @override
  ConsumerState<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends ConsumerState<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.teamId != null;
    if (_isEdit) {
      _loadTeam();
    }
  }

  Future<void> _loadTeam() async {
    // Team will be loaded via provider
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(teamsRepositoryProvider);
      if (_isEdit) {
        await repo.updateTeam(
          id: widget.teamId!,
          name: _nameController.text.trim(),
        );
      } else {
        await repo.createTeam(name: _nameController.text.trim());
      }
      if (mounted) {
        context.go('/teams');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
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
    // Watch team data if editing
    if (_isEdit) {
      final teamAsync = ref.watch(teamByIdProvider(widget.teamId!));
      teamAsync.whenData((team) {
        if (team != null && _nameController.text.isEmpty) {
          _nameController.text = team.name;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifica Squadra' : 'Nuova Squadra'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/teams'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Team avatar preview
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.groups,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Team name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Squadra',
                hintText: 'Es. Lakers, Bulls, etc.',
                prefixIcon: Icon(Icons.badge),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci il nome della squadra';
                }
                if (value.trim().length < 2) {
                  return 'Il nome deve avere almeno 2 caratteri';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTeam,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Salva Modifiche' : 'Crea Squadra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
