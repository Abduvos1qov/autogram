import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/coming_soon_view.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        title: const Text('Yordam markazi'),
      ),
      body: const SafeArea(
        child: ComingSoonView(icon: Icons.headset_mic_outlined),
      ),
    );
  }
}
