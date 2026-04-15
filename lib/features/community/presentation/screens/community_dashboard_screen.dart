import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../data/community_repository.dart';
import '../../data/selected_community_provider.dart';
import '../../../../core/database/app_database.dart';

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
  bool _showInitialForm = false;

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
    
    String slug = _slugController.text.trim();
    if (slug.isEmpty) {
      slug = _nameController.text.trim().toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '-')
          .replaceAll(RegExp(r'-+'), '-');
    }

    final repo = ref.read(communityRepositoryProvider);
    final success = await repo.upsertCommunity(
      name: _nameController.text.trim(),
      slug: slug,
      location: _locationController.text.trim(),
      instagramUrl: igVal.isNotEmpty ? 'https://instagram.com/$igVal' : null,
      tiktokUrl: tkVal.isNotEmpty ? 'https://tiktok.com/@$tkVal' : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.saveCommunity} 🏆', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        ref.invalidate(currentCommunityProvider);
        setState(() => _showInitialForm = false);
        if (context.canPop()) {
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorJoiningCommunity, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCommunityAsync = ref.watch(currentCommunityProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityManagement),
        actions: [
          activeCommunityAsync.when(
            data: (community) {
              if (community == null) return const SizedBox.shrink();
              if (community.isOwner) {
                // Owner: can scan to join another community
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: l10n.scanQrInvitation,
                    onPressed: () => context.push('/community/join'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_2),
                    tooltip: l10n.shareInvitation,
                    onPressed: () => _showShareQr(context, community),
                  ),
                ]);
              } else {
                // Member: can scan another community OR create their own
                return Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: l10n.scanQrInvitation,
                    onPressed: () => context.push('/community/join'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: l10n.createNewGroup,
                    onPressed: () => setState(() => _showInitialForm = true),
                  ),
                ]);
              }
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: activeCommunityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
        error: (e, st) => Center(child: Text('Errore: $e')),
        data: (community) {
          // If user pressed '+', show the creation/join form regardless
          if (_showInitialForm) {
            return _buildCreationForm(context, isOwner: true);
          }
          
          if (community == null) {
            return _buildEmptyState(context);
          }
          
          final isOwner = community.isOwner;

          // Pre-fill controllers with community data
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_nameController.text.isEmpty) {
              _nameController.text = community.name;
            }
            if (_slugController.text.isEmpty) {
              _slugController.text = community.slug;
            }
            if (_locationController.text.isEmpty && community.location != null) {
              _locationController.text = community.location!;
            }
            if (_instagramController.text.isEmpty && community.instagramUrl != null) {
              final ig = community.instagramUrl!.split('/').last;
              _instagramController.text = ig;
            }
            if (_tiktokController.text.isEmpty && community.tiktokUrl != null) {
              final tk = community.tiktokUrl!.split('@').last;
              _tiktokController.text = tk;
            }
          });
          return Column(
            children: [
              _buildSwitchBar(ref),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          isOwner ? Icons.hub_outlined : Icons.groups_outlined, 
                          size: 80, 
                          color: isOwner ? Colors.orange : Colors.blue
                        ),
                        const SizedBox(height: 24),
                        Text(
                          isOwner 
                              ? l10n.adminStatus 
                              : l10n.collaboratorStatus,
                          textAlign: TextAlign.center, 
                          style: const TextStyle(fontSize: 15, color: Colors.white70)
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: l10n.nameLabel, 
                            border: const OutlineInputBorder()
                          ),
                          validator: (v) => v == null || v.length < 3 ? 'Inserisci un nome valido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _slugController,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: 'URL Slug', 
                            border: const OutlineInputBorder(), 
                            prefixText: 'trnmnt.vercel.app/it/',
                            prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          validator: (v) => v == null || v.length < 3 ? 'Inserisci un URL valido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          readOnly: !isOwner,
                          decoration: const InputDecoration(
                            labelText: 'Location', 
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _instagramController,
                          readOnly: !isOwner,
                          decoration: const InputDecoration(
                            labelText: 'Instagram',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.camera_alt_outlined),
                            prefixText: '@ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tiktokController,
                          readOnly: !isOwner,
                          decoration: const InputDecoration(
                            labelText: 'TikTok',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.music_note_outlined),
                            prefixText: '@ ',
                          ),
                        ),
                        if (isOwner) ...[
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
                                : Text(l10n.updateData),
                          )
                        ] else ... [
                          const SizedBox(height: 32),
                          Center(child: Text(l10n.onlyAdminCanEdit, style: const TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic)))
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitchBar(WidgetRef ref) {
    // We'll Fetch all local communities
    final repo = ref.read(communityRepositoryProvider);
    return FutureBuilder<List<Community>>(
      future: repo.getAllLocalCommunities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length <= 1) return const SizedBox.shrink();
        
        final communities = snapshot.data!;
        final activeId = ref.watch(selectedCommunityIdProvider);
        
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            border: const Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final c = communities[index];
              final isSelected = activeId == c.id || (activeId == null && index == 0);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(c.name),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref.read(selectedCommunityIdProvider.notifier).setSelected(c.id);
                    }
                  },
                  selectedColor: Colors.orange.withValues(alpha: 0.3),
                  labelStyle: TextStyle(color: isSelected ? Colors.orange : Colors.white),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreationForm(BuildContext context, {bool isOwner = false}) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.add_business_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              l10n.createNewGroup,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.business),
              ),
              validator: (v) => v == null || v.length < 3 ? 'Inserisci un nome valido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.camera_alt_outlined),
                prefixText: '@ ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tiktokController,
              decoration: const InputDecoration(
                labelText: 'TikTok',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.music_note_outlined),
                prefixText: '@ ',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.saveAction ?? 'SALVA'),
            ),
            const SizedBox(height: 16),
            if (!isOwner) ...[  
              OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanQrInvitation),
                onPressed: () => context.push('/community/join'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.orange),
                  foregroundColor: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextButton(
              onPressed: () => setState(() => _showInitialForm = false),
              child: Text(l10n.cancel ?? 'ANNULLA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_showInitialForm) {
      return _buildCreationForm(context);
    }


    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 100, color: Colors.white24),
            const SizedBox(height: 32),
            Text(
              l10n.joinCommunity,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.communityIdentityDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.createNewGroup),
                onPressed: () => setState(() => _showInitialForm = true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanQrInvitation),
                onPressed: () => context.push('/community/join'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.orange),
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _loadExtendedData(String communityId) async {
    final repo = ref.read(communityRepositoryProvider);
    final data = await repo.getMyCommunityFromCloud();
    if (data != null && mounted) {
      setState(() {
        _locationController.text = data['location'] ?? '';
        final ig = data['instagram_url']?.toString().split('/').last ?? '';
        _instagramController.text = ig;
        final tk = data['tiktok_url']?.toString().split('@').last ?? '';
        _tiktokController.text = tk;
      });
    }
  }

  void _showShareQr(BuildContext context, Community community) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.shareInvitation} in ${community.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.scanQrInstructions, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=trnmnt://join-community?id=${community.id}',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
            Text('ID: ${community.id}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CHIUDI')),
        ],
      ),
    );
  }
}
