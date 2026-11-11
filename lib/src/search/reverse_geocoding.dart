import '../../mapbox_api.dart';
import '../http_helpers.dart';
import '../url_helpers.dart';

/// The reverse geocoding query type allows you to look up a
/// single pair of coordinates and returns the geographic feature
/// or features that exist at that location.
///
/// https://docs.mapbox.com/api/search/#reverse-geocoding
class ReverseGeocodingApi {
  ReverseGeocodingApi(
    this.api, {
    this.version = 'v5',
    this.endpoint = 'https://api.mapbox.com/geocoding',
  });

  /// The API response for a reverse geocoding query returns a
  /// GeoJSON feature collection in Mapbox Geocoding Response format.
  Future<GeocodingApiResponse> request({
    GeocoderEndpoint endpoint = GeocoderEndpoint.PLACES,
    List<double> coordinate = const <double>[],
    List<String> country = const <String>[],
    String? language,
    int limit = 5,
    GeocoderReverseMode reverseMode = GeocoderReverseMode.DISTANCE,
    bool routing = false,
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    if (api.accessToken == null) {
      throw missingAccessToken();
    }

    var url = '${this.endpoint}/$version${geocoderEndpointPath(endpoint)}';

    url += '/${lonLat(coordinate)}.json';

    url += _urlQuery(
      country: country,
      language: language,
      limit: limit,
      reverseMode: reverseMode,
      routing: routing,
      types: types,
    );

    final result = await fetchJson(url);
    final json = result.json;
    if (json == null) {
      return GeocodingApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return GeocodingApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      // On a non-2xx response, keep the HTTP error: the body may not have
      // the shape of a successful response.
      return GeocodingApiResponse.withError(result.error ?? error);
    }
  }

  /// The batch geocoding query type allows you to have
  /// multiple reverse geocoding queries in a single request
  Future<GeocodingApiResponse> batch({
    GeocoderEndpoint endpoint = GeocoderEndpoint.PLACES_PERMANENT,
    List<List<double>> coordinates = const <List<double>>[],
    List<String> country = const <String>[],
    String? language,
    int limit = 5,
    GeocoderReverseMode reverseMode = GeocoderReverseMode.DISTANCE,
    bool routing = false,
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    if (api.accessToken == null) {
      throw missingAccessToken();
    }

    var url = '${this.endpoint}/$version';

    if (endpoint == GeocoderEndpoint.PLACES_PERMANENT) {
      url += '/mapbox.places-permanent';
    } else {
      return GeocodingApiResponse.withError(
        GeocoderError(
          message: 'Batch geocoding is only available using '
              'the mapbox.places-permanent endpoint',
        ),
      );
    }

    if (coordinates.isNotEmpty) {
      url += '/${coordinates.map(lonLat).join(';')}.json';
    }

    url += _urlQuery(
      country: country,
      language: language,
      limit: limit,
      reverseMode: reverseMode,
      routing: routing,
      types: types,
    );

    final result = await fetchJson(url);
    final json = result.json;
    if (json == null) {
      return GeocodingApiResponse.withError(result.error!);
    }

    try {
      // Endpoint-specific errors (e.g. `code: NoRoute`) take precedence over
      // the generic HTTP error.
      return GeocodingApiResponse.fromJson(json)..error ??= result.error;
    } on Error catch (error) {
      // On a non-2xx response, keep the HTTP error: the body may not have
      // the shape of a successful response.
      return GeocodingApiResponse.withError(result.error ?? error);
    }
  }

  String _urlQuery({
    List<String>? country,
    String? language,
    int? limit,
    GeocoderReverseMode? reverseMode,
    bool? routing,
    List<GeocoderPlaceType>? types,
  }) {
    var url = '?access_token=${api.accessToken!}';

    if (routing != null && routing) {
      url += '&routing=true';
    }

    if (language != null) {
      url += '&language=${encode(language)}';
    }

    if (limit != null && limit != 5) {
      url += '&limit=$limit';
    }

    if (reverseMode == GeocoderReverseMode.SCORE) {
      url += '&reverseMode=score';
    }

    url += listParam('country', (country ?? const []).map(encode), ',');
    url += listParam('types', (types ?? const []).map((t) => t.value), ',');

    return url;
  }

  String version;
  String endpoint;
  MapboxApi api;
}
