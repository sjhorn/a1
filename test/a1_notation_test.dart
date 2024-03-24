import 'package:a1/src/grammer/a1_notation.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final A1Notation a1 = A1Notation();
  group('A1 components ', () {
    test('column', () {
      final column = a1.buildFrom(a1.column()).end();
      expect(column.parse('ABC').value, containsPair(#column, 'ABC'));
      expect(() => column.parse('0A').value, throwsA(isA<ParserException>()));
      expect(() => column.parse('').value, throwsA(isA<ParserException>()));
      expect(() => column.parse('A12').value, throwsA(isA<ParserException>()));
      expect(() => column.parse('12A').value, throwsA(isA<ParserException>()));
      expect(() => column.parse(':').value, throwsA(isA<ParserException>()));
    });

    test('row', () {
      final row = a1.buildFrom(a1.row()).end();
      expect(row.parse('123').value, containsPair(#row, '123'));
      expect(() => row.parse('01').value, throwsA(isA<ParserException>()));
      expect(() => row.parse('').value, throwsA(isA<ParserException>()));
      expect(() => row.parse('A12').value, throwsA(isA<ParserException>()));
      expect(() => row.parse('12A').value, throwsA(isA<ParserException>()));
      expect(() => row.parse(':').value, throwsA(isA<ParserException>()));
    });

    test('a1', () {
      final a1p = a1.buildFrom(a1.a1()).end();
      var result = a1p.parse('abc123').value;
      expect(result, containsPair(#row, '123'));
      expect(result, containsPair(#column, 'abc'));
      expect(() => a1p.parse('a01').value, throwsA(isA<ParserException>()));
      expect(() => a1p.parse('').value, throwsA(isA<ParserException>()));
      expect(() => a1p.parse('12A').value, throwsA(isA<ParserException>()));
      expect(() => a1p.parse(':').value, throwsA(isA<ParserException>()));
    });

    test('cols', () {
      final cols = a1.buildFrom(a1.cols()).end();
      var result = cols.parse('AA:ZZ').value;
      expect(result, containsPair(#column1, 'AA'));
      expect(result, containsPair(#column2, 'ZZ'));
      result = cols.parse('ZZ...CC').value;
      expect(result, containsPair(#column1, 'ZZ'));
      expect(result, containsPair(#column2, 'CC'));
      expect(() => cols.parse('ZZ:').value, throwsA(isA<ParserException>()));
      expect(() => cols.parse('').value, throwsA(isA<ParserException>()));
      expect(
          () => cols.parse('AA:ZZ:CC').value, throwsA(isA<ParserException>()));
      expect(() => cols.parse(':').value, throwsA(isA<ParserException>()));
      expect(() => cols.parse('...').value, throwsA(isA<ParserException>()));
      expect(() => cols.parse('..').value, throwsA(isA<ParserException>()));
      expect(() => cols.parse('.').value, throwsA(isA<ParserException>()));
    });
    test('rows', () {
      final rows = a1.buildFrom(a1.rows()).end();
      var result = rows.parse('12:34').value;
      expect(result, containsPair(#row1, '12'));
      expect(result, containsPair(#row2, '34'));
      expect(result, containsPair(#separator, ':'));
      result = rows.parse('345...12').value;
      expect(result, containsPair(#row1, '345'));
      expect(result, containsPair(#row2, '12'));
      expect(result, containsPair(#separator, '...'));
      expect(() => rows.parse('12:').value, throwsA(isA<ParserException>()));
      expect(() => rows.parse('').value, throwsA(isA<ParserException>()));
      expect(
          () => rows.parse('12:11:2').value, throwsA(isA<ParserException>()));
      expect(() => rows.parse(':').value, throwsA(isA<ParserException>()));
      expect(() => rows.parse('...').value, throwsA(isA<ParserException>()));
      expect(() => rows.parse('..').value, throwsA(isA<ParserException>()));
      expect(() => rows.parse('.').value, throwsA(isA<ParserException>()));
    });
    test('columns from', () {
      final columnsFrom = a1.buildFrom(a1.columnsFrom()).end();
      var result = columnsFrom.parse('A5:A').value;
      expect(result, containsPair(#column1, 'A'));
      expect(result, containsPair(#row1, '5'));
      expect(result, containsPair(#column2, 'A'));
      expect(result[#row2], isNull);
      expect(result, containsPair(#separator, ':'));
      result = columnsFrom.parse('CAD12...A').value;
      expect(result, containsPair(#column1, 'CAD'));
      expect(result, containsPair(#row1, '12'));
      expect(result, containsPair(#column2, 'A'));
      expect(result[#row2], isNull);
      expect(result, containsPair(#separator, '...'));
    });
    test('columns to', () {
      final columnsTo = a1.buildFrom(a1.columnsTo()).end();
      var result = columnsTo.parse('C:C5').value;
      expect(result, containsPair(#column1, 'C'));
      expect(result[#row1], isNull);
      expect(result, containsPair(#column2, 'C'));
      expect(result, containsPair(#row2, '5'));
      expect(result, containsPair(#separator, ':'));
    });
    test('rows from', () {
      final rowsFrom = a1.buildFrom(a1.rowsFrom()).end();
      var result = rowsFrom.parse('C1:2').value;
      expect(result, containsPair(#column1, 'C'));
      expect(result, containsPair(#row1, '1'));
      expect(result[#column2], isNull);
      expect(result, containsPair(#row2, '2'));
      expect(result, containsPair(#separator, ':'));
    });
    test('rows to', () {
      final rowsTo = a1.buildFrom(a1.rowsTo()).end();
      var result = rowsTo.parse('4...C5').value;
      expect(result[#column1], isNull);
      expect(result, containsPair(#row1, '4'));
      expect(result, containsPair(#column2, 'C'));
      expect(result, containsPair(#row2, '5'));
      expect(result, containsPair(#separator, '...'));
    });
    test('a1 a2 range', () {
      final a1Range = a1.buildFrom(a1.a1Range()).end();
      var result = a1Range.parse('A43:Z65').value;
      expect(result, containsPair(#column1, 'A'));
      expect(result, containsPair(#row1, '43'));
      expect(result, containsPair(#column2, 'Z'));
      expect(result, containsPair(#row2, '65'));
      expect(result, containsPair(#separator, ':'));

      expect(
          () => a1Range.parse(':Z65').value, throwsA(isA<ParserException>()));
      expect(
          () => a1Range.parse('A43:').value, throwsA(isA<ParserException>()));
    });

    test('worksheet name', () {
      final worksheet = a1.buildFrom(a1.worksheetName()).end();
      final result = worksheet.parse('filename').value;
      expect(result, containsPair(#worksheet, 'filename'));

      // Larger than 31 chars
      expect(
        () => worksheet.parse(List.filled(32, 'a').join('')).value,
        throwsA(isA<ParserException>()),
      );

      // invalid character :?*[]/\
      for (var test in '?*[]/\\'.split('')) {
        expect(
          () => worksheet.parse('test${test}two').value,
          throwsA(isA<ParserException>()),
        );
      }
    });
    test('worksheet name with spaces', () {
      final worksheet = a1.buildFrom(a1.worksheet()).end();
      final result = worksheet.parse("'file name'").value;
      expect(result, containsPair(#worksheet, 'file name'));

      // unquoted should faile
      expect(
        () => worksheet.parse("file name").value,
        throwsA(isA<ParserException>()),
      );
    });
    test('worksheet reference', () {
      final worksheet = a1.buildFrom(a1.worksheetReference()).end();
      final result = worksheet.parse("'Jan'!B2:B5").value;
      expect(result, containsPair(#worksheet, 'Jan'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
    test('filename', () {
      final filename = a1.buildFrom(a1.filename()).end();
      final result = filename.parse("[file name]").value;
      expect(result, containsPair(#filename, 'file name'));

      // unbalanced square brackets should faile
      expect(
        () => filename.parse("file name").value,
        throwsA(isA<ParserException>()),
      );
      expect(
        () => filename.parse("[file name").value,
        throwsA(isA<ParserException>()),
      );
      expect(
        () => filename.parse("file name]").value,
        throwsA(isA<ParserException>()),
      );
    });

    test('filename with sheet reference', () {
      final fwsRef = a1.buildFrom(a1.filenameWithSheetReference()).end();
      final result = fwsRef.parse("'[file name]Jan'!B2:B5").value;
      expect(result, containsPair(#filename, 'file name'));
      expect(result, containsPair(#worksheet, 'Jan'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
  });

  group('A1 part composition  ', () {
    test('filename with sheet', () {
      final fsheetP = a1.buildFrom(a1.filenameWithSheet()).end();
      final result = fsheetP.parse("[Sales.xlsx]Jan Sales").value;

      expect(result, containsPair(#filename, 'Sales.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan Sales'));
    });
    test('file path', () {
      final filePathP = a1.buildFrom(a1.filePath()).end();
      final result = filePathP
          .parse("'http://sharepoint.com/path1/path2/[Sales.xlsx]Jan sales'")
          .value;

      expect(result, containsPair(#hostname, 'sharepoint.com'));
      expect(result, containsPair(#filename, 'Sales.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan sales'));
    });

    test('uri reference', () {
      final uriP = a1.buildFrom(a1.uriReference()).end();
      final result = uriP
          .parse(
              "'http://sharepoint.com/path1/path2/[Sales.xlsx]Jan sales'!B2:B5")
          .value;

      expect(result, containsPair(#hostname, 'sharepoint.com'));
      expect(result, containsPair(#filename, 'Sales.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan sales'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
  });
  group('Uri types', () {
    test('file uri', () {
      final a1P = a1.build();
      final result = a1P.parse("'[Year budget.xlsx]Jan'!B2:B5").value;

      expect(result, containsPair(#filename, 'Year budget.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
    test('file uri with filename space', () {
      final a1P = a1.build();
      final result = a1P.parse("'[Year budget.xlsx]Jan sales'!B2:B5").value;

      expect(result, containsPair(#filename, 'Year budget.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan sales'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
    test('file uri with windows local drive', () {
      final a1P = a1.build();
      final result =
          a1P.parse("'D:\\Reports\\[Sales.xlsx]Jan sales'!B2:B5").value;

      expect(result, containsPair(#scheme, 'D'));
      expect(result, containsPair(#path, '\\Reports\\'));
      expect(result, containsPair(#filename, 'Sales.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan sales'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
    test('http uri ', () {
      final a1P = a1.build();
      final result = a1P
          .parse(
              "'http://sharepoint.com/path1/path2/[Sales.xlsx]Jan sales'!B2:B5")
          .value;

      expect(result, containsPair(#scheme, 'http'));
      expect(result, containsPair(#hostname, 'sharepoint.com'));
      expect(result, containsPair(#path, '/path1/path2/'));
      expect(result, containsPair(#filename, 'Sales.xlsx'));
      expect(result, containsPair(#worksheet, 'Jan sales'));
      expect(result, containsPair(#column1, 'B'));
      expect(result, containsPair(#row1, '2'));
      expect(result, containsPair(#column2, 'B'));
      expect(result, containsPair(#row2, '5'));
    });
  });
}
