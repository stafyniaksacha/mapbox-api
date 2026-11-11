import '../../mapbox_api.dart';
import '../http_helpers.dart';
import '../json_helpers.dart';
import '../url_helpers.dart';

/// The Mapbox Matrix API returns travel times between many points.
///
/// https://docs.mapbox.com/api/navigation/#matrix
class MatrixApi {
  MapboxApi api;
  String version;
  String endpoint;

  MatrixApi(
    this.api, {
    this.version = 'v1',
    this.endpoint = 'https://api.mapbox.com/directions-matrix',
  });

  /// Returns a duration matrix, a distance matrix, or both,
  /// showing travel times and distances between coordinates.
  /// In the default case, this endpoint returns a symmetric matrix that uses
  /// all the input coordinates as sources and destinations.
  /// Using the optional sources and destination parameters,
  /// you can also generate an asymmetric matrix that uses only
  /// some coordinates as sources or destinations.
  Future<MatrixApiResponse> request({
    NavigationProfile? profile,
    List<List<double>> coordinates = const <List<double>>[],
    List<NavigationAnnotations> annotations = const <NavigationAnnotations>[],
    List<NavigationApproaches> approaches = const <NavigationApproaches>[],
    List<int>? destinations,
    int fallbackSpeed = 0,
    List<int> sources = const <int>[],
  }) async {
    if (api.accessToken == null) {
      return MatrixApiResponse.withError(missingAccessToken());
    }

    var url = '$endpoint/$version${profilePath(profile)}';

    if (coordinates.isNotEmpty) {
      url += '/${coordinates.map(lonLat).join(';')}';
    }

    url += '?access_token=${api.accessToken!}';

    // The Matrix API only supports duration and distance annotations.
    url += listParam(
      'annotations',
      annotations
          .where(
            (a) =>
                a == NavigationAnnotations.DURATION ||
                a == NavigationAnnotations.DISTANCE,
          )
          .map((a) => a.value),
      ',',
    );
    url += listParam('approaches', approaches.map((a) => a.value), ';');
    // Omitted (null) or empty means "all coordinates" (API default).
    url += listParam(
      'destinations',
      (destinations ?? const <int>[]).map((d) => '$d'),
      ';',
    );
    url += listParam('sources', sources.map((s) => '$s'), ';');

    if (fallbackSpeed != 0) {
      url += '&fallback_speed=$fallbackSpeed';
    }

    final result = await fetchJson(url);
    final json = result.json;
    if (json == null) {
      return MatrixApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return MatrixApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      return MatrixApiResponse.withError(error);
    }
  }
}

class MatrixApiResponse {
  String? code;
  List<NavigationWaypoint>? destinations;

  /// `distances[i][j]` is from source `i` to destination `j`.
  /// [double.infinity] when there is no route between the two.
  List<List<double>>? distances;

  /// `durations[i][j]` is from source `i` to destination `j`.
  /// [double.infinity] when there is no route between the two.
  List<List<double>>? durations;
  Error? error;
  List<NavigationWaypoint>? sources;
  String? uuid;

  MatrixApiResponse({
    this.code,
    this.destinations,
    this.distances,
    this.durations,
    this.error,
    this.sources,
    this.uuid,
  });

  MatrixApiResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'] as String?;
    uuid = json['uuid'] as String?;

    switch (code) {
      case 'NoRoute':
        error = NavigationNoRouteError();
        break;
      case 'ProfileNotFound':
        error = NavigationProfileNotFoundError();
        break;
      case 'InvalidInput':
        error = NavigationInvalidInputError();
        break;
    }

    if (json.containsKey('durations') && json['durations'] != null) {
      durations = (json['durations'] as List<dynamic>).map(matrixRow).toList();
    }

    if (json.containsKey('distances') && json['distances'] != null) {
      distances = (json['distances'] as List<dynamic>).map(matrixRow).toList();
    }

    if (json.containsKey('destinations') && json['destinations'] != null) {
      destinations = List<NavigationWaypoint>.from(
        (json['destinations'] as List<dynamic>).map(
          (waypoint) => NavigationWaypoint.fromJson(
            waypoint as Map<String, dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('sources') && json['sources'] != null) {
      sources = List<NavigationWaypoint>.from(
        (json['sources'] as List<dynamic>).map(
          (waypoint) => NavigationWaypoint.fromJson(
            waypoint as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  MatrixApiResponse.withError(Error this.error);
}
