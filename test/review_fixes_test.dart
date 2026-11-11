// Regression tests for the CodeRabbit review of PR #15.
import 'dart:convert';

import 'package:mapbox_api/mapbox_api.dart';
import 'package:test/test.dart';

import 'support/fake_http.dart';
import 'support/url_cases.dart';

final api = MapboxApi(accessToken: testToken);

const twoPoints = [
  [1.0, 2.0],
  [3.0, 4.0],
];

void main() {
  group('MapboxHttpError.toString redacts tokens', () {
    test('access_token query parameters and pk./sk. tokens', () {
      final error = MapboxHttpError(
        statusCode: 401,
        message: 'Bad https://api.mapbox.com/x?access_token=sk.eyJabc.def-1&a=1'
            ' and pk.eyJ1Ijoi.xyz_2',
      );
      final text = error.toString();
      expect(text, isNot(contains('sk.eyJabc')));
      expect(text, isNot(contains('pk.eyJ1Ijoi')));
      expect(text, contains('access_token=REDACTED'));
      expect(text, contains('401'));
      // The raw message stays available to callers.
      expect(error.message, contains('sk.eyJabc.def-1'));
    });

    test('ordinary messages are unchanged', () {
      expect(
        MapboxHttpError(statusCode: 401, message: 'Not Authorized').toString(),
        contains('message: Not Authorized'),
      );
    });
  });

  test('a non-2xx body that fails to parse keeps the HTTP error', () async {
    final r = (await capture(
      () => api.directions.request(coordinates: twoPoints),
      responseBody: jsonEncode({'code': 429, 'message': 'Rate limited'}),
      statusCode: 429,
    ))
        .result;
    expect(
      r.error,
      isA<MapboxHttpError>()
          .having((e) => e.statusCode, 'statusCode', 429)
          .having((e) => e.message, 'message', 'Rate limited'),
    );
  });

  test('a 2xx body that fails to parse still reports the parse error',
      () async {
    final r = (await capture(
      () => api.directions.request(coordinates: twoPoints),
      responseBody: jsonEncode({'code': 1}),
    ))
        .result;
    expect(r.error, isA<TypeError>());
  });

  group('rawCoordinates has typed nested lists', () {
    NavigationFeatureGeometry geometry(String type, Object coordinates) =>
        NavigationFeatureGeometry.fromJson(
          {'type': type, 'coordinates': coordinates},
        );

    test('LineString', () {
      final raw = geometry('LineString', [
        [1, 2],
        [3.5, 4],
      ]).rawCoordinates;
      expect(raw, isA<List<List<double>>>());
      expect(raw, [
        [1.0, 2.0],
        [3.5, 4.0],
      ]);
    });

    test('Polygon', () {
      final raw = geometry('Polygon', [
        [
          [1, 2],
          [3, 4],
          [1, 2],
        ],
      ]).rawCoordinates;
      expect(raw, isA<List<List<List<double>>>>());
    });

    test('MultiPolygon', () {
      final raw = geometry('MultiPolygon', [
        [
          [
            [1, 2],
            [3, 4],
            [1, 2],
          ],
        ],
      ]).rawCoordinates;
      expect(raw, isA<List<List<List<List<double>>>>>());
    });

    test('Point keeps coordinates and a flat rawCoordinates', () {
      final g = geometry('Point', [1, 2]);
      expect(g.coordinates, [1.0, 2.0]);
      expect(g.rawCoordinates, isA<List<double>>());
    });
  });

  test('geocoding routable_points are read from point objects', () async {
    final r = (await capture(
      () => api.forwardGeocoding.request(searchText: 'x'),
      responseBody: jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          {
            'id': 'address.1',
            'type': 'Feature',
            'routable_points': {
              'points': [
                {
                  'coordinates': [2, 48.5],
                },
              ],
            },
          },
        ],
      }),
    ))
        .result;
    expect(r.error, isNull);
    expect(r.features!.single.routablePoints!.points, [
      [2.0, 48.5],
    ]);
  });
}
