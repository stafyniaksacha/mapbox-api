import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';

/// An isochrone is a line that connects points of
/// equal travel time around a given location.
///
/// https://docs.mapbox.com/api/navigation/#isochrone
class IsochroneApi {
  IsochroneApi(
    this.api, {
    this.version = 'v1',
    this.endpoint = 'https://api.mapbox.com/isochrone',
  });

  /// Given a location and a routing profile,
  /// retrieve up to four isochrone contours.
  /// The contours are calculated using rasters and
  /// are returned as either polygon or line features,
  /// depending on your input setting for the polygons parameter.
  Future<IsochroneApiResponse> request({
    NavigationProfile? profile,
    List<double> coordinates = const <double>[],
    List<int> contoursMinutes = const <int>[],
    List<String> contoursColors = const <String>[],
    bool polygons = false,
    double denoise = 1.0,
    double? generalize,
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

    url += '/';
    url += coordinates[LONGITUDE].toString();
    url += ',';
    url += coordinates[LATITUDE].toString();

    url += '?access_token=' + api.accessToken!;

    for (var i = 0; i < contoursMinutes.length; i++) {
      if (i == 0) {
        url += '&contours_minutes=';
      }

      url += contoursMinutes[i].toString();

      if (i != contoursMinutes.length - 1) {
        url += ',';
      }
    }

    for (var i = 0; i < contoursColors.length; i++) {
      if (i == 0) {
        url += '&contours_colors=';
      }

      url += contoursColors[i];

      if (i != contoursColors.length - 1) {
        url += ',';
      }
    }

    if (polygons) {
      url += '&polygons=true';
    }

    if (denoise != 1.0) {
      url += '&denoise=';
      url += denoise.toString();
    }

    if (generalize != null) {
      url += '&generalize=';
      url += generalize.toString();
    }

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return IsochroneApiResponse.fromJson(json);
    } on Error catch (error) {
      return IsochroneApiResponse.withError(error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}

class IsochroneApiResponse {
  IsochroneApiResponse({
    this.code,
    this.uuid,
    this.features,
    this.error,
  });

  IsochroneApiResponse.withError(Error error) {
    error = error;
  }

  IsochroneApiResponse.fromJson(Map<String, dynamic> json) {
    final _message = json['message'] as String?;

    if (_message != null) {
      error = NavigationError(message: _message);
    }

    code = json['code'] as String?;
    uuid = json['uuid'] as String?;

    // todo: handle errors from 'message' field

    if (json.containsKey('features') && json['features'] != null) {
      features = List<NavigationFeature>.from(
        (json['features'] as List<dynamic>).map(
          (match) => NavigationFeature.fromJson(
            match as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  String? code;
  String? uuid;
  List<NavigationFeature>? features;
  Error? error;
}
