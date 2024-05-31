import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group("A1RangeBinarySearch", () {
    A1RangeBinarySearch rangeSearch = A1RangeBinarySearch<bool>();
    A1RangeBinarySearch rangeSearch2 = A1RangeBinarySearch<bool>();
    setUp(() {
      rangeSearch = A1RangeBinarySearch<bool>();
      rangeSearch['B2:B3'.a1Range] = true;
      rangeSearch['C2:C2'.a1Range] = true;
      rangeSearch['C3:C3'.a1Range] = true;
      rangeSearch['D3:D4'.a1Range] = true;
      rangeSearch['C4:C4'.a1Range] = true;

      rangeSearch2 = [
        'C20:D20',
        'C28:D28',
        'C30:D31',
      ].a1rSearch;
    });

    test(" match", () {
      expect(rangeSearch.valueOf('B2'.a1), isTrue);
      expect(rangeSearch.valueOf('C2'.a1), isTrue);
      expect(rangeSearch.valueOf('B3'.a1), isTrue);
      expect(rangeSearch.valueOf('C3'.a1), isTrue);
      expect(rangeSearch.valueOf('D3'.a1), isTrue);
      expect(rangeSearch.valueOf('C4'.a1), isTrue);
      expect(rangeSearch.valueOf('D4'.a1), isTrue);
    });
    test(" keyOf", () {
      expect(rangeSearch.rangeOf('B2'.a1), equals('B2:B3'.a1Range));
      expect(rangeSearch.rangeOf('C2'.a1), equals('C2:C2'.a1Range));
      expect(rangeSearch.rangeOf('B3'.a1), equals('B2:B3'.a1Range));
      expect(rangeSearch.rangeOf('C3'.a1), equals('C3:C3'.a1Range));
      expect(rangeSearch.rangeOf('D3'.a1), equals('D3:D4'.a1Range));
      expect(rangeSearch.rangeOf('C4'.a1), equals('C4:C4'.a1Range));
      expect(rangeSearch.rangeOf('D4'.a1), equals('D3:D4'.a1Range));
    });
    test(" valueOf", () {
      expect(rangeSearch2.valueOf('C30'.a1), equals(true));
    });
    test(" rangeOf", () {
      expect(rangeSearch2.rangeOf('C30'.a1), equals('C30:D31'.a1Range));

      // expect the same result from a cache hit
      expect(rangeSearch2.rangeOf('C30'.a1), equals('C30:D31'.a1Range));

      // missing
      expect(rangeSearch2.rangeOf('C50'.a1), isNull);

      // expect the same result from a cache hit
      expect(rangeSearch2.rangeOf('C50'.a1), isNull);
    });
    test(" rangeIn", () {
      expect(
          rangeSearch2.rangeIn('C30:C31'.a1Range), equals('C30:D31'.a1Range));
      expect(
          rangeSearch2.rangeIn('C20:C21'.a1Range), equals('C20:D20'.a1Range));
    });
    test(" [] operator", () {
      expect(rangeSearch['C2:C2'.a1Range], equals(true));
    });
    test(" remove method", () {
      rangeSearch.remove('C2:C2'.a1Range);
      expect(rangeSearch.length, equals(4));
      expect(
          rangeSearch.keys,
          everyElement(isIn([
            'B2:B3'.a1Range,
            'C3:C3'.a1Range,
            'D3:D4'.a1Range,
            'C4:C4'.a1Range,
          ])));
    });
    test(" clear method", () {
      rangeSearch.clear();
      expect(rangeSearch.length, equals(0));
      expect(rangeSearch.keys, equals([]));
    });
    test(" keys method", () {
      expect(
          rangeSearch.keys,
          everyElement(isIn([
            'B2:B3'.a1Range,
            'C2:C2'.a1Range,
            'C3:C3'.a1Range,
            'D3:D4'.a1Range,
            'C4:C4'.a1Range,
          ])));
    });
  });
}
