# mapbox_api

Unofficial Dart SDK for the [Mapbox web services APIs](https://docs.mapbox.com/api/).

- Pure Dart: works in Flutter, on the server and on the web.
- One runtime dependency: [`http`](https://pub.dev/packages/http).
- Follows the official API documentation.

## Install

```sh
dart pub add mapbox_api
```

Requires Dart 3.4 or later.

## Usage

```dart
import 'package:mapbox_api/mapbox_api.dart';

final mapbox = MapboxApi(accessToken: '<Mapbox access token>');
```

### Coordinates are `[latitude, longitude]`

Unlike GeoJSON and the Mapbox URLs (`longitude,latitude`), this package takes
coordinates as `[latitude, longitude]` and swaps them for you. Use the
`LATITUDE` / `LONGITUDE` index constants when reading them back. Coordinates in
**responses** (`location`, `center`, geometries) are as Mapbox returns them:
`[longitude, latitude]`.

### Directions

```dart
final response = await mapbox.directions.request(
  profile: NavigationProfile.DRIVING_TRAFFIC,
  overview: NavigationOverview.FULL,
  geometries: NavigationGeometries.GEOJSON,
  steps: true,
  coordinates: <List<double>>[
    <double>[37.786060, -122.246225], // latitude, longitude
    <double>[37.785939, -122.194292],
  ],
);

if (response.error == null) {
  // response.routes, response.waypoints
}
```

See [`example/example.dart`](example/example.dart).

### Forward geocoding

```dart
final response = await mapbox.forwardGeocoding.request(
  searchText: 'tour eiffel',
  fuzzyMatch: true,
  language: 'fr',
  proximity: <double>[48.858638, 2.286020], // latitude, longitude
);

if (response.error == null) {
  // response.features
}
```

See [`example/example_forward_search.dart`](example/example_forward_search.dart).

## Error handling

- **Thrown:** network failures (`ClientException`, `SocketException`), a body
  that is not JSON (`FormatException`), a timeout (`TimeoutException`), and a
  missing access token (`ArgumentError`).
- **Returned in `response.error`:** everything the API answered with:
  - endpoint errors such as `NavigationNoRouteError` or `GeocoderError`;
  - other HTTP errors as `MapboxHttpError` (`statusCode`, `message`), e.g.
    401 invalid token or 429 rate limited;
  - responses that could not be parsed.

```dart
try {
  final response = await mapbox.directions.request(/* ... */);
  final error = response.error;
  if (error is MapboxHttpError && error.statusCode == 429) {
    // rate limited: back off and retry
  } else if (error != null) {
    // no route, invalid input, ...
  }
} on Exception {
  // network failure or timeout
}
```

## Access tokens

The token is sent in the request URL (`access_token=…`), which is the only way
the Mapbox web services accept it.

- In apps, use a **public token (`pk.`)** restricted to your URLs or app
  identifiers, with only the scopes you need. Never ship a secret (`sk.`)
  token in a client.
- Request URLs contain the token: don't log them. `MapboxHttpError` and
  `MapboxRequestError` never include the URL, but a thrown `ClientException`
  does in its `toString()`.

See [Mapbox: token security](https://docs.mapbox.com/help/dive-deeper/how-to-use-mapbox-securely/).

## HTTP client and timeout

```dart
final client = http.Client(); // or a retrying / instrumented client
final mapbox = MapboxApi(
  accessToken: '<token>',
  client: client,
  timeout: const Duration(seconds: 10),
);
// ...
client.close();
```

## Supported APIs

### Navigation

| Service | Implemented | Example |
| ------ | ------ | ------ |
| Directions | :white_check_mark: | [`example/example.dart`](example/example.dart) |
| Isochrone | :white_check_mark: | |
| Map Matching | :white_check_mark: | |
| Matrix | :white_check_mark: | |
| Optimization (v1) | :white_check_mark: | |

### Search (Geocoding v5)

| Service | Implemented | Batch | Example |
| ------ | ------ | ------ | ------ |
| Forward Geocoding | :white_check_mark: | single query only ¹ | [`example/example_forward_search.dart`](example/example_forward_search.dart) |
| Reverse Geocoding | :white_check_mark: | single query only ¹ | [`example/example_reverse_search.dart`](example/example_reverse_search.dart) |
| Intersection | :white_check_mark: | :heavy_multiplication_x: | [`example/example_intersection_search.dart`](example/example_intersection_search.dart) |

¹ With two or more queries Mapbox returns a list of results, which is not
supported yet: `response.error` is a `MapboxRequestError`.

Geocoding v5 is legacy at Mapbox; Geocoding v6 is planned.

### Not implemented

Maps (vector/raster tiles, static images, styles, tilequery, uploads,
datasets, fonts) and Accounts (tokens).

## Displaying results in Flutter

This package only calls the web services. To draw results on a map, use a map
SDK such as the official
[`mapbox_maps_flutter`](https://pub.dev/packages/mapbox_maps_flutter): request
`geometries: NavigationGeometries.GEOJSON` and pass the route geometry to a
GeoJSON source, or decode `POLYLINE` / `POLYLINE6` strings with a polyline
package.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
