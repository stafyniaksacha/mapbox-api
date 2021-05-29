# mapbox_api

This package aim to :
- be a **Dart SDK** for **Mapbox API** with only [http](https://github.com/dart-lang/http) as dependency
- follow the [official documentation](https://docs.mapbox.com/api/)

## Examples

See [`examples/`](https://github.com/stafyniaksacha/mapbox-api/tree/master/example) for all available examples

```dart
import 'package:mapbox_api/mapbox_api.dart';

MapboxApi mapbox = MapboxApi(
  accessToken: '<Mapbox API token>',
);
```
> Get your API token on [mapbox.com](https://www.mapbox.com/)

#### Request directions services

```dart
final response = await mapbox.directions.request(
  profile: NavigationProfile.DRIVING_TRAFFIC,
  overview: NavigationOverview.FULL,
  geometries: NavigationGeometries.GEOJSON,
  steps: true,
  coordinates: <List<double>>[
    <double>[
      37.786060, // latitude
      -122.246225, // longitude
    ],
    <double>[
      37.785939, // latitude
      -122.194292, // longitude
    ],
  ],
);

if (response.error == null) {
  // response.routes ...
  // response.waypoints ...
}
```
> see basic example: [`example/example.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example.dart)  
> see full example with flutter_gl: [`example/example_directions_flutter.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example_directions_flutter.dart)

#### Request forward geocoding services

```dart
final response = await mapbox.forwardGeocoding.request(
  searchText: 'tour eiffel',
  fuzzyMatch: true,
  language: 'fr',
  proximity: <double>[
    48.858638, // latitude
    2.286020, // longitude
  ],
);

if (response.error == null) {
  // response.features ...
}
```
> see full example : [`example/example_forward_search.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example_forward_search.dart)

## Supported API

### Maps

| Service | Implemented |
| ------ | ------ |
| Vector Tiles | :heavy_multiplication_x: |
| Taster Tiles | :heavy_multiplication_x: |
| Static Images | :heavy_multiplication_x: |
| Static Tiles | :heavy_multiplication_x: |
| Styles | :heavy_multiplication_x: |
| Tilequery | :heavy_multiplication_x: |
| Uploads | :heavy_multiplication_x: |
| Mapbox Tiling Service | :heavy_multiplication_x: |
| Datasets | :heavy_multiplication_x: |
| Fonts | :heavy_multiplication_x: |

### Navigation

| Service | Implemented | Example |
| ------ | ------ | ------ |
| Directions | :white_check_mark:   | [`example/example.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example.dart) <br> [`example/example_directions_flutter.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example_directions_flutter.dart) |
| Isochrone | :white_check_mark:   |
| Map Matching | :white_check_mark:   |
| Matrix | :white_check_mark: |
| Optimization | :white_check_mark:   |

### Search

| Service | Implemented | Batch | Example |
| ------ | ------ | ------ | ------ |
| Forward Geocoding | :white_check_mark: | :white_check_mark: | [`example/example_forward_search.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example_forward_search.dart) |
| Reverse Geocoding | :white_check_mark: | :white_check_mark: | [`example/example_reverse_search.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example_reverse_search.dart) |
| Intersection | :white_check_mark: | :heavy_multiplication_x: | [`example/example_intersection_search.dart`](https://github.com/stafyniaksacha/mapbox-api/blob/master/example/example_intersection_search.dart) |

### Accounts

| Service | Implemented |
| ------ | ------ |
| Tokens | :heavy_multiplication_x: |


## Related Packages

This SDK will work perfectly with  [flutter-mapbox-gl](https://github.com/tobrun/flutter-mapbox-gl) to display retrieved data *(will work with any other package too)*.
You may also need [polyline](https://github.com/DartSociety/polyline.dart) package to convert polylines strings to coordinates.
