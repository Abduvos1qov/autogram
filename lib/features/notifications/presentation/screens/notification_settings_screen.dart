import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/coming_soon_view.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        title: const Text('Bildirishnoma sozlamalari'),
      ),
      body: const SafeArea(
        child: ComingSoonView(icon: Icons.notifications_outlined),
      ),
    );
  }
}
