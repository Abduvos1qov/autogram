import 'package:equatable/equatable.dart';

import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/boost_package.dart';

/// Payment BLoC events.

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => const [];
}

/// Start a subscription payment for [plan] on the chosen [cycle], optionally
/// purchasing [additionalSeats] above the plan's bundled seat allowance.
class PaymentInitiated extends PaymentEvent {
  final SubscriptionPlan plan;
  final BillingCycle cycle;
  final int additionalSeats;

  const PaymentInitiated({
    required this.plan,
    required this.cycle,
    this.additionalSeats = 0,
  });

  @override
  List<Object?> get props => [plan, cycle, additionalSeats];
}

/// Start a standalone payment for [seatCount] additional seats at
/// [unitPrice] UZS per seat.
class SeatPaymentInitiated extends PaymentEvent {
  final int seatCount;
  final int unitPrice;

  const SeatPaymentInitiated({
    required this.seatCount,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [seatCount, unitPrice];
}

/// Start a boost package payment.
class BoostPaymentInitiated extends PaymentEvent {
  final BoostPackage package;

  const BoostPaymentInitiated(this.package);

  @override
  List<Object?> get props => [package];
}

/// User dismissed the gateway WebView — bloc transitions to processing
/// and starts watching the payment status.
class PaymentWebViewClosed extends PaymentEvent {
  const PaymentWebViewClosed();
}

/// Subscribe to status updates for [paymentId] until terminal.
class PaymentStatusChecked extends PaymentEvent {
  final String paymentId;

  const PaymentStatusChecked(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

/// User explicitly cancelled the payment from the app UI.
class PaymentCancelledByUser extends PaymentEvent {
  const PaymentCancelledByUser();
}

/// Reset to [PaymentInitial] — used after acknowledging a terminal state.
class PaymentReset extends PaymentEvent {
  const PaymentReset();
}
