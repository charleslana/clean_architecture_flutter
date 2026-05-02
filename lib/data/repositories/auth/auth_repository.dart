import 'package:flutter/foundation.dart';

import '../../../utils/result.dart';

/// Single source of truth for the user's authentication state.
///
/// Extends [ChangeNotifier] so that go_router's `refreshListenable` can hook
/// into login/logout events and automatically re-evaluate its `redirect`
/// (sending the user to /login when they log out, bouncing them back to the
/// originally-requested route when they log in). The same `ChangeNotifier`
/// is exposed via `ChangeNotifierProvider`, so any widget that needs to
/// react to auth changes (e.g. the [DefaultAppBar] login/logout icon) can
/// `context.watch<AuthRepository>()`.
abstract class AuthRepository extends ChangeNotifier {
  bool get isAuthenticated;
  String? get username;

  /// Returns `Result.ok(null)` on success, or `Result.error(...)` carrying
  /// an [InvalidCredentialsException] / network exception otherwise.
  Future<Result<void>> login({
    required String username,
    required String password,
  });

  void logout();
}

/// Thrown by an [AuthRepository.login] call when the credentials are wrong.
/// Implements [Exception] so it flows through `errorMessageFor` cleanly.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();

  @override
  String toString() => 'Invalid credentials';
}
