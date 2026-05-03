import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/media/avatar.dart';

/// Stories bar - horizontal scrollable list of seller stories

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual stories data from BLoC
    final stories = List.generate(
      10,
      (index) => StoryItem(
        id: 'story_$index',
        sellerName: 'Salon ${index + 1}',
        logoUrl: null,
        hasUnseenStory: index < 5,
      ),
    );

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerLight),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < stories.length - 1 ? AppSpacing.md : 0,
            ),
            child: StoryAvatar(
              imageUrl: story.logoUrl,
              name: story.sellerName,
              hasUnseenStory: story.hasUnseenStory,
              size: 64,
              onTap: () {
                // TODO: Navigate to story viewer
              },
            ),
          );
        },
      ),
    );
  }
}

class StoryItem {
  final String id;
  final String sellerName;
  final String? logoUrl;
  final bool hasUnseenStory;

  const StoryItem({
    required this.id,
    required this.sellerName,
    this.logoUrl,
    required this.hasUnseenStory,
  });
}

/// Featured sellers bar - alternative to stories

class FeaturedSellersBar extends StatelessWidget {
  const FeaturedSellersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mashhur salonlar',
                style: AppTypography.titleMedium(context),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all sellers
                },
                child: const Text('Barchasi'),
              ),
            ],
          ),
          AppSpacing.gapVerticalSm,
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(
                    right: index < 4 ? AppSpacing.md : 0,
                  ),
                  child: Column(
                    children: [
                      AppAvatar(
                        name: 'Salon ${index + 1}',
                        size: AvatarSize.xl,
                        isVerified: index < 3,
                      ),
                      AppSpacing.gapVerticalSm,
                      Text(
                        'Salon ${index + 1}',
                        style: AppTypography.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${(index + 1) * 15} ta e\'lon',
                        style: AppTypography.labelSmall(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
