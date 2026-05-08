import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/avatar.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  String? _language;

  /// Sticky-on-purpose hydration flag. We seed the controllers from the bloc
  /// state on first build only; once `true` we ignore subsequent profile
  /// emits so the user's in-flight edits aren't clobbered by a backend
  /// refresh. The flag resets on screen re-entry because [State] is rebuilt
  /// each push.
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _hydrate(ProfileState state) {
    if (_initialized || state.profile == null) return;
    final profile = state.profile!;
    _fullNameController.text = profile.fullName;
    _emailController.text = profile.email ?? '';
    _language = profile.language;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ProfileStatus.loaded && _initialized) {
          // Update arrived. If we triggered it, pop back to the storefront /
          // buyer view. We only pop after `loaded`, so if updating fails the
          // user stays on this screen.
          if (Navigator.of(context).canPop()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('profile.edit_screen.success_message'.tr()),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          }
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.failure?.message ?? 'common.error'.tr(),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      buildWhen: (prev, curr) =>
          prev.status != curr.status || prev.profile != curr.profile,
      builder: (context, state) {
        _hydrate(state);
        final profile = state.profile;
        final isUpdating = state.isUpdating;

        return Scaffold(
          backgroundColor: AppColors.surfaceOf(context),
          appBar: AppBar(
            title: Text('profile.edit_screen.title'.tr()),
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.surfaceOf(context),
          ),
          body: SafeArea(
            child: profile == null
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: AppSpacing.paddingMd,
                      children: [
                        _AvatarPicker(
                          avatarUrl: profile.avatarUrl,
                          fullName: profile.fullName,
                          onChanged: (file) {
                            HapticFeedback.lightImpact();
                            context
                                .read<ProfileBloc>()
                                .add(ProfileAvatarUpdateRequested(file));
                          },
                          isUpdating: isUpdating,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _fullNameController,
                          label: 'profile.edit_screen.full_name_label'.tr(),
                          hint: 'profile.edit_screen.full_name_hint'.tr(),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'profile.edit_screen.full_name_required'
                                  .tr();
                            }
                            if (value.trim().length < 2) {
                              return 'profile.edit_screen.full_name_min_length'
                                  .tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _emailController,
                          label: 'profile.edit_screen.email_label'.tr(),
                          hint: 'profile.edit_screen.email_hint'.tr(),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            // `Validators.validateEmail` returns a localized
                            // error message; map it to our edit-screen key so
                            // the UI stays consistent.
                            final base = Validators.validateEmail(value.trim());
                            return base == null
                                ? null
                                : 'profile.edit_screen.email_invalid'.tr();
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PhoneReadOnlyField(phone: profile.phone),
                        const SizedBox(height: AppSpacing.md),
                        _LanguageSelector(
                          value: _language ?? profile.language,
                          onChanged: (lang) {
                            setState(() => _language = lang);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          text: 'profile.edit_screen.save_button'.tr(),
                          isLoading: isUpdating,
                          onPressed: () => _onSave(profile.fullName,
                              profile.email, profile.language),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _onSave(
    String currentFullName,
    String? currentEmail,
    String currentLanguage,
  ) {
    if (!_formKey.currentState!.validate()) return;

    final newName = _fullNameController.text.trim();
    final rawEmail = _emailController.text.trim();
    final newEmail = rawEmail.isEmpty ? null : rawEmail;
    final newLanguage = _language ?? currentLanguage;

    final hasChanges = newName != currentFullName ||
        newEmail != currentEmail ||
        newLanguage != currentLanguage;
    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.edit_screen.no_changes'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<ProfileBloc>().add(
          ProfileUpdateRequested(
            fullName: newName != currentFullName ? newName : null,
            email: newEmail != currentEmail ? newEmail : null,
            language: newLanguage != currentLanguage ? newLanguage : null,
          ),
        );

    if (newLanguage != currentLanguage) {
      context.setLocale(Locale(newLanguage));
    }
  }
}

class _AvatarPicker extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;
  final void Function(File file) onChanged;
  final bool isUpdating;

  const _AvatarPicker({
    required this.avatarUrl,
    required this.fullName,
    required this.onChanged,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              AppAvatar(
                imageUrl: avatarUrl,
                name: fullName,
                size: AvatarSize.xxl,
              ),
              if (isUpdating)
                const Positioned.fill(
                  child: CircleAvatar(
                    backgroundColor: AppColors.overlayDark,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isUpdating
                        ? null
                        : () => _pickSource(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: isUpdating ? null : () => _pickSource(context),
            child: Text('profile.edit_screen.avatar_change'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _pickSource(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dividerOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'profile.edit_screen.avatar_dialog_title'.tr(),
                  style: AppTypography.titleMedium(context),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text('profile.edit_screen.avatar_camera'.tr()),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('profile.edit_screen.avatar_gallery'.tr()),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    onChanged(File(picked.path));
  }
}

class _PhoneReadOnlyField extends StatelessWidget {
  final String phone;

  const _PhoneReadOnlyField({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.edit_screen.phone_label'.tr(),
          style: AppTypography.labelMedium(context),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerOf(context),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 18,
                color: AppColors.textTertiaryOf(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  phone,
                  style: AppTypography.bodyLarge(context).copyWith(
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textTertiaryOf(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'profile.edit_screen.phone_readonly_note'.tr(),
          style: AppTypography.bodySmall(context),
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.value,
    required this.onChanged,
  });

  static const _options = ['uz', 'ru', 'en'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.edit_screen.language_label'.tr(),
          style: AppTypography.labelMedium(context),
        ),
        const SizedBox(height: 8),
        Row(
          children: _options.map((code) {
            final isSelected = code == value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerOf(context),
                  borderRadius: AppSpacing.borderRadiusSm,
                  child: InkWell(
                    onTap: () => onChanged(code),
                    borderRadius: AppSpacing.borderRadiusSm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'profile.language_$code'.tr(),
                          style: AppTypography.labelMediumStyle.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimaryOf(context),
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
