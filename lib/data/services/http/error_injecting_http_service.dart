import 'dart:async';
import 'dart:io';

import 'error_injector.dart';
import 'http_service.dart';

/// Decorator over an [HttpService] that consults an [ErrorInjector] before
/// every request and may short-circuit the call with a simulated failure.
///
/// Sits between the real [HttpService] and the [ApiClient]:
///   - `ErrorMode.none` → every call passes through to the inner service
///     unchanged,
///   - any other mode → the decorator throws/returns the simulated failure
///     **exactly** as it would arrive from the network. The repository sees a
///     real `SocketException`, `TimeoutException`, or non-2xx response and
///     reacts via its existing `try/catch` → `Result.error` path. No special
///     branch is added anywhere upstream.
class ErrorInjectingHttpService implements HttpService {
  ErrorInjectingHttpService({required this.inner, required this.injector});

  final HttpService inner;
  final ErrorInjector injector;

  Future<HttpResponse> _maybeInject(
    Future<HttpResponse> Function() realCall,
  ) async {
    final mode = injector.mode;
    if (!mode.isActive) return realCall();

    if (mode == ErrorMode.timeout) {
      // Brief delay so the View shows a spinner before the failure.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      throw TimeoutException('Simulated timeout');
    }
    if (mode == ErrorMode.noInternet) {
      throw const SocketException('Simulated: no internet');
    }
    final code = mode.statusCode!;
    return HttpResponse(
      statusCode: code,
      body: '{"error":"Simulated $code"}',
      headers: const {'content-type': 'application/json'},
    );
  }

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) =>
      _maybeInject(() => inner.get(url, headers: headers));

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _maybeInject(() => inner.post(url, headers: headers, body: body));

  @override
  Future<HttpResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _maybeInject(() => inner.put(url, headers: headers, body: body));

  @override
  Future<HttpResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _maybeInject(() => inner.patch(url, headers: headers, body: body));

  @override
  Future<HttpResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) => _maybeInject(() => inner.delete(url, headers: headers, body: body));

  @override
  void close() => inner.close();
}
