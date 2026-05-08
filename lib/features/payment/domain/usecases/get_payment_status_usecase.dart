import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_status.dart';
import '../repositories/payment_repository.dart';

class GetPaymentStatusUseCase implements UseCase<PaymentStatus, IdParams> {
  final PaymentRepository _repository;

  GetPaymentStatusUseCase(this._repository);

  @override
  Future<Either<Failure, PaymentStatus>> call(IdParams params) =>
      _repository.getPaymentStatus(params.id);
}
