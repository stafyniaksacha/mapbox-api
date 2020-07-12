import 'package:mapbox_api/mapbox_api.dart';

void main() async {
  final mapbox = MapboxApi(
    accessToken: '<Mapbox API token>',
  );

  final response = await mapbox.intersection.request(
    street1: 'Market Street',
    street2: 'Fremont Street',
    proximity: [
      37.792514711136945, // latitude
      -122.39738575285674, // longitude
    ],
    types: <GeocoderPlaceType>[
      GeocoderPlaceType.ADDRESS,
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

  if (response.features != null && response.features.isNotEmpty) {
    for (final feature in response.features) {
      print(feature.placeName);
    }
  }
}
