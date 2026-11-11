// Every enum member published in 1.1.0 must still exist, at the same index.
// Generated from the 1.1.0 sources; do not edit by hand when adding members
// (new members go at the end of an enum).
import 'package:mapbox_api/mapbox_api.dart';
import 'package:test/test.dart';

void main() {
  test('NavigationProfile', () {
    expect(
        NavigationProfile.values
            .take(4)
            .map((e) => e.toString().split('.').last),
        [
          'DRIVING_TRAFFIC',
          'DRIVING',
          'WALKING',
          'CYCLING',
        ]);
  });
  test('NavigationAnnotations', () {
    expect(
        NavigationAnnotations.values
            .take(4)
            .map((e) => e.toString().split('.').last),
        [
          'DURATION',
          'DISTANCE',
          'SPEED',
          'CONGESTION',
        ]);
  });
  test('NavigationExclude', () {
    expect(
        NavigationExclude.values
            .take(3)
            .map((e) => e.toString().split('.').last),
        [
          'TOLL',
          'MOTORWAY',
          'FERRY',
        ]);
  });
  test('NavigationGeometries', () {
    expect(
        NavigationGeometries.values
            .take(3)
            .map((e) => e.toString().split('.').last),
        [
          'GEOJSON',
          'POLYLINE',
          'POLYLINE6',
        ]);
  });
  test('NavigationOverview', () {
    expect(
        NavigationOverview.values
            .take(3)
            .map((e) => e.toString().split('.').last),
        [
          'FULL',
          'SIMPLIFIED',
          'NONE',
        ]);
  });
  test('NavigationApproaches', () {
    expect(
        NavigationApproaches.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'UNRESTRICTED',
          'CURB',
        ]);
  });
  test('NavigationVoiceUnits', () {
    expect(
        NavigationVoiceUnits.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'IMPERIAL',
          'METRIC',
        ]);
  });
  test('NavigationStepMode', () {
    expect(
        NavigationStepMode.values
            .take(6)
            .map((e) => e.toString().split('.').last),
        [
          'DRIVING',
          'FERRY',
          'UNACCESSIBLE',
          'WALKING',
          'CYLCING',
          'TRAIN',
        ]);
  });
  test('NavigationInstructionType', () {
    expect(
        NavigationInstructionType.values
            .take(7)
            .map((e) => e.toString().split('.').last),
        [
          'TURN',
          'MERGE',
          'DEPART',
          'ARRIVE',
          'FORK',
          'OFF_RAMP',
          'ROUNDABOUT',
        ]);
  });
  test('NavigationInstructionModifier', () {
    expect(
        NavigationInstructionModifier.values
            .take(8)
            .map((e) => e.toString().split('.').last),
        [
          'UTURN',
          'SHARP_RIGHT',
          'RIGHT',
          'SLIGHT_RIGHT',
          'STRAIGHT',
          'SLIGHT_LEFT',
          'LEFT',
          'SHARP_LEFT',
        ]);
  });
  test('NavigationDrivingSide', () {
    expect(
        NavigationDrivingSide.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'LEFT',
          'RIGHT',
        ]);
  });
  test('NavigationPropertyComponentType', () {
    expect(
        NavigationPropertyComponentType.values
            .take(6)
            .map((e) => e.toString().split('.').last),
        [
          'TEXT',
          'ICON',
          'DELIMITER',
          'EXIT_NUMBER',
          'EXIT',
          'LANE',
        ]);
  });
  test('NavigationDirection', () {
    expect(
        NavigationDirection.values
            .take(3)
            .map((e) => e.toString().split('.').last),
        [
          'LEFT',
          'RIGHT',
          'STRAIGHT',
        ]);
  });
  test('NavigationIntersectionClass', () {
    expect(
        NavigationIntersectionClass.values
            .take(6)
            .map((e) => e.toString().split('.').last),
        [
          'UNKNOWN',
          'TOLL',
          'FERRY',
          'RESTRICTED',
          'MOTORWAY',
          'TUNNEL',
        ]);
  });
  test('NavigationIndicationType', () {
    expect(
        NavigationIndicationType.values
            .take(9)
            .map((e) => e.toString().split('.').last),
        [
          'NONE',
          'UTURN',
          'SHARP_RIGHT',
          'RIGHT',
          'SLIGHT_RIGHT',
          'STRAIGHT',
          'SLIGHT_LEFT',
          'LEFT',
          'SHARP_LEFT',
        ]);
  });
  test('NavigationManeuverModifier', () {
    expect(
        NavigationManeuverModifier.values
            .take(8)
            .map((e) => e.toString().split('.').last),
        [
          'UTURN',
          'SHARP_RIGHT',
          'RIGHT',
          'SLIGHT_RIGHT',
          'STRAIGHT',
          'SLIGHT_LEFT',
          'LEFT',
          'SHARP_LEFT',
        ]);
  });
  test('NavigationManeuverType', () {
    expect(
        NavigationManeuverType.values
            .take(16)
            .map((e) => e.toString().split('.').last),
        [
          'TURN',
          'NEW_NAME',
          'DEPART',
          'ARRIVE',
          'MERGE',
          'ON_RAMP',
          'OFF_RAMP',
          'FORK',
          'END_OF_ROAD',
          'CONTINUE',
          'ROUNDABOUT',
          'ROTARY',
          'ROUNDABOUT_TURN',
          'NOTIFICATION',
          'EXIT_ROUNDABOUT',
          'EXIT_ROTARY',
        ]);
  });
  test('NavigationDestination', () {
    expect(
        NavigationDestination.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'ANY',
          'LAST',
        ]);
  });
  test('NavigationSource', () {
    expect(
        NavigationSource.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'ANY',
          'FIRST',
        ]);
  });
  test('GeocoderEndpoint', () {
    expect(
        GeocoderEndpoint.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'PLACES',
          'PLACES_PERMANENT',
        ]);
  });
  test('GeocoderPlaceType', () {
    expect(
        GeocoderPlaceType.values
            .take(10)
            .map((e) => e.toString().split('.').last),
        [
          'COUNTRY',
          'REGION',
          'POSTCODE',
          'DISTRICT',
          'PLACE',
          'LOCALITY',
          'NEIGHBORHOOD',
          'ADDRESS',
          'POI',
          'EMPTY',
        ]);
  });
  test('GeocoderFeaturePropertyAccuracy', () {
    expect(
        GeocoderFeaturePropertyAccuracy.values
            .take(7)
            .map((e) => e.toString().split('.').last),
        [
          'ROOFTOP',
          'PARCEL',
          'POINT',
          'INTERPOLATED',
          'INTERSECTION',
          'APPROXIMATE',
          'STREET',
        ]);
  });
  test('GeocoderReverseMode', () {
    expect(
        GeocoderReverseMode.values
            .take(2)
            .map((e) => e.toString().split('.').last),
        [
          'DISTANCE',
          'SCORE',
        ]);
  });
}
