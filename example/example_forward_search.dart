import 'package:mapbox_api/mapbox_api.dart';

void main() async {
  final mapbox = MapboxApi(
    accessToken: '<Mapbox API token>',
  );

  final response = await mapbox.forwardGeocoding.request(
    searchText: 'tour eiffel',
    fuzzyMatch: true,
    language: 'fr',
    proximity: <double>[
      48.858638, // latitude
      2.286020, // longitude
    ],
  );

  if (response.error != null) {
    if (response.error is GeocoderError) {
      print('GeocoderError: ${(response.error as GeocoderError).message}');
      return;
    }

    print('Network error');
    return;
  }

  if (response.features != null && response.features!.isNotEmpty) {
    for (final feature in response.features!) {
      print(feature.placeName);
    }
  }
}
