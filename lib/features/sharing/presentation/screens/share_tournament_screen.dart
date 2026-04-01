import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/api_config_provider.dart';
import '../../data/share_repository.dart';
import 'package:trnmnt/features/tournaments/data/tournaments_repository.dart';

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
  String? _ip;
  bool _isLoading = true;
  String? _error;
  bool _isPublishing = false;
  String? _webUrl;
  final _twitchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupServer();
  }

  @override
  void dispose() {
    ref.read(shareRepositoryProvider).stopServer();
    _twitchController.dispose();
    super.dispose();
  }

  Future<void> _setupServer() async {
    final repo = ref.read(shareRepositoryProvider);
    try {
      // Fetch existing webUrl/twitchChannel from DB
      final tournament = await ref.read(tournamentByIdProvider(widget.tournamentId).future);
      if (tournament != null) {
        setState(() {
          _webUrl = tournament.webUrl;
          // Note: twitchChannel is not in the schema yet, but if it were we'd load it.
        });
      }

      // On Android, getting the WiFi IP requires Location permission
      if (Theme.of(context).platform == TargetPlatform.android) {
        final status = await Permission.locationWhenInUse.request();
        if (status != PermissionStatus.granted) {
          setState(() {
            _error = 'Location permission is required to get WiFi IP on Android.';
            _isLoading = false;
          });
          return;
        }
      }

      final ip = await repo.getLocalIp();
      if (ip == null || ip == '0.0.0.0' || ip.isEmpty) {
        setState(() {
          _error = 'No WiFi connection found or IP hidden.\nPlease connect to the same network as the receiver.';
          _isLoading = false;
        });
        return;
      }
      await repo.startServer();
      setState(() {
        _ip = ip;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error starting server: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openWebUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  Future<void> _publishToWeb() async {
    setState(() => _isPublishing = true);
    try {
      final repo = ref.read(shareRepositoryProvider);
      final apiConfig = ref.read(apiConfigProvider);
      final bundle = await repo.getTournamentExport(widget.tournamentId);

      // Inject twitchChannel into tournament data if provided
      final twitchChannel = _twitchController.text.trim();
      if (twitchChannel.isNotEmpty && bundle != null) {
        final tournament = Map<String, dynamic>.from(bundle['tournament'] as Map);
        tournament['twitchChannel'] = twitchChannel;
        bundle['tournament'] = tournament;
      }

      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}/api/publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bundle),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final relativeUrl = data['url'] as String;
        final fullUrl = apiConfig.baseUrl + (relativeUrl.startsWith('/') ? relativeUrl : '/$relativeUrl');

        setState(() {
          _webUrl = fullUrl;
          _isPublishing = false;
        });

        // Save to DB
        await repo.saveWebUrl(widget.tournamentId, fullUrl);

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pubblicato con successo! 🏀'), backgroundColor: Colors.blue),
          );
        }
      } else {
        throw 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pubblicazione fallita: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(shareRepositoryProvider);
    final apiConfig = ref.watch(apiConfigProvider);
    final qrData = _webUrl ?? (_ip != null ? repo.getShareUrl(widget.tournamentId) : '');
    final isWebLink = _webUrl != null;

    Widget bodyContent;
    if (_isLoading) {
      bodyContent = const CircularProgressIndicator();
    } else if (_error != null) {
      bodyContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _setupServer, child: const Text('Retry')),
        ],
      );
    } else {
      bodyContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Twitch channel input ──────────────────────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.live_tv, color: Colors.purpleAccent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Diretta Twitch (opzionale)',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _twitchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'es. venicestreetball',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                    prefixText: 'twitch.tv/',
                    prefixStyle: TextStyle(color: Colors.purple.shade300, fontWeight: FontWeight.bold, fontSize: 13),
                    filled: true,
                    fillColor: Colors.black26,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.purple.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.purpleAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Se attivo, verrà mostrato il player video nella pagina web del torneo.',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                ),
              ],
            ),
          ),

          // ── QR Code ───────────────────────────────────────────────
          Text(
            isWebLink ? 'Web Board QR Code' : 'Scan to Import (Local P2P)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isWebLink
                ? 'Scansiona per vedere i risultati nel browser'
                : 'Assicurati che il ricevente sia sulla stessa rete.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: QrImageView(
              data: qrData.isNotEmpty ? qrData : 'https://vesb.vercel.app',
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ).animate(key: ValueKey(isWebLink)).scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),

          const SizedBox(height: 40),

          // ── IP badge (local only) ─────────────────────────────────
          if (!isWebLink)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text('IP: $_ip', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // ── Publish button ────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _isPublishing ? null : _publishToWeb,
            icon: _isPublishing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.public),
            label: Text(AppLocalizations.of(context)!.publishToWeb),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blueAccent,
              side: const BorderSide(color: Colors.blueAccent),
            ),
          ),

          // ── URL display ───────────────────────────────────────────
          if (_webUrl != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              _webUrl!,
              style: const TextStyle(color: Colors.blue, fontSize: 11, decoration: TextDecoration.underline),
            ),
          ],

          // ── Open in browser & Copy Link ───────────────────────────
          if (isWebLink) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openWebUrl(_webUrl!),
                  icon: const Icon(Icons.open_in_browser),
                  label: Text(AppLocalizations.of(context)!.openInBrowser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _webUrl!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiato! 📋')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copia Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppLocalizations.of(context)!.share} ${widget.tournamentName}'),
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
}
