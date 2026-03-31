import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/api_config_provider.dart';
import '../../data/share_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _setupServer();
  }

  Future<void> _setupServer() async {
    final repo = ref.read(shareRepositoryProvider);
    try {
      final ip = await repo.getLocalIp();
      if (ip == null) {
        setState(() {
          _error = 'No WiFi connection found.\nPlease connect to the same network as the receiver.';
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

  @override
  void dispose() {
    ref.read(shareRepositoryProvider).stopServer();
    super.dispose();
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
      
      final response = await http.post(
        Uri.parse('${apiConfig.baseUrl}/api/publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bundle),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final relativeUrl = data['url'];
        final fullRelativeUrl = relativeUrl.startsWith('/') ? relativeUrl : '/$relativeUrl';
        final fullUrl = apiConfig.baseUrl + fullRelativeUrl;

        setState(() {
          _webUrl = fullUrl;
          _isPublishing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully published to Next.js!'), backgroundColor: Colors.blue),
          );
        }
      } else {
        throw 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPublishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publishing failed: $e'), backgroundColor: Colors.red),
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
          Text(
            isWebLink ? 'Web Board QR Code' : 'Scan to Import (Local P2P)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isWebLink 
              ? 'Scan to view results on the web browser' 
              : 'Make sure the receiver is on the same network.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ).animate(key: ValueKey(isWebLink)).scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
          const SizedBox(height: 40),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
          if (_webUrl != null) ...[
            const SizedBox(height: 8),
            Text(
              'URL: $_webUrl',
              style: const TextStyle(color: Colors.blue, fontSize: 11, decoration: TextDecoration.underline),
            ),
          ],
          if (isWebLink) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  ElevatedButton.icon(
                    onPressed: () => _openWebUrl(_webUrl!),
                    icon: const Icon(Icons.open_in_browser),
                    label: Text(AppLocalizations.of(context)!.openInBrowser),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
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
