import 'package:test/test.dart';

Matcher equalsList(list) => _ListEquals(list);

class _ListEquals<T> implements Matcher {
  List<T> list;
  _ListEquals(this.list);

  // from flutter foundation
  bool listEquals(List<T>? a, List<T>? b) {
    if (a == null) {
      return b == null;
    }
    if (b == null || a.length != b.length) {
      return false;
    }
    if (identical(a, b)) {
      return true;
    }
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describe(Description description) =>
      description.addDescriptionOf(list);

  @override
  Description describeMismatch(item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      mismatchDescription.add('$item does not equal $list');

  @override
  bool matches(item, Map matchState) => listEquals(list, item);
}
