// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A1:B2 refers to the first two cells in the top two rows of Sheet1.
// A:A refers to all the cells in the first column of Sheet1.
// 1:2 refers to all the cells in the first two rows of Sheet1.
// A5:A refers to all the cells of the first column of Sheet 1, from row 5 onward.

import 'dart:math';

import 'package:a1/src/helpers/a1_area.dart';
import 'package:petitparser/petitparser.dart';

import 'package:a1/a1.dart';
import 'package:a1/src/grammer/a1_notation.dart';

class A1Range implements Comparable<A1Range> {
  static const _maxInt = -1 >>> 1;

  /// All range
  static final A1Range all =
      A1Range._(A1Partial.all, A1Partial.all, anchor: 'A1'.a1);
  static final A1Notation _a1n = A1Notation();
  static final _parser = _a1n.buildFrom(_a1n.range()).end();

  /// range from A1Partial
  late final A1Partial from;

  /// range to A1Partial
  late final A1Partial to;

  /// optional anchor a1
  final A1? anchor;

  /// optional tag for this range, used when associating formatting
  final Object? tag;

  /// Private contructor
  A1Range._(A1Partial from, A1Partial to, {this.anchor, this.tag}) {
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
  factory A1Range.fromPartials(A1Partial from, A1Partial to, {Object? tag}) {
    if ((from.isAll || to.isAll) || from <= to) {
      return A1Range._(from, to, anchor: from.a1, tag: tag);
    } else {
      return A1Range._(to, from, anchor: from.a1, tag: tag);
    }
  }

  /// Creates a range from two supplied A1s for from and to
  /// ensures 'from' is less than or equal to 'to'
  /// the fromA1 will be used as the anchor in the range
  factory A1Range.fromA1s(A1 fromA1, A1 toA1, {Object? tag}) {
    final from = A1Partial.fromA1(fromA1);
    final to = A1Partial.fromA1(toA1);
    if (from <= to) {
      return A1Range._(from, to, anchor: fromA1, tag: tag);
    } else {
      return A1Range._(to, from, anchor: fromA1, tag: tag);
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

  /// Compare the area of two [A1Range]s this and other to determine
  /// which is bigger
  /// Returns a negative number if this is less than other, zero if they are
  /// equal, and a positive number if this is greater than other.
  @override
  int compareTo(A1Range other) =>
      A1Area.fromA1Range(this).compareTo(A1Area.fromA1Range(other));

  /// Test whether this A1 is equal to `other`.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // anchor and tag are not considered for equality
    return other is A1Range && other.from == from && other.to == to;
  }

  /// Returns a hash code for a numerical value.
  ///
  /// The hash code is compatible with equality. It returns the same value
  @override
  int get hashCode {
    return '$from:$to'.hashCode;
  }

  /// copy with different attributes
  A1Range copyWith({
    A1Partial? from,
    A1Partial? to,
    A1? anchor,
    Object? tag,
  }) {
    return A1Range._(
      from ?? this.from,
      to ?? this.to,
      anchor: anchor ?? this.anchor,
      tag: tag ?? this.tag,
    );
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
    if (this == all && a1 == 'a1'.a1) {
      return true;
    }

    if (from.a1 == a1 || to.a1 == a1) {
      return true;
    }

    if (from.a1 != null &&
        to.a1 != null &&
        (A1.fromVector(from.a1!.column, to.a1!.row) == a1 ||
            A1.fromVector(to.a1!.column, from.a1!.row) == a1)) {
      return true;
    }

    // From column eg A:
    if (from.a1 == null && a1.row == 0 && a1.column == from.column) {
      return true;
    }

    // From row 1:
    if (from.a1 == null && a1.column == 0 && a1.row == from.row) {
      return true;
    }

    // To column :A
    if (to.a1 == null && a1.row == 0 && a1.column == to.column) {
      return true;
    }

    // To row :1
    if (to.a1 == null && a1.column == 0 && a1.row == to.row) {
      return true;
    }

    return false;
  }

  /// is the row in this range
  bool hasRow(int row) => switch ((from.a1, to.a1)) {
        // A1:A10
        (A1(row: var fromRow), A1(row: var toRow))
            when row >= fromRow && row <= toRow =>
          true,

        // :A1
        (_, A1(row: var toRow)) when from.isAll && row <= toRow => true,

        // A:B2
        (null, A1(row: var toRow))
            when from.row != null && row >= from.row! && row <= toRow =>
          true,

        // A1:
        (A1(row: var fromRow), _) when row >= fromRow && to.isAll => true,

        // A1:1
        (A1(row: var fromRow), null)
            when row >= fromRow && to.row != null && row <= to.row! =>
          true,

        // A:B
        (null, null) when from.row == null && to.row == null => true,

        // 1:1
        (null, null)
            when from.row != null &&
                row >= from.row! &&
                to.row != null &&
                row <= to.row! =>
          true,
        (_, _) when from.isAll && to.isAll => true,
        _ => false,
      };

  /// is the column in this range
  bool hasColumn(int column) => switch ((from.a1, to.a1)) {
        // A1:A10
        (A1(column: var fromColumn), A1(column: var toColumn))
            when column >= fromColumn && column <= toColumn =>
          true,

        // :B2
        (_, A1(column: var toColumn)) when from.isAll && column <= toColumn =>
          true,

        // 2:B2
        (null, A1(column: var toColumn))
            when from.column != null &&
                column >= from.column! &&
                column <= toColumn =>
          true,

        // A1:
        (A1(column: var fromColumn), _) when column >= fromColumn && to.isAll =>
          true,

        // A1:A
        (A1(column: var fromColumn), null)
            when column >= fromColumn &&
                to.column != null &&
                column <= to.column! =>
          true,

        // 1:2
        (null, null) when from.column == null && to.column == null => true,

        // A:A
        (null, null)
            when from.column != null &&
                column >= from.column! &&
                to.column != null &&
                column <= to.column! =>
          true,

        // <empty>
        (_, _) when from.isAll && to.isAll => true,
        _ => false,
      };

  /// Select the left border strip for this range
  A1Range get leftBorder =>
      A1Range.fromPartials(from, A1Partial(from.letters, to.digits));

  /// Select the right border strip for this range
  A1Range get rightBorder =>
      A1Range.fromPartials(A1Partial(to.letters, from.digits), to);

  /// Select the top border strip for this range
  A1Range get topBorder =>
      A1Range.fromPartials(from, A1Partial(to.letters, from.digits));

  /// Select the bottom border strip for this range
  A1Range get bottomBorder =>
      A1Range.fromPartials(A1Partial(from.letters, to.digits), to);

  /// Return range excluding the last row (assumes bottom borders) or null
  /// if there are no internal horizontal borders
  A1Range? get horizontalBorders {
    if (this == all || to.isWholeColumn) {
      return this;
    }
    final digits = to.digits! - 1;
    if (to.digits! - 1 < 1) {
      return null;
    }
    if (from.digits != null && digits < from.digits!) {
      return null;
    }
    return A1Range.fromPartials(from, A1Partial(to.letters, digits));
  }

  /// Return range excluding the last column (assumes right borders) or null
  /// if there are no internal vertical borders
  A1Range? get verticalBorders {
    if (this == all || to.isWholeRow) {
      return this;
    }
    final column = to.column! - 1;
    if (column < 0) {
      return null;
    }
    if (from.column != null && column < from.column!) {
      return null;
    }

    return A1Range.fromPartials(from, A1Partial(column.a1Letters, to.digits));
  }

  /// Special case of overlayRanges where we are overlaying an [A1Range] on
  /// a list of [A1Range]s
  static List<A1Range> overlayRange(List<A1Range> ranges, A1Range range) {
    if (ranges.isEmpty) return [range];
    return ranges.first.overlayRanges([...ranges.skip(1), range]);
  }

  /// Overlay [A1Range] on top of each other, merging intersects and
  /// substracting to create non-overlapping [A1Range]s
  /// The tags for ranges are maintained or staged in a list with the
  /// early item in the list considered overlayed on the latter
  ///
  List<A1Range> overlayRanges(List<A1Range> ranges) {
    List<A1Range> result = [this];

    // Loop over each overlayed A1Range subtracting
    // to create unchanged A1Range
    // and merging intersecting A1Ranges
    for (final overlayedRange in ranges) {
      List<A1Range> newResult = [];
      List<A1Range> intersects = [];

      // subtract overlayed A1Range
      for (final range in result) {
        newResult.addAll(range.subtract(overlayedRange));

        if (range.overlaps(overlayedRange)) {
          intersects.add(range.intersect(overlayedRange)!);
        }
      }

      if (intersects.isNotEmpty) {
        newResult.addAll(intersects);

        // Iterate through intersects subtracting from overlayed rect until
        // only non-intersecting rectangles of the overlayed rect are left.
        List<A1Range> nonIntersectedResult = [overlayedRange];
        for (final intersect in intersects) {
          List<A1Range> newNonIntersectedResult = [];
          for (final nonIntersected in nonIntersectedResult) {
            newNonIntersectedResult.addAll(nonIntersected.subtract(intersect));
          }
          nonIntersectedResult = newNonIntersectedResult;
        }
        newResult.addAll(nonIntersectedResult);
      } else {
        newResult.add(overlayedRange);
      }

      result = newResult;
    }
    return result;
  }

  /// Return the [A1Range]s that is left after subtracting
  /// the other [A1Range]. Maintains the tag
  ///
  List<A1Range> subtract(A1Range other) {
    if (!overlaps(other)) {
      return [this];
    }

    List<A1Range> result = [];
    final (int x1, int y1, int x2, int y2) = (
      from.column ?? 0,
      from.row ?? 0,
      to.column ?? _maxInt,
      to.row ?? _maxInt,
    );
    final (int otherX1, int otherY1, int otherX2, int otherY2) = (
      other.from.column ?? 0,
      other.from.row ?? 0,
      other.to.column ?? _maxInt,
      other.to.row ?? _maxInt,
    );
    if (x1 < otherX1) {
      result.add(A1Range.fromPartials(
        A1Partial.fromVector(x1.a1P, y1.a1P),
        A1Partial.fromVector(otherX1.a1PDecrement, y2.a1P),
        tag: tag,
      ));
    }
    if (x2 > otherX2) {
      result.add(A1Range.fromPartials(
        A1Partial.fromVector(otherX2.a1PIncrement, y1.a1P),
        A1Partial.fromVector(x2.a1P, y2.a1P),
        tag: tag,
      ));
    }
    if (y1 < otherY1) {
      result.add(A1Range.fromPartials(
        A1Partial.fromVector(max(x1, otherX1).a1P, y1.a1P),
        A1Partial.fromVector(min(x2, otherX2).a1P, otherY1.a1PDecrement),
        tag: tag,
      ));
    }
    if (y2 > otherY2) {
      result.add(A1Range.fromPartials(
        A1Partial.fromVector(max(x1, otherX1).a1P, otherY2.a1PIncrement),
        A1Partial.fromVector(min(x2, otherX2).a1P, y2.a1P),
        tag: tag,
      ));
    }
    return result;
  }

  void _flattenAndAdd(List list, Object? object) {
    if (object != null) {
      if (object is List) {
        list.addAll(object);
      } else {
        list.add(object);
      }
    }
  }

  int? _maxPartial(int one, int two) => one >= two ? one.a1P : two.a1P;
  int? _minPartial(int one, int two) => one <= two ? one.a1P : two.a1P;

  /// Return the [A1Range] or null where this and other intersect
  /// updates the tag as [this.tag, other.tag]
  A1Range? intersect(A1Range other) {
    if (!overlaps(other)) {
      return null;
    }

    List? tagStack = [];
    _flattenAndAdd(tagStack, tag);
    _flattenAndAdd(tagStack, other.tag);
    final intersectTag = tagStack.isEmpty
        ? null
        : tagStack.length == 1
            ? tagStack.single
            : tagStack;

    if (this == all && other == all) {
      return all.copyWith(tag: intersectTag);
    } else if (this == all) {
      return other.copyWith(tag: intersectTag);
    } else if (other == all) {
      return copyWith(tag: intersectTag);
    }
    final (int left, int top, int right, int bottom) = (
      from.column ?? -1,
      from.row ?? -1,
      to.column ?? _maxInt,
      to.row ?? _maxInt,
    );
    final (int otherLeft, int otherTop, int otherRight, int otherBottom) = (
      other.from.column ?? -1,
      other.from.row ?? -1,
      other.to.column ?? _maxInt,
      other.to.row ?? _maxInt,
    );

    return A1Range.fromPartials(
      A1Partial.fromVector(
          _maxPartial(left, otherLeft), _maxPartial(top, otherTop)),
      A1Partial.fromVector(
          _minPartial(right, otherRight), _minPartial(bottom, otherBottom)),
      tag: intersectTag,
    );
  }

  /// Check if this [A1Range] overlaps the other [A1Range]
  ///
  bool overlaps(A1Range other) {
    if (this == all || other == all) {
      return true;
    }
    final (int left, int top, int right, int bottom) = (
      from.column ?? 0,
      from.row ?? 0,
      to.column ?? _maxInt,
      to.row ?? _maxInt,
    );
    final (int otherLeft, int otherTop, int otherRight, int otherBottom) = (
      other.from.column ?? 0,
      other.from.row ?? 0,
      other.to.column ?? _maxInt,
      other.to.row ?? _maxInt,
    );
    if (right < otherLeft || otherRight < left) {
      return false;
    }
    if (bottom < otherTop || otherBottom < top) {
      return false;
    }
    return true;
  }
}

/// This extension allows an [A1Range] to be create from a [String]
extension StringA1RangeExtension on String {
  /// Return an [A1Range] from the current [String] or throw
  /// a [FormatException] see [A1Range.parse].
  A1Range get a1Range => A1Range.parse(this);
}

extension on int {
  static const int _maxInt = -1 >>> 1;
  int? get a1P => this == _maxInt || isNegative ? null : this;
  int? get a1PIncrement => this == _maxInt ? null : this + 1;
  int? get a1PDecrement => this == _maxInt ? null : this - 1;
}
