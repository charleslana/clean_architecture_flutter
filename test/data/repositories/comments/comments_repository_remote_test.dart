import 'package:clean_architecture_flutter/data/repositories/comments/comments_repository_remote.dart';
import 'package:clean_architecture_flutter/data/services/api/api_client.dart';
import 'package:clean_architecture_flutter/data/services/http/http_service.dart';
import 'package:clean_architecture_flutter/domain/models/comment.dart';
import 'package:clean_architecture_flutter/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('CommentsRepositoryRemote', () {
    test('getCommentsForPost maps API model to domain on 200', () async {
      final http = FakeHttpService(
        onGet: (url) async {
          expect(url.path, '/posts/1/comments');
          return const HttpResponse(
            statusCode: 200,
            body: '''
            [{
              "postId": 1,
              "id": 10,
              "name": "n",
              "email": "e@x.com",
              "body": "b"
            }]
            ''',
          );
        },
      );
      final repo = CommentsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getCommentsForPost(1);

      expect(result, isA<Ok<List<Comment>>>());
      final comments = (result as Ok<List<Comment>>).value;
      expect(comments.first.id, 10);
      expect(comments.first.email, 'e@x.com');
    });

    test('getCommentsForPost returns Error on non-200', () async {
      final http = FakeHttpService(
        onGet: (_) async => const HttpResponse(statusCode: 500, body: ''),
      );
      final repo = CommentsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getCommentsForPost(1);

      expect(result, isA<Error<List<Comment>>>());
    });
  });
}
