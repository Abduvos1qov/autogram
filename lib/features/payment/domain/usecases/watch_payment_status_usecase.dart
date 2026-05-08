import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/payment_status.dart';
import '../repositories/payment_repository.dart';

/// Streams payment status updates until terminal.
///
/// Doesn't implement [StreamUseCase] because the parameter is a primitive
/// `String` (paymentId) and wrapping it in a Params class adds no value.
class WatchPaymentStatusUseCase {
  final PaymentRepository _repository;

  WatchPaymentStatusUseCase(this._repository);

  Stream<Either<Failure, PaymentStatus>> call(String paymentId) =>
      _repository.watchPaymentStatus(paymentId);
}
