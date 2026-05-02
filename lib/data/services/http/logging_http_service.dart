import 'package:flutter/foundation.dart';

import 'http_service.dart';

/// Debug-only [HttpService] decorator that logs request/response info via
/// [debugPrint]. No-op in release because `kDebugMode` is a compile-time
/// const and the bodies tree-shake out.
///
/// Logs include:
///   - **Request**: full URL, headers, body
///   - **Response**: status code, latency, headers, body (truncated)
///   - **Error**: thrown exception + latency
///
/// Stacks like the [ErrorInjectingHttpService]: sit it ABOVE the error
/// injector in the chain so simulated errors are also logged. Recommended
/// composition (in `dependencies.dart`):
///
///     ApiClient
///        ↓
///     LoggingHttpService           ◀── logs every call (real or simulated)
///        ↓
///     ErrorInjectingHttpService    ◀── may short-circuit with simulated err
///        ↓
///     HttpServiceHttp              ◀── real network
class LoggingHttpService implements HttpService {
  LoggingHttpService({required HttpService inner}) : _inner = inner;

  final HttpService _inner;

  Future<HttpResponse> _logCall(
    String verb,
    Uri url,
    Map<String, String>? headers,
    Object? body,
    Future<HttpResponse> Function() call,
  ) async {
    if (!kDebugMode) return call();

    debugPrint('[http] → $verb $url');
    if (headers != null && headers.isNotEmpty) {
      debugPrint('[http]   req headers: $headers');
    }
    if (body != null) {
      debugPrint('[http]   req body:    ${_truncate(body.toString())}');
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await call();
      debugPrint(
        '[http] ← $verb $url ${response.statusCode} '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      if (response.headers.isNotEmpty) {
        debugPrint('[http]   res headers: ${response.headers}');
      }
      if (response.body.isNotEmpty) {
        debugPrint('[http]   res body:    ${_truncate(response.body)}');
      }
      return response;
    } catch (e) {
      debugPrint(
        '[http] ✗ $verb $url threw $e '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      rethrow;
    }
  }

  /// Truncate large payloads so console output stays usable. Bump [max] if
  /// you need to inspect a full response body during debugging.
  static String _truncate(String s, {int max = 500}) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}… (${s.length - max} more chars)';
  }

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) => _logCall(
    'GET',
    url,
    headers,
    null,
    () => _inner.get(url, headers: headers),
  );

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _logCall(
    'POST',
    url,
    headers,
    body,
    () => _inner.post(url, headers: headers, body: body),
  );

  @override
  Future<HttpResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _logCall(
    'PUT',
    url,
    headers,
    body,
    () => _inner.put(url, headers: headers, body: body),
  );

  @override
  Future<HttpResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _logCall(
    'PATCH',
    url,
    headers,
    body,
    () => _inner.patch(url, headers: headers, body: body),
  );

  @override
  Future<HttpResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _logCall(
    'DELETE',
    url,
    headers,
    body,
    () => _inner.delete(url, headers: headers, body: body),
  );

  @override
  void close() => _inner.close();
}
