// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

class SimpleCache<K, V> with MapMixin {
  final Map<K, V> _store = {};
  final List<K> _order = [];

  /// how much this cache stores before clearing 30 entires fifo
  final int capacity;

  /// Creates a [SimpleCache] based on the K,V supplied
  /// [capacity] represents the size of the cahce in keys cached
  /// and will eject 30 items when this is exceeded in a first in, first out
  /// manner ie. FIFO
  SimpleCache(this.capacity);

  /// retrieve an entries V value
  @override
  operator [](Object? key) => _store[key];

  /// add an entry based on K (key) amd V (value)
  @override
  void operator []=(key, value) {
    if (_store.containsKey(key)) {
      _order.remove(key);
    } else if (_store.length >= capacity) {
      final clearCount = 0.1 * capacity;
      for (var i = 0; i < clearCount; i++) {
        _store.remove(_order.removeAt(0));
      }
    }
    _store[key] = value;
    _order.add(key);
  }

  /// clear all entries
  @override
  void clear() {
    _store.clear();
    _order.clear();
  }

  /// rertrieve an interable of K keys in a FIFO manner,
  /// ie. the oldest item is first
  /// and then ordered to the newest item
  @override
  Iterable get keys => _order;

  /// remove an entry
  @override
  remove(Object? key) {
    _store.remove(key);
    _order.remove(key);
  }
}
