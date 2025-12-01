import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order_draft.dart';
import '../../domain/repositories/order_draft_repository.dart';
import '../datasources/order_draft_local_data_source.dart';

class OrderDraftRepositoryImpl implements OrderDraftRepository {
  final OrderDraftLocalDataSource localDataSource;

  OrderDraftRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<OrderDraft>>> getOrderDrafts() async {
    try {
      final draftModels = await localDataSource.getOrderDrafts();
      final drafts = draftModels.map((m) => m.toEntity()).toList();
      return Right(drafts);
    } on CacheException {
      return Left(CacheFailure('Failed to load order drafts'));
    }
  }

  @override
  Future<Either<Failure, OrderDraft>> getOrderDraft(String id) async {
    try {
      final draftModel = await localDataSource.getOrderDraft(id);
      if (draftModel != null) {
        return Right(draftModel.toEntity());
      } else {
        return Left(CacheFailure('Order draft not found'));
      }
    } on CacheException {
      return Left(CacheFailure('Failed to load order draft'));
    }
  }

  @override
  Future<Either<Failure, OrderDraft>> saveOrderDraft(OrderDraft draft) async {
    try {
      final savedDraft = await localDataSource.saveOrderDraft(draft);
      return Right(savedDraft);
    } on CacheException {
      return Left(CacheFailure('Failed to save order draft'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteOrderDraft(String id) async {
    try {
      await localDataSource.deleteOrderDraft(id);
      return const Right(unit);
    } on CacheException {
      return Left(CacheFailure('Failed to delete order draft'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllOrderDrafts() async {
    try {
      await localDataSource.deleteAllOrderDrafts();
      return const Right(unit);
    } on CacheException {
      return Left(CacheFailure('Failed to delete all order drafts'));
    }
  }
} 
