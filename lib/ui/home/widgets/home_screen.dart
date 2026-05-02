import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';

/// Home is purely presentational: no ViewModel, no data calls — just a menu of
/// destinations. Sub-screens are reached with `context.push` so the
/// [Scaffold] auto-adds a back arrow that walks the stack back to here.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clean Architecture')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeTile(
            icon: Icons.article_outlined,
            title: 'Posts',
            subtitle: 'Lista de posts do JSONPlaceholder',
            onTap: () => context.push(Routes.posts),
          ),
          const SizedBox(height: 12),
          _HomeTile(
            icon: Icons.people_outline,
            title: 'Users',
            subtitle: 'Lista de usuários do JSONPlaceholder',
            onTap: () => context.push(Routes.users),
          ),
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
