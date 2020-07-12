enum NavigationProfile {
  DRIVING_TRAFFIC,
  DRIVING,
  WALKING,
  CYCLING,
}

enum NavigationAnnotations {
  DURATION,
  DISTANCE,
  SPEED,
  CONGESTION,
}

enum NavigationExclude {
  TOLL,
  MOTORWAY,
  FERRY,
}

enum NavigationGeometries {
  GEOJSON,
  POLYLINE,
  POLYLINE6,
}

enum NavigationOverview {
  FULL,
  SIMPLIFIED,
  NONE,
}

enum NavigationApproaches {
  UNRESTRICTED,
  CURB,
}

enum NavigationVoiceUnits {
  IMPERIAL,
  METRIC,
}

enum NavigationStepMode {
  DRIVING,
  FERRY,
  UNACCESSIBLE,
  WALKING,
  CYLCING,
  TRAIN,
}

enum NavigationInstructionType {
  TURN,
  MERGE,
  DEPART,
  ARRIVE,
  FORK,
  OFF_RAMP,
  ROUNDABOUT,
}

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

enum NavigationDrivingSide {
  LEFT,
  RIGHT,
}

enum NavigationPropertyComponentType {
  TEXT,
  ICON,
  DELIMITER,
  EXIT_NUMBER,
  EXIT,
  LANE,
}

enum NavigationDirection {
  LEFT,
  RIGHT,
  STRAIGHT,
}

enum NavigationIntersectionClass {
  UNKNOWN,
  TOLL,
  FERRY,
  RESTRICTED,
  MOTORWAY,
  TUNNEL,
}

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
}

enum NavigationDestination {
  ANY,
  LAST,
}

enum NavigationSource {
  ANY,
  FIRST,
}

class NavigationBearings {
  NavigationBearings(
    this.angle,
    this.degree,
  );

  NavigationBearings.fromJson(Map<String, dynamic> json) {
    angle = (json['angle'] as num)?.toDouble();
    degree = (json['degree'] as num)?.toDouble();
  }

  double angle;
  double degree;
}

class NavigationFeature {
  NavigationFeature({
    this.type,
    this.properties,
    this.geometry,
  });

  NavigationFeature.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String;

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

  String type;
  NavigationFeatureProperty properties;
  NavigationFeatureGeometry geometry;
}

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
    contour = (json['contour'] as num)?.toInt();
    color = json['color'] as String;
    opacity = (json['opacity'] as num)?.toDouble();
    fill = json['fill'] as String;
    fillColor = json['fillColor'] as String;
    fillOpacity = (json['fillOpacity'] as num)?.toDouble();
  }

  int contour;
  String color;
  double opacity;
  String fill;
  String fillColor;
  double fillOpacity;
}

class NavigationFeatureGeometry {
  NavigationFeatureGeometry({
    this.coordinates,
    this.type,
  });

  NavigationFeatureGeometry.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String;

    if (json.containsKey('coordinates') && json['coordinates'] != null) {
      coordinates = List<double>.from(
        json['coordinates'] as List<dynamic>,
      );
    }
  }

  List<double> coordinates;
  String type;
}

class NavigationWaypoint {
  NavigationWaypoint({
    this.name,
    this.location = const <double>[],
    this.distance,
  });

  NavigationWaypoint.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;
    distance = (json['distance'] as num)?.toDouble();

    if (json.containsKey('location') && json['location'] != null) {
      location = List<double>.from(
        json['location'] as List<dynamic>,
      );
    }
  }

  String name;
  List<double> location;
  double distance;
}

class NavigationOptimizedWaypoint {
  NavigationOptimizedWaypoint({
    this.name,
    this.location = const <double>[],
    this.tripsIndex,
    this.waypointIndex,
  });

  NavigationOptimizedWaypoint.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;
    tripsIndex = (json['trips_index'] as num)?.toInt();
    waypointIndex = (json['waypoint_index'] as num)?.toInt();

    if (json.containsKey('location') && json['location'] != null) {
      location = List<double>.from(
        json['location'] as List<dynamic>,
      );
    }
  }

  String name;
  List<double> location;
  int tripsIndex;
  int waypointIndex;
}

class NavigationTracepoint extends NavigationWaypoint {
  NavigationTracepoint({
    this.matchingsIndex,
    this.waypointIndex,
    this.alternativesCount,
    String name,
    List<double> location,
    double distance,
  }) : super(
          name: name,
          location: location,
          distance: distance,
        );

  NavigationTracepoint.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String;
    distance = (json['distance'] as num)?.toDouble();
    matchingsIndex = (json['matchings_index'] as num)?.toInt();
    waypointIndex = (json['waypoint_index'] as num)?.toInt();
    alternativesCount = (json['alternatives_count'] as num)?.toInt();

    if (json.containsKey('location') && json['location'] != null) {
      location = List<double>.from(
        json['location'] as List<dynamic>,
      );
    }
  }

  int matchingsIndex;
  int waypointIndex;
  int alternativesCount;
}

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
    duration = (json['duration'] as num)?.toDouble();
    distance = (json['distance'] as num)?.toDouble();
    weightName = json['weightName'] as String;
    weight = (json['weight'] as num)?.toDouble();
    geometry = json['geometry'] as dynamic;
    voiceLocale = json['voiceLocale'] as String;

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

  double duration;
  double distance;
  String weightName;
  double weight;
  dynamic geometry;
  List<NavigationLeg> legs;
  String voiceLocale;
}

class NavigationMatchRoute extends NavigationRoute {
  NavigationMatchRoute({
    this.confidence,
    double duration,
    double distance,
    String weightName,
    double weight,
    dynamic geometry,
    List<NavigationLeg> legs,
    String voiceLocale,
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
    confidence = (json['confidence'] as num)?.toDouble();
    duration = (json['duration'] as num)?.toDouble();
    distance = (json['distance'] as num)?.toDouble();
    weightName = json['weightName'] as String;
    weight = (json['weight'] as num)?.toDouble();
    geometry = json['geometry'] as dynamic;
    voiceLocale = json['voiceLocale'] as String;

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

  double confidence;
}

class NavigationLeg {
  NavigationLeg({
    this.duration,
    this.distance,
    this.steps = const <NavigationStep>[],
    this.summary,
    this.annotation,
  });

  NavigationLeg.fromJson(Map<String, dynamic> json) {
    duration = (json['duration'] as num)?.toDouble();
    distance = (json['distance'] as num)?.toDouble();
    summary = json['summary'] as String;

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
  }

  double duration;
  double distance;
  List<NavigationStep> steps;
  String summary;
  NavigationAnnotation annotation;
}

class NavigationAnnotation {
  NavigationAnnotation({
    this.duration,
    this.distance,
    this.speed,
    this.congestion,
  });

  NavigationAnnotation.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('duration') && json['duration'] != null) {
      duration = List<double>.from(
        json['duration'] as List<dynamic>,
      );
    }
    if (json.containsKey('distance') && json['distance'] != null) {
      distance = List<double>.from(
        json['distance'] as List<dynamic>,
      );
    }
    if (json.containsKey('speed') && json['speed'] != null) {
      speed = List<double>.from(
        json['speed'] as List<dynamic>,
      );
    }
    if (json.containsKey('congestion') && json['congestion'] != null) {
      congestion = List<String>.from(
        json['congestion'] as List<dynamic>,
      );
    }
  }

  List<double> duration;
  List<double> distance;
  List<double> speed;
  List<String> congestion;
}

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
    duration = (json['duration'] as num)?.toDouble();
    distance = (json['distance'] as num)?.toDouble();
    geometry = json['geometry'] as dynamic;
    name = json['name'] as String;
    destinations = json['destinations'] as String;
    pronunciation = json['pronunciation'] as String;

    if (json.containsKey('driving_side') && json['driving_side'] != null) {
      switch (json['driving_side'] as String) {
        case 'right':
          drivingSide = NavigationDrivingSide.RIGHT;
          break;
        case 'left':
          drivingSide = NavigationDrivingSide.LEFT;
          break;
      }
    }

    if (json.containsKey('mode') && json['mode'] != null) {
      switch (json['mode'] as String) {
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
          ? <String>[json['ref']]
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

  NavigationManeuver maneuver;
  double duration;
  double distance;
  dynamic geometry;
  String name;
  List<String> ref;
  String destinations;
  String exits;
  NavigationDrivingSide drivingSide;
  NavigationStepMode mode;
  String pronunciation;
  List<NavigationIntersection> intersections;
  List<NavigationVoiceInstruction> voiceInstructions;
  List<NavigationBannerInstruction> bannerInstructions;
}

class NavigationVoiceInstruction {
  NavigationVoiceInstruction({
    this.distanceAlongGeometry,
    this.announcement,
    this.ssmlAnnouncement,
  });

  NavigationVoiceInstruction.fromJson(Map<String, dynamic> json) {
    distanceAlongGeometry = (json['distanceAlongGeometry'] as num)?.toDouble();
    announcement = json['announcement'] as String;
    ssmlAnnouncement = json['ssmlAnnouncement'] as String;
  }

  double distanceAlongGeometry;
  String announcement;
  String ssmlAnnouncement;
}

class NavigationBannerInstruction {
  NavigationBannerInstruction({
    this.distanceAlongGeometry,
    this.primary,
    this.secondary,
    this.sub,
  });

  NavigationBannerInstruction.fromJson(Map<String, dynamic> json) {
    distanceAlongGeometry = (json['distanceAlongGeometry'] as num)?.toDouble();

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

  double distanceAlongGeometry;
  NavigationInstructionProperty primary;
  NavigationInstructionProperty secondary;
  NavigationInstructionProperty sub;
}

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
    text = json['text'] as String;
    degrees = (json['degrees'] as num)?.toDouble();

    if (json.containsKey('type') && json['type'] != null) {
      switch (json['type'] as String) {
        case 'turn':
          type = NavigationInstructionType.TURN;
          break;
        case 'merge':
          type = NavigationInstructionType.MERGE;
          break;
        case 'depart':
          type = NavigationInstructionType.DEPART;
          break;
        case 'fork':
          type = NavigationInstructionType.FORK;
          break;
        case 'off ramp':
          type = NavigationInstructionType.OFF_RAMP;
          break;
        case 'roundabout':
          type = NavigationInstructionType.ROUNDABOUT;
          break;
      }
    }

    if (json.containsKey('modifier') && json['modifier'] != null) {
      switch (json['modifier'] as String) {
        case 'uturn':
          modifier = NavigationInstructionModifier.UTURN;
          break;
        case 'sharp_right':
          modifier = NavigationInstructionModifier.SHARP_RIGHT;
          break;
        case 'slight_right':
          modifier = NavigationInstructionModifier.SLIGHT_RIGHT;
          break;
        case 'straight':
          modifier = NavigationInstructionModifier.STRAIGHT;
          break;
        case 'slight_left':
          modifier = NavigationInstructionModifier.SLIGHT_LEFT;
          break;
        case 'left':
          modifier = NavigationInstructionModifier.LEFT;
          break;
        case 'sharp_left':
          modifier = NavigationInstructionModifier.SHARP_LEFT;
          break;
      }
    }

    if (json.containsKey('driving_side') && json['driving_side'] != null) {
      switch (json['driving_side'] as String) {
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

  String text;
  NavigationInstructionType type;
  NavigationInstructionModifier modifier;
  double degrees;
  NavigationDrivingSide drivingSide;
  List<NavigationInstructionPropertyComponent> components;
}

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
    text = json['text'] as String;
    abbr = json['abbr'] as String;
    abbrPriority = (json['abbr_priority'] as num)?.toInt();
    imageBaseURL = json['imageBaseURL'] as String;
    active = json['active'] as bool;

    if (json.containsKey('type') && json['type'] != null) {
      switch (json['type'] as String) {
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
                break;
            }

            return NavigationDirection.LEFT;
          },
        ),
      );
    }
  }

  NavigationPropertyComponentType type;
  String text;
  String abbr;
  int abbrPriority;
  String imageBaseURL;
  List<NavigationDirection> directions;
  bool active;
}

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
    geometryIndex = (json['geometry_index'] as num)?.toInt();
    inIndex = (json['in'] as num)?.toInt();
    outIndex = (json['outIndex'] as num)?.toInt();
    duration = (json['duration'] as num)?.toDouble();

    if (json.containsKey('location') && json['location'] != null) {
      location = List<double>.from(
        json['location'] as List<dynamic>,
      );
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
                break;
              case 'toll':
                return NavigationIntersectionClass.TOLL;
                break;
              case 'restricted':
                return NavigationIntersectionClass.RESTRICTED;
                break;
              case 'motorway':
                return NavigationIntersectionClass.MOTORWAY;
                break;
              case 'tunnel':
                return NavigationIntersectionClass.TUNNEL;
                break;
            }

            return NavigationIntersectionClass.UNKNOWN;
          },
        ),
      );
    }
  }

  List<double> location;
  List<int> bearings;
  List<NavigationIntersectionClass> classes;
  List<bool> entry;
  int geometryIndex;
  int inIndex;
  int outIndex;
  List<NavigationIntersectionLane> lanes;
  double duration;
}

class NavigationIntersectionLane {
  NavigationIntersectionLane({
    this.valid,
    this.indications,
  });

  NavigationIntersectionLane.fromJson(Map<String, dynamic> json) {
    valid = json['valid'] as bool;

    if (json.containsKey('classes') && json['classes'] != null) {
      indications = List<NavigationIndicationType>.from(
        (json['classes'] as List<dynamic>).map(
          (classElement) {
            switch (classElement as String) {
              case 'uturn':
                return NavigationIndicationType.UTURN;
                break;
              case 'sharp_right':
                return NavigationIndicationType.SHARP_RIGHT;
                break;
              case 'right':
                return NavigationIndicationType.RIGHT;
                break;
              case 'slight_right':
                return NavigationIndicationType.SLIGHT_RIGHT;
                break;
              case 'sharp_left':
                return NavigationIndicationType.SHARP_LEFT;
                break;
              case 'left':
                return NavigationIndicationType.LEFT;
                break;
              case 'slight_left':
                return NavigationIndicationType.SLIGHT_LEFT;
                break;
              case 'straight':
                return NavigationIndicationType.STRAIGHT;
                break;
            }

            return NavigationIndicationType.NONE;
          },
        ),
      );
    }
  }

  bool valid;
  List<NavigationIndicationType> indications;
}

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
    bearingBefore = (json['bearing_before'] as num)?.toInt();
    bearingAfter = (json['bearing_after'] as num)?.toInt();
    instruction = json['instruction'] as String;

    if (json.containsKey('location') && json['location'] != null) {
      location = List<double>.from(
        json['location'] as List<dynamic>,
      );
    }

    if (json.containsKey('modifier') && json['modifier'] != null) {
      switch (json['modifier'] as String) {
        case 'uturn':
          modifier = NavigationManeuverModifier.UTURN;
          break;
        case 'sharp_right':
          modifier = NavigationManeuverModifier.SHARP_RIGHT;
          break;
        case 'right':
          modifier = NavigationManeuverModifier.RIGHT;
          break;
        case 'slap_right':
          modifier = NavigationManeuverModifier.SLIGHT_RIGHT;
          break;
        case 'sharp_left':
          modifier = NavigationManeuverModifier.SHARP_LEFT;
          break;
        case 'left':
          modifier = NavigationManeuverModifier.LEFT;
          break;
        case 'slap_left':
          modifier = NavigationManeuverModifier.SLIGHT_LEFT;
          break;
        case 'straight':
          modifier = NavigationManeuverModifier.STRAIGHT;
          break;
      }
    }
    if (json.containsKey('type') && json['type'] != null) {
      switch (json['type'] as String) {
        case 'turn':
          type = NavigationManeuverType.TURN;
          break;
        case 'new name':
          type = NavigationManeuverType.NEW_NAME;
          break;
        case 'depart':
          type = NavigationManeuverType.DEPART;
          break;
        case 'arrive':
          type = NavigationManeuverType.ARRIVE;
          break;
        case 'merge':
          type = NavigationManeuverType.MERGE;
          break;
        case 'on ramp':
          type = NavigationManeuverType.ON_RAMP;
          break;
        case 'off ramp':
          type = NavigationManeuverType.OFF_RAMP;
          break;
        case 'fork':
          type = NavigationManeuverType.FORK;
          break;
        case 'end of road':
          type = NavigationManeuverType.END_OF_ROAD;
          break;
        case 'continue':
          type = NavigationManeuverType.CONTINUE;
          break;
        case 'roundabout':
          type = NavigationManeuverType.ROUNDABOUT;
          break;
        case 'rotary':
          type = NavigationManeuverType.ROTARY;
          break;
        case 'roundabout turn':
          type = NavigationManeuverType.ROUNDABOUT_TURN;
          break;
        case 'notification':
          type = NavigationManeuverType.NOTIFICATION;
          break;
        case 'exit roundabout':
          type = NavigationManeuverType.EXIT_ROUNDABOUT;
          break;
        case 'exit rotary':
          type = NavigationManeuverType.EXIT_ROTARY;
          break;
      }
    }
  }

  int bearingBefore;
  int bearingAfter;
  String instruction;
  List<double> location;
  NavigationManeuverModifier modifier;
  NavigationManeuverType type;
}

class NavigationError extends Error {
  NavigationError({
    this.message,
  });

  String message;
}

class NavigationNoMatchError extends NavigationError {
  NavigationNoMatchError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationNoTripsError extends NavigationError {
  NavigationNoTripsError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationNotImplementedError extends NavigationError {
  NavigationNotImplementedError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationTooManyCoordinatesError extends NavigationError {
  NavigationTooManyCoordinatesError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationNoRouteError extends NavigationError {
  NavigationNoRouteError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationNoSegmentError extends NavigationError {
  NavigationNoSegmentError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationProfileNotFoundError extends NavigationError {
  NavigationProfileNotFoundError({
    String message,
  }) : super(
          message: message,
        );
}

class NavigationInvalidInputError extends NavigationError {
  NavigationInvalidInputError({
    String message,
  }) : super(
          message: message,
        );
}
