import 'package:a1/a1.dart';
import 'package:a1/src/helpers/a1_area.dart';
import 'package:test/test.dart';

void main() {
  group('A1Area ', () {
    final area1 = A1Area(magnitude: 1);
    final area2 = A1Area(magnitude: 2, oneInfinite: true, twoInfinite: true);
    final area3 = A1Area(magnitude: 1, oneInfinite: true, twoInfinite: true);
    final area4 = A1Area(
        magnitude: -2,
        oneInfinite: true,
        twoInfinite: true,
        threeInfinite: true);
    final area5 = A1Area(
        magnitude: 0,
        oneInfinite: true,
        twoInfinite: true,
        threeInfinite: true);

    final area1fromA1Range =
        A1Area.fromA1Range(A1Range.fromA1s('A1'.a1, 'A1'.a1));
    final area2fromA1Range = A1Area.fromA1Range(
      A1Range.fromPartials(
        A1Partial.fromVector(null, 0),
        A1Partial.fromVector(null, 1),
      ),
    );
    final area3fromA1Range = A1Area.fromA1Range(
      A1Range.fromPartials(
        A1Partial.fromVector(null, null),
        A1Partial.fromVector(0, 0),
      ),
    );
    final area4fromA1Range = A1Area.fromA1Range(
      A1Range.fromPartials(
        A1Partial.fromVector(0, 0),
        A1Partial.fromVector(null, null),
      ),
    );
    final area5fromA1Range = A1Area.fromA1Range(A1Range.all);
    test(' constructors and factories', () {
      expect(area1fromA1Range, equals(area1));
      expect(area2fromA1Range, equals(area2));
      expect(area3fromA1Range, equals(area3));
      expect(area4fromA1Range, equals(area4));
      expect(area5fromA1Range, equals(area5));
    });

    test(' comparison', () {
      expect(area1.compareTo(area2), equals(-1));
      expect(area2.compareTo(area3), equals(1));
      expect(area3.compareTo(area4), equals(-1));
      expect(area1.compareTo(area2), equals(-1));
      expect(area4.compareTo(area4), equals(0));
      expect(area4.compareTo(area1fromA1Range), equals(1));

      final odd1 = A1Area(
          magnitude: 0,
          oneInfinite: false,
          twoInfinite: true,
          threeInfinite: true);
      final odd2 = A1Area(
          magnitude: 0,
          oneInfinite: true,
          twoInfinite: true,
          threeInfinite: true);

      expect(odd1.compareTo(odd2), equals(-1));
      expect(odd2.compareTo(odd1), equals(1));
    });

    test(' hashCode', () {
      expect(area1.hashCode, equals(area1fromA1Range.hashCode));
      expect(area2.hashCode, equals(area2fromA1Range.hashCode));
      expect(area3.hashCode, equals(area3fromA1Range.hashCode));
      expect(area4.hashCode, equals(area4fromA1Range.hashCode));
      expect(area5.hashCode, equals(area5fromA1Range.hashCode));
    });
    test(' equals', () {
      expect(area1, equals(area1fromA1Range));
      expect(area2, equals(area2fromA1Range));
      expect(area3, equals(area3fromA1Range));
      expect(area4, equals(area4fromA1Range));
      expect(area5, equals(area5fromA1Range));
    });

    test(' toString', () {
      expect(
          area1.toString(),
          equals(
              'A1Area(threeInfinite: false, twoInfinite: false,oneInfinite: false,  magnitude: 1)'));
    });
  });
}
