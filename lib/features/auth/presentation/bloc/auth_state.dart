import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.loaded(User user) = _Loaded;
  const factory AuthState.error(String message) = _Error;
  const factory AuthState.configLoaded({
    required String userId,
    required String prCode,
    required String groupCode,
    required String pinCode,
    required String baseUrl,
    required String mobNo,
  }) = _ConfigLoaded;
} 
