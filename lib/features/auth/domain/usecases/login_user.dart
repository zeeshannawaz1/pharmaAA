import 'package:dartz/dartz.dart';
import 'package:aa_app/core/error/failures.dart';
import 'package:aa_app/features/auth/domain/entities/user.dart';
import 'package:aa_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;
  LoginUser(this.repository);

  Future<Either<Failure, User>> call({required String baseUrl, required String userId}) async {
    return await repository.login(baseUrl: baseUrl, userId: userId);
  }
} 
