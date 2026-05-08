import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment.dart';

/// Payment BLoC states — Pattern A (state hierarchy).
///
/// The flow models a multi-step checkout: idle → loading → webview ready →
/// processing → terminal (success / failed / cancelled). Each state carries
/// only the fields relevant to that step.

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => const [];
}

/// Idle state — no checkout in progress.
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Creating the payment record on the server.
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Payment created and checkout URL resolved — UI should open the gateway
/// WebView with [checkoutUrl].
class PaymentWebViewReady extends PaymentState {
  final Payment payment;
  final String checkoutUrl;

  const PaymentWebViewReady(this.payment, this.checkoutUrl);

  @override
  List<Object?> get props => [payment, checkoutUrl];
}

/// WebView closed and the bloc is polling the gateway for the final status.
class PaymentProcessing extends PaymentState {
  final Payment payment;

  const PaymentProcessing(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Payment completed successfully.
class PaymentSuccess extends PaymentState {
  final Payment payment;

  const PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

/// Payment failed. [payment] is `null` when the failure occurred before the
/// payment record could be created (e.g. validation failure on
/// [PaymentInitiated], or [SubscriptionPlan.enterprise] which is not payable
/// in-app).
class PaymentFailed extends PaymentState {
  final Payment? payment;
  final Failure failure;

  const PaymentFailed({this.payment, required this.failure});

  @override
  List<Object?> get props => [payment, failure];
}

/// Payment cancelled — either by the user dismissing the WebView or by an
/// explicit cancel call. [payment] is `null` if cancellation occurred before
/// the payment record was created.
class PaymentCancelled extends PaymentState {
  final Payment? payment;

  const PaymentCancelled({this.payment});

  @override
  List<Object?> get props => [payment];
}
