import 'package:mapbox_api/mapbox_api.dart';

void main() async {
  MapboxApi mapbox = MapboxApi(
    accessToken: '<Mapbox API token>',
  );

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

  if (response.error != null) {
    if (response.error is NavigationNoRouteError) {
      // handle NoRoute response
    } else if (response.error is NavigationNoSegmentError) {
      // handle NoSegment response
    }

    return;
  }

  if (response.routes.length > 0) {
    final route = response.routes[0];
    final eta = Duration(
      seconds: route.duration.toInt(),
    );

    /*
    // Draw direction to mapbox_gl (flutter)

    import 'package:mapbox_gl/mapbox_gl.dart';
    import 'package:polyline/polyline.dart';

    final polyline = Polyline.Decode(
      encodedString: route.geometry as String,
      precision: 6,
    );
    final coordinates = polyline.decodedCoords;
    final path = <LatLng>[];

    for (var i = 0; i < coordinates.length; i++) {
      path.add(
        LatLng(
          coordinates[i][0],
          coordinates[i][1],
        ),
      );
    }

    if (path.length > 0) {
      // here we assume that controller was created from flutter and mapbox_gl
      final controller = MapboxMapController();

      await controller.addLine(
        LineOptions(
          geometry: path,
          lineColor: "#2196F3",
          lineWidth: 3.0,
          lineOpacity: 1,
          draggable: false,
        ),
      );
    }
    */
  }
}
