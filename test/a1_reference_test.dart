import 'package:a1/a1.dart';
import 'package:test/test.dart';

// Reference allows a cell or cell range to be referenced in another
// sheet/file/url
//
// Sheet1!<A1RANGE> refers to the range in Sheet1.
//

void main() {
  group('Creating an A1Reference', () {
    test('from a worsheet without quotes and range', () {
      final a1r = A1Reference.parse("Sheet1!A1:Z2");
      expect(a1r, isA<A1Reference>());
      print(a1r);
      expect(a1r.worksheet, equals('Sheet1'));
      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to.a1, equals('Z2'.a1));
    });
    test('from a worsheet and range', () {
      final a1r = A1Reference.parse("'Sheet1'!A1:Z2");
      expect(a1r, isA<A1Reference>());
      print(a1r);
      expect(a1r.worksheet, equals('Sheet1'));
      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to.a1, equals('Z2'.a1));
    });

    test('from a file path and range', () {
      final a1r =
          A1Reference.parse("'c:\\path1\\path2\\[file name]Sheet1'!A1:Z2");
      expect(a1r, isA<A1Reference>());
      print(a1r);
      expect(a1r.scheme, equals('c'));
      expect(a1r.path, equals('/path1/path2/'));
      expect(a1r.filename, equals('file name'));
      expect(a1r.worksheet, equals('Sheet1'));
      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to.a1, equals('Z2'.a1));
    });

    test('from a https path and range', () {
      final a1r = A1Reference.parse(
          "'https://test.com/path1/path2/[file name]Sheet1'!A1:Z2");
      expect(a1r, isA<A1Reference>());
      expect(a1r.toString(),
          equals("'https://test.com/path1/path2/[file name]Sheet1'!A1:Z2"));
      expect(a1r.scheme, equals('https'));
      expect(a1r.host, equals('test.com'));
      expect(a1r.path, equals('/path1/path2/'));
      expect(a1r.filename, equals('file name'));
      expect(a1r.worksheet, equals('Sheet1'));
      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to.a1, equals('Z2'.a1));
    });
    test('with a partial range column to', () {
      var a1r = A1Reference.parse(
          "'https://test.com/path1/path2/[file name]Sheet1'!A1:Z");
      expect(a1r, isA<A1Reference>());
      expect(a1r.toString(),
          equals("'https://test.com/path1/path2/[file name]Sheet1'!A1:Z"));
      expect(a1r.scheme, equals('https'));
      expect(a1r.host, equals('test.com'));
      expect(a1r.path, equals('/path1/path2/'));
      expect(a1r.filename, equals('file name'));
      expect(a1r.worksheet, equals('Sheet1'));
      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to, equals(A1Partial('Z', null)));
    });
    test('with a partial range from only', () {
      var a1r = A1Reference.parse(
          "'https://test.com/path1/path2/[file name]Sheet1'!A1");
      expect(a1r, isA<A1Reference>());
      expect(a1r.toString(),
          equals("'https://test.com/path1/path2/[file name]Sheet1'!A1"));

      expect(a1r.from.a1, equals('A1'.a1));
      expect(a1r.to, equals(A1Partial(null, null)));
    });
    test('with a partial range from column only', () {
      var a1r = A1Reference.parse(
          "'https://test.com/path1/path2/[file name]Sheet1'!A");
      expect(a1r, isA<A1Reference>());
      expect(a1r.toString(),
          equals("'https://test.com/path1/path2/[file name]Sheet1'!A"));

      expect(a1r.from, equals(A1Partial('A', null)));
      expect(a1r.to, equals(A1Partial(null, null)));
    });
    test('with no range', () {
      var a1r =
          A1Reference.parse("'https://test.com/path1/path2/[file name]Sheet1'");
      expect(a1r, isA<A1Reference>());

      expect(a1r.toString(),
          equals("'https://test.com/path1/path2/[file name]Sheet1'"));

      expect(a1r.from, equals(A1Partial(null, null)));
      expect(a1r.to, equals(A1Partial(null, null)));
    });
  });

  group('Operators', () {
    test('comparison', () {
      expect('worksheet!a1:b2'.a1Ref.compareTo('worksheet!a1:a2'.a1Ref),
          equals(1));
      expect(
          "'worksheet 2'!b1:b2"
              .a1Reference
              .compareTo("'worksheet 2'!b1:b2".a1Ref),
          equals(0));

      expect(
          "'[filename]worksheet'!b2:a1"
              .a1Ref
              .compareTo("'[filename]worksheet'!a1:a2".a1Ref),
          equals(1));

      expect(
        () => 'worksheet3!a1:a'.a1Ref.compareTo('worksheet1!b1:c3'.a1Ref),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () =>
            "'[file]worksheet1!a1:b2".a1Ref.compareTo('worksheet1!a1:b2'.a1Ref),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('Extensions', () {
    test('string to a1Range', () {
      final a1Ref =
          "'file://c:/path1/path2/[file name]Work sheet'!Z26:A1".a1Ref;
      expect(a1Ref.scheme, equals('file'));
      expect(a1Ref.host, equals('c'));
      expect(a1Ref.path, equals('/path1/path2/'));
      expect(a1Ref.filename, equals('file name'));
      expect(a1Ref.worksheet, equals('Work sheet'));
      expect(a1Ref.from.row, equals(0)); // A
      expect(a1Ref.from.row, equals(0)); // 1
      expect(a1Ref.to.column, equals(25)); // Z
      expect(a1Ref.to.row, equals(25)); // 26
      print(a1Ref);
    });
  });
}
