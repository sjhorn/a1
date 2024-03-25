// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Reference allows a cell or cell range to be referenced in another
// sheet/file/url
//
// Sheet1!<A1RANGE> refers to the range in Sheet1.
// Sheet1 refers to all the cells in Sheet1.
// 'My Custom Sheet'!<A1RANGE> refers to all the cells in the first column of a
// sheet named "My Custom Sheet." Single quotes are required for sheet
// names with spaces, special characters, or an alphanumeric combination.
// 'My Custom Sheet' refers to all the cells in 'My Custom Sheet'.
// 'C:\Documents and Settings\Username\My spreadsheets\[main sheet]Sheet1!<A1RANGE> file reference on local file system
// 'C:\Documents and Settings\Username\My spreadsheets\[main sheet]Sheet1!<A1RANGE> file reference on local file system

import 'package:petitparser/petitparser.dart';

import 'package:a1/a1.dart';
import 'package:a1/src/grammer/a1_notation.dart';

class A1Reference implements Comparable<A1Reference> {
  static final A1Notation _a1n = A1Notation();
  static final _parser = _a1n.buildFrom(_a1n.range()).end();

  // expect(result, containsPair(#scheme, 'd'));
  //     expect(result, containsPair(#path, '/Reports/2024/Jan/'));
  //     expect(result, containsPair(#filename, 'Sales.xlsx'));
  //     expect(result, containsPair(#worksheet, 'Jan sales'));
  //     expect(result, containsPair(#column1, 'B'));
  //     expect(result, containsPair(#row1, '2'));
  //     expect(result, containsPair(#column2, 'B'));
  //     expect(result, containsPair(#row2, '5'));

  @override
  int compareTo(A1Reference other) {
    // TODO: implement compareTo
    throw UnimplementedError();
  }
}
