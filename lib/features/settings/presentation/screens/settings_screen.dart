import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '...';
  String _baseVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _baseVersion = info.version;
          _version = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (e) {
      // Ignorato se il plugin nativo non è stato ancora compilato
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile aprire $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Tema Base (Vibrante)'),
                    value: AppThemeMode.base,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Tema Scuro (Puro)'),
                    value: AppThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
                  ),
                  RadioListTile<AppThemeMode>(
                    title: const Text('Tema Chiaro'),
                    value: AppThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Developer Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sviluppatori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Venice Streetball Community'),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.globe),
                    title: const Text('Sito Ufficiale'),
                    subtitle: const Text('vesb.vercel.app'),
                    onTap: () => _launchUrl('https://vesb.vercel.app'),
                  ),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.instagram),
                    title: const Text('Instagram'),
                    onTap: () => _launchUrl('https://instagram.com/venicestreetball'),
                  ),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.tiktok),
                    title: const Text('TikTok'),
                    onTap: () => _launchUrl('https://tiktok.com/@venicestreetball'),
                  ),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.github),
                    title: const Text('GitHub'),
                    onTap: () => _launchUrl('https://github.com/bitcoininvenice/trnmnt/releases/tag/$_baseVersion'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Version Info
          Center(
            child: Text(
              'Versione $_version',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
