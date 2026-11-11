import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:test/test.dart';

import 'support/url_cases.dart';

void main() {
  test('an injected client is used for every request', () async {
    final urls = <Uri>[];
    final client = MockClient((request) async {
      urls.add(request.url);
      return http.Response('{"code": "Ok", "routes": []}', 200);
    });
    final api = MapboxApi(accessToken: testToken, client: client);

    // No runWithClient zone here: only the injected client can answer.
    final r = await api.directions.request(
      coordinates: [
        [1.0, 2.0],
        [3.0, 4.0],
      ],
    );
    await api.forwardGeocoding.request(searchText: 'x');

    expect(r.error, isNull);
    expect(r.routes, isEmpty);
    expect(urls, hasLength(2));
    expect(urls.first.path, '/directions/v5/2.0,1.0;4.0,3.0');
  });

  test('a timeout throws TimeoutException', () async {
    final never = Completer<http.Response>();
    final api = MapboxApi(
      accessToken: testToken,
      client: MockClient((_) => never.future),
      timeout: const Duration(milliseconds: 10),
    );
    await expectLater(
      api.matrix!.request(destinations: []),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('client and timeout default to null (1.1.0 behavior)', () {
    final api = MapboxApi(accessToken: testToken);
    expect(api.client, isNull);
    expect(api.timeout, isNull);
  });
}
