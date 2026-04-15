import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import '../../data/community_repository.dart';
import '../../../../core/database/app_database.dart';

class JoinCommunityScreen extends ConsumerStatefulWidget {
  const JoinCommunityScreen({super.key});

  @override
  ConsumerState<JoinCommunityScreen> createState() => _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends ConsumerState<JoinCommunityScreen> {
  bool _isProcessing = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final l10n = AppLocalizations.of(context)!;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;
      
      final String code = barcode.rawValue!;
      final uri = Uri.tryParse(code);
      
      if (uri != null && (uri.host == 'join-community' || code.startsWith('trnmnt://join-community'))) {
        setState(() => _isProcessing = true);
        
        final token = uri.queryParameters['token'];
        final id = uri.queryParameters['id'];
        
        bool success = false;
        if (token != null) {
          success = await ref.read(communityRepositoryProvider).joinCommunityByToken(token);
        } else if (id != null) {
          // Legacy support (optional: remove for maximum security)
          success = await ref.read(communityRepositoryProvider).joinCommunity(id);
        }
        
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.joinedCommunitySuccess), backgroundColor: Colors.green),
            );
            ref.invalidate(currentCommunityProvider);
            context.pop();
          } else {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.errorJoiningCommunity), backgroundColor: Colors.red),
            );
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanQrTitle)),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: Colors.black54,
              child: Text(
                l10n.scanQrInstructions,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
