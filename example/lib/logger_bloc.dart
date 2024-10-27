import 'package:bloc/bloc.dart';
import 'package:bloc_dependency_manager_example/counter_bloc.dart';
import 'package:bloc_dependency_manager_example/counter_state_listener.dart';

class LoggerBloc extends Cubit<String> implements CounterStateListener {
  LoggerBloc() : super('');

  @override
  void onCounterStateReset() {
    emit('$runtimeType => Counter state reset.');
  }

  @override
  void onCounterStateChange(CounterState counterState) {
    emit('$runtimeType => Counter state changed to $counterState.');
  }
}
