import '../../mapbox_api.dart';
import '../http_helpers.dart';
import '../url_helpers.dart';

/// The Mapbox Directions API will show you how to get where you're going.
///
/// https://docs.mapbox.com/api/navigation/#directions
class DirectionsApi {
  DirectionsApi(
    this.api, {
    this.version = 'v5',
    this.endpoint = 'https://api.mapbox.com/directions',
  });

  /// Retrieve directions between waypoints.
  /// Directions requests must specify at least two waypoints
  /// as starting and ending points.
  ///
  /// Driving-profile options (sent as given; the API reports unsupported
  /// combinations in `error`):
  /// - [maxHeight] / [maxWidth] (meters, 0–10) and [maxWeight] (metric tons,
  ///   0–100) avoid roads the vehicle cannot use.
  ///   When no compliant route exists, Mapbox still returns one and reports
  ///   the violation in [NavigationLeg.notifications].
  /// - [departAt] (`driving`, `driving-traffic`) or [arriveBy] (`driving`)
  ///   plan for a time; sent in UTC.
  /// - [include] allows HOV/HOT lanes; [avoidManeuverRadius] (meters,
  ///   1–1000) avoids maneuvers right after the start, e.g. while moving.
  ///   It cannot be combined with [departAt] or [arriveBy].
  Future<DirectionsApiResponse> request({
    NavigationProfile? profile,
    List<List<double>> coordinates = const <List<double>>[],
    bool alternatives = false,
    List<NavigationAnnotations> annotations = const <NavigationAnnotations>[],
    List<NavigationBearings> bearings = const <NavigationBearings>[],
    bool continueStraight = false,
    List<NavigationExclude> excludes = const <NavigationExclude>[],
    NavigationGeometries geometries = NavigationGeometries.POLYLINE,
    NavigationOverview overview = NavigationOverview.SIMPLIFIED,
    List<double> radiuses = const <double>[],
    List<NavigationApproaches> approaches = const <NavigationApproaches>[],
    bool steps = false,
    bool bannerInstructions = false,
    String language = 'en',
    bool roundaboutExits = false,
    bool voiceInstructions = false,
    NavigationVoiceUnits voiceUnits = NavigationVoiceUnits.IMPERIAL,
    List<String> waypointNames = const <String>[],
    List<List<double>> waypointTargets = const <List<double>>[],
    List<List<double>> waypoints = const <List<double>>[],
    double walkingSpeed = 1.42,
    double walkwayBias = 0,
    double alleyBias = 0,
    List<NavigationInclude> include = const <NavigationInclude>[],
    double? maxHeight,
    double? maxWidth,
    double? maxWeight,
    DateTime? departAt,
    DateTime? arriveBy,
    double? avoidManeuverRadius,
  }) async {
    if (api.accessToken == null) {
      throw missingAccessToken();
    }

    var url = '$endpoint/$version${profilePath(profile)}';

    if (coordinates.isNotEmpty) {
      url += '/${coordinates.map(lonLat).join(';')}';
    }

    url += '?access_token=${api.accessToken!}';

    if (profile == NavigationProfile.WALKING) {
      if (walkingSpeed != 1.42) {
        url += '&walking_speed=$walkingSpeed';
      }
      if (walkwayBias != 0) {
        url += '&walkway_bias=$walkwayBias';
      }
      if (alleyBias != 0) {
        url += '&alley_bias=$alleyBias';
      }
    }

    if (language != 'en') {
      url += '&language=${encode(language)}';
    }
    if (steps) {
      url += '&steps=true';
    }
    if (alternatives) {
      url += '&alternatives=true';
    }
    if (bannerInstructions) {
      url += '&banner_instructions=true';
    }
    if (roundaboutExits) {
      url += '&roundabout_exits=true';
    }
    if (voiceInstructions) {
      url += '&voice_instructions=true';
    }
    // Mapbox's default depends on the profile (true for driving, false for
    // walking/cycling), so `false` means "API default" and is not sent.
    if (continueStraight) {
      url += '&continue_straight=true';
    }

    url += geometries.query;
    url += overview.query;
    url += listParam('approaches', approaches.map((a) => a.value), ';');
    url += listParam('bearings', bearings.map(bearingValue), ';');

    if (voiceUnits == NavigationVoiceUnits.METRIC) {
      url += '&voice_units=metric';
    }

    url += listParam('radiuses', radiuses.map(radiusValue), ';');
    url += listParam('waypoint_names', waypointNames.map(encode), ';');
    url += listParam('waypoint_targets', waypointTargets.map(lonLat), ';');
    url += listParam('waypoints', waypoints.map(lonLat), ';');
    url += listParam('annotations', annotations.map((a) => a.value), ',');
    url += listParam('exclude', excludes.map((e) => e.value), ',');
    url += listParam('include', include.map((i) => i.value), ',');

    if (maxHeight != null) {
      url += '&max_height=$maxHeight';
    }
    if (maxWidth != null) {
      url += '&max_width=$maxWidth';
    }
    if (maxWeight != null) {
      url += '&max_weight=$maxWeight';
    }
    if (departAt != null) {
      url += '&depart_at=${mapboxDateTime(departAt)}';
    }
    if (arriveBy != null) {
      url += '&arrive_by=${mapboxDateTime(arriveBy)}';
    }
    if (avoidManeuverRadius != null) {
      url += '&avoid_maneuver_radius=$avoidManeuverRadius';
    }

    final result = await fetchJson(api, url);
    final json = result.json;
    if (json == null) {
      return DirectionsApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return DirectionsApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      // On a non-2xx response, keep the HTTP error: the body may not have
      // the shape of a successful response.
      return DirectionsApiResponse.withError(result.error ?? error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}

/// Response of [DirectionsApi.request]. Check [error] first.
class DirectionsApiResponse {
  DirectionsApiResponse({
    this.code,
    this.uuid,
    this.waypoints,
    this.routes,
    this.error,
  });

  DirectionsApiResponse.withError(Error this.error);

  DirectionsApiResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'] as String?;
    uuid = json['uuid'] as String?;

    switch (code) {
      case 'NoRoute':
        error = NavigationNoRouteError();
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
      waypoints = List<NavigationWaypoint>.from(
        (json['waypoints'] as List<dynamic>).map(
          (waypoint) => NavigationWaypoint.fromJson(
            waypoint as Map<String, dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('routes') && json['routes'] != null) {
      routes = List<NavigationRoute>.from(
        (json['routes'] as List<dynamic>).map(
          (route) => NavigationRoute.fromJson(
            route as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  String? code;
  String? uuid;
  List<NavigationWaypoint>? waypoints;
  List<NavigationRoute>? routes;
  Error? error;
}
