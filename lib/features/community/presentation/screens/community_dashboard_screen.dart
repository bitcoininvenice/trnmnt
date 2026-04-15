import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  void _clearControllers() {
    _nameController.clear();
    _slugController.clear();
    _locationController.clear();
    _instagramController.clear();
    _tiktokController.clear();
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
    final errorResult = await repo.upsertCommunity(
      name: _nameController.text.trim(),
      slug: slug,
      location: _locationController.text.trim(),
      instagramUrl: igVal.isNotEmpty ? 'https://instagram.com/$igVal' : null,
      tiktokUrl: tkVal.isNotEmpty ? 'https://tiktok.com/@$tkVal' : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (errorResult == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.saveCommunity} 🏆', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        ref.invalidate(currentCommunityProvider);
        setState(() => _showInitialForm = false);
        if (context.canPop()) {
          context.pop();
        }
      } else if (errorResult == 'slug-exists') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.slugAlreadyExists, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.orange));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorJoiningCommunity, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for community changes to update controllers
    ref.listen<AsyncValue<Community?>>(currentCommunityProvider, (previous, next) {
      if (_showInitialForm) return; // Don't overwrite if creating new
      final community = next.value;
      if (community != null) {
        _nameController.text = community.name;
        _slugController.text = community.slug;
        _locationController.text = community.location ?? '';
        _instagramController.text = community.instagramUrl?.split('/').last ?? '';
        _tiktokController.text = community.tiktokUrl?.split('@').last ?? '';
      }
    });

    final activeCommunityAsync = ref.watch(currentCommunityProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityManagement),
        actions: [
          activeCommunityAsync.when(
            data: (community) {
              if (community == null) return const SizedBox.shrink();
              final isOwner = community.isOwner;
              final isLegacy = community.id.startsWith('legacy');
              
              if (isOwner) {
                return IconButton(
                  icon: Icon(Icons.qr_code_2, color: isLegacy ? Colors.white24 : null),
                  tooltip: isLegacy ? 'Configura e salva i dati della community prima di generare inviti!' : l10n.shareInvitation,
                  onPressed: isLegacy 
                    ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configura e salva i dati della community prima di generare inviti! 🚀')))
                    : () => _showShareQr(context, community),
                );
              }
              // Members see no actions in the AppBar (cleaner UI)
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: activeCommunityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.orange)),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
        data: (community) {
          // If user pressed '+', show the creation/join form regardless
          if (_showInitialForm) {
            return _buildCreationForm(context, isOwner: true);
          }
          
          if (community == null) {
            return _buildEmptyState(context);
          }
          
          final isOwner = community.isOwner;

          // Note: Initial controller population happens in ref.listen
          // but we do a one-time check here for the very first build if data is already present
          if (!_showInitialForm && _nameController.text.isEmpty) {
            _nameController.text = community.name;
            _slugController.text = community.slug;
            _locationController.text = community.location ?? '';
            _instagramController.text = community.instagramUrl?.split('/').last ?? '';
            _tiktokController.text = community.tiktokUrl?.split('@').last ?? '';
          }

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
                          validator: (v) => v == null || v.length < 3 ? l10n.invalidName : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _slugController,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: l10n.urlSlug, 
                            border: const OutlineInputBorder(), 
                            prefixText: 'trnmnt.vercel.app/it/',
                            prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          validator: (v) => v == null || v.length < 3 ? l10n.invalidUrl : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: l10n.locationLabel, 
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _instagramController,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: l10n.instagramLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.camera_alt_outlined),
                            prefixText: '@ ',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tiktokController,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: l10n.tiktokLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.music_note_outlined),
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
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/community/join'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(l10n.scanQrInvitation),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              side: const BorderSide(color: Colors.orange),
                              foregroundColor: Colors.orange,
                            ),
                          ),
                        ] else ... [
                          const SizedBox(height: 32),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/community/join'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: Text(l10n.scanQrInvitation),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              side: const BorderSide(color: Colors.blue),
                              foregroundColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
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
    final repo = ref.read(communityRepositoryProvider);
    return FutureBuilder<List<Community>>(
      future: repo.getAllLocalCommunities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length <= 1) return const SizedBox.shrink();
        
        // Sort so that owned communities appear first
        final communities = snapshot.data!;
        communities.sort((a, b) {
          if (a.isOwner && !b.isOwner) return -1;
          if (!a.isOwner && b.isOwner) return 1;
          return a.name.compareTo(b.name);
        });

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
                  avatar: c.isOwner 
                      ? Icon(Icons.stars, size: 16, color: isSelected ? Colors.white : Colors.orange)
                      : Icon(Icons.people_outline, size: 16, color: isSelected ? Colors.white : Colors.blue),
                  label: Text(c.name),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      ref.read(selectedCommunityIdProvider.notifier).setSelected(c.id);
                    }
                  },
                  selectedColor: c.isOwner ? Colors.orange.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.5),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (c.isOwner ? Colors.orange.shade300 : Colors.blue.shade300),
                    fontWeight: c.isOwner ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
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
              validator: (v) => v == null || v.length < 3 ? l10n.invalidName : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: l10n.locationLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration: InputDecoration(
                labelText: l10n.instagramLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.camera_alt_outlined),
                prefixText: '@ ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tiktokController,
              decoration: InputDecoration(
                labelText: l10n.tiktokLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.music_note_outlined),
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
                onPressed: () {
                  _clearControllers();
                  setState(() => _showInitialForm = true);
                },
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

  void _showShareQr(BuildContext context, Community community, {AppLocalizations? l10n}) {
    // Use the passed context or the stable widget context
    final stableContext = mounted ? this.context : context;
    final effectiveL10n = l10n ?? AppLocalizations.of(stableContext)!;
    
    final inviteToken = community.inviteToken;
    final expiresAt = community.inviteTokenExpiresAt;
    
    final bool isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);
    final bool hasToken = inviteToken != null && !isExpired;

    showDialog(
      context: stableContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('${effectiveL10n.shareInvitation} in ${community.name}'),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasToken 
                        ? effectiveL10n.scanQrInstructions 
                        : effectiveL10n.noActiveInvite,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (hasToken) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: QrImageView(
                        data: 'trnmnt://join-community?token=$inviteToken',
                        version: QrVersions.auto,
                        size: 200,
                        gapless: false,
                        embeddedImage: const AssetImage('assets/icon/logo.png'),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(40, 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      effectiveL10n.expiryDate('${expiresAt!.hour}:${expiresAt.minute.toString().padLeft(2, '0')}', '${expiresAt.day}/${expiresAt.month}'),
                      style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ] else
                    const Icon(Icons.qr_code_2, size: 100, color: Colors.white10),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final repo = ref.read(communityRepositoryProvider);
                  final newToken = await repo.generateInviteToken(community.id);
                  if (newToken != null && mounted) {
                    ref.invalidate(currentCommunityProvider);
                    // Use dialogContext to pop only the dialog
                    Navigator.pop(dialogContext);
                    
                    // Re-open with new data after a short delay
                    Future.delayed(const Duration(milliseconds: 300), () async {
                      if (mounted) {
                        final freshComm = await ref.read(currentCommunityProvider.future);
                        if (freshComm != null && mounted) {
                          _showShareQr(stableContext, freshComm, l10n: effectiveL10n);
                        }
                      }
                    });
                  }
                },
                child: Text(hasToken ? effectiveL10n.regenerateInvite : effectiveL10n.generateInviteAction),
              ),
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(effectiveL10n.close)),
            ],
          );
        }
      ),
    );
  }
}
