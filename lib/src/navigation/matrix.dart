import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';
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
    var url = '$endpoint/$version${profilePath(profile)}';

    if (coordinates.isNotEmpty) {
      url += '/${coordinates.map(lonLat).join(';')}';
    }

    url += '?access_token=${api.accessToken!}';

    // The Matrix API does not support speed and congestion annotations.
    // 1.1.0 sends an empty value for them (separator kept).
    url += listParam(
      'annotations',
      annotations.map(
        (a) => switch (a) {
          NavigationAnnotations.SPEED || NavigationAnnotations.CONGESTION => '',
          _ => a.value,
        },
      ),
      ',',
    );
    url += listParam('approaches', approaches.map((a) => a.value), ';');
    // Known 1.1.0 bug: throws when `destinations` is omitted (null).
    url += listParam('destinations', destinations!.map((d) => '$d'), ',');
    url += listParam('sources', sources.map((s) => '$s'), ',');

    if (fallbackSpeed != 0) {
      url += '&fallback_speed=$fallbackSpeed';
    }

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return MatrixApiResponse.fromJson(json);
    } on Error catch (error) {
      return MatrixApiResponse.withError(error);
    }
  }
}

class MatrixApiResponse {
  String? code;
  List<NavigationWaypoint>? destinations;
  List<List<double>>? distances;
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
      case 'ProfileNotFound':
        error = NavigationProfileNotFoundError();
        break;
      case 'InvalidInput':
        error = NavigationInvalidInputError();
        break;
    }

    if (json.containsKey('durations') && json['durations'] != null) {
      durations = List<List<double>>.from(
        (json['durations'] as List<dynamic>).map(
          (durations) => List<double>.from(
            durations as List<dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('distances') && json['distances'] != null) {
      distances = List<List<double>>.from(
        (json['distances'] as List<dynamic>).map(
          (duration) => List<double>.from(
            duration as List<dynamic>,
          ),
        ),
      );
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

  MatrixApiResponse.withError(Error error) {
    error = error;
  }
}
