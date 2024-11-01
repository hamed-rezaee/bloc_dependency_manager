import 'dart:async';

import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';

/// Function signature for `BlocManagerListenerHandler`.
typedef BlocManagerListenerHandler = void Function(Object state);

/// Bloc manager interface.
///
/// This interface defines contract for bloc managers.
abstract class BaseBlocManager {
  /// Default bloc key.
  static const String defaultKey = 'default';

  /// Stores registered blocs instances.
  Map<String, GenericBloc> get repository;

  /// Registers a bloc to bloc manager, the bloc will be instantiated whenever needed.
  ///
  /// [predicate] is required.
  ///
  /// [key] is registered bloc identifier,
  /// you can omit this parameter if you need only one bloc instance of type [B] in the repository.
  void lazyRegister<B extends GenericBloc>(
    Function predicate, {
    String key = defaultKey,
  });

  /// Registers a bloc to bloc manager.
  ///
  /// [bloc] is required.
  ///
  /// [key] is registered bloc identifier,
  /// you can omit this parameter if you need only one bloc instance of type [B] in the repository.
  B register<B extends GenericBloc>(B bloc, {String key = defaultKey});

  /// Indicates that bloc of type [B] is registered or not.
  bool isBlocRegistered<B extends GenericBloc>(String key);

  /// Resolves the bloc of type [B].
  B resolve<B extends GenericBloc>([String key]);

  /// Adds a listener to bloc.
  ///
  /// [listenerKey] is an identifier for listener, this field is required.
  /// [handler] is a callback that will be executed when listener is called, this field is required.
  /// [key] is used to identify bloc, this field is optional and defaults to [defaultKey].
  void addListener<B extends GenericBloc>({
    required String listenerKey,
    required BlocManagerListenerHandler handler,
    String key = defaultKey,
  });

  /// Removes listener from bloc manager.
  ///
  /// [key] is registered listener identifier.
  /// NOTE: if you need to check listener for specific bloc type leave it `empty`.
  Future<void> removeListener<B extends GenericBloc>({String key = defaultKey});

  /// Indicates that bloc of type [B] has listener or not.
  ///
  /// [key] is registered listener identifier, or bloc identifier if you need to check listener for specific bloc.
  bool hasListener<B extends GenericBloc>(String key);

  /// Adds a [BaseStateEmitter] to bloc manager.
  void registerStateEmitter(GenericStateEmitter stateEmitter);

  /// Emits core blocs states.
  void emitCoreStates<E extends GenericStateEmitter>({
    required GenericBloc bloc,
    Object? state,
  });

  /// Disposes the bloc of type [B].
  Future<void> dispose<B extends GenericBloc>([String key = defaultKey]);
}
