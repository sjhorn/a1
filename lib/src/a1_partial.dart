// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:a1/a1.dart';

class A1Partial implements Comparable {
  final String? letters;
  final int? digits;

  A1Partial(this.letters, this.digits);

  A1? get a1 =>
      letters != null && digits != null ? A1.fromVector(column!, row!) : null;

  @override
  int compareTo(other) {
    return switch ((other, letters, digits)) {
      // other is B1  vs. A,B,C
      (A1(column: var column1), String(), null) when column1 > column! => -1,
      (A1(column: var column1), String(), null) when column1 == column! => 0,
      (A1(column: var column1), String(), null) when column1 < column! => 1,

      // other is B2 vs 1,2,3
      (A1(row: var row1), null, int()) when row1 > row! => -1,
      (A1(row: var row1), null, int()) when row1 == row! => 0,
      (A1(row: var row1), null, int()) when row1 < row! => 1,

      // A1 and we are an A1 too, so just use A1
      (A1(), String(), int()) => a1!.compareTo(other),

      // other is a A1Partial
      (A1Partial(), _, _) => _comparePartials(other),

      // Comparing to an unknown object
      _ => throw UnimplementedError(),
    };
  }

  int _comparePartials(A1Partial other) {
    return switch ((other.a1, other.column, other.row, a1, column, row)) {
      // both are a1s
      (A1(self: var otherA1), _, _, A1(self: var selfA1), _, _) =>
        selfA1.compareTo(otherA1),

      // if other is an a1 feed back into compareTo
      (A1(self: var otherA1), _, _, null, _, _) => compareTo(otherA1),

      // if we are an a1 and other is not
      (null, _, _, A1(self: var selfA1), _, _) => -1 * other.compareTo(selfA1),

      // we are noth partials, so we need to try and compare
      // B vs A,B,C
      (null, int(), null, null, int(), null) =>
        column!.compareTo(other.column!),

      // 2 vs 1,2,3
      (null, null, int(), null, null, int()) => row!.compareTo(other.row!),

      // A vs 1,2,3 treat any columns as larger
      (null, int(), null, null, null, int()) => 1,
      // 1 vs A,B,C treat any columns as larger
      (null, null, int(), null, int(), null) => -1,

      // 123 vs null single row range
      (null, null, int(), null, null, null) => 1,

      // null vs 123 single row range
      (null, null, null, null, null, int()) => -1,

      // A vs null single column range
      (null, int(), null, null, null, null) => 1,

      // null vs A single column range
      (null, null, null, null, int(), null) => -1,
      _ => throw UnimplementedError(),
    };
  }

  /// Return the column as a zero based [int] or null
  int? get column {
    if (letters == null) return null;
    int column = 0;
    for (final unit in letters!.codeUnits) {
      column = column * 26 + unit - 'A'.codeUnitAt(0) + 1;
    }
    return column - 1;
  }

  /// Return the row as a zero based [int] or null
  int? get row => digits != null ? digits! - 1 : null;

  bool operator <(other) => compareTo(other) < 0;
  bool operator <=(other) => compareTo(other) <= 0;
  bool operator >(other) => compareTo(other) > 0;
  bool operator >=(other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is A1) return a1 == other;

    return other is A1Partial &&
        other.letters == letters &&
        other.digits == digits;
  }

  @override
  int get hashCode => letters.hashCode ^ digits.hashCode;

  @override
  String toString() => '${letters ?? ""}${digits ?? ""}';
}
