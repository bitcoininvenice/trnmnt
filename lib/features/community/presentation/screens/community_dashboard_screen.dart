import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/community_repository.dart';

class CommunityDashboardScreen extends ConsumerStatefulWidget {
  const CommunityDashboardScreen({super.key});

  @override
  ConsumerState<CommunityDashboardScreen> createState() => _CommunityDashboardScreenState();
}

class _CommunityDashboardScreenState extends ConsumerState<CommunityDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _locationController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _locationController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String igVal = _instagramController.text.trim().replaceAll('@', '');
    final String tkVal = _tiktokController.text.trim().replaceAll('@', '');

    final repo = ref.read(communityRepositoryProvider);
    final success = await repo.upsertCommunity(
      name: _nameController.text.trim(),
      slug: _slugController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'-+'), '-'),
      location: _locationController.text.trim(),
      instagramUrl: igVal.isNotEmpty ? 'https://instagram.com/$igVal' : null,
      tiktokUrl: tkVal.isNotEmpty ? 'https://tiktok.com/@$tkVal' : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Community salvata! 🏆', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        ref.invalidate(myCommunityProvider);
        if (context.canPop()) {
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore. Slug già in uso o rete assente.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityAsync = ref.watch(myCommunityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('La tua Community')),
      body: communityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
        error: (e, st) => Center(child: Text('Errore: $e')),
        data: (community) {
          // Pre-fill if exists and unchanged manually
          if (community != null && _nameController.text.isEmpty && _slugController.text.isEmpty) {
            _nameController.text = community['name'] ?? '';
            _slugController.text = community['slug'] ?? '';
            _locationController.text = community['location'] ?? '';
            _instagramController.text = (community['instagram_url'] ?? '').replaceAll('https://instagram.com/', '');
            _tiktokController.text = (community['tiktok_url'] ?? '').replaceAll('https://tiktok.com/@', '').replaceAll('https://www.tiktok.com/@', '');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.hub_outlined, size: 80, color: Colors.orange),
                  const SizedBox(height: 24),
                  const Text(
                    'Questa è l\'identità pubblica del tuo gruppo. Tutti i tornei che assegnerai verranno mostrati sul tuo URL esclusivo TRNMNT!',
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontSize: 15, color: Colors.white70)
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome (es: Venice Streetball)', 
                      border: OutlineInputBorder()
                    ),
                    validator: (v) => v == null || v.length < 3 ? 'Inserisci un nome valido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _slugController,
                    decoration: InputDecoration(
                      labelText: 'URL (es: venice-sb)', 
                      border: const OutlineInputBorder(), 
                      prefixText: 'trnmnt.app/',
                      prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    validator: (v) => v == null || v.length < 3 ? 'Inserisci un URL valido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Città o Zona (es: Milano, Playground Nord)', 
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instagramController,
                    decoration: InputDecoration(
                      labelText: 'Username Instagram', 
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.camera_alt),
                      prefixText: 'instagram.com/',
                      prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tiktokController,
                    decoration: InputDecoration(
                      labelText: 'Username TikTok', 
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.music_note),
                      prefixText: 'tiktok.com/@',
                      prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16), 
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                        : const Text('SALVA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
