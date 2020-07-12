import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';

/// Intersection search allows users to search for a point
/// where two streets intersect, without a precise address.
///
/// https://docs.mapbox.com/api/search/#intersection-search-support
class IntersectionApi {
  IntersectionApi(
    this.api, {
    this.version = 'v5',
    this.endpoint = 'https://api.mapbox.com/geocoding',
  });

  /// The response from an intersection search query is a GeoJSON
  /// feature collection with the accuracy property set to intersection
  Future<GeocodingApiResponse> request({
    GeocoderEndpoint endpoint = GeocoderEndpoint.PLACES,
    String street1,
    String street2,
    List<double> proximity = const <double>[],
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    var url = this.endpoint + '/' + version;

    if (endpoint == GeocoderEndpoint.PLACES_PERMANENT) {
      url += '/mapbox.places-permanent';
    } else {
      url += '/mapbox.places';
    }

    url += '/${street1} and ${street2}.json';
    url += '?access_token=' + api.accessToken;

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

    if (proximity != null && proximity.isNotEmpty) {
      url += '&proximity=';
      url += '${proximity[LONGITUDE]},${proximity[LATITUDE]}';
    }

    try {
      final response = await get(url);
      final json = jsonDecode(
        response.body,
      ) as Map<String, dynamic>;
      return GeocodingApiResponse.fromJson(json);
    } catch (error) {
      return GeocodingApiResponse.withError(error);
    }
  }

  String version;
  String endpoint;
  MapboxApi api;
}
