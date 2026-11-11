import 'package:mapbox_api/mapbox_api.dart';

/// Token used in every golden URL. Not a real token.
const testToken = 'pk.test-token';

final _api = MapboxApi(accessToken: testToken);

/// Representative calls for every endpoint, keyed by a stable name.
///
/// The URLs these produce are pinned in `url_golden_test.dart`.
/// They describe the behavior of the published 1.1.0 release, bugs
/// included (see comments), so that refactors cannot change a URL silently.
final Map<String, Future<Object?> Function()> urlCases = {
  // ---------------------------------------------------------------- directions
  'directions/minimal': () => _api.directions.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [37.786060, -122.246225],
          [37.785939, -122.194292],
        ],
      ),
  'directions/no-profile': () => _api.directions.request(
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
      ),
  'directions/all-options': () => _api.directions.request(
        profile: NavigationProfile.DRIVING_TRAFFIC,
        coordinates: [
          [48.8, 2.3],
          [48.9, 2.4],
          [49.0, 2.5],
        ],
        alternatives: true,
        annotations: NavigationAnnotations.values,
        bearings: [NavigationBearings(45, 90), NavigationBearings(0, 180)],
        // Known 1.1.0 bug: continueStraight and excludes are never sent.
        continueStraight: true,
        excludes: [NavigationExclude.TOLL, NavigationExclude.FERRY],
        geometries: NavigationGeometries.GEOJSON,
        overview: NavigationOverview.FULL,
        radiuses: [10, double.infinity, 25.5],
        approaches: [
          NavigationApproaches.CURB,
          NavigationApproaches.UNRESTRICTED,
        ],
        steps: true,
        bannerInstructions: true,
        language: 'fr',
        roundaboutExits: true,
        voiceInstructions: true,
        voiceUnits: NavigationVoiceUnits.METRIC,
        waypointNames: ['Home', 'Work'],
        waypointTargets: [
          [48.81, 2.31],
          [49.01, 2.51],
        ],
        waypoints: [
          [48.8, 2.3],
          [49.0, 2.5],
        ],
      ),
  'directions/walking': () => _api.directions.request(
        profile: NavigationProfile.WALKING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
        walkingSpeed: 2.0,
        walkwayBias: 0.5,
        alleyBias: -1,
        geometries: NavigationGeometries.POLYLINE6,
        overview: NavigationOverview.NONE,
      ),
  'directions/walking-params-ignored-when-not-walking': () =>
      _api.directions.request(
        profile: NavigationProfile.CYCLING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
        walkingSpeed: 2.0,
        walkwayBias: 0.5,
      ),

  // ------------------------------------------------------------- map matching
  'map_matching/minimal': () => _api.mapMatching!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
      ),
  'map_matching/all-options': () => _api.mapMatching!.request(
        profile: NavigationProfile.WALKING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
          [5.0, 6.0],
        ],
        annotations: [
          NavigationAnnotations.DISTANCE,
          NavigationAnnotations.SPEED,
        ],
        approaches: NavigationApproaches.CURB,
        geometries: NavigationGeometries.GEOJSON,
        language: 'de',
        overview: NavigationOverview.FULL,
        radiuses: [5, 10, 15],
        steps: true,
        tidy: true,
        // Known 1.1.0 bug: timestamps are never sent.
        timestamps: [1000, 1010, 1020],
        waypointNames: ['A', 'B'],
        waypoints: [
          [1.0, 2.0],
          [5.0, 6.0],
        ],
      ),

  // ---------------------------------------------------------------- isochrone
  'isochrone/minimal': () => _api.isochrone!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [48.85, 2.35],
        contoursMinutes: [10],
      ),
  'isochrone/all-options': () => _api.isochrone!.request(
        profile: NavigationProfile.CYCLING,
        coordinates: [48.85, 2.35],
        contoursMinutes: [5, 10, 15],
        contoursColors: ['ff0000', '00ff00', '0000ff'],
        polygons: true,
        denoise: 0.5,
        generalize: 100,
      ),

  // ------------------------------------------------------------------- matrix
  // Known 1.1.0 bug: omitting `destinations` throws (see url_golden_test),
  // so the minimal case has to pass an empty list.
  'matrix/minimal': () => _api.matrix!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
        destinations: [],
      ),
  'matrix/all-options': () => _api.matrix!.request(
        profile: NavigationProfile.DRIVING_TRAFFIC,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
          [5.0, 6.0],
        ],
        annotations: [
          NavigationAnnotations.DURATION,
          NavigationAnnotations.DISTANCE,
        ],
        approaches: [
          NavigationApproaches.CURB,
          NavigationApproaches.UNRESTRICTED,
          NavigationApproaches.CURB,
        ],
        destinations: [1, 2],
        fallbackSpeed: 13,
        sources: [0],
      ),

  // ------------------------------------------------------------- optimization
  'optimization/minimal': () => _api.optimization!.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
      ),
  'optimization/all-options': () => _api.optimization!.request(
        profile: NavigationProfile.WALKING,
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
          [5.0, 6.0],
        ],
        annotations: [NavigationAnnotations.SPEED],
        approaches: [
          NavigationApproaches.UNRESTRICTED,
          NavigationApproaches.CURB,
          NavigationApproaches.CURB,
        ],
        bearings: [NavigationBearings(10, 20)],
        destination: NavigationDestination.LAST,
        distributions: [
          [0, 2],
        ],
        geometries: NavigationGeometries.POLYLINE6,
        language: 'es',
        overview: NavigationOverview.FULL,
        radiuses: [double.infinity, 5, 5],
        source: NavigationSource.FIRST,
        steps: true,
        roundtrip: false,
      ),

  // -------------------------------------------------------- forward geocoding
  'forward/minimal': () => _api.forwardGeocoding.request(
        searchText: 'tour eiffel',
      ),
  'forward/all-options': () => _api.forwardGeocoding.request(
        endpoint: GeocoderEndpoint.PLACES_PERMANENT,
        searchText: 'paris',
        autocomplete: false,
        bbox: GeocoderBbox(minX: 2.2, minY: 48.8, maxX: 2.5, maxY: 48.9),
        country: ['fr', 'be'],
        fuzzyMatch: false,
        language: 'fr',
        limit: 3,
        proximity: [48.858638, 2.286020],
        routing: true,
        types: [GeocoderPlaceType.ADDRESS, GeocoderPlaceType.POI],
      ),
  // Known 1.1.0 behavior: user text is not percent-encoded by the library.
  'forward/reserved-characters': () => _api.forwardGeocoding.request(
        searchText: 'a&b#c',
      ),
  'forward/batch': () => _api.forwardGeocoding.batch(
        searchTexts: ['paris', 'lyon'],
        limit: 1,
      ),

  // -------------------------------------------------------- reverse geocoding
  'reverse/minimal': () => _api.reverseGeocoding.request(
        coordinate: [48.858638, 2.286020],
      ),
  'reverse/all-options': () => _api.reverseGeocoding.request(
        endpoint: GeocoderEndpoint.PLACES_PERMANENT,
        coordinate: [48.858638, 2.286020],
        country: ['fr'],
        language: 'en',
        limit: 1,
        reverseMode: GeocoderReverseMode.SCORE,
        routing: true,
        types: [GeocoderPlaceType.ADDRESS],
      ),
  'reverse/batch': () => _api.reverseGeocoding.batch(
        coordinates: [
          [48.85, 2.29],
          [45.76, 4.83],
        ],
      ),

  // ------------------------------------------------------------- intersection
  'intersection/minimal': () => _api.intersection.request(
        street1: 'market street',
        street2: 'fremont street',
      ),
  'intersection/all-options': () => _api.intersection.request(
        street1: 'market street',
        street2: 'fremont street',
        proximity: [37.79, -122.39],
        types: [GeocoderPlaceType.ADDRESS],
      ),
};
