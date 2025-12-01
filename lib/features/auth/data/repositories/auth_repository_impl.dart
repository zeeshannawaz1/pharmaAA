import 'package:dartz/dartz.dart';
import 'package:aa_app/core/error/failures.dart';
import 'package:aa_app/features/auth/domain/entities/user.dart';
import 'package:aa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:aa_app/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> login({required String baseUrl, required String userId}) async {
    try {
      final user = await remoteDataSource.login(baseUrl: baseUrl, userId: userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
} 
