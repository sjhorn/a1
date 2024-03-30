// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Reference allows a cell or cell range to be referenced in another
// sheet/file/url
//
// Sheet1!A1:Z26 refers to the range in Sheet1.
// Sheet1 refers to all the cells in Sheet1.
// 'My Custom Sheet'!A1:Z26 refers to all the cells in the first column of a
// sheet named "My Custom Sheet." Single quotes are required for sheet
// names with spaces, special characters, or an alphanumeric combination.
// 'My Custom Sheet' refers to all the cells in 'My Custom Sheet'.
// 'C:\Documents and Settings\Username\My spreadsheets\[main sheet]Sheet1!A1:Z26 file reference on local file system
// 'C:\Documents and Settings\Username\My spreadsheets\[main sheet]Sheet1!A1:Z26 file reference on local file system

import 'package:petitparser/petitparser.dart';

import 'package:a1/a1.dart';
import 'package:a1/src/grammer/a1_notation.dart';

class A1Reference implements Comparable<A1Reference> {
  static final A1Notation _a1n = A1Notation();
  static final _parser = _a1n.build();

  final String? scheme;
  final String? authority;
  final String? username;
  final String? password;
  final String? host;
  final String? port;
  final String? path;
  final String? query;
  final String? fragment;
  final String? filename;
  final String? worksheet;
  final String? column;
  final String? column1;
  final int? row;
  final int? row1;
  final String? column2;
  final int? row2;

  /// Private contructor
  A1Reference._({
    this.scheme,
    this.authority,
    this.username,
    this.password,
    this.host,
    this.port,
    this.path,
    this.query,
    this.fragment,
    this.filename,
    this.worksheet,
    this.column,
    this.column1,
    this.row,
    this.row1,
    this.column2,
    this.row2,
  });

  /// Parses a string containing an A1Reference literal into an A1Reference.
  ///
  /// If that fails, too, it throws a [FormatException].
  ///
  /// Rather than throwing and immediately catching the [FormatException],
  /// instead use [tryParse] to handle a potential parsing error.
  ///
  /// Examples:
  /// ```dart
  /// A1Reference a1ref = A1Reference.parse("'c:\\path\\[file]Sheet'!A1:Z26"));
  /// ```
  static A1Reference parse(String input) {
    final result = tryParse(input);
    if (result == null) {
      throw FormatException('Invalid A1Reference notation $input', input, 0);
    }
    return result;
  }

  /// Parses a string containing an A1Reference literal into an A1Reference.
  ///
  /// Like [parse], except that this function returns `null` for invalid inputs
  /// instead of throwing.
  ///
  /// Examples:
  /// ```dart
  /// A1Reference? a1 = A1Reference.tryParse("'c:\\path\\[file]Sheet'!A1:Z26"));
  /// ```
  static A1Reference? tryParse(String input) {
    final result = _parser.parse(input);
    if (result is Failure) {
      return null;
    }
    final value = result.value;

    // leverage the range to ensure the values are reordered if needed
    final range = A1Range.fromPartials(
      A1Partial(
        value[#column1],
        value[#row1] is String ? int.parse(value[#row1]) : null,
      ),
      A1Partial(
        value[#column2],
        value[#row2] is String ? int.parse(value[#row2]) : null,
      ),
    );

    return A1Reference._(
      scheme: value[#scheme],
      authority: value[#authority],
      username: value[#username],
      password: value[#password],
      host: value[#host],
      port: value[#port],
      path: value[#path],
      query: value[#query],
      fragment: value[#fragment],
      filename: value[#filename],
      worksheet: value[#worksheet],
      column: range.from.letters,
      column1: range.from.letters,
      row: range.from.digits,
      row1: range.from.digits,
      column2: range.to.letters,
      row2: range.to.digits,
    );
  }

  /// return the from A1Partial
  A1Partial get from => A1Partial(column1, row1);

  /// return the to A1Partial
  A1Partial get to => A1Partial(column2, row2);

  /// return the A1Range
  A1Range get range => A1Range.fromPartials(from, to);

  /// return a Uri based on passed info without the filename
  Uri get uri => Uri(
      scheme: scheme,
      userInfo: username != null && username!.isNotEmpty
          ? '$username${password != null && password!.isNotEmpty ? ":$password" : ""}'
          : null,
      host: host != null && host!.isNotEmpty ? host : null,
      port: port != null && port!.isNotEmpty ? int.parse(port!) : null,
      path: path != null && path!.isNotEmpty ? path : null,
      //'$path${filename != null ? "/$filename" : ""}',
      query: query != null && query!.isNotEmpty ? query : null,
      fragment: fragment != null && fragment!.isNotEmpty ? fragment : null);

  /// return a Uri with the filename
  Uri get uriWithFilename =>
      uri.replace(path: '$path${filename != null ? "$filename" : ""}');

  /// If we are comparing two ranges in the same uris/filename/worksheet
  /// then defer to the A1Range comparison
  @override
  int compareTo(A1Reference other) {
    if (other.uri == uri && worksheet == other.worksheet) {
      return range.compareTo(other.range);
    }
    throw UnsupportedError('The area of the two references is not comparable');
  }

  /// Print an a1 reference in the expected format
  ///
  /// 'scheme://username:password@host:port/path/[filename]worksheet'!a1:b2
  ///
  @override
  String toString() {
    final reference = StringBuffer();

    reference.write(uri);
    //reference.write(path ?? '');
    reference.write(filename != null ? '[$filename]' : '');
    reference.write(worksheet != null ? '$worksheet' : '');

    final range = switch ((from.isAll, to.isAll)) {
      (false, false) => '$from:$to',
      (false, true) => '$from',
      _ => '',
    };

    return switch ((reference.isNotEmpty, range.isNotEmpty)) {
      (true, true) => "'$reference'!$range",
      (false, true) => range,
      (true, false) => "'$reference'",
      _ => '',
    };
  }
}

/// This extension allows an [A1Reference] to be create from a [String]
extension StringA1ReferenceExtension on String {
  /// Return an [A1Reference] from the current [String] or throw
  /// a [FormatException] see [A1Reference.parse].
  A1Reference get a1Ref => A1Reference.parse(this);

  /// Return an [A1Reference] from the current [String] or throw
  /// a [FormatException] see [A1Reference.parse].
  A1Reference get a1Reference => A1Reference.parse(this);
}
