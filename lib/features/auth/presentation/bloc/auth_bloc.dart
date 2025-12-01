import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:aa_app/features/auth/domain/usecases/login_user.dart';
import 'package:aa_app/core/utils/constants.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  AuthBloc({required this.loginUser}) : super(const AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LoadConfig>(_onLoadConfig);
    on<SaveConfig>(_onSaveConfig);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    
    try {
      final result = await loginUser(baseUrl: event.baseUrl, userId: event.userId);
      result.fold(
        (failure) {
          String errorMessage = 'Login failed';
          if (failure.message.contains('ServerFailure')) {
            errorMessage = 'Server connection failed. Please check:\n1. IP Address is correct\n2. Server is running\n3. Network connection';
          } else if (failure.message.contains('Invalid credentials')) {
            errorMessage = 'Invalid User ID. Please check your credentials.';
          } else {
            errorMessage = failure.message;
          }
          emit(AuthState.error(errorMessage));
        },
        (user) => emit(AuthState.loaded(user)),
      );
    } catch (e) {
      String errorMessage = 'Network error. Please check your connection and try again.';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Please check IP Address and network connection.';
      }
      emit(AuthState.error(errorMessage));
    }
  }

  Future<void> _onLoadConfig(LoadConfig event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final config = prefs.getStringList(Constants.configKey);
    if (config != null && config.length == 6) {
      emit(AuthState.configLoaded(
        userId: config[0],
        prCode: config[1],
        groupCode: config[2],
        pinCode: config[3],
        baseUrl: config[4],
        mobNo: config[5],
      ));
    } else {
      emit(const AuthState.configLoaded(
        userId: '',
        prCode: '',
        groupCode: '',
        pinCode: '',
        baseUrl: '',
        mobNo: '',
      ));
    }
  }

  Future<void> _onSaveConfig(SaveConfig event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(Constants.configKey, [
      event.userId,
      event.prCode,
      event.groupCode,
      event.pinCode,
      event.baseUrl,
      event.mobNo,
    ]);
    emit(AuthState.configLoaded(
      userId: event.userId,
      prCode: event.prCode,
      groupCode: event.groupCode,
      pinCode: event.pinCode,
      baseUrl: event.baseUrl,
      mobNo: event.mobNo,
    ));
  }
} 
