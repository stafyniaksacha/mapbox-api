import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';

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
    String language,
    int limit = 5,
    GeocoderReverseMode reverseMode = GeocoderReverseMode.DISTANCE,
    bool routing = false,
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    var url = this.endpoint + '/' + version;

    if (endpoint == GeocoderEndpoint.PLACES_PERMANENT) {
      url += '/mapbox.places-permanent';
    } else {
      url += '/mapbox.places';
    }

    url += '/${coordinate[LONGITUDE]},${coordinate[LATITUDE]}.json';

    url += _urlQuery(
      country: country,
      language: language,
      limit: limit,
      reverseMode: reverseMode,
      routing: routing,
      types: types,
    );

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return GeocodingApiResponse.fromJson(json);
    } catch (error) {
      return GeocodingApiResponse.withError(error);
    }
  }

  /// The batch geocoding query type allows you to have
  /// multiple reverse geocoding queries in a single request
  Future<GeocodingApiResponse> batch({
    GeocoderEndpoint endpoint = GeocoderEndpoint.PLACES_PERMANENT,
    List<List<double>> coordinates = const <List<double>>[],
    List<String> country = const <String>[],
    String language,
    int limit = 5,
    GeocoderReverseMode reverseMode = GeocoderReverseMode.DISTANCE,
    bool routing = false,
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    var url = this.endpoint + '/' + version;

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
      for (var i = 0; i < coordinates.length; i++) {
        if (i == 0) {
          url += '/';
        }

        url += '${coordinates[i][LONGITUDE]},${coordinates[i][LATITUDE]}';

        if (i != coordinates.length - 1) {
          url += ';';
        } else {
          url += '.json';
        }
      }
    }

    url += _urlQuery(
      country: country,
      language: language,
      limit: limit,
      reverseMode: reverseMode,
      routing: routing,
      types: types,
    );

    try {
      final response = await get(Uri.parse(url));
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return GeocodingApiResponse.fromJson(json);
    } catch (error) {
      return GeocodingApiResponse.withError(error);
    }
  }

  String _urlQuery({
    List<String> country,
    String language,
    int limit,
    GeocoderReverseMode reverseMode,
    bool routing,
    List<GeocoderPlaceType> types,
  }) {
    var url = '?access_token=' + api.accessToken;

    if (routing != null && routing) {
      url += '&routing=true';
    }

    if (language != null) {
      url += '&language=' + language;
    }

    if (limit != null && limit != 5) {
      url += '&limit=${limit}';
    }

    if (reverseMode != null) {
      switch (reverseMode) {
        case GeocoderReverseMode.SCORE:
          url += '&reverseMode=score';
          break;
        case GeocoderReverseMode.DISTANCE:
          break;
      }
    }

    if (country != null && country.isNotEmpty) {
      for (var i = 0; i < country.length; i++) {
        if (i == 0) {
          url += '&country=';
        }

        url += country[i];

        if (i != country.length - 1) {
          url += ',';
        }
      }
    }

    if (types != null && types.isNotEmpty) {
      for (var i = 0; i < types.length; i++) {
        if (i == 0) {
          url += '&types=';
        }

        switch (types[i]) {
          case GeocoderPlaceType.COUNTRY:
            url += 'country';
            break;
          case GeocoderPlaceType.REGION:
            url += 'region';
            break;
          case GeocoderPlaceType.POSTCODE:
            url += 'postcode';
            break;
          case GeocoderPlaceType.DISTRICT:
            url += 'district';
            break;
          case GeocoderPlaceType.PLACE:
            url += 'place';
            break;
          case GeocoderPlaceType.LOCALITY:
            url += 'locality';
            break;
          case GeocoderPlaceType.NEIGHBORHOOD:
            url += 'neighborhood';
            break;
          case GeocoderPlaceType.ADDRESS:
            url += 'address';
            break;
          case GeocoderPlaceType.POI:
            url += 'poi';
            break;
          case GeocoderPlaceType.EMPTY:
            url += '';
            break;
        }

        if (i != types.length - 1) {
          url += ',';
        }
      }
    }

    return url;
  }

  String version;
  String endpoint;
  MapboxApi api;
}
