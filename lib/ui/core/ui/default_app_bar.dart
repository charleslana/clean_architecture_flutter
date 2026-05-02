import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/routes.dart';
import '../../../data/repositories/auth/auth_repository.dart';

/// Default [AppBar] used by every screen **except** the home itself.
///
/// Adds two action buttons on the right:
///   - **Login / Logout**: hidden when the current route already is `/login`
///     (would be redundant). Reads [AuthRepository] via `context.watch` so it
///     re-renders automatically when auth state flips. Logging out triggers
///     the global router redirect, which kicks the user out of `/admin/*` if
///     that's where they were.
///   - **Home**: jumps straight to `/`, regardless of how deep into the
///     navigation stack the user is.
///
/// Drop-in for `Scaffold.appBar` because it implements [PreferredSizeWidget].
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
                // Order matters: navigate to home FIRST, then drop the
                // session. If we logged out first while still on /admin/*,
                // the router redirect would briefly send us to /login
                // before the explicit `go` lands us at /.
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
