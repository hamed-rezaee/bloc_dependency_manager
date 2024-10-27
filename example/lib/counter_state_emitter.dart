import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:bloc_dependency_manager_example/counter_bloc.dart';
import 'package:bloc_dependency_manager_example/counter_state_listener.dart';

class CounterStateEmitter
    extends BaseStateEmitter<CounterStateListener, CounterBloc> {
  CounterStateEmitter(super.blocManager);

  @override
  void handleStates({
    required CounterStateListener stateListener,
    required Object? state,
  }) =>
      switch (state) {
        CounterState.reset => stateListener.onCounterStateReset(),
        CounterState.increment =>
          stateListener.onCounterStateChange(CounterState.increment),
        CounterState.decrement =>
          stateListener.onCounterStateChange(CounterState.decrement),
        _ => throw UnimplementedError(),
      };
}
