import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(BaseStateEmitter, () {
    final BaseBlocManager blocManager = BlocManager();

    late BaseStateEmitter<MockStateListener, GenericBloc> emitter;

    setUp(() {
      emitter = MockStateEmitter(blocManager);
    });

    test('handles states correctly.', () {
      const state = true;

      final listener = MockStateListener();

      emitter.handleStates(stateListener: listener, state: state);

      expect(listener.onStateChanged(state), isTrue);
    });

    test('calls handleStates with correct arguments.', () {
      const state = false;

      final listener = MockStateListener();

      emitter.call(stateListener: listener, state: state);

      expect(listener.onStateChanged(state), isTrue);
    });
  });
}

class MockStateListener implements BaseStateListener {
  bool onStateChanged(Object state) => state is bool;
}

class MockStateEmitter
    extends BaseStateEmitter<MockStateListener, GenericBloc> {
  MockStateEmitter(super.blocManager);

  @override
  void handleStates({
    required MockStateListener stateListener,
    required Object state,
  }) {}
}
