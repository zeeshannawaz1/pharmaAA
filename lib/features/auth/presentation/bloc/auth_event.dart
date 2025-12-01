import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String baseUrl,
    required String userId,
  }) = LoginRequested;

  const factory AuthEvent.loadConfig() = LoadConfig;
  const factory AuthEvent.saveConfig({
    required String userId,
    required String prCode,
    required String groupCode,
    required String pinCode,
    required String baseUrl,
    required String mobNo,
  }) = SaveConfig;
} 
