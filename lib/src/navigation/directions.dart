import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';
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
  }) async {
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
      url += '&language=$language';
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

    url += geometries.query;
    url += overview.query;
    url += listParam('approaches', approaches.map((a) => a.value), ';');
    url += listParam('bearings', bearings.map(bearingValue), ';');

    if (voiceUnits == NavigationVoiceUnits.METRIC) {
      url += '&voice_units=metric';
    }

    url += listParam('radiuses', radiuses.map(radiusValue), ',');
    url += listParam('waypoint_names', waypointNames, ',');
    url += listParam('waypoint_targets', waypointTargets.map(lonLat), ';');
    url += listParam('waypoints', waypoints.map(lonLat), ';');
    url += listParam('annotations', annotations.map((a) => a.value), ',');

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return DirectionsApiResponse.fromJson(json);
    } on Error catch (error) {
      return DirectionsApiResponse.withError(error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}

class DirectionsApiResponse {
  DirectionsApiResponse({
    this.code,
    this.uuid,
    this.waypoints,
    this.routes,
    this.error,
  });

  DirectionsApiResponse.withError(Error error) {
    error = error;
  }

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
