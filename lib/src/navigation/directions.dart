import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';

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
    NavigationProfile profile,
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
    var url = endpoint + '/' + version;

    switch (profile) {
      case NavigationProfile.DRIVING_TRAFFIC:
        url += '/mapbox/driving-traffic';
        break;
      case NavigationProfile.DRIVING:
        url += '/mapbox/driving';
        break;
      case NavigationProfile.CYCLING:
        url += '/mapbox/cycling';
        break;
      case NavigationProfile.WALKING:
        url += '/mapbox/walking';
        break;
    }

    for (var i = 0; i < coordinates.length; i++) {
      if (i == 0) {
        url += '/';
      }

      url += coordinates[i][LONGITUDE].toString();
      url += ',';
      url += coordinates[i][LATITUDE].toString();

      if (i != coordinates.length - 1) {
        url += ';';
      }
    }

    url += '?access_token=' + api.accessToken;

    if (profile == NavigationProfile.WALKING) {
      if (walkingSpeed != 1.42) {
        url += '&walking_speed=' + walkingSpeed.toString();
      }
      if (walkwayBias != 0) {
        url += '&walkway_bias=' + walkwayBias.toString();
      }
      if (alleyBias != 0) {
        url += '&alley_bias=' + alleyBias.toString();
      }
    }

    if (language != 'en') {
      url += '&language=' + language;
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

    switch (geometries) {
      case NavigationGeometries.GEOJSON:
        url += '&geometries=geojson';
        break;
      case NavigationGeometries.POLYLINE6:
        url += '&geometries=polyline6';
        break;
      case NavigationGeometries.POLYLINE:
        break;
    }

    switch (overview) {
      case NavigationOverview.FULL:
        url += '&overview=full';
        break;
      case NavigationOverview.NONE:
        url += '&overview=false';
        break;
      case NavigationOverview.SIMPLIFIED:
        break;
    }

    for (var i = 0; i < approaches.length; i++) {
      if (i == 0) {
        url += '&approaches=';
      }

      switch (approaches[i]) {
        case NavigationApproaches.CURB:
          url += 'curb';
          break;
        case NavigationApproaches.UNRESTRICTED:
          url += 'unrestricted';
          break;
      }

      if (i != approaches.length - 1) {
        url += ';';
      }
    }

    for (var i = 0; i < bearings.length; i++) {
      if (i == 0) {
        url += '&bearings=';
      }

      url += bearings[i].angle.toString();
      url += ',';
      url += bearings[i].degree.toString();

      if (i != bearings.length - 1) {
        url += ';';
      }
    }

    switch (voiceUnits) {
      case NavigationVoiceUnits.METRIC:
        url += '&voice_units=metric';
        break;
      case NavigationVoiceUnits.IMPERIAL:
        break;
    }

    for (var i = 0; i < radiuses.length; i++) {
      if (i == 0) {
        url += '&radiuses=';
      }

      if (radiuses[i] == double.infinity) {
        url += 'unlimited';
      } else {
        url += radiuses[i].toString();
      }

      if (i != radiuses.length - 1) {
        url += ',';
      }
    }

    for (var i = 0; i < waypointNames.length; i++) {
      if (i == 0) {
        url += '&waypoint_names=';
      }

      url += waypointNames[i];

      if (i != waypointNames.length - 1) {
        url += ',';
      }
    }

    for (var i = 0; i < waypointTargets.length; i++) {
      if (i == 0) {
        url += '&waypoint_targets=';
      }

      url += waypointTargets[i][LONGITUDE].toString();
      url += ',';
      url += waypointTargets[i][LATITUDE].toString();

      if (i != waypointTargets.length - 1) {
        url += ';';
      }
    }

    for (var i = 0; i < waypoints.length; i++) {
      if (i == 0) {
        url += '&waypoints=';
      }

      url += waypoints[i][LONGITUDE].toString();
      url += ',';
      url += waypoints[i][LATITUDE].toString();

      if (i != waypoints.length - 1) {
        url += ';';
      }
    }

    for (var i = 0; i < annotations.length; i++) {
      if (i == 0) {
        url += '&annotations=';
      }

      switch (annotations[i]) {
        case NavigationAnnotations.DURATION:
          url += 'duration';
          break;
        case NavigationAnnotations.DISTANCE:
          url += 'distance';
          break;
        case NavigationAnnotations.SPEED:
          url += 'speed';
          break;
        case NavigationAnnotations.CONGESTION:
          url += 'congestion';
          break;
      }

      if (i != annotations.length - 1) {
        url += ',';
      }
    }

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return DirectionsApiResponse.fromJson(json);
    } catch (error) {
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
    code = json['code'] as String;
    uuid = json['uuid'] as String;

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

  String code;
  String uuid;
  List<NavigationWaypoint> waypoints;
  List<NavigationRoute> routes;
  Error error;
}
