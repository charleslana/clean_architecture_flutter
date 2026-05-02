import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    login = Command1(_login);
  }

  final AuthRepository _authRepository;

  late final Command1<void, ({String username, String password})> login;

  // ── UI state ────────────────────────────────────────────────────────────
  // Whether the password field is rendered visible (eye toggle). Lives here
  // (not in the View's State) because the architecture guide places UI state
  // in the ViewModel — keeps the View dumb and the toggle unit-testable.
  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  Future<Result<void>> _login(({String username, String password}) creds) {
    return _authRepository.login(
      username: creds.username,
      password: creds.password,
    );
  }
}
