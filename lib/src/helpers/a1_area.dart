// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:a1/a1.dart';
import 'package:a1/src/helpers/a1_vector.dart';

class A1Area implements Comparable {
  /// Infininte in one direction
  final bool oneInfinite;

  /// Infinite in two directions
  final bool twoInfinite;

  /// Infinite squared
  final bool threeInfinite;
  final int magnitude;

  /// [A1Area] represents an [A1Range] area taking into account some items
  /// will be infinite/unbounded.
  ///
  /// This class is helpful for [A1Range] sorting and comparison
  ///
  /// Examples:
  /// ```dart
  /// A1Area a1Area = A1(magnitude: 2);
  /// A1Area a1Area = A1.fromA1Arange('A1:B2'.a1Range);
  /// ```
  A1Area({
    this.threeInfinite = false,
    this.twoInfinite = false,
    this.oneInfinite = false,
    required this.magnitude,
  });

  /// Create an [A1Area] from an [A1Range]
  factory A1Area.fromA1Range(A1Range range) =>
      A1Vector.fromPoints(range.from.column, range.to.column) *
      A1Vector.fromPoints(range.from.row, range.to.row);

  /// Compare two A1Areas considering their absolute sizes
  /// or their relative infinite/unbounded vectors/areas.
  @override
  int compareTo(other) {
    bool compare4 = threeInfinite == other.threeInfinite;
    bool compare3 = twoInfinite == other.twoInfinite;
    bool compare2 = oneInfinite == other.oneInfinite;
    int compare1 = magnitude.compareTo(other.magnitude);

    return switch ((compare4, compare3, compare2, compare1)) {
      (true, true, true, 0) => 0,
      (true, true, true, _) => compare1,
      (true, true, _, _) => oneInfinite ? 1 : -1,
      (true, _, _, _) => twoInfinite ? 1 : -1,
      _ => threeInfinite ? 1 : -1,
    };
  }

  /// Test if this [A1Area] matches the other [A1Area]
  @override
  bool operator ==(covariant A1Area other) {
    if (identical(this, other)) return true;

    return other.oneInfinite == oneInfinite &&
        other.twoInfinite == twoInfinite &&
        other.threeInfinite == threeInfinite &&
        other.magnitude == magnitude;
  }

  /// Returns a hascode for the attributes of this [A1Area]
  @override
  int get hashCode {
    return oneInfinite.hashCode ^
        twoInfinite.hashCode ^
        threeInfinite.hashCode ^
        magnitude.hashCode;
  }

  /// Returns a [String] for this [A1Area]
  @override
  String toString() {
    return 'A1Area(threeInfinite: $threeInfinite, twoInfinite: $twoInfinite,oneInfinite: $oneInfinite,  magnitude: $magnitude)';
  }
}
