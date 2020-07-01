# mapbox-api

This package aim to :
- be a **Dart SDK** for **Mapbox API** with only [http](https://github.com/dart-lang/http) as dependency
- follow the [official documentation](https://docs.mapbox.com/api/)

### :construction: WIP Notice

This is a work in progress, feel free open an issue for questions and remarks. (PR are welcome :))

## Examples

```dart
import 'package:mapbox_api/mapbox_api.dart';

MapboxApi mapbox = MapboxApi(
  accessToken: '<Mapbox API token>',
);
```
> Get your API token on [mapbox.com](https://www.mapbox.com/)

#### Request directions services

```dart
DirectionsApiResponse response = await mapbox.directions.request(
  profile: NavigationProfile.DRIVING_TRAFFIC,
  overview: NavigationOverview.FULL,
  geometries: NavigationGeometries.POLYLINE6,
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

#### Request map matching services

```dart
MapMatchingApiResponse response = await mapbox.mapMatching.request(
  profile: NavigationProfile.WALKING,
  geometries: NavigationGeometries.GEOJSON,
  tidy: true,
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
  // response.matchings ...
  // response.tracepoints ...
}
```

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

| Service | Implemented |
| ------ | ------ |
| Directions | :white_check_mark:   |
| Isochrone | :white_check_mark:   |
| Map Matching | :white_check_mark:   |
| Matrix | :white_check_mark: |
| Optimization | :white_check_mark:   |

### Search

| Service | Implemented |
| ------ | ------ |
| Geocoding | :heavy_multiplication_x: |

> If you are looking for geocoding, take a look at [ketanchoyal/mapbox_search](https://github.com/ketanchoyal/mapbox_search)

### Accounts

| Service | Implemented |
| ------ | ------ |
| Tokens | :heavy_multiplication_x: |


## Related Packages

This SDK will work perfectly with  [flutter-mapbox-gl](https://github.com/tobrun/flutter-mapbox-gl) to display retrieved data *(will work with any other package too)*.
You may also need [polyline](https://github.com/DartSociety/polyline.dart) package to convert polylines strings to coordinates.