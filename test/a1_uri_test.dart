import 'package:a1/src/grammer/a1_uri.dart';

import 'package:petitparser/petitparser.dart';

import 'package:test/test.dart';

final a1Uri = A1Uri();
final parser = a1Uri.build();

void uriTest(String source, Map<Symbol, dynamic> values) {
  final result = parser.parse(source);
  expect(result is Success, isTrue, reason: 'isSuccess');
  for (final entry in values.entries) {
    expect(result.value[entry.key], entry.value, reason: entry.key.toString());
  }
}

void main() {
  group('Query with', () {
    test('different key value parameters', () async {
      final parser = a1Uri.buildFrom(a1Uri.param()).end();

      expect(parser.parse('test=mamma').value, equals(('test', 'mamma')));
      expect(parser.parse('test').value, equals(('test', null)));
      expect(parser.parse('=mamma').value, equals(('', 'mamma')));
      expect(parser.parse('').value, equals(('', null)));
      expect(() => parser.parse('teset=2&test2').value,
          throwsA(isA<ParserException>()));
    });

    test('list of parameters', () async {
      final parser = a1Uri.buildFrom(a1Uri.query()).end();

      expect(
        parser.parse('test=mamma&test2=daddy').value,
        containsAll([
          ('test', 'mamma'),
          ('test2', 'daddy'),
        ]),
      );
      expect(
        parser.parse('test=mamma&test2').value,
        containsAll([
          ('test', 'mamma'),
          ('test2', null),
        ]),
      );
      expect(
        parser.parse('test=mamma&=daddy&=daddy2').value,
        containsAll([
          ('test', 'mamma'),
          ('', 'daddy'),
          ('', 'daddy2'),
        ]),
      );
    });
  });

  group('Authority with', () {
    test('creditionals ', () {
      final parser = a1Uri.buildFrom(a1Uri.credentials()).end();

      expect(parser.parse('scott@').value, equals(('scott', null, '@')));
      expect(parser.parse('scott:horn@').value,
          equals(('scott', (':', 'horn'), '@')));
      expect(
          () => parser.parse('scott:@').value, throwsA(isA<ParserException>()));
    });
    test('port', () {
      final parser = a1Uri.buildFrom(a1Uri.authority()).end();

      var result = parser.parse('scott:horn@test.com:123').value;
      expect(result, containsPair(#port, '123'));

      result = parser.parse('test.com:123').value;
      expect(result, containsPair(#port, '123'));

      result = parser.parse('scott:horn@test.com').value;
      expect(result, containsPair(#port, null));

      expect(() => parser.parse('scott@test:').value,
          throwsA(isA<ParserException>()));
    });
    test('host', () {
      final parser = a1Uri.buildFrom(a1Uri.authority()).end();

      var result = parser.parse('scott:horn@test.com:123').value;
      expect(result, containsPair(#host, 'test.com'));

      result = parser.parse('com:123').value;
      expect(result, containsPair(#host, 'com'));

      result = parser.parse('scott').value;
      expect(result, containsPair(#host, 'scott'));

      expect(() => parser.parse('scott@test:').value,
          throwsA(isA<ParserException>()));
    });
  });

  group('Uri with ', () {
    test('an Anchor', () async {
      uriTest('http://www.ics.uci.edu/pub/ietf/uri/#Related', {
        #scheme: 'http',
        #authority: 'www.ics.uci.edu',
        #username: isNull,
        #password: isNull,
        #host: 'www.ics.uci.edu',
        #port: isNull,
        #path: '/pub/ietf/uri/',
        #query: isNull,
        #params: [],
        #fragment: 'Related',
      });
    });
    test('a Query', () async {
      uriTest('http://a/b/c/d;e?f&g=h', {
        #scheme: 'http',
        #authority: 'a',
        #username: isNull,
        #password: isNull,
        #host: 'a',
        #port: isNull,
        #path: '/b/c/d;e',
        #query: 'f&g=h',
        #params: [('f', null), ('g', 'h')],
        #fragment: isNull,
      });
    });
    test('a port and funky path', () async {
      uriTest(r'ftp://www.example.org:22/foo bar/zork<>?\^`{|}', {
        #scheme: 'ftp',
        #authority: 'www.example.org:22',
        #username: isNull,
        #password: isNull,
        #host: 'www.example.org',
        #port: '22',
        #path: '/foo bar/zork<>',
        #query: r'\^`{|}',
        #fragment: isNull,
      });
    });
    test('a data type definition', () async {
      uriTest('data:text/plain;charset=iso-8859-7,hallo', {
        #scheme: 'data',
        #authority: isNull,
        #username: isNull,
        #password: isNull,
        #host: isNull,
        #port: isNull,
        #path: 'text/plain;charset=iso-8859-7,hallo',
        #query: isNull,
        #params: [],
        #fragment: isNull,
      });
    });
    test('characters beyond ASCII', () async {
      uriTest('https://www.übermäßig.de/müßiggänger', {
        #scheme: 'https',
        #authority: 'www.übermäßig.de',
        #username: isNull,
        #password: isNull,
        #host: 'www.übermäßig.de',
        #port: isNull,
        #path: '/müßiggänger',
        #query: isNull,
        #params: [],
        #fragment: isNull,
      });
    });
    test('just a path', () async {
      uriTest('http:test', {
        #scheme: 'http',
        #authority: isNull,
        #username: isNull,
        #password: isNull,
        #host: isNull,
        #port: isNull,
        #path: 'test',
        #query: isNull,
        #params: [],
        #fragment: isNull,
      });
    });
    test('a file schema path DOS style drive', () async {
      uriTest(r'file:c:\foo\bar.html', {
        #scheme: 'file',
        #authority: isNull,
        #username: isNull,
        #password: isNull,
        #host: isNull,
        #port: isNull,
        #path: r'c:/foo/bar.html',
        #query: isNull,
        #params: [],
        #fragment: isNull,
      });
    });
    test('with username:password authority', () async {
      uriTest('file://foo:bar@localhost/test', {
        #scheme: 'file',
        #authority: 'foo:bar@localhost',
        #username: 'foo',
        #password: 'bar',
        #host: 'localhost',
        #port: isNull,
        #path: '/test',
        #query: isNull,
        #params: [],
        #fragment: isNull,
      });
    });
  });
  group('https://mathiasbynens.be/demo/url-regex', () {
    for (final input in const [
      'http://foo.com/blah_blah',
      'http://foo.com/blah_blah/',
      'http://foo.com/blah_blah_(wikipedia)',
      'http://foo.com/blah_blah_(wikipedia)_(again)',
      'http://www.example.com/wpstyle/?p=364',
      'https://www.example.com/foo/?bar=baz&inga=42&quux',
      'http://✪df.ws/123',
      'http://userid:password@example.com:8080',
      'http://userid:password@example.com:8080/',
      'http://userid@example.com',
      'http://userid@example.com/',
      'http://userid@example.com:8080',
      'http://userid@example.com:8080/',
      'http://userid:password@example.com',
      'http://userid:password@example.com/',
      'http://142.42.1.1/',
      'http://142.42.1.1:8080/',
      'http://➡.ws/䨹',
      'http://⌘.ws',
      'http://⌘.ws/',
      'http://foo.com/blah_(wikipedia)#cite-1',
      'http://foo.com/blah_(wikipedia)_blah#cite-1',
      'http://foo.com/unicode_(✪)_in_parens',
      'http://foo.com/(something)?after=parens',
      'http://☺.damowmow.com/',
      'http://code.google.com/events/#&product=browser',
      'http://j.mp',
      'ftp://foo.bar/baz',
      'http://foo.bar/?q=Test%20URL-encoded%20stuff',
      'http://مثال.إختبار',
      'http://例子.测试',
      'http://उदाहरण.परीक्षा',
      'http://-.~_!\$&\'()*+,;=:%40:80%2f::::::@example.com',
      'http://1337.net',
      'http://a.b-c.de',
      'http://223.255.255.254',
    ]) {
      test(input, () {
        final result = parser.parse(input);
        expect(result is Success, isTrue);
      });
    }
  });
}
