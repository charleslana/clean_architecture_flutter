import 'dart:convert';

import 'package:clean_architecture_flutter/data/repositories/albums/albums_repository_remote.dart';
import 'package:clean_architecture_flutter/data/services/api/api_client.dart';
import 'package:clean_architecture_flutter/data/services/http/http_service.dart';
import 'package:clean_architecture_flutter/domain/models/album.dart';
import 'package:clean_architecture_flutter/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingHttpService implements HttpService {
  _RecordingHttpService(this._handler);

  final Future<HttpResponse> Function(String verb, Uri url, Object? body)
  _handler;

  final List<({String verb, Uri url, Object? body})> calls = [];

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) {
    calls.add((verb: 'GET', url: url, body: null));
    return _handler('GET', url, null);
  }

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    calls.add((verb: 'POST', url: url, body: body));
    return _handler('POST', url, body);
  }

  @override
  Future<HttpResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    calls.add((verb: 'PUT', url: url, body: body));
    return _handler('PUT', url, body);
  }

  @override
  Future<HttpResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    calls.add((verb: 'PATCH', url: url, body: body));
    return _handler('PATCH', url, body);
  }

  @override
  Future<HttpResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    calls.add((verb: 'DELETE', url: url, body: body));
    return _handler('DELETE', url, body);
  }

  @override
  void close() {}
}

void main() {
  group('AlbumsRepositoryRemote', () {
    test('getAlbums GETs /albums and maps DTOs to domain', () async {
      final http = _RecordingHttpService((verb, url, body) async {
        return const HttpResponse(
          statusCode: 200,
          body: '[{"id":1,"userId":1,"title":"a"}]',
        );
      });
      final repo = AlbumsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getAlbums();

      expect(result, isA<Ok<List<Album>>>());
      final albums = (result as Ok<List<Album>>).value;
      expect(albums, [const Album(id: 1, userId: 1, title: 'a')]);
      expect(http.calls.single.verb, 'GET');
      expect(http.calls.single.url.path, '/albums');
    });

    test('createAlbum POSTs userId and returns the new album', () async {
      final http = _RecordingHttpService((verb, url, body) async {
        return const HttpResponse(
          statusCode: 201,
          body: '{"id":101,"userId":7}',
        );
      });
      final repo = AlbumsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.createAlbum(userId: 7);

      expect(result, isA<Ok<Album>>());
      final album = (result as Ok<Album>).value;
      expect(album.id, 101);
      expect(album.userId, 7);
      expect(album.title, '');

      final call = http.calls.single;
      expect(call.verb, 'POST');
      expect(call.url.path, '/albums');
      expect(call.body, {'userId': 7});
    });

    test('patchAlbum PATCHes only the fields supplied', () async {
      final http = _RecordingHttpService((verb, url, body) async {
        final received = body as Map<String, Object>;
        final id = int.parse(url.pathSegments.last);
        return HttpResponse(
          statusCode: 200,
          body: jsonEncode({'id': id, 'userId': 1, ...received}),
        );
      });
      final repo = AlbumsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.patchAlbum(101, title: 'new title');

      expect(result, isA<Ok<Album>>());
      expect((result as Ok<Album>).value.title, 'new title');

      final call = http.calls.single;
      expect(call.verb, 'PATCH');
      expect(call.url.path, '/albums/101');
      expect(call.body, {'title': 'new title'});
    });

    test('replaceAlbum PUTs the full album', () async {
      final http = _RecordingHttpService((verb, url, body) async {
        return HttpResponse(statusCode: 200, body: jsonEncode(body));
      });
      final repo = AlbumsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.replaceAlbum(
        const Album(id: 5, userId: 2, title: 'replaced'),
      );

      expect(result, isA<Ok<Album>>());
      final call = http.calls.single;
      expect(call.verb, 'PUT');
      expect(call.url.path, '/albums/5');
      expect(call.body, {'id': 5, 'userId': 2, 'title': 'replaced'});
    });

    test('deleteAlbum DELETEs and returns Ok on 200', () async {
      final http = _RecordingHttpService((verb, url, body) async {
        return const HttpResponse(statusCode: 200, body: '{}');
      });
      final repo = AlbumsRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.deleteAlbum(42);

      expect(result, isA<Ok<void>>());
      final call = http.calls.single;
      expect(call.verb, 'DELETE');
      expect(call.url.path, '/albums/42');
    });

    test(
      'any HTTP failure becomes Result.error (no exception leaks)',
      () async {
        final http = _RecordingHttpService(
          (verb, url, body) async =>
              const HttpResponse(statusCode: 500, body: ''),
        );
        final repo = AlbumsRepositoryRemote(
          apiClient: ApiClient(httpService: http),
        );

        expect(await repo.getAlbums(), isA<Error<List<Album>>>());
        expect(await repo.createAlbum(userId: 1), isA<Error<Album>>());
        expect(await repo.patchAlbum(1, title: 'x'), isA<Error<Album>>());
        expect(
          await repo.replaceAlbum(const Album(id: 1, userId: 1, title: 't')),
          isA<Error<Album>>(),
        );
        expect(await repo.deleteAlbum(1), isA<Error<void>>());
      },
    );
  });
}
