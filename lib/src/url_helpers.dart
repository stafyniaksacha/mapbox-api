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

/// The geocoding `mapbox.places` / `mapbox.places-permanent` path segment.
String geocoderEndpointPath(GeocoderEndpoint endpoint) =>
    endpoint == GeocoderEndpoint.PLACES_PERMANENT
        ? '/mapbox.places-permanent'
        : '/mapbox.places';
