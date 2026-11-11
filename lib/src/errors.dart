/// The API answered with a non-2xx HTTP status that the endpoint-specific
/// error types (e.g. [GeocoderError], `NavigationNoRouteError`) do not cover.
///
/// Typical cases: 401 (invalid or missing token), 403 (token not allowed for
/// this URL/scope), 422 (invalid input), 429 (rate limited), 5xx.
class MapboxHttpError extends Error {
  MapboxHttpError({required this.statusCode, this.message});

  /// HTTP status code returned by the API.
  final int statusCode;

  /// The `message` field of the response body, when there is one.
  final String? message;

  @override
  String toString() => 'MapboxHttpError{statusCode: $statusCode, '
      'message: $message}';
}

/// The request failed in a way 1.1.0 silently ignored: an `Error` while
/// sending (e.g. an endpoint without scheme or host), or a JSON body that is
/// not an object (e.g. a multi-query batch geocoding array).
///
/// Network failures (`ClientException`, `SocketException`) and non-JSON
/// bodies (`FormatException`) are still thrown, as in 1.1.0.
///
/// [toString] never includes the request URL, which contains the access
/// token, so this error is safe to log.
class MapboxRequestError extends Error {
  MapboxRequestError({required this.message, this.cause});

  /// Human-readable description, without the request URL.
  final String message;

  /// What was thrown, if anything (e.g. the `ArgumentError` for an invalid
  /// endpoint). Its own `toString()` may include the request URL and access
  /// token: avoid logging it as is.
  final Object? cause;

  @override
  String toString() => 'MapboxRequestError{message: $message}';
}
