import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';

/// Base state emitter class.
abstract class BaseStateEmitter<L extends BaseStateListener,
    B extends GenericBloc> {
  /// Initializes base state emitter.
  BaseStateEmitter(this.blocManager) {
    blocManager.registerStateEmitter(this);
  }

  /// Bloc manager instance.
  final BaseBlocManager blocManager;

  /// Handles states for state listener [L].
  void handleStates({required L stateListener, required Object state});

  /// Emits state to corresponding listener.
  void call({required BaseStateListener stateListener, Object? state}) {
    if (stateListener is L) {
      handleStates(
        stateListener: stateListener,
        state: state ?? blocManager.resolve<B>().state,
      );
    }
  }
}
