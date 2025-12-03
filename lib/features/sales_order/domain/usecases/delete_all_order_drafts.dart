import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/order_draft_repository.dart';

class DeleteAllOrderDrafts implements UseCase<Unit, NoParams> {
  final OrderDraftRepository repository;

  DeleteAllOrderDrafts(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await repository.deleteAllOrderDrafts();
  }
}

