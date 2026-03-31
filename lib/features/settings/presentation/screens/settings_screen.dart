import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trnmnt/core/providers/theme_provider.dart';
import 'package:trnmnt/core/providers/locale_provider.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '...';
  String _baseVersion = '1.0.0';
  final String _assetIconPath = 'assets/icon/app_icon.png';

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
          SnackBar(content: Text(AppLocalizations.of(context)!.unableToOpenUrl(url))),
        );
      }
    }
  }

  Future<void> _pickAppIcon() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        await ref.read(customIconProvider.notifier).setIcon(image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.changeAppIcon), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final customIconPath = ref.watch(customIconProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.appLanguage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('Italiano'),
                    value: 'it',
                    groupValue: ref.watch(localeProvider).languageCode,
                    onChanged: (lang) => ref.read(localeProvider.notifier).setLocale(Locale(lang!)),
                  ),
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en',
                    groupValue: ref.watch(localeProvider).languageCode,
                    onChanged: (lang) => ref.read(localeProvider.notifier).setLocale(Locale(lang!)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.theme, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  RadioListTile<AppThemeMode>(
                    title: Text(AppLocalizations.of(context)!.baseTheme),
                    value: AppThemeMode.base,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(AppLocalizations.of(context)!.darkTheme),
                    value: AppThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(AppLocalizations.of(context)!.lightTheme),
                    value: AppThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App Icon Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.appIcon, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: customIconPath != null
                            ? Image.file(File(customIconPath), fit: BoxFit.cover)
                            : Image.asset(_assetIconPath, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.apps, size: 50)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _pickAppIcon,
                          icon: const Icon(Icons.photo_library),
                          label: Text(AppLocalizations.of(context)!.pickImageIcon),
                        ),
                        if (customIconPath != null)
                          TextButton.icon(
                            onPressed: () async {
                              await ref.read(customIconProvider.notifier).reset();
                            },
                            icon: const Icon(Icons.restore, color: Colors.orange),
                            label: Text(
                              AppLocalizations.of(context)!.resetIcon,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
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
                  Text(AppLocalizations.of(context)!.developers, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Venice Streetball Community'),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.globe),
                    title: Text(AppLocalizations.of(context)!.officialWebsite),
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
              '${AppLocalizations.of(context)!.appVersion} $_version',
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
