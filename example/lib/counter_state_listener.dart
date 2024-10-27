import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:bloc_dependency_manager_example/counter_bloc.dart';

abstract class CounterStateListener extends BaseStateListener {
  void onCounterStateReset();

  void onCounterStateChange(CounterState state);
}
