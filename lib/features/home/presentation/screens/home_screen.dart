import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'TRNMNT',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'Gestione Tornei di Basket',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildQuickAction(
                      context,
                      icon: Icons.groups,
                      title: 'Squadre',
                      subtitle: 'Gestisci le squadre',
                      color: Colors.blue,
                      onTap: () => context.go('/teams'),
                    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.sports_basketball,
                      title: 'Partita Singola',
                      subtitle: 'Gestisci una partita singola',
                      color: Colors.purple,
                      onTap: () => context.go('/single-match-setup'),
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.emoji_events,
                      title: 'Tornei',
                      subtitle: 'Crea e gestisci',
                      color: Colors.orange,
                      onTap: () => context.go('/tournaments'),
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.add_circle,
                      title: 'Nuovo Torneo',
                      subtitle: 'Inizia subito',
                      color: Colors.green,
                      onTap: () => context.go('/tournaments/new'),
                    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.map,
                      title: 'Mappa',
                      subtitle: 'La mappa dei campetti',
                      color: Colors.teal,
                      onTap: () => context.go('/map'),
                    ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.settings,
                      title: 'Impostazioni',
                      subtitle: 'Opzioni app',
                      color: Colors.grey,
                      onTap: () => context.go('/settings'),
                    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.bar_chart,
                      title: 'Statistiche',
                      subtitle: 'Dati e numeri',
                      color: Colors.deepPurple,
                      onTap: () => context.go('/stats'),
                    ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
