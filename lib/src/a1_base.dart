// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

class A1 implements Comparable<A1> {
  late final String letter;
  late final int digit;
  A1 get self => this;

  A1._(this.letter, this.digit);

  static A1 parse(String input) {
    final result = tryParse(input);
    if (result == null) {
      throw FormatException('Invalid A1 notation $input', input, 0);
    }
    return result;
  }

  static A1? tryParse(String input) {
    String source = input.trim().toUpperCase();
    List<int> units = source.codeUnits;
    if (!units.first.isLetter) {
      return null;
    }
    int digitIndex = 0;
    bool inLetters = true;
    for (var (index, unit) in units.sublist(1).indexed) {
      if ((inLetters && unit.isLetter) || (!inLetters && unit.isDigit)) {
        continue;
      } else if (inLetters && unit.isDigit) {
        digitIndex = index + 1;
        inLetters = false;
        continue;
      }
      return null;
    }
    return A1._(source.substring(0, digitIndex),
        int.parse(source.substring(digitIndex)));
  }

  (int column, int row) get vector => (column, row);

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
    letter = String.fromCharCodes(codeUnits);
    digit = row + 1;
  }

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

  @override
  String toString() => '$letter$digit';

  int get column {
    int column = 0;
    for (final unit in letter.codeUnits) {
      column = column * 26 + unit - 'A'.codeUnitAt(0) + 1;
    }
    return column - 1;
  }

  int get row => digit - 1;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is A1 && other.letter == letter && other.digit == digit;
  }

  @override
  int get hashCode => letter.hashCode ^ digit.hashCode;

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

  A1 operator +(A1 other) =>
      A1.fromVector(column + other.column, row + other.row);

  A1 get right => A1.fromVector(column + 1, row);
  A1 get left => A1.fromVector(max(0, column - 1), row);
  A1 get down => A1.fromVector(column, row + 1);
  A1 get up => A1.fromVector(column, max(0, row - 1));
}

extension on int {
  bool get isLetter => this >= 'A'.codeUnitAt(0) && this <= 'Z'.codeUnitAt(0);
  bool get isDigit => this >= '0'.codeUnitAt(0) && this <= '9'.codeUnitAt(0);
}

extension S1 on String {
  A1 get a1 => A1.parse(this);
}

extension L2 on List<String> {
  Iterable<A1> get a1 => map((e) => e.a1);
}
