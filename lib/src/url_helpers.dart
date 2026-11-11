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
