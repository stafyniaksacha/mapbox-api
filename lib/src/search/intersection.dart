import 'dart:convert';

import 'package:http/http.dart';

import '../../mapbox_api.dart';
import '../url_helpers.dart';

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
    String? street1,
    String? street2,
    List<double> proximity = const <double>[],
    List<GeocoderPlaceType> types = const <GeocoderPlaceType>[],
  }) async {
    var url = '${this.endpoint}/$version${geocoderEndpointPath(endpoint)}';

    url += '/$street1 and $street2.json';
    url += '?access_token=${api.accessToken!}';
    url += listParam('types', types.map((t) => t.value), ',');

    if (proximity.isNotEmpty) {
      url += '&proximity=${lonLat(proximity)}';
    }

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

  String version;
  String endpoint;
  MapboxApi api;
}
