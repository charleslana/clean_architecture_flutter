import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/comments/comments_repository.dart';
import '../data/repositories/comments/comments_repository_remote.dart';
import '../data/repositories/posts/posts_repository.dart';
import '../data/repositories/posts/posts_repository_remote.dart';
import '../data/repositories/users/users_repository.dart';
import '../data/repositories/users/users_repository_remote.dart';
import '../data/services/api/api_client.dart';
import '../data/services/http/error_injecting_http_service.dart';
import '../data/services/http/error_injector.dart';
import '../data/services/http/http_service.dart';
import '../data/services/http/http_service_http.dart';

/// Dependency-injection wiring for the app.
///
/// Layout follows the architecture guide case study:
///   - services are registered first (cross-feature, shared),
///   - repositories depend on services and are exposed by their abstract type
///     (so views/view_models receive interfaces, not concrete classes),
///   - repositories are grouped per FEATURE: `posts` and `users` are the two
///     features of this sample — see `lib/data/repositories/<feature>/` and
///     `lib/ui/<feature>/`,
///   - view_models are not registered here — they are created in the router
///     so they live exactly as long as the screen that owns them.
///
/// The HTTP stack is composed as a chain:
///
///     ApiClient → ErrorInjectingHttpService → HttpServiceHttp → package:http
///
/// `ApiClient` only knows about [HttpService]; the only file that imports
/// `package:http` is [HttpServiceHttp]. Adding a debug interceptor (here, the
/// error injector) doesn't leak into any other layer.
List<SingleChildWidget> get providersRemote => [
  // ── Debug helper (drives the ErrorBanner UI and the decorator below) ─
  ChangeNotifierProvider<ErrorInjector>(create: (_) => ErrorInjector()),

  // ── Shared services ──────────────────────────────────────────────────
  Provider<HttpService>(
    create: (context) => ErrorInjectingHttpService(
      inner: HttpServiceHttp(),
      injector: context.read<ErrorInjector>(),
    ),
    dispose: (_, service) => service.close(),
  ),
  Provider<ApiClient>(
    create: (context) => ApiClient(httpService: context.read<HttpService>()),
  ),

  // ── Feature: posts ───────────────────────────────────────────────────
  Provider<PostsRepository>(
    create: (context) =>
        PostsRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),

  // ── Feature: comments (used inside the post detail screen) ──────────
  Provider<CommentsRepository>(
    create: (context) =>
        CommentsRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),

  // ── Feature: users ───────────────────────────────────────────────────
  Provider<UsersRepository>(
    create: (context) =>
        UsersRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),
];
