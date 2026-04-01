import 'package:flutter/material.dart';
import 'package:trnmnt/generated/l10n/app_localizations.dart';

class ModeDetailScreen extends StatelessWidget {
  final String modeId;
  const ModeDetailScreen({super.key, required this.modeId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final Map<String, dynamic> detail;
    
    switch (modeId) {
      case 'group_only':
        detail = {
          'title': l10n.groupOnly,
          'icon': Icons.table_rows_outlined,
          'color': Colors.blue,
          'description': 'La modalità classica "Tutti contro Tutti". Tutte le squadre iscritte vengono inserite in un unico girone.',
          'rules': [
            'Ogni squadra affronta tutte le altre esattamente una volta.',
            'Vengono assegnati punti per Vittoria, Pareggio o Sconfitta (configurabili).',
            'La classifica finale determina il vincitore in base al punteggio totale.',
            'In caso di parità, si considerano gli scontri diretti e la differenza canestri.',
          ],
        };
        break;
      case 'elimination_only':
        detail = {
          'title': l10n.eliminationOnly,
          'icon': Icons.account_tree_outlined,
          'color': Colors.red,
          'description': 'In questa modalità, ogni partita è decisiva. Solo chi vince prosegue nel tabellone.',
          'rules': [
            'Le squadre vengono accoppiate casualmente o in base al seeding.',
            'Chi perde una partita viene immediatamente eliminato dal torneo.',
            'Si prosegue attraverso Ottavi, Quarti e Semifinali fino alla Finalissima.',
            'Può essere prevista una finale 3°/4° posto per le perdenti delle semifinali.',
          ],
        };
        break;
      case 'group_and_elimination':
        detail = {
          'title': l10n.groupAndElimination,
          'icon': Icons.military_tech_outlined,
          'color': Colors.orange,
          'description': 'La formula più completa, tipica dei grandi tornei internazionali. Unisce una fase a gironi iniziale a una fase finale a eliminazione diretta.',
          'rules': [
            'Le squadre sono divise in più gironi (es. Girone A, Girone B).',
            'Le migliori di ogni girone si qualificano per i Playoffs.',
            'I Playoffs seguono il tabellone a eliminazione diretta fino alla finale.',
            'Garantisce più partite a tutte le squadre rispetto alla sola eliminazione.',
          ],
        };
        break;
      case 'madness':
        detail = {
          'title': l10n.madness,
          'icon': Icons.flash_on_outlined,
          'color': Colors.purple,
          'description': 'La modalità più dinamica e frenetica del Venice Streetball. Non contano le vittorie, ma quanto riesci a segnare!',
          'rules': [
            'Classifica unica basata esclusivamente sul TOTALE CANESTRI segnati.',
            'Tutte le partite caricate in questa modalità concorrono alla classifica.',
            'Al termine del tempo, le PRIME DUE SQUADRE giocano una Finalissima.',
            'Ideale per tornei rapidi con molte partite simultanee su più campi.',
          ],
        };
        break;
      default:
        detail = {
          'title': 'Sconosciuto',
          'icon': Icons.help_outline,
          'color': Colors.grey,
          'description': 'Informazioni non disponibili.',
          'rules': [],
        };
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(detail['title']),
        backgroundColor: detail['color'],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(detail['icon'], size: 80, color: detail['color']),
            ),
            const SizedBox(height: 24),
            Text(
              'Descrizione',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: detail['color']
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail['description'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            Text(
              'Regole Principali',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: detail['color']
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              (detail['rules'] as List).length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20, color: detail['color']),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        detail['rules'][index],
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
