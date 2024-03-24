import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group('Creating an A1Range', () {
    test('by parsing a string', () {
      final a1r = A1Range.parse('A1:B2');
      expect(a1r, isA<A1Range>());
      expect(a1r.from, equals('A1'.a1));
      expect(a1r.to, equals('B2'.a1));
      expect(a1r.from?.letters, equals('A'));
      expect(a1r.from?.digits, equals(1));
      expect(a1r.to?.letters, equals('B'));
      expect(a1r.to?.digits, equals(2));
    });

    test('throws when parsing an invalid string', () {
      expect(() => A1Range.parse('123:'), throwsA(isA<FormatException>()));
      expect(() => A1Range.parse('å1:a2'), throwsA(isA<FormatException>()));
      expect(() => A1Range.parse('aøa1:b2'), throwsA(isA<FormatException>()));
      expect(() => A1Range.parse('A1.1:b2'), throwsA(isA<FormatException>()));
    });

    test('by tryParsing a two valid A1 string', () {
      final a1r = A1Range.tryParse('ZZA123:a2');
      expect(a1r?.from, equals('ZZA123'.a1));
      expect(a1r?.to, equals('a2'.a1));
      expect(a1r, equals('ZZA123:a2'.a1Range));
    });

    test('returns null when tryParsing an invalid A1Range string', () {
      final result = A1Range.tryParse('123');
      expect(result, isNull);
    });
  });

  group('A1Range has the correct partial rows and columns', () {
    final fromPartial1 = A1Range.parse('AAA:B2');
    final fromPartial2 = A1Range.parse('1:B2');
    final toPartial1 = A1Range.parse('A1:2');
    final toPartial2 = A1Range.parse('A1:B');

    test('valid from letters', () {
      expect(fromPartial1.fromLetters, equals('AAA'));
      expect(fromPartial1.fromDigits, isNull);
      expect(fromPartial2.fromLetters, isNull);
      expect(fromPartial2.fromDigits, equals(1));
    });
    test('valid to letters', () {
      expect(toPartial1.toLetters, isNull);
      expect(toPartial1.toDigits, equals(2));
      expect(toPartial2.toLetters, equals('B'));
      expect(toPartial2.toDigits, isNull);
    });
  });

  // group('Operators', () {
  //   test('comparison', () {
  //     expect('a1'.a1.compareTo('a2'.a1), equals(-1));
  //     expect('a1'.a1.compareTo('b2'.a1), equals(-1));
  //     expect('a1'.a1.compareTo('b1'.a1), equals(-1));

  //     expect('z1'.a1.compareTo('a1'.a1), equals(1));
  //     expect('b1'.a1.compareTo('a1'.a1), equals(1));
  //     expect('a2'.a1.compareTo('b1'.a1), equals(1));

  //     expect('A1'.a1.compareTo('a1'.a1), equals(0));
  //     expect('a1'.a1.compareTo('a2'.a1.up), equals(0));
  //     expect(A1.fromVector(0, 0).compareTo('A1'.a1), equals(0));
  //   });

  // });

  group('Extensions', () {
    test('string to a1Range', () {
      final a1Range = 'Z26:A1'.a1Range;
      expect(a1Range.from?.column, equals(25));
      expect(a1Range.from?.row, equals(25));
      expect(a1Range.to?.row, equals(0));
      expect(a1Range.to?.row, equals(0));
    });
  });
}
