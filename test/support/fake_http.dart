import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Result of running [body] against a fake HTTP client.
class Captured<T> {
  Captured(this.requests, this.result);

  final List<http.Request> requests;
  final T result;

  /// URL of the single request that was sent.
  String get url {
    if (requests.length != 1) {
      throw StateError('Expected 1 request, got ${requests.length}');
    }
    return requests.single.url.toString();
  }
}

/// Runs [body] with every top-level `http` call routed to a [MockClient]
/// that records the request and answers with [responseBody] / [statusCode],
/// or throws [throwOnSend] (to simulate a network failure).
///
/// Uses `runWithClient`, so the library code is exercised unchanged.
Future<Captured<T>> capture<T>(
  Future<T> Function() body, {
  String responseBody = '{}',
  int statusCode = 200,
  Object? throwOnSend,
}) async {
  final requests = <http.Request>[];
  final client = MockClient((request) async {
    requests.add(request);
    if (throwOnSend != null) {
      throw throwOnSend;
    }
    return http.Response(
      responseBody,
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  final result = await http.runWithClient(body, () => client);
  return Captured(requests, result);
}

/// Reads a JSON fixture from `test/fixtures/`.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();
