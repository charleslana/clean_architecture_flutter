import 'package:flutter/foundation.dart';

/// Pre-defined error scenarios the [ErrorInjector] can simulate at runtime.
///
/// Used by [ErrorInjectingHttpService] (the http-layer decorator) to short-
/// circuit the real network call with a deterministic failure, so the UI's
/// error handling can be exercised without flaky reproduction in production.
enum ErrorMode {
  none('Off (real network)'),
  timeout('Timeout'),
  noInternet('No internet (SocketException)'),
  badRequest('400 Bad Request'),
  unauthorized('401 Unauthorized'),
  forbidden('403 Forbidden'),
  notFound('404 Not Found'),
  unprocessableEntity('422 Unprocessable Entity (unmapped)'),
  tooManyRequests('429 Too Many Requests'),
  serverError('500 Internal Server Error'),
  badGateway('502 Bad Gateway'),
  serviceUnavailable('503 Service Unavailable');

  const ErrorMode(this.label);

  final String label;

  bool get isActive => this != ErrorMode.none;

  /// HTTP status code for status-based errors, `null` for transport-level
  /// failures (timeout, no internet) and for [ErrorMode.none].
  int? get statusCode => switch (this) {
    ErrorMode.badRequest => 400,
    ErrorMode.unauthorized => 401,
    ErrorMode.forbidden => 403,
    ErrorMode.notFound => 404,
    ErrorMode.unprocessableEntity => 422,
    ErrorMode.tooManyRequests => 429,
    ErrorMode.serverError => 500,
    ErrorMode.badGateway => 502,
    ErrorMode.serviceUnavailable => 503,
    ErrorMode.none || ErrorMode.timeout || ErrorMode.noInternet => null,
  };
}

/// Holds the currently-active [ErrorMode]. Listened to by the debug banner
/// (so the dropdown reflects the live state) and read by
/// [ErrorInjectingHttpService] before each request.
class ErrorInjector extends ChangeNotifier {
  ErrorMode _mode = ErrorMode.none;

  ErrorMode get mode => _mode;

  set mode(ErrorMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }
}
