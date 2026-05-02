import 'package:clean_architecture_flutter/data/repositories/auth/auth_repository.dart';
import 'package:clean_architecture_flutter/ui/auth/view_models/login_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('LoginViewModel', () {
    test('successful login flips repository state', () async {
      final repo = FakeAuthRepository();
      final vm = LoginViewModel(authRepository: repo);

      await vm.login.execute((username: 'admin', password: 'admin'));

      expect(vm.login.completed, isTrue);
      expect(repo.isAuthenticated, isTrue);
      expect(repo.username, 'admin');
      expect(repo.loginCalls, 1);
    });

    test('wrong credentials surface as Command.error', () async {
      final repo = FakeAuthRepository();
      final vm = LoginViewModel(authRepository: repo);

      await vm.login.execute((username: 'admin', password: 'wrong'));

      expect(vm.login.error, isTrue);
      expect(repo.isAuthenticated, isFalse);

      final result = vm.login.result;
      expect(result, isNotNull);
      expect((result! as dynamic).error, isA<InvalidCredentialsException>());
    });

    test('togglePasswordVisibility flips passwordVisible and notifies', () {
      final vm = LoginViewModel(authRepository: FakeAuthRepository());
      var notifyCount = 0;
      vm.addListener(() => notifyCount++);

      expect(vm.passwordVisible, isFalse);

      vm.togglePasswordVisibility();
      expect(vm.passwordVisible, isTrue);
      expect(notifyCount, 1);

      vm.togglePasswordVisibility();
      expect(vm.passwordVisible, isFalse);
      expect(notifyCount, 2);
    });
  });
}
