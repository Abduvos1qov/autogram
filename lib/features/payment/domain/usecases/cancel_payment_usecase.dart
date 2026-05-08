import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class CancelPaymentUseCase implements UseCase<Payment, IdParams> {
  final PaymentRepository _repository;

  CancelPaymentUseCase(this._repository);

  @override
  Future<Either<Failure, Payment>> call(IdParams params) =>
      _repository.cancelPayment(params.id);
}
