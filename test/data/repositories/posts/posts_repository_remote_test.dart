import 'package:clean_architecture_flutter/data/repositories/posts/posts_repository_remote.dart';
import 'package:clean_architecture_flutter/data/services/api/api_client.dart';
import 'package:clean_architecture_flutter/data/services/http/http_service.dart';
import 'package:clean_architecture_flutter/domain/models/post.dart';
import 'package:clean_architecture_flutter/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('PostsRepositoryRemote', () {
    test('getPosts returns mapped domain models on 200', () async {
      final http = FakeHttpService(
        onGet: (url) async {
          expect(url.path, '/posts');
          return const HttpResponse(
            statusCode: 200,
            body: '[{"id":1,"userId":10,"title":"t","body":"b"}]',
          );
        },
      );
      final repo = PostsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getPosts();

      expect(result, isA<Ok<List<Post>>>());
      final posts = (result as Ok<List<Post>>).value;
      expect(posts, hasLength(1));
      expect(posts.first.id, 1);
      expect(posts.first.title, 't');
    });

    test('getPosts returns Error when API returns non-200', () async {
      final http = FakeHttpService(
        onGet: (_) async => const HttpResponse(statusCode: 500, body: 'nope'),
      );
      final repo = PostsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getPosts();

      expect(result, isA<Error<List<Post>>>());
    });

    test('getPost returns the requested post', () async {
      final http = FakeHttpService(
        onGet: (url) async {
          expect(url.path, '/posts/42');
          return const HttpResponse(
            statusCode: 200,
            body: '{"id":42,"userId":1,"title":"hi","body":"there"}',
          );
        },
      );
      final repo = PostsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getPost(42);

      expect(result, isA<Ok<Post>>());
      expect((result as Ok<Post>).value.id, 42);
    });
  });
}
