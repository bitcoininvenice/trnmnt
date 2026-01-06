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
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
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
                      icon: Icons.emoji_events,
                      title: 'Tornei',
                      subtitle: 'Crea e gestisci',
                      color: Colors.orange,
                      onTap: () => context.go('/tournaments'),
                    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.add_circle,
                      title: 'Nuovo Torneo',
                      subtitle: 'Inizia subito',
                      color: Colors.green,
                      onTap: () => context.go('/tournaments/new'),
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                    _buildQuickAction(
                      context,
                      icon: Icons.timer,
                      title: 'Timer',
                      subtitle: 'Cronometro partita',
                      color: Colors.red,
                      onTap: () => context.go('/timer'),
                    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8)),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
