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
          ]));

      final partial = A1Range.fromPartials(A1Partial('A', null), A1Partial.all);
      expect(
          () => partial.compareTo(partial), throwsA(isA<UnsupportedError>()));
    });
  });

  group('Operators', () {
    test('comparison', () {
      expect('a1:b2'.a1Range.compareTo('a1:a2'.a1Range), equals(1));
      expect('b1:b2'.a1Range.compareTo('a1:a2'.a1Range), equals(0));

      expect('b2:a1'.a1Range.compareTo('a1:a2'.a1Range), equals(1));

      expect(
        () => 'a1:a'.a1Range.compareTo('b1:c3'.a1Range),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => '1:a2'.a1Range.compareTo('b1:c3'.a1Range),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => 'a1:a2'.a1Range.compareTo('b1:c'.a1Range),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => 'a1:a2'.a1Range.compareTo('b1:2'.a1Range),
        throwsA(isA<UnsupportedError>()),
      );
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
