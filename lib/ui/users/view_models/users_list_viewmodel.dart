import 'package:flutter/foundation.dart';

import '../../../data/repositories/users/users_repository.dart';
import '../../../domain/models/user.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class UsersListViewModel extends ChangeNotifier {
  UsersListViewModel({required UsersRepository usersRepository})
    : _usersRepository = usersRepository {
    load = Command0(_load)..execute();
  }

  final UsersRepository _usersRepository;

  List<User> _users = const [];
  List<User> get users => _users;

  late final Command0<List<User>> load;

  Future<Result<List<User>>> _load() async {
    final result = await _usersRepository.getUsers();
    if (result is Ok<List<User>>) {
      _users = result.value;
    } else {
      _users = const [];
    }
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }
}
