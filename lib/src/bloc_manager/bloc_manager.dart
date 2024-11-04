import 'dart:async';

import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:get_it/get_it.dart';

/// Bloc manager class.
///
/// This class implements [BaseBlocManager] interface.
class BlocManager implements BaseBlocManager {
  /// Returns bloc manager instance.
  factory BlocManager() => _instance;

  BlocManager._internal() : _getIt = GetIt.instance;

  static final BlocManager _instance = BlocManager._internal();

  final Map<String, StreamSubscription<Object>> _subscriptions =
      <String, StreamSubscription<Object>>{};

  final List<GenericStateEmitter> _stateEmitters = <GenericStateEmitter>[];

  @override
  final List<GenericBloc> repository = <GenericBloc>[];

  final GetIt _getIt;

  @override
  B register<B extends GenericBloc>(
    B bloc, {
    String key = BaseBlocManager.defaultKey,
  }) {
    if (isBlocRegistered<B>(key)) {
      return resolve<B>(key);
    }

    /// This future is added to make sure the state emits in the correct order,
    /// and emitting states dose not block widget build.
    Future<void>.delayed(
      Duration.zero,
      () => emitCoreStates<GenericStateEmitter>(bloc: bloc),
    );

    repository.add(bloc);

    return _getIt.registerSingleton<B>(bloc, instanceName: key);
  }

  @override
  bool isBlocRegistered<B extends GenericBloc>(String key) =>
      _getIt.isRegistered<B>(instanceName: key);

  @override
  B resolve<B extends GenericBloc>([String key = BaseBlocManager.defaultKey]) =>
      _getIt.get<B>(instanceName: key);

  @override
  void addListener<B extends GenericBloc>({
    required String listenerKey,
    required BlocManagerListenerHandler handler,
    String key = BaseBlocManager.defaultKey,
  }) {
    if (hasListener(listenerKey)) {
      return;
    }

    final bloc = resolve<B>(key);

    _subscriptions[_getKey<B>(listenerKey)] =
        bloc.stream.listen((Object state) => handler(state));
  }

  @override
  Future<void> removeListener<B extends GenericBloc>({
    String key = BaseBlocManager.defaultKey,
  }) async {
    final subscriptionKeys =
        _subscriptions.keys.where((itemKey) => itemKey.contains('$B')).toList();

    for (final key in subscriptionKeys) {
      try {
        await _subscriptions[key]?.cancel();
      } on Exception catch (exception) {
        Exception('<$B::$key> remove listener exception: $exception');
      } finally {
        _subscriptions.remove(key);
      }
    }
  }

  @override
  void registerStateEmitter(GenericStateEmitter stateEmitter) =>
      _stateEmitters.add(stateEmitter);

  @override
  void emitCoreStates<E extends GenericStateEmitter>({
    required GenericBloc bloc,
    Object? state,
  }) {
    if (bloc is BaseStateListener) {
      final stateEmitters = _stateEmitters.whereType<E>().toList();

      for (final GenericStateEmitter stateEmitter in stateEmitters) {
        stateEmitter(stateListener: bloc as BaseStateListener, state: state);
      }
    }
  }

  @override
  bool hasListener<B extends GenericBloc>(String key) =>
      _subscriptions.containsKey(_getKey<B>(key));

  /// Gets bloc key.
  static String _getKey<B>(String key) => '$B::$key';

  @override
  Future<void> dispose<B extends GenericBloc>([
    String key = BaseBlocManager.defaultKey,
  ]) async {
    if (isBlocRegistered<B>(key)) {
      final bloc = resolve<B>(key);

      repository.remove(bloc);
      await bloc.close();
      _getIt.unregister<B>(instanceName: key);
      await removeListener<B>(key: key);
    }
  }
}
