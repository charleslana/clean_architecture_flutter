import 'dart:async';
import 'dart:io';

import '../data/services/api/api_client.dart';

/// Maps low-level exceptions thrown by the data layer into short
/// user-friendly labels for the UI.
///
/// Returns a generic fallback for anything we don't recognize, so unexpected
/// failures (e.g. a status code that isn't in the table below — try simulating
/// 422 in the debug banner) still surface readable information instead of
/// `Instance of 'HttpException'`.
String errorMessageFor(Object? error) {
  if (error == null) return 'Unknown error';
  if (error is TimeoutException) return 'Timeout';
  if (error is SocketException) return 'No internet';
  if (error is HttpException) {
    final code = error.statusCode;
    final reason = _reasonFor(code);
    return reason != null ? '$code $reason' : '$code (unmapped status)';
  }
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
