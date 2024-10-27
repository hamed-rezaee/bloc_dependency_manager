import 'package:bloc/bloc.dart';
import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

void main() {
  const blocKey = 'CUBIT_KEY';
  const firstListenerKey = 'CUBIT_FIRST_LISTENER_KEY';
  const secondListenerKey = 'CUBIT_SECOND_LISTENER_KEY';

  late final BaseBlocManager blocManager;

  setUpAll(() => blocManager = BlocManager());

  tearDownAll(() {
    blocManager
      ..dispose<_TestCubit>()
      ..dispose<_TestCubit>(blocKey);
  });

  group(BlocManager, () {
    test('should register and fetch cubit from bloc manager.', () {
      blocManager.lazyRegister<_TestCubit>(_TestCubit.new);

      expect(blocManager.fetch<_TestCubit>(), isA<Cubit<bool>>());
    });

    blocTest<_TestCubit, bool>(
      'emits trueState() and register a listener for bloc manager.',
      build: () {
        blocManager.addListener<_TestCubit>(
          listenerKey: 'TestCubitListener',
          handler: (Object state) => expect(state, isTrue),
        );

        return blocManager.fetch<_TestCubit>();
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

    group(BlocManagerException, () {
      test(
        'fetch throws BlocManagerException when bloc is not registered.',
        () => expect(
          () => blocManager.fetch<GenericBloc>(),
          throwsA(isA<BlocManagerException>()),
        ),
      );

      test('fetch throws BlocManagerException when bloc key is invalid.', () {
        blocManager.register<GenericBloc>(_TestCubit(), key: 'test_key');

        expect(
          () => blocManager.fetch<GenericBloc>('invalid_key'),
          throwsA(isA<BlocManagerException>()),
        );
      });

      test(
        'addListener throws BlocManagerException when bloc is not registered.',
        () => expect(
          () => blocManager.addListener<GenericBloc>(
            listenerKey: 'test_listener',
            handler: (_) {},
          ),
          throwsA(isA<BlocManagerException>()),
        ),
      );
    });
  });
}

class _TestCubit extends Cubit<bool> {
  _TestCubit() : super(false);

  void trueState() => emit(true);

  void falseState() => emit(false);
}
