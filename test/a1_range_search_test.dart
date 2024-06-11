import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group("A1RangeBinarySearch", () {
    A1RangeSearch rangeSearch = A1RangeSearch<bool>();
    A1RangeSearch rangeSearch2 = A1RangeSearch<bool>();
    setUp(() {
      rangeSearch = A1RangeSearch<bool>();
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
    test(" rangesIn", () {
      expect(rangeSearch2.rangesIn('C30:C31'.a1Range),
          everyElement(isIn(['C30:D31'.a1Range])));
      expect(rangeSearch2.rangesIn('C20:C21'.a1Range),
          everyElement(isIn(['C20:D20'.a1Range])));
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

  group("Merged Range Cell moves - cellUp", () {
    final a1b = A1RangeSearch();
    a1b['G14:H16'.a1Range] = true;
    a1b['E20:E21'.a1Range] = true;
    a1b['C17:C20'.a1Range] = true;

    a1b['C5:D5'.a1Range] = true;
    a1b['E5:F5'.a1Range] = true;
    a1b['D6:E6'.a1Range] = true;

    a1b['C26:C27'.a1Range] = true;
    a1b['D25:D26'.a1Range] = true;
    a1b['D27:D28'.a1Range] = true;

    test(" up no merges", () {
      expect(a1b.cellUp('K2:L3'.a1Range), equals('K2:L2'.a1Range));

      // opposite anchor
      expect(a1b.cellUp('K3:L2'.a1Range), equals('K1:L3'.a1Range));
    });

    test(" up merged below", () {
      expect(a1b.cellUp('G13:H16'.a1Range), equals('G13:H13'.a1Range));
    });
    test(" up when contracting switch to expanding one merge", () {
      expect(a1b.cellUp('D20:E21'.a1Range), equals('D19:E21'.a1Range));

      // try different anchor
      expect(a1b.cellUp('D21:E20'.a1Range), equals('D19:E21'.a1Range));
    });

    test(" up when contracting switch to expanding multiple merges", () {
      expect(a1b.cellUp('C21:E17'.a1Range), equals('C16:E21'.a1Range));
    });

    test(' up with a cascade of column merges', () {
      final newRange = a1b.cellUp('C6:C6'.a1Range);
      expect(newRange, equals('C5:F6'.a1Range));
      expect(newRange.anchor, equals('C6'.a1));
    });
    test(' up with a cascade of row merges', () {
      final newRange = a1b.cellUp('C25:D28'.a1Range);
      expect(newRange, equals('C24:D28'.a1Range));
    });
  });
  group("Merged Range Cell moves - cellDown", () {
    final a1b = A1RangeSearch();
    a1b['J10:K12'.a1Range] = true;
    a1b['E20:E21'.a1Range] = true;
    a1b['C17:C20'.a1Range] = true;

    test(" down no merges", () {
      expect(a1b.cellDown('K2:L3'.a1Range), equals('K2:L4'.a1Range));

      // opposite anchor
      expect(a1b.cellDown('K3:L2'.a1Range), equals('K3:L3'.a1Range));
    });

    test(" down merged above", () {
      expect(a1b.cellDown('J13:K10'.a1Range), equals('J13:K13'.a1Range));
    });
    test(" down when contracting switch to expanding one merge", () {
      expect(a1b.cellDown('D21:E20'.a1Range), equals('D20:E22'.a1Range));

      // try different anchor
      //expect(a1b.cellDown('D20:E21'.a1Range), equals('D20:E22'.a1Range));
    });

    test("test down when contracting switch to expanding multiple merges", () {
      expect(a1b.cellDown('C21:E17'.a1Range), equals('C17:E22'.a1Range));
    });
  });

  group("Merged Range Cell moves - cellLeft", () {
    final a1b = A1RangeSearch();
    a1b['G14:I15'.a1Range] = true;
    a1b['D21:E21'.a1Range] = true;
    a1b['E19:H19'.a1Range] = true;

    a1b['C5:D5'.a1Range] = true;
    a1b['E5:F5'.a1Range] = true;
    a1b['D6:E6'.a1Range] = true;

    test(" left no merges", () {
      expect(a1b.cellLeft('K2:L3'.a1Range), equals('K2:K3'.a1Range));

      // opposite anchor
      expect(a1b.cellLeft('L2:K3'.a1Range), equals('J2:L3'.a1Range));
    });

    test(" left merged below", () {
      expect(a1b.cellLeft('F14:I15'.a1Range), equals('F14:F15'.a1Range));
    });
    test(" left when contracting switch to expanding one merge", () {
      expect(a1b.cellLeft('D20:E21'.a1Range), equals('C20:E21'.a1Range));

      // try different anchor
      expect(a1b.cellLeft('E20:D21'.a1Range), equals('C20:E21'.a1Range));
    });

    test(" left when contracting switch to expanding multiple merges", () {
      expect(a1b.cellLeft('D19:H21'.a1Range), equals('C19:H21'.a1Range));

      expect(a1b.cellLeft('C6:F5'.a1Range), equals('B5:F6'.a1Range));
    });
  });
  group("Merged Range Cell moves - cellRight", () {
    final a1b = A1RangeSearch();
    a1b['G14:I15'.a1Range] = true;
    a1b['D21:E21'.a1Range] = true;
    a1b['E19:H19'.a1Range] = true;

    a1b['C5:D5'.a1Range] = true;
    a1b['E5:F5'.a1Range] = true;
    a1b['D6:E6'.a1Range] = true;

    a1b['C26:C27'.a1Range] = true;
    a1b['D25:D26'.a1Range] = true;
    a1b['D27:D28'.a1Range] = true;

    test(" right no merges", () {
      expect(a1b.cellRight('K2:L3'.a1Range), equals('K2:M3'.a1Range));

      // opposite anchor
      expect(a1b.cellRight('L2:K3'.a1Range), equals('L2:L3'.a1Range));
    });

    test(" right merged right", () {
      expect(a1b.cellRight('J14:G15'.a1Range), equals('J14:J15'.a1Range));
    });
    test(" right when contracting switch to expanding one merge", () {
      expect(a1b.cellRight('E20:D21'.a1Range), equals('D20:F21'.a1Range));

      // try different anchor
      expect(a1b.cellRight('D20:E21'.a1Range), equals('D20:F21'.a1Range));
    });

    test(" right when contracting switch to expanding multiple merges", () {
      expect(a1b.cellRight('H21:D19'.a1Range), equals('D19:I21'.a1Range));
    });

    test(' right with a cascade of column merges', () {
      final newRange = a1b.cellRight('B5:G6'.a1Range.copyWith(anchor: 'C6'.a1));
      expect(newRange, equals('C5:G6'.a1Range));
    });

    test(' right with a cascade of row merges', () {
      final newRange = a1b.cellRight('C25:C25'.a1Range);
      expect(newRange, equals('C25:D28'.a1Range));
    });
  });
}
