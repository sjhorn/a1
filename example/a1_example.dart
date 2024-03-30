import 'package:a1/a1.dart';

void main() {
  // Using the A1 class
  var a1 = A1.parse('A1');

  print(a1); // A1
  print(a1.column); // 0
  print(a1.row); // 0

  // Using the extensions
  print('b2'.a1); // A1
  print('b2'.a1.column); // 1
  print('b2'.a1.row); // 1

  // List of a1s
  print(['a1', 'b2', 'C3', 'z4'].a1); // List of A1 Classs A1,B2,C3,Z4

  print(['a1', 'b2', 'C3', 'z4'].a1.map((a1) => a1.column));
  // [0, 2, 3, 26]

  a1 = A1.parse('B234');
  print('The A1 $a1 has a column of ${a1.column} and row of ${a1.row}');
  // The A1 B234 has a column of 1 and row of 233

  print('The A1 above is ${a1.up}'); // B233
  print('The A1 left is ${a1.left}'); // A233
  print('The A1 right is ${a1.right}'); // B234
  print('The A1 below is ${a1.down}'); // C233

  // Using the A1Range class
  var a1Range = A1Range.parse('A1:Z26');

  print(a1Range); // A1:Z26
  print(a1Range.area); // 625.0 ie. 25 cells x 25 cells

  a1Range = 'A1:B'.a1Range; // String extension with cell:column range
  print(a1Range); // A1:B
  print(a1Range.area); // Infinity

  // Using the A1Reference class
  var a1Ref = A1Reference.parse("'c:\\path\\[file]Sheet'!A1:Z26");
  print(a1Ref); // 'c:/path/[file]Sheet'!A1:Z26
  print(a1Ref.worksheet); // Sheet
  print(a1Ref.filename); // file
  print(a1Ref.path); // /path/
  print(a1Ref.range); // A1:Z26
  print(a1Ref.range.to); // Z26

  a1Ref = "'https://sharepoint.com/path/[Book1.xlsx]Sheet1'!A1:Z26".a1Ref;
  print(a1Ref); // 'https://sharepoint.com/path/[Book1.xlsx]Sheet1'!A1:Z26
  print(a1Ref.worksheet); // Sheet1
  print(a1Ref.filename); // Book1.xlsx
  print(a1Ref.path); // /path/
  print(a1Ref.range); // A1:Z26
  print(a1Ref.range.from); // A1
}
