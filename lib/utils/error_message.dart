import 'dart:async';
import 'dart:io';

import '../data/services/api/api_client.dart';
import '../data/services/api/json_field.dart';

String errorMessageFor(Object? error) {
  if (error == null) return 'Unknown error';
  if (error is TimeoutException) return 'Timeout';
  if (error is SocketException) return 'No internet';
  if (error is HttpException) {
    final code = error.statusCode;
    final reason = _reasonFor(code);
    return reason != null ? '$code $reason' : '$code (unmapped status)';
  }

  if (error is FieldShapeException) {
    return 'Missing/invalid field: "${error.key}"';
  }

  if (error is TypeError) return 'Unexpected data shape';
  return error.toString();
}

String? _reasonFor(int code) => switch (code) {
  400 => 'Bad Request',
  401 => 'Unauthorized',
  403 => 'Forbidden',
  404 => 'Not Found',
  429 => 'Too Many Requests',
  500 => 'Internal Server Error',
  502 => 'Bad Gateway',
  503 => 'Service Unavailable',
  _ => null,
};
