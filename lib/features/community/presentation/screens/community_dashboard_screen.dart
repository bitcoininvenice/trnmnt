import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/community_repository.dart';
import '../../data/selected_community_provider.dart';
import '../../../../core/database/app_database.dart';

class CommunityDashboardScreen extends ConsumerStatefulWidget {
  const CommunityDashboardScreen({super.key});

  @override
  ConsumerState<CommunityDashboardScreen> createState() => _CommunityDashboardScreenState();
}

class _CommunityDashboardScreenState extends ConsumerState<CommunityDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _slugController.addListener(_onSlugChanged);
    _slugFocusNode.addListener(_onSlugFocusChange);
  }

  void _onSlugFocusChange() {
    if (!_slugFocusNode.hasFocus) {
      // Just lost focus, if slug is available, search logo
      final slug = _slugController.text.trim();
      
      // Trigger search if:
      // 1. Slug is available
      // 2. Slug is not empty
      // 3. EITHER we haven't confirmed a logo yet OR the slug has changed from original
      final hasSlugChanged = slug != _originalSlug;
      
      if (_isSlugAvailable == true && slug.isNotEmpty && (!_logoConfirmed || hasSlugChanged)) {
        _searchSocialLogo(slug);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _locationController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  bool _isLoading = false;
  bool _showInitialForm = false;
  
  // Slug validation state
  Timer? _debounceTimer;
  bool _isSlugValidating = false;
  bool? _isSlugAvailable;
  String? _lastCheckedSlug;
  String? _lastAutoSlug;
  String? _originalSlug;
  final FocusNode _slugFocusNode = FocusNode();

  // Logo search state
  bool _isSearchingLogo = false;
  String? _foundLogoUrl;
  bool _logoConfirmed = false;
  String _currentSocialSource = 'tiktok'; // Start with tiktok

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _locationController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _debounceTimer?.cancel();
    _slugController.removeListener(_onSlugChanged);
    _slugFocusNode.removeListener(_onSlugFocusChange);
    _slugFocusNode.dispose();
    super.dispose();
  }

  void _onSlugChanged() {
    final slug = _slugController.text.trim();
    if (slug == _lastCheckedSlug) return;
    
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    if (slug.isEmpty || slug.length < 3) {
      setState(() {
        _isSlugAvailable = null;
        _isSlugValidating = false;
        _lastCheckedSlug = slug;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isSlugValidating = true;
        _lastCheckedSlug = slug;
      });

      final repo = ref.read(communityRepositoryProvider);
      final activeCommunity = ref.read(currentCommunityProvider).value;
      
      final isAvailable = await repo.isSlugAvailable(
        slug, 
        excludeId: _showInitialForm ? null : activeCommunity?.id
      );

      if (mounted && slug == _slugController.text.trim()) {
        setState(() {
          _isSlugAvailable = isAvailable;
          _isSlugValidating = false;
        });

        // REMOVED: Auto-trigger logo search here. 
        // Now it triggers on unfocus in _onSlugFocusChange.
      }
    });
  }

  Future<void> _searchSocialLogo(String slug) async {
    setState(() {
      _isSearchingLogo = true;
      _currentSocialSource = 'facebook';
    });

    await _fetchLogoWithMeta(slug, 'facebook');
  }

  Future<void> _fetchLogoWithMeta(String slug, String source) async {
    try {
      // Simulate browser request to the meta API which is often less restricted
      final response = await http.get(
        Uri.parse('https://unavatar.io/api/avatar-meta/$source/$slug'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Referer': 'https://unavatar.io/?provider=$source&input=$slug',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String? url = data['url'];
        if (mounted && url != null) {
          setState(() {
            _foundLogoUrl = url;
            _isSearchingLogo = false;
          });
          return;
        }
      }
      
      // If API fails, try direct URL as fallback
      if (mounted) {
        setState(() {
          _foundLogoUrl = 'https://unavatar.io/$source/$slug';
          _isSearchingLogo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _foundLogoUrl = 'https://unavatar.io/$source/$slug';
          _isSearchingLogo = false;
        });
      }
    }
  }

  void _tryNextSocialSource() async {
    if (_currentSocialSource == 'facebook') {
      setState(() {
        _currentSocialSource = 'youtube';
        _isSearchingLogo = true;
      });
      await _fetchLogoWithMeta(_slugController.text.trim(), 'youtube');
    } else if (_currentSocialSource == 'youtube') {
      setState(() {
        _currentSocialSource = 'tiktok';
        _isSearchingLogo = true;
      });
      await _fetchLogoWithMeta(_slugController.text.trim(), 'tiktok');
    } else if (_currentSocialSource == 'tiktok') {
      setState(() {
        _currentSocialSource = 'twitch';
        _isSearchingLogo = true;
      });
      await _fetchLogoWithMeta(_slugController.text.trim(), 'twitch');
    } else {
      // Give up
      setState(() {
        _foundLogoUrl = null;
        _currentSocialSource = 'none';
        _isSearchingLogo = false;
      });
    }
  }

  String _extractUsername(String? url, String separator) {
    if (url == null || url.isEmpty) return '';
    // Remove trailing slash if present
    String cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    return cleanUrl.split(separator).last;
  }

  void _clearControllers() {
    _nameController.clear();
    _slugController.clear();
    _locationController.clear();
    _instagramController.clear();
    _tiktokController.clear();
    _foundLogoUrl = null;
    _logoConfirmed = false;
    _isSearchingLogo = false;
    _isSlugAvailable = null;
    _lastAutoSlug = null;
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
      logoUrl: _logoConfirmed ? _foundLogoUrl : null,
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

  Future<void> _leaveCommunity(Community community) async {
    final isOwner = community.isOwner;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isOwner ? l10n.leaveCommunityTitle : l10n.removeCommunityTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isOwner
            ? l10n.leaveCommunityOwnerDesc
            : l10n.leaveCommunityMemberDesc,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              isOwner ? l10n.leaveAction : l10n.removeAction,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(communityRepositoryProvider);
      await repo.leaveCommunity(community.id, isOwner: isOwner);
      
      if (!mounted) return;

      ref.invalidate(currentCommunityProvider);
      ref.read(selectedCommunityIdProvider.notifier).setSelected(null);
      
      context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for community changes to update controllers
    ref.listen<AsyncValue<Community?>>(currentCommunityProvider, (previous, next) {
      if (_showInitialForm) return; // Don't overwrite if creating new
      final community = next.value;
      if (community != null) {
        if (_nameController.text.isEmpty) _nameController.text = community.name;
        if (_slugController.text.isEmpty) {
          _slugController.text = community.slug;
          _originalSlug = community.slug;
        }
        if (_locationController.text.isEmpty) _locationController.text = community.location ?? '';
        if (_instagramController.text.isEmpty) _instagramController.text = _extractUsername(community.instagramUrl, '/');
        if (_tiktokController.text.isEmpty) _tiktokController.text = _extractUsername(community.tiktokUrl, '@');
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
          if (!_showInitialForm) {
            if (_nameController.text.isEmpty) _nameController.text = community.name;
            if (_slugController.text.isEmpty) {
              _slugController.text = community.slug;
              _originalSlug = community.slug;
            }
            if (_locationController.text.isEmpty) _locationController.text = community.location ?? '';
            if (_instagramController.text.isEmpty) _instagramController.text = _extractUsername(community.instagramUrl, '/');
            if (_tiktokController.text.isEmpty) _tiktokController.text = _extractUsername(community.tiktokUrl, '@');
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
                        _buildTopIdentity(isOwner, existingLogoUrl: community?.logoUrl),
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
                          focusNode: _slugFocusNode,
                          readOnly: !isOwner,
                          decoration: InputDecoration(
                            labelText: l10n.urlSlug, 
                            border: const OutlineInputBorder(), 
                            prefixText: 'trnmnt.vercel.app/it/',
                            prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            suffixIcon: _buildSlugSuffix(),
                            helperText: _getSlugHelperText(l10n),
                            helperStyle: TextStyle(
                              color: _isSlugAvailable == false ? Colors.orange : Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 3) return l10n.invalidUrl;
                            if (_isSlugAvailable == false) return l10n.slugAlreadyExists;
                            return null;
                          },
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
                          const SizedBox(height: 24),
                          TextButton.icon(
                            onPressed: _isLoading ? null : () => _leaveCommunity(community),
                            icon: const Icon(Icons.logout, color: Color(0xFFef9a9a), size: 16),
                            label: Text(
                              l10n.leaveCommunityAction,
                              style: const TextStyle(color: Color(0xFFef9a9a), fontSize: 12),
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
                          Center(child: Text(l10n.onlyAdminCanEdit, style: const TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic))),
                          const SizedBox(height: 24),
                          TextButton.icon(
                            onPressed: _isLoading ? null : () => _leaveCommunity(community),
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFef9a9a), size: 16),
                            label: Text(
                              l10n.removeCommunityAction,
                              style: const TextStyle(color: Color(0xFFef9a9a), fontSize: 12),
                            ),
                          ),
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

  Widget _buildTopIdentity(bool isOwner, {String? existingLogoUrl}) {
    // If slug has changed from original, we treat existing logo as "stale"
    final bool isSlugChanged = _slugController.text.trim() != _originalSlug;
    final bool shouldShowExisting = existingLogoUrl != null && !isSlugChanged;

    if (_isSearchingLogo) {
      return Column(
        children: [
          const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(color: Colors.orange)),
          ),
          const SizedBox(height: 8),
          Text(
            'Ricerca logo sui social network...',
            style: TextStyle(color: Colors.orange.shade300, fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    if (_foundLogoUrl != null && !_logoConfirmed && _currentSocialSource != 'none') {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    _foundLogoUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Automatically try next source if current one fails (e.g. 429)
                      Future.microtask(() => _tryNextSocialSource());
                      return const Center(child: Icon(Icons.broken_image, color: Colors.orange, size: 20));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('È questa l\'immagine?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _smallButton(
                        icon: Icons.check, 
                        color: Colors.green, 
                        onTap: () => setState(() => _logoConfirmed = true)
                      ),
                      const SizedBox(width: 8),
                      _smallButton(
                        icon: Icons.close, 
                        color: Colors.red, 
                        onTap: _tryNextSocialSource
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Logo trovato su ${_currentSocialSource.toUpperCase()}',
            style: const TextStyle(color: Colors.white38, fontSize: 9, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    if (_logoConfirmed && _foundLogoUrl != null) {
      return Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              _foundLogoUrl!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    if (shouldShowExisting) {
      return Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: ClipOval(
            child: Image.network(
              existingLogoUrl,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Icon(
                isOwner ? Icons.hub_outlined : Icons.groups_outlined, 
                size: 80, 
                color: isOwner ? Colors.orange : Colors.blue
              ),
            ),
          ),
        ),
      );
    }

    return Icon(
      isOwner ? Icons.hub_outlined : Icons.groups_outlined, 
      size: 80, 
      color: isOwner ? Colors.orange : Colors.blue
    );
  }

  Widget _smallButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget? _buildSlugSuffix() {
    if (_isSlugValidating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
        ),
      );
    }
    if (_isSlugAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    if (_isSlugAvailable == false) {
      return const Icon(Icons.error, color: Colors.orange, size: 20);
    }
    return null;
  }

  String? _getSlugHelperText(AppLocalizations l10n) {
    if (_isSlugAvailable == true) return 'Slug disponibile! ✨';
    if (_isSlugAvailable == false) return l10n.slugAlreadyExists;
    return null;
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
            _buildTopIdentity(isOwner),
            const SizedBox(height: 24),
            Text(
              l10n.createNewCommunity,
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
              onChanged: (v) {
                if (_slugController.text.isEmpty || _slugController.text == _lastAutoSlug) {
                  final newSlug = v.trim().toLowerCase()
                      .replaceAll(RegExp(r'[^a-z0-9]'), '-')
                      .replaceAll(RegExp(r'-+'), '-');
                  _slugController.text = newSlug;
                  _lastAutoSlug = newSlug;
                }
              },
              validator: (v) => v == null || v.length < 3 ? l10n.invalidName : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _slugController,
              focusNode: _slugFocusNode,
              decoration: InputDecoration(
                labelText: l10n.urlSlug,
                border: const OutlineInputBorder(),
                prefixText: 'trnmnt.vercel.app/it/',
                prefixStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                suffixIcon: _buildSlugSuffix(),
                helperText: _getSlugHelperText(l10n),
                helperStyle: TextStyle(
                  color: _isSlugAvailable == false ? Colors.orange : Colors.white60,
                  fontSize: 10,
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 3) return l10n.invalidUrl;
                if (_isSlugAvailable == false) return l10n.slugAlreadyExists;
                return null;
              },
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
            const Icon(Icons.hub_outlined, size: 100, color: Colors.white24),
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
                label: Text(l10n.createNewCommunity),
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
