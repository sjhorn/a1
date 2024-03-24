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

  /// if a full formed A1 this is the from A1
  final A1? from;

  /// if a full formed A1 this is the to A1
  final A1? to;

  /// Either the from letters (eg. BB) or null
  final String? fromLetters;

  /// Either the from digits (eg. 123) or null
  final int? fromDigits;

  /// Either the to letters (eg. AA) or null
  final String? toLetters;

  /// Either the to digits (eg. 123) or null
  final int? toDigits;

  /// Private contructor
  A1Range._(
    this.from,
    this.to, {
    this.fromLetters,
    this.fromDigits,
    this.toLetters,
    this.toDigits,
  });

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
    final result = _a1n.buildFrom(_a1n.a1Range()).end().parse(input);
    if (result is Failure) {
      return null;
    }
    final value = result.value;
    A1? from, to;

    if (value[#column1] != null && value[#row1] != null) {
      from = A1.parse('${value[#column1]}${value[#row1]}');
    }
    if (value[#column2] != null && value[#row2] != null) {
      to = A1.parse('${value[#column2]}${value[#row2]}');
    }
    return A1Range._(
      from,
      to,
      fromLetters: value[#column1],
      fromDigits: value.containsKey(#row1)
          ? int.parse((value[#row1]! as String))
          : null,
      toLetters: value[#column2],
      toDigits: value.containsKey(#row2)
          ? int.parse((value[#row2]! as String))
          : null,
    );
  }

  @override
  int compareTo(A1Range other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }

  /// Test whether this A1 is equal to `other`.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is A1Range &&
        other.from == from &&
        other.to == to &&
        other.fromLetters == fromLetters &&
        other.fromDigits == fromDigits &&
        other.toLetters == toLetters &&
        other.toDigits == toDigits;
  }

  /// Returns a hash code for a numerical value.
  ///
  /// The hash code is compatible with equality. It returns the same value
  @override
  int get hashCode {
    return from.hashCode ^
        to.hashCode ^
        fromLetters.hashCode ^
        fromDigits.hashCode ^
        toLetters.hashCode ^
        toDigits.hashCode;
  }
}

/// This extension allows an [A1Range] to be create from a [String]
extension StringA1RangeExtension on String {
  /// Return an [A1Range] from the current [String] or throw
  /// a [FormatException] see [A1Range.parse].
  A1Range get a1Range => A1Range.parse(this);
}
