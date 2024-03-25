import 'package:a1/a1.dart';
import 'package:a1/src/a1_partial.dart';
import 'package:test/test.dart';

void main() {
  group('Creating an A1Range', () {
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
    });
    test('valid to letters', () {
      expect(toPartial1.to.letters, isNull);
      expect(toPartial1.to.digits, equals(2));
      expect(toPartial2.to.letters, equals('B'));
      expect(toPartial2.to.digits, isNull);
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
