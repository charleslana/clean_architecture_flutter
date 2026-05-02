import '../../../utils/result.dart';
import 'auth_repository.dart';

/// In-memory mock [AuthRepository]: only `admin` / `admin` is accepted.
///
/// Real implementations would talk to a backend (and likely persist the token
/// in secure storage). Swapping this out for a real impl is a one-line change
/// in `dependencies.dart`.
class AuthRepositoryMock extends AuthRepository {
  bool _isAuthenticated = false;
  String? _username;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get username => _username;

  @override
  Future<Result<void>> login({
    required String username,
    required String password,
  }) async {
    // Brief delay so the spinner is visible — feels like a real round-trip.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (username == 'admin' && password == 'admin') {
      _isAuthenticated = true;
      _username = username;
      notifyListeners();
      return const Result.ok(null);
    }
    return const Result<void>.error(InvalidCredentialsException());
  }

  @override
  void logout() {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}
