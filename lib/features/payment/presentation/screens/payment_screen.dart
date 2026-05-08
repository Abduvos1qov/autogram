import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/buttons/secondary_button.dart';
import '../../../../navigation/route_names.dart';
import '../../domain/entities/payment_product.dart';
import '../../domain/entities/payment_request.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../widgets/payment_status_view.dart';
import '../widgets/payment_summary_card.dart';

/// Checkout screen — renders the order summary and the pay CTA, then drives
/// the WebView opening / processing / terminal flow off [PaymentBloc] state.
///
/// [PaymentBloc] is provided globally in `app.dart`, so this screen does NOT
/// wrap a [BlocProvider] — it reads the bloc out of the ambient scope.
class PaymentScreen extends StatefulWidget {
  final PaymentRequest request;

  const PaymentScreen({super.key, required this.request});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _webViewPushed = false;

  @override
  void initState() {
    super.initState();
    // Reset the bloc when entering the checkout — guards against leftover
    // terminal state from a previous purchase (the bloc is app-scoped).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<PaymentBloc>();
      if (bloc.state is! PaymentInitial) {
        bloc.add(const PaymentReset());
      }
    });
  }

  void _handlePayPressed() {
    final bloc = context.read<PaymentBloc>();
    final r = widget.request;
    switch (r.productType) {
      case PaymentProduct.subscription:
        final plan = r.plan;
        final cycle = r.billingCycle;
        if (plan == null || cycle == null) return;
        bloc.add(PaymentInitiated(
          plan: plan,
          cycle: cycle,
          additionalSeats: 0,
        ));
        break;
      case PaymentProduct.additionalSeat:
        final seatCount = r.seatCount;
        final unitPrice = r.unitSeatPrice;
        if (seatCount == null || unitPrice == null) return;
        bloc.add(SeatPaymentInitiated(
          seatCount: seatCount,
          unitPrice: unitPrice,
        ));
        break;
      case PaymentProduct.boost:
        final pkg = r.boostPackage;
        if (pkg == null) return;
        bloc.add(BoostPaymentInitiated(pkg));
        break;
    }
  }

  void _handleRetry() => _handlePayPressed();

  /// Show the cancel-confirmation dialog and, if confirmed, dispatch
  /// [PaymentCancelledByUser]. Returns `true` when the screen may be popped.
  Future<bool> _confirmExit() async {
    final bloc = context.read<PaymentBloc>();
    final blocState = bloc.state;
    // Idle / terminal — no in-flight payment, allow pop without prompting.
    if (blocState is PaymentInitial ||
        blocState is PaymentSuccess ||
        blocState is PaymentFailed ||
        blocState is PaymentCancelled) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('payment.exit_confirm_title'.tr()),
          content: Text('payment.exit_confirm_message'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('payment.exit_confirm_no'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'payment.exit_confirm_yes'.tr(),
                style: TextStyle(color: AppColors.errorOf(dialogContext)),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return false;
    if (shouldExit == true) {
      bloc.add(const PaymentCancelledByUser());
      return true;
    }
    return false;
  }

  Future<void> _handleBackPressed() async {
    final shouldPop = await _confirmExit();
    if (!mounted) return;
    if (shouldPop) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          title: Text(
            'payment.title'.tr(),
            style: AppTypography.titleLarge(context),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackPressed,
          ),
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: _onStateChange,
          builder: _buildBody,
        ),
      ),
    );
  }

  void _onStateChange(BuildContext _, PaymentState state) {
    if (state is PaymentWebViewReady && !_webViewPushed) {
      _webViewPushed = true;
      // Push the gateway WebView; when it pops the bloc transitions to
      // PaymentProcessing via PaymentWebViewClosed dispatched there.
      Future.microtask(() {
        if (!mounted) return;
        context
            .push<void>(RoutePaths.paymentWebView, extra: state)
            .whenComplete(() {
          _webViewPushed = false;
        });
      });
    }
  }

  Widget _buildBody(BuildContext context, PaymentState state) {
    if (state is PaymentInitial ||
        state is PaymentLoading ||
        state is PaymentWebViewReady) {
      return _SummaryAndCta(
        request: widget.request,
        isLoading: state is PaymentLoading || state is PaymentWebViewReady,
        onPay: _handlePayPressed,
      );
    }

    if (state is PaymentProcessing) {
      return SingleChildScrollView(
        child: PaymentStatusView.processing(payment: state.payment),
      );
    }

    if (state is PaymentSuccess) {
      return SingleChildScrollView(
        child: PaymentStatusView.success(
          payment: state.payment,
          actionButton: PrimaryButton(
            text: 'auth.continue'.tr(),
            onPressed: () => context.go(RoutePaths.upgradeSuccess),
          ),
        ),
      );
    }

    if (state is PaymentFailed) {
      return SingleChildScrollView(
        child: PaymentStatusView.failed(
          failure: state.failure,
          actionButton: Column(
            children: [
              PrimaryButton(
                text: 'payment.retry'.tr(),
                onPressed: _handleRetry,
              ),
              AppSpacing.gapVerticalMd,
              SecondaryButton(
                text: 'payment.cancel_button'.tr(),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }

    if (state is PaymentCancelled) {
      return SingleChildScrollView(
        child: PaymentStatusView.cancelled(
          actionButton: PrimaryButton(
            text: 'payment.back_to_plans'.tr(),
            onPressed: () => context.pop(),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Summary + pay CTA — shown for [PaymentInitial], [PaymentLoading] and
/// [PaymentWebViewReady] (the latter while the WebView is being pushed).
class _SummaryAndCta extends StatelessWidget {
  final PaymentRequest request;
  final bool isLoading;
  final VoidCallback onPay;

  const _SummaryAndCta({
    required this.request,
    required this.isLoading,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screenPaddingHorizontal,
        child: Column(
          children: [
            AppSpacing.gapVerticalMd,
            Expanded(
              child: SingleChildScrollView(
                child: PaymentSummaryCard(request: request),
              ),
            ),
            AppSpacing.gapVerticalMd,
            PrimaryButton(
              text: 'payment.pay_button'.tr(),
              isLoading: isLoading,
              onPressed: onPay,
            ),
            AppSpacing.gapVerticalMd,
          ],
        ),
      ),
    );
  }
}
