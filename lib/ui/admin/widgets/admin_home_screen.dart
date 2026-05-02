import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../core/ui/default_app_bar.dart';

/// Admin entry point. Currently lists Albums; future tiles can plug here.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: 'Admin'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo_album_outlined, size: 32),
              title: const Text('Albums'),
              subtitle: const Text(
                'CRUD: list, create (2 steps), edit, delete',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.adminAlbums),
            ),
          ),
        ],
      ),
    );
  }
}
