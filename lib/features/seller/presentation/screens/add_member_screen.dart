import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../bloc/team/team_bloc.dart';
import '../bloc/team/team_event.dart';
import '../bloc/team/team_state.dart';
import '../widgets/role_selection_widget.dart';

/// Screen for inviting a new team member

class AddMemberScreen extends StatefulWidget {
  final String sellerProfileId;

  const AddMemberScreen({
    super.key,
    required this.sellerProfileId,
  });

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  MemberRole? _selectedRole;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeamBloc, TeamState>(
      listener: (context, state) {
        if (state.status == TeamStatus.actionSuccess) {
          final messageKey = state.successMessage ??
              'seller.add_member_screen.default_success';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(messageKey.tr()),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
        if (state.status == TeamStatus.error && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text('seller.add_member_screen.app_bar_title'.tr()),
          ),
          body: SafeArea(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email input
                    Text(
                      'seller.add_member_screen.email_label'.tr(),
                      style: AppTypography.titleSmall(context),
                    ),
                    AppSpacing.gapVerticalSm,
                    AppTextField(
                      controller: _emailController,
                      hint: 'seller.add_member_screen.email_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'seller.add_member_screen.email_required'.tr();
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'seller.add_member_screen.email_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapVerticalLg,

                    // Role selection
                    Text(
                      'seller.add_member_screen.role_label'.tr(),
                      style: AppTypography.titleSmall(context),
                    ),
                    AppSpacing.gapVerticalSm,
                    Expanded(
                      child: RoleSelectionWidget(
                        selectedRole: _selectedRole,
                        onRoleSelected: (role) {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                        currentUserRole: state.currentMembership?.role,
                      ),
                    ),

                    // Submit button
                    AppSpacing.gapVerticalMd,
                    PrimaryButton(
                      text: 'seller.add_member_screen.submit'.tr(),
                      onPressed: _canSubmit()
                          ? () => _onSubmit(context)
                          : null,
                      isLoading: state.isActionInProgress,
                    ),
                    AppSpacing.gapVerticalMd,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _canSubmit() {
    return _selectedRole != null && _emailController.text.isNotEmpty;
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<TeamBloc>().add(
            TeamInvitationSent(
              sellerProfileId: widget.sellerProfileId,
              email: _emailController.text.trim(),
              role: _selectedRole!,
            ),
          );
    }
  }
}
