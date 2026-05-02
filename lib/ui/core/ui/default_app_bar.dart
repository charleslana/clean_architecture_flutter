import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/routes.dart';
import '../../../data/repositories/auth/auth_repository.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRepository>();
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isOnLogin = currentLocation == Routes.login;

    return AppBar(
      title: Text(title),
      actions: [
        ...?actions,
        if (!isOnLogin)
          IconButton(
            tooltip: auth.isAuthenticated
                ? 'Logout (${auth.username})'
                : 'Login',
            icon: Icon(auth.isAuthenticated ? Icons.logout : Icons.login),
            onPressed: () {
              if (auth.isAuthenticated) {
                context.go(Routes.home);
                auth.logout();
              } else {
                context.push(Routes.login);
              }
            },
          ),
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go(Routes.home),
        ),
      ],
    );
  }
}
