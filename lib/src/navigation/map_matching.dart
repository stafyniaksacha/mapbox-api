import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';

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
    var url = endpoint + '/' + version;

    if (profile != null) {
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
      } else {
        url += '.json';
      }
    }

    url += '?access_token=' + api.accessToken!;

    if (language != 'en') {
      url += '&language=' + language;
    }
    if (steps) {
      url += '&steps=true';
    }
    if (tidy) {
      url += '&tidy=true';
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

    switch (approaches) {
      case NavigationApproaches.CURB:
        url += '&approaches=curb';
        break;
      case NavigationApproaches.UNRESTRICTED:
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
      return MapMatchingApiResponse.fromJson(json);
    } on Error catch (error) {
      return MapMatchingApiResponse.withError(error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}

class MapMatchingApiResponse {
  MapMatchingApiResponse({
    this.code,
    this.uuid,
    this.matchings,
    this.tracepoints,
    this.error,
  });

  MapMatchingApiResponse.withError(Error error) {
    error = error;
  }

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
      tracepoints = List<NavigationTracepoint>.from(
        (json['tracepoints'] as List<dynamic>).map(
          (route) => NavigationTracepoint.fromJson(
            route as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  String? code;
  String? uuid;
  List<NavigationMatchRoute>? matchings;
  List<NavigationTracepoint>? tracepoints;
  Error? error;
}
