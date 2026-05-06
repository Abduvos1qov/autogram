import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/coming_soon_view.dart';

class LikedScreen extends StatelessWidget {
  const LikedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      appBar: AppBar(
        title: const Text('Yoqtirgan e\'lonlar'),
      ),
      body: const SafeArea(
        child: ComingSoonView(icon: Icons.favorite_outline),
      ),
    );
  }
}
