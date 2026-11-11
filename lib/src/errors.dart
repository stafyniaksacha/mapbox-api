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

  /// Includes [message] with URLs replaced by `<url>` and anything that looks
  /// like an access token redacted, since the message comes from the server.
  /// Read [message] for the raw text.
  @override
  String toString() => 'MapboxHttpError{statusCode: $statusCode, '
      'message: ${message == null ? null : _redactTokens(message!)}}';
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

final _url = RegExp(r'[a-zA-Z][a-zA-Z0-9+.-]*://\S+');
final _accessTokenParameter = RegExp(r"""access_token=[^&\s"'#]*""");
final _mapboxToken = RegExp(r'\b[ps]k\.[A-Za-z0-9._-]+');

/// Replaces URLs in [text] with `<url>`, then `access_token=…` values and
/// Mapbox `pk.` / `sk.` tokens outside URLs with `REDACTED`.
String _redactTokens(String text) => text
    .replaceAll(_url, '<url>')
    .replaceAll(_accessTokenParameter, 'access_token=REDACTED')
    .replaceAll(_mapboxToken, 'REDACTED');
