import 'package:a1/src/helpers/simple_cache.dart';
import 'package:test/test.dart';

void main() {
  group("Simple Cache", () {
    final cache = SimpleCache<String, int>(10);
    setUp(() {
      cache.clear();
      cache['test1'] = 1;
      cache['test2'] = 13;
      cache['test3'] = -1;
    });

    test(" contruction", () {
      expect(cache.capacity, equals(10));
    });
    test(" adding", () {
      cache['test1'] = 1;
      expect(cache['test1'], equals(1));
    });
    test(" retrieving", () {
      expect(cache['test2'], equals(13));
      expect(cache['not-in-cache'], isNull);
    });
    test(" keys", () {
      expect(cache.keys, containsAllInOrder(['test1', 'test2', 'test3']));
    });
    test(" remove", () {
      cache.remove('test1');
      expect(cache.keys, containsAllInOrder(['test2', 'test3']));
    });
    test(" cache eviction", () {
      for (int i = 4; i < 13; i++) {
        cache['test$i'] = i;
      }
      expect(cache.length, equals(10));
      expect(cache.keys.first, equals('test3'));
      expect(cache.keys.last, equals('test12'));
    });
  });
}
