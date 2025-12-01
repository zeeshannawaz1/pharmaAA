import 'package:dartz/dartz.dart';
import 'package:aa_app/core/error/failures.dart';
import 'package:aa_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({required String baseUrl, required String userId});
} 
