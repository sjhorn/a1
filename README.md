# A1 Notation Package

This package implements a set of A1 types to assist with the use of A1 Notation used in spreadsheets and worksheets. 

The screenshot below shows the user interface presenting the A1 notation in the rows and columns.

![A1 Spreadsheet User Interface](https://raw.githubusercontent.com/sjhorn/a1/main/assets/worksheet.png)

From [wikipedia](https://en.wikipedia.org/wiki/Spreadsheet#) 

> A spreadsheet consists of a table of cells arranged into rows and columns and referred to by the X and Y locations. X locations, the columns, are normally represented by letters, "A," "B," "C," etc., while rows are normally represented by numbers, 1, 2, 3, etc. 
>
> A single cell can be referred to by addressing its row and column, "C10". This electronic concept of cell references was first introduced in LANPAR (Language for Programming Arrays at Random) (co-invented by Rene Pardo and Remy Landau) and a variant used in VisiCalc and known as "A1 notation".

## Features

 - [A1](a1/A1-class.html) class for parsing string to rows and columns and reverse eg. `A1`
 - [A1Partial](a1/A1Partial-class.html) class for representing who columsn, rows or the whole spreadsheet eg. `A`, `1`, ``
 - [A1Range](a1/A1Range-class.html) class for select all cells between two ranges `A1:ZZ123`
 - [A1Reference](a1/A1Reference-class.html) class for referencing cells in a another worksheet or spreadsheet `'C:\Documents and Settings\Username\My spreadsheets\[main sheet]Sheet1'!A1`

## Getting started

Simple usage examples below:

```dart
  // Using the class
  var a1 = A1.parse('A1');

  print(a1); // A1
  print(a1.column); // 0
  print(a1.row); // 0

  // Using the extensions
  print('b2'.a1); // A1
  print('b2'.a1.column); // 1
  print('b2'.a1.row); // 1

  // List of a1s
  print(['a1', 'b2', 'C3', 'z4'].a1); 
  // List of A1 Classs A1,B2,C3,Z4

  print(['a1', 'b2', 'C3', 'z4'].a1.map((a1) => a1.column));
  // [0, 2, 3, 26]


  a1 = A1.parse('B234');
  print('The A1 $a1 has a column of ${a1.column} and row of ${a1.row}');
  // The A1 B234 has a column of 1 and row of 233

  print('The A1 above is ${a1.up}'); // B233
  print('The A1 left is ${a1.left}'); // A233
  print('The A1 right is ${a1.right}'); // B234
  print('The A1 below is ${a1.down}'); // C233

```
The `test/` directory explores other use cases for the A1 types and library.

## Usage

The code above is available in the `example/a1_example.dart`

## Reference

* The [a1 logo](https://raw.githubusercontent.com/sjhorn/a1/main/assets/a1.svg) was created using [inkscape](https://inkscape.org/) with simple shapes and the sans font on mac and a square shape with the top left point removed to echo the 'table select' in spreadsheets. The 1 overlaps the A slightly with slight transparency in a similar manner to the flutter and dart logos.