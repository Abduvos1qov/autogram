import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/empty_view.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../widgets/seller_storefront_about.dart';

/// Standalone screen presenting the seller's About content (working hours,
/// contact channels, address, etc.). Replaces the old "About" tab — accessed
/// via the info-icon button in the storefront action row.
class AboutSellerScreen extends StatelessWidget {
  const AboutSellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        title: Text(
          'seller.storefront.tabs.about'.tr(),
          style: AppTypography.titleMedium(context).copyWith(
            fontWeight: AppTypography.bold,
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (prev, curr) => prev.sellerProfile != curr.sellerProfile,
        builder: (context, state) {
          final seller = state.sellerProfile;
          if (seller == null) {
            return EmptyView(
              icon: Icons.storefront_outlined,
              title: 'seller.storefront.empty.about_title'.tr(),
              message: 'seller.storefront.empty.about_message'.tr(),
            );
          }
          return SellerStorefrontAbout(
            seller: seller,
            onPhoneTap: (phone) => _launch('tel:$phone'),
            onTelegramTap: (handle) => _launch(
              'https://t.me/${handle.replaceAll('@', '')}',
            ),
            onInstagramTap: (handle) => _launch(
              'https://instagram.com/${handle.replaceAll('@', '')}',
            ),
            onFacebookTap: (handle) => _launch(
              handle.startsWith('http')
                  ? handle
                  : 'https://facebook.com/${handle.replaceAll('@', '')}',
            ),
            onYoutubeTap: (handle) => _launch(
              handle.startsWith('http')
                  ? handle
                  : 'https://youtube.com/${handle.startsWith('@') ? handle : '@$handle'}',
            ),
            onWebsiteTap: (url) => _launch(
              url.startsWith('http') ? url : 'https://$url',
            ),
          );
        },
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
