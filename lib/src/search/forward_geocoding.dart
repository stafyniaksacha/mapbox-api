import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';
import '../url_helpers.dart';

/// The forward geocoding query type allows you to look up
/// a single location by name and returns its geographic coordinates.
///
/// https://docs.mapbox.com/api/search/#forward-geocoding
class ForwardGeocodingApi {
  ForwardGeocodingApi(
    this.api, {
    this.version = 'v5',
    this.endpoint = 'https://api.mapbox.com/geocoding',
  });

  /// The API response for a forward geocoding query returns a
  /// GeoJSON feature collection in Mapbox Geocoding Response format.
  Future<GeocodingApiResponse> request({
    GeocoderEndpoint endpoint = GeocoderEndpoint.PLACES,
    String? searchText,
    bool autocomplete = true,
    GeocoderBbox? bbox,
    List<String> country = const <String>[],
    bool fuzzyMatch = true,
    String? language,
    int limit = 5,
    List<double> proximity = const <double>[],
    bool routing = false,
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    var url = '${this.endpoint}/$version${geocoderEndpointPath(endpoint)}';

    url += '/$searchText.json';

    url += _urlQuery(
      autocomplete: autocomplete,
      bbox: bbox,
      country: country,
      fuzzyMatch: fuzzyMatch,
      language: language,
      limit: limit,
      proximity: proximity,
      routing: routing,
      types: types,
    );

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return GeocodingApiResponse.fromJson(json);
    } on Error catch (error) {
      return GeocodingApiResponse.withError(error);
    }
  }

  /// The batch geocoding query type allows you to have
  /// multiple forward geocoding queries in a single request
  Future<GeocodingApiResponse> batch({
    GeocoderEndpoint endpoint = GeocoderEndpoint.PLACES_PERMANENT,
    List<String> searchTexts = const <String>[],
    bool autocomplete = true,
    GeocoderBbox? bbox,
    List<String> country = const <String>[],
    bool fuzzyMatch = true,
    String? language,
    int limit = 5,
    List<double> proximity = const <double>[],
    bool routing = false,
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
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

    if (searchTexts.isNotEmpty) {
      url += '/${searchTexts.join(';')}.json';
    }

    url += _urlQuery(
      autocomplete: autocomplete,
      bbox: bbox,
      country: country,
      fuzzyMatch: fuzzyMatch,
      language: language,
      limit: limit,
      proximity: proximity,
      routing: routing,
      types: types,
    );

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return GeocodingApiResponse.fromJson(json);
    } on Error catch (error) {
      return GeocodingApiResponse.withError(error);
    }
  }

  String _urlQuery({
    bool? autocomplete,
    GeocoderBbox? bbox,
    List<String>? country,
    bool? fuzzyMatch,
    String? language,
    int? limit,
    List<double>? proximity,
    bool? routing,
    List<GeocoderPlaceType>? types,
  }) {
    var url = '?access_token=${api.accessToken!}';

    if (autocomplete != null && !autocomplete) {
      url += '&autocomplete=false';
    }

    if (fuzzyMatch != null && !fuzzyMatch) {
      url += '&fuzzyMatch=false';
    }

    if (routing != null && routing) {
      url += '&routing=true';
    }

    if (language != null) {
      url += '&language=$language';
    }

    if (limit != null && limit != 5) {
      url += '&limit=$limit';
    }

    if (bbox != null) {
      url += '&bbox=${bbox.minX},${bbox.minY},${bbox.maxX},${bbox.maxY}';
    }

    url += listParam('country', country ?? const [], ',');
    url += listParam('types', (types ?? const []).map((t) => t.value), ',');

    if (proximity != null && proximity.isNotEmpty) {
      url += '&proximity=${lonLat(proximity)}';
    }

    return url;
  }

  String version;
  String endpoint;
  MapboxApi api;
}
