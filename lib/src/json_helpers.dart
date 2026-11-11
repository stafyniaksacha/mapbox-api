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

/// Nested lists with every number converted to a double (GeoJSON
/// coordinates of any depth).
Object? deepDoubles(Object? json) => switch (json) {
      final List<dynamic> list => [
          for (final value in list) deepDoubles(value)
        ],
      final num number => number.toDouble(),
      _ => json,
    };
