import 'package:a1/src/helpers/a1_area.dart';
import 'package:a1/src/helpers/a1_vector.dart';
import 'package:test/test.dart';

void main() {
  group('A1Vector ', () {
    final vector1 = A1Vector(magnitude: 2);
    final vector2 =
        A1Vector(magnitude: -3, oneInfinite: true, twoInfinite: true);
    final vector3 =
        A1Vector(magnitude: 0, oneInfinite: true, twoInfinite: true);
    final vector4 = A1Vector(magnitude: 1, oneInfinite: true);

    final vector1FromPoints = A1Vector.fromPoints(0, 1);
    final vector2FromPoints = A1Vector.fromPoints(2, null);
    final vector3FromPoints = A1Vector.fromPoints(null, null);
    test(' constructors and factories', () {
      expect(vector1, equals(vector1FromPoints));
      expect(vector2, equals(vector2FromPoints));
      expect(vector3, equals(vector3FromPoints));
    });

    test(' multiply operator', () {
      expect(vector1 * vector1, equals(A1Area(magnitude: 4)));
      expect(vector3 * vector1,
          equals(A1Area(twoInfinite: true, oneInfinite: true, magnitude: 2)));

      expect(vector4 * vector1,
          equals(A1Area(magnitude: 2, oneInfinite: true, twoInfinite: true)));
      expect(vector1 * vector4,
          equals(A1Area(magnitude: 2, oneInfinite: true, twoInfinite: true)));
    });

    test(' hashCode', () {
      expect(vector1.hashCode, equals(vector1FromPoints.hashCode));
      expect(vector2.hashCode, equals(vector2FromPoints.hashCode));
      expect(vector3.hashCode, equals(vector3FromPoints.hashCode));
    });

    test(' equals', () {
      expect(vector1, equals(vector1FromPoints));
      expect(vector2, equals(vector2FromPoints));
      expect(vector3, equals(vector3FromPoints));
    });

    test(' toString', () {
      expect(
          vector1.toString(),
          equals(
              'A1Vector(twoInfinite: false, oneInfinite: false, magnitude: 2)'));
    });
  });
}
