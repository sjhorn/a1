// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A1:B2 refers to the first two cells in the top two rows of Sheet1.
// A:A refers to all the cells in the first column of Sheet1.
// 1:2 refers to all the cells in the first two rows of Sheet1.
// A5:A refers to all the cells of the first column of Sheet 1, from row 5 onward.

import 'package:petitparser/petitparser.dart';

import 'package:a1/a1.dart';
import 'package:a1/src/grammer/a1_notation.dart';

class A1Range implements Comparable<A1Range> {
  static final A1Notation _a1n = A1Notation();
  static final _parser = _a1n.buildFrom(_a1n.range()).end();

  /// range from A1Partial
  late final A1Partial from;

  /// range to A1Partial
  late final A1Partial to;

  /// optional anchor a1
  final A1? anchor;

  /// Private contructor
  A1Range._(A1Partial from, A1Partial to, {this.anchor}) {
    // normalise the reverse diagonal to always have
    // eg. A2:B3
    switch ((from.a1, to.a1)) {
      case (
            A1(column: var columnFrom, row: var rowFrom),
            A1(column: var columnTo, row: var rowTo)
          )
          when columnTo < columnFrom:
        this.from = A1Partial.fromVector(columnTo, rowFrom);
        this.to = A1Partial.fromVector(columnFrom, rowTo);
      default:
        this.from = from;
        this.to = to;
    }
  }

  /// Creates a range from two supplied A1Partials for from and to
  /// ensures 'from' is less than or equal to 'to' when not all
  /// if the from is an A1 is will be treated as the anchor
  static A1Range fromPartials(A1Partial from, A1Partial to) {
    if ((from.isAll || to.isAll) || from <= to) {
      return A1Range._(from, to, anchor: from.a1);
    } else {
      return A1Range._(to, from, anchor: from.a1);
    }
  }

  /// Creates a range from two supplied A1s for from and to
  /// ensures 'from' is less than or equal to 'to'
  /// the fromA1 will be used as the anchor in the range
  static A1Range fromA1s(A1 fromA1, A1 toA1) {
    final from = A1Partial.fromA1(fromA1);
    final to = A1Partial.fromA1(toA1);
    if (from <= to) {
      return A1Range._(from, to, anchor: fromA1);
    } else {
      return A1Range._(to, from, anchor: fromA1);
    }
  }

  /// Parses a string containing an A1Range literal into an A1Range.
  ///
  /// If that fails, too, it throws a [FormatException].
  ///
  /// Rather than throwing and immediately catching the [FormatException],
  /// instead use [tryParse] to handle a potential parsing error.
  ///
  /// Examples:
  /// ```dart
  /// A1Range a1Range = A1.parse('a1:b2'); //A1:B2
  /// a1Range = A1Range.parse('b2:z100');  // B2:Z100
  /// a1Range = A1Range.parse('A1:'); // FormatException
  /// a1Range = A1Range.parse(':A1'); // FormatException
  /// ```
  static A1Range parse(String input) {
    final result = tryParse(input);
    if (result == null) {
      throw FormatException('Invalid A1Range notation $input', input, 0);
    }
    return result;
  }

  /// Parses a string containing an A1Range literal into an A1Range.
  ///
  /// Like [parse], except that this function returns `null` for invalid inputs
  /// instead of throwing.
  ///
  /// Examples:
  /// ```dart
  /// A1Range? a1 = A1Range.tryParse('a1:b2'); //A1:B2
  /// a1Range = A1Range.tryParse('b2:z2');  // B2:Z2
  /// a1Range = A1Range.tryParse('A1:'); // null
  /// a1Range = A1Range.tryParse(':A1'); // null
  /// a1Range = A1Range.tryParse(''); // null
  /// ```
  static A1Range? tryParse(String input) {
    final result = _parser.parse(input);
    if (result is Failure) {
      return null;
    }
    final value = result.value;
    final left = A1Partial(value[#column1], int.tryParse(value[#row1] ?? ''));
    final right = A1Partial(value[#column2], int.tryParse(value[#row2] ?? ''));

    return A1Range.fromPartials(left, right);
  }

  /// Compare the area of two ranges to determine which is bigger
  @override
  int compareTo(A1Range other) =>
      switch ((from.a1, to.a1, other.from.a1, other.to.a1)) {
        (
          A1(self: var from1),
          A1(self: var to1),
          A1(self: var from2),
          A1(self: var to2),
        ) =>
          from1.area(to1).compareTo(from2.area(to2)),
        _ => throw UnsupportedError(
            'The area of the two ranges is not comparable'),
      };

  /// Test whether this A1 is equal to `other`.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is A1Range && other.from == from && other.to == to;
  }

  /// Returns a hash code for a numerical value.
  ///
  /// The hash code is compatible with equality. It returns the same value
  @override
  int get hashCode {
    return from.hashCode ^ to.hashCode;
  }

  /// Print the range in the form A1:B2, A1:B, A1, A, or ''
  @override
  String toString() => '$from${to.isAll ? "" : ":"}$to';

  /// Area of this range, for items unbounded ranges, returns double.infinity
  double get area => from.a1?.area(to.a1) ?? double.infinity;

  /// Does this [A1Range] contain this [A1]
  bool contains(A1 a1) {
    return switch ((from.column, from.row, to.column, to.row)) {
      (int(), int(), int(), int()) => a1.column >= from.column! &&
          a1.row >= from.row! &&
          a1.column <= to.column! &&
          a1.row <= to.row!,
      (null, int(), int(), int()) =>
        a1.row >= from.row! && a1.column <= to.column! && a1.row <= to.row!,
      (null, null, int(), int()) =>
        a1.column <= to.column! && a1.row <= to.row!,
      (null, null, null, null) => true,
      (int(), null, int(), int()) => a1.column >= from.column! &&
          a1.column <= to.column! &&
          a1.row <= to.row!,
      (int(), null, null, int()) =>
        a1.column >= from.column! && a1.row <= to.row!,
      (int(), null, null, null) => a1.column >= from.column!,
      (int(), int(), null, int()) =>
        a1.column >= from.column! && a1.row >= from.row! && a1.row <= to.row!,
      (int(), int(), null, null) =>
        a1.column >= from.column! && a1.row >= from.row!,
      (int(), int(), int(), null) => a1.column >= from.column! &&
          a1.row >= from.row! &&
          a1.column <= to.column!,
      (int(), null, int(), null) =>
        a1.column >= from.column! && a1.column <= to.column!,
      (null, int(), int(), null) =>
        a1.row <= from.row! && a1.column <= to.column!,
      (null, int(), null, int()) => a1.row >= from.row! && a1.row <= to.row!,
      (null, int(), null, null) => a1.row >= from.row!,
      (null, null, int(), null) => a1.column <= to.column!,
      (null, null, null, int()) => a1.row <= to.row!,
    };
  }

  /// Does this [A1Range] have this [A1] at one of its corners.
  bool hasCorner(A1 a1) {
    if (from.a1 == a1 || to.a1 == a1) {
      return true;
    }

    if (from.a1 != null &&
        to.a1 != null &&
        (A1.fromVector(from.a1!.column, to.a1!.row) == a1 ||
            A1.fromVector(to.a1!.column, from.a1!.row) == a1)) {
      return true;
    }

    return false;
  }
}

/// This extension allows an [A1Range] to be create from a [String]
extension StringA1RangeExtension on String {
  /// Return an [A1Range] from the current [String] or throw
  /// a [FormatException] see [A1Range.parse].
  A1Range get a1Range => A1Range.parse(this);
}
