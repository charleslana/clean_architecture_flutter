/// Transport-agnostic abstraction over HTTP.
///
/// Every HTTP call in the app — `ApiClient`, repositories, error injection —
/// goes through this interface. Switching from `package:http` to `dio`,
/// `chopper`, or any other library is a single-file change: replace the
/// implementation, leave the rest of the codebase untouched.
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

/// Transport-agnostic HTTP response — what the rest of the app sees.
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
