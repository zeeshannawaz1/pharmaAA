import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/order_draft_repository.dart';

class DeleteOrderDraft implements UseCase<Unit, String> {
  final OrderDraftRepository repository;

  DeleteOrderDraft(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String draftId) async {
    return await repository.deleteOrderDraft(draftId);
  }
} 
