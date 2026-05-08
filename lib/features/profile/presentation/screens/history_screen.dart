import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/coming_soon_view.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        title: Text('profile.history'.tr()),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceOf(context),
      ),
      body: const SafeArea(
        child: ComingSoonView(icon: Icons.history),
      ),
    );
  }
}
