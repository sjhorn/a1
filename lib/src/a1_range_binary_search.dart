// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'package:a1/a1.dart';
import 'package:a1/src/helpers/simple_cache.dart';

/// A wrapped [HashMap] of <A1Range,T> that stores the keys
/// in a SplayTreeSet for sorting to optimise the binarysearch to
/// [valueOf] a value or retrieve [rangeOf] matching the cell
class A1RangeBinarySearch<T> with MapMixin<A1Range, T> {
  final Map<A1Range, T> _map = {};
  final SplayTreeSet<A1Range> _keys =
      SplayTreeSet((k1, k2) => k1.compareTo(k2));

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
  /// Return [A1Range] if intersect and null otherwise.
  A1Range? rangeIn(A1Range range) {
    List<A1Range> sortedKeys = _keys.toList();
    int left = 0;
    int right = sortedKeys.length - 1;
    while (left <= right) {
      int middle = left + (right - left) ~/ 2;
      A1Range guess = sortedKeys[middle];
      if (guess.intersect(range) != null) {
        return guess;
      } else if (A1.fromVector(guess.left, guess.bottom) <
          A1.fromVector(range.left, range.bottom)) {
        left = middle + 1;
      } else {
        right = middle - 1;
      }
    }
    return null;
  }

  @override
  T? operator [](Object? key) => _map[key];

  @override
  void operator []=(A1Range key, T value) {
    _map[key] = value;
    _keys.add(key);
    _cache.clear();
  }

  @override
  void clear() {
    _map.clear();
    _keys.clear();
    _cache.clear();
  }

  @override
  Iterable<A1Range> get keys => _map.keys;

  @override
  T? remove(Object? key) {
    _cache.clear();
    _keys.remove(key);
    return _map.remove(key);
  }
}

extension A1RSearch on List<String> {
  A1RangeBinarySearch get a1rSearch {
    final me = A1RangeBinarySearch<bool>();
    for (final rangeString in this) {
      me[rangeString.a1Range] = true;
    }
    return me;
  }
}
