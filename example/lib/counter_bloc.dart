import 'package:bloc/bloc.dart';

enum CounterState { increment, decrement, reset }

class CounterBloc extends Cubit<CounterState> {
  CounterBloc() : super(CounterState.reset);

  void reset() {
    print('$runtimeType => ${CounterState.reset}.');

    emit(CounterState.reset);
  }

  void increment() {
    print('$runtimeType => ${CounterState.increment}.');

    emit(CounterState.increment);
  }

  void decrement() {
    print('$runtimeType => ${CounterState.decrement}.');

    emit(CounterState.decrement);
  }
}
