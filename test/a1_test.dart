import 'package:a1/a1.dart';
import 'package:test/test.dart';

void main() {
  group('Create A1', () {
    // final awesome = Awesome();

    // setUp(() {
    //   // Additional setup goes here.
    // });

    test('A1 by parsing a string', () {
      final a1 = A1.parse('ZZA123');
      expect(a1, isA<A1>());
      expect(a1.column, equals(18252));
      expect(a1.row, equals(122));
    });
  });
}
