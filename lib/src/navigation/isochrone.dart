import '../../mapbox_api.dart';
import '../http_helpers.dart';
import '../url_helpers.dart';

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
    if (api.accessToken == null) {
      throw missingAccessToken();
    }

    var url = '$endpoint/$version${profilePath(profile)}';

    url += '/${lonLat(coordinates)}';
    url += '?access_token=${api.accessToken!}';

    url += listParam(
      'contours_minutes',
      contoursMinutes.map((minutes) => '$minutes'),
      ',',
    );
    url += listParam('contours_colors', contoursColors, ',');

    if (polygons) {
      url += '&polygons=true';
    }

    if (denoise != 1.0) {
      url += '&denoise=$denoise';
    }

    if (generalize != null) {
      url += '&generalize=$generalize';
    }

    final result = await fetchJson(api, url);
    final json = result.json;
    if (json == null) {
      return IsochroneApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return IsochroneApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      // On a non-2xx response, keep the HTTP error: the body may not have
      // the shape of a successful response.
      return IsochroneApiResponse.withError(result.error ?? error);
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

  IsochroneApiResponse.withError(Error this.error);

  IsochroneApiResponse.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as String?;

    if (message != null) {
      error = NavigationError(message: message);
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
