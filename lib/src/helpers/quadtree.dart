// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Inspired and some code copied from https://github.com/rlch/quadtree-dart/
// Copyright (c) 2021 Richard Mathieson
// License detailed https://github.com/rlch/quadtree-dart/blob/master/LICENSE

import 'package:a1/a1.dart';

/// Spatial partitioning
enum Quadrant { ne, nw, sw, se }

/// A class representing a Quadtree data structure for spatial partitioning.
class Quadtree {
  Quadtree(
    this.bounds, {
    this.depth = 0,
  });
  static final int maxRanges = 4;
  static final int maxDepth = 4;

  /// The range of this partiion
  final A1Range bounds;

  /// Depth of this partition
  final int depth;

  /// Ranges contained within the node
  final List<A1Range> ranges = [];

  /// Subnodes of the [Quadtree].
  final Map<Quadrant, Quadtree> nodes = {};

  /// Split the node into 4 subnodes (ne, nw, sw, se)
  void split() {
    final nextDepth = depth + 1;
    final subWidth = bounds.width ~/ 2;
    final subHeight = bounds.height ~/ 2;
    final left = bounds.left;
    final top = bounds.top;

    final ne = Quadtree(
      A1Range.fromCoordinates(
        left + subWidth,
        top,
        left + subWidth * 2,
        top + subHeight,
      ),
      depth: nextDepth,
    );

    final nw = Quadtree(
      A1Range.fromCoordinates(
        left,
        top,
        left + subWidth,
        top + subHeight,
      ),
      depth: nextDepth,
    );

    final sw = Quadtree(
      A1Range.fromCoordinates(
        left,
        top + subHeight,
        left + subWidth,
        top + subHeight * 2,
      ),
      depth: nextDepth,
    );

    final se = Quadtree(
      A1Range.fromCoordinates(
        left + subWidth,
        top + subHeight,
        left + subWidth * 2,
        top + subHeight * 2,
      ),
      depth: nextDepth,
    );

    nodes
      ..[Quadrant.ne] = ne
      ..[Quadrant.nw] = nw
      ..[Quadrant.sw] = sw
      ..[Quadrant.se] = se;
  }

  /// Find the Quadrants the [A1Range] belongs to by
  /// returning the partition that overlaps (ne, nw, sw, se)
  List<Quadrant> getQuadrants(A1Range range) {
    final List<Quadrant> quadrants = [];
    final xMidpoint = bounds.left + bounds.width ~/ 2;
    final yMidpoint = bounds.top + bounds.height ~/ 2;

    final startIsNorth = range.left < yMidpoint;
    final startIsWest = range.top < xMidpoint;
    final endIsEast = range.left + range.width >= xMidpoint;
    final endIsSouth = range.top + range.height >= yMidpoint;

    if (startIsNorth && endIsEast) quadrants.add(Quadrant.ne);
    if (startIsWest && startIsNorth) quadrants.add(Quadrant.nw);
    if (startIsWest && endIsSouth) quadrants.add(Quadrant.sw);
    if (endIsEast && endIsSouth) quadrants.add(Quadrant.se);

    return quadrants;
  }

  bool remove(A1Range range) {
    bool result = false;

    /// Recursively retrieve ranges from subnodes in the relevant quadrants.
    if (nodes.isNotEmpty) {
      final quadrants = getQuadrants(range);
      for (final q in quadrants) {
        for (final child in nodes[q]!.retrieve(range)) {
          if (child == range) {
            if (nodes[q]!.remove(range)) {
              result = true;
            }
          }
        }
      }
    }
    ranges.removeWhere((element) {
      final match = element == range;
      if (match) {
        result = true;
      }
      return match;
    });
    return result;
  }

  /// Insert the [A1Range] into the node. If the node exceeds the capacity,
  /// it will split and add all ranges to their corresponding subnodes.
  void insert(A1Range range) {
    /// If we have subnodes, call [insert] on the matching subnodes.
    if (nodes.isNotEmpty) {
      final quadrants = getQuadrants(range);

      for (int i = 0; i < quadrants.length; i++) {
        nodes[quadrants[i]]!.insert(range);
      }
      return;
    }

    ranges.add(range);

    /// maxRanges reached; only split if maxDepth hasn't been reached.
    if (ranges.length > maxRanges && depth < maxDepth) {
      if (nodes.isEmpty) split();

      /// Add ranges to their corresponding subnodes
      for (final rng in ranges) {
        getQuadrants(rng).forEach((q) {
          nodes[q]!.insert(rng);
        });
      }

      /// Node should be cleaned up as the ranges are now contained within
      /// subnodes.
      ranges.clear();
    }
  }

  /// Return all ranges that could overlap
  List<A1Range> retrieve(A1Range range) {
    final quadrants = getQuadrants(range);
    final List<A1Range> foundObjects = [...ranges];

    if (nodes.isNotEmpty) {
      for (final q in quadrants) {
        foundObjects.addAll(nodes[q]!.retrieve(range));
      }
    }
    return foundObjects.toSet().toList();
  }

  /// Ranges that overlap with this range useing the optimised lookup
  List<A1Range> rangesIn(A1Range range) {
    final List<A1Range> ranges = [];
    for (final match in retrieve(range)) {
      if (match.overlaps(range)) {
        ranges.add(match);
      }
    }
    return ranges;
  }

  /// Clear all nodes
  void clear() {
    ranges.clear();

    for (final node in nodes.values) {
      if (node.nodes.isNotEmpty) node.clear();
    }

    nodes.clear();
  }

  @override
  bool operator ==(covariant Quadtree other) {
    if (identical(this, other)) return true;

    return other.bounds == bounds &&
        other.depth == depth &&
        other.ranges == ranges;
  }

  @override
  int get hashCode => bounds.hashCode ^ depth.hashCode ^ ranges.hashCode;

  @override
  String toString() {
    return 'Quadtree(depth: $depth, bounds: $bounds)';
  }
}
