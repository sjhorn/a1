// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:a1/src/a1_partial.dart';
import 'package:a1/src/a1_range.dart';
import 'package:a1/src/grammer/a1_notation.dart';
import 'package:petitparser/petitparser.dart';

class A1 implements Comparable<A1> {
  static final A1Notation _a1n = A1Notation();

  /// Uppercase letters for the A part of A1 notation
  late final String letters;

  /// Digits for the 1 in the A1 notation
  late final int digits;

  /// Utility for self reference in new pattern matching
  A1 get self => this;

  /// Private contructor
  A1._(this.letters, this.digits);

  /// Parses a string containing an A1 literal into an A1.
  ///
  /// If that fails, too, it throws a [FormatException].
  ///
  /// Rather than throwing and immediately catching the [FormatException],
  /// instead use [tryParse] to handle a potential parsing error.
  ///
  /// Examples:
  /// ```dart
  /// A1 a1 = A1.parse('a1'); //A1
  /// a1 = A1.parse('b2');  // B2
  /// a1 = A1.parse(' B345'); // B324
  /// a1 = A1.parse('A0'); // FormatException
  /// a1 = A1.parse('1A'); // FormatException
  /// a1 = A1.parse('A-1'); // FormatException
  /// ```
  static A1 parse(String input) {
    final result = tryParse(input);
    if (result == null) {
      throw FormatException('Invalid A1 notation $input', input, 0);
    }
    return result;
  }

  /// Parses a string containing an A1 literal into an A1.
  ///
  /// Like [parse], except that this function returns `null` for invalid inputs
  /// instead of throwing.
  ///
  /// Examples:
  /// ```dart
  /// A1? a1 = A1.tryParse('a1'); //A1
  /// a1 = A1.tryParse('b2');  // B2
  /// a1 = A1.tryParse(' B345'); // B324
  /// a1 = A1.tryParse('A0'); // null
  /// a1 = A1.tryParse('1A'); // null
  /// a1 = A1.tryParse('A-1'); // null
  /// ```
  static A1? tryParse(String input) {
    final result = _a1n.buildFrom(_a1n.a1()).end().parse(input);
    if (result is Failure ||
        result.value[#column] == null ||
        result.value[#row] == null) {
      return null;
    }
    final column = result.value[#column]!;
    final row = int.tryParse(result.value[#row]!);
    if (row == null) return null;
    return A1._(column, row);
  }

  /// Returns a (column, row) vector representing the A1
  ///
  /// Both column are row are [int] that are zero-based
  (int column, int row) get vector => (column, row);

  /// Create an A1 from column and row
  ///
  /// Both column are row are [int] that are zero-based
  ///
  /// Examples:
  /// ```dart
  /// A1 a1 = A1.fromVector(0,0); //A1
  /// a1 = A1.fromVector(1,1);  // B2
  /// a1 = A1.fromVector(1,344); // B324
  /// a1 = A1.fromVector(1,-1); // FormatException
  /// ```
  A1.fromVector(int column, int row) {
    if (column < 0 || row < 0) {
      throw FormatException('column & row must be positive ($column,$row)');
    }

    final codeUnits = <int>[];
    if (column < 26) {
      codeUnits.add(65 + column);
    } else {
      var evaluationIndex = column;
      while (evaluationIndex >= 26) {
        codeUnits.add(65 + evaluationIndex % 26);
        evaluationIndex = (evaluationIndex / 26 - 1).floor();
      }
      codeUnits.add(65 + evaluationIndex);
    }
    letters = String.fromCharCodes(codeUnits.reversed);
    digits = row + 1;
  }

  /// Create a list of A1's between this A1 and to
  ///
  /// Examples:
  /// ```dart
  /// List<A1> a1 = A1.fromVector(0,0).rangeTo('A2'.a1); // [A1,A2]
  /// a1 = A1.fromVector(0,0).rangeTo('B1'.a1); // [A1,B1]
  /// a1 = A1.fromVector(0,0).rangeTo('C2'.a1); // [A1,A2,B1,B2,C1,C2]
  /// ```
  List<A1> rangeTo(A1 to) {
    final result = <A1>[];
    final columns = (min(to.column, column), max(to.column, column));
    final rows = (min(to.row, row), max(to.row, row));
    for (var i = columns.$1; i <= columns.$2; i++) {
      for (var j = rows.$1; j <= rows.$2; j++) {
        result.add(A1.fromVector(i, j));
      }
    }
    return result;
  }

  /// Return a [String] of the A1
  @override
  String toString() => '$letters$digits';

  /// Return the column as a zero based [int]
  int get column {
    int column = 0;
    for (final unit in letters.codeUnits) {
      column = column * 26 + unit - 'A'.codeUnitAt(0) + 1;
    }
    return column - 1;
  }

  /// Return the row as a zero based [int]
  int get row => digits - 1;

  /// Test whether this A1 is equal to `other`.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is A1Partial) return other.a1 == this;
    return other is A1 && other.letters == letters && other.digits == digits;
  }

  /// Returns a hash code for a numerical value.
  ///
  /// The hash code is compatible with equality. It returns the same value
  @override
  int get hashCode => letters.hashCode ^ digits.hashCode;

  /// Compares this to `other` [A1].
  ///
  /// Returns a negative number if `this` is less than `other`, zero if they are
  /// equal, and a positive number if `this` is greater than `other`.
  ///
  /// Examples:
  /// ```dart
  /// print('a1'.a1.compareTo('a2'.a1)); // => -1
  /// print('a2'.a1.compareTo('a1'.a1)); // => 1
  /// print('a1'.a1.compareTo('a1'.a1)); // => 0
  /// ```
  @override
  int compareTo(A1 other) {
    return row < other.row
        ? -1
        : row > other.row
            ? 1
            : column < other.column
                ? -1
                : column > other.column
                    ? 1
                    : 0;
  }

  /// Sum operator for two [A1]s
  A1 operator +(A1 other) =>
      A1.fromVector(column + other.column, row + other.row);

  /// Returns the [A1] to the right of the current [A1]
  A1 get right => A1.fromVector(column + 1, row);

  /// Returns the [A1] to the left of the current [A1] if already
  /// in column 0 will return a copy of the current cell
  A1 get left => A1.fromVector(max(0, column - 1), row);

  /// Returns the [A1] below the current [A1]
  A1 get down => A1.fromVector(column, row + 1);

  /// Returns the [A1] above the current [A1] if already
  /// in row 0 will return a copy of the current cell
  A1 get up => A1.fromVector(column, max(0, row - 1));

  // Less than operator for two [A1]s
  bool operator <(A1 other) => compareTo(other) < 0;

  // Less than equal to operator for two [A1]s
  bool operator <=(A1 other) => compareTo(other) <= 0;

  // Greater than operator for two [A1]s
  bool operator >(A1 other) => compareTo(other) > 0;

  // Greater than equal to operator for two [A1]s
  bool operator >=(A1 other) => compareTo(other) >= 0;

  // Area between two A1s
  int area(A1 other) =>
      (max(column, other.column) - min(column, other.column)) *
          (max(row, other.row) - min(row, other.row)) as int;
}

/// Utility extension to help the comparison be more expressive
extension A1Tools on int {
  bool get isA1Letter => this >= 'A'.codeUnitAt(0) && this <= 'Z'.codeUnitAt(0);
  bool get isA1Digit => this >= '0'.codeUnitAt(0) && this <= '9'.codeUnitAt(0);
}

/// This extension allows an [A1] to be create from a [String]
extension StringA1Extension on String {
  /// Return an [A1] from the current [String] or throw
  /// a [FormatException] see [A1.parse].
  A1 get a1 => A1.parse(this);
}

/// This extension allows a [List] of [String]s to be converted to
/// a [List] of [A1]
extension StringListA1Extension on List<String> {
  /// Return a [List<A1>] from the current [List<String>] or throw
  /// a [FormatException] see [A1.parse].
  /// Example:
  /// ```dart
  /// List<A1> a1List = ['a1','b2','c3].a1; // <A1>[A1,A2,A3]
  /// ```
  Iterable<A1> get a1 => map((e) => e.a1);
}
