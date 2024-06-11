import 'package:a1/src/helpers/quadtree.dart';
import 'package:test/test.dart';
import 'package:a1/a1.dart';

void main() {
  group('Quadtree Tests', () {
    final A1Range bounds = A1Range.fromCoordinates(0, 0, 100, 100);
    Quadtree quadtree = Quadtree(0, bounds);

    setUp(() {
      quadtree = Quadtree(0, bounds);
      for (int i = 0; i < 5; i++) {
        var (column, row) = (i * 10, i * 10);
        quadtree
            .insert(A1Range.fromCoordinates(column, row, column + 9, row + 9));
      }
    });

    test('Initialization', () {
      expect(quadtree.level, 0);
      expect(quadtree.bounds, bounds);
    });

    test('Clear', () {
      quadtree.insert(A1Range.fromCoordinates(10, 10, 10, 10));
      quadtree.clear();
    });

    test('Splitting', () {
      A1Range range = A1Range.fromCoordinates(10, 10, 19, 19);
      int index = quadtree.getIndex(range);

      expect(index, 1);

      range = A1Range.fromCoordinates(20, 20, 29, 29);
      index = quadtree.getIndex(range);
      expect(index, 1);
    });

    test('Remove', () {
      final A1Range range = A1Range.fromCoordinates(10, 10, 10, 10);
      quadtree.insert(range);
      bool removed = quadtree.remove(range);
      expect(removed, isTrue);
    });

    test('Find Containing Ranges', () {
      final A1Range range1 = A1Range.fromCoordinates(10, 10, 10, 10);
      final A1Range range2 = A1Range.fromCoordinates(15, 15, 10, 10);
      final A1Range target = A1Range.fromCoordinates(12, 12, 5, 5);

      expect(quadtree.findContainingA1Ranges(target), containsAll([]));

      quadtree.insert(range1);
      quadtree.insert(range2);

      List<A1Range> containingRanges = quadtree.findContainingA1Ranges(target);
      expect(containingRanges, containsAll([range1, range2]));
    });

    test('toString', () {
      expect(
          quadtree.toString(), equals('Quadtree(level: 0, bounds: A1:CW101)'));
    });
  });
}
