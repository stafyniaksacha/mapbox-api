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

/// The request could not be completed or its response could not be read:
/// network failure, timeout, or a body that is not a JSON object.
///
/// [toString] never includes the request URL, which contains the access
/// token, so this error is safe to log.
class MapboxRequestError extends Error {
  MapboxRequestError({required this.message, this.cause});

  /// Human-readable description, without the request URL.
  final String message;

  /// The original exception (e.g. `ClientException`, `FormatException`).
  /// Its own `toString()` may include the request URL and access token:
  /// avoid logging it as is.
  final Object? cause;

  @override
  String toString() => 'MapboxRequestError{message: $message}';
}
