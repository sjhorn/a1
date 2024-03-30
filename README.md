# A1 Notation Package
[![Pub Package](https://img.shields.io/pub/v/a1.svg)](https://pub.dev/packages/a1)
[![Build Status](https://github.com/sjhorn/a1/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/sjhorn/a1/actions)
[![codecov](https://codecov.io/gh/sjhorn/a1/graph/badge.svg?token=O8MCNXGB6A)](https://codecov.io/gh/sjhorn/a1)
[![GitHub Issues](https://img.shields.io/github/issues/sjhorn/a1.svg)](https://github.com/sjhorn/a1/issues)
[![GitHub Forks](https://img.shields.io/github/forks/sjhorn/a1.svg)](https://github.com/sjhorn/a1/network)
[![GitHub Stars](https://img.shields.io/github/stars/sjhorn/a1.svg)](https://github.com/sjhorn/a1/stargazers)
![GitHub License](https://img.shields.io/github/license/sjhorn/a1)

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

```
The `test/` directory explores other use cases for the A1 types and library.

## Usage

The code above is available in the `example/a1_example.dart`

## Reference

* The [a1 logo](https://raw.githubusercontent.com/sjhorn/a1/main/assets/a1.svg) was created using [inkscape](https://inkscape.org/) with simple shapes and the sans font on mac and a square shape with the top left point removed to echo the 'table select' in spreadsheets. The 1 overlaps the A slightly with slight transparency in a similar manner to the flutter and dart logos.
* The parsing depends on the great library [petitparser](https://pub.dev/packages/petitparser) by Lukas Renggli.