import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group('A1 Partials', () {
    final a1p1 = A1Partial('B', 1);
    final a1p2 = A1Partial('B', null);
    final a1p3 = A1Partial(null, 1);
    final a1p4 = A1Partial(null, null);
    test('compare A1 with A1,A,1,null', () {
      expect(a1p1.compareTo(a1p1), equals(0));
      expect(a1p1.compareTo(a1p2), equals(0));
      expect(a1p1.compareTo(a1p3), equals(0));
      expect(() => a1p1.compareTo(a1p4), throwsA(isA<UnimplementedError>()));
    });
    test('compare A with A1,A,1,null', () {
      expect(a1p2.compareTo(a1p1), equals(0));
      expect(a1p2.compareTo(a1p2), equals(0));
      expect(a1p2.compareTo(a1p3), equals(-1));
      expect(() => a1p1.compareTo(a1p4), throwsA(isA<UnimplementedError>()));
    });
    test('compare 1 with A1,A,1,null', () {
      expect(a1p3.compareTo(a1p1), equals(0));
      expect(a1p3.compareTo(a1p2), equals(1));
      expect(a1p3.compareTo(a1p3), equals(0));
      expect(a1p3.compareTo(a1p4), equals(-1));
    });
    test('compare null with A1,A,1,null', () {
      expect(() => a1p4.compareTo(a1p1), throwsA(isA<UnimplementedError>()));
      expect(a1p4.compareTo(a1p2), equals(1));
      expect(a1p4.compareTo(a1p3), equals(1));
      expect(() => a1p4.compareTo(a1p4), throwsA(isA<UnimplementedError>()));
    });

    test('<', () {
      expect(a1p2 < a1p3, isTrue);
    });
    test('<=', () {
      expect(a1p1 <= a1p1, isTrue);
      expect(a1p2 <= a1p3, isTrue);
      expect(a1p3 <= a1p2, isFalse);
    });
    test('>', () {
      expect(a1p2 > a1p3, isFalse);
      expect(a1p3 > a1p2, isTrue);
    });

    test('>=', () {
      expect(a1p1 >= a1p1, isTrue);
      expect(a1p3 >= a1p2, isTrue);
    });

    test('hashcode', () {
      expect(a1p1.hashCode, equals(A1Partial('B', 1).hashCode));
      expect(a1p2.hashCode, equals(A1Partial('B', null).hashCode));
      expect(a1p3.hashCode, equals(A1Partial(null, 1).hashCode));
      expect(a1p4.hashCode, equals(A1Partial(null, null).hashCode));
    });
  });
}
