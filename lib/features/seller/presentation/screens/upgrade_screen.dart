import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/seller_profile.dart';
import '../bloc/seller_bloc.dart';
import '../bloc/seller_event.dart';
import '../bloc/seller_state.dart';
import '../widgets/type_card.dart';

/// Upgrade to seller screen - Step 1: Business type selection

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerBloc, SellerState>(
      listener: (context, state) {
        if (state.currentStep == 1 && state.selectedBusinessType != null) {
          context.push('/upgrade/business-info');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context.read<SellerBloc>().add(const SellerUpgradeFlowReset());
                context.pop();
              },
            ),
            title: const Text('Sotuvchi bo\'lish'),
          ),
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  _buildProgressIndicator(0),
                  AppSpacing.gapVerticalXl,

                  // Header
                  Text(
                    'Biznes turini tanlang',
                    style: AppTypography.headlineSmall,
                  ),
                  AppSpacing.gapVerticalSm,
                  Text(
                    'Sizning faoliyat turingizni tanlang',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.gapVerticalXl,

                  // Business type cards
                  Expanded(
                    child: ListView(
                      children: BusinessType.values.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TypeCard(
                            type: type,
                            isSelected: state.selectedBusinessType == type,
                            onTap: () {
                              context.read<SellerBloc>().add(
                                    SellerBusinessTypeSelected(type),
                                  );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int step) {
    return Row(
      children: List.generate(3, (index) {
        final isCompleted = index < step;
        final isCurrent = index == step;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent
                  ? AppColors.primary
                  : AppColors.grey200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
