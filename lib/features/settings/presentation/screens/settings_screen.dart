import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';
import 'package:trnmnt/core/providers/theme_provider.dart';
import 'package:trnmnt/core/providers/locale_provider.dart';
import 'package:trnmnt/core/providers/api_config_provider.dart';
import 'package:trnmnt/core/providers/icon_provider.dart';
import 'package:trnmnt/core/providers/default_tab_provider.dart';
import 'package:trnmnt/core/providers/osm_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '...';
  String _baseVersion = '1.0.0';
  final String _assetIconPath = 'assets/icon/logo.png';

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
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader(context, AppLocalizations.of(context)!.appLanguage),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: Text(AppLocalizations.of(context)!.appLanguage),
            trailing: DropdownButton<String>(
              value: ref.watch(localeProvider).languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'it', child: Text('Italiano')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (lang) => ref.read(localeProvider.notifier).setLocale(Locale(lang!)),
            ),
          ),
          const Divider(),

          _buildSectionHeader(context, AppLocalizations.of(context)!.theme),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Colors.orange),
            title: Text(AppLocalizations.of(context)!.theme),
            trailing: DropdownButton<AppThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: AppThemeMode.base, child: Text(AppLocalizations.of(context)!.baseTheme)),
                DropdownMenuItem(value: AppThemeMode.dark, child: Text(AppLocalizations.of(context)!.darkTheme)),
                DropdownMenuItem(value: AppThemeMode.light, child: Text(AppLocalizations.of(context)!.lightTheme)),
              ],
              onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode!),
            ),
          ),
          const Divider(),

          _buildSectionHeader(context, AppLocalizations.of(context)!.defaultHomeScreen),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: Colors.purple),
            title: Text(AppLocalizations.of(context)!.defaultHomeScreen),
            trailing: DropdownButton<int>(
              value: ref.watch(defaultTabProvider),
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.dashboard)),
                DropdownMenuItem(value: 1, child: Text(AppLocalizations.of(context)!.hub)),
              ],
              onChanged: (index) => ref.read(defaultTabProvider.notifier).setDefaultTab(index!),
            ),
          ),
          const Divider(),

          _buildSectionHeader(context, AppLocalizations.of(context)!.mapSettings),
          SwitchListTile(
            secondary: const Icon(Icons.public, color: Colors.blue),
            title: Text(AppLocalizations.of(context)!.enableOsmData),
            subtitle: Text(AppLocalizations.of(context)!.osmDataDesc),
            value: ref.watch(osmSettingsProvider),
            onChanged: (value) => ref.read(osmSettingsProvider.notifier).setEnabled(value),
          ),
          const Divider(),

          _buildSectionHeader(context, 'Legenda'),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.green),
            title: const Text('Modalità Torneo'),
            subtitle: const Text('Scopri regole e dettagli'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/legend'),
          ),
          const Divider(),

          _buildSectionHeader(context, AppLocalizations.of(context)!.appIcon),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              clipBehavior: Clip.antiAlias,
              child: customIconPath != null
                ? Image.file(File(customIconPath), fit: BoxFit.cover)
                : Image.asset(_assetIconPath, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.apps)),
            ),
            title: Text(AppLocalizations.of(context)!.appIcon),
            subtitle: Text(customIconPath != null ? 'Icona personalizzata attiva' : 'Icona predefinita'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (customIconPath != null)
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.orange),
                    onPressed: () => ref.read(customIconProvider.notifier).reset(),
                  ),
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.blue),
                  onPressed: _pickAppIcon,
                ),
              ],
            ),
          ),
          const Divider(),

          _buildSectionHeader(context, AppLocalizations.of(context)!.developers),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.globe, size: 20),
            title: Text(AppLocalizations.of(context)!.officialWebsite),
            onTap: () => _launchUrl(ref.read(apiConfigProvider).baseUrl),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.instagram, size: 20),
            title: const Text('Instagram'),
            onTap: () => _launchUrl('https://instagram.com/venicestreetball'),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.github, size: 20),
            title: const Text('GitHub'),
            onTap: () => _launchUrl('https://github.com/bitcoininvenice/trnmnt/releases/tag/$_baseVersion'),
          ),
          const SizedBox(height: 32),

          Center(
            child: Text(
              '${AppLocalizations.of(context)!.appVersion} $_version',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
