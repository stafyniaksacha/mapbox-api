// Internal JSON helpers for response parsing. Not exported.
//
// JSON numbers decode to `int` when they have no fractional part (`573`),
// so `List<double>.from(...)` fails on real responses. These helpers accept
// any number.

/// A list of numbers as doubles.
List<double> doubleList(Object? json) =>
    [for (final value in json! as List<dynamic>) (value as num).toDouble()];

/// A matrix row: numbers as doubles, `null` (no route between the pair) as
/// [double.infinity].
List<double> matrixRow(Object? json) => [
      for (final value in json! as List<dynamic>)
        value == null ? double.infinity : (value as num).toDouble(),
    ];

/// GeoJSON coordinates of any depth with every number as a double, typed by
/// depth: `List<double>` (Point), `List<List<double>>` (LineString),
/// `List<List<List<double>>>` (Polygon), `List<List<List<List<double>>>>`
/// (MultiPolygon). Throws when an element is neither a number nor a list.
List<dynamic> coordinatesOfAnyDepth(List<dynamic> json) {
  if (json.every((value) => value is num)) {
    return doubleList(json);
  }
  final children = [
    for (final value in json) coordinatesOfAnyDepth(value as List<dynamic>),
  ];
  if (children.every((child) => child is List<double>)) {
    return children.cast<List<double>>().toList();
  }
  if (children.every((child) => child is List<List<double>>)) {
    return children.cast<List<List<double>>>().toList();
  }
  if (children.every((child) => child is List<List<List<double>>>)) {
    return children.cast<List<List<List<double>>>>().toList();
  }
  return children;
}
