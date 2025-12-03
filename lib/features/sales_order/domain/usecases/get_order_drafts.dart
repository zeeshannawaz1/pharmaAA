import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_draft.dart';
import '../repositories/order_draft_repository.dart';

class GetOrderDrafts implements UseCase<List<OrderDraft>, NoParams> {
  final OrderDraftRepository repository;

  GetOrderDrafts(this.repository);

  @override
  Future<Either<Failure, List<OrderDraft>>> call(NoParams params) async {
    return await repository.getOrderDrafts();
  }
} 
