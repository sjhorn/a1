import 'package:petitparser/petitparser.dart';
import 'a1_uri.dart';

typedef SymbolMap = Map<Symbol, dynamic>;

class A1Notation extends GrammarDefinition<SymbolMap> {
  @override
  Parser<SymbolMap> start() => reference();

  // Reference allows a cell or cell range to be referenced in another
  // 'My Custom Sheet' refers to all the cells in 'My Custom Sheet'.
  Parser<SymbolMap> reference() => [
        uriReference(),
        filenameWithSheetReference(),
        worksheetReference(),
        range(),
      ].toChoiceParser();

  //'[Year budget.xlsx]Jan'!B2:B5
  //'[Sales.xlsx]Jan sales'!B2:B5
  // 'D:\Reports\[Sales.xlsx]Jan sales'!B2:B5
  // 'http://sharepoint.com/path1/path2/[Sales.xlsx]Jan sales'!B2:B5
  // 'C:\Users\sumit\Desktop\[Example File.xlsx]Sheet1'!$A$1
  // 'C:\Documents and Settings\Username\My spreadsheets\[main sheet.xls]Sheet1'!<A1RANGE> file reference on local file system
  // 'C:\Documents and Settings\Username\My spreadsheets\[main sheet.xlsx]Sheet1'!<A1RANGE> file reference on local file system
  // Windows / DOS file reference
  //
  Parser<SymbolMap> uriReference() => seq3(
        ref0(filePath),
        char('!'),
        ref0(range),
      ).map3((filePath1, _, range1) => {
            ...filePath1,
            ...range1,
          });

  Parser<SymbolMap> filePath() => seq4(
        ref0(quote),
        pattern('^[').plus().flatten('uri'),
        ref0(filenameWithSheet),
        ref0(quote),
      ).map4((q1, uriString, fileSheet, q2) {
        return {
          ...A1Uri().build().parse(uriString).value,
          ...fileSheet,
        };
      });

  //'[Year budget.xlsx]Jan'!B2:B5
  Parser<SymbolMap> filenameWithSheetReference() => seq5(
        ref0(quote),
        ref0(filenameWithSheet),
        ref0(quote),
        char('!'),
        ref0(range),
      ).map5(
        (q1, fws1, q2, _, range1) => {
          ...fws1,
          ...range1,
        },
      );

  Parser<SymbolMap> filenameWithSheet() => seq2(
        ref0(filename),
        ref1(worksheetName, "'"),
      ).map2((filename1, worksheet1) => {
            ...filename1,
            ...worksheet1,
          });

  Parser<SymbolMap> filename() =>
      seq3(char('['), pattern('^[]').plus().flatten('filename'), char(']'))
          .map3((_, filename, __) => {#filename: filename});

  // Sheet1!<A1RANGE> refers to the range in Sheet1.
  // Sheet1 refers to all the cells in Sheet1.
  // 'My Custom Sheet'!<A1RANGE> refers to all the cells in the first column of a
  // sheet named "My Custom Sheet." Single quotes are required for sheet
  // names with spaces, special characters, or an alphanumeric combination.
  Parser<SymbolMap> worksheetReference() =>
      seq3(ref0(worksheet), char('!'), ref0(range)).map3(
        (worksheet, _, range) => {
          ...worksheet,
          ...range,
        },
      );

  Parser<SymbolMap> worksheet() => [
        ref0(worksheetQuoted),
        ref0(worksheetName),
      ].toChoiceParser().map((worksheet1) => {...worksheet1});

  // If there are spaces the name must be wrapped in single quotes
  Parser<SymbolMap> worksheetQuoted() =>
      seq3(ref0(quote), ref1(worksheetName, "'"), ref0(quote))
          .map3((_, worksheet, __) => {...worksheet});

  // Worksheet must start with a non space/tab and
  // not have the [worksheetPattern] chars
  // it also is limited to between 1 and 31 chars
  Parser<SymbolMap> worksheetName([String extras = ' ']) => seq2(
          pattern('^\t\n $worksheetPattern'),
          pattern('^$worksheetPattern$extras').repeat(0, 30))
      .flatten('worksheet name')
      .map((value) => {#worksheet: value});

  // Invalid worksheet chars are :?*[]/\
  String worksheetPattern = '^:?*[]/\\';
  Parser<String> quote() => char("'");

  // Range types
  Parser<SymbolMap> range() => [
        ref0(a1Range),
        ref0(rowsTo),
        ref0(rowsFrom),
        ref0(rows),
        ref0(columnsTo),
        ref0(columnsFrom),
        ref0(column),
        ref0(row),
      ].toChoiceParser();

  // A1:B2 refers to the first two cells in the top two rows
  Parser<SymbolMap> a1Range() =>
      seq3(ref0(a1), ref0(separator), ref0(a1)).map3((a1, separator, a2) => {
            #column1: a1[#column]!,
            #row1: a1[#row]!,
            #separator: separator[#separator]!,
            #column2: a2[#column]!,
            #row2: a2[#row]!,
          });

  // 2:C3 refers to all the cells in row 2 and 3 up to column C
  Parser<SymbolMap> rowsTo() =>
      seq3(ref0(row), ref0(separator), ref0(a1)).map3((row1, separator, a2) => {
            #row1: row1[#row]!,
            #separator: separator[#separator]!,
            #column2: a2[#column]!,
            #row2: a2[#row]!,
          });

  // C1:2 refers to all the cells in row 1 and 2 start at column C
  Parser<SymbolMap> rowsFrom() =>
      seq3(ref0(a1), ref0(separator), ref0(row)).map3((a1, separator, row2) => {
            #column1: a1[#column]!,
            #row1: a1[#row]!,
            #separator: separator[#separator]!,
            #row2: row2[#row]!,
          });

  // 1:2 refers to all the cells in the first two rows of Sheet1.
  Parser<SymbolMap> rows() => seq3(ref0(row), ref0(separator), ref0(row))
      .map3((row1, separator, row2) => {
            #row1: row1[#row]!,
            #separator: separator[#separator]!,
            #row2: row2[#row]!,
          });

  // A:A5 refers to all the cells of the first column up to row 5
  Parser<SymbolMap> columnsTo() => seq3(ref0(column), ref0(separator), ref0(a1))
      .map3((column1, separator, a2) => {
            #column1: column1[#column]!,
            #separator: separator[#separator]!,
            #column2: a2[#column]!,
            #row2: a2[#row]!,
          });

  // A5:A refers to all the cells of the first column from row 5
  Parser<SymbolMap> columnsFrom() =>
      seq3(ref0(a1), ref0(separator), ref0(column))
          .map3((a1, separator, column2) => {
                #column1: a1[#column]!,
                #row1: a1[#row]!,
                #separator: separator[#separator]!,
                #column2: column2[#column]!,
              });

  // A:C refers to all the cells of the first column up to row 5
  Parser<SymbolMap> cols() => seq3(ref0(column), ref0(separator), ref0(column))
      .map3((column1, separator, column2) => {
            #column1: column1[#column]!,
            #seperator: separator[#separator]!,
            #column2: column2[#column]!
          });

  // Range separator either : or ...
  Parser<SymbolMap> separator() => [
        char(':', 'colon separator'),
        string('...', 'ellipsis separator'),
      ].toChoiceParser().map((value) => {#separator: value});

  // a1, AAZ123 complete A1
  Parser<SymbolMap> a1() => seq2(ref0(column), ref0(row))
      .map2((column, row) => {#column: column[#column]!, #row: row[#row]!});

  // any letter a-z or A-Z repeating
  Parser<SymbolMap> column() =>
      letter().plus().flatten('column').map((value) => {#column: value});

  // any number greater than 0
  Parser<SymbolMap> row() =>
      seq2(anyOf('123456789'), digit().star().flatten('row'))
          .flatten()
          .map((value) => {#row: value});
}
