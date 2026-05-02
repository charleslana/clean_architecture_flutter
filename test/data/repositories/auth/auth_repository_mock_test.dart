import 'package:clean_architecture_flutter/data/repositories/auth/auth_repository.dart';
import 'package:clean_architecture_flutter/data/repositories/auth/auth_repository_mock.dart';
import 'package:clean_architecture_flutter/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepositoryMock', () {
    test('starts unauthenticated', () {
      final repo = AuthRepositoryMock();
      expect(repo.isAuthenticated, isFalse);
      expect(repo.username, isNull);
    });

    test('login with admin/admin succeeds and notifies', () async {
      final repo = AuthRepositoryMock();
      var notifyCount = 0;
      repo.addListener(() => notifyCount++);

      final result = await repo.login(username: 'admin', password: 'admin');

      expect(result, isA<Ok<void>>());
      expect(repo.isAuthenticated, isTrue);
      expect(repo.username, 'admin');
      expect(notifyCount, 1);
    });

    test(
      'login with wrong creds returns InvalidCredentialsException',
      () async {
        final repo = AuthRepositoryMock();
        var notifyCount = 0;
        repo.addListener(() => notifyCount++);

        final result = await repo.login(username: 'foo', password: 'bar');

        expect(result, isA<Error<void>>());
        expect(
          (result as Error<void>).error,
          isA<InvalidCredentialsException>(),
        );
        expect(repo.isAuthenticated, isFalse);
        expect(notifyCount, 0); // no state change → no notify
      },
    );

    test('logout flips state and notifies (only when authenticated)', () async {
      final repo = AuthRepositoryMock();
      await repo.login(username: 'admin', password: 'admin');

      var notifyCount = 0;
      repo.addListener(() => notifyCount++);

      repo.logout();
      expect(repo.isAuthenticated, isFalse);
      expect(repo.username, isNull);
      expect(notifyCount, 1);

      // Calling logout again is a no-op (no listeners notified twice).
      repo.logout();
      expect(notifyCount, 1);
    });
  });
}
