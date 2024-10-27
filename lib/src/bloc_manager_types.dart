import 'package:bloc/bloc.dart';
import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';

/// Function signature for `BlocManagerListenerHandler`.
typedef GenericBloc = BlocBase<Object>;

/// Function signature for `BlocManagerListenerHandler`.
typedef GenericStateEmitter = BaseStateEmitter<BaseStateListener, GenericBloc>;
