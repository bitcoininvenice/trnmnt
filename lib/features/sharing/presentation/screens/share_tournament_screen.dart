import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/api_config_provider.dart';
import '../../data/share_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';

enum ShareType { web, manage }

class ShareTournamentScreen extends ConsumerStatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const ShareTournamentScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  ConsumerState<ShareTournamentScreen> createState() => _ShareTournamentScreenState();
}

class _ShareTournamentScreenState extends ConsumerState<ShareTournamentScreen> {
  bool _isPublishing = false;
  String? _webUrl;
  String? _cloudId;
  ShareType _shareType = ShareType.web;
  final _twitchController = TextEditingController();
  final _tickerController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _twitchController.dispose();
    _tickerController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
      if (tournament != null) {
        setState(() {
          _webUrl = tournament.webUrl;
          _cloudId = tournament.cloudId;
          _locationController.text = tournament.location;
          if (tournament.twitchChannel != null) {
            _twitchController.text = tournament.twitchChannel!;
          }
          if (tournament.customTicker != null) {
            _tickerController.text = tournament.customTicker!;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile aprire $url')),
        );
      }
    }
  }

  Future<void> _publishToWeb() async {
    setState(() => _isPublishing = true);
    try {
      final repo = ref.read(shareRepositoryProvider);
      final tournamentsRepo = ref.read(tournamentsRepositoryProvider);
      
      final twitchChannel = _twitchController.text.trim();
      final customTicker = _tickerController.text.trim();
      final location = _locationController.text.trim();
      
      await tournamentsRepo.updateTournament(
        id: widget.tournamentId, 
        twitchChannel: twitchChannel,
        customTicker: customTicker,
        location: location.isNotEmpty ? location : null,
      );

      final fullUrl = await repo.publishToSupabase(widget.tournamentId);

      if (fullUrl != null) {
        await _loadInitialData();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sincronizzato sul Cloud! ☁️🏀'), backgroundColor: Colors.blue),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiConfig = ref.watch(apiConfigProvider);
    final l10n = AppLocalizations.of(context)!;

    final themeColor = _shareType == ShareType.web ? Colors.blueAccent : Colors.orangeAccent;
    final cloudId = _cloudId;
    final isCloudActive = cloudId != null;

    Widget bodyContent;

    if (!isCloudActive) {
      bodyContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
          const SizedBox(height: 24),
          Text(
            l10n.publishToCloud_title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.publishToCloud_desc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isPublishing ? null : _publishToWeb,
            icon: _isPublishing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload),
            label: Text(l10n.publishNow),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      );
    } else {
      final qrData = _shareType == ShareType.web 
          ? _webUrl! 
          : "trnmnt://manage?id=$cloudId";

      bodyContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabButton(ShareType.web, 'Web Result', Icons.public),
                _buildTabButton(ShareType.manage, 'Co-Management', Icons.sync),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // QR Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220,
              foregroundColor: Colors.black,
            ),
          ).animate().scale(),

          const SizedBox(height: 24),
          Text(
            _shareType == ShareType.web ? 'DASHBOARD PUBBLICA' : 'CO-GESTIONE CLOUD',
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            _shareType == ShareType.web 
                ? 'Chiunque può vedere i risultati live' 
                : 'Invita un altro organizzatore a gestire il torneo',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 32),
          
          // Cloud Settings Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings_suggest, size: 18, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      'IMPOSTAZIONI CLOUD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Location Adjustment
                _buildField(
                  controller: _locationController,
                  label: 'LOCATION LIVE',
                  hint: 'Es: Playground San Alvise',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                // Twitch integration
                _buildField(
                  controller: _twitchController,
                  label: 'TWITCH CHANNEL',
                  hint: 'Es: venicestreetball',
                  icon: Icons.live_tv_rounded,
                ),
                const SizedBox(height: 16),

                // Custom Ticker
                _buildField(
                  controller: _tickerController,
                  label: 'TESTO SCORREVOLE (TICKER)',
                  hint: 'Sponsor, annunci community...',
                  icon: Icons.message_outlined,
                  maxLines: 2,
                ),
                
                const SizedBox(height: 12),
                Text(
                  'Lascia vuoto per utilizzare il testo generato automaticamente dal sistema.',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: () => Clipboard.setData(ClipboardData(text: qrData)),
                icon: const Icon(Icons.copy),
                tooltip: 'Copia link',
              ),
              const SizedBox(width: 16),
              if (_shareType == ShareType.web)
                ElevatedButton.icon(
                  onPressed: () => _openUrl(_webUrl!),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Apri Risultati'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              else 
                ElevatedButton.icon(
                  onPressed: _publishToWeb, // Re-update cloud cache
                  icon: _isPublishing 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync),
                  label: const Text('Aggiorna Cloud'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.share} ${widget.tournamentName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: apiConfig.isConnected ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Colors.white24),
            prefixIcon: Icon(icon, size: 18, color: Colors.white70),
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(ShareType type, String label, IconData icon) {
    final isSelected = _shareType == type;
    final color = type == ShareType.web ? Colors.blueAccent : Colors.orangeAccent;

    return GestureDetector(
      onTap: () => setState(() => _shareType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
