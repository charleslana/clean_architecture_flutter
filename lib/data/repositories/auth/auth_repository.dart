import 'package:flutter/foundation.dart';

import '../../../utils/result.dart';

abstract class AuthRepository extends ChangeNotifier {
  bool get isAuthenticated;
  String? get username;

  Future<Result<void>> login({
    required String username,
    required String password,
  });

  void logout();
}

class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();

  @override
  String toString() => 'Invalid credentials';
}
