// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:petitparser/petitparser.dart';

typedef SymbolMap = Map<Symbol, dynamic>;

class A1Notation extends GrammarDefinition<SymbolMap> {
  @override
  Parser<SymbolMap> start() => reference();

  // Reference allows a cell or cell range to be referenced in another
  //
  // These can come with full uri, or be simple the name eg:
  // http uri: 'https://sharepoint.com/path1/path2/[Sales.xlsx]Jan sales'!B2:B5
  // file uri using drive as scheme: 'D:\Reports\[Sales.xlsx]Jan sales'!B2:B5
  // file uri using file scheme: 'file:\D:\Reports\[Sales.xlsx]Jan sales'!B2:B5
  // worksheet: 'My Custom Sheet' refers to all the cells in 'My Custom Sheet'.
  Parser<SymbolMap> reference() => [
        uriReference(),
        filenameWithSheetReference(),
        worksheetReference(),
        range(),
      ].toChoiceParser();

  // URI reference for https, file, drive schemes etc.
  //
  // '[Year budget.xlsx]Jan'!B2:B5
  // '[Sales.xlsx]Jan sales'!B2:B5
  // 'D:\Reports\[Sales.xlsx]Jan sales'!B2:B5
  // 'https://sharepoint.com/path1/path2/[Sales.xlsx]Jan sales'!B2:B5
  // 'C:\Users\sumit\Desktop\[Example File.xlsx]Sheet1'!$A$1
  // 'C:\Documents and Settings\Username\My spreadsheets\[main sheet.xls]Sheet1'!A1:Z26 file reference on local file system
  // 'C:\Documents and Settings\Username\My spreadsheets\[main sheet.xlsx]Sheet1'!A1:Z26 file reference on local file system
  // Windows / DOS file reference
  //
  Parser<SymbolMap> uriReference() => seq2(
        ref0(filePath),
        ref0(bangRange).optional(),
      ).map2((filePath1, range1) => {
            ...filePath1,
            ...(range1 ?? {}),
          });

  // support the seperation of the file from the uri with the
  // square brackets [] wrapping the file
  //
  Parser<SymbolMap> filePath() => seq4(
        ref0(quote),
        pattern('^[').plus().flatten('uri'),
        ref0(filenameWithSheet),
        ref0(quote),
      ).map4((q1, uriString, fileSheet, q2) {
        final uri = Uri.parse(uriString);
        final userInfoParts = uri.userInfo.split(':');
        final username = userInfoParts[0];
        final password = userInfoParts.length == 2 ? userInfoParts[1] : '';

        return {
          ...uri.queryParameters
              .map((key, value) => MapEntry(Symbol(key), value)),
          //...A1Uri().build().parse(uriString).value,
          #scheme: uri.scheme,
          #authority: uri.authority,
          #username: username,
          #password: password,
          #host: uri.host,
          #port: '${uri.port}',
          #path: uri.path,
          #query: uri.query,
          #fragment: uri.fragment,
          ...fileSheet,
        };
      });

  // Quoted Squarebracket file with the worksheet
  //
  // eg. '[Year budget.xlsx]Jan'!B2:B5
  // eg. '[Year budget.xlsx]Jan'
  //
  Parser<SymbolMap> filenameWithSheetReference() => seq4(
        ref0(quote),
        ref0(filenameWithSheet),
        ref0(quote),
        ref0(bangRange).optional(),
      ).map4(
        (q1, fws1, q2, range1) => {
          ...fws1,
          ...(range1 ?? {}),
        },
      );

  // Filename with the worksheet name
  //
  // eg. [file name]worksheet
  //
  Parser<SymbolMap> filenameWithSheet() => seq2(
        ref0(filename),
        ref1(worksheetName, "'"),
      ).map2((filename1, worksheet1) => {
            ...filename1,
            ...worksheet1,
          });

  // Filename with square brackets []
  //
  Parser<SymbolMap> filename() =>
      seq3(char('['), pattern('^[]').plus().flatten('filename'), char(']'))
          .map3((_, filename, __) => {#filename: filename});

  // A worksheet reference includes Worksheet with range
  //
  // Examples:
  // Sheet1!A1:Z26 refers to the range in Sheet1.
  // Sheet1 refers to all the cells in Sheet1.
  // 'My Custom Sheet'!A1:Z26 refers to all the cells in the first column of a
  // sheet named "My Custom Sheet." Single quotes are required for sheet
  // names with spaces, special characters, or an alphanumeric combination.
  //
  Parser<SymbolMap> worksheetReference() =>
      seq2(ref0(worksheet), ref0(bangRange).optional()).map2(
        (worksheet, range) => {
          ...worksheet,
          ...(range ?? {}),
        },
      );

  // exclamation/bang ! a1range
  Parser<SymbolMap> bangRange() =>
      seq2(char('!'), ref0(range)).map2((_, range) => {...range});

  // A worksheet can be quote if there are spaces
  // or without spaces can be unquoted in some scenarios
  //
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
  String worksheetPattern = '^!:?*[]/\\';
  Parser<String> quote() => char("'");

  // Range types vary to allow specifying different rectangles
  //
  // Examples:
  // A1:B2 (or A1...B2) - simple range betwee column A, row 1 & column B, row 2
  // 2:C3 (or 2...C3) - includes all columns up to C between rows 2 and 3
  // C1:2 (or C1...2) - includes all columns starting at C between rows 1 and 2
  // C:E2 (or C...E2) - includes all rows up to 2 between columns C and E
  // C1:E (or C1...E) - includes all rows starting at 1 between columns C and E
  // A1 - everything beyond A1
  // A - all rows of colummn A
  // 23 - all columns of row 23
  Parser<SymbolMap> range() => [
        ref0(a1Range),
        ref0(rowsTo),
        ref0(rowsFrom),
        ref0(rows),
        ref0(columnsTo),
        ref0(columnsFrom),
        ref0(cols),
        ref0(a1),
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

  // A:C refers to all the cells of the first column up to column C
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
  Parser<SymbolMap> a1() =>
      seq2(ref0(column), ref0(row)).map2((column, row) => {
            #column: column[#column]!,
            #row: row[#row]!,
            #column1: column[#column]!,
            #row1: row[#row]!,
          });

  // any letter a-z or A-Z repeating
  Parser<SymbolMap> column() =>
      letter().plus().flatten('column').map((value) => {
            #column: value.toUpperCase(),
            #column1: value.toUpperCase(),
          });

  // any number greater than 0
  Parser<SymbolMap> row() =>
      seq2(anyOf('123456789'), digit().star().flatten('row'))
          .flatten()
          .map((value) => {#row: value, #row1: value});
}
