// Response parsing, pinned against fixtures shaped like the documented
// Mapbox responses (https://docs.mapbox.com/api/). Fixtures are hand-written
// from the docs, not recorded from the live API.
//
// Tests under "known 1.1.0 bugs" describe current, wrong behavior on purpose.
// When a bug is fixed, flip the expectation and note it in CHANGELOG.md.
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show ClientException;
import 'package:mapbox_api/mapbox_api.dart';
import 'package:test/test.dart';

import 'support/fake_http.dart';
import 'support/url_cases.dart';

final api = MapboxApi(accessToken: testToken);

const twoPoints = [
  [48.8566, 2.3522],
  [48.8698, 2.3069],
];

Future<DirectionsApiResponse> directions(String body,
        {int status = 200}) async =>
    (await capture(
      () => api.directions.request(
        profile: NavigationProfile.DRIVING,
        coordinates: twoPoints,
      ),
      responseBody: body,
      statusCode: status,
    ))
        .result;

void main() {
  group('directions', () {
    late DirectionsApiResponse response;

    setUpAll(() async {
      response = await directions(fixture('directions.json'));
    });

    test('top level', () {
      expect(response.error, isNull);
      expect(response.code, 'Ok');
      expect(response.uuid, 'cjd51uqn5005447p8eu3d1ldx');
      expect(response.waypoints, hasLength(2));
      expect(response.waypoints!.first.name, 'Rue de Rivoli');
      expect(response.waypoints!.first.location, [2.3522, 48.8566]);
    });

    test('route and leg', () {
      final route = response.routes!.single;
      expect(route.duration, 812.5);
      expect(route.distance, 4321.1);
      expect(route.weight, 900.25);
      expect(route.geometry, 'o{~hHk~gM??');
      expect(route.voiceLocale, 'en-US');

      final leg = route.legs!.single;
      expect(leg.summary, 'Rue de Rivoli, Avenue des Champs-Élysées');
      expect(leg.steps, hasLength(3));
      expect(leg.annotation!.duration, [10.5, 20.25]);
      expect(leg.annotation!.congestion, ['low', 'heavy']);
    });

    test('step, maneuver, intersection', () {
      final step = response.routes!.single.legs!.single.steps!.first;
      expect(step.name, 'Rue de Rivoli');
      expect(step.drivingSide, NavigationDrivingSide.RIGHT);
      expect(step.mode, NavigationStepMode.DRIVING);
      expect(step.ref, ['D1']);

      final maneuver = step.maneuver!;
      expect(maneuver.type, NavigationManeuverType.DEPART);
      expect(maneuver.bearingAfter, 270);
      expect(maneuver.instruction, 'Drive west on Rue de Rivoli.');

      final intersection = step.intersections!.single;
      expect(intersection.bearings, [90, 270]);
      expect(intersection.entry, [false, true]);
      expect(intersection.inIndex, 0);
      expect(intersection.geometryIndex, 0);
    });

    test('voice and banner instructions', () {
      final step = response.routes!.single.legs!.single.steps!.first;
      final voice = step.voiceInstructions!.single;
      expect(voice.announcement, 'Drive west on Rue de Rivoli.');
      expect(voice.distanceAlongGeometry, 120.5);

      final primary = step.bannerInstructions!.single.primary!;
      expect(primary.text, 'Place de la Concorde');
      expect(primary.type, NavigationInstructionType.ROUNDABOUT);
      expect(primary.modifier, NavigationInstructionModifier.SLIGHT_RIGHT);
      expect(primary.degrees, 90.5);
    });

    test('maneuver types documented by Mapbox are all parsed', () {
      final steps = response.routes!.single.legs!.single.steps!;
      expect(steps[1].maneuver!.type, NavigationManeuverType.EXIT_ROUNDABOUT);
      expect(
          steps[1].maneuver!.modifier, NavigationManeuverModifier.SLIGHT_RIGHT);
      expect(steps[2].maneuver!.type, NavigationManeuverType.ARRIVE);
    });

    // Every maneuver type listed in the Mapbox Directions docs, including the
    // three restored after the unreleased #9 regression.
    const maneuverTypes = <String, NavigationManeuverType>{
      'turn': NavigationManeuverType.TURN,
      'new name': NavigationManeuverType.NEW_NAME,
      'depart': NavigationManeuverType.DEPART,
      'arrive': NavigationManeuverType.ARRIVE,
      'merge': NavigationManeuverType.MERGE,
      'on ramp': NavigationManeuverType.ON_RAMP,
      'off ramp': NavigationManeuverType.OFF_RAMP,
      'fork': NavigationManeuverType.FORK,
      'end of road': NavigationManeuverType.END_OF_ROAD,
      'continue': NavigationManeuverType.CONTINUE,
      'roundabout': NavigationManeuverType.ROUNDABOUT,
      'rotary': NavigationManeuverType.ROTARY,
      'roundabout turn': NavigationManeuverType.ROUNDABOUT_TURN,
      'notification': NavigationManeuverType.NOTIFICATION,
      'exit roundabout': NavigationManeuverType.EXIT_ROUNDABOUT,
      'exit rotary': NavigationManeuverType.EXIT_ROTARY,
    };
    for (final entry in maneuverTypes.entries) {
      test('maneuver type "${entry.key}"', () {
        final maneuver = NavigationManeuver.fromJson({'type': entry.key});
        expect(maneuver.type, entry.value);
      });
    }

    test('unknown maneuver type parses to null without printing', () {
      final printed = <String>[];
      final maneuver = Zone.current
          .fork(
            specification: ZoneSpecification(
              print: (_, __, ___, line) => printed.add(line),
            ),
          )
          .run(() => NavigationManeuver.fromJson({'type': 'teleport'}));
      expect(maneuver.type, isNull);
      expect(printed, isEmpty);
    });

    test('NoRoute code maps to NavigationNoRouteError', () async {
      final r = await directions(fixture('directions_no_route.json'));
      expect(r.error, isA<NavigationNoRouteError>());
      expect(r.routes, isEmpty);
    });
  });

  test('matrix', () async {
    final r = (await capture(
      () => api.matrix!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: twoPoints,
        destinations: [],
      ),
      responseBody: fixture('matrix.json'),
    ))
        .result;
    expect(r.error, isNull);
    expect(r.durations, [
      [0.0, 573.5],
      [579.25, 0.0],
    ]);
    expect(r.distances![1][0], 4400.75);
    expect(r.sources, hasLength(2));
    expect(r.destinations!.last.name, 'Avenue des Champs-Élysées');
  });

  test('isochrone', () async {
    final r = (await capture(
      () => api.isochrone!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [48.85, 2.35],
        contoursMinutes: [10],
      ),
      responseBody: fixture('isochrone.json'),
    ))
        .result;
    expect(r.error, isNull);
    final feature = r.features!.single;
    expect(feature.type, 'Feature');
    expect(feature.properties!.contour, 10);
    expect(feature.properties!.fillOpacity, 0.33);
    expect(feature.geometry!.type, 'Polygon');
    // Nested geometry: only rawCoordinates is set (fixed in 1.2.0, was a
    // parse failure for every isochrone response).
    expect(feature.geometry!.coordinates, isNull);
    expect(feature.geometry!.rawCoordinates, [
      [
        [2.35, 48.85],
        [2.36, 48.86],
        [2.34, 48.86],
        [2.35, 48.85],
      ],
    ]);
  });

  test('optimization', () async {
    final r = (await capture(
      () => api.optimization!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: twoPoints,
      ),
      responseBody: fixture('optimization.json'),
    ))
        .result;
    expect(r.error, isNull);
    expect(r.code, 'Ok');
    expect(r.waypoints!.last.waypointIndex, 1);
    expect(r.trips!.single.legs, hasLength(2));
    expect(r.trips!.single.duration, 1600.5);
  });

  test('map matching', () async {
    final r = (await capture(
      () => api.mapMatching!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: twoPoints,
      ),
      responseBody: fixture('map_matching.json'),
    ))
        .result;
    expect(r.error, isNull);
    expect(r.matchings!.single.confidence, 0.95);
    expect(r.tracepoints!.single.matchingsIndex, 0);
  });

  group('geocoding', () {
    test('forward', () async {
      final r = (await capture(
        () => api.forwardGeocoding.request(searchText: 'tour eiffel'),
        responseBody: fixture('geocoding_forward.json'),
      ))
          .result;
      expect(r.error, isNull);
      expect(r.query, ['tour', 'eiffel']);
      final f = r.features!.single;
      expect(f.id, 'poi.123');
      expect(f.placeType, [GeocoderPlaceType.POI]);
      expect(f.relevance, 1.0);
      expect(f.text, 'Tour Eiffel');
      expect(f.center, [2.294481, 48.85837]);
      expect(f.bbox!.maxY, 48.86);
      expect(f.properties!.landmark, isTrue);
      expect(f.context!.last.shortCode, 'fr');
    });

    test('a "message" body maps to GeocoderError', () async {
      final r = (await capture(
        () => api.forwardGeocoding.request(searchText: 'x'),
        responseBody: fixture('unauthorized.json'),
        statusCode: 401,
      ))
          .result;
      expect(r.error, isA<GeocoderError>());
      expect((r.error! as GeocoderError).message, contains('Invalid Token'));
    });
  });

  group('constructor defaults (1.1.0)', () {
    // Subclass constructors forward null to the parent, overriding its
    // `const []` default. Guards against an automatic super-parameter fix.
    test('NavigationTracepoint().location is null', () {
      expect(NavigationTracepoint().location, isNull);
      expect(NavigationWaypoint().location, isEmpty);
    });

    test('NavigationMatchRoute().legs is null', () {
      expect(NavigationMatchRoute().legs, isNull);
      expect(NavigationRoute().legs, isEmpty);
    });

    test('error subclasses keep their message', () {
      expect(NavigationNoRouteError(message: 'm').message, 'm');
    });
  });

  // 1.2.0 rule: what threw in 1.1.0 still throws (same types); what 1.1.0
  // silently swallowed is now reported in `error`.
  group('error reporting (1.2.0)', () {
    test('parse failures are stored in error (was dropped)', () async {
      final r = (await capture(
        () => api.matrix!.request(coordinates: twoPoints, destinations: []),
        responseBody: jsonEncode({'code': 'Ok', 'durations': 'oops'}),
      ))
          .result;
      expect(r.error, isA<TypeError>());
      expect(r.durations, isNull);
    });

    test('HTTP 401 without an endpoint error code is a MapboxHttpError',
        () async {
      final r = await directions(fixture('unauthorized.json'), status: 401);
      expect(r.routes, isNull);
      expect(
        r.error,
        isA<MapboxHttpError>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', contains('Invalid Token')),
      );
    });

    test('endpoint-specific errors take precedence over the HTTP status',
        () async {
      final r =
          await directions(fixture('directions_no_route.json'), status: 422);
      expect(r.error, isA<NavigationNoRouteError>());

      final g = (await capture(
        () => api.forwardGeocoding.request(searchText: 'x'),
        responseBody: fixture('unauthorized.json'),
        statusCode: 401,
      ))
          .result;
      expect(g.error, isA<GeocoderError>());
    });

    test('matrix NoRoute code maps to NavigationNoRouteError', () async {
      final r = (await capture(
        () => api.matrix!.request(coordinates: twoPoints),
        responseBody: jsonEncode({'code': 'NoRoute'}),
      ))
          .result;
      expect(r.error, isA<NavigationNoRouteError>());
    });

    test('a non-JSON body still throws FormatException, as in 1.1.0', () async {
      await expectLater(
        directions('<html>502 Bad Gateway</html>', status: 502),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        directions('not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('a network failure still throws the original exception, as in 1.1.0',
        () async {
      final failure = ClientException(
        'Connection refused',
        Uri.parse('https://api.mapbox.com/x'),
      );
      await expectLater(
        capture(
          () => api.directions.request(coordinates: twoPoints),
          throwOnSend: failure,
        ),
        throwsA(same(failure)),
      );
    });

    test('an invalid endpoint is a MapboxRequestError, not thrown', () async {
      final custom = MapboxApi(accessToken: testToken);
      custom.directions.endpoint = 'api.mapbox.com/directions'; // no scheme
      final r = (await capture(
        () => custom.directions.request(coordinates: twoPoints),
        throwOnSend: ArgumentError(
          'No host specified in URI api.mapbox.com/x?access_token=$testToken',
        ),
      ))
          .result;
      expect(
        r.error,
        isA<MapboxRequestError>()
            .having((e) => e.message, 'message', 'Invalid request URL'),
      );
      expect(r.error.toString(), isNot(contains(testToken)));
    });

    test('a missing access token still throws, before any request', () async {
      final noToken = MapboxApi();
      final calls = <Future<Object?> Function()>[
        () => noToken.directions.request(),
        () => noToken.matrix!.request(destinations: []),
        () => noToken.forwardGeocoding.request(searchText: 'x'),
        () => noToken.reverseGeocoding.batch(),
      ];
      for (final call in calls) {
        await expectLater(capture(call), throwsA(isA<ArgumentError>()));
      }
      final captured = await capture(() async {
        try {
          await noToken.directions.request();
        } on ArgumentError {
          // expected
        }
      });
      expect(captured.requests, isEmpty);
    });
  });

  group('known bugs (still open)', () {
    // Multi-query v5 batch geocoding returns a JSON array of feature
    // collections, which GeocodingApiResponse cannot hold. 1.1.0 silently
    // returned an empty response; 1.2.0 reports it. Proper support needs a
    // new API (see docs/modernization-plan.md).
    test('multi-query batch geocoding is reported as an error', () async {
      final collection = jsonDecode(fixture('geocoding_forward.json'));
      final r = (await capture(
        () => api.forwardGeocoding.batch(searchTexts: ['a', 'b']),
        responseBody: jsonEncode([collection, collection]),
      ))
          .result;
      expect(r.features, isNull);
      expect(r.error, isA<MapboxRequestError>());
    });
  });

  test('maxspeed, congestion_numeric and closures (1.2.0)', () async {
    final r = await directions(jsonEncode({
      'code': 'Ok',
      'routes': [
        {
          'legs': [
            {
              'annotation': {
                'maxspeed': [
                  {'speed': 50, 'unit': 'km/h'},
                  {'unknown': true},
                  {'none': true},
                ],
                'congestion_numeric': [0, null, 100],
              },
              'closures': [
                {'geometry_index_start': 3, 'geometry_index_end': 7},
              ],
            },
          ],
        },
      ],
    }));
    expect(r.error, isNull);
    final leg = r.routes!.single.legs!.single;
    final maxspeed = leg.annotation!.maxspeed!;
    expect(maxspeed[0].speed, 50.0);
    expect(maxspeed[0].unit, 'km/h');
    expect(maxspeed[0].unknown, isFalse);
    expect(maxspeed[1].unknown, isTrue);
    expect(maxspeed[1].speed, isNull);
    expect(maxspeed[2].none, isTrue);
    expect(leg.annotation!.congestionNumeric, [0, null, 100]);
    expect(leg.closures!.single.geometryIndexStart, 3);
    expect(leg.closures!.single.geometryIndexEnd, 7);
  });

  group('parsing (fixed in 1.2.0)', () {
    test('integer values in matrix durations are parsed', () async {
      final r = (await capture(
        () => api.matrix!.request(coordinates: twoPoints, destinations: []),
        responseBody: fixture('matrix_integer_values.json'),
      ))
          .result;
      expect(r.error, isNull);
      expect(r.durations, [
        [0.0, 573.0],
        [579.0, 0.0],
      ]);
    });

    test('null matrix cells (no route) become double.infinity', () async {
      final r = (await capture(
        () => api.matrix!.request(coordinates: twoPoints, destinations: []),
        responseBody: jsonEncode({
          'code': 'Ok',
          'durations': [
            [0, null],
            [12.5, 0],
          ],
        }),
      ))
          .result;
      expect(r.error, isNull);
      expect(r.durations![0][1], double.infinity);
      expect(r.durations![1][0], 12.5);
    });

    test('integer coordinates are parsed', () async {
      final r = await directions(jsonEncode({
        'code': 'Ok',
        'waypoints': [
          {
            'name': 'x',
            'location': [2, 48],
          },
        ],
      }));
      expect(r.error, isNull);
      expect(r.waypoints!.single.location, [2.0, 48.0]);
    });

    test('a null tracepoint (unmatched point) keeps its index', () async {
      final body = jsonDecode(fixture('map_matching.json')) as Map;
      body['tracepoints'] = [null, ...body['tracepoints'] as List];
      final r = (await capture(
        () => api.mapMatching!.request(coordinates: twoPoints),
        responseBody: jsonEncode(body),
      ))
          .result;
      expect(r.error, isNull);
      expect(r.tracepoints, hasLength(2));
      expect(r.tracepoints![0].location, isNull);
      expect(r.tracepoints![0].name, isNull);
      expect(r.tracepoints![1].name, 'Rue de Rivoli');
    });

    test('route weight_name is read', () async {
      final r = await directions(fixture('directions.json'));
      expect(r.routes!.single.weightName, 'auto');
    });

    test('map matching weight_name is read', () async {
      final r = (await capture(
        () => api.mapMatching!.request(coordinates: twoPoints),
        responseBody: fixture('map_matching.json'),
      ))
          .result;
      expect(r.matchings!.single.weightName, 'auto');
    });

    test('intersection "out" is read', () async {
      final r = await directions(fixture('directions.json'));
      final step = r.routes!.single.legs!.single.steps!.first;
      expect(step.intersections!.single.outIndex, 1);
    });
  });
}
