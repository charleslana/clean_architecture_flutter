import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_service.dart';

class HttpServiceHttp implements HttpService {
  HttpServiceHttp({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers}) async {
    final response = await _client.get(url, headers: headers);
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.post(
      url,
      headers: _withJsonContentType(headers, body),
      body: _encode(body),
    );
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.put(
      url,
      headers: _withJsonContentType(headers, body),
      body: _encode(body),
    );
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.patch(
      url,
      headers: _withJsonContentType(headers, body),
      body: _encode(body),
    );
    return _toHttpResponse(response);
  }

  @override
  Future<HttpResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.delete(
      url,
      headers: _withJsonContentType(headers, body),
      body: _encode(body),
    );
    return _toHttpResponse(response);
  }

  @override
  void close() => _client.close();

  HttpResponse _toHttpResponse(http.Response response) => HttpResponse(
    statusCode: response.statusCode,
    body: response.body,
    headers: response.headers,
  );

  Object? _encode(Object? body) {
    if (body == null || body is String) return body;
    return jsonEncode(body);
  }

  Map<String, String>? _withJsonContentType(
    Map<String, String>? headers,
    Object? body,
  ) {
    if (body == null || body is String) return headers;
    return {'content-type': 'application/json', ...?headers};
  }
}
