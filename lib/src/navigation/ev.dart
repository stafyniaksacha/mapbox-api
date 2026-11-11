// Electric vehicle routing for the Directions API.
//
// EV routing is a Mapbox *private preview* (beta): it needs access granted by
// Mapbox, works with the `driving` and `driving-traffic` profiles, and its
// parameters may change. https://docs.mapbox.com/api/navigation/directions/

/// Charging connector types the vehicle supports (`ev_connector_types`).
enum EvConnectorType {
  CCS_COMBO_TYPE1,
  CCS_COMBO_TYPE2,
  CHAOJI,
  CHADEMO,
  GBT_DC,
  TESLA,
}

/// Amenities to prefer near charging stops (`ev_prefer_amenities`).
enum EvAmenity {
  LIGHT,
  RESTAURANT,
  RESTROOM,
  RECREATION_CENTER,
}

/// Charging stations to exclude by category (`ev_exclude`).
enum EvExclude {
  /// Stations only usable by Tesla vehicles.
  TESLA_EXCLUSIVE,
}

/// Current type of a user-provided charging station.
enum EvCurrentType {
  SINGLE_PHASE_AC,
  THREE_PHASE_AC,
  DC,
}

/// A point of the energy consumption curve: consumption in Wh/km at a speed
/// in km/h.
typedef EvConsumptionPoint = ({num speedKph, num whPerKm});

/// A point of a charging curve: charging power in W at a battery charge in
/// Wh.
typedef EvChargingPoint = ({num chargeWh, num powerW});

/// A charging station the driver wants to stop at, given as one of the
/// request coordinates (`waypoints.charging_station_*`).
class EvWaypointChargingStation {
  const EvWaypointChargingStation({
    required this.power,
    required this.currentType,
    required this.stationId,
    this.minimalStopTime,
  });

  /// Station power in W (at least 1000).
  final int power;

  final EvCurrentType currentType;

  /// Station ID, looked up in the planner's station database.
  final String stationId;

  /// Minimum stop time in seconds (0 to 7200).
  final int? minimalStopTime;
}

/// Electric vehicle routing options for `DirectionsApi.request(ev: ...)`.
///
/// Sends `engine=electric` with the `ev_*` parameters. Energy values are in
/// Wh, power in W. Up to 12 coordinates when [addChargingStops] is true (the
/// API default), 25 otherwise. Request `waypointsPerRoute: true` to get the
/// charging stops of each alternative route.
///
/// Mapbox private preview: see the library comment of this file.
class DirectionsEvOptions {
  const DirectionsEvOptions({
    required this.maxCharge,
    required this.connectorTypes,
    required this.energyConsumptionCurve,
    required this.chargingCurve,
    this.initialCharge,
    this.unconditionedChargingCurve,
    this.preConditioningTime,
    this.maxAcChargingPower,
    this.minChargeAtDestination,
    this.minChargeAtChargingStation,
    this.ascent,
    this.descent,
    this.regenerationEfficiency,
    this.auxiliaryConsumption,
    this.addChargingStops,
    this.preferAmenities = const <EvAmenity>[],
    this.excludeStationIds = const <String>[],
    this.excludeChargePointProviderIds = const <String>[],
    this.preferChargePointProviderIds = const <String>[],
    this.preferChargePointProviderWeights = const <double>[],
    this.exclude = const <EvExclude>[],
    this.maxChargingVoltage,
    this.maxChargingPowerAtLowerVoltage,
    this.minEnergyIncrementAtChargingStation,
    this.waypointChargingStations = const <EvWaypointChargingStation?>[],
  })  : assert(
          (unconditionedChargingCurve == null) == (preConditioningTime == null),
          'unconditionedChargingCurve and preConditioningTime go together',
        ),
        assert(
          (ascent == null) == (descent == null),
          'ascent and descent go together',
        ),
        assert(
          (maxChargingVoltage == null) ==
              (maxChargingPowerAtLowerVoltage == null),
          'maxChargingVoltage and maxChargingPowerAtLowerVoltage go together',
        );

  /// Battery capacity in Wh (`ev_max_charge`, 80000 = 80 kWh).
  final int maxCharge;

  /// Connectors the vehicle supports (`ev_connector_types`).
  final List<EvConnectorType> connectorTypes;

  /// Consumption by speed (`energy_consumption_curve`).
  final List<EvConsumptionPoint> energyConsumptionCurve;

  /// Charging power by battery charge (`ev_charging_curve`).
  final List<EvChargingPoint> chargingCurve;

  /// Charge at departure in Wh (`ev_initial_charge`, default [maxCharge]).
  final int? initialCharge;

  /// Charging curve without battery pre-conditioning
  /// (`ev_unconditioned_charging_curve`). Requires [preConditioningTime].
  final List<EvChargingPoint>? unconditionedChargingCurve;

  /// Minutes needed to pre-condition the battery, 0 to 240
  /// (`ev_pre_conditioning_time`). Requires [unconditionedChargingCurve].
  final int? preConditioningTime;

  /// Maximum AC charging power in W (`ev_max_ac_charging_power`).
  final int? maxAcChargingPower;

  /// Minimum charge at the destination in Wh
  /// (`ev_min_charge_at_destination`).
  final int? minChargeAtDestination;

  /// Minimum charge when arriving at a charging station in Wh
  /// (`ev_min_charge_at_charging_station`).
  final int? minChargeAtChargingStation;

  /// Energy used going up, in Wh/m (`ev_ascent`). Requires [descent].
  final num? ascent;

  /// Energy recovered going down, in Wh/m (`ev_descent`). Requires
  /// [ascent].
  final num? descent;

  /// Share of energy recovered by regenerative braking, 0.0 to 1.0
  /// (`ev_regeneration_efficiency`).
  final double? regenerationEfficiency;

  /// Constant consumption of auxiliaries (heating, A/C, …) in W, 0 to 10000
  /// (`auxiliary_consumption`).
  final int? auxiliaryConsumption;

  /// Whether Mapbox adds charging stops (`ev_add_charging_stops`). `null`
  /// keeps the API default (true).
  final bool? addChargingStops;

  /// Amenities to prefer near stops (`ev_prefer_amenities`), soft preference.
  final List<EvAmenity> preferAmenities;

  /// Stations to avoid, at most 40 (`ev_exclude_station_ids`).
  final List<String> excludeStationIds;

  /// Charge point providers to avoid, at most 40
  /// (`ev_exclude_charge_point_provider_ids`).
  final List<String> excludeChargePointProviderIds;

  /// Charge point providers to prefer, at most 30
  /// (`ev_prefer_charge_point_provider_ids`).
  final List<String> preferChargePointProviderIds;

  /// Weight of each preferred provider, each in (0.0, 1.0], same length as
  /// [preferChargePointProviderIds]
  /// (`ev_prefer_charge_point_provider_weights`).
  final List<double> preferChargePointProviderWeights;

  /// Station categories to avoid (`ev_exclude`).
  final List<EvExclude> exclude;

  /// Maximum charging voltage in V (`ev_max_charging_voltage`). Requires
  /// [maxChargingPowerAtLowerVoltage].
  final int? maxChargingVoltage;

  /// Charging power at lower voltage in W
  /// (`ev_max_charging_power_at_lower_voltage`). Requires
  /// [maxChargingVoltage].
  final int? maxChargingPowerAtLowerVoltage;

  /// Minimum energy to add at each stop in Wh
  /// (`ev_min_energy_increment_at_charging_station`).
  final int? minEnergyIncrementAtChargingStation;

  /// User-provided charging stations, aligned with the request coordinates:
  /// one entry per coordinate, `null` for coordinates that are not a station.
  /// Empty (default) sends nothing.
  final List<EvWaypointChargingStation?> waypointChargingStations;
}
