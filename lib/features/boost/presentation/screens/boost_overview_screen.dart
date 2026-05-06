import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/coming_soon_view.dart';

class BoostOverviewScreen extends StatelessWidget {
  const BoostOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        title: const Text('Boost'),
      ),
      body: const SafeArea(
        child: ComingSoonView(icon: Icons.local_fire_department_outlined),
      ),
    );
  }
}
