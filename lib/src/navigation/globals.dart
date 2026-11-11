import '../json_helpers.dart';

/// Routing profile: mode of travel and data used.
enum NavigationProfile {
  DRIVING_TRAFFIC,
  DRIVING,
  WALKING,
  CYCLING,
}

/// Metadata to return for each route segment (`annotations`).
enum NavigationAnnotations {
  DURATION,
  DISTANCE,
  SPEED,
  CONGESTION,

  /// Posted speed limit per segment (beta at Mapbox). Driving profiles.
  MAXSPEED,

  /// Congestion as a number from 0 to 100. `driving-traffic` only.
  CONGESTION_NUMERIC,

  /// Live-traffic closures, returned in [NavigationLeg.closures].
  /// `driving-traffic` only.
  CLOSURE,
}

/// Road types to avoid (`exclude`), best effort.
enum NavigationExclude {
  TOLL,
  MOTORWAY,
  FERRY,
  UNPAVED,
  CASH_ONLY_TOLLS,
  COUNTRY_BORDER,
  STATE_BORDER,
  TUNNEL,
}

/// Restricted lanes the route may use (`include`). Driving profiles.
enum NavigationInclude {
  /// High-occupancy vehicle lanes requiring at least 2 occupants.
  HOV2,

  /// High-occupancy vehicle lanes requiring at least 3 occupants.
  HOV3,

  /// High-occupancy toll lanes.
  HOT,
}

/// Format of returned geometries.
enum NavigationGeometries {
  GEOJSON,
  POLYLINE,
  POLYLINE6,
}

/// Detail level of the route overview geometry.
enum NavigationOverview {
  FULL,
  SIMPLIFIED,
  NONE,
}

/// Side of the road from which to approach a waypoint.
enum NavigationApproaches {
  UNRESTRICTED,
  CURB,
}

/// Unit system of voice instructions.
enum NavigationVoiceUnits {
  IMPERIAL,
  METRIC,
}

/// Mode of transportation of a step.
enum NavigationStepMode {
  DRIVING,
  FERRY,
  UNACCESSIBLE,
  WALKING,
  CYLCING,
  TRAIN,
}

/// Maneuver type of a banner instruction.
enum NavigationInstructionType {
  TURN,
  MERGE,
  DEPART,
  ARRIVE,
  FORK,
  OFF_RAMP,
  ROUNDABOUT,
  CONTINUE,
  END_OF_ROAD,
  NEW_NAME,
  NOTIFICATION,
  ON_RAMP,
  ROTARY,
  UPDOWN,
  UTURN,
  CLOSE,
  FLAG,
}

/// Direction modifier of a banner instruction.
enum NavigationInstructionModifier {
  UTURN,
  SHARP_RIGHT,
  RIGHT,
  SLIGHT_RIGHT,
  STRAIGHT,
  SLIGHT_LEFT,
  LEFT,
  SHARP_LEFT,
}

/// Side of the road on which traffic drives.
enum NavigationDrivingSide {
  LEFT,
  RIGHT,
}

/// Type of a banner instruction component.
enum NavigationPropertyComponentType {
  TEXT,
  ICON,
  DELIMITER,
  EXIT_NUMBER,
  EXIT,
  LANE,
}

/// Driving direction of a lane indication.
enum NavigationDirection {
  LEFT,
  RIGHT,
  STRAIGHT,
}

/// Road classes at an intersection.
enum NavigationIntersectionClass {
  UNKNOWN,
  TOLL,
  FERRY,
  RESTRICTED,
  MOTORWAY,
  TUNNEL,
}

/// Arrow shown for a lane.
enum NavigationIndicationType {
  NONE,
  UTURN,
  SHARP_RIGHT,
  RIGHT,
  SLIGHT_RIGHT,
  STRAIGHT,
  SLIGHT_LEFT,
  LEFT,
  SHARP_LEFT,
}

/// Direction modifier of a maneuver.
enum NavigationManeuverModifier {
  UTURN,
  SHARP_RIGHT,
  RIGHT,
  SLIGHT_RIGHT,
  STRAIGHT,
  SLIGHT_LEFT,
  LEFT,
  SHARP_LEFT,
}

/// Type of a maneuver, as documented by the Directions API.
enum NavigationManeuverType {
  TURN,
  NEW_NAME,
  DEPART,
  ARRIVE,
  MERGE,
  ON_RAMP,
  OFF_RAMP,
  FORK,
  END_OF_ROAD,
  CONTINUE,
  ROUNDABOUT,
  ROTARY,
  ROUNDABOUT_TURN,
  NOTIFICATION,
  EXIT_ROUNDABOUT,
  EXIT_ROTARY,
  UPDOWN,
  UTURN,
  CLOSE,
  FLAG,
}

/// Whether an optimized trip must end at the last coordinate.
enum NavigationDestination {
  ANY,
  LAST,
}

/// Whether an optimized trip must start at the first coordinate.
enum NavigationSource {
  ANY,
  FIRST,
}

/// Bearing constraint for a coordinate: `angle` and allowed deviation `degree`, in degrees.
class NavigationBearings {
  NavigationBearings(
    this.angle,
    this.degree,
  );

  NavigationBearings.fromJson(Map<String, dynamic> json) {
    angle = (json['angle'] as num?)?.toDouble();
    degree = (json['degree'] as num?)?.toDouble();
  }

  double? angle;
  double? degree;
}

/// A GeoJSON feature returned by the Isochrone API (one contour).
class NavigationFeature {
  NavigationFeature({
    this.type,
    this.properties,
    this.geometry,
  });

  NavigationFeature.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;

    if (json.containsKey('properties') && json['properties'] != null) {
      properties = NavigationFeatureProperty.fromJson(
        json['properties'] as Map<String, dynamic>,
      );
    }

    if (json.containsKey('geometry') && json['geometry'] != null) {
      geometry = NavigationFeatureGeometry.fromJson(
        json['geometry'] as Map<String, dynamic>,
      );
    }
  }

  String? type;
  NavigationFeatureProperty? properties;
  NavigationFeatureGeometry? geometry;
}

/// Properties of an isochrone contour: minutes and display colors.
class NavigationFeatureProperty {
  NavigationFeatureProperty({
    this.contour,
    this.color,
    this.opacity,
    this.fill,
    this.fillColor,
    this.fillOpacity,
  });

  NavigationFeatureProperty.fromJson(Map<String, dynamic> json) {
    contour = (json['contour'] as num?)?.toInt();
    color = json['color'] as String?;
    opacity = (json['opacity'] as num?)?.toDouble();
    fill = json['fill'] as String?;
    fillColor = json['fillColor'] as String?;
    fillOpacity = (json['fillOpacity'] as num?)?.toDouble();
  }

  int? contour;
  String? color;
  double? opacity;
  String? fill;
  String? fillColor;
  double? fillOpacity;
}

/// GeoJSON geometry of a [NavigationFeature].
class NavigationFeatureGeometry {
  NavigationFeatureGeometry({
    this.coordinates,
    this.type,
    this.rawCoordinates,
  });

  NavigationFeatureGeometry.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;

    final value = json['coordinates'];
    if (value is List<dynamic>) {
      rawCoordinates = coordinatesOfAnyDepth(value);
      if (value.every((element) => element is num)) {
        coordinates = doubleList(value);
      }
    }
  }

  /// Coordinates of a `Point` geometry (`[longitude, latitude]`).
  ///
  /// `null` for nested geometries such as the `LineString` and `Polygon`
  /// returned by the Isochrone API: use [rawCoordinates] for those.
  List<double>? coordinates;

  /// The GeoJSON `coordinates` of any geometry type, as nested lists of
  /// doubles (e.g. `List<List<double>>` for a `LineString`,
  /// `List<List<List<double>>>` for a `Polygon`).
  List<dynamic>? rawCoordinates;

  String? type;
}

/// A requested coordinate snapped to the road network.
class NavigationWaypoint {
  NavigationWaypoint({
    this.name,
    this.location = const <double>[],
    this.distance,
  });

  NavigationWaypoint.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    distance = (json['distance'] as num?)?.toDouble();

    if (json.containsKey('location') && json['location'] != null) {
      location = doubleList(json['location']);
    }
  }

  String? name;
  List<double>? location;
  double? distance;
}

/// A waypoint of an optimized trip, with its position in the trip.
class NavigationOptimizedWaypoint {
  NavigationOptimizedWaypoint({
    this.name,
    this.location = const <double>[],
    this.tripsIndex,
    this.waypointIndex,
  });

  NavigationOptimizedWaypoint.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    tripsIndex = (json['trips_index'] as num?)?.toInt();
    waypointIndex = (json['waypoint_index'] as num?)?.toInt();

    if (json.containsKey('location') && json['location'] != null) {
      location = doubleList(json['location']);
    }
  }

  String? name;
  List<double>? location;
  int? tripsIndex;
  int? waypointIndex;
}

/// An input point of a Map Matching request, snapped to the road.
///
/// Unmatched points have every field `null`.
class NavigationTracepoint extends NavigationWaypoint {
  // Not using super parameters on purpose: they would inherit the parent's
  // default (`const []`) instead of passing null, which changes behavior.
  // ignore: use_super_parameters
  NavigationTracepoint({
    this.matchingsIndex,
    this.waypointIndex,
    this.alternativesCount,
    String? name,
    List<double>? location,
    double? distance,
  }) : super(
          name: name,
          location: location,
          distance: distance,
        );

  NavigationTracepoint.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    distance = (json['distance'] as num?)?.toDouble();
    matchingsIndex = (json['matchings_index'] as num?)?.toInt();
    waypointIndex = (json['waypoint_index'] as num?)?.toInt();
    alternativesCount = (json['alternatives_count'] as num?)?.toInt();

    if (json.containsKey('location') && json['location'] != null) {
      location = doubleList(json['location']);
    }
  }

  int? matchingsIndex;
  int? waypointIndex;
  int? alternativesCount;
}

/// A route between waypoints (also an Optimization API trip).
class NavigationRoute {
  NavigationRoute({
    this.duration,
    this.distance,
    this.weightName,
    this.weight,
    this.geometry,
    this.legs = const <NavigationLeg>[],
    this.voiceLocale,
  });

  NavigationRoute.fromJson(Map<String, dynamic> json) {
    duration = (json['duration'] as num?)?.toDouble();
    distance = (json['distance'] as num?)?.toDouble();
    weightName = (json['weight_name'] ?? json['weightName']) as String?;
    weight = (json['weight'] as num?)?.toDouble();
    geometry = json['geometry'] as dynamic;
    voiceLocale = json['voiceLocale'] as String?;

    if (json.containsKey('legs') && json['legs'] != null) {
      legs = List<NavigationLeg>.from(
        (json['legs'] as List<dynamic>).map(
          (leg) => NavigationLeg.fromJson(
            leg as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  double? duration;
  double? distance;
  String? weightName;
  double? weight;
  dynamic geometry;
  List<NavigationLeg>? legs;
  String? voiceLocale;
}

/// A route matched to a GPS trace by the Map Matching API.
class NavigationMatchRoute extends NavigationRoute {
  // Not using super parameters on purpose: they would inherit the parent's
  // default (`const []`) instead of passing null, which changes behavior.
  // ignore: use_super_parameters
  NavigationMatchRoute({
    this.confidence,
    double? duration,
    double? distance,
    String? weightName,
    double? weight,
    dynamic geometry,
    List<NavigationLeg>? legs,
    String? voiceLocale,
  }) : super(
          duration: duration,
          distance: distance,
          weightName: weightName,
          weight: weight,
          geometry: geometry,
          legs: legs,
          voiceLocale: voiceLocale,
        );

  NavigationMatchRoute.fromJson(Map<String, dynamic> json) {
    confidence = (json['confidence'] as num?)?.toDouble();
    duration = (json['duration'] as num?)?.toDouble();
    distance = (json['distance'] as num?)?.toDouble();
    weightName = (json['weight_name'] ?? json['weightName']) as String?;
    weight = (json['weight'] as num?)?.toDouble();
    geometry = json['geometry'] as dynamic;
    voiceLocale = json['voiceLocale'] as String?;

    if (json.containsKey('legs') && json['legs'] != null) {
      legs = List<NavigationLeg>.from(
        (json['legs'] as List<dynamic>).map(
          (leg) => NavigationLeg.fromJson(
            leg as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  double? confidence;
}

/// The part of a route between two waypoints.
class NavigationLeg {
  NavigationLeg({
    this.duration,
    this.distance,
    this.steps = const <NavigationStep>[],
    this.summary,
    this.annotation,
    this.closures,
  });

  NavigationLeg.fromJson(Map<String, dynamic> json) {
    duration = (json['duration'] as num?)?.toDouble();
    distance = (json['distance'] as num?)?.toDouble();
    summary = json['summary'] as String?;

    if (json.containsKey('steps') && json['steps'] != null) {
      steps = List<NavigationStep>.from(
        (json['steps'] as List<dynamic>).map(
          (step) => NavigationStep.fromJson(
            step as Map<String, dynamic>,
          ),
        ),
      );
    }
    if (json.containsKey('annotation') && json['annotation'] != null) {
      annotation = NavigationAnnotation.fromJson(
        json['annotation'] as Map<String, dynamic>,
      );
    }
    if (json['closures'] != null) {
      closures = [
        for (final value in json['closures'] as List<dynamic>)
          NavigationClosure.fromJson(value as Map<String, dynamic>),
      ];
    }
  }

  double? duration;
  double? distance;
  List<NavigationStep>? steps;
  String? summary;
  NavigationAnnotation? annotation;

  /// Live-traffic closures on this leg (requested with
  /// [NavigationAnnotations.CLOSURE]).
  List<NavigationClosure>? closures;
}

/// Per-segment metadata of a route leg, requested with `annotations`.
class NavigationAnnotation {
  NavigationAnnotation({
    this.duration,
    this.distance,
    this.speed,
    this.congestion,
    this.maxspeed,
    this.congestionNumeric,
  });

  NavigationAnnotation.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('duration') && json['duration'] != null) {
      duration = doubleList(json['duration']);
    }
    if (json.containsKey('distance') && json['distance'] != null) {
      distance = doubleList(json['distance']);
    }
    if (json.containsKey('speed') && json['speed'] != null) {
      speed = doubleList(json['speed']);
    }
    if (json.containsKey('congestion') && json['congestion'] != null) {
      congestion = List<String>.from(
        json['congestion'] as List<dynamic>,
      );
    }
    if (json['maxspeed'] != null) {
      maxspeed = [
        for (final value in json['maxspeed'] as List<dynamic>)
          NavigationMaxSpeed.fromJson(value as Map<String, dynamic>),
      ];
    }
    if (json['congestion_numeric'] != null) {
      congestionNumeric = [
        for (final value in json['congestion_numeric'] as List<dynamic>)
          (value as num?)?.toInt(),
      ];
    }
  }

  List<double>? duration;
  List<double>? distance;
  List<double>? speed;
  List<String>? congestion;

  /// Posted speed limit per segment ([NavigationAnnotations.MAXSPEED]).
  List<NavigationMaxSpeed>? maxspeed;

  /// Congestion from 0 (none) to 100 (maximum) per segment; `null` when
  /// unknown ([NavigationAnnotations.CONGESTION_NUMERIC]).
  List<int?>? congestionNumeric;
}

/// Posted speed limit of a segment: either [speed] and [unit], or
/// [unknown], or [none] (no limit, e.g. a German Autobahn).
class NavigationMaxSpeed {
  NavigationMaxSpeed({
    this.speed,
    this.unit,
    this.unknown = false,
    this.none = false,
  });

  NavigationMaxSpeed.fromJson(Map<String, dynamic> json)
      : speed = (json['speed'] as num?)?.toDouble(),
        unit = json['unit'] as String?,
        unknown = json['unknown'] == true,
        none = json['none'] == true;

  /// The limit, in [unit].
  double? speed;

  /// `km/h` or `mph`.
  String? unit;

  /// The limit is not known.
  bool unknown;

  /// There is no limit.
  bool none;
}

/// A live-traffic closure on a leg, as geometry indexes relative to the start
/// of the leg ([NavigationAnnotations.CLOSURE], `driving-traffic`).
class NavigationClosure {
  NavigationClosure({this.geometryIndexStart, this.geometryIndexEnd});

  NavigationClosure.fromJson(Map<String, dynamic> json)
      : geometryIndexStart = (json['geometry_index_start'] as num?)?.toInt(),
        geometryIndexEnd = (json['geometry_index_end'] as num?)?.toInt();

  int? geometryIndexStart;
  int? geometryIndexEnd;
}

/// A single maneuver and the road travelled until the next one.
class NavigationStep {
  NavigationStep({
    this.maneuver,
    this.distance,
    this.duration,
    this.geometry,
    this.name,
    this.ref,
    this.destinations,
    this.exits,
    this.drivingSide,
    this.mode,
    this.pronunciation,
    this.intersections,
  });

  NavigationStep.fromJson(Map<String, dynamic> json) {
    duration = (json['duration'] as num?)?.toDouble();
    distance = (json['distance'] as num?)?.toDouble();
    geometry = json['geometry'] as dynamic;
    name = json['name'] as String?;
    destinations = json['destinations'] as String?;
    pronunciation = json['pronunciation'] as String?;

    if (json.containsKey('driving_side') && json['driving_side'] != null) {
      switch (json['driving_side'] as String?) {
        case 'right':
          drivingSide = NavigationDrivingSide.RIGHT;
          break;
        case 'left':
          drivingSide = NavigationDrivingSide.LEFT;
          break;
      }
    }

    if (json.containsKey('mode') && json['mode'] != null) {
      switch (json['mode'] as String?) {
        case 'driving':
          mode = NavigationStepMode.DRIVING;
          break;
        case 'ferry':
          mode = NavigationStepMode.FERRY;
          break;
        case 'unaccessible':
          mode = NavigationStepMode.UNACCESSIBLE;
          break;
        case 'walking':
          mode = NavigationStepMode.WALKING;
          break;
        case 'cycling':
          mode = NavigationStepMode.CYLCING;
          break;
        case 'train':
          mode = NavigationStepMode.TRAIN;
          break;
      }
    }

    if (json.containsKey('ref') && json['ref'] != null) {
      ref = json['ref'] is String
          ? <String?>[json['ref']]
          : List<String>.from(json['ref'] as List<dynamic>);
    }

    if (json.containsKey('maneuver') && json['maneuver'] != null) {
      maneuver = NavigationManeuver.fromJson(
        json['maneuver'] as Map<String, dynamic>,
      );
    }
    if (json.containsKey('intersections') && json['intersections'] != null) {
      intersections = List<NavigationIntersection>.from(
        (json['intersections'] as List<dynamic>).map(
          (intersection) => NavigationIntersection.fromJson(
            intersection as Map<String, dynamic>,
          ),
        ),
      );
    }
    if (json.containsKey('voiceInstructions') &&
        json['voiceInstructions'] != null) {
      voiceInstructions = List<NavigationVoiceInstruction>.from(
        (json['voiceInstructions'] as List<dynamic>).map(
          (voiceInstruction) => NavigationVoiceInstruction.fromJson(
            voiceInstruction as Map<String, dynamic>,
          ),
        ),
      );
    }
    if (json.containsKey('bannerInstructions') &&
        json['bannerInstructions'] != null) {
      bannerInstructions = List<NavigationBannerInstruction>.from(
        (json['bannerInstructions'] as List<dynamic>).map(
          (bannerInstruction) => NavigationBannerInstruction.fromJson(
            bannerInstruction as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  NavigationManeuver? maneuver;
  double? duration;
  double? distance;
  dynamic geometry;
  String? name;
  List<String?>? ref;
  String? destinations;
  String? exits;
  NavigationDrivingSide? drivingSide;
  NavigationStepMode? mode;
  String? pronunciation;
  List<NavigationIntersection>? intersections;
  List<NavigationVoiceInstruction>? voiceInstructions;
  List<NavigationBannerInstruction>? bannerInstructions;
}

/// Spoken instruction along a step (`voice_instructions=true`).
class NavigationVoiceInstruction {
  NavigationVoiceInstruction({
    this.distanceAlongGeometry,
    this.announcement,
    this.ssmlAnnouncement,
  });

  NavigationVoiceInstruction.fromJson(Map<String, dynamic> json) {
    distanceAlongGeometry = (json['distanceAlongGeometry'] as num?)?.toDouble();
    announcement = json['announcement'] as String?;
    ssmlAnnouncement = json['ssmlAnnouncement'] as String?;
  }

  double? distanceAlongGeometry;
  String? announcement;
  String? ssmlAnnouncement;
}

/// Visual instruction shown along a step (`banner_instructions=true`).
class NavigationBannerInstruction {
  NavigationBannerInstruction({
    this.distanceAlongGeometry,
    this.primary,
    this.secondary,
    this.sub,
  });

  NavigationBannerInstruction.fromJson(Map<String, dynamic> json) {
    distanceAlongGeometry = (json['distanceAlongGeometry'] as num?)?.toDouble();

    if (json.containsKey('primary') && json['primary'] != null) {
      primary = NavigationInstructionProperty.fromJson(
        json['primary'] as Map<String, dynamic>,
      );
    }
    if (json.containsKey('secondary') && json['secondary'] != null) {
      secondary = NavigationInstructionProperty.fromJson(
        json['secondary'] as Map<String, dynamic>,
      );
    }
    if (json.containsKey('sub') && json['sub'] != null) {
      sub = NavigationInstructionProperty.fromJson(
        json['sub'] as Map<String, dynamic>,
      );
    }
  }

  double? distanceAlongGeometry;
  NavigationInstructionProperty? primary;
  NavigationInstructionProperty? secondary;
  NavigationInstructionProperty? sub;
}

/// Primary, secondary or sub text of a [NavigationBannerInstruction].
class NavigationInstructionProperty {
  NavigationInstructionProperty({
    this.text,
    this.type,
    this.modifier,
    this.degrees,
    this.drivingSide,
    this.components,
  });

  NavigationInstructionProperty.fromJson(Map<String, dynamic> json) {
    text = json['text'] as String?;
    degrees = (json['degrees'] as num?)?.toDouble();

    if (json.containsKey('type') && json['type'] != null) {
      switch (json['type'] as String?) {
        case 'arrive':
          type = NavigationInstructionType.ARRIVE;
          break;
        case 'depart':
          type = NavigationInstructionType.DEPART;
          break;
        case 'continue':
          type = NavigationInstructionType.CONTINUE;
          break;
        case 'end of road':
          type = NavigationInstructionType.END_OF_ROAD;
          break;
        case 'fork':
          type = NavigationInstructionType.FORK;
          break;
        case 'merge':
          type = NavigationInstructionType.MERGE;
          break;
        case 'new name':
          type = NavigationInstructionType.NEW_NAME;
          break;
        case 'notification':
          type = NavigationInstructionType.NOTIFICATION;
          break;
        case 'off ramp':
          type = NavigationInstructionType.OFF_RAMP;
          break;
        case 'on ramp':
          type = NavigationInstructionType.ON_RAMP;
          break;
        case 'rotary':
          type = NavigationInstructionType.ROTARY;
          break;
        case 'roundabout':
          type = NavigationInstructionType.ROUNDABOUT;
          break;
        case 'turn':
          type = NavigationInstructionType.TURN;
          break;
        case 'updown':
          type = NavigationInstructionType.UPDOWN;
          break;
        case 'uturn':
          type = NavigationInstructionType.UTURN;
          break;
        case 'close':
          type = NavigationInstructionType.CLOSE;
          break;
        case 'flag':
          type = NavigationInstructionType.FLAG;
          break;
      }
    }

    if (json.containsKey('modifier') && json['modifier'] != null) {
      switch (json['modifier'] as String?) {
        case 'uturn':
          modifier = NavigationInstructionModifier.UTURN;
          break;
        case 'sharp right':
          modifier = NavigationInstructionModifier.SHARP_RIGHT;
          break;
        case 'right':
          modifier = NavigationInstructionModifier.RIGHT;
          break;
        case 'slight right':
          modifier = NavigationInstructionModifier.SLIGHT_RIGHT;
          break;
        case 'straight':
          modifier = NavigationInstructionModifier.STRAIGHT;
          break;
        case 'slight left':
          modifier = NavigationInstructionModifier.SLIGHT_LEFT;
          break;
        case 'left':
          modifier = NavigationInstructionModifier.LEFT;
          break;
        case 'sharp left':
          modifier = NavigationInstructionModifier.SHARP_LEFT;
          break;
      }
    }

    if (json.containsKey('driving_side') && json['driving_side'] != null) {
      switch (json['driving_side'] as String?) {
        case 'right':
          drivingSide = NavigationDrivingSide.RIGHT;
          break;
        case 'left':
          drivingSide = NavigationDrivingSide.LEFT;
          break;
      }
    }

    if (json.containsKey('components') && json['components'] != null) {
      components = List<NavigationInstructionPropertyComponent>.from(
        (json['components'] as List<dynamic>).map(
          (component) => NavigationInstructionPropertyComponent.fromJson(
            component as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  String? text;
  NavigationInstructionType? type;
  NavigationInstructionModifier? modifier;
  double? degrees;
  NavigationDrivingSide? drivingSide;
  List<NavigationInstructionPropertyComponent>? components;
}

/// A piece of a banner instruction text (text, icon, lane, exit, …).
class NavigationInstructionPropertyComponent {
  NavigationInstructionPropertyComponent({
    this.type,
    this.text,
    this.abbr,
    this.abbrPriority,
    this.imageBaseURL,
    this.directions,
    this.active,
  });

  NavigationInstructionPropertyComponent.fromJson(Map<String, dynamic> json) {
    text = json['text'] as String?;
    abbr = json['abbr'] as String?;
    abbrPriority = (json['abbr_priority'] as num?)?.toInt();
    imageBaseURL = json['imageBaseURL'] as String?;
    active = json['active'] as bool?;

    if (json.containsKey('type') && json['type'] != null) {
      switch (json['type'] as String?) {
        case 'text':
          type = NavigationPropertyComponentType.TEXT;
          break;
        case 'icon':
          type = NavigationPropertyComponentType.ICON;
          break;
        case 'delimiter':
          type = NavigationPropertyComponentType.DELIMITER;
          break;
        case 'exit_number':
          type = NavigationPropertyComponentType.EXIT_NUMBER;
          break;
        case 'exit':
          type = NavigationPropertyComponentType.EXIT;
          break;
        case 'lane':
          type = NavigationPropertyComponentType.LANE;
          break;
      }
    }

    if (json.containsKey('directions') && json['directions'] != null) {
      directions = List<NavigationDirection>.from(
        (json['directions'] as List<dynamic>).map(
          (direction) {
            switch (direction as String) {
              case 'right':
                return NavigationDirection.RIGHT;
            }

            return NavigationDirection.LEFT;
          },
        ),
      );
    }
  }

  NavigationPropertyComponentType? type;
  String? text;
  String? abbr;
  int? abbrPriority;
  String? imageBaseURL;
  List<NavigationDirection>? directions;
  bool? active;
}

/// An intersection passed along a step.
class NavigationIntersection {
  NavigationIntersection({
    this.location,
    this.bearings,
    this.classes,
    this.entry,
    this.geometryIndex,
    this.inIndex,
    this.outIndex,
    this.lanes,
    this.duration,
  });

  NavigationIntersection.fromJson(Map<String, dynamic> json) {
    geometryIndex = (json['geometry_index'] as num?)?.toInt();
    inIndex = (json['in'] as num?)?.toInt();
    outIndex = ((json['out'] ?? json['outIndex']) as num?)?.toInt();
    duration = (json['duration'] as num?)?.toDouble();

    if (json.containsKey('location') && json['location'] != null) {
      location = doubleList(json['location']);
    }
    if (json.containsKey('entry') && json['entry'] != null) {
      entry = List<bool>.from(
        json['entry'] as List<dynamic>,
      );
    }
    if (json.containsKey('bearings') && json['bearings'] != null) {
      bearings = List<int>.from(
        json['bearings'] as List<dynamic>,
      );
    }

    if (json.containsKey('lanes') && json['lanes'] != null) {
      lanes = List<NavigationIntersectionLane>.from(
        (json['lanes'] as List<dynamic>).map(
          (lane) => NavigationIntersectionLane.fromJson(
            lane as Map<String, dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('classes') && json['classes'] != null) {
      classes = List<NavigationIntersectionClass>.from(
        (json['classes'] as List<dynamic>).map(
          (classElement) {
            switch (classElement as String) {
              case 'ferry':
                return NavigationIntersectionClass.FERRY;
              case 'toll':
                return NavigationIntersectionClass.TOLL;
              case 'restricted':
                return NavigationIntersectionClass.RESTRICTED;
              case 'motorway':
                return NavigationIntersectionClass.MOTORWAY;
              case 'tunnel':
                return NavigationIntersectionClass.TUNNEL;
            }

            return NavigationIntersectionClass.UNKNOWN;
          },
        ),
      );
    }
  }

  List<double>? location;
  List<int>? bearings;
  List<NavigationIntersectionClass>? classes;
  List<bool>? entry;
  int? geometryIndex;
  int? inIndex;
  int? outIndex;
  List<NavigationIntersectionLane>? lanes;
  double? duration;
}

/// A lane at an intersection, with its valid directions.
class NavigationIntersectionLane {
  NavigationIntersectionLane({
    this.valid,
    this.indications,
  });

  NavigationIntersectionLane.fromJson(Map<String, dynamic> json) {
    valid = json['valid'] as bool?;

    if (json.containsKey('classes') && json['classes'] != null) {
      indications = List<NavigationIndicationType>.from(
        (json['classes'] as List<dynamic>).map(
          (classElement) {
            switch (classElement as String) {
              case 'uturn':
                return NavigationIndicationType.UTURN;
              case 'sharp_right':
                return NavigationIndicationType.SHARP_RIGHT;
              case 'right':
                return NavigationIndicationType.RIGHT;
              case 'slight_right':
                return NavigationIndicationType.SLIGHT_RIGHT;
              case 'sharp_left':
                return NavigationIndicationType.SHARP_LEFT;
              case 'left':
                return NavigationIndicationType.LEFT;
              case 'slight_left':
                return NavigationIndicationType.SLIGHT_LEFT;
              case 'straight':
                return NavigationIndicationType.STRAIGHT;
            }

            return NavigationIndicationType.NONE;
          },
        ),
      );
    }
  }

  bool? valid;
  List<NavigationIndicationType>? indications;
}

/// The maneuver that starts a step.
class NavigationManeuver {
  NavigationManeuver({
    this.bearingBefore,
    this.bearingAfter,
    this.instruction,
    this.location,
    this.modifier,
    this.type,
  });
  NavigationManeuver.fromJson(Map<String, dynamic> json) {
    bearingBefore = (json['bearing_before'] as num?)?.toInt();
    bearingAfter = (json['bearing_after'] as num?)?.toInt();
    instruction = json['instruction'] as String?;

    if (json.containsKey('location') && json['location'] != null) {
      location = doubleList(json['location']);
    }

    if (json.containsKey('modifier') && json['modifier'] != null) {
      switch (json['modifier'] as String?) {
        case 'uturn':
          modifier = NavigationManeuverModifier.UTURN;
          break;
        case 'sharp right':
          modifier = NavigationManeuverModifier.SHARP_RIGHT;
          break;
        case 'right':
          modifier = NavigationManeuverModifier.RIGHT;
          break;
        case 'slight right':
          modifier = NavigationManeuverModifier.SLIGHT_RIGHT;
          break;
        case 'straight':
          modifier = NavigationManeuverModifier.STRAIGHT;
          break;
        case 'slight left':
          modifier = NavigationManeuverModifier.SLIGHT_LEFT;
          break;
        case 'left':
          modifier = NavigationManeuverModifier.LEFT;
          break;
        case 'sharp left':
          modifier = NavigationManeuverModifier.SHARP_LEFT;
          break;
      }
    }

    if (json.containsKey('type') && json['type'] != null) {
      switch (json['type'] as String?) {
        case 'arrive':
          type = NavigationManeuverType.ARRIVE;
          break;
        case 'depart':
          type = NavigationManeuverType.DEPART;
          break;
        case 'continue':
          type = NavigationManeuverType.CONTINUE;
          break;
        case 'end of road':
          type = NavigationManeuverType.END_OF_ROAD;
          break;
        case 'fork':
          type = NavigationManeuverType.FORK;
          break;
        case 'merge':
          type = NavigationManeuverType.MERGE;
          break;
        case 'new name':
          type = NavigationManeuverType.NEW_NAME;
          break;
        case 'notification':
          type = NavigationManeuverType.NOTIFICATION;
          break;
        case 'off ramp':
          type = NavigationManeuverType.OFF_RAMP;
          break;
        case 'on ramp':
          type = NavigationManeuverType.ON_RAMP;
          break;
        case 'rotary':
          type = NavigationManeuverType.ROTARY;
          break;
        case 'roundabout':
          type = NavigationManeuverType.ROUNDABOUT;
          break;
        case 'roundabout turn':
          type = NavigationManeuverType.ROUNDABOUT_TURN;
          break;
        case 'exit roundabout':
          type = NavigationManeuverType.EXIT_ROUNDABOUT;
          break;
        case 'exit rotary':
          type = NavigationManeuverType.EXIT_ROTARY;
          break;
        case 'turn':
          type = NavigationManeuverType.TURN;
          break;
        case 'updown':
          type = NavigationManeuverType.UPDOWN;
          break;
        case 'uturn':
          type = NavigationManeuverType.UTURN;
          break;
        case 'close':
          type = NavigationManeuverType.CLOSE;
          break;
        case 'flag':
          type = NavigationManeuverType.FLAG;
          break;
      }
    }
  }

  int? bearingBefore;
  int? bearingAfter;
  String? instruction;
  List<double>? location;
  NavigationManeuverModifier? modifier;
  NavigationManeuverType? type;
}

/// Base class of the errors returned by the navigation APIs.
class NavigationError extends Error {
  NavigationError({
    this.message,
  });

  String? message;
}

/// The input could not be matched to the road network (`code: NoMatch`).
class NavigationNoMatchError extends NavigationError {
  NavigationNoMatchError({
    super.message,
  });
}

/// No trip could be found by the Optimization API (`code: NoTrips`).
class NavigationNoTripsError extends NavigationError {
  NavigationNoTripsError({
    super.message,
  });
}

/// The request is not supported by the API (`code: NotImplemented`).
class NavigationNotImplementedError extends NavigationError {
  NavigationNotImplementedError({
    super.message,
  });
}

/// The request has too many coordinates (`code: TooManyCoordinates`).
class NavigationTooManyCoordinatesError extends NavigationError {
  NavigationTooManyCoordinatesError({
    super.message,
  });
}

/// No route was found between the coordinates (`code: NoRoute`).
class NavigationNoRouteError extends NavigationError {
  NavigationNoRouteError({
    super.message,
  });
}

/// A coordinate could not be snapped to the road network (`code: NoSegment`).
class NavigationNoSegmentError extends NavigationError {
  NavigationNoSegmentError({
    super.message,
  });
}

/// The routing profile does not exist (`code: ProfileNotFound`).
class NavigationProfileNotFoundError extends NavigationError {
  NavigationProfileNotFoundError({
    super.message,
  });
}

/// The request was invalid (`code: InvalidInput`).
class NavigationInvalidInputError extends NavigationError {
  NavigationInvalidInputError({
    super.message,
  });
}
