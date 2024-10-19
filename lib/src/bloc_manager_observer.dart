import 'dart:developer' as logger;

import 'package:flutter_bloc/flutter_bloc.dart';

/// An observer for blocs and cubits state change.
class BlocManagerObserver extends BlocObserver {
  /// Initializes a new instance of the [BlocManagerObserver] class.
  BlocManagerObserver({
    this.enableOnCreateLogs = true,
    this.enableOnChangeLogs = false,
    this.enableOnCloseLogs = true,
    this.enableOnErrorLogs = true,
    this.verboseChangeStateLogs = false,
    this.onCreateCallback,
    this.onChangeCallback,
    this.onCloseCallback,
    this.onErrorCallback,
  });

  /// Enables on create logs.
  final bool enableOnCreateLogs;

  /// Enables on change logs.
  final bool enableOnChangeLogs;

  /// Enables on close logs.
  final bool enableOnCloseLogs;

  /// Enables on error logs.
  final bool enableOnErrorLogs;

  /// Enables verbose change state logs.
  final bool verboseChangeStateLogs;

  /// Called whenever a [Bloc] is created.
  final void Function(BlocBase<dynamic> bloc)? onCreateCallback;

  /// Called whenever a [Bloc] state changes.
  final void Function({
    required BlocBase<dynamic> bloc,
    required Change<dynamic> change,
  })? onChangeCallback;

  /// Called whenever a [Bloc] is closed.
  final void Function(BlocBase<dynamic> bloc)? onCloseCallback;

  /// Called whenever a [Bloc] throws an error.
  final void Function({
    required BlocBase<dynamic> bloc,
    required Object error,
    required StackTrace stackTrace,
  })? onErrorCallback;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);

    onCreateCallback?.call(bloc);

    if (enableOnCreateLogs) {
      logger.log('Bloc created: ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    onChangeCallback?.call(bloc: bloc, change: change);

    if (enableOnChangeLogs) {
      logger.log(
        verboseChangeStateLogs
            ? 'Bloc state: ${bloc.runtimeType} state changed from ${change.currentState} to ${change.nextState}'
            : 'Bloc state: ${bloc.runtimeType} state changed from ${change.currentState.runtimeType} to ${change.nextState.runtimeType}',
      );
    }
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);

    onCloseCallback?.call(bloc);

    if (enableOnCloseLogs) {
      logger.log('Bloc closed: ${bloc.runtimeType}');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    onErrorCallback?.call(bloc: bloc, error: error, stackTrace: stackTrace);

    if (enableOnErrorLogs) {
      logger.log('Bloc error: ${bloc.runtimeType}\n$error\n$stackTrace');
    }
  }
}
