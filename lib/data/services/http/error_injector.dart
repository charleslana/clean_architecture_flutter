import 'package:flutter/foundation.dart';

enum ErrorMode {
  none('Off (real network)'),
  timeout('Timeout'),
  noInternet('No internet (SocketException)'),
  unexpectedShape('200 OK with malformed body (parse error)'),
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
    ErrorMode.none ||
    ErrorMode.timeout ||
    ErrorMode.noInternet ||
    ErrorMode.unexpectedShape => null,
  };
}

class ErrorInjector extends ChangeNotifier {
  ErrorMode _mode = ErrorMode.none;

  ErrorMode get mode => _mode;

  set mode(ErrorMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }
}
