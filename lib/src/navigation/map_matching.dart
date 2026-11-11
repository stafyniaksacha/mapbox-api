import '../../mapbox_api.dart';
import '../http_helpers.dart';
import '../url_helpers.dart';

/// The Mapbox Map Matching API snaps fuzzy,
/// inaccurate traces from a GPS unit or a phone
/// to the OpenStreetMap road and path network using the Directions API.
///
/// https://docs.mapbox.com/api/navigation/#map-matching
class MapMatchingApi {
  MapMatchingApi(
    this.api, {
    this.version = 'v5',
    this.endpoint = 'https://api.mapbox.com/matching',
  });

  /// Return a path on the road and path network that is
  /// closest to the input traces.
  Future<MapMatchingApiResponse> request({
    NavigationProfile? profile,
    List<List<double>> coordinates = const <List<double>>[],
    List<NavigationAnnotations> annotations = const <NavigationAnnotations>[],
    NavigationApproaches approaches = NavigationApproaches.UNRESTRICTED,
    NavigationGeometries geometries = NavigationGeometries.POLYLINE,
    String language = 'en',
    NavigationOverview overview = NavigationOverview.SIMPLIFIED,
    List<double> radiuses = const <double>[],
    bool steps = false,
    bool tidy = false,
    List<int> timestamps = const <int>[],
    List<String> waypointNames = const <String>[],
    List<List<double>> waypoints = const <List<double>>[],
  }) async {
    if (api.accessToken == null) {
      throw missingAccessToken();
    }

    var url = '$endpoint/$version${profilePath(profile)}';

    if (coordinates.isNotEmpty) {
      url += '/${coordinates.map(lonLat).join(';')}.json';
    }

    url += '?access_token=${api.accessToken!}';

    if (language != 'en') {
      url += '&language=${encode(language)}';
    }
    if (steps) {
      url += '&steps=true';
    }
    if (tidy) {
      url += '&tidy=true';
    }

    url += geometries.query;
    url += overview.query;

    if (approaches == NavigationApproaches.CURB) {
      url += '&approaches=curb';
    }

    url += listParam('radiuses', radiuses.map(radiusValue), ';');
    url += listParam('waypoint_names', waypointNames.map(encode), ';');
    url += listParam('waypoints', waypoints.map(lonLat), ';');
    // Annotations added for Directions in 1.2.0 are not sent to Map Matching.
    url += listParam(
      'annotations',
      annotations
          .where(
            (a) =>
                a == NavigationAnnotations.DURATION ||
                a == NavigationAnnotations.DISTANCE ||
                a == NavigationAnnotations.SPEED ||
                a == NavigationAnnotations.CONGESTION,
          )
          .map((a) => a.value),
      ',',
    );
    url += listParam('timestamps', timestamps.map((t) => '$t'), ';');

    final result = await fetchJson(api, url);
    final json = result.json;
    if (json == null) {
      return MapMatchingApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return MapMatchingApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      // On a non-2xx response, keep the HTTP error: the body may not have
      // the shape of a successful response.
      return MapMatchingApiResponse.withError(result.error ?? error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}

/// Response of [MapMatchingApi.request]. Check [error] first.
class MapMatchingApiResponse {
  MapMatchingApiResponse({
    this.code,
    this.uuid,
    this.matchings,
    this.tracepoints,
    this.error,
  });

  MapMatchingApiResponse.withError(Error this.error);

  MapMatchingApiResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'] as String?;
    uuid = json['uuid'] as String?;

    switch (code) {
      case 'NoMatch':
        error = NavigationNoMatchError();
        break;
      case 'NoSegment':
        error = NavigationNoSegmentError();
        break;
      case 'TooManyCoordinates':
        error = NavigationTooManyCoordinatesError();
        break;
      case 'ProfileNotFound':
        error = NavigationProfileNotFoundError();
        break;
      case 'InvalidInput':
        error = NavigationInvalidInputError();
        break;
    }

    if (json.containsKey('matchings') && json['matchings'] != null) {
      matchings = List<NavigationMatchRoute>.from(
        (json['matchings'] as List<dynamic>).map(
          (match) => NavigationMatchRoute.fromJson(
            match as Map<String, dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('tracepoints') && json['tracepoints'] != null) {
      // Unmatched input points are `null` in the response. They become an
      // empty NavigationTracepoint (all fields null) so that indexes keep
      // matching the input coordinates.
      tracepoints = [
        for (final tracepoint in json['tracepoints'] as List<dynamic>)
          tracepoint == null
              ? NavigationTracepoint()
              : NavigationTracepoint.fromJson(
                  tracepoint as Map<String, dynamic>,
                ),
      ];
    }
  }

  String? code;
  String? uuid;
  List<NavigationMatchRoute>? matchings;
  List<NavigationTracepoint>? tracepoints;
  Error? error;
}
