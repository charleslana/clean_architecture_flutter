import '../../../utils/debug_log.dart';
import 'http_service.dart';

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
    debugLog('http', '→ $verb $url');
    if (headers != null && headers.isNotEmpty) {
      debugLog('http', '  req headers: $headers');
    }
    if (body != null) {
      debugLog('http', '  req body:    ${_truncate(body.toString())}');
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await call();
      debugLog(
        'http',
        '← $verb $url ${response.statusCode} '
            '(${stopwatch.elapsedMilliseconds}ms)',
      );
      if (response.headers.isNotEmpty) {
        debugLog('http', '  res headers: ${response.headers}');
      }
      if (response.body.isNotEmpty) {
        debugLog('http', '  res body:    ${_truncate(response.body)}');
      }
      return response;
    } catch (e) {
      debugLog(
        'http',
        '✗ $verb $url threw $e '
            '(${stopwatch.elapsedMilliseconds}ms)',
      );
      rethrow;
    }
  }

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
