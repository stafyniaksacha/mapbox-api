import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';

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
      }
    }

    url += '?access_token=' + api.accessToken!;

    if (language != 'en') {
      url += '&language=' + language;
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
        url += '&overview=false ';
        break;
      case NavigationOverview.SIMPLIFIED:
        break;
    }

    for (var i = 0; i < distributions.length; i++) {
      if (i == 0) {
        url += '&distributions=';
      }

      url += distributions[i][0].toString();
      url += ',';
      url += distributions[i][1].toString();

      if (i != coordinates.length - 1) {
        url += ';';
      }
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
          // not supported
          break;
      }

      if (i != annotations.length - 1) {
        url += ',';
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

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return OptimizationApiResponse.fromJson(json);
    } on Error catch (error) {
      return OptimizationApiResponse.withError(error);
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

  OptimizationApiResponse.withError(Error error) {
    error = error;
  }

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
