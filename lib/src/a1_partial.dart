// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:a1/a1.dart';

class A1Partial implements Comparable {
  /// Empty/all [A1Partial]
  static A1Partial all = A1Partial(null, null);

  /// letters of the A1 or null for all columns
  final String? letters;

  /// digits of the A1 or null for all rows
  final int? digits;

  /// Create a A1Partial from letters or null, and digits or null
  ///
  /// Examples:
  /// ```dart
  /// A1Partial a1p = A1Partial('A', 1); //A1
  /// a1p = A1Partial('b', null); // B <all rows>
  /// a1p = A1Partial(null, '1'); // 1 <all columns>
  /// a1p = A1Partial(null, null);  // <all columns & rows>
  /// ```
  A1Partial(String? letters, this.digits) : letters = letters?.toUpperCase();

  /// Create a A1Partial from an A1
  ///
  /// Examples:
  /// ```dart
  /// A1Partial a1p = A1Partial.fromA1('a1'.a1); //A1
  /// ```
  factory A1Partial.fromA1(A1 a1) => A1Partial(a1.letters, a1.digits);

  /// Create a A1Partial from the partial vector
  ///
  /// Examples:
  /// ```dart
  /// A1Partial a1p = A1Partial.fromVector(0, 0); //A1
  /// a1p = A1Partial.fromVector(1, null); // B <all rows>
  /// a1p = A1Partial.fromVector(null, 1); // 1 <all columns>
  /// a1p = A1Partial.fromVector(null, null);  // <all columns & rows>
  /// ```
  factory A1Partial.fromVector(int? column, int? row) =>
      A1Partial(column?.a1Letters, row != null ? row + 1 : null);

  /// If this partial has letters and digitis it get be returned as A1
  /// otherwise a null is returned
  ///
  /// Examples:
  /// ```dart
  /// A1? a1 = A1Partial('A', 1); // A1
  /// a1 = A1Partial('A', null); // null
  /// a1 = A1Partial(null, 1); // null
  /// ```
  A1? get a1 =>
      letters != null && digits != null ? A1.fromVector(column!, row!) : null;

  /// The real work in a A1Partial is deciding if it is bigger than another
  /// this is important for creation of a range to order the left and right
  /// side of the : or ...
  ///
  @override
  int compareTo(other) {
    final thisA1 = A1.fromVector(column ?? 0, row ?? 0);
    final otherA1 = A1.fromVector(other.column ?? 0, other.row ?? 0);
    return thisA1.compareTo(otherA1);
  }

  /// Conveniance function for determining range from a list of partials
  static A1Range rangefromList(
      List<A1Partial?> listFrom, List<A1Partial?> listTo,
      {Object? tag, A1? anchor}) {
    // clean the nulls and create from list
    final fromItems = listFrom.where((element) => element != null);
    final fromColumns =
        fromItems.map((A1Partial? e) => e?.column ?? 0).toList();
    fromColumns.sort();
    final fromColumn = fromColumns.first;
    final fromRows = fromItems.map((A1Partial? e) => e?.row ?? 0).toList();
    fromRows.sort();
    final fromRow = fromRows.first;

    // clean the nulls and create to list
    final toItems = listTo.where((element) => element != null);
    final toColumns =
        toItems.map((A1Partial? e) => e?.column ?? A1.maxColumns).toList();
    toColumns.sort();

    final toColumn = toColumns.last;
    final toRows = toItems.map((A1Partial? e) => e?.row ?? A1.maxRows).toList();
    toRows.sort();
    final toRow = toRows.last;

    return A1Range.fromPartials(
      A1Partial.fromVector(fromColumn, fromRow),
      A1Partial.fromVector(toColumn == A1.maxColumns ? null : toColumn,
          toRow == A1.maxRows ? null : toRow),
      tag: tag,
      anchor: anchor,
    );
  }

  /// Conveniance function for determining minimum of a list of partials
  static A1Partial min(Iterable<A1Partial?> list) {
    final items = list.where((element) => element != null).toList();
    items.sort();
    return items.first!;
  }

  /// Conveniance function for determining maximum of a list of partials
  static A1Partial max(Iterable<A1Partial?> list) {
    final items = list.where((element) => element != null).toList();
    items.sort();
    return items.last!;
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

  /// If other is an A1Partial then compare letters/digits
  /// if it is an A1, try to see if this is castable as A1 and compare
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is A1) return a1 == other;

    return other is A1Partial &&
        other.letters == letters &&
        other.digits == digits;
  }

  @override
  int get hashCode => '$letters$digits'.hashCode;

  /// Show the A1Partial with null left as a blank string
  @override
  String toString() => '${letters ?? ""}${digits ?? ""}';

  /// if both letters and digits are null this selects all
  bool get isAll => letters == null && digits == null;

  /// if this partial represents a whole column ie. no row specified
  bool get isWholeColumn => row == null && column != null;

  /// if this partial represents a whole row ie. no column specified
  bool get isWholeRow => column == null && row != null;

  /// if this partial represents either a whole row or column
  bool get isWholeRowOrColumn => isWholeColumn || isWholeRow;

  /// Utility for copying
  A1Partial vectorCopyWith({
    int? column,
    int? row,
  }) {
    return A1Partial.fromVector(
      column ?? this.column,
      row ?? this.row,
    );
  }

  /// utility for moving right
  A1Partial get right => goRight(1);

  /// utility for moving left
  A1Partial get left => goLeft(1);

  /// utility for moving down
  A1Partial get down => goDown(1);

  /// utility for moving up
  A1Partial get up => goUp(1);

  /// adjust [A1PArtial] down by count
  A1Partial goDown(int count) {
    if (row == null) return this;
    return vectorCopyWith(
        row: (A1.maxRows - count) < row! ? A1.maxRows : row! + count);
  }

  /// adjust [A1PArtial] up by count
  A1Partial goUp(int count) {
    if (row == null) return this;
    return vectorCopyWith(row: (row! - count) < 0 ? 0 : row! - count);
  }

  /// adjust [A1PArtial] right by count
  A1Partial goRight(int count) {
    if (column == null) return this;
    return vectorCopyWith(
        column: (A1.maxColumns - count) < column!
            ? A1.maxColumns
            : column! + count);
  }

  /// adjust [A1PArtial] left by count
  A1Partial goLeft(int count) {
    if (column == null) return this;
    return vectorCopyWith(column: (column! - count) < 0 ? 0 : column! - count);
  }
}
