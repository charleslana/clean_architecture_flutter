import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/albums/albums_repository.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/comments/comments_repository.dart';
import '../data/repositories/posts/posts_repository.dart';
import '../data/repositories/users/users_repository.dart';
import '../ui/admin/widgets/admin_home_screen.dart';
import '../ui/albums/album_draft.dart';
import '../ui/albums/view_models/albums_list_viewmodel.dart';
import '../ui/albums/view_models/create_album_step2_viewmodel.dart';
import '../ui/albums/view_models/edit_album_viewmodel.dart';
import '../ui/albums/widgets/albums_list_screen.dart';
import '../ui/albums/widgets/create_album_step1_screen.dart';
import '../ui/albums/widgets/create_album_step2_screen.dart';
import '../ui/albums/widgets/edit_album_screen.dart';
import '../ui/auth/view_models/login_viewmodel.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/core/ui/error_banner.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/posts/view_models/post_detail_viewmodel.dart';
import '../ui/posts/view_models/posts_list_viewmodel.dart';
import '../ui/posts/widgets/post_detail_screen.dart';
import '../ui/posts/widgets/posts_list_screen.dart';
import '../ui/users/view_models/users_list_viewmodel.dart';
import '../ui/users/widgets/users_list_screen.dart';
import 'routes.dart';

/// Builds the [GoRouter] with all the auth wiring.
///
/// Why a function (and not a top-level `final`)? Because the router needs the
/// [AuthRepository] for two things:
///   - `refreshListenable: authRepository` — re-runs the redirect whenever
///     login/logout happens, so the user bounces in/out of /admin without any
///     screen having to navigate explicitly.
///   - `redirect: (...)` — the global gate that protects every `/admin/*`
///     route. The closure reads `authRepository.isAuthenticated` directly
///     (it's captured in scope), so the redirect's logic stays self-contained
///     and testable.
GoRouter buildRouter(AuthRepository authRepository) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authRepository,
    // Tree-shaken out of release. `debugLogDiagnostics` enables go_router's
    // own verbose logs; navigation logging is done inside `redirect` because
    // that's the one callback that sees every navigation by URL (the
    // `ShellRoute` we use has a nested Navigator, so a top-level
    // `NavigatorObserver` would miss most pushes).
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      // Single gate: /admin/* requires auth. We pass the requested URL as
      // `?from=...` so [LoginScreen] can bounce the user back there after
      // a successful login. Where the user goes after login/logout is
      // decided by the calling screen (no isLogin clause here) so the
      // redirect never races against `context.go(...)` in the View.
      final goingTo = state.matchedLocation;

      // Debug-only navigation log. `redirect` runs on every navigation
      // (including pops, since they trigger a re-resolve of the new
      // location), so this captures the user's full path through the app.
      if (kDebugMode) {
        final query = state.uri.query;
        debugPrint('[router] → $goingTo${query.isNotEmpty ? '?$query' : ''}');
      }

      if (goingTo.startsWith(Routes.adminHome) &&
          !authRepository.isAuthenticated) {
        return '${Routes.login}?from=$goingTo';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // The ErrorBanner is a debug-only tool: tree-shaken out of release
          // builds because `kDebugMode` is a compile-time const.
          return ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                if (kDebugMode)
                  const SafeArea(bottom: false, child: ErrorBanner()),
                Expanded(
                  child: kDebugMode
                      ? MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: child,
                        )
                      : child,
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (BuildContext context, GoRouterState state) =>
                const HomeScreen(),
          ),
          GoRoute(
            path: Routes.login,
            builder: (BuildContext context, GoRouterState state) {
              // `from` is set by the redirect when a protected route
              // bounced the user here — captures the URL they were trying
              // to reach so login can send them back there.
              final from = state.uri.queryParameters['from'];
              return LoginScreen(
                viewModel: LoginViewModel(
                  authRepository: context.read<AuthRepository>(),
                ),
                from: from,
              );
            },
          ),
          GoRoute(
            path: Routes.posts,
            builder: (BuildContext context, GoRouterState state) {
              return PostsListScreen(
                viewModel: PostsListViewModel(
                  postsRepository: context.read<PostsRepository>(),
                ),
              );
            },
          ),
          GoRoute(
            path: Routes.postDetailPattern,
            builder: (BuildContext context, GoRouterState state) {
              final id = int.parse(state.pathParameters['id']!);
              return PostDetailScreen(
                viewModel: PostDetailViewModel(
                  postsRepository: context.read<PostsRepository>(),
                  commentsRepository: context.read<CommentsRepository>(),
                  postId: id,
                ),
              );
            },
          ),
          GoRoute(
            path: Routes.users,
            builder: (BuildContext context, GoRouterState state) {
              return UsersListScreen(
                viewModel: UsersListViewModel(
                  usersRepository: context.read<UsersRepository>(),
                ),
              );
            },
          ),

          // ── Admin · Albums CRUD (protected by the redirect above) ───────
          GoRoute(
            path: Routes.adminHome,
            builder: (BuildContext context, GoRouterState state) =>
                const AdminHomeScreen(),
          ),
          GoRoute(
            path: Routes.adminAlbums,
            builder: (BuildContext context, GoRouterState state) {
              return AlbumsListScreen(
                viewModel: AlbumsListViewModel(
                  albumsRepository: context.read<AlbumsRepository>(),
                ),
              );
            },
          ),
          GoRoute(
            path: Routes.adminAlbumsCreate,
            builder: (BuildContext context, GoRouterState state) =>
                const CreateAlbumStep1Screen(),
          ),
          GoRoute(
            path: Routes.adminAlbumsCreateStep2,
            redirect: (BuildContext context, GoRouterState state) {
              if (state.extra is! AlbumDraft) {
                return Routes.adminAlbumsCreate;
              }
              return null;
            },
            builder: (BuildContext context, GoRouterState state) {
              final draft = state.extra! as AlbumDraft;
              return CreateAlbumStep2Screen(
                viewModel: CreateAlbumStep2ViewModel(
                  albumsRepository: context.read<AlbumsRepository>(),
                  draft: draft,
                ),
              );
            },
          ),
          GoRoute(
            path: Routes.adminAlbumsEditPattern,
            builder: (BuildContext context, GoRouterState state) {
              final id = int.parse(state.pathParameters['id']!);
              return EditAlbumScreen(
                viewModel: EditAlbumViewModel(
                  albumsRepository: context.read<AlbumsRepository>(),

                  albumId: id,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
