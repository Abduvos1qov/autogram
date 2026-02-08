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
                Expanded(child: _buildSpecItem('Yil', '${autoDetails.year}')),
              if (autoDetails.mileage != null)
                Expanded(child: _buildSpecItem('Yurgan', Formatters.formatMileage(autoDetails.mileage!))),
              if (autoDetails.engineVolume != null)
                Expanded(child: _buildSpecItem('Dvigatel', '${autoDetails.engineVolume}L')),
            ],
          ),
          const Divider(height: 24),

          // Detailed specs
          _buildSpecRow('Marka', autoDetails.brand),
          _buildSpecRow('Model', autoDetails.model),
          _buildSpecRow('Uzatmalar qutisi', _getTransmissionLabel(autoDetails.transmission)),
          _buildSpecRow('Yoqilg\'i turi', _getFuelLabel(autoDetails.fuelType)),
          _buildSpecRow('Kuzov turi', _getBodyLabel(autoDetails.bodyType)),
          _buildSpecRow('Haydovchi turi', _getDriveLabel(autoDetails.driveType)),
          _buildSpecRow('Rang', autoDetails.color),
          _buildSpecRow('Holati', _getConditionLabel(autoDetails.condition)),
          _buildSpecRow('Avariya', autoDetails.hasAccident ? 'Ha' : 'Yo\'q'),
          _buildSpecRow('Egalar soni', '${autoDetails.ownersCount}'),

          // Features
          if (autoDetails.features.isNotEmpty) ...[
            const Divider(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qo\'shimcha jihozlar',
                style: AppTypography.titleSmall,
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
                  labelStyle: AppTypography.labelSmall.copyWith(
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

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
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
