import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_draft.dart';
import '../repositories/order_draft_repository.dart';

class SaveOrderDraft implements UseCase<OrderDraft, SaveOrderDraftParams> {
  final OrderDraftRepository repository;

  SaveOrderDraft(this.repository);

  @override
  Future<Either<Failure, OrderDraft>> call(SaveOrderDraftParams params) async {
    return await repository.saveOrderDraft(params.draft);
  }
}

class SaveOrderDraftParams extends Equatable {
  final OrderDraft draft;

  const SaveOrderDraftParams({required this.draft});

  @override
  List<Object> get props => [draft];
} 
