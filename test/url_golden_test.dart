// Golden URLs produced by the published 1.1.0 release.
//
// These lock the exact request URL of every endpoint so refactors cannot
// change behavior silently. If a change here is intended (e.g. a bug fix),
// update the golden in the same commit and mention it in CHANGELOG.md.
//
// Known 1.1.0 bugs captured on purpose (do not "fix" the goldens alone):
// - directions: `continueStraight` and `excludes` are never sent.
// - map_matching: `timestamps` are never sent.
// - matrix: omitting `destinations` throws (null check).
// - optimization: the `;` after each distribution depends on the number of
//   coordinates, so it can be missing or trailing.
// - optimization: overview NONE sends `overview=false ` (trailing space).
// - matrix drops SPEED/CONGESTION annotations and optimization drops
//   CONGESTION, but both keep the `,` separator; place type EMPTY is ''.
// - geocoding: user text is not percent-encoded; `#` starts a URL fragment,
//   which drops the query string (including the access token).
import 'package:mapbox_api/mapbox_api.dart';
import 'package:test/test.dart';

import 'support/fake_http.dart';
import 'support/url_cases.dart';

const goldens = <String, String>{
  'directions/minimal':
      'https://api.mapbox.com/directions/v5/mapbox/driving/-122.246225,37.78606;-122.194292,37.785939?access_token=pk.test-token',
  'directions/no-profile':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'directions/all-options':
      'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/2.3,48.8;2.4,48.9;2.5,49.0?access_token=pk.test-token&language=fr&steps=true&alternatives=true&banner_instructions=true&roundabout_exits=true&voice_instructions=true&geometries=geojson&overview=full&approaches=curb;unrestricted&bearings=45.0,90.0;0.0,180.0&voice_units=metric&radiuses=10.0,unlimited,25.5&waypoint_names=Home,Work&waypoint_targets=2.31,48.81;2.51,49.01&waypoints=2.3,48.8;2.5,49.0&annotations=duration,distance,speed,congestion',
  'directions/walking':
      'https://api.mapbox.com/directions/v5/mapbox/walking/2.0,1.0;4.0,3.0?access_token=pk.test-token&walking_speed=2.0&walkway_bias=0.5&alley_bias=-1.0&geometries=polyline6&overview=false',
  'directions/walking-params-ignored-when-not-walking':
      'https://api.mapbox.com/directions/v5/mapbox/cycling/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'map_matching/minimal':
      'https://api.mapbox.com/matching/v5/mapbox/driving/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'map_matching/all-options':
      'https://api.mapbox.com/matching/v5/mapbox/walking/2.0,1.0;4.0,3.0;6.0,5.0.json?access_token=pk.test-token&language=de&steps=true&tidy=true&geometries=geojson&overview=full&approaches=curb&radiuses=5.0,10.0,15.0&waypoint_names=A,B&waypoints=2.0,1.0;6.0,5.0&annotations=distance,speed',
  'isochrone/minimal':
      'https://api.mapbox.com/isochrone/v1/mapbox/driving/2.35,48.85?access_token=pk.test-token&contours_minutes=10',
  'isochrone/all-options':
      'https://api.mapbox.com/isochrone/v1/mapbox/cycling/2.35,48.85?access_token=pk.test-token&contours_minutes=5,10,15&contours_colors=ff0000,00ff00,0000ff&polygons=true&denoise=0.5&generalize=100.0',
  'matrix/minimal':
      'https://api.mapbox.com/directions-matrix/v1/mapbox/driving/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'matrix/all-options':
      'https://api.mapbox.com/directions-matrix/v1/mapbox/driving-traffic/2.0,1.0;4.0,3.0;6.0,5.0?access_token=pk.test-token&annotations=duration,distance&approaches=curb;unrestricted;curb&destinations=1,2&sources=0&fallback_speed=13',
  'optimization/minimal':
      'https://api.mapbox.com/optimized-trips/v1/mapbox/driving/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'optimization/all-options':
      'https://api.mapbox.com/optimized-trips/v1/mapbox/walking/2.0,1.0;4.0,3.0;6.0,5.0?access_token=pk.test-token&language=es&steps=true&roundtrip=false&destination=last&source=first&geometries=polyline6&overview=full&distributions=0,2;&radiuses=unlimited,5.0,5.0&annotations=speed&bearings=10.0,20.0&approaches=unrestricted;curb;curb',
  'forward/minimal':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/tour%20eiffel.json?access_token=pk.test-token',
  'forward/all-options':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent/paris.json?access_token=pk.test-token&autocomplete=false&fuzzyMatch=false&routing=true&language=fr&limit=3&bbox=2.2,48.8,2.5,48.9&country=fr,be&types=address,poi&proximity=2.28602,48.858638',
  'forward/reserved-characters':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/a&b#c.json?access_token=pk.test-token',
  'forward/batch':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent/paris;lyon.json?access_token=pk.test-token&limit=1',
  'reverse/minimal':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/2.28602,48.858638.json?access_token=pk.test-token',
  'reverse/all-options':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent/2.28602,48.858638.json?access_token=pk.test-token&routing=true&language=en&limit=1&reverseMode=score&country=fr&types=address',
  'reverse/batch':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent/2.29,48.85;4.83,45.76.json?access_token=pk.test-token',
  'intersection/minimal':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/market%20street%20and%20fremont%20street.json?access_token=pk.test-token',
  'intersection/all-options':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/market%20street%20and%20fremont%20street.json?access_token=pk.test-token&types=address&proximity=-122.39,37.79',
  'edge/directions/profile-driving_traffic':
      'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/map_matching/profile-driving_traffic':
      'https://api.mapbox.com/matching/v5/mapbox/driving-traffic/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/isochrone/profile-driving_traffic':
      'https://api.mapbox.com/isochrone/v1/mapbox/driving-traffic/2.0,1.0?access_token=pk.test-token&contours_minutes=5',
  'edge/matrix/profile-driving_traffic':
      'https://api.mapbox.com/directions-matrix/v1/mapbox/driving-traffic/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/optimization/profile-driving_traffic':
      'https://api.mapbox.com/optimized-trips/v1/mapbox/driving-traffic/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/profile-driving':
      'https://api.mapbox.com/directions/v5/mapbox/driving/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/map_matching/profile-driving':
      'https://api.mapbox.com/matching/v5/mapbox/driving/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/isochrone/profile-driving':
      'https://api.mapbox.com/isochrone/v1/mapbox/driving/2.0,1.0?access_token=pk.test-token&contours_minutes=5',
  'edge/matrix/profile-driving':
      'https://api.mapbox.com/directions-matrix/v1/mapbox/driving/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/optimization/profile-driving':
      'https://api.mapbox.com/optimized-trips/v1/mapbox/driving/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/profile-walking':
      'https://api.mapbox.com/directions/v5/mapbox/walking/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/map_matching/profile-walking':
      'https://api.mapbox.com/matching/v5/mapbox/walking/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/isochrone/profile-walking':
      'https://api.mapbox.com/isochrone/v1/mapbox/walking/2.0,1.0?access_token=pk.test-token&contours_minutes=5',
  'edge/matrix/profile-walking':
      'https://api.mapbox.com/directions-matrix/v1/mapbox/walking/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/optimization/profile-walking':
      'https://api.mapbox.com/optimized-trips/v1/mapbox/walking/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/profile-cycling':
      'https://api.mapbox.com/directions/v5/mapbox/cycling/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/map_matching/profile-cycling':
      'https://api.mapbox.com/matching/v5/mapbox/cycling/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/isochrone/profile-cycling':
      'https://api.mapbox.com/isochrone/v1/mapbox/cycling/2.0,1.0?access_token=pk.test-token&contours_minutes=5',
  'edge/matrix/profile-cycling':
      'https://api.mapbox.com/directions-matrix/v1/mapbox/cycling/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/optimization/profile-cycling':
      'https://api.mapbox.com/optimized-trips/v1/mapbox/cycling/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/geometries-geojson':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token&geometries=geojson',
  'edge/map_matching/geometries-geojson':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token&geometries=geojson',
  'edge/optimization/geometries-geojson':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&geometries=geojson',
  'edge/directions/geometries-polyline':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/map_matching/geometries-polyline':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/optimization/geometries-polyline':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/geometries-polyline6':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token&geometries=polyline6',
  'edge/map_matching/geometries-polyline6':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token&geometries=polyline6',
  'edge/optimization/geometries-polyline6':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&geometries=polyline6',
  'edge/directions/overview-full':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token&overview=full',
  'edge/map_matching/overview-full':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token&overview=full',
  'edge/optimization/overview-full':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&overview=full',
  'edge/directions/overview-simplified':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/map_matching/overview-simplified':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/optimization/overview-simplified':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/overview-none':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token&overview=false',
  'edge/map_matching/overview-none':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token&overview=false',
  'edge/optimization/overview-none':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&overview=false%20',
  'edge/map_matching/approaches-unrestricted':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token',
  'edge/map_matching/approaches-curb':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token&approaches=curb',
  'edge/directions/voice_units-imperial':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token',
  'edge/directions/voice_units-metric':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token&voice_units=metric',
  'edge/directions/annotations-all':
      'https://api.mapbox.com/directions/v5/2.0,1.0;4.0,3.0?access_token=pk.test-token&annotations=duration,distance,speed,congestion',
  'edge/map_matching/annotations-all':
      'https://api.mapbox.com/matching/v5/2.0,1.0;4.0,3.0.json?access_token=pk.test-token&annotations=duration,distance,speed,congestion',
  'edge/matrix/annotations-all':
      'https://api.mapbox.com/directions-matrix/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&annotations=duration,distance,,',
  'edge/optimization/annotations-all':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&annotations=duration,distance,speed,',
  'edge/forward/types-all':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/x.json?access_token=pk.test-token&types=country,region,postcode,district,place,locality,neighborhood,address,poi,',
  'edge/forward/batch-types-all':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent/x.json?access_token=pk.test-token&types=country,region,postcode,district,place,locality,neighborhood,address,poi,',
  'edge/reverse/types-all':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/2.0,1.0.json?access_token=pk.test-token&types=country,region,postcode,district,place,locality,neighborhood,address,poi,',
  'edge/reverse/batch-types-all':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent/2.0,1.0.json?access_token=pk.test-token&types=country,region,postcode,district,place,locality,neighborhood,address,poi,',
  'edge/intersection/types-all':
      'https://api.mapbox.com/geocoding/v5/mapbox.places/a%20and%20b.json?access_token=pk.test-token&types=country,region,postcode,district,place,locality,neighborhood,address,poi,',
  'edge/forward/batch-empty':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent?access_token=pk.test-token',
  'edge/reverse/batch-empty':
      'https://api.mapbox.com/geocoding/v5/mapbox.places-permanent?access_token=pk.test-token',
  'edge/map_matching/no-coordinates':
      'https://api.mapbox.com/matching/v5?access_token=pk.test-token',
  'edge/directions/no-coordinates':
      'https://api.mapbox.com/directions/v5?access_token=pk.test-token',
  'edge/optimization/distributions-more-than-coordinates':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0?access_token=pk.test-token&distributions=0,1;1,00,1;',
  'edge/optimization/distributions-fewer-than-coordinates':
      'https://api.mapbox.com/optimized-trips/v1/2.0,1.0;4.0,3.0;6.0,5.0?access_token=pk.test-token&distributions=0,1;1,2;',
  'edge/directions/single-elements':
      'https://api.mapbox.com/directions/v5/123456789012345680000.0,1e-7;4.0,3.0?access_token=pk.test-token&approaches=unrestricted&bearings=1.0,2.0&radiuses=unlimited&waypoint_names=only',
};

void main() {
  test('every case has a golden and vice versa', () {
    expect(goldens.keys.toSet(), urlCases.keys.toSet());
  });

  for (final entry in urlCases.entries) {
    test('URL: ${entry.key}', () async {
      final captured = await capture(entry.value);
      expect(captured.requests.single.method, 'GET');
      expect(captured.url, goldens[entry.key]);
    });
  }

  group('known 1.1.0 bugs', () {
    test('matrix throws when destinations is omitted', () async {
      final api = MapboxApi(accessToken: testToken);
      await expectLater(
        capture(
          () => api.matrix!.request(
            profile: NavigationProfile.DRIVING,
            coordinates: [
              [1.0, 2.0],
              [3.0, 4.0],
            ],
          ),
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('a "#" in search text pushes the token into the fragment', () async {
      final captured = await capture(urlCases['forward/reserved-characters']!);
      final uri = captured.requests.single.url;
      expect(uri.queryParameters, isEmpty);
      expect(uri.fragment, contains('access_token'));
    });
  });
}
