import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/error_handler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../navigation/route_names.dart';
import '../../../payment/domain/entities/billing_cycle.dart';
import '../../domain/entities/seller_profile.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';
import '../widgets/step_progress_bar.dart';

/// Upgrade entry point — the seller-tier picker (formerly business type
/// selection). Shows 3 tabs (Pro / Premium / Enterprise) with marketing
/// headlines, animated tab swap, and a "Stay on Free" link as a low-key escape
/// hatch. Tapping Continue advances to [BusinessInfoScreen].

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  static const List<SubscriptionPlan> _tabs = [
    SubscriptionPlan.pro,
    SubscriptionPlan.premium,
    SubscriptionPlan.enterprise,
  ];

  SubscriptionPlan _activeTab = SubscriptionPlan.pro;
  BillingCycle _billingCycle = BillingCycle.monthly;
  int _slideDirection = 1;

  void _onTabChanged(SubscriptionPlan plan) {
    if (plan == _activeTab) return;
    final next = _tabs.indexOf(plan);
    final prev = _tabs.indexOf(_activeTab);
    setState(() {
      _slideDirection = next > prev ? 1 : -1;
      _activeTab = plan;
    });
  }

  void _handleContinue() {
    if (_activeTab == SubscriptionPlan.enterprise) {
      _showEnterpriseContactDialog();
      return;
    }
    context.read<SellerBloc>().add(
      SellerPlanSelected(_activeTab, _billingCycle),
    );
    context.push(RoutePaths.upgradeBusinessInfo);
  }

  void _continueWithFree() {
    context.read<SellerBloc>().add(
      const SellerPlanSelected(SubscriptionPlan.free, BillingCycle.monthly),
    );
    context.push(RoutePaths.upgradeBusinessInfo);
  }

  void _showEnterpriseContactDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('seller.plan_selection.enterprise_dialog_title'.tr()),
        content: Text('seller.plan_selection.enterprise_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('seller.plan_selection.enterprise_dialog_close'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'seller.plan_selection.enterprise_contact_placeholder'.tr(),
                  ),
                ),
              );
            },
            child: Text('seller.plan_selection.enterprise_dialog_contact'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerBloc, SellerState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.hasError && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorHandler.getUserMessage(state.failure!)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundOf(context),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<SellerBloc>().add(const SellerUpgradeFlowReset());
              context.pop();
            },
          ),
          title: Text('seller.plan_selection.app_bar_title'.tr()),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: AppSpacing.screenPadding,
                child: const StepProgressBar(currentStep: 0, totalSteps: 2),
              ),
              AppSpacing.gapVerticalMd,
              _Headline(plan: _activeTab),
              AppSpacing.gapVerticalLg,
              Padding(
                padding: AppSpacing.paddingHorizontalMd,
                child: _PlanTabBar(
                  tabs: _tabs,
                  active: _activeTab,
                  onChanged: _onTabChanged,
                ),
              ),
              AppSpacing.gapVerticalLg,
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final offsetTween = Tween<Offset>(
                      begin: Offset(_slideDirection * 0.05, 0),
                      end: Offset.zero,
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: animation.drive(offsetTween),
                        child: child,
                      ),
                    );
                  },
                  child: _PlanTabBody(
                    key: ValueKey<SubscriptionPlan>(_activeTab),
                    plan: _activeTab,
                    billingCycle: _billingCycle,
                    onBillingChanged: (cycle) =>
                        setState(() => _billingCycle = cycle),
                  ),
                ),
              ),
              _BottomBar(
                plan: _activeTab,
                onContinue: _handleContinue,
                onStayOnFree: _continueWithFree,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Headline (animated marketing title + tagline)
// ============================================================

class _Headline extends StatelessWidget {
  final SubscriptionPlan plan;

  const _Headline({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontalMd,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeIn,
        child: Column(
          key: ValueKey<SubscriptionPlan>(plan),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'seller.plan_selection.headlines.${plan.name}'.tr(),
              style: AppTypography.headlineSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.gapVerticalXs,
            Text(
              'seller.plan_selection.taglines.${plan.name}'.tr(),
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondaryOf(context)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Pill tab bar (3 segments, animated indicator)
// ============================================================

class _PlanTabBar extends StatelessWidget {
  final List<SubscriptionPlan> tabs;
  final SubscriptionPlan active;
  final ValueChanged<SubscriptionPlan> onChanged;

  const _PlanTabBar({
    required this.tabs,
    required this.active,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / tabs.length;
          final activeIndex = tabs.indexOf(active);
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: activeIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: tabs.map((plan) {
                  final isActive = plan == active;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onChanged(plan),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTypography.labelMedium(context).copyWith(
                              color: isActive
                                  ? AppColors.white
                                  : AppColors.textSecondaryOf(context),
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            child: Text(
                              'seller.plan_selection.tabs.${plan.name}'.tr(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// Tab body (per-plan content)
// ============================================================

class _PlanTabBody extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;
  final ValueChanged<BillingCycle> onBillingChanged;

  const _PlanTabBody({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.onBillingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnterprise = plan == SubscriptionPlan.enterprise;
    return SingleChildScrollView(
      padding: AppSpacing.paddingHorizontalMd,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriceBlock(plan: plan, billingCycle: billingCycle),
          AppSpacing.gapVerticalLg,
          if (!isEnterprise) ...[
            _BillingToggle(
              billingCycle: billingCycle,
              onChanged: onBillingChanged,
            ),
            AppSpacing.gapVerticalLg,
          ],
          _FeatureList(features: plan.features),
          AppSpacing.gapVerticalXl,
        ],
      ),
    );
  }
}

// ============================================================
// Price block with animated digit interpolation
// ============================================================

class _PriceBlock extends StatelessWidget {
  final SubscriptionPlan plan;
  final BillingCycle billingCycle;

  const _PriceBlock({required this.plan, required this.billingCycle});

  @override
  Widget build(BuildContext context) {
    final isFree = plan == SubscriptionPlan.free;
    final isYearly = billingCycle == BillingCycle.yearly;
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final isNegotiable = price == -1;

    if (isFree) {
      return _PriceLabel(
        primary: 'seller.ui.free_price'.tr(),
        secondary: plan.audienceLabelKey.tr(),
        primaryColor: AppColors.successOf(context),
      );
    }

    if (isNegotiable) {
      return _PriceLabel(
        primary: 'seller.ui.negotiable'.tr(),
        secondary: plan.audienceLabelKey.tr(),
        primaryColor: AppColors.textPrimaryOf(context),
      );
    }

    final suffix = isYearly
        ? 'seller.ui.price_per_year'.tr()
        : 'seller.ui.price_per_month'.tr();
    final savePercent = _yearlyDiscountPercent(plan);

    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _AnimatedPrice(price: price, suffix: suffix),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isYearly && savePercent > 0 ? 1 : 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successOf(context),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'seller.plan_selection.save_percent'.tr(
                      namedArgs: {'percent': '$savePercent'},
                    ),
                    style: AppTypography.labelSmall(context).copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalSm,
          Text(
            plan.audienceLabelKey.tr(),
            style: AppTypography.bodySmall(
              context,
            ).copyWith(color: AppColors.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }

  static int _yearlyDiscountPercent(SubscriptionPlan plan) {
    final monthly = plan.monthlyPrice;
    final yearly = plan.yearlyPrice;
    if (monthly <= 0 || yearly <= 0) return 0;
    final fullYear = monthly * 12;
    if (fullYear <= 0) return 0;
    final saved = fullYear - yearly;
    if (saved <= 0) return 0;
    return ((saved / fullYear) * 100).round();
  }
}

class _PriceLabel extends StatelessWidget {
  final String primary;
  final String secondary;
  final Color primaryColor;

  const _PriceLabel({
    required this.primary,
    required this.secondary,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            primary,
            style: AppTypography.headlineSmall(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          AppSpacing.gapVerticalSm,
          Text(
            secondary,
            style: AppTypography.bodySmall(
              context,
            ).copyWith(color: AppColors.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPrice extends StatefulWidget {
  final int price;
  final String suffix;

  const _AnimatedPrice({required this.price, required this.suffix});

  @override
  State<_AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<_AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _animation = AlwaysStoppedAnimation(widget.price.toDouble());
  }

  @override
  void didUpdateWidget(_AnimatedPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price != widget.price) {
      _animation =
          Tween<double>(
            begin: oldWidget.price.toDouble(),
            end: widget.price.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return RichText(
          text: TextSpan(
            style: AppTypography.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryOf(context),
            ),
            children: [
              TextSpan(
                text: Formatters.formatPrice(_animation.value, currency: 'UZS'),
              ),
              TextSpan(
                text: widget.suffix,
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.textSecondaryOf(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Billing cycle toggle (Monthly / Yearly pill)
// ============================================================

class _BillingToggle extends StatelessWidget {
  final BillingCycle billingCycle;
  final ValueChanged<BillingCycle> onChanged;

  const _BillingToggle({required this.billingCycle, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerOf(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        children: BillingCycle.values.map((cycle) {
          final isActive = billingCycle == cycle;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(cycle),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: Center(
                  child: Text(
                    cycle == BillingCycle.monthly
                        ? 'seller.plan_selection.billing_monthly'.tr()
                        : 'seller.plan_selection.billing_yearly'.tr(),
                    style: AppTypography.labelMedium(context).copyWith(
                      color: isActive
                          ? AppColors.white
                          : AppColors.textSecondaryOf(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============================================================
// Feature list (rows of check + text)
// ============================================================

class _FeatureList extends StatelessWidget {
  final List<String> features;

  const _FeatureList({required this.features});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.bodyMedium(context),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ============================================================
// Bottom bar (CTA + Stay on Free link)
// ============================================================

class _BottomBar extends StatefulWidget {
  final SubscriptionPlan plan;
  final VoidCallback onContinue;
  final VoidCallback onStayOnFree;

  const _BottomBar({
    required this.plan,
    required this.onContinue,
    required this.onStayOnFree,
  });

  @override
  State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  bool _pressed = false;

  String get _ctaLabel {
    if (widget.plan == SubscriptionPlan.enterprise) {
      return 'seller.plan_selection.enterprise_button'.tr();
    }
    return 'seller.plan_selection.default_button'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.screenPadding.copyWith(
        top: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              child: PrimaryButton(
                text: _ctaLabel,
                onPressed: widget.onContinue,
              ),
            ),
          ),
          AppSpacing.gapVerticalSm,
          TextButton(
            onPressed: widget.onStayOnFree,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondaryOf(context),
            ),
            child: Text(
              'seller.plan_selection.stay_on_free'.tr(),
              style: AppTypography.bodySmall(context).copyWith(
                decoration: TextDecoration.underline,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
