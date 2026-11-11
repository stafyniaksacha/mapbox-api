import '../../mapbox_api.dart';
import '../http_helpers.dart';
import '../url_helpers.dart';

/// The Mapbox Optimization API returns a duration-optimized route
/// between the input coordinates.
///
/// https://docs.mapbox.com/api/navigation/#optimization
class OptimizationApi {
  OptimizationApi(
    this.api, {
    this.version = 'v1',
    this.endpoint = 'https://api.mapbox.com/optimized-trips',
  });

  /// A call to this endpoint retrieves a duration-optimized
  /// route between input coordinates.
  Future<OptimizationApiResponse> request({
    NavigationProfile? profile,
    List<List<double>> coordinates = const <List<double>>[],
    List<NavigationAnnotations> annotations = const <NavigationAnnotations>[],
    List<NavigationApproaches> approaches = const <NavigationApproaches>[],
    List<NavigationBearings> bearings = const <NavigationBearings>[],
    NavigationDestination destination = NavigationDestination.ANY,
    List<List<int>> distributions = const <List<int>>[],
    NavigationGeometries geometries = NavigationGeometries.POLYLINE,
    String language = 'en',
    NavigationOverview overview = NavigationOverview.SIMPLIFIED,
    List<double> radiuses = const <double>[],
    NavigationSource source = NavigationSource.ANY,
    bool steps = false,
    bool roundtrip = true,
  }) async {
    if (api.accessToken == null) {
      throw missingAccessToken();
    }

    var url = '$endpoint/$version${profilePath(profile)}';

    if (coordinates.isNotEmpty) {
      url += '/${coordinates.map(lonLat).join(';')}';
    }

    url += '?access_token=${api.accessToken!}';

    if (language != 'en') {
      url += '&language=${encode(language)}';
    }
    if (steps) {
      url += '&steps=true';
    }
    if (!roundtrip) {
      url += '&roundtrip=false';
    }
    if (destination == NavigationDestination.LAST) {
      url += '&destination=last';
    }
    if (source == NavigationSource.FIRST) {
      url += '&source=first';
    }

    url += geometries.query;
    url += overview.query;
    url += listParam(
      'distributions',
      distributions.map((pair) => '${pair[0]},${pair[1]}'),
      ';',
    );
    url += listParam('radiuses', radiuses.map(radiusValue), ';');
    // The Optimization API does not support congestion annotations.
    url += listParam(
      'annotations',
      annotations
          .where((a) => a != NavigationAnnotations.CONGESTION)
          .map((a) => a.value),
      ',',
    );
    url += listParam('bearings', bearings.map(bearingValue), ';');
    url += listParam('approaches', approaches.map((a) => a.value), ';');

    final result = await fetchJson(url);
    final json = result.json;
    if (json == null) {
      return OptimizationApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return OptimizationApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      // On a non-2xx response, keep the HTTP error: the body may not have
      // the shape of a successful response.
      return OptimizationApiResponse.withError(result.error ?? error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}

class OptimizationApiResponse {
  OptimizationApiResponse({
    this.code,
    this.uuid,
    this.waypoints,
    this.trips,
    this.error,
  });

  OptimizationApiResponse.withError(Error this.error);

  OptimizationApiResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'] as String?;
    uuid = json['uuid'] as String?;

    switch (code) {
      case 'NoTrips':
        error = NavigationNoTripsError();
        break;
      case 'NotImplemented':
        error = NavigationNotImplementedError();
        break;
      case 'NoSegment':
        error = NavigationNoSegmentError();
        break;
      case 'ProfileNotFound':
        error = NavigationProfileNotFoundError();
        break;
      case 'InvalidInput':
        error = NavigationInvalidInputError();
        break;
    }

    if (json.containsKey('waypoints') && json['waypoints'] != null) {
      waypoints = List<NavigationOptimizedWaypoint>.from(
        (json['waypoints'] as List<dynamic>).map(
          (waypoint) => NavigationOptimizedWaypoint.fromJson(
            waypoint as Map<String, dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('trips') && json['trips'] != null) {
      trips = List<NavigationRoute>.from(
        (json['trips'] as List<dynamic>).map(
          (trip) => NavigationRoute.fromJson(
            trip as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  String? code;
  String? uuid;
  List<NavigationOptimizedWaypoint>? waypoints;
  List<NavigationRoute>? trips;
  Error? error;
}
