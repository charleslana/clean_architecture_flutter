import 'package:clean_architecture_flutter/data/repositories/users/users_repository_remote.dart';
import 'package:clean_architecture_flutter/data/services/api/api_client.dart';
import 'package:clean_architecture_flutter/data/services/api/json_field.dart';
import 'package:clean_architecture_flutter/data/services/http/http_service.dart';
import 'package:clean_architecture_flutter/domain/models/user.dart';
import 'package:clean_architecture_flutter/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('UsersRepositoryRemote', () {
    test('getUsers maps API model (with records) to domain', () async {
      final http = FakeHttpService(
        onGet: (url) async {
          expect(url.path, '/users');
          return const HttpResponse(
            statusCode: 200,
            body: '''
            [{
              "id": 1,
              "name": "Alice",
              "username": "alice",
              "email": "alice@example.com",
              "phone": "111",
              "website": "alice.example.com",
              "address": {"city": "Paris", "street": "Rue", "suite": "1A"},
              "company": {"name": "Acme", "catchPhrase": "go"}
            }]
            ''',
          );
        },
      );
      final repo = UsersRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getUsers();

      expect(result, isA<Ok<List<User>>>());
      final users = (result as Ok<List<User>>).value;
      expect(users.first.address.city, 'Paris');
      expect(users.first.company.name, 'Acme');
    });

    test('getUsers returns Error on transport failure', () async {
      final http = FakeHttpService(
        onGet: (_) async => throw Exception('offline'),
      );
      final repo = UsersRepositoryRemote(
        apiClient: ApiClient(httpService: http),
      );

      final result = await repo.getUsers();

      expect(result, isA<Error<List<User>>>());
    });

    test(
      'getUsers returns Error on PARSE failure (backend dropped a required field)',
      () async {
        // Server responded 200 OK but `email` is missing — `as String` in the
        // DTO will throw a TypeError. Without the broadened `on Object` catch
        // in the repository, this would crash silently and the UI would just
        // show an empty list.
        final http = FakeHttpService(
          onGet: (_) async => const HttpResponse(
            statusCode: 200,
            body: '''
            [{
              "id": 1,
              "name": "Alice",
              "username": "alice",
              "address": {},
              "company": {}
            }]
            ''',
          ),
        );
        final repo = UsersRepositoryRemote(
          apiClient: ApiClient(httpService: http),
        );

        final result = await repo.getUsers();

        expect(result, isA<Error<List<User>>>());
        final error = (result as Error<List<User>>).error;
        // The DTO uses `jsonRequired<T>` so the failure carries the key name
        // — not just a bare TypeError — and the UI can surface it.
        expect(error, isA<FieldShapeException>());
        expect((error as FieldShapeException).key, 'email');
      },
    );
  });
}
