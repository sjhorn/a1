import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group('Creating an A1', () {
    test('by parsing a string', () {
      final a1 = A1.parse('SZA123');
      expect(a1, isA<A1>());
      expect(a1.column, equals(13520));
      expect(a1.row, equals(122));
      expect(a1.self, equals(a1));
    });

    test('throws when parsing an invalid string', () {
      expect(() => A1.parse('123'), throwsA(isA<FormatException>()));
      expect(() => A1.parse('å1'), throwsA(isA<FormatException>()));
      expect(() => A1.parse('aøa1'), throwsA(isA<FormatException>()));
      expect(() => A1.parse('A1.1'), throwsA(isA<FormatException>()));
    });

    test('by tryParsing a valid A1 string', () {
      final a1 = A1.tryParse('SZA123');
      expect(a1, equals(A1.parse('SZA123')));

      // test bigger than A1.maxColumns
      expect(() => A1.tryParse('ZZA123'), throwsA(isA<FormatException>()));
      // test digits bigger than A1.maxRows + 2
      expect(() => A1.tryParse('A1048578'), throwsA(isA<FormatException>()));
    });

    test('returns null when tryParsing invalid A1 string', () {
      final result = A1.tryParse('123');
      expect(result, isNull);
    });

    test('from a vector', () {
      final a1 = A1.fromVector(25, 2);
      expect(a1, isA<A1>());
      expect(a1.column, equals(25));
      expect(a1.row, equals(2));
      expect(a1.toString(), equals('Z3'));
      expect(() => A1.fromVector(1, -1), throwsA(isA<FormatException>()));
    });

    test('throws from an invalid vector', () {
      expect(() => A1.fromVector(-1, 2), throwsA(isA<FormatException>()));
    });

    test('maxRows and maxColumns constants', () {
      expect(A1.maxRows, equals(1048576));
      expect(A1.maxColumns, equals(16384));
    });

    test('rejects column exceeding maxColumns', () {
      expect(
          () => A1.fromVector(A1.maxColumns + 1, 0),
          throwsA(isA<FormatException>()));
    });

    test('rejects row exceeding maxRows', () {
      expect(
          () => A1.fromVector(0, A1.maxRows + 1),
          throwsA(isA<FormatException>()));
    });
  });

  group('A1 has the correct row and column', () {
    final fromString = A1.parse('AAA1');
    final fromVector = A1.fromVector(702, 0);

    test('valid column', () {
      expect(fromVector.column, equals(fromString.column));
      expect(fromString.column, equals(702));
    });
    test('valid row', () {
      expect(fromVector.row, equals(fromString.row));
      expect(fromString.row, 0);
    });

    test('valid vector', () {
      expect(fromString.vector, equals((702, 0)));
      expect(fromVector.vector, equals((702, 0)));
    });
    test('valid hashCode', () {
      expect(fromString.hashCode, fromVector.hashCode);
    });

    test('< and <=', () {
      expect('A1'.a1 < 'A2'.a1, isTrue);
      expect('A1'.a1 <= 'A1'.a1, isTrue);
      expect('A1'.a1 < 'Z26'.a1, isTrue);
    });
    test('> and >=', () {
      expect('Z26'.a1 > 'C1'.a1, isTrue);
      expect('Z26'.a1 >= 'Z1'.a1, isTrue);
      expect('D21'.a1 > 'Z1'.a1, isFalse);
    });
  });
  group('Move to adjacent cells', () {
    final a1 = A1.parse('B2');

    test('move left', () {
      final moved = a1.left;
      expect(moved.column, equals(0));
      expect(moved.row, equals(1));

      // can't move further left beyond A2
      expect(moved.left, equals(moved));
    });

    test('move right', () {
      final moved = a1.right;
      expect(moved.column, equals(2));
      expect(moved.row, equals(1));
    });

    test('move up', () {
      final moved = a1.up;
      expect(moved.column, equals(1));
      expect(moved.row, equals(0));

      // can't move up form B1
      expect(moved.up, equals(moved));
    });

    test('move down', () {
      final moved = a1.down;
      expect(moved.column, equals(1));
      expect(moved.row, equals(2));
    });

    test('page up', () {
      var moved = a1.pageUp(4);
      expect(moved.column, equals(1));
      expect(moved.row, equals(0));

      moved = 'a10'.a1.pageUp(4);
      expect(moved.column, equals(0));
      expect(moved.row, equals(5));
    });
    test('page down', () {
      var moved = A1.fromVector(0, A1.maxRows).pageDown(4);
      expect(moved.column, equals(0));
      expect(moved.row, equals(A1.maxRows));

      moved = 'a10'.a1.pageDown(4);
      expect(moved.column, equals(0));
      expect(moved.row, equals(13));
    });
  });

  group('Operators', () {
    test('comparison', () {
      expect('a1'.a1.compareTo('a2'.a1), equals(-1));
      expect('a1'.a1.compareTo('b2'.a1), equals(-1));
      expect('a1'.a1.compareTo('b1'.a1), equals(-1));

      expect('z1'.a1.compareTo('a1'.a1), equals(1));
      expect('b1'.a1.compareTo('a1'.a1), equals(1));
      expect('a2'.a1.compareTo('b1'.a1), equals(-1));

      expect('A1'.a1.compareTo('a1'.a1), equals(0));
      expect('a1'.a1.compareTo('a2'.a1.up), equals(0));
      expect(A1.fromVector(0, 0).compareTo('A1'.a1), equals(0));
    });
    test('addition', () {
      expect('a1'.a1 + 'a1'.a1, equals('a1'.a1)); // 0,0 + 0,0
      expect('b1'.a1 + 'b1'.a1, equals('c1'.a1)); // 1,0 + 1,0
      expect('c2'.a1 + 'c2'.a1, equals('e3'.a1)); // 2,1 + 2,1 = 4,2
    });

    test('rangeTo list', () {
      expect('a1'.a1.rangeTo('a3'.a1),
          containsAllInOrder('a1,a2,a3'.split(',').a1));
      expect(
          'a1'.a1.rangeTo('b1'.a1), containsAllInOrder('a1,b1'.split(',').a1));
      expect('a1'.a1.rangeTo('c3'.a1),
          containsAllInOrder('a1,a2,a3,b1,b2,b3,c1,c2,c3'.split(',').a1));
    });
  });

  group('Extensions', () {
    test('string to a1', () {
      final a1 = 'Z26'.a1;
      expect(a1.column, equals(25));
      expect(a1.row, equals(25));
    });

    test('string list to a1 list', () {
      final a1List = ['a1', 'B2', 'c3'].a1.toList();
      expect(a1List[0], equals('a1'.a1));
      expect(a1List[1], equals('B2'.a1));
      expect(a1List[2], equals('c3'.a1));
    });

    test('string set to a1 set', () {
      final a1Set = {'a1', 'B2', 'c3'}.a1;
      expect(a1Set, containsAll({'a1'.a1, 'B2'.a1, 'c3'.a1}));
    });
    test('Map of String:String strings to Map of A1:A1s', () {
      final moves = {'a1': 'd1', 'B2': 'c3'}.a1;
      expect(moves, containsPair('A1'.a1, 'D1'.a1));
      expect(moves, containsPair('B2'.a1, 'C3'.a1));
    });
    test('isLetter', () {
      expect('A'.codeUnits.first.isA1Letter, isTrue);
      expect('@'.codeUnits.first.isA1Letter, isFalse);
    });
    test('isDigit', () {
      expect('A'.codeUnits.first.isA1Digit, isFalse);
      expect('2'.codeUnits.first.isA1Digit, isTrue);
    });
  });

  group('Absolute references', () {
    test('parse \$A\$1', () {
      final a1 = A1.parse('\$A\$1');
      expect(a1.column, equals(0));
      expect(a1.row, equals(0));
      expect(a1.columnAbsolute, isTrue);
      expect(a1.rowAbsolute, isTrue);
      expect(a1.toString(), equals('\$A\$1'));
    });

    test('parse \$A1', () {
      final a1 = A1.parse('\$A1');
      expect(a1.columnAbsolute, isTrue);
      expect(a1.rowAbsolute, isFalse);
      expect(a1.toString(), equals('\$A1'));
    });

    test('parse A\$1', () {
      final a1 = A1.parse('A\$1');
      expect(a1.columnAbsolute, isFalse);
      expect(a1.rowAbsolute, isTrue);
      expect(a1.toString(), equals('A\$1'));
    });

    test('parse A1 (default relative)', () {
      final a1 = A1.parse('A1');
      expect(a1.columnAbsolute, isFalse);
      expect(a1.rowAbsolute, isFalse);
      expect(a1.toString(), equals('A1'));
    });

    test('equality ignores absolute state', () {
      expect(A1.parse('\$A\$1'), equals(A1.parse('A1')));
      expect(A1.parse('\$A1'), equals(A1.parse('A\$1')));
    });

    test('hashCode ignores absolute state', () {
      expect(A1.parse('\$A\$1').hashCode, equals(A1.parse('A1').hashCode));
    });

    test('round-trip toString', () {
      expect(A1.parse('\$A\$1').toString(), equals('\$A\$1'));
      expect(A1.parse('\$Z\$26').toString(), equals('\$Z\$26'));
      expect(A1.parse('A\$1').toString(), equals('A\$1'));
      expect(A1.parse('\$A1').toString(), equals('\$A1'));
    });

    test('copyWith absolute flags', () {
      final a1 = A1.parse('A1');
      final abs = a1.copyWith(columnAbsolute: true, rowAbsolute: true);
      expect(abs.toString(), equals('\$A\$1'));
      expect(abs, equals(a1));
    });

    test('fromVector with absolute flags', () {
      final a1 = A1.fromVector(0, 0, columnAbsolute: true, rowAbsolute: true);
      expect(a1.toString(), equals('\$A\$1'));
    });

    test('string extension with dollar', () {
      final a1 = '\$B\$2'.a1;
      expect(a1.column, equals(1));
      expect(a1.row, equals(1));
      expect(a1.columnAbsolute, isTrue);
      expect(a1.rowAbsolute, isTrue);
    });
  });
}
