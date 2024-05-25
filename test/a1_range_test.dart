import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group('Creating an A1Range', () {
    test('from singleton all', () {
      expect(A1Range.all.from.column, isNull);
      expect(A1Range.all.from.row, isNull);
      expect(A1Range.all.to.column, isNull);
      expect(A1Range.all.to.row, isNull);
      expect(A1Range.all.anchor, equals('a1'.a1));
    });
    test('by parsing a string with full a1s', () {
      final a1r = A1Range.parse('A1:B2');
      expect(a1r, isA<A1Range>());
      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to.a1, equals('B2'.a1));
      expect(a1r.from.letters, equals('A'));
      expect(a1r.from.digits, equals(1));
      expect(a1r.to.letters, equals('B'));
      expect(a1r.to.digits, equals(2));
    });
    test('by parsing a string with partial a1s', () {
      final a1r = A1Range.parse('A1:B');
      expect(a1r, isA<A1Range>());
      expect(a1r.from, equals('A1'.a1));
      expect(a1r.from.letters, equals('A'));
      expect(a1r.from.digits, equals(1));
      expect(a1r.to.letters, equals('B'));
      expect(a1r.to.digits, isNull);
    });

    test('throws when parsing an invalid string', () {
      expect(() => A1Range.parse('123:'), throwsA(isA<FormatException>()));
      expect(() => A1Range.parse('å1:a2'), throwsA(isA<FormatException>()));
      expect(() => A1Range.parse('aøa1:b2'), throwsA(isA<FormatException>()));
      expect(() => A1Range.parse('A1.1:b2'), throwsA(isA<FormatException>()));
    });

    test('by tryParsing a two valid A1 string', () {
      final a1r = A1Range.tryParse('ZZA123:a2');
      expect(a1r?.from, equals('a2'.a1));
      expect(a1r?.to, equals('ZZA123'.a1));
      expect(a1r, equals('ZZA123:a2'.a1Range));
      expect(a1r?.anchor, equals('ZZA123'.a1));
    });
    test('where the to column/row is greater than the from column/row ', () {
      final a1r = 'C2:A5'.a1Range;
      expect(a1r.from, equals('a2'.a1));
      expect(a1r.to, equals('c5'.a1));
      expect(a1r, equals('a2:c5'.a1Range));
      expect(a1r.anchor, equals('c2'.a1));
    });
    test('where the to column/row is greater than the from column/row ', () {
      final a1r = 'C2:A5'.a1Range;
      expect(a1r.from, equals('a2'.a1));
      expect(a1r.to, equals('c5'.a1));
      expect(a1r, equals('a2:c5'.a1Range));
      expect(a1r.anchor, equals('c2'.a1));
    });
    test('corner test ', () {
      final a1r = 'C2:A5'.a1Range;
      expect(a1r.hasCorner('A2'.a1), isTrue);
      expect(a1r.hasCorner('C2'.a1), isTrue);
      expect(a1r.hasCorner('A5'.a1), isTrue);
      expect(a1r.hasCorner('C5'.a1), isTrue);
      expect(A1Range.all.hasCorner('a1'.a1), isTrue);

      expect('A:B'.a1Range.hasCorner('A1'.a1), isTrue);
      expect('A:A'.a1Range.hasCorner('A1'.a1), isTrue);
      expect('A'.a1Range.hasCorner('A1'.a1), isTrue);
      expect('1:2'.a1Range.hasCorner('A2'.a1), isTrue);
      expect('2'.a1Range.hasCorner('A2'.a1), isTrue);
      expect('I'.a1Range.hasCorner('I1'.a1), isTrue);
    });
    test(
        'where the to column is greater than the from column, but row is greater',
        () {
      final a1r = 'B2:A3'.a1Range;
      expect(a1r.from, equals('a2'.a1));
      expect(a1r.to, equals('b3'.a1));
      expect(a1r, equals('a2:b3'.a1Range));
      expect(a1r.anchor, equals('b2'.a1));
    });
    test('from A1s', () {
      var a1r = A1Range.fromA1s('a2'.a1, 'ZZA123'.a1);
      expect(a1r.from, equals('a2'.a1));
      expect(a1r.to, equals('ZZA123'.a1));
      expect(a1r, equals('ZZA123:a2'.a1Range));
      expect(a1r.anchor, equals('a2'.a1));

      // wrong order
      a1r = A1Range.fromA1s('ZZA123'.a1, 'a2'.a1);
      expect(a1r.from, equals('a2'.a1));
      expect(a1r.to, equals('ZZA123'.a1));
      expect(a1r, equals('ZZA123:a2'.a1Range));
      expect(a1r.anchor, equals('ZZA123'.a1));
    });

    test('returns null when tryParsing an invalid A1Range string', () {
      final result = A1Range.tryParse('123');
      expect(result, isA<A1Range>());
      expect(result?.from, isA<A1Partial>());
      expect(result?.from.column, isNull);
      expect(result?.from.row, equals(122));
      expect(result?.to, isA<A1Partial>());
      expect(result?.to.column, isNull);
      expect(result?.to.row, isNull);
    });
    test('hasColumn for variages ranges', () {
      expect('A1:A2'.a1Range.hasColumn(0), isTrue);
      expect('A1:A2'.a1Range.hasColumn(1), isFalse);
      expect('A1:A'.a1Range.hasColumn(0), isTrue);
      expect('A1:2'.a1Range.hasColumn(0), isFalse);
      expect('A:B2'.a1Range.hasColumn(0), isTrue);
      expect('1:2'.a1Range.hasColumn(0), isTrue);
      expect('A:A'.a1Range.hasColumn(1), isFalse);
    });
    test('hasRow for variages ranges', () {
      expect('A1:A2'.a1Range.hasRow(0), isTrue);
      expect('A1:B1'.a1Range.hasRow(1), isFalse);
      expect('A1:A'.a1Range.hasRow(0), isFalse);
      expect('A1:2'.a1Range.hasRow(0), isTrue);
      expect('2:B2'.a1Range.hasRow(1), isTrue);
      expect('A:B'.a1Range.hasRow(0), isTrue);
      expect('1:1'.a1Range.hasRow(1), isFalse);
    });
    test('leftBorder for various ranges', () {
      expect('A1:A2'.a1Range.leftBorder, equals('A1:A2'.a1Range));
      expect('A1:B1'.a1Range.leftBorder, equals('A1:A1'.a1Range));
      expect('A1:A'.a1Range.leftBorder, equals('A1:A'.a1Range));
      expect('A1:2'.a1Range.leftBorder, equals('A1:A2'.a1Range));
      expect('2:B2'.a1Range.leftBorder, equals('2:2'.a1Range));
      expect('A:B'.a1Range.leftBorder, equals('A:A'.a1Range));
      expect('1:1'.a1Range.leftBorder, equals('1:1'.a1Range));
    });
    test('rightBorder for various ranges', () {
      expect('A1:A2'.a1Range.rightBorder, equals('A1:A2'.a1Range));
      expect('A1:B1'.a1Range.rightBorder, equals('B1:B1'.a1Range));
      expect('A1:A'.a1Range.rightBorder, equals('A1:A'.a1Range));
      expect('A1:2'.a1Range.rightBorder, equals('1:2'.a1Range));
      expect('2:B2'.a1Range.rightBorder, equals('B2:B2'.a1Range));
      expect('A:B'.a1Range.rightBorder, equals('B:B'.a1Range));
      expect('1:1'.a1Range.rightBorder, equals('1:1'.a1Range));
    });
    test('topBorder for various ranges', () {
      expect('A1:A2'.a1Range.topBorder, equals('A1:A1'.a1Range));
      expect('A1:B1'.a1Range.topBorder, equals('A1:B1'.a1Range));
      expect('A1:A'.a1Range.topBorder, equals('A1:A1'.a1Range));
      expect('A1:2'.a1Range.topBorder, equals('A1:1'.a1Range));
      expect('2:B2'.a1Range.topBorder, equals('2:B2'.a1Range));
      expect('A:B'.a1Range.topBorder, equals('A:B'.a1Range));
      expect('1:1'.a1Range.topBorder, equals('1:1'.a1Range));
    });
    test('bottomBorder for various ranges', () {
      expect('A1:A2'.a1Range.bottomBorder, equals('A2:A2'.a1Range));
      expect('A1:B1'.a1Range.bottomBorder, equals('A1:B1'.a1Range));
      expect('A1:A'.a1Range.bottomBorder, equals('A:A'.a1Range));
      expect('A1:2'.a1Range.bottomBorder, equals('A2:2'.a1Range));
      expect('2:B2'.a1Range.bottomBorder, equals('2:B2'.a1Range));
      expect('A:B'.a1Range.bottomBorder, equals('A:B'.a1Range));
      expect('1:1'.a1Range.bottomBorder, equals('1:1'.a1Range));
    });
    test('horizontalBorders for various ranges', () {
      expect('A1:A2'.a1Range.horizontalBorders, equals('A1:A1'.a1Range));
      expect('A1:B1'.a1Range.horizontalBorders, isNull);
      expect('A1:A'.a1Range.horizontalBorders, equals('A1:A'.a1Range));
      expect('A1:2'.a1Range.horizontalBorders, equals('A1:1'.a1Range));
      expect('2:B2'.a1Range.horizontalBorders, isNull);
      expect('A:B'.a1Range.horizontalBorders, equals('A:B'.a1Range));
      expect('1:1'.a1Range.horizontalBorders, isNull);
    });
    test('verticalBorders for various ranges', () {
      expect('A1:A2'.a1Range.verticalBorders, isNull);
      expect('A1:B1'.a1Range.verticalBorders, equals('A1:A1'.a1Range));
      expect('A1:A'.a1Range.verticalBorders, isNull);
      expect('A1:2'.a1Range.verticalBorders, equals('A1:2'.a1Range));
      expect('2:B2'.a1Range.verticalBorders, equals('2:A2'.a1Range));
      expect('A:B'.a1Range.verticalBorders, equals('A:A'.a1Range));
      expect('1:1'.a1Range.verticalBorders, equals('1:1'.a1Range));
    });

    test('overlaps for various ranges', () {
      // // ranges without whole columns
      // expect('A1:B2'.a1Range.overlaps('B2:E4'.a1Range), isTrue);
      // expect('A1:B2'.a1Range.overlaps('C2:D3'.a1Range), isFalse);

      // expect('A4:B5'.a1Range.overlaps('B2:E4'.a1Range), isTrue);
      // expect('E1:G2'.a1Range.overlaps('B2:E4'.a1Range), isTrue);
      // expect('E4:G5'.a1Range.overlaps('B2:E4'.a1Range), isTrue);

      // // whole column in one
      // expect('A:E'.a1Range.overlaps('E2:G4'.a1Range), isTrue);
      // expect('A:E'.a1Range.overlaps('E:F'.a1Range), isTrue);
      // expect('A:E'.a1Range.overlaps('G:I'.a1Range), isFalse);

      // expect('E2:G4'.a1Range.overlaps('A:E'.a1Range), isTrue);
      // expect('E:F'.a1Range.overlaps('A:E'.a1Range), isTrue);
      // expect('G:I'.a1Range.overlaps('A:E'.a1Range), isFalse);

      // // whole row in one
      // expect('3:7'.a1Range.overlaps('C6:D13'.a1Range), isTrue);
      // expect('3:7'.a1Range.overlaps('5:9'.a1Range), isTrue);
      // expect('1:2'.a1Range.overlaps('3:4'.a1Range), isFalse);

      // expect('C6:D13'.a1Range.overlaps('3:7'.a1Range), isTrue);
      // expect('5:9'.a1Range.overlaps('3:7'.a1Range), isTrue);
      // expect('3:4'.a1Range.overlaps('1:2'.a1Range), isFalse);

      // all from a starting cell
      expect('D1'.a1Range.overlaps('E1:E1'.a1Range), isTrue);
    });

    test('intersects for various ranges', () {
      // ranges without whole columns
      expect(
          'A1:B2'.a1Range.intersect('B2:E4'.a1Range), equals('B2:B2'.a1Range));
      expect('A1:B2'.a1Range.intersect('C2:D3'.a1Range), isNull);

      expect(
          'A4:B5'.a1Range.intersect('B2:E4'.a1Range), equals('B4:B4'.a1Range));
      expect(
          'E1:G2'.a1Range.intersect('B2:E4'.a1Range), equals('E2:E2'.a1Range));
      expect(
          'E4:G5'.a1Range.intersect('B2:E4'.a1Range), equals('E4:E4'.a1Range));

      // whole column in one
      expect('A:E'.a1Range.intersect('E2:G4'.a1Range), equals('E2:E4'.a1Range));
      expect('A:E'.a1Range.intersect('E:F'.a1Range), equals('E:E'.a1Range));
      expect('A:E'.a1Range.intersect('G:I'.a1Range), isNull);

      expect('E2:G4'.a1Range.intersect('A:E'.a1Range), equals('E2:E4'.a1Range));
      expect('E:F'.a1Range.intersect('A:E'.a1Range), equals('E:E'.a1Range));
      expect('G:I'.a1Range.intersect('A:E'.a1Range), isNull);

      // whole row in one
      expect(
          '3:7'.a1Range.intersect('C6:D13'.a1Range), equals('C6:D7'.a1Range));
      expect('3:7'.a1Range.intersect('5:9'.a1Range), equals('5:7'.a1Range));
      expect('1:2'.a1Range.intersect('3:4'.a1Range), isNull);

      expect(
          'C6:D13'.a1Range.intersect('3:7'.a1Range), equals('C6:D7'.a1Range));
      expect('5:9'.a1Range.intersect('3:7'.a1Range), equals('5:7'.a1Range));
      expect('3:4'.a1Range.intersect('1:2'.a1Range), isNull);

      // all intersects
      expect(A1Range.all.intersect('A1:A2'.a1Range), equals('A1:A2'.a1Range));
      expect('A1:A2'.a1Range.intersect(A1Range.all), equals('A1:A2'.a1Range));

      expect('A:B'.a1Range.intersect('A1:A2'.a1Range), equals('A1:A2'.a1Range));
      expect('A1:A2'.a1Range.intersect('A:B'.a1Range), equals('A1:A2'.a1Range));

      expect('1:2'.a1Range.intersect('A1:A2'.a1Range), equals('A1:A2'.a1Range));
      expect('A1:A2'.a1Range.intersect('1:2'.a1Range), equals('A1:A2'.a1Range));
      expect(A1Range.all.intersect(A1Range.all), equals(A1Range.all));
    });
    test('subtract for bounded ranges', () {
      // inside ranges
      expect('A1:A4'.a1Range.subtract('A1:A2'.a1Range),
          containsAll(['A3:A4'.a1Range]));
      expect('C1:C4'.a1Range.subtract('C3:C4'.a1Range),
          containsAll(['C1:C2'.a1Range]));
      expect('A9:D9'.a1Range.subtract('A9:B9'.a1Range),
          containsAll(['C9:D9'.a1Range]));
      expect('A9:D9'.a1Range.subtract('C9:D9'.a1Range),
          containsAll(['A9:B9'.a1Range]));

      // overlapping top/right/bottom
      expect('A18:E21'.a1Range.subtract('D16:F24'.a1Range),
          containsAll(['A18:C21'.a1Range]));

      // overlapping left/top/bottom
      expect('C29:G32'.a1Range.subtract('A26:C35'.a1Range),
          containsAll(['D29:G32'.a1Range]));

      // complete overlap
      expect('C4:G32'.a1Range.subtract('A1:F35'.a1Range), containsAll([]));

      // no overlap
      expect('A1:B6'.a1Range.subtract('D1:F35'.a1Range),
          containsAll(['A1:B6'.a1Range]));
    });
    test('subtract for unbounded ranges', () {
      // // Substract from whole columns
      // expect(
      //   'A:D'.a1Range.subtract('B2:C3'.a1Range),
      //   everyElement(isIn([
      //     'A1:A'.a1Range,
      //     'D1:D'.a1Range,
      //     'B1:C1'.a1Range,
      //     'B4:C'.a1Range,
      //   ])),
      // );

      // // Subtract from whole rows
      // expect(
      //   '1:4'.a1Range.subtract('B2:C3'.a1Range),
      //   everyElement(isIn([
      //     'A1:A4'.a1Range,
      //     'D1:4'.a1Range,
      //     'B1:C1'.a1Range,
      //     'B4:C4'.a1Range,
      //   ])),
      // );

      // // Subtract from all
      // expect(
      //   A1Range.all.subtract('B2:C3'.a1Range),
      //   everyElement(isIn([
      //     'A1:A'.a1Range,
      //     'D1'.a1Range,
      //     'B1:C1'.a1Range,
      //     'B4:C'.a1Range,
      //   ])),
      // );
      // expect(
      //   A1Range.all.subtract('A1:A1'.a1Range),
      //   everyElement(isIn([
      //     'B1'.a1Range,
      //     'A2:A'.a1Range,
      //   ])),
      // );

      // // Subtract from whole columns from all
      // expect(
      //   A1Range.all.subtract('B:C'.a1Range),
      //   everyElement(isIn([
      //     'A1:A'.a1Range,
      //     'D1'.a1Range,
      //   ])),
      // );

      // // Subtract from whole row from all
      // expect(
      //   A1Range.all.subtract('2:2'.a1Range),
      //   everyElement(isIn([
      //     'A1:1'.a1Range,
      //     'A3'.a1Range,
      //   ])),
      // );

      // Subtract from unbounded with starting cell
      expect(
        'D1'.a1Range.subtract('E2:E2'.a1Range),
        everyElement(isIn([
          'D1:D'.a1Range,
          'E1:E1'.a1Range,
          'F1'.a1Range,
          'E3:E'.a1Range,
        ])),
      );
    });

    test('overlayRange for bounded ranges', () {
      final ranges = [
        'A1:B1'.a1Range.copyWith(tag: 'first'),
        'A2:B2'.a1Range.copyWith(tag: 'second'),
      ];
      final overlay = 'A1:B2'.a1Range.copyWith(tag: 'overlay');
      final overlayed1 = A1Range.overlayRange(ranges, overlay);
      final overlayed2 = A1Range.overlayRange([], overlay);
      expect(overlayed1, everyElement(isIn(ranges)));
      expect(
        overlayed1.firstWhere((e) => e == 'A1:B1'.a1Range).tag,
        everyElement(isIn(['overlay', 'first'])),
      );
      expect(
        overlayed1.firstWhere((e) => e == 'A2:B2'.a1Range).tag,
        everyElement(isIn(['overlay', 'second'])),
      );
      expect(overlayed2, everyElement(isIn([overlay])));
    });
    test('overlayRange for unbounded ranges', () {
      final ranges = [
        A1Range.all.copyWith(tag: 'all'),
        'A:D'.a1Range.copyWith(tag: 'vertical'),
        '1:4'.a1Range.copyWith(tag: 'horizontal'),
      ];
      final overlay = 'B2:C2'.a1Range.copyWith(tag: 'overlay');

      final overlayAll = A1Range.all.copyWith(tag: 'overlay');
      final overlayed1 = A1Range.overlayRange([], overlayAll);
      expect(overlayed1.length, equals(1));
      expect(overlayed1.first, equals(A1Range.all));
      expect(overlayed1.first.tag, equals('overlay'));

      final overlayed2 = A1Range.overlayRange(ranges.sublist(0, 1), overlay);
      expect(overlayed2.length, equals(5));
      expect(overlayed2.last, equals(overlay));
      expect((overlayed2.last.tag as List).last, equals('overlay'));

      final overlayed3 = A1Range.overlayRange(ranges.sublist(1, 2), overlay);
      expect(overlayed3.length, equals(5));
      expect(overlayed3.last, equals(overlay));
      expect((overlayed3.last.tag as List).last, equals('overlay'));

      final overlayed4 = A1Range.overlayRange(ranges.sublist(2, 3), overlay);
      expect(overlayed4.length, equals(5));
      expect(overlayed4.last, equals(overlay));
      expect((overlayed4.last.tag as List).last, equals('overlay'));

      // final overlayed3 = A1Range.overlayRange(ranges.sublist(1,2), overlay);
      // expect(overlayed3, everyElement(isIn(ranges)));
      // expect(
      //   overlayed3.firstWhere((e) => e == 'A1:B1'.a1Range).tag,
      //   everyElement(isIn(['overlay', 'first'])),
      // );
      // expect(
      //   overlayed3.firstWhere((e) => e == 'A2:B2'.a1Range).tag,
      //   everyElement(isIn(['overlay', 'second'])),
      // );
      //expect(overlayed2, everyElement(isIn([overlay])));
    });
    test('overlayRanges for various ranges', () {
      final overlapsOneTag = 'A1:B1'
          .a1Range
          .overlayRanges(['B1:B1'.a1Range.copyWith(tag: 'b1:b1')]);
      expect(overlapsOneTag.firstWhere((e) => e == 'B1:B1'.a1Range).tag,
          equals('b1:b1'));

      final (r1, r2, r3, r4, r5) = (
        'C1:D2'.a1Range.copyWith(tag: 'r1'),
        'A3:D5'.a1Range.copyWith(tag: 'r2'),
        'B2:E5'.a1Range.copyWith(tag: 'r3'),
        'E7:F9'.a1Range.copyWith(tag: 'r4'),
        'C4:F8'.a1Range.copyWith(tag: 'r5'),
      );
      final r2OverR1 = r1.overlayRanges([r2]);
      expect(r2OverR1, containsAll([r1, r2]));
      expect(r2OverR1.firstWhere((e) => e == r1).tag, equals('r1'));
      expect(r2OverR1.firstWhere((e) => e == r2).tag, equals('r2'));

      final r3OverR2OverR1 = r1.overlayRanges([r2, r3]);
      expect(
        r3OverR2OverR1,
        everyElement(isIn([
          'C1:D1'.a1Range,
          'B2:B2'.a1Range,
          'C2:D2'.a1Range,
          'A3:A5'.a1Range,
          'B3:D5'.a1Range,
          'E2:E5'.a1Range,
        ])),
      );
      expect(
        r3OverR2OverR1.firstWhere((e) => e == 'C1:D1'.a1Range).tag,
        equals('r1'),
      );
      expect(
        r3OverR2OverR1.firstWhere((e) => e == 'B2:B2'.a1Range).tag,
        equals('r3'),
      );
      expect(
        r3OverR2OverR1.firstWhere((e) => e == 'C2:D2'.a1Range).tag,
        everyElement(isIn(['r3', 'r1'])),
      );
      expect(
        r3OverR2OverR1.firstWhere((e) => e == 'A3:A5'.a1Range).tag,
        equals('r2'),
      );
      expect(
        r3OverR2OverR1.firstWhere((e) => e == 'B3:D5'.a1Range).tag,
        everyElement(isIn(['r3', 'r2'])),
      );
      expect(
        r3OverR2OverR1.firstWhere((e) => e == 'E2:E5'.a1Range).tag,
        equals('r3'),
      );

      expect(
        r1.overlayRanges([r2, r3, r4]),
        everyElement(isIn([
          'C1:D1'.a1Range,
          'B2:B2'.a1Range,
          'C2:D2'.a1Range,
          'A3:A5'.a1Range,
          'B3:D5'.a1Range,
          'E2:E5'.a1Range,
          'E7:F9'.a1Range,
        ])),
      );

      final r5r4r3r2r1 = r1.overlayRanges([r2, r3, r4, r5]);
      expect(
        r5r4r3r2r1,
        everyElement(isIn([
          'C1:D1'.a1Range,
          'A3:A5'.a1Range,
          'C2:D2'.a1Range,
          'B3:B5'.a1Range,
          'C3:D3'.a1Range,
          'B2:B2'.a1Range,
          'E2:E3'.a1Range,
          'E9:F9'.a1Range,
          'C4:D5'.a1Range,
          'E4:E5'.a1Range,
          'E7:F8'.a1Range,
          'F4:F6'.a1Range,
          'E6:E6'.a1Range,
          'C6:D8'.a1Range,
        ])),
      );
      expect(
        r5r4r3r2r1.firstWhere((e) => e == 'C4:D5'.a1Range).tag,
        everyElement(isIn(['r5', 'r3', 'r2'])),
      );
      expect(
        r5r4r3r2r1.firstWhere((e) => e == 'E6:E6'.a1Range).tag,
        equals('r5'),
      );
    });
  });

  group('A1Range has the correct partial rows and columns', () {
    final fromPartial1 = A1Range.parse('AAA:B2');
    final fromPartial2 = A1Range.parse('1:B2');
    final toPartial1 = A1Range.parse('A1:2');
    final toPartial2 = A1Range.parse('A1:B');

    test('valid from letters', () {
      expect(fromPartial1.to.letters, equals('AAA'));
      expect(fromPartial1.to.digits, isNull);
      expect(fromPartial2.from.letters, isNull);
      expect(fromPartial2.from.digits, equals(1));
      expect(fromPartial2.anchor, isNull);
    });
    test('valid to letters', () {
      expect(toPartial1.to.letters, isNull);
      expect(toPartial1.to.digits, equals(2));
      expect(toPartial2.to.letters, equals('B'));
      expect(toPartial2.to.digits, isNull);
    });

    test('valid hashcode', () {
      expect(fromPartial1.hashCode, equals(A1Range.parse('AAA:B2').hashCode));
      expect(
        A1Range.parse('A1:A1').hashCode,
        isNot(equals(A1Range.parse('B2:B2').hashCode)),
      );
    });
    test('valid toString', () {
      expect('A1:Z26'.a1Range.toString(), equals('A1:Z26'));
      expect('A1:Z'.a1Range.toString(), equals('A1:Z'));
      expect('A1'.a1Range.toString(), equals('A1'));
      expect('A'.a1Range.toString(), equals('A'));
    });
    test('valid area', () {
      expect('A1:Z26'.a1Range.area, equals(26 * 26));
      expect('A1:A1'.a1Range.area, equals(1));
      expect('A1:A2'.a1Range.area, equals(2));
      expect('A1:B2'.a1Range.area, equals(4));
    });
    test('contains', () {
      expect('A1:a6'.a1Range.contains('a2'.a1), isTrue);
      expect('A1:a6'.a1Range.contains('b2'.a1), isFalse);
      expect('A1:a1'.a1Range.contains('a2'.a1), isFalse);
      expect('1:a1'.a1Range.contains('a2'.a1), isFalse);
      expect('1:a3'.a1Range.contains('a2'.a1), isTrue);
      expect('a:a3'.a1Range.contains('a2'.a1), isTrue);

      // Some unparsables
      final a1 = A1Partial('A', 1);
      final a = A1Partial('A', null);
      final one = A1Partial(null, 1);
      final two = A1Partial(null, 2);
      final b = A1Partial('B', null);
      final null1 = A1Partial(null, null);

      expect(A1Range.fromPartials(a, b).contains('a2'.a1), isTrue);
      expect(A1Range.fromPartials(a1, b).contains('a2'.a1), isTrue);
      expect(A1Range.fromPartials(a1, null1).contains('a2'.a1), isTrue);
      expect(A1Range.fromPartials(a, one).contains('a2'.a1), isFalse);
      expect(A1Range.fromPartials(null1, one).contains('a2'.a1), isFalse);
      expect(A1Range.fromPartials(null1, one).contains('a1'.a1), isTrue);
      expect(A1Range.fromPartials(null1, null1).contains('a1'.a1), isTrue);
      expect(A1Range.fromPartials(null1, a1).contains('a2'.a1), isFalse);
      expect(A1Range.fromPartials(a1, one).contains('a2'.a1), isFalse);
      expect(A1Range.fromPartials(two, a).contains('a2'.a1), isTrue);

      expect('A'.a1Range.contains('a2'.a1), isTrue);
      expect('B'.a1Range.contains('a2'.a1), isFalse);
    });

    test('sorting', () {
      final list = [
        A1Range.all,
        'A1:B2'.a1Range,
        'A1:C3'.a1Range,
        'A:B'.a1Range,
        '1:2'.a1Range,
        'A:C'.a1Range
      ];
      list.sort();
      expect(
          list,
          containsAllInOrder([
            'A1:B2'.a1Range,
            'A1:C3'.a1Range,
            'A:B'.a1Range,
            '1:2'.a1Range,
            'A:C'.a1Range,
            A1Range.all,
          ]));
    });
  });

  group('Operators', () {
    test('comparison', () {
      expect('a1:b2'.a1Range.compareTo('a1:a2'.a1Range), equals(1));
      expect('b1:b2'.a1Range.compareTo('a1:a2'.a1Range), equals(0));

      expect('b2:a1'.a1Range.compareTo('a1:a2'.a1Range), equals(1));

      expect('a1:a'.a1Range.compareTo('b1:c3'.a1Range), equals(1));

      expect(A1Range.all.compareTo('a1:b2'.a1Range), equals(1));
      expect(A1Range.all.compareTo('a:b'.a1Range), equals(1));
      expect(A1Range.all.compareTo('1:2'.a1Range), equals(1));

      expect('b2:a1'.a1Range.compareTo('a1:a2'.a1Range), equals(1));
      expect('a1:a2'.a1Range.compareTo('b2:a1'.a1Range), equals(-1));

      final partial = A1Range.fromPartials(A1Partial('B', null), A1Partial.all);
      expect(partial.compareTo(partial), equals(0));
    });
  });

  group('Extensions', () {
    test('string to a1Range', () {
      final a1Range = 'Z26:A1'.a1Range;
      expect(a1Range.to.column, equals(25));
      expect(a1Range.to.row, equals(25));
      expect(a1Range.from.row, equals(0));
      expect(a1Range.from.row, equals(0));
    });
  });
}
