/// A1 Notation
///
/// The simplest form refers to a single cell with column letter and a row
/// number. eg. A1.
///
/// A typical cell reference in "A1" style consists of one or two
/// case-insensitive letters to identify the column (if there are up to 256
/// columns: A–Z and AA–IV) followed by a row number (e.g., in the range
/// 1–65536). Either part can be relative (it changes when the formula
/// it is in is moved or copied), or absolute (indicated with $ in front of
/// the part concerned of the cell reference).
///
/// The alternative "R1C1" reference style consists of the letter R,
/// the row number, the letter C, and the column number; relative row or
/// column numbers are indicated by enclosing the number in square brackets.
/// Most current spreadsheets use the A1 style, some providing the R1C1 style
/// as a compatibility option.
///
/// **See also:**
/// * [Spreadsheet on Wikipedia](https://en.wikipedia.org/wiki/Spreadsheet#)
/// * [A1..explained](https://bettersolutions.com/excel/formulas/cell-references-a1-r1c1-notation.htm)
/// * [Google Sheets ](https://developers.google.com/sheets/api/guides/concepts)

library;

export 'src/a1.dart';
export 'src/a1_partial.dart';
export 'src/a1_range.dart';
export 'src/a1_reference.dart';
