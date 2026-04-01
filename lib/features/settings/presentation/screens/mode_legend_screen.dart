import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class ModeLegendScreen extends StatelessWidget {
  const ModeLegendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final modes = [
      {
        'id': 'group_only',
        'title': l10n.groupOnly,
        'icon': Icons.table_rows_outlined,
        'color': Colors.blue,
      },
      {
        'id': 'elimination_only',
        'title': l10n.eliminationOnly,
        'icon': Icons.account_tree_outlined,
        'color': Colors.red,
      },
      {
        'id': 'group_and_elimination',
        'title': l10n.groupAndElimination,
        'icon': Icons.military_tech_outlined,
        'color': Colors.orange,
      },
      {
        'id': 'madness',
        'title': l10n.madness,
        'icon': Icons.flash_on_outlined,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legenda Modalità'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: modes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final mode = modes[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (mode['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(mode['icon'] as IconData, color: mode['color'] as Color),
              ),
              title: Text(
                mode['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/legend/${mode['id']}'),
            ),
          );
        },
      ),
    );
  }
}
