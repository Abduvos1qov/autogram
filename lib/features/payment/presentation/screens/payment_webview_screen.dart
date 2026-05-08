import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/test_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../navigation/route_names.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

/// Hosts the payment-gateway WebView (Click / Payme / Octobank).
///
/// In test mode the gateway WebView is bypassed: the screen shows a
/// "processing" placeholder and immediately dispatches
/// [PaymentWebViewClosed] so the bloc starts polling
/// [MockPaymentGatewayService] which auto-succeeds after ~5 seconds.
///
/// In production the gateway redirects to a return URL on terminal events
/// (`/payment/return?status=...`); we intercept that URL via
/// [NavigationDelegate.onNavigationRequest] and dispatch
/// [PaymentWebViewClosed] to let the bloc settle the final status.
class PaymentWebViewScreen extends StatefulWidget {
  final PaymentWebViewReady state;

  const PaymentWebViewScreen({super.key, required this.state});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _gatewayClosedDispatched = false;

  @override
  void initState() {
    super.initState();
    if (TestConfig.isTestMode) {
      // Mock gateway — skip the real WebView and immediately ask the bloc
      // to start polling the mocked status stream.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _gatewayClosedDispatched) return;
        _gatewayClosedDispatched = true;
        context.read<PaymentBloc>().add(const PaymentWebViewClosed());
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.surface)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.state.checkoutUrl));
  }

  /// Intercepts gateway return URLs.
  ///
  /// Click/Payme/Octobank redirect to a configured return URL (e.g.
  /// `https://autogram.uz/payment/return?status=success&payment_id=...`)
  /// once the user finishes the flow. We catch that URL, prevent the
  /// in-app navigation, and ask the bloc to poll the gateway for the
  /// authoritative status. The Phase 6 Click integration may extend this
  /// with gateway-specific URL schemes.
  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (request.url.contains('/payment/return')) {
      _dispatchGatewayClosed();
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _dispatchGatewayClosed() {
    if (_gatewayClosedDispatched || !mounted) return;
    _gatewayClosedDispatched = true;
    context.read<PaymentBloc>().add(const PaymentWebViewClosed());
  }

  /// Confirms exit, then cancels the in-flight payment.
  /// Returns `true` when the user agreed to exit.
  Future<bool> _confirmExitAndCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('payment.exit_confirm_title'.tr()),
        content: Text('payment.exit_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('payment.exit_confirm_no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'payment.exit_confirm_yes'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PaymentBloc>().add(const PaymentCancelledByUser());
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      listener: (context, state) {
        if (state is PaymentSuccess) {
          context.go(RoutePaths.upgradeSuccess);
          return;
        }
        if (state is PaymentFailed || state is PaymentCancelled) {
          // Pop back to PaymentScreen, which renders the failed / cancelled
          // UI from the same bloc state. If the back-stack is empty (e.g.
          // deep-linked into webview), bounce back to the upgrade entry.
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RoutePaths.upgrade);
          }
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final shouldExit = await _confirmExitAndCancel();
          if (shouldExit && mounted) {
            // Bloc emits PaymentCancelled; the listener above pops the route.
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.backgroundOf(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textPrimaryOf(context),
              ),
              onPressed: _confirmExitAndCancel,
            ),
            title: Text(
              'payment.webview_title'.tr(),
              style: AppTypography.titleLarge(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: TestConfig.isTestMode
              ? _buildTestModeBody(context)
              : _buildWebViewBody(context),
        ),
      ),
    );
  }

  Widget _buildTestModeBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            AppSpacing.gapVerticalLg,
            Text(
              '${'payment.processing'.tr()} (mock)',
              style: AppTypography.titleMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapVerticalSm,
            Text(
              'Payment ID: ${widget.state.payment.id}',
              style: AppTypography.bodySmall(
                context,
              ).copyWith(color: AppColors.textSecondaryOf(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewBody(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
