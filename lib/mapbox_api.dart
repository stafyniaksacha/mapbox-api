import 'package:http/http.dart' as http;

import './src/navigation/directions.dart';
import './src/navigation/isochrone.dart';
import './src/navigation/map_matching.dart';
import './src/navigation/matrix.dart';
import './src/navigation/optimization.dart';

import './src/search/forward_geocoding.dart';
import './src/search/reverse_geocoding.dart';
import './src/search/intersection.dart';

export './src/errors.dart';
export './src/navigation/globals.dart';
export './src/navigation/directions.dart';
export './src/navigation/isochrone.dart';
export './src/navigation/map_matching.dart';
export './src/navigation/matrix.dart';
export './src/navigation/optimization.dart';

export './src/search/globals.dart';
export './src/search/forward_geocoding.dart';
export './src/search/reverse_geocoding.dart';
export './src/search/intersection.dart';

const LATITUDE = 0;
const LONGITUDE = 1;

/// The Mapbox web services APIs allow you to programmatically
/// access Mapbox tools and services.
/// You can use these APIs to retrieve information about your account,
/// upload and change resources, use core Mapbox tools, and more.
///
/// https://docs.mapbox.com/api/
class MapboxApi {
  /// Creates a client for the Mapbox web services.
  ///
  /// [accessToken] is sent as the `access_token` query parameter on every
  /// request. In clients, use a public (`pk.`) token with only the scopes
  /// you need, and never ship a secret (`sk.`) token. Restrict browser tokens
  /// to your URLs; native mobile apps need a separate token without URL
  /// restrictions, which Mapbox's URL restrictions would block.
  ///
  /// [client] is used for every request when set, which allows connection
  /// reuse, custom headers, proxies or retries, and testing. When `null`,
  /// each request uses a short-lived client from `package:http` (1.1.0
  /// behavior). The caller owns [client] and must close it.
  ///
  /// [timeout] limits each request. When it elapses, the request future
  /// throws a `TimeoutException`; the underlying HTTP request is not
  /// aborted. `null` (default) means no timeout.
  MapboxApi({
    this.accessToken,
    this.client,
    this.timeout,
  }) {
    directions = DirectionsApi(this);
    mapMatching = MapMatchingApi(this);
    isochrone = IsochroneApi(this);
    matrix = MatrixApi(this);
    optimization = OptimizationApi(this);
    forwardGeocoding = ForwardGeocodingApi(this);
    reverseGeocoding = ReverseGeocodingApi(this);
    intersection = IntersectionApi(this);
  }

  /// Directions API: routes between two or more coordinates.
  late DirectionsApi directions;

  /// Map Matching API: snaps GPS traces to the road network.
  MapMatchingApi? mapMatching;

  /// Isochrone API: areas reachable within a travel time.
  IsochroneApi? isochrone;

  /// Matrix API: travel times and distances between many points.
  MatrixApi? matrix;

  /// Optimization API: optimal ordering of up to 12 waypoints.
  OptimizationApi? optimization;

  /// Forward geocoding (v5): place name or address to coordinates.
  late ForwardGeocodingApi forwardGeocoding;

  /// Reverse geocoding (v5): coordinates to place names.
  late ReverseGeocodingApi reverseGeocoding;

  /// Intersection search (v5): the crossing point of two streets.
  late IntersectionApi intersection;

  /// Mapbox access token sent with every request. Required.
  String? accessToken;

  /// HTTP client used for every request, or `null` for `package:http`'s
  /// default. Owned by the caller.
  http.Client? client;

  /// Per-request timeout, or `null` for none.
  Duration? timeout;
}
