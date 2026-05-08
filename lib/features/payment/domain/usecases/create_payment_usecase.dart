import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentUseCase implements UseCase<Payment, CreatePaymentParams> {
  final PaymentRepository _repository;

  CreatePaymentUseCase(this._repository);

  @override
  Future<Either<Failure, Payment>> call(CreatePaymentParams params) =>
      _repository.createPayment(params);
}
