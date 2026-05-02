import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/comments/comments_repository.dart';
import '../data/repositories/posts/posts_repository.dart';
import '../data/repositories/users/users_repository.dart';
import '../ui/core/ui/error_banner.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/posts/view_models/post_detail_viewmodel.dart';
import '../ui/posts/view_models/posts_list_viewmodel.dart';
import '../ui/posts/widgets/post_detail_screen.dart';
import '../ui/posts/widgets/posts_list_screen.dart';
import '../ui/users/view_models/users_list_viewmodel.dart';
import '../ui/users/widgets/users_list_screen.dart';
import 'routes.dart';

/// Router built with `go_router` (the package recommended by the Flutter team
/// in the architecture guide).
///
/// Top level is a [ShellRoute] that wraps every screen with a persistent
/// [ErrorBanner] strip — the user can pick a simulated error mode at any
/// time, and the next API call short-circuits with that failure (timeout,
/// SocketException, 4xx/5xx). The screens themselves don't change.
///
/// Every nested route is reached with `context.push`, so each [Scaffold]
/// auto-adds a back arrow that walks the user back to the home screen.
///
/// ViewModels are instantiated here, in the route's `builder`, so each one
/// is scoped to a single screen.
final GoRouter router = GoRouter(
  initialLocation: Routes.home,
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              const SafeArea(bottom: false, child: ErrorBanner()),
              Expanded(
                // Strip the top inset that the SafeArea above already
                // consumed, so the inner Scaffold's AppBar doesn't add it
                // again and end up double-padded.
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: child,
                ),
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
      ],
    ),
  ],
);
