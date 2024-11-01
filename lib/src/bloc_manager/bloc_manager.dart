import 'dart:async';

import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';

/// Bloc manager class.
///
/// This class implements [BaseBlocManager] interface.
class BlocManager implements BaseBlocManager {
  /// Returns bloc manager instance.
  factory BlocManager() => _instance;

  BlocManager._internal();

  static final BlocManager _instance = BlocManager._internal();

  final Map<String, Function> _factories = <String, Function>{};
  final Map<String, GenericBloc> _repository = <String, GenericBloc>{};

  final Map<String, StreamSubscription<Object>> _subscriptions =
      <String, StreamSubscription<Object>>{};

  final List<GenericStateEmitter> _stateEmitters = <GenericStateEmitter>[];

  @override
  Map<String, GenericBloc> get repository => _repository;

  @override
  void lazyRegister<B extends GenericBloc>(
    Function predicate, {
    String key = BaseBlocManager.defaultKey,
  }) {
    if (isBlocRegistered<B>(key)) {
      return;
    }

    _factories[_getKey<B>(key)] = predicate;
  }

  @override
  B register<B extends GenericBloc>(
    B bloc, {
    String key = BaseBlocManager.defaultKey,
  }) {
    if (_hasRepository<B>(key)) {
      return resolve<B>(key);
    }

    /// This future is added to make sure the state emits in the correct order,
    /// and emitting states dose not block widget build.
    Future<void>.delayed(
      Duration.zero,
      () => emitCoreStates<GenericStateEmitter>(bloc: bloc),
    );

    return _repository[_getKey<B>(key)] = bloc;
  }

  @override
  bool isBlocRegistered<B extends GenericBloc>(String key) =>
      _hasFactory<B>(key) || _hasRepository<B>(key);

  @override
  B resolve<B extends GenericBloc>([String key = BaseBlocManager.defaultKey]) =>
      _hasRepository<B>(key)
          ? _repository[_getKey<B>(key)]! as B
          : _hasFactory<B>(key)
              ? _invoke<B>(key)! as B
              : throw _getCouldNotFindBlocException<B>(key);

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
    final listenerKey = _getKey<B>(key);

    final subscriptionKeys = _subscriptions.keys
        .where((itemKey) => itemKey.contains(listenerKey))
        .toList();

    for (final key in subscriptionKeys) {
      try {
        await _subscriptions[key]?.cancel();
      } on Exception catch (exception) {
        BlocManagerException(
          message: '<$B::$key> remove listener exception: $exception',
        );
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

  GenericBloc? _invoke<B extends GenericBloc>(String key) {
    final blocKey = _getKey<B>(key);

    register<B>(_factories[blocKey]!() as B, key: key);

    return repository[blocKey];
  }

  /// Gets bloc key.
  static String _getKey<B>(String key) => '$B::$key';

  /// Indicates whether bloc is registered in factory or not.
  bool _hasFactory<B extends GenericBloc>(String key) =>
      _factories.containsKey(_getKey<B>(key));

  /// Indicates whether bloc is registered in repository or not.
  bool _hasRepository<B extends GenericBloc>(String key) =>
      _repository.containsKey(_getKey<B>(key));

  Exception _getCouldNotFindBlocException<B extends GenericBloc>(String key) =>
      BlocManagerException(
        message:
            'Could not find <$B::$key> object, use register method to add it to bloc manager.',
      );

  @override
  Future<void> dispose<B extends GenericBloc>([
    String key = BaseBlocManager.defaultKey,
  ]) async {
    final blocKey = _getKey<B>(key);

    if (_hasRepository<B>(key)) {
      await _repository[blocKey]?.close();
      _repository.remove(blocKey);

      await removeListener<B>(key: key);
    }
  }
}
