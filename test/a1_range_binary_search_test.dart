import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group("A1RangeBinarySearch", () {
    A1RangeBinarySearch rangeSearch = A1RangeBinarySearch<bool>();
    setUp(() {
      rangeSearch = A1RangeBinarySearch<bool>();
      rangeSearch['B2:B3'.a1Range] = true;
      rangeSearch['C2:C2'.a1Range] = true;
      rangeSearch['C3:C3'.a1Range] = true;
      rangeSearch['D3:D4'.a1Range] = true;
      rangeSearch['C4:C4'.a1Range] = true;
    });

    test(" match", () {
      expect(rangeSearch.match('B2'.a1), isTrue);
      expect(rangeSearch.match('C2'.a1), isTrue);
      expect(rangeSearch.match('B3'.a1), isTrue);
      expect(rangeSearch.match('C3'.a1), isTrue);
      expect(rangeSearch.match('D3'.a1), isTrue);
      expect(rangeSearch.match('C4'.a1), isTrue);
      expect(rangeSearch.match('D4'.a1), isTrue);
    });
    test(" keyOf", () {
      expect(rangeSearch.keyOf('B2'.a1), equals('B2:B3'.a1Range));
      expect(rangeSearch.keyOf('C2'.a1), equals('C2:C2'.a1Range));
      expect(rangeSearch.keyOf('B3'.a1), equals('B2:B3'.a1Range));
      expect(rangeSearch.keyOf('C3'.a1), equals('C3:C3'.a1Range));
      expect(rangeSearch.keyOf('D3'.a1), equals('D3:D4'.a1Range));
      expect(rangeSearch.keyOf('C4'.a1), equals('C4:C4'.a1Range));
      expect(rangeSearch.keyOf('D4'.a1), equals('D3:D4'.a1Range));
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
