import 'package:a1/a1.dart';

/// A class representing a Quadtree data structure for spatial partitioning.
class Quadtree {
  static const int _maxObjects = 4;
  static const int _maxLevels = 4;

  /// The current level of this node.
  final int level;
  final List<A1Range> _objects = [];
  final List<Quadtree?> _nodes = List<Quadtree?>.filled(
    4,
    null,
    growable: false,
  );

  /// bounds for this node/tree
  final A1Range bounds;

  /// Creates a Quadtree node with a specific level and bounds.
  Quadtree(this.level, this.bounds);

  /// Clears the Quadtree by removing all objects and child nodes.
  void clear() {
    _objects.clear();
    for (int i = 0; i < _nodes.length; i++) {
      _nodes[i]?.clear();
      _nodes[i] = null;
    }
  }

  /// Splits the node into four subnodes.
  void split() {
    int subWidth = bounds.width ~/ 2;
    int subHeight = bounds.height ~/ 2;
    int left = bounds.left;
    int top = bounds.top;

    _nodes[0] = Quadtree(level + 1,
        A1Range.fromCoordinates(left + subWidth, top, subWidth, subHeight));
    _nodes[1] = Quadtree(
        level + 1, A1Range.fromCoordinates(left, top, subWidth, subHeight));
    _nodes[2] = Quadtree(level + 1,
        A1Range.fromCoordinates(left, top + subHeight, subWidth, subHeight));
    _nodes[3] = Quadtree(
      level + 1,
      A1Range.fromCoordinates(
        left + subWidth,
        top + subHeight,
        subWidth,
        subHeight,
      ),
    );
  }

  /// Determines the index of the subnode that would contain the given range.
  ///
  /// Returns -1 if the range cannot fit within a subnode and should remain
  /// in the parent node.
  int getIndex(A1Range range) {
    int index = -1;
    double verticalMidpoint = bounds.left + bounds.width / 2;
    double horizontalMidpoint = bounds.top + bounds.height / 2;

    bool topQuadrant = range.left < horizontalMidpoint &&
        range.top + range.height < horizontalMidpoint;
    bool bottomQuadrant = range.top > horizontalMidpoint;

    if (range.left < verticalMidpoint &&
        range.left + range.width < verticalMidpoint) {
      if (topQuadrant) {
        index = 1;
      } else if (bottomQuadrant) {
        index = 2;
      }
    } else if (range.left > verticalMidpoint) {
      if (topQuadrant) {
        index = 0;
      } else if (bottomQuadrant) {
        index = 3;
      }
    }
    return index;
  }

  /// Inserts a range into the Quadtree.
  ///
  /// If the node exceeds the maximum number of objects, it will split
  /// and distribute its objects among the subnodes.
  void insert(A1Range range) {
    if (_nodes[0] != null) {
      int index = getIndex(range);
      if (index != -1) {
        _nodes[index]!.insert(range);
        return;
      }
    }

    _objects.add(range);

    if (_objects.length > _maxObjects && level < _maxLevels) {
      if (_nodes[0] == null) {
        split();
      }

      int i = 0;
      while (i < _objects.length) {
        int index = getIndex(_objects[i]);
        if (index != -1) {
          _nodes[index]!.insert(_objects.removeAt(i));
        } else {
          i++;
        }
      }
    }
  }

  /// Removes a range from the Quadtree.
  ///
  /// Returns `true` if the range was successfully removed.
  bool remove(A1Range rect) {
    if (_nodes[0] != null) {
      int index = getIndex(rect);
      if (index != -1) {
        bool removedFromChild = _nodes[index]!.remove(rect);
        if (removedFromChild) {
          return true;
        }
      }
    }
    int initialLength = _objects.length;
    _objects.remove(rect);
    return initialLength != _objects.length;
  }

  // Retrieves all ranges that could collide with the given range.
  List<A1Range> _retrieve(List<A1Range> returnObjects, A1Range range) {
    int index = getIndex(range);
    if (index != -1 && _nodes[0] != null) {
      _nodes[index]!._retrieve(returnObjects, range);
    }
    returnObjects.addAll(_objects);
    return returnObjects;
  }

  /// Finds and returns all ranges that overlap with the given target range.
  List<A1Range> findContainingA1Ranges(A1Range target) {
    final possibleMatches = _retrieve([], target);
    return possibleMatches.where((range) => range.overlaps(target)).toList();
  }

  @override
  String toString() => 'Quadtree(level: $level, bounds: $bounds)';
}
