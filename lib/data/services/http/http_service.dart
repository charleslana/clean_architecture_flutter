abstract interface class HttpService {
  Future<HttpResponse> get(Uri url, {Map<String, String>? headers});

  Future<HttpResponse> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  });

  Future<HttpResponse> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  });

  Future<HttpResponse> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  });

  Future<HttpResponse> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  });

  void close();
}

class HttpResponse {
  const HttpResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
}
