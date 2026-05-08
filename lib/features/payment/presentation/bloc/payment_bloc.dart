import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/billing_cycle.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_product.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/services/payment_gateway_service.dart';
import '../../domain/usecases/cancel_payment_usecase.dart';
import '../../domain/usecases/create_payment_usecase.dart';
import '../../domain/usecases/get_payment_status_usecase.dart';
import '../../domain/usecases/watch_payment_status_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

/// Payment BLoC — orchestrates the multi-step checkout flow.
///
/// Flow:
/// 1. UI dispatches one of the `*Initiated` events.
/// 2. Bloc validates inputs, computes the amount, calls
///    [CreatePaymentUseCase], then resolves the gateway checkout URL via
///    [PaymentGatewayService].
/// 3. UI opens the WebView with [PaymentWebViewReady.checkoutUrl].
/// 4. When the WebView closes, UI dispatches [PaymentWebViewClosed] which
///    triggers status polling via [WatchPaymentStatusUseCase].
/// 5. Bloc settles into a terminal state ([PaymentSuccess], [PaymentFailed]
///    or [PaymentCancelled]) and the UI navigates accordingly.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentUseCase _createPaymentUseCase;
  final GetPaymentStatusUseCase _getPaymentStatusUseCase;
  final WatchPaymentStatusUseCase _watchPaymentStatusUseCase;
  final CancelPaymentUseCase _cancelPaymentUseCase;
  final PaymentGatewayService _gatewayService;

  PaymentBloc({
    required CreatePaymentUseCase createPaymentUseCase,
    required GetPaymentStatusUseCase getPaymentStatusUseCase,
    required WatchPaymentStatusUseCase watchPaymentStatusUseCase,
    required CancelPaymentUseCase cancelPaymentUseCase,
    required PaymentGatewayService gatewayService,
  })  : _createPaymentUseCase = createPaymentUseCase,
        _getPaymentStatusUseCase = getPaymentStatusUseCase,
        _watchPaymentStatusUseCase = watchPaymentStatusUseCase,
        _cancelPaymentUseCase = cancelPaymentUseCase,
        _gatewayService = gatewayService,
        super(const PaymentInitial()) {
    on<PaymentInitiated>(_onPaymentInitiated);
    on<SeatPaymentInitiated>(_onSeatPaymentInitiated);
    on<BoostPaymentInitiated>(_onBoostPaymentInitiated);
    on<PaymentWebViewClosed>(_onWebViewClosed);
    on<PaymentStatusChecked>(_onStatusChecked);
    on<PaymentCancelledByUser>(_onCancelledByUser);
    on<PaymentReset>(_onReset);
  }

  Future<void> _onPaymentInitiated(
    PaymentInitiated event,
    Emitter<PaymentState> emit,
  ) async {
    AppLogger.info(
      'Subscription payment initiated: plan=${event.plan.name} '
      'cycle=${event.cycle.name} seats=${event.additionalSeats}',
    );

    // Enterprise plan is contract-based, not purchasable in-app.
    if (event.plan == SubscriptionPlan.enterprise) {
      AppLogger.warning('Enterprise plan is not payable in-app');
      emit(const PaymentFailed(
        failure: ValidationFailure(
          message: 'Enterprise tarifi savdo bo\'limi orqali rasmiylashtiriladi',
        ),
      ));
      return;
    }

    final basePrice = event.cycle == BillingCycle.yearly
        ? event.plan.yearlyPrice
        : event.plan.monthlyPrice;

    if (basePrice < 0) {
      AppLogger.warning('Plan price is negotiable, cannot initiate payment');
      emit(const PaymentFailed(
        failure: ValidationFailure(
          message: 'Bu tarif uchun narx kelishiladi',
        ),
      ));
      return;
    }

    final seatCharge = event.additionalSeats > 0 &&
            event.plan.additionalSeatPrice > 0
        ? event.additionalSeats * event.plan.additionalSeatPrice
        : 0;
    final amount = basePrice + seatCharge;

    emit(const PaymentLoading());

    final params = CreatePaymentParams(
      productType: PaymentProduct.subscription,
      plan: event.plan,
      billingCycle: event.cycle,
      seatCount: event.additionalSeats > 0 ? event.additionalSeats : null,
      gateway: _gatewayService.gateway,
      amount: amount,
    );

    await _createAndOpenCheckout(params, emit);
  }

  Future<void> _onSeatPaymentInitiated(
    SeatPaymentInitiated event,
    Emitter<PaymentState> emit,
  ) async {
    AppLogger.info(
      'Seat payment initiated: count=${event.seatCount} '
      'unitPrice=${event.unitPrice}',
    );

    if (event.seatCount <= 0 || event.unitPrice <= 0) {
      emit(const PaymentFailed(
        failure: ValidationFailure(
          message: 'Seat soni va narxi 0 dan katta bo\'lishi shart',
        ),
      ));
      return;
    }

    final amount = event.seatCount * event.unitPrice;
    emit(const PaymentLoading());

    final params = CreatePaymentParams(
      productType: PaymentProduct.additionalSeat,
      seatCount: event.seatCount,
      gateway: _gatewayService.gateway,
      amount: amount,
    );

    await _createAndOpenCheckout(params, emit);
  }

  Future<void> _onBoostPaymentInitiated(
    BoostPaymentInitiated event,
    Emitter<PaymentState> emit,
  ) async {
    AppLogger.info('Boost payment initiated: package=${event.package.id}');

    if (event.package.priceUzs <= 0) {
      emit(const PaymentFailed(
        failure: ValidationFailure(
          message: 'Boost narxi noto\'g\'ri',
        ),
      ));
      return;
    }

    emit(const PaymentLoading());

    final params = CreatePaymentParams(
      productType: PaymentProduct.boost,
      boostPackageId: event.package.id,
      gateway: _gatewayService.gateway,
      amount: event.package.priceUzs,
    );

    await _createAndOpenCheckout(params, emit);
  }

  Future<void> _createAndOpenCheckout(
    CreatePaymentParams params,
    Emitter<PaymentState> emit,
  ) async {
    final createResult = await _createPaymentUseCase(params);

    final payment = createResult.fold<Payment?>(
      (failure) {
        AppLogger.error('Payment creation failed: ${failure.message}');
        emit(PaymentFailed(failure: failure));
        return null;
      },
      (payment) => payment,
    );

    if (payment == null) return;

    AppLogger.info('Payment created: id=${payment.id} amount=${payment.amount}');

    final urlResult = await _gatewayService.getCheckoutUrl(payment);
    urlResult.fold(
      (failure) {
        AppLogger.error('Checkout URL fetch failed: ${failure.message}');
        emit(PaymentFailed(payment: payment, failure: failure));
      },
      (url) {
        AppLogger.info('Checkout URL ready: $url');
        emit(PaymentWebViewReady(payment, url));
      },
    );
  }

  Future<void> _onWebViewClosed(
    PaymentWebViewClosed event,
    Emitter<PaymentState> emit,
  ) async {
    final current = state;
    if (current is! PaymentWebViewReady) {
      AppLogger.warning(
        'PaymentWebViewClosed received in unexpected state: '
        '${current.runtimeType}',
      );
      return;
    }

    AppLogger.info('WebView closed, polling status for ${current.payment.id}');
    emit(PaymentProcessing(current.payment));
    add(PaymentStatusChecked(current.payment.id));
  }

  Future<void> _onStatusChecked(
    PaymentStatusChecked event,
    Emitter<PaymentState> emit,
  ) async {
    final current = state;
    if (current is! PaymentProcessing) {
      AppLogger.warning(
        'PaymentStatusChecked received in unexpected state: '
        '${current.runtimeType}',
      );
      return;
    }

    final payment = current.payment;

    // One-shot read first so we settle immediately if the gateway already
    // knows the terminal status.
    final initial = await _getPaymentStatusUseCase(IdParams(payment.id));
    final initialSettled = initial.fold<bool>(
      (failure) {
        AppLogger.error('Initial status read failed: ${failure.message}');
        emit(PaymentFailed(payment: payment, failure: failure));
        return true;
      },
      (status) => _emitForStatus(payment, status, emit),
    );

    if (initialSettled) return;

    // Subscribe to the status stream until a terminal state is emitted.
    // [emit.onEach] auto-cancels when the bloc is closed.
    await emit.onEach<Either<Failure, PaymentStatus>>(
      _watchPaymentStatusUseCase(payment.id),
      onData: (result) {
        result.fold(
          (failure) {
            AppLogger.error('Status stream error: ${failure.message}');
            emit(PaymentFailed(payment: payment, failure: failure));
          },
          (status) => _emitForStatus(payment, status, emit),
        );
      },
      onError: (error, stackTrace) {
        AppLogger.error('Status stream exception', error, stackTrace);
        emit(PaymentFailed(
          payment: payment,
          failure: const ServerFailure(
            message: 'To\'lov holatini tekshirishda xatolik',
          ),
        ));
      },
    );
  }

  /// Emits a terminal state for [status] and returns `true` if [status] is
  /// terminal (so the caller can stop further polling), `false` otherwise.
  bool _emitForStatus(
    Payment payment,
    PaymentStatus status,
    Emitter<PaymentState> emit,
  ) {
    switch (status) {
      case PaymentStatus.success:
        AppLogger.info('Payment succeeded: ${payment.id}');
        emit(PaymentSuccess(payment.copyWith(
          status: status,
          completedAt: DateTime.now(),
        )));
        return true;
      case PaymentStatus.failed:
        AppLogger.warning('Payment failed: ${payment.id}');
        emit(PaymentFailed(
          payment: payment.copyWith(status: status),
          failure: const ServerFailure(message: 'To\'lov amalga oshmadi'),
        ));
        return true;
      case PaymentStatus.cancelled:
        AppLogger.info('Payment cancelled by gateway: ${payment.id}');
        emit(PaymentCancelled(payment: payment.copyWith(status: status)));
        return true;
      case PaymentStatus.refunded:
        AppLogger.info('Payment refunded: ${payment.id}');
        emit(PaymentSuccess(payment.copyWith(status: status)));
        return true;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        // Non-terminal — stay in PaymentProcessing.
        return false;
    }
  }

  Future<void> _onCancelledByUser(
    PaymentCancelledByUser event,
    Emitter<PaymentState> emit,
  ) async {
    final current = state;
    Payment? payment;
    if (current is PaymentWebViewReady) {
      payment = current.payment;
    } else if (current is PaymentProcessing) {
      payment = current.payment;
    }

    if (payment == null) {
      AppLogger.info('Cancellation requested before payment was created');
      emit(const PaymentCancelled());
      return;
    }

    AppLogger.info('User cancelled payment: ${payment.id}');
    final result = await _cancelPaymentUseCase(IdParams(payment.id));
    result.fold(
      (failure) {
        AppLogger.warning(
          'Cancel call failed (settling locally): ${failure.message}',
        );
        emit(PaymentCancelled(payment: payment));
      },
      (cancelled) => emit(PaymentCancelled(payment: cancelled)),
    );
  }

  void _onReset(PaymentReset event, Emitter<PaymentState> emit) {
    AppLogger.info('Payment bloc reset');
    emit(const PaymentInitial());
  }
}
