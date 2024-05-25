// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:a1/src/helpers/a1_area.dart';

class A1Vector {
  /// true if one point is infinate/unbounded
  final bool oneInfinite;

  /// true if both points are infinate/unbounded
  final bool twoInfinite;

  /// if we have both dimensions
  final int magnitude;

  /// Create an [A1Vector]
  ///
  /// Examples:
  /// ```dart
  /// A1Vector a1v = A1Vector(magnitude: 3);
  /// A1Vector a1v = A1Vector.fromPoints(6, 3);
  /// ```
  A1Vector({
    this.twoInfinite = false,
    this.oneInfinite = false,
    required this.magnitude,
  });

  /// Create a vector based on two points, where one or both can be null
  ///
  /// If only the first point is null, then this will be bounded between 0 and
  /// second point, but still market oneInfinite
  ///
  /// If only second point is null, this is treated as having a infinite upper
  /// bound that has a negative magnitude based on the first point. Marked as
  /// oneInfinite
  ///
  /// If first and second are null, this this is market as twoInfinite
  ///
  factory A1Vector.fromPoints(int? first, int? second) =>
      switch ((first, second)) {
        (null, null) =>
          A1Vector(magnitude: 0, oneInfinite: true, twoInfinite: true),
        (null, int()) => A1Vector(magnitude: second! + 1, oneInfinite: true),
        (int(), null) => A1Vector(
            magnitude: -1 * (first! + 1), oneInfinite: true, twoInfinite: true),
        (int(), int()) => A1Vector(magnitude: second! - first! + 1),
      };

  /// The product of two [A1Vector] produces an [A1Area]
  ///
  /// This is used for [A1Range] area comparisons
  ///
  /// Depending on the oneInfinite and twoInfinite attributes of the [A1Vector]s
  /// the [A1Area] will be attributed with oneInfinite, twoInfinite and
  /// threeInfinite as well as a magnitude for comparison.
  A1Area operator *(A1Vector other) {
    if (twoInfinite && other.twoInfinite) {
      return A1Area(
          magnitude: magnitude + other.magnitude,
          oneInfinite: true,
          twoInfinite: true,
          threeInfinite: true);
    } else if (twoInfinite) {
      return A1Area(
          magnitude: magnitude + other.magnitude,
          oneInfinite: true,
          twoInfinite: true);
    } else if (other.twoInfinite) {
      return A1Area(
          magnitude: magnitude + other.magnitude,
          oneInfinite: true,
          twoInfinite: true);
    } else if (oneInfinite && other.oneInfinite) {
      return A1Area(
          magnitude: magnitude * other.magnitude,
          oneInfinite: true,
          twoInfinite: true);
    } else if (oneInfinite) {
      return A1Area(
          magnitude: other.magnitude, oneInfinite: true, twoInfinite: true);
    } else if (other.oneInfinite) {
      return A1Area(magnitude: magnitude, oneInfinite: true, twoInfinite: true);
    } else {
      return A1Area(magnitude: magnitude * other.magnitude);
    }
  }

  /// Compare [A1Vector]s for equality
  @override
  bool operator ==(covariant A1Vector other) {
    if (identical(this, other)) return true;

    return other.oneInfinite == oneInfinite &&
        other.twoInfinite == twoInfinite &&
        other.magnitude == magnitude;
  }

  /// [A1Vector]s hashcode based on its attributes
  @override
  int get hashCode =>
      oneInfinite.hashCode ^ twoInfinite.hashCode ^ magnitude.hashCode;

  // [A1Vector]s string based on its attributes
  @override
  String toString() =>
      'A1Vector(twoInfinite: $twoInfinite, oneInfinite: $oneInfinite, magnitude: $magnitude)';
}
