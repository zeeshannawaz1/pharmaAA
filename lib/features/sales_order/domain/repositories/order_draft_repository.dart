import 'package:dartz/dartz.dart';
import '../entities/order_draft.dart';
import '../../../../core/error/failures.dart';

abstract class OrderDraftRepository {
  Future<Either<Failure, List<OrderDraft>>> getOrderDrafts();
  Future<Either<Failure, OrderDraft>> getOrderDraft(String id);
  Future<Either<Failure, OrderDraft>> saveOrderDraft(OrderDraft draft);
  Future<Either<Failure, Unit>> deleteOrderDraft(String id);
  Future<Either<Failure, Unit>> deleteAllOrderDrafts();
} 
