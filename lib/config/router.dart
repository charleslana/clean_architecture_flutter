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
import '../ui/core/ui/scoped_view_model.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/posts/view_models/post_detail_viewmodel.dart';
import '../ui/posts/view_models/posts_list_viewmodel.dart';
import '../ui/posts/widgets/post_detail_screen.dart';
import '../ui/posts/widgets/posts_list_screen.dart';
import '../ui/users/view_models/users_list_viewmodel.dart';
import '../ui/users/widgets/users_list_screen.dart';
import '../utils/debug_log.dart';
import 'debug/shell_nav_logger.dart';
import 'routes.dart';

GoRouter buildRouter(AuthRepository authRepository) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: authRepository,
    debugLogDiagnostics: kDebugMode,
    redirect: (BuildContext context, GoRouterState state) {
      final goingTo = state.matchedLocation;

      final query = state.uri.query;
      debugLog('router', '→ $goingTo${query.isNotEmpty ? '?$query' : ''}');

      if (goingTo.startsWith(Routes.adminHome) &&
          !authRepository.isAuthenticated) {
        return '${Routes.login}?from=$goingTo';
      }
      return null;
    },
    routes: [
      ShellRoute(
        observers: kDebugMode ? [ShellNavLogger()] : const [],
        builder: (BuildContext context, GoRouterState state, Widget child) {
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
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.login,
            builder: (context, state) {
              final from = state.uri.queryParameters['from'];
              return ScopedViewModel<LoginViewModel>(
                create: (ctx) =>
                    LoginViewModel(authRepository: ctx.read<AuthRepository>()),
                builder: (ctx, vm) => LoginScreen(viewModel: vm, from: from),
              );
            },
          ),
          GoRoute(
            path: Routes.posts,
            builder: (context, state) => ScopedViewModel<PostsListViewModel>(
              create: (ctx) => PostsListViewModel(
                postsRepository: ctx.read<PostsRepository>(),
              ),
              builder: (ctx, vm) => PostsListScreen(viewModel: vm),
            ),
          ),
          GoRoute(
            path: Routes.postDetailPattern,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ScopedViewModel<PostDetailViewModel>(
                create: (ctx) => PostDetailViewModel(
                  postsRepository: ctx.read<PostsRepository>(),
                  commentsRepository: ctx.read<CommentsRepository>(),
                  postId: id,
                ),
                builder: (ctx, vm) => PostDetailScreen(viewModel: vm),
              );
            },
          ),
          GoRoute(
            path: Routes.users,
            builder: (context, state) => ScopedViewModel<UsersListViewModel>(
              create: (ctx) => UsersListViewModel(
                usersRepository: ctx.read<UsersRepository>(),
              ),
              builder: (ctx, vm) => UsersListScreen(viewModel: vm),
            ),
          ),

          GoRoute(
            path: Routes.adminHome,
            builder: (context, state) => const AdminHomeScreen(),
          ),
          GoRoute(
            path: Routes.adminAlbums,
            builder: (context, state) => ScopedViewModel<AlbumsListViewModel>(
              create: (ctx) => AlbumsListViewModel(
                albumsRepository: ctx.read<AlbumsRepository>(),
              ),
              builder: (ctx, vm) => AlbumsListScreen(viewModel: vm),
            ),
          ),
          GoRoute(
            path: Routes.adminAlbumsCreate,
            builder: (context, state) => const CreateAlbumStep1Screen(),
          ),
          GoRoute(
            path: Routes.adminAlbumsCreateStep2,
            redirect: (context, state) {
              if (state.extra is! AlbumDraft) return Routes.adminAlbumsCreate;
              return null;
            },
            builder: (context, state) {
              final draft = state.extra! as AlbumDraft;
              return ScopedViewModel<CreateAlbumStep2ViewModel>(
                create: (ctx) => CreateAlbumStep2ViewModel(
                  albumsRepository: ctx.read<AlbumsRepository>(),
                  draft: draft,
                ),
                builder: (ctx, vm) => CreateAlbumStep2Screen(viewModel: vm),
              );
            },
          ),
          GoRoute(
            path: Routes.adminAlbumsEditPattern,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ScopedViewModel<EditAlbumViewModel>(
                create: (ctx) => EditAlbumViewModel(
                  albumsRepository: ctx.read<AlbumsRepository>(),
                  albumId: id,
                ),
                builder: (ctx, vm) => EditAlbumScreen(viewModel: vm),
              );
            },
          ),
        ],
      ),
    ],
  );
}
