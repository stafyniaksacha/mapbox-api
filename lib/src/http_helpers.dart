// Internal: sends a request and decodes its JSON body. Not exported.
//
// Compatibility rule (1.2.0): what threw in 1.1.0 still throws, with the same
// exception types, so `try/catch` around `request()` keeps working. What 1.1.0
// silently swallowed is now reported in the response's `error` field.

import 'dart:convert';

import 'package:http/http.dart';

import 'errors.dart';

/// Decoded JSON object (when the body is one) and the error to report, if any.
typedef JsonResult = ({Map<String, dynamic>? json, Error? error});

/// Thrown when [MapboxApi.accessToken] is not set (1.1.0 threw a null-check
/// error at the same point).
Error missingAccessToken() => ArgumentError.notNull('accessToken');

/// GETs [url] and decodes the JSON object it returns.
///
/// Throws, as 1.1.0 did:
/// - exceptions from the HTTP client (`ClientException`, `SocketException`, …)
///   unchanged;
/// - [FormatException] when the body is not JSON (e.g. an HTML 502 page).
///
/// Reports (was silently ignored in 1.1.0):
/// - non-2xx status → [MapboxHttpError], with `json` set when the body is a
///   JSON object so endpoint-specific errors can still be read from it;
/// - `Error`s thrown while sending, such as the `ArgumentError` for an
///   endpoint without scheme or host → [MapboxRequestError];
/// - 2xx JSON that is not an object (e.g. a batch geocoding array) →
///   [MapboxRequestError].
Future<JsonResult> fetchJson(String url) async {
  final Response response;
  try {
    response = await get(Uri.parse(url));
  } on Exception {
    rethrow;
  } on Error catch (failure) {
    // Never use failure.toString(): the ArgumentError thrown for an invalid
    // endpoint includes the URL, and so the access token.
    return (
      json: null,
      error: MapboxRequestError(
        message: failure is ArgumentError
            ? 'Invalid request URL'
            : failure.runtimeType.toString(),
        cause: failure,
      ),
    );
  }

  // Throws FormatException for a non-JSON body, as in 1.1.0.
  final decoded = jsonDecode(response.body);
  final json = decoded is Map<String, dynamic> ? decoded : null;

  final ok = response.statusCode >= 200 && response.statusCode < 300;
  if (!ok) {
    final message = json?['message'];
    return (
      json: json,
      error: MapboxHttpError(
        statusCode: response.statusCode,
        message: message is String ? message : null,
      ),
    );
  }

  if (json == null) {
    return (
      json: null,
      error: MapboxRequestError(message: 'Response body is not a JSON object'),
    );
  }

  return (json: json, error: null);
}
