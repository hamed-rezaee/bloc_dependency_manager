// ignore_for_file: public_member_api_docs

import 'package:bloc_dependency_manager/bloc_dependency_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef GenericBloc = BlocBase<Object>;
typedef GenericStateEmitter = BaseStateEmitter<BaseStateListener, GenericBloc>;
