import 'package:clean_architecture_flutter/ui/users/view_models/users_list_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils/fakes.dart';

void main() {
  group('UsersListViewModel', () {
    test('exposes users on success', () async {
      final repo = FakeUsersRepository();

      final vm = UsersListViewModel(usersRepository: repo);
      await Future<void>.delayed(Duration.zero);

      expect(repo.getUsersCalls, 1);
      expect(vm.users, [fakeUser1, fakeUser2]);
    });

    test('clears users on failure', () async {
      final repo = FakeUsersRepository(fail: true);

      final vm = UsersListViewModel(usersRepository: repo);
      await Future<void>.delayed(Duration.zero);

      expect(vm.load.error, isTrue);
      expect(vm.users, isEmpty);
    });
  });
}
