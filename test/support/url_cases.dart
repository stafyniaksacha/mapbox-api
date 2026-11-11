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
  ..._baseCases,
  ..._edgeCases(),
};

final Map<String, Future<Object?> Function()> _baseCases = {
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

  // Parameters added in 1.2.0 (phase 5b).
  'directions/vehicle-time-include': () => _api.directions.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [48.8, 2.3],
          [48.9, 2.4],
        ],
        excludes: NavigationExclude.values,
        include: NavigationInclude.values,
        maxHeight: 4.2,
        maxWidth: 2.55,
        maxWeight: 19,
        // Not UTC on purpose: must be converted, without milliseconds.
        departAt: DateTime.utc(2026, 3, 4, 5, 6, 7, 890).toLocal(),
        arriveBy: DateTime.utc(2026, 12, 31, 23, 59),
        avoidManeuverRadius: 300,
      ),

  // EV routing (1.2.0, Mapbox private preview).
  'directions/ev-minimal': () => _api.directions.request(
        profile: NavigationProfile.DRIVING_TRAFFIC,
        coordinates: [
          [48.8566, 2.3522],
          [45.764, 4.8357],
        ],
        ev: const DirectionsEvOptions(
          maxCharge: 80000,
          connectorTypes: [EvConnectorType.CCS_COMBO_TYPE2],
          energyConsumptionCurve: [
            (speedKph: 0, whPerKm: 300),
            (speedKph: 20, whPerKm: 160),
            (speedKph: 120, whPerKm: 212.5),
          ],
          chargingCurve: [
            (chargeWh: 0, powerW: 100000),
            (chargeWh: 40000, powerW: 70000),
          ],
        ),
      ),
  'directions/ev-all-options': () => _api.directions.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [48.8566, 2.3522],
          [47.0, 3.0],
          [45.764, 4.8357],
        ],
        waypointsPerRoute: true,
        alternatives: true,
        annotations: [NavigationAnnotations.STATE_OF_CHARGE],
        overview: NavigationOverview.FULL,
        ev: const DirectionsEvOptions(
          maxCharge: 80000,
          connectorTypes: [
            EvConnectorType.CCS_COMBO_TYPE2,
            EvConnectorType.CHADEMO,
          ],
          energyConsumptionCurve: [
            (speedKph: 0, whPerKm: 300),
            (speedKph: 120, whPerKm: 200),
          ],
          chargingCurve: [
            (chargeWh: 0, powerW: 100000),
            (chargeWh: 80000, powerW: 10000),
          ],
          initialCharge: 60000,
          unconditionedChargingCurve: [
            (chargeWh: 0, powerW: 50000),
          ],
          preConditioningTime: 30,
          maxAcChargingPower: 11000,
          minChargeAtDestination: 12000,
          minChargeAtChargingStation: 8000,
          ascent: 3.5,
          descent: 2,
          regenerationEfficiency: 0.7,
          auxiliaryConsumption: 300,
          addChargingStops: false,
          preferAmenities: [EvAmenity.RESTROOM, EvAmenity.RESTAURANT],
          excludeStationIds: ['st-1', 'st 2'],
          excludeChargePointProviderIds: ['prov-a'],
          preferChargePointProviderIds: ['prov-b', 'prov-c'],
          preferChargePointProviderWeights: [1, 0.5],
          exclude: [EvExclude.TESLA_EXCLUSIVE],
          maxChargingVoltage: 400,
          maxChargingPowerAtLowerVoltage: 50000,
          minEnergyIncrementAtChargingStation: 5000,
          waypointChargingStations: [
            null,
            EvWaypointChargingStation(
              power: 150000,
              currentType: EvCurrentType.DC,
              stationId: 'FR*ABC*E123',
              minimalStopTime: 600,
            ),
            null,
          ],
        ),
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

const _two = [
  [1.0, 2.0],
  [3.0, 4.0],
];

String _n(Enum e) => e.toString().split('.').last.toLowerCase();

/// One case per enum value for every builder, so each value's wire string is
/// pinned in every endpoint (the request builders used to duplicate these
/// mappings, and some of them differ).
Map<String, Future<Object?> Function()> _edgeCases() {
  final cases = <String, Future<Object?> Function()>{};

  for (final p in NavigationProfile.values) {
    cases['edge/directions/profile-${_n(p)}'] =
        () => _api.directions.request(profile: p, coordinates: _two);
    cases['edge/map_matching/profile-${_n(p)}'] =
        () => _api.mapMatching!.request(profile: p, coordinates: _two);
    cases['edge/isochrone/profile-${_n(p)}'] = () => _api.isochrone!
        .request(profile: p, coordinates: [1.0, 2.0], contoursMinutes: [5]);
    cases['edge/matrix/profile-${_n(p)}'] = () =>
        _api.matrix!.request(profile: p, coordinates: _two, destinations: []);
    cases['edge/optimization/profile-${_n(p)}'] =
        () => _api.optimization!.request(profile: p, coordinates: _two);
  }

  for (final g in NavigationGeometries.values) {
    cases['edge/directions/geometries-${_n(g)}'] =
        () => _api.directions.request(coordinates: _two, geometries: g);
    cases['edge/map_matching/geometries-${_n(g)}'] =
        () => _api.mapMatching!.request(coordinates: _two, geometries: g);
    cases['edge/optimization/geometries-${_n(g)}'] =
        () => _api.optimization!.request(coordinates: _two, geometries: g);
  }

  for (final o in NavigationOverview.values) {
    cases['edge/directions/overview-${_n(o)}'] =
        () => _api.directions.request(coordinates: _two, overview: o);
    cases['edge/map_matching/overview-${_n(o)}'] =
        () => _api.mapMatching!.request(coordinates: _two, overview: o);
    // Known 1.1.0 bug: NONE sends `overview=false ` (trailing space).
    cases['edge/optimization/overview-${_n(o)}'] =
        () => _api.optimization!.request(coordinates: _two, overview: o);
  }

  for (final a in NavigationApproaches.values) {
    cases['edge/map_matching/approaches-${_n(a)}'] =
        () => _api.mapMatching!.request(coordinates: _two, approaches: a);
  }

  for (final u in NavigationVoiceUnits.values) {
    cases['edge/directions/voice_units-${_n(u)}'] =
        () => _api.directions.request(coordinates: _two, voiceUnits: u);
  }

  // Every annotation, in every builder. Matrix drops SPEED and CONGESTION,
  // optimization drops CONGESTION, but both keep the separator.
  const allAnnotations = NavigationAnnotations.values;
  cases['edge/directions/annotations-all'] = () =>
      _api.directions.request(coordinates: _two, annotations: allAnnotations);
  cases['edge/map_matching/annotations-all'] = () =>
      _api.mapMatching!.request(coordinates: _two, annotations: allAnnotations);
  cases['edge/matrix/annotations-all'] = () => _api.matrix!.request(
      coordinates: _two, annotations: allAnnotations, destinations: []);
  cases['edge/optimization/annotations-all'] = () => _api.optimization!
      .request(coordinates: _two, annotations: allAnnotations);

  // Every place type (EMPTY maps to an empty string), in every geocoder.
  const allTypes = GeocoderPlaceType.values;
  cases['edge/forward/types-all'] =
      () => _api.forwardGeocoding.request(searchText: 'x', types: allTypes);
  cases['edge/forward/batch-types-all'] =
      () => _api.forwardGeocoding.batch(searchTexts: ['x'], types: allTypes);
  cases['edge/reverse/types-all'] = () =>
      _api.reverseGeocoding.request(coordinate: [1.0, 2.0], types: allTypes);
  cases['edge/reverse/batch-types-all'] = () => _api.reverseGeocoding.batch(
        coordinates: [
          [1.0, 2.0],
        ],
        types: allTypes,
      );
  cases['edge/intersection/types-all'] = () =>
      _api.intersection.request(street1: 'a', street2: 'b', types: allTypes);

  // Empty lists.
  cases['edge/forward/batch-empty'] = () => _api.forwardGeocoding.batch();
  cases['edge/reverse/batch-empty'] = () => _api.reverseGeocoding.batch();
  cases['edge/map_matching/no-coordinates'] = () => _api.mapMatching!.request();
  cases['edge/directions/no-coordinates'] = () => _api.directions.request();

  // Known 1.1.0 bug: the `;` after each distribution depends on the number
  // of coordinates, not of distributions.
  cases['edge/optimization/distributions-more-than-coordinates'] =
      () => _api.optimization!.request(
            coordinates: _two,
            distributions: [
              [0, 1],
              [1, 0],
              [0, 1],
            ],
          );
  cases['edge/optimization/distributions-fewer-than-coordinates'] =
      () => _api.optimization!.request(
            coordinates: [
              [1.0, 2.0],
              [3.0, 4.0],
              [5.0, 6.0],
            ],
            distributions: [
              [0, 1],
              [1, 2],
            ],
          );

  // Directions approaches/bearings/radiuses with a single element (no
  // separator) and doubles that print with an exponent.
  cases['edge/directions/single-elements'] = () => _api.directions.request(
        coordinates: [
          [1e-7, 123456789012345678901.0],
          [3.0, 4.0],
        ],
        approaches: [NavigationApproaches.UNRESTRICTED],
        bearings: [NavigationBearings(1, 2)],
        radiuses: [double.infinity],
        waypointNames: ['only'],
      );

  return cases;
}
