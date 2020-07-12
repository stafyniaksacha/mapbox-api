enum GeocoderEndpoint {
  PLACES,
  PLACES_PERMANENT,
}

enum GeocoderPlaceType {
  COUNTRY,
  REGION,
  POSTCODE,
  DISTRICT,
  PLACE,
  LOCALITY,
  NEIGHBORHOOD,
  ADDRESS,
  POI,
  EMPTY,
}

enum GeocoderFeaturePropertyAccuracy {
  ROOFTOP,
  PARCEL,
  POINT,
  INTERPOLATED,
  INTERSECTION,
  APPROXIMATE,
  STREET,
}

enum GeocoderReverseMode {
  DISTANCE,
  SCORE,
}

class GeocoderBbox {
  GeocoderBbox({
    this.minX,
    this.minY,
    this.maxX,
    this.maxY,
  });
  GeocoderBbox.fromJson(List<dynamic> json) {
    minX = (json[0] as num).toDouble();
    minY = (json[1] as num).toDouble();
    maxX = (json[2] as num).toDouble();
    maxY = (json[3] as num).toDouble();
  }

  double minX;
  double minY;
  double maxX;
  double maxY;
}

class GeocoderGeometry {
  GeocoderGeometry({
    this.type,
    this.coordinates,
    this.interpolated,
    this.omitted,
  });

  GeocoderGeometry.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String;
    interpolated = json['interpolated'] as bool;
    omitted = json['omitted'] as bool;

    if (json.containsKey('coordinates') && json['coordinates'] != null) {
      coordinates = List<double>.from(
        json['coordinates'] as List<dynamic>,
      );
    }
  }

  String type;
  List<double> coordinates;
  bool interpolated;
  bool omitted;
}

class GeocoderContext {
  GeocoderContext({
    this.id,
    this.text,
    this.shortCode,
    this.wikidata,
  });

  GeocoderContext.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    text = json['text'] as String;
    shortCode = json['short_code'] as String;
    wikidata = json['wikidata'] as String;
  }

  String id;
  String text;
  String shortCode;
  String wikidata;
}

class GeocoderRoutablePoints {
  GeocoderRoutablePoints({
    this.points = const <List<double>>[],
  });

  GeocoderRoutablePoints.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('points') && json['points'] != null) {
      points = List<List<double>>.from(
        (json['points'] as List<dynamic>).map(
          (point) => List<double>.from(
            point as List<dynamic>,
          ),
        ),
      );
    }
  }

  List<List<double>> points;
}

class GeocoderFeatureProperty {
  GeocoderFeatureProperty({
    this.accuracy = GeocoderFeaturePropertyAccuracy.POINT,
    this.address,
    this.category,
    this.maki,
    this.landmark,
    this.wikidata,
    this.shortCode,
    this.tel,
  });

  GeocoderFeatureProperty.fromJson(Map<String, dynamic> json) {
    address = json['address'] as String;
    category = json['category'] as String;
    maki = json['maki'] as String;
    landmark = json['landmark'] as bool;
    wikidata = json['wikidata'] as String;
    shortCode = json['short_code'] as String;
    tel = json['tel'] as String;

    if (json.containsKey('accuracy') && json['accuracy'] != null) {
      switch (json['accuracy'] as String) {
        case 'rooftop':
          accuracy = GeocoderFeaturePropertyAccuracy.ROOFTOP;
          break;
        case 'parcel':
          accuracy = GeocoderFeaturePropertyAccuracy.PARCEL;
          break;
        case 'point':
          accuracy = GeocoderFeaturePropertyAccuracy.POINT;
          break;
        case 'interpolated':
          accuracy = GeocoderFeaturePropertyAccuracy.INTERPOLATED;
          break;
        case 'intersection':
          accuracy = GeocoderFeaturePropertyAccuracy.INTERSECTION;
          break;
        case 'street':
          accuracy = GeocoderFeaturePropertyAccuracy.STREET;
          break;
        case 'approximate':
          accuracy = GeocoderFeaturePropertyAccuracy.APPROXIMATE;
          break;
      }
    }
  }

  GeocoderFeaturePropertyAccuracy accuracy;
  String address;
  String category;
  String maki;
  bool landmark;
  String wikidata;
  String shortCode;
  String tel;
}

class GeocoderFeature {
  GeocoderFeature({
    this.id,
    this.type,
    this.placeType = const <GeocoderPlaceType>[],
    this.relevance,
    this.address,
    this.properties,
    this.text,
    this.placeName,
    this.matchingText,
    this.matchingPlaceName,
    // todo: text_{language}
    // todo: place_name_{language}
    this.language,
    // todo: language_{language}
    this.bbox,
    this.center = const <double>[],
    this.geometry,
    this.context = const <GeocoderContext>[],
    this.routablePoints,
  });

  GeocoderFeature.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    type = json['type'] as String;
    relevance = (json['relevance'] as num)?.toDouble();
    address = json['address'] as String;
    text = json['text'] as String;
    placeName = json['place_name'] as String;
    matchingText = json['matching_text'] as String;
    matchingPlaceName = json['matching_place_name'] as String;
    language = json['language'] as String;

    if (json.containsKey('geometry') && json['geometry'] != null) {
      geometry = GeocoderGeometry.fromJson(
        json['geometry'] as Map<String, dynamic>,
      );
    }
    if (json.containsKey('routable_points') &&
        json['routable_points'] != null) {
      routablePoints = GeocoderRoutablePoints.fromJson(
        json['routable_points'] as Map<String, dynamic>,
      );
    }
    if (json.containsKey('bbox') && json['bbox'] != null) {
      bbox = GeocoderBbox.fromJson(
        json['bbox'] as List<dynamic>,
      );
    }
    if (json.containsKey('center') && json['center'] != null) {
      center = List<double>.from(
        json['center'] as List<dynamic>,
      );
    }

    if (json.containsKey('properties') && json['properties'] != null) {
      properties = GeocoderFeatureProperty.fromJson(
        json['properties'] as Map<String, dynamic>,
      );
    }

    if (json.containsKey('context') && json['context'] != null) {
      context = List<GeocoderContext>.from(
        (json['context'] as List<dynamic>).map(
          (ctx) => GeocoderContext.fromJson(
            ctx as Map<String, dynamic>,
          ),
        ),
      );
    }

    if (json.containsKey('place_type') && json['place_type'] != null) {
      placeType = List<GeocoderPlaceType>.from(
        (json['place_type'] as List<dynamic>).map(
          (type) {
            switch (type as String) {
              case 'country':
                return GeocoderPlaceType.COUNTRY;
                break;
              case 'region':
                return GeocoderPlaceType.REGION;
                break;
              case 'postcode':
                return GeocoderPlaceType.POSTCODE;
                break;
              case 'district':
                return GeocoderPlaceType.DISTRICT;
                break;
              case 'place':
                return GeocoderPlaceType.PLACE;
                break;
              case 'locality':
                return GeocoderPlaceType.LOCALITY;
                break;
              case 'neighborhood':
                return GeocoderPlaceType.NEIGHBORHOOD;
                break;
              case 'address':
                return GeocoderPlaceType.ADDRESS;
                break;
              case 'poi':
                return GeocoderPlaceType.POI;
                break;
            }

            return GeocoderPlaceType.EMPTY;
          },
        ),
      );
    }
  }

  @override
  String toString() {
    return 'GeocoderFeature{'
        'id: $id, '
        'type: $type, '
        'placeType: $placeType, '
        'relevance: $relevance, '
        'address: $address, '
        'properties: $properties, '
        'text: $text, '
        'placeName: $placeName, '
        'matchingText: $matchingText, '
        'matchingPlaceName: $matchingPlaceName, '
        'language: $language, '
        'bbox: $bbox, '
        'center: $center, '
        'geometry: $geometry, '
        'context: $context, '
        'routablePoints: $routablePoints, '
        '}';
  }

  String id;
  String type;
  List<GeocoderPlaceType> placeType;
  double relevance;
  String address;
  GeocoderFeatureProperty properties;
  String text;
  String placeName;
  String matchingText;
  String matchingPlaceName;
  // todo: text_{language}
  // todo: place_name_{language}
  String language;
  // todo: language_{language}
  GeocoderBbox bbox;
  List<double> center;
  GeocoderGeometry geometry;
  List<GeocoderContext> context;
  GeocoderRoutablePoints routablePoints;
}

class GeocoderError extends Error {
  GeocoderError({
    this.message,
  });

  @override
  String toString() {
    return 'GeocoderError{'
        'message: $message, '
        '}';
  }

  String message;
}

class GeocodingApiResponse {
  GeocodingApiResponse({
    this.type,
    this.query,
    this.attribution,
    this.features,
    this.error,
  });

  GeocodingApiResponse.withError(Error error) {
    error = error;
  }

  GeocodingApiResponse.fromJson(Map<String, dynamic> json) {
    final _message = json['message'] as String;

    if (_message != null) {
      error = GeocoderError(message: _message);
    }

    type = json['type'] as String;
    attribution = json['attribution'] as String;

    if (json.containsKey('query') && json['query'] != null) {
      query = List<String>.from(
        (json['query'] as List<dynamic>).map((query) => query.toString()),
      );
    }

    if (json.containsKey('features') && json['features'] != null) {
      features = List<GeocoderFeature>.from(
        (json['features'] as List<dynamic>).map(
          (feature) => GeocoderFeature.fromJson(
            feature as Map<String, dynamic>,
          ),
        ),
      );
    }
  }

  @override
  String toString() {
    return 'GeocodingApiResponse{'
        'type: $type, '
        'query: $query, '
        'attribution: $attribution, '
        'features: $features, '
        'error: $error, '
        '}';
  }

  String type;
  List<String> query;
  String attribution;
  List<GeocoderFeature> features;
  Error error;
}
