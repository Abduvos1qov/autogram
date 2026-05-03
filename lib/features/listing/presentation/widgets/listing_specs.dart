import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/listing.dart';

/// Listing specifications widget

class ListingSpecs extends StatelessWidget {
  final AutoDetails autoDetails;

  const ListingSpecs({
    super.key,
    required this.autoDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Main specs row
          Row(
            children: [
              if (autoDetails.year != null)
                Expanded(child: _buildSpecItem(context,'Yil', '${autoDetails.year}')),
              if (autoDetails.mileage != null)
                Expanded(child: _buildSpecItem(context,'Yurgan', Formatters.formatMileage(autoDetails.mileage!))),
              if (autoDetails.engineVolume != null)
                Expanded(child: _buildSpecItem(context,'Dvigatel', '${autoDetails.engineVolume}L')),
            ],
          ),
          const Divider(height: 24),

          // Detailed specs
          _buildSpecRow(context,'Marka', autoDetails.brand),
          _buildSpecRow(context,'Model', autoDetails.model),
          _buildSpecRow(context,'Uzatmalar qutisi', _getTransmissionLabel(autoDetails.transmission)),
          _buildSpecRow(context,'Yoqilg\'i turi', _getFuelLabel(autoDetails.fuelType)),
          _buildSpecRow(context,'Kuzov turi', _getBodyLabel(autoDetails.bodyType)),
          _buildSpecRow(context,'Haydovchi turi', _getDriveLabel(autoDetails.driveType)),
          _buildSpecRow(context,'Rang', autoDetails.color),
          _buildSpecRow(context,'Holati', _getConditionLabel(autoDetails.condition)),
          _buildSpecRow(context,'Avariya', autoDetails.hasAccident ? 'Ha' : 'Yo\'q'),
          _buildSpecRow(context,'Egalar soni', '${autoDetails.ownersCount}'),

          // Features
          if (autoDetails.features.isNotEmpty) ...[
            const Divider(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qo\'shimcha jihozlar',
                style: AppTypography.titleSmall(context),
              ),
            ),
            AppSpacing.gapVerticalSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: autoDetails.features.map((feature) {
                return Chip(
                  label: Text(feature),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: AppTypography.labelSmall(context).copyWith(
                    color: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall(context).copyWith(
            color: AppColors.textSecondaryOf(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String? _getTransmissionLabel(String? value) {
    switch (value) {
      case 'automatic':
        return 'Avtomat';
      case 'manual':
        return 'Mexanik';
      default:
        return value;
    }
  }

  String? _getFuelLabel(String? value) {
    switch (value) {
      case 'petrol':
        return 'Benzin';
      case 'diesel':
        return 'Dizel';
      case 'gas':
        return 'Gaz';
      case 'electric':
        return 'Elektr';
      case 'hybrid':
        return 'Gibrid';
      default:
        return value;
    }
  }

  String? _getBodyLabel(String? value) {
    switch (value) {
      case 'sedan':
        return 'Sedan';
      case 'suv':
        return 'SUV';
      case 'hatchback':
        return 'Xetchbek';
      case 'wagon':
        return 'Universal';
      case 'coupe':
        return 'Kupe';
      case 'convertible':
        return 'Kabriolet';
      case 'minivan':
        return 'Miniven';
      case 'pickup':
        return 'Pikap';
      default:
        return value;
    }
  }

  String? _getDriveLabel(String? value) {
    switch (value) {
      case 'front':
        return 'Oldingi';
      case 'rear':
        return 'Orqa';
      case 'all':
        return 'To\'liq';
      default:
        return value;
    }
  }

  String? _getConditionLabel(String? value) {
    switch (value) {
      case 'new':
        return 'Yangi';
      case 'excellent':
        return 'A\'lo';
      case 'good':
        return 'Yaxshi';
      case 'fair':
        return 'Qoniqarli';
      default:
        return value;
    }
  }
}
