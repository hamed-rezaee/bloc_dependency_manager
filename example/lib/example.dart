import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:bloc_dependency_manager_example/counter_bloc.dart';
import 'package:bloc_dependency_manager_example/counter_state_emitter.dart';
import 'package:bloc_dependency_manager_example/logger_bloc.dart';

Future<void> main() async {
  // Register all the blocs.
  BlocManager().register(LoggerBloc());
  BlocManager().register(CounterBloc());

  // Register the state emitter for the [CounterBloc].
  StateDispatcher(BlocManager()).register<CounterBloc, CounterStateEmitter>(
    (BaseBlocManager blocManager) =>
        CounterStateEmitter(blocManager as BlocManager),
  );

  // Fetch the [LoggerBloc] and listen to its state changes.
  BlocManager().fetch<LoggerBloc>().stream.listen(print);

  // Fetch the [CounterBloc] and dispatch some events.
  BlocManager().fetch<CounterBloc>().decrement();
  await Future<void>.delayed(const Duration(seconds: 1));
  BlocManager().fetch<CounterBloc>().increment();
  await Future<void>.delayed(const Duration(seconds: 1));
  BlocManager().fetch<CounterBloc>().reset();
  await Future<void>.delayed(const Duration(seconds: 1));

  // Dispose [BlocManager] to clean up resources.
  await BlocManager().dispose();

  print('All blocs disposed.');
}
