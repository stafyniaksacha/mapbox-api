// Internal helpers shared by the request builders. Not exported from
// package:mapbox_api, so nothing here is public API.
//
// Every mapping below reproduces the 1.1.0 request URLs exactly; they are
// pinned by test/url_golden_test.dart. Endpoint-specific quirks (e.g. matrix
// dropping some annotations) stay in the endpoint files.

import '../mapbox_api.dart';

/// `longitude,latitude` from a `[latitude, longitude]` pair.
String lonLat(List<double> coordinate) =>
    '${coordinate[LONGITUDE]},${coordinate[LATITUDE]}';

/// `&name=` followed by [values] joined with [separator],
/// or an empty string when there are no values.
String listParam(String name, Iterable<String> values, String separator) {
  final list = values.toList();
  return list.isEmpty ? '' : '&$name=${list.join(separator)}';
}

/// `/mapbox/<profile>`, or an empty string when [profile] is null.
String profilePath(NavigationProfile? profile) => switch (profile) {
      null => '',
      NavigationProfile.DRIVING_TRAFFIC => '/mapbox/driving-traffic',
      NavigationProfile.DRIVING => '/mapbox/driving',
      NavigationProfile.CYCLING => '/mapbox/cycling',
      NavigationProfile.WALKING => '/mapbox/walking',
    };

/// A radius in meters, or `unlimited` for [double.infinity].
String radiusValue(double radius) =>
    radius == double.infinity ? 'unlimited' : radius.toString();

/// `angle,degree`.
String bearingValue(NavigationBearings bearing) =>
    '${bearing.angle},${bearing.degree}';

extension NavigationGeometriesQuery on NavigationGeometries {
  /// The `geometries` parameter; empty for the API default (polyline).
  String get query => switch (this) {
        NavigationGeometries.GEOJSON => '&geometries=geojson',
        NavigationGeometries.POLYLINE6 => '&geometries=polyline6',
        NavigationGeometries.POLYLINE => '',
      };
}

extension NavigationOverviewQuery on NavigationOverview {
  /// The `overview` parameter; empty for the API default (simplified).
  String get query => switch (this) {
        NavigationOverview.FULL => '&overview=full',
        NavigationOverview.NONE => '&overview=false',
        NavigationOverview.SIMPLIFIED => '',
      };
}

extension NavigationApproachesValue on NavigationApproaches {
  String get value => switch (this) {
        NavigationApproaches.CURB => 'curb',
        NavigationApproaches.UNRESTRICTED => 'unrestricted',
      };
}

extension NavigationAnnotationsValue on NavigationAnnotations {
  String get value => switch (this) {
        NavigationAnnotations.DURATION => 'duration',
        NavigationAnnotations.DISTANCE => 'distance',
        NavigationAnnotations.SPEED => 'speed',
        NavigationAnnotations.CONGESTION => 'congestion',
        NavigationAnnotations.MAXSPEED => 'maxspeed',
        NavigationAnnotations.CONGESTION_NUMERIC => 'congestion_numeric',
        NavigationAnnotations.CLOSURE => 'closure',
        NavigationAnnotations.STATE_OF_CHARGE => 'state_of_charge',
      };
}

extension GeocoderPlaceTypeValue on GeocoderPlaceType {
  String get value => switch (this) {
        GeocoderPlaceType.COUNTRY => 'country',
        GeocoderPlaceType.REGION => 'region',
        GeocoderPlaceType.POSTCODE => 'postcode',
        GeocoderPlaceType.DISTRICT => 'district',
        GeocoderPlaceType.PLACE => 'place',
        GeocoderPlaceType.LOCALITY => 'locality',
        GeocoderPlaceType.NEIGHBORHOOD => 'neighborhood',
        GeocoderPlaceType.ADDRESS => 'address',
        GeocoderPlaceType.POI => 'poi',
        GeocoderPlaceType.EMPTY => '',
      };
}

extension NavigationExcludeValue on NavigationExclude {
  String get value => switch (this) {
        NavigationExclude.TOLL => 'toll',
        NavigationExclude.MOTORWAY => 'motorway',
        NavigationExclude.FERRY => 'ferry',
        NavigationExclude.UNPAVED => 'unpaved',
        NavigationExclude.CASH_ONLY_TOLLS => 'cash_only_tolls',
        NavigationExclude.COUNTRY_BORDER => 'country_border',
        NavigationExclude.STATE_BORDER => 'state_border',
        NavigationExclude.TUNNEL => 'tunnel',
      };
}

extension NavigationIncludeValue on NavigationInclude {
  String get value => switch (this) {
        NavigationInclude.HOV2 => 'hov2',
        NavigationInclude.HOV3 => 'hov3',
        NavigationInclude.HOT => 'hot',
      };
}

/// A date-time in the `YYYY-MM-DDThh:mm:ssZ` form the Directions API
/// accepts (UTC, no fractional seconds).
String mapboxDateTime(DateTime dateTime) {
  final utc = dateTime.toUtc();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
      '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:'
      '${two(utc.second)}Z';
}

/// Percent-encodes user-provided text for a URL path segment or query value,
/// so reserved characters (`&`, `#`, `?`, `/`, `;`, …) cannot change the
/// request.
String encode(String text) => Uri.encodeComponent(text);

/// The geocoding `mapbox.places` / `mapbox.places-permanent` path segment.
String geocoderEndpointPath(GeocoderEndpoint endpoint) =>
    endpoint == GeocoderEndpoint.PLACES_PERMANENT
        ? '/mapbox.places-permanent'
        : '/mapbox.places';

/// A number without a trailing `.0` for whole values (`300`, `0.7`).
String numValue(num value) =>
    value == value.truncate() ? value.truncate().toString() : '$value';

extension EvConnectorTypeValue on EvConnectorType {
  String get value => switch (this) {
        EvConnectorType.CCS_COMBO_TYPE1 => 'ccs_combo_type1',
        EvConnectorType.CCS_COMBO_TYPE2 => 'ccs_combo_type2',
        EvConnectorType.CHAOJI => 'chaoji',
        EvConnectorType.CHADEMO => 'chademo',
        EvConnectorType.GBT_DC => 'gbt_dc',
        EvConnectorType.TESLA => 'tesla',
      };
}

extension EvAmenityValue on EvAmenity {
  String get value => switch (this) {
        EvAmenity.LIGHT => 'light',
        EvAmenity.RESTAURANT => 'restaurant',
        EvAmenity.RESTROOM => 'restroom',
        EvAmenity.RECREATION_CENTER => 'recreation_center',
      };
}

extension EvExcludeValue on EvExclude {
  String get value => switch (this) {
        EvExclude.TESLA_EXCLUSIVE => 'tesla_exclusive',
      };
}

extension EvCurrentTypeValue on EvCurrentType {
  String get value => switch (this) {
        EvCurrentType.SINGLE_PHASE_AC => 'single_phase_ac',
        EvCurrentType.THREE_PHASE_AC => 'three_phase_ac',
        EvCurrentType.DC => 'dc',
      };
}

String _chargingCurve(List<EvChargingPoint> curve) => curve
    .map((point) => '${numValue(point.chargeWh)},${numValue(point.powerW)}')
    .join(';');

/// Throws [ArgumentError] for EV options Mapbox would reject, so no request
/// is sent. [coordinateCount] is the number of request coordinates.
void checkEvOptions(DirectionsEvOptions ev, int coordinateCount) {
  void require(bool condition, String message) {
    if (!condition) {
      throw ArgumentError(message, 'ev');
    }
  }

  require(ev.connectorTypes.isNotEmpty, 'connectorTypes must not be empty');
  require(
    ev.energyConsumptionCurve.isNotEmpty,
    'energyConsumptionCurve must not be empty',
  );
  require(ev.chargingCurve.isNotEmpty, 'chargingCurve must not be empty');
  require(
    ev.preConditioningTime == null ||
        (ev.unconditionedChargingCurve?.isNotEmpty ?? false),
    'preConditioningTime requires a non-empty unconditionedChargingCurve',
  );
  require(
    ev.preferChargePointProviderWeights.isEmpty ||
        ev.preferChargePointProviderWeights.length ==
            ev.preferChargePointProviderIds.length,
    'preferChargePointProviderWeights needs one weight per '
    'preferChargePointProviderIds entry',
  );

  final stations = ev.waypointChargingStations;
  if (stations.isNotEmpty) {
    require(
      stations.length == coordinateCount,
      'waypointChargingStations needs one entry per coordinate '
      '(${stations.length} for $coordinateCount coordinates)',
    );
    require(
      stations.first == null,
      'waypointChargingStations: the origin (first entry) must be null',
    );
  }
}

/// The EV routing query parameters (`engine=electric&ev_…`).
String evQuery(DirectionsEvOptions ev) {
  var url = '&engine=electric&ev_max_charge=${ev.maxCharge}';
  url += listParam(
    'ev_connector_types',
    ev.connectorTypes.map((c) => c.value),
    ',',
  );
  url += listParam(
    'energy_consumption_curve',
    ev.energyConsumptionCurve.map(
      (point) => '${numValue(point.speedKph)},${numValue(point.whPerKm)}',
    ),
    ';',
  );
  if (ev.chargingCurve.isNotEmpty) {
    url += '&ev_charging_curve=${_chargingCurve(ev.chargingCurve)}';
  }

  void number(String name, num? value) {
    if (value != null) {
      url += '&$name=${numValue(value)}';
    }
  }

  number('ev_initial_charge', ev.initialCharge);
  final unconditioned = ev.unconditionedChargingCurve;
  if (unconditioned != null && unconditioned.isNotEmpty) {
    url += '&ev_unconditioned_charging_curve=${_chargingCurve(unconditioned)}';
  }
  number('ev_pre_conditioning_time', ev.preConditioningTime);
  number('ev_max_ac_charging_power', ev.maxAcChargingPower);
  number('ev_min_charge_at_destination', ev.minChargeAtDestination);
  number('ev_min_charge_at_charging_station', ev.minChargeAtChargingStation);
  number('ev_ascent', ev.ascent);
  number('ev_descent', ev.descent);
  number('ev_regeneration_efficiency', ev.regenerationEfficiency);
  number('auxiliary_consumption', ev.auxiliaryConsumption);
  if (ev.addChargingStops != null) {
    url += '&ev_add_charging_stops=${ev.addChargingStops}';
  }
  url += listParam(
    'ev_prefer_amenities',
    ev.preferAmenities.map((a) => a.value),
    ',',
  );
  url += listParam(
    'ev_exclude_station_ids',
    ev.excludeStationIds.map(encode),
    ',',
  );
  url += listParam(
    'ev_exclude_charge_point_provider_ids',
    ev.excludeChargePointProviderIds.map(encode),
    ',',
  );
  url += listParam(
    'ev_prefer_charge_point_provider_ids',
    ev.preferChargePointProviderIds.map(encode),
    ',',
  );
  url += listParam(
    'ev_prefer_charge_point_provider_weights',
    ev.preferChargePointProviderWeights.map(numValue),
    ',',
  );
  url += listParam('ev_exclude', ev.exclude.map((e) => e.value), ',');
  number('ev_max_charging_voltage', ev.maxChargingVoltage);
  number(
    'ev_max_charging_power_at_lower_voltage',
    ev.maxChargingPowerAtLowerVoltage,
  );
  number(
    'ev_min_energy_increment_at_charging_station',
    ev.minEnergyIncrementAtChargingStation,
  );

  // One `;`-separated entry per coordinate, empty for non-stations.
  final stations = ev.waypointChargingStations;
  if (stations.any((station) => station != null)) {
    String aligned(String? Function(EvWaypointChargingStation) field) =>
        stations.map((s) => s == null ? '' : field(s) ?? '').join(';');
    url += '&waypoints.charging_station_power=${aligned((s) => '${s.power}')}';
    url += '&waypoints.charging_station_current_type='
        '${aligned((s) => s.currentType.value)}';
    url += '&waypoints.charging_station_id='
        '${aligned((s) => encode(s.stationId))}';
    if (stations.any((s) => s?.minimalStopTime != null)) {
      url += '&waypoints.minimal_stop_time='
          '${aligned((s) => s.minimalStopTime?.toString())}';
    }
  }

  return url;
}
