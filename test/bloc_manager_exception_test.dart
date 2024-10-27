import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:test/test.dart';

void main() {
  group(BlocManagerException, () {
    test('toString returns correct string.', () {
      final exception = BlocManagerException(message: 'test message');

      expect('$exception', '$BlocManagerException: test message');
    });
  });
}
