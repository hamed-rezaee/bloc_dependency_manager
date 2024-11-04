import 'package:bloc/bloc.dart';
import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  const blocKey = 'CUBIT_KEY';
  const firstListenerKey = 'CUBIT_FIRST_LISTENER_KEY';
  const secondListenerKey = 'CUBIT_SECOND_LISTENER_KEY';

  late final BaseBlocManager blocManager;

  setUpAll(() => blocManager = BlocManager()..register(_TestCubit()));

  tearDownAll(() {
    blocManager
      ..dispose<_TestCubit>()
      ..dispose<_TestCubit>(blocKey);
  });

  group(BlocManager, () {
    test('should register and resolve cubit from bloc manager.', () {
      blocManager.register(_TestCubit(), key: blocKey);

      expect(blocManager.resolve<_TestCubit>(), isA<Cubit<bool>>());
    });

    blocTest<_TestCubit, bool>(
      'emits trueState() and register a listener for bloc manager.',
      build: () {
        blocManager.addListener<_TestCubit>(
          listenerKey: 'TestCubitListener',
          handler: (Object state) => expect(state, isTrue),
        );

        return blocManager.resolve<_TestCubit>();
      },
      act: (_TestCubit cubit) => <void>[cubit.trueState()],
      expect: () => <bool>[true],
    );

    test(
        'should remove listener from bloc manager with a proper [listenerKey].',
        () async {
      blocManager
        ..register(_TestCubit())
        ..register(_TestCubit(), key: blocKey)
        ..addListener<_TestCubit>(
          listenerKey: firstListenerKey,
          handler: (Object state) => expect(state, isTrue),
          key: blocKey,
        )
        ..addListener<_TestCubit>(
          listenerKey: secondListenerKey,
          handler: (Object state) => expect(state, isTrue),
        );

      await blocManager.removeListener<_TestCubit>(key: firstListenerKey);

      expect(
        blocManager.hasListener<_TestCubit>(firstListenerKey),
        isFalse,
      );
    });

    test(
        'should remove all listeners from bloc manager for a specific bloc type.',
        () async {
      blocManager
        ..register(_TestCubit(), key: blocKey)
        ..addListener<_TestCubit>(
          listenerKey: firstListenerKey,
          handler: (Object state) => expect(state, isTrue),
          key: blocKey,
        )
        ..addListener<_TestCubit>(
          listenerKey: secondListenerKey,
          handler: (Object state) => expect(state, isTrue),
          key: blocKey,
        );

      await blocManager.removeListener<_TestCubit>();

      expect(
        blocManager.hasListener<_TestCubit>(blocKey),
        isFalse,
      );
    });
  });
}

class _TestCubit extends Cubit<bool> {
  _TestCubit() : super(false);

  void trueState() => emit(true);

  void falseState() => emit(false);
}
