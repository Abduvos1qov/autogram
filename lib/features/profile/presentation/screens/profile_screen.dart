import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/error_view.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../views/buyer_profile_view.dart';
import '../views/profile_loading_view.dart';
import '../views/seller_storefront_view.dart';

/// Top-level profile tab. Splits the rendering between [BuyerProfileView]
/// and [SellerStorefrontView] based on `state.isSellerView`. The bloc owns
/// both data shapes (buyer + seller storefront) so this widget never has to
/// deal with multiple BlocProviders.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProfileBloc>();
    if (bloc.state.profile == null) {
      bloc.add(const ProfileLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Status bar styling is owned by each child view (BuyerProfileView wraps
    // its dark header in `light`; SellerStorefrontView toggles between
    // `light` and `dark` based on cover scroll). We avoid wrapping the whole
    // screen in another AnnotatedRegion to prevent the layered priorities
    // from conflicting.
    return Scaffold(
      backgroundColor: AppColors.surfaceOf(context),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.profile != curr.profile ||
            prev.sellerProfile != curr.sellerProfile,
        builder: (context, state) {
          // Initial state: hit the bloc and show loading. Avoids the
          // single-frame blank flash the original screen had between
          // `initState` and the first `loading` emit.
          //
          // The `state.profile == null` guard keeps the loaded view on
          // screen during pull-to-refresh — the bloc briefly toggles back
          // to `loading` to force a stream emit (so the RefreshIndicator
          // resolves) but we don't want to flash the loading shimmer.
          if (state.profile == null &&
              (state.status == ProfileStatus.initial || state.isLoading)) {
            return const ProfileLoadingView();
          }

          if (state.hasError && state.profile == null) {
            return ErrorView(
              failure: state.failure,
              onRetry: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileLoadRequested()),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return const SizedBox.shrink();
          }

          if (state.isSellerView) {
            return SellerStorefrontView(
              user: profile,
              seller: state.sellerProfile!,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<ProfileBloc>();
              bloc.add(const ProfileRefreshRequested());
              // Refresh doesn't toggle `loading` (we keep current data
              // visible), so we wait for the next `loaded` emit instead of
              // `!isLoading` (which would match immediately).
              await bloc.stream.firstWhere(
                (s) => s.status == ProfileStatus.loaded ||
                    s.status == ProfileStatus.error,
              );
            },
            child: BuyerProfileView(profile: profile),
          );
        },
      ),
    );
  }
}
