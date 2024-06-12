// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'package:a1/a1.dart';
import 'package:a1/src/helpers/quadtree.dart';
import 'package:a1/src/helpers/simple_cache.dart';

/// A wrapped [HashMap] of <A1Range,T> that stores the keys
/// in a SplayTreeSet for sorting to optimise the binarysearch to
/// [valueOf] a value or retrieve [rangeOf] matching the cell
class A1RangeSearch<T> with MapMixin<A1Range, T> {
  static final int _maxInt = -1 >>> 1;
  final Map<A1Range, T> _map = {};
  final SplayTreeSet<A1Range> _keys =
      SplayTreeSet((k1, k2) => k1.compareTo(k2));

  final Quadtree _ranges = Quadtree(0, A1Range.all);

  final SimpleCache<A1, A1Range?> _cache = SimpleCache(10000);

  /// Search for a key in a sorted, non-overlapping set of of [A1Arange]s.
  /// It returns the matching value against the [A1Range] key using a
  /// binary search. If there is no match null is retuned.
  T? valueOf(A1 cell) {
    final keyMatch = rangeOf(cell);
    return keyMatch != null ? _map[keyMatch] : null;
  }

  /// Search for a key in a sorted, non-overlapping set of of [A1Arange]s.
  /// It returns the matching key against the [A1Range] key using a
  /// binary search. If there is no match null is retuned.
  A1Range? rangeOf(A1 cell) {
    if (_cache.containsKey(cell)) {
      return _cache[cell];
    }
    List<A1Range> sortedKeys = _keys.toList();

    int left = 0;
    int right = sortedKeys.length - 1;
    while (left <= right) {
      int middle = left + (right - left) ~/ 2;
      A1Range guess = sortedKeys[middle];

      if (guess.contains(cell)) {
        _cache[cell] = guess;
        return guess;
      } else if (A1.fromVector(guess.left, guess.bottom) < cell) {
        left = middle + 1;
      } else {
        right = middle - 1;
      }
    }
    _cache[cell] = null;
    return null;
  }

  /// Search the ranges to see if this range intersects any
  /// using the binary search method
  /// Returns a [List] of [A1Range]s if they intersect and and
  /// empty list otherwise.
  List<A1Range> rangesIn(A1Range range) =>
      _ranges.findContainingA1Ranges(range);

  @override
  T? operator [](Object? key) => _map[key];

  @override
  void operator []=(A1Range key, T value) {
    _map[key] = value;
    _keys.add(key);

    _ranges.remove(key);
    _ranges.insert(key);

    _cache.clear();
  }

  @override
  void clear() {
    _map.clear();
    _keys.clear();
    _cache.clear();
    _ranges.clear();
  }

  @override
  Iterable<A1Range> get keys => _map.keys;

  @override
  T? remove(Object? key) {
    _cache.clear();
    _keys.remove(key);
    if (key is A1Range) {
      _ranges.remove(key);
    }
    return _map.remove(key);
  }

  /// Move the [A1Range] one cell upwards based on the anchor and merged
  /// [A1Range]s
  A1Range cellUp(A1Range range) {
    if (range.top == 0) return range;
    var newRange = range.goUp;
    final mergedRanges = rangesIn(newRange);

    if (newRange.top < range.top) {
      newRange = _expandToMergeBoundaries(newRange, mergedRanges);
    } else {
      newRange = _contractToMergeBoundaries(newRange, mergedRanges);
      if (newRange == range) {
        newRange = range.copyWith(from: range.from.up);
        newRange = _expandToMergeBoundaries(newRange, mergedRanges);
      }
    }
    return newRange;
  }

  /// Move the [A1Range] one cell leftwards based on the anchor and merged
  /// [A1Range]s
  A1Range cellLeft(A1Range range) {
    if (range.left == 0) return range;
    var newRange = range.goLeft;
    final mergedRanges = rangesIn(newRange);

    if (newRange.left < range.left) {
      newRange = _expandToMergeBoundaries(newRange, mergedRanges);
    } else {
      newRange = _contractToMergeBoundaries(newRange, mergedRanges);
      if (newRange == range) {
        newRange = range.copyWith(from: range.from.left);
        newRange = _expandToMergeBoundaries(newRange, mergedRanges);
      }
    }
    return newRange;
  }

  /// Move the [A1Range] one cell downwards based on the anchor and merged
  /// [A1Range]s
  A1Range cellDown(A1Range range) {
    if (range.bottom == _maxInt) return range;
    var newRange = range.goDown;
    final mergedRanges = rangesIn(newRange);

    if (newRange.bottom > range.bottom) {
      newRange = _expandToMergeBoundaries(newRange, mergedRanges);
    } else {
      newRange = _contractToMergeBoundaries(newRange, mergedRanges);
      if (newRange == range) {
        newRange = range.copyWith(to: range.to.down);
        newRange = _expandToMergeBoundaries(newRange, mergedRanges);
      }
    }
    return newRange;
  }

  /// Move the [A1Range] one cell rightwards based on the anchor and merged
  /// [A1Range]s
  A1Range cellRight(A1Range range) {
    if (range.right == _maxInt) return range;
    var newRange = range.goRight;
    final mergedRanges = rangesIn(newRange);

    if (newRange.right > range.right) {
      newRange = _expandToMergeBoundaries(newRange, mergedRanges);
    } else {
      newRange = _contractToMergeBoundaries(newRange, mergedRanges);
      if (newRange == range) {
        newRange = range.copyWith(to: range.to.right);
        newRange = _expandToMergeBoundaries(newRange, mergedRanges);
      }
    }
    return newRange;
  }

  /// Move the [A1Range] a page upwards based on the anchor and merged
  /// [A1Range]s
  A1Range pageUp(A1Range range, int page) {
    if (range.top == 0) return range;
    var newRange = range.pageUp(page);
    final mergedRanges = rangesIn(newRange);

    if (newRange.top < range.top) {
      newRange = _expandToMergeBoundaries(newRange, mergedRanges);
    } else {
      newRange = _contractToMergeBoundaries(newRange, mergedRanges);
      if (newRange == range) {
        newRange = range.copyWith(from: range.from.up);
        newRange = _expandToMergeBoundaries(newRange, mergedRanges);
      }
    }
    return newRange;
  }

  /// Move the [A1Range] a page downwards based on the anchor and merged
  /// [A1Range]s
  A1Range pageDown(A1Range range, int page) {
    if (range.bottom == _maxInt) return range;
    var newRange = range.pageDown(page);
    final mergedRanges = rangesIn(newRange);

    if (newRange.bottom > range.bottom) {
      newRange = _expandToMergeBoundaries(newRange, mergedRanges);
    } else {
      newRange = _contractToMergeBoundaries(newRange, mergedRanges);
      if (newRange == range) {
        newRange = range.copyWith(to: range.to.down);
        newRange = _expandToMergeBoundaries(newRange, mergedRanges);
      }
    }
    return newRange;
  }

  A1Range _expandToMergeBoundaries(A1Range range, List<A1Range> ranges) {
    final newRange = A1Partial.rangefromList(
      [range.from, ...(ranges.map((e) => e.from))],
      [range.to, ...(ranges.map((e) => e.to))],
      anchor: range.anchor,
      tag: range.tag,
    );
    final mergeRanges = rangesIn(newRange);
    if (mergeRanges.length != ranges.length) {
      return _expandToMergeBoundaries(newRange, mergeRanges);
    }
    return newRange;
  }

  (int, int) _anchorRows(A1Range testRange) {
    final anchorRow = testRange.anchor?.row ?? 0;

    final ranges = rangesIn(testRange);
    final anchorTouch = ranges.where((e) =>
        (e.from.row ?? 0) <= anchorRow && (e.to.row ?? _maxInt) >= anchorRow);

    if (anchorTouch.isEmpty) {
      return (anchorRow, anchorRow);
    }

    var rowMin = anchorTouch.first.from.row ?? 0;
    var rowMax = anchorTouch.first.to.row ?? _maxInt;

    bool rangesUpdated = true;
    while (rangesUpdated) {
      rangesUpdated = false;
      for (final range in ranges) {
        if (range.top >= rowMin &&
            range.top <= rowMax &&
            range.bottom > rowMax) {
          rowMax = range.bottom;
          rangesUpdated = true;
        }
        if (range.bottom >= rowMin &&
            range.bottom <= rowMax &&
            range.top < rowMin) {
          rowMin = range.top;
          rangesUpdated = true;
        }
      }
    }
    return (rowMin, rowMax);
  }

  (int, int) _anchorColumns(A1Range testRange) {
    final anchorColumn = testRange.anchor?.column ?? 0;

    final ranges = rangesIn(testRange);
    final anchorTouch = ranges.where((e) =>
        (e.from.column ?? 0) <= anchorColumn &&
        (e.to.column ?? _maxInt) >= anchorColumn);

    if (anchorTouch.isEmpty) {
      return (anchorColumn, anchorColumn);
    }

    var colMin = anchorTouch.first.from.column ?? 0;
    var colMax = anchorTouch.first.to.column ?? _maxInt;

    bool rangesUpdated = true;
    while (rangesUpdated) {
      rangesUpdated = false;
      for (final range in ranges) {
        if (range.left >= colMin &&
            range.left <= colMax &&
            range.right > colMax) {
          colMax = range.right;
          rangesUpdated = true;
        }
        if (range.right >= colMin &&
            range.right <= colMax &&
            range.left < colMin) {
          colMin = range.left;
          rangesUpdated = true;
        }
      }
    }
    return (colMin, colMax);
  }

  A1Range _contractToMergeBoundaries(A1Range range, List<A1Range> ranges) {
    final (rowFrom, rowTo) = _anchorRows(range);
    final (columnFrom, columnTo) = _anchorColumns(range);

    var newRange = range;
    for (final mergeRange in ranges) {
      if (mergeRange.top < range.top) {
        if (mergeRange.bottom < rowFrom) {
          newRange = range.copyWith(
              from: A1Partial.fromVector(
                  range.from.column, mergeRange.to.down.row));
        } else {
          newRange = range.copyWith(
              from:
                  A1Partial.fromVector(range.from.column, mergeRange.from.row));
        }
      } else if (mergeRange.bottom > range.bottom) {
        if (mergeRange.top > rowTo) {
          newRange = range.copyWith(
              to: A1Partial.fromVector(
                  range.to.column, mergeRange.from.up.row));
        } else {
          newRange = range.copyWith(
              to: A1Partial.fromVector(range.to.column, mergeRange.to.row));
        }
      } else if (mergeRange.left < range.left) {
        if (mergeRange.right < columnFrom) {
          newRange = range.copyWith(
              from: A1Partial.fromVector(
                  mergeRange.to.right.column, range.from.row));
        } else {
          newRange = range.copyWith(
              from:
                  A1Partial.fromVector(mergeRange.from.column, range.from.row));
        }
      } else if (mergeRange.right > range.right) {
        if (mergeRange.left > columnTo) {
          newRange = range.copyWith(
              to: A1Partial.fromVector(
                  mergeRange.from.left.column, range.to.row));
        } else {
          newRange = range.copyWith(
              to: A1Partial.fromVector(mergeRange.to.column, range.to.row));
        }
      }
    }
    final mergeRanges = rangesIn(newRange);
    if (mergeRanges.length != ranges.length) {
      return _contractToMergeBoundaries(newRange, mergeRanges);
    }
    return newRange;
  }
}

extension A1RSearch on List<String> {
  A1RangeSearch get a1rSearch {
    final me = A1RangeSearch<bool>();
    for (final rangeString in this) {
      me[rangeString.a1Range] = true;
    }
    return me;
  }
}
