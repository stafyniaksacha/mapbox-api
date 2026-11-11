// Response parsing, pinned against fixtures shaped like the documented
// Mapbox responses (https://docs.mapbox.com/api/). Fixtures are hand-written
// from the docs, not recorded from the live API.
//
// Tests under "known 1.1.0 bugs" describe current, wrong behavior on purpose.
// When a bug is fixed, flip the expectation and note it in CHANGELOG.md.
import 'dart:convert';

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

  test('isochrone (known 1.1.0 bug: features never parse)', () async {
    final r = (await capture(
      () => api.isochrone!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [48.85, 2.35],
        contoursMinutes: [10],
      ),
      responseBody: fixture('isochrone.json'),
    ))
        .result;
    // Known 1.1.0 bug: NavigationFeatureGeometry.coordinates is typed
    // List<double>, but isochrone geometries are always nested (LineString /
    // Polygon). Parsing throws, withError drops it: every real response ends
    // up with features == null and error == null. Fixing needs a public type
    // change (2.0).
    expect(r.features, isNull);
    expect(r.error, isNull);
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

  group('known 1.1.0 bugs', () {
    test('withError never stores the error (self-assignment)', () async {
      // `durations` is a string: the cast throws a TypeError, which is caught
      // and handed to withError, which then drops it.
      final r = (await capture(
        () => api.matrix!.request(coordinates: twoPoints, destinations: []),
        responseBody: jsonEncode({'code': 'Ok', 'durations': 'oops'}),
      ))
          .result;
      expect(r.error, isNull);
      expect(r.durations, isNull);
    });

    test('integer values in matrix durations are silently dropped', () async {
      final r = (await capture(
        () => api.matrix!.request(coordinates: twoPoints, destinations: []),
        responseBody: fixture('matrix_integer_values.json'),
      ))
          .result;
      expect(r.durations, isNull);
      expect(r.error, isNull);
    });

    test('a null tracepoint (unmatched point) drops the whole response',
        () async {
      final body = jsonDecode(fixture('map_matching.json')) as Map;
      body['tracepoints'] = [...body['tracepoints'] as List, null];
      final r = (await capture(
        () => api.mapMatching!.request(coordinates: twoPoints),
        responseBody: jsonEncode(body),
      ))
          .result;
      expect(r.tracepoints, isNull);
      expect(r.error, isNull);
    });

    test('route weight_name is read from the wrong key', () async {
      final r = await directions(fixture('directions.json'));
      expect(r.routes!.single.weightName, isNull);
    });

    test('intersection "out" is read from the wrong key', () async {
      final r = await directions(fixture('directions.json'));
      final step = r.routes!.single.legs!.single.steps!.first;
      expect(step.intersections!.single.outIndex, isNull);
    });

    test('HTTP 401 on directions is reported as success', () async {
      final r = await directions(fixture('unauthorized.json'), status: 401);
      expect(r.error, isNull);
      expect(r.routes, isNull);
    });

    test('a non-JSON body throws FormatException out of request()', () async {
      await expectLater(
        directions('<html>502 Bad Gateway</html>', status: 502),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
