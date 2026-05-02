import 'dart:async';
import 'dart:io';

import 'error_injector.dart';
import 'http_service.dart';

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
      await Future<void>.delayed(const Duration(milliseconds: 600));
      throw TimeoutException('Simulated timeout');
    }
    if (mode == ErrorMode.noInternet) {
      throw const SocketException('Simulated: no internet');
    }
    if (mode == ErrorMode.unexpectedShape) {
      return const HttpResponse(
        statusCode: 200,
        body: '[{}]',
        headers: {'content-type': 'application/json'},
      );
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
