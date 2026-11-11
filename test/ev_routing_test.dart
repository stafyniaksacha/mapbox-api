import 'dart:convert';

import 'package:mapbox_api/mapbox_api.dart';
import 'package:test/test.dart';

import 'support/fake_http.dart';
import 'support/url_cases.dart';

final api = MapboxApi(accessToken: testToken);

const minimalEv = DirectionsEvOptions(
  maxCharge: 80000,
  connectorTypes: [EvConnectorType.CCS_COMBO_TYPE2],
  energyConsumptionCurve: [(speedKph: 0, whPerKm: 300)],
  chargingCurve: [(chargeWh: 0, powerW: 100000)],
);

Future<DirectionsApiResponse> evDirections(Object body) async => (await capture(
      () => api.directions.request(
        profile: NavigationProfile.DRIVING,
        coordinates: [
          [48.8566, 2.3522],
          [45.764, 4.8357],
        ],
        waypointsPerRoute: true,
        ev: minimalEv,
      ),
      responseBody: jsonEncode(body),
    ))
        .result;

void main() {
  test('charging stops, state of charge and EV notifications are parsed',
      () async {
    final r = await evDirections({
      'code': 'Ok',
      'routes': [
        {
          'waypoints': [
            {
              'name': 'Paris',
              'location': [2.3522, 48.8566],
            },
            {
              'name': 'Station A6',
              'location': [3.5, 47.2],
              'metadata': {
                'type': 'charging-station',
                'name': 'Aire de Beaune',
                'charge_time': 1260,
                'charge_to': 64000,
                'charge_at_arrival': 9500,
                'plug_type': 'ccs_combo_type2',
                'current_type': 'dc',
                'power_kw': 150,
                'station_id': 'st-42',
                'provider_names': ['Provider X'],
              },
            },
            {
              'name': 'Lyon',
              'location': [4.8357, 45.764],
            },
          ],
          'legs': [
            {
              'annotation': {
                'state_of_charge': [75, 40.5, null, -3],
              },
              'notifications': [
                {
                  'type': 'alert',
                  'subtype': 'stationUnavailable',
                  'station_id': 'st-17',
                  'reason': 'outOfOrder',
                },
                {'type': 'violation', 'subtype': 'evInsufficientCharge'},
              ],
            },
          ],
        },
      ],
    });

    expect(r.error, isNull);
    final route = r.routes!.single;

    final stop = route.waypoints![1];
    expect(stop.name, 'Station A6');
    final metadata = stop.metadata!;
    expect(metadata.type, 'charging-station');
    expect(metadata.name, 'Aire de Beaune');
    expect(metadata.chargeTime, 1260.0);
    expect(metadata.chargeTo, 64000.0);
    expect(metadata.chargeAtArrival, 9500.0);
    expect(metadata.plugType, 'ccs_combo_type2');
    expect(metadata.currentType, 'dc');
    expect(metadata.powerKw, 150.0);
    expect(metadata.stationId, 'st-42');
    expect(metadata.providerNames, ['Provider X']);
    expect(metadata.minimalStopTime, isNull);
    expect(route.waypoints!.first.metadata, isNull);

    final leg = route.legs!.single;
    expect(leg.annotation!.stateOfCharge, [75.0, 40.5, null, -3.0]);
    expect(leg.notifications!.first.subtype, 'stationUnavailable');
    expect(leg.notifications!.first.stationId, 'st-17');
    expect(leg.notifications!.first.reason, 'outOfOrder');
    expect(leg.notifications!.last.subtype, 'evInsufficientCharge');
  });

  test('without ev, no EV parameter is sent', () async {
    final captured = await capture(
      () => api.directions.request(
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
        ],
      ),
    );
    final keys = captured.requests.single.url.queryParameters.keys;
    expect(keys.where((k) => k == 'engine' || k.startsWith('ev_')), isEmpty);
  });

  test('stations aligned with coordinates keep empty entries', () async {
    final captured = await capture(
      () => api.directions.request(
        coordinates: [
          [1.0, 2.0],
          [3.0, 4.0],
          [5.0, 6.0],
          [7.0, 8.0],
        ],
        ev: const DirectionsEvOptions(
          maxCharge: 50000,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: [(speedKph: 0, whPerKm: 250)],
          chargingCurve: [(chargeWh: 0, powerW: 50000)],
          waypointChargingStations: [
            null,
            EvWaypointChargingStation(
              power: 22000,
              currentType: EvCurrentType.THREE_PHASE_AC,
              stationId: 'a',
            ),
            null,
            null,
          ],
        ),
      ),
    );
    final query = captured.requests.single.url.queryParameters;
    expect(query['waypoints.charging_station_power'], ';22000;;');
    expect(
        query['waypoints.charging_station_current_type'], ';three_phase_ac;;');
    expect(query['waypoints.charging_station_id'], ';a;;');
    // No station sets a minimal stop time: the parameter is not sent.
    expect(query.containsKey('waypoints.minimal_stop_time'), isFalse);
  });

  group('paired EV parameters are checked', () {
    test('preConditioningTime needs unconditionedChargingCurve', () {
      expect(
        () => DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [],
          energyConsumptionCurve: [],
          chargingCurve: [],
          preConditioningTime: 10,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('ascent needs descent', () {
      expect(
        () => DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [],
          energyConsumptionCurve: [],
          chargingCurve: [],
          ascent: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('maxChargingVoltage needs maxChargingPowerAtLowerVoltage', () {
      expect(
        () => DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [],
          energyConsumptionCurve: [],
          chargingCurve: [],
          maxChargingVoltage: 400,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('invalid EV options throw ArgumentError before any request', () {
    const curve = [(speedKph: 0, whPerKm: 300)];
    const charging = [(chargeWh: 0, powerW: 100000)];
    const station = EvWaypointChargingStation(
      power: 50000,
      currentType: EvCurrentType.DC,
      stationId: 's',
    );
    const twoCoordinates = [
      [1.0, 2.0],
      [3.0, 4.0],
    ];

    Future<void> expectRejected(
      DirectionsEvOptions ev,
      String reason, {
      List<List<double>> coordinates = twoCoordinates,
    }) async {
      await expectLater(
        capture(
          () => api.directions.request(
            profile: NavigationProfile.DRIVING,
            coordinates: coordinates,
            ev: ev,
          ),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'message',
            contains(reason),
          ),
        ),
      );
    }

    test('stations not aligned with coordinates', () async {
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: curve,
          chargingCurve: charging,
          waypointChargingStations: [null],
        ),
        'one entry per coordinate',
      );
    });

    test('a station on the origin', () async {
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: curve,
          chargingCurve: charging,
          waypointChargingStations: [station, null],
        ),
        'origin',
      );
    });

    test('provider weights not aligned with provider ids', () async {
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: curve,
          chargingCurve: charging,
          preferChargePointProviderIds: ['a', 'b'],
          preferChargePointProviderWeights: [1],
        ),
        'preferChargePointProviderWeights',
      );
    });

    test('weights without provider ids', () async {
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: curve,
          chargingCurve: charging,
          preferChargePointProviderWeights: [1],
        ),
        'preferChargePointProviderWeights',
      );
    });

    test('empty required lists', () async {
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [],
          energyConsumptionCurve: curve,
          chargingCurve: charging,
        ),
        'connectorTypes',
      );
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: [],
          chargingCurve: charging,
        ),
        'energyConsumptionCurve',
      );
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: curve,
          chargingCurve: [],
        ),
        'chargingCurve',
      );
    });

    test('pre-conditioning time with an empty curve', () async {
      await expectRejected(
        const DirectionsEvOptions(
          maxCharge: 1,
          connectorTypes: [EvConnectorType.CHADEMO],
          energyConsumptionCurve: curve,
          chargingCurve: charging,
          unconditionedChargingCurve: [],
          preConditioningTime: 10,
        ),
        'unconditionedChargingCurve',
      );
    });

    test('nothing is sent when options are rejected', () async {
      final captured = await capture(() async {
        try {
          await api.directions.request(
            coordinates: twoCoordinates,
            ev: const DirectionsEvOptions(
              maxCharge: 1,
              connectorTypes: [],
              energyConsumptionCurve: curve,
              chargingCurve: charging,
            ),
          );
        } on ArgumentError {
          // expected
        }
      });
      expect(captured.requests, isEmpty);
    });
  });
}
