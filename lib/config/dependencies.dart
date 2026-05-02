import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/albums/albums_repository.dart';
import '../data/repositories/albums/albums_repository_remote.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_mock.dart';
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
import '../data/services/http/logging_http_service.dart';

List<SingleChildWidget> get providersRemote => [
  ChangeNotifierProvider<ErrorInjector>(create: (_) => ErrorInjector()),

  ChangeNotifierProvider<AuthRepository>(create: (_) => AuthRepositoryMock()),

  Provider<HttpService>(
    create: (context) {
      HttpService service = HttpServiceHttp();
      if (kDebugMode) {
        service = ErrorInjectingHttpService(
          inner: service,
          injector: context.read<ErrorInjector>(),
        );
        service = LoggingHttpService(inner: service);
      }
      return service;
    },
    dispose: (_, service) => service.close(),
  ),
  Provider<ApiClient>(
    create: (context) => ApiClient(httpService: context.read<HttpService>()),
  ),

  Provider<PostsRepository>(
    create: (context) =>
        PostsRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),

  Provider<CommentsRepository>(
    create: (context) =>
        CommentsRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),

  Provider<UsersRepository>(
    create: (context) =>
        UsersRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),

  Provider<AlbumsRepository>(
    create: (context) =>
        AlbumsRepositoryRemote(apiClient: context.read<ApiClient>()),
  ),
];
