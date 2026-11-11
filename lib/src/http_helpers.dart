// Internal: sends a request and turns every failure into an [Error] so the
// response objects can report it in their `error` field. Not exported.

import 'dart:convert';

import 'package:http/http.dart';

import 'errors.dart';

/// Decoded JSON object (when the body is one) and the error to report, if any.
typedef JsonResult = ({Map<String, dynamic>? json, Error? error});

/// Error returned when [MapboxApi.accessToken] is not set.
Error missingAccessToken() => ArgumentError.notNull('accessToken');

/// GETs [url] and decodes the JSON object it returns.
///
/// - Network failures and invalid URLs → `json == null`, [MapboxRequestError].
/// - Non-2xx status → [MapboxHttpError], with `json` set when the body is a
///   JSON object so endpoint-specific errors can still be read from it.
/// - 2xx with a body that is not a JSON object → [MapboxRequestError].
Future<JsonResult> fetchJson(String url) async {
  final Response response;
  try {
    response = await get(Uri.parse(url));
  } on Exception catch (exception) {
    // Do not use exception.toString(): ClientException includes the URL.
    final message = exception is ClientException
        ? exception.message
        : exception is FormatException
            ? 'Invalid request URL'
            : exception.runtimeType.toString();
    return (
      json: null,
      error: MapboxRequestError(message: message, cause: exception),
    );
  }

  final ok = response.statusCode >= 200 && response.statusCode < 300;

  Object? decoded;
  try {
    decoded = jsonDecode(response.body);
  } on FormatException catch (exception) {
    decoded = exception;
  }

  final json = decoded is Map<String, dynamic> ? decoded : null;

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
      error: MapboxRequestError(
        message: 'Response body is not a JSON object',
        cause: decoded is FormatException ? decoded : null,
      ),
    );
  }

  return (json: json, error: null);
}
