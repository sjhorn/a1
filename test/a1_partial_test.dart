import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group('A1 Partials', () {
    final a1p1 = A1Partial('B', 1);
    final a1p2 = A1Partial('B', null);
    final a1p3 = A1Partial(null, 1);
    final a1p4 = A1Partial(null, null);
    final a1p5 = A1Partial.fromVector(1, 0);
    final a1p6 = A1Partial.fromA1('B1'.a1);
    test('vector matches parse', () {
      expect(a1p1 == a1p5, isTrue);
      expect(a1p1 == a1p6, isTrue);
    });
    test('compare A1 with A1,A,1,null', () {
      expect(a1p1.compareTo(a1p1), equals(0));
      expect(a1p1.compareTo(a1p2), equals(0));
      expect(a1p1.compareTo(a1p3), equals(1));
      expect(a1p1.compareTo(a1p4), equals(1));
    });
    test('compare A with A1,A,1,null', () {
      expect(a1p2.compareTo(a1p1), equals(0));
      expect(a1p2.compareTo(a1p2), equals(0));
      expect(a1p2.compareTo(a1p3), equals(1));
      expect(a1p1.compareTo(a1p4), equals(1));
    });
    test('compare 1 with A1,A,1,null', () {
      expect(a1p3.compareTo(a1p1), equals(-1));
      expect(a1p3.compareTo(a1p2), equals(-1));
      expect(a1p3.compareTo(a1p3), equals(0));
      expect(a1p3.compareTo(a1p4), equals(0));
    });
    test('compare null with A1,A,1,null', () {
      expect(a1p4.compareTo(a1p1), equals(-1));
      expect(a1p4.compareTo(a1p2), equals(-1));
      expect(a1p4.compareTo(a1p3), equals(0));
      expect(a1p4.compareTo(a1p4), equals(0));
    });

    test('<', () {
      expect(a1p2 < a1p3, isFalse);
    });
    test('<=', () {
      expect(a1p1 <= a1p1, isTrue);
      expect(a1p2 <= a1p3, isFalse);
      expect(a1p3 <= a1p2, isTrue);
    });
    test('>', () {
      expect(a1p2 > a1p3, isTrue);
      expect(a1p3 > a1p2, isFalse);
    });

    test('>=', () {
      expect(a1p1 >= a1p1, isTrue);
      expect(a1p3 >= a1p2, isFalse);
    });

    test('hashcode', () {
      expect(a1p1.hashCode, equals(A1Partial('B', 1).hashCode));
      expect(a1p2.hashCode, equals(A1Partial('B', null).hashCode));
      expect(a1p3.hashCode, equals(A1Partial(null, 1).hashCode));
      expect(a1p4.hashCode, equals(A1Partial(null, null).hashCode));
    });
    test('whole row, column or either', () {
      expect(A1Partial('A', null).isWholeColumn, isTrue);
      expect(A1Partial('A', null).isWholeRow, isFalse);
      expect(A1Partial('A', null).isWholeRowOrColumn, isTrue);
      expect(A1Partial(null, 1).isWholeColumn, isFalse);
      expect(A1Partial(null, 1).isWholeRow, isTrue);
      expect(A1Partial(null, 1).isWholeRowOrColumn, isTrue);
    });

    test('all singleton', () {
      expect(A1Partial.all, equals(A1Partial(null, null)));
    });
    test('min/max', () {
      final list = [
        A1Partial('A', 1),
        A1Partial('B', 2),
        null,
        A1Partial('C', 3),
        null
      ];
      expect(
        A1Partial.min(list),
        equals(A1Partial('A', 1)),
      );
      expect(
        A1Partial.max(list),
        equals(A1Partial('C', 3)),
      );
    });
  });

  group('A1Partial with absolute references', () {
    test('constructor with absolute flags', () {
      final p = A1Partial('A', 1, columnAbsolute: true, rowAbsolute: true);
      expect(p.columnAbsolute, isTrue);
      expect(p.rowAbsolute, isTrue);
      expect(p.toString(), equals('\$A\$1'));
    });

    test('default flags are false', () {
      final p = A1Partial('A', 1);
      expect(p.columnAbsolute, isFalse);
      expect(p.rowAbsolute, isFalse);
    });

    test('equality ignores absolute state', () {
      expect(A1Partial('A', 1, columnAbsolute: true),
          equals(A1Partial('A', 1)));
    });

    test('fromVector with absolute flags', () {
      final p = A1Partial.fromVector(0, 0,
          columnAbsolute: true, rowAbsolute: true);
      expect(p.toString(), equals('\$A\$1'));
    });

    test('fromA1 preserves absolute state', () {
      final a1 = A1.parse('\$A\$1');
      final p = A1Partial.fromA1(a1);
      expect(p.columnAbsolute, isTrue);
      expect(p.rowAbsolute, isTrue);
    });

    test('vectorCopyWith preserves absolute state', () {
      final p = A1Partial('A', 1, columnAbsolute: true, rowAbsolute: true);
      final moved = p.vectorCopyWith(row: 5);
      expect(moved.columnAbsolute, isTrue);
      expect(moved.rowAbsolute, isTrue);
    });

    test('partial with only column absolute', () {
      final p = A1Partial('A', null, columnAbsolute: true);
      expect(p.toString(), equals('\$A'));
    });

    test('partial with only row absolute', () {
      final p = A1Partial(null, 1, rowAbsolute: true);
      expect(p.toString(), equals('\$1'));
    });
  });
}
