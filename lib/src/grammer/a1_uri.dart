// Copyright (c) 2024, Scott Horn.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// Based on petitparser examples
// from https://github.com/petitparser/dart-petitparser-examples
// which in turn are based on RFC-3986.
//
// Note: this has been adjusted to be the same as dart URI implementation
// now this just serves as a stand alone grammar/parser for academic purposes
// as a1_notation grammer uses dart:core uri.
//
// The accepted inputs and decomposition matches the example given in
// Appendix B of the standard: https://tools.ietf.org/html/rfc3986#appendix-B.

import 'package:petitparser/petitparser.dart';

typedef SymbolMap = Map<Symbol, dynamic>;

class A1Uri extends GrammarDefinition {
  @override
  Parser<SymbolMap> start() => uri().end();

  // A Uniform Resource Identifier (URI) is a compact sequence of
  // characters that identifies an abstract or physical resource.  This
  // specification defines the generic URI syntax and a process for
  // resolving URI references that might be in relative form, along with
  // guidelines and security considerations for the use of URIs on the
  // Internet
  Parser<SymbolMap> uri() => seq5(
        seq2(ref0(_scheme), ':'.toParser()).optional(),
        seq2('//'.toParser(), ref0(_authority)).optional(),
        ref0(_path),
        seq2('?'.toParser(), ref0(_query)).optional(),
        seq2('#'.toParser(), ref0(_fragment)).optional(),
      ).map5((scheme, authorityString, path, queryString, fragment) {
        final a1Uri = A1Uri();
        final params = a1Uri
            .buildFrom(a1Uri.query())
            .end()
            .parse(queryString?.$2 ?? '')
            .value;
        final authorityMap = a1Uri
            .buildFrom(a1Uri.authority())
            .end()
            .parse(authorityString?.$2 ?? '')
            .value;
        return <Symbol, dynamic>{
          #scheme: scheme?.$1.toLowerCase(), // to match dart:core uri
          #authority: authorityString?.$2,
          ...authorityMap,
          #path: path.replaceAll('\\', '/'), // to match dart:core uri
          #query: queryString?.$2,
          #params: params,
          #fragment: fragment?.$2,
        };
      });
  Parser<String> _scheme() => pattern('^:/?#').plusString('scheme');

  Parser<String> _authority() => pattern('^/?#').starString('authority');

  Parser<String> _path() => pattern('^?#').starString('path');

  Parser<String> _query() => pattern('^#').starString('query');

  Parser<String> _fragment() => any().starString('fragment');

  // Authoriy
  // Many URI schemes include a hierarchical element for a naming
  // authority so that governance of the name space defined by the
  // remainder of the URI is delegated to that authority (which may, in
  // turn, delegate it further).  The generic syntax provides a common
  // means for distinguishing an authority based on a registered name or
  // server address, along with optional port and user information.
  Parser<Map<Symbol, String?>> authority() => seq3(
        ref0(credentials).optional(),
        ref0(_hostname).optional(),
        ref0(_port).optional(),
      ).map3((credentials, hostname, port) => {
            #username: credentials?.$1,
            #password: credentials?.$2?.$2,
            #host: hostname,
            #port: port?.$2,
          });

  Parser<(String, (String, String)?, String)> credentials() => seq3(
      ref0(_username),
      seq2(':'.toParser(), ref0(_password)).optional(),
      '@'.toParser());

  Parser<String> _username() => pattern('^:@').plusString('username');

  Parser<String> _password() => pattern('^@').plusString('password');

  Parser<String> _hostname() => pattern('^:').plusString('hostname');

  Parser<(String, String)> _port() =>
      seq2(':'.toParser(), digit().plusString('port'));

  // Query
  // The query component contains non-hierarchical data that, along with
  // data in the path component, serves to identify a
  Parser<Iterable<(String, String?)>> query() =>
      ref0(param).plusSeparated('&'.toParser()).map((list) =>
          list.elements.where((each) => each.$1 != '' || each.$2 != null));

  Parser<(String, String?)> param() =>
      seq2(ref0(_paramKey), seq2('='.toParser(), ref0(_paramValue)).optional())
          .map2((key, value) => (key, value?.$2));

  Parser<String> _paramKey() => pattern('^=&').starString('param key');

  Parser<String> _paramValue() => pattern('^&').starString('param value');
}
