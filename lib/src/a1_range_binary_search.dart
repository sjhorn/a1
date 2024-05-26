// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'package:a1/a1.dart';

/// A wrapped [HashMap] of <A1Range,T> that stores the keys
/// in a SplayTreeSet for sorting to optimise the binarysearch to
/// [match] a value or retrieve [keyOf] matching the cell
class A1RangeBinarySearch<T> with MapMixin<A1Range, T> {
  final Map<A1Range, T> _map = {};
  final SplayTreeSet<A1Range> _keys =
      SplayTreeSet((k1, k2) => k1.to.compareTo(k2.to));

  /// Search for a key in a sorted, non-overlapping set of of [A1Arange]s.
  /// It returns the matching value against the [A1Range] key using a
  /// binary search. If there is no match null is retuned.
  T? match(A1 cell) {
    final keyMatch = keyOf(cell);
    return keyMatch != null ? _map[keyMatch] : null;
  }

  /// Search for a key in a sorted, non-overlapping set of of [A1Arange]s.
  /// It returns the matching key against the [A1Range] key using a
  /// binary search. If there is no match null is retuned.
  A1Range? keyOf(A1 cell) {
    List<A1Range> sortedKeys = _keys.toList();
    int left = 0;
    int right = sortedKeys.length - 1;
    while (left <= right) {
      int middle = left + (right - left) ~/ 2;
      A1Range guess = sortedKeys[middle];
      if (guess.contains(cell)) {
        return guess;
      } else if (guess.to < cell) {
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
  }

  @override
  void clear() {
    _map.clear();
    _keys.clear();
  }

  @override
  Iterable<A1Range> get keys => _map.keys;

  @override
  T? remove(Object? key) {
    _keys.remove(key);
    return _map.remove(key);
  }
}
