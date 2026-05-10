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
import '../../../../core/widgets/media/avatar.dart';
import '../../../seller/domain/entities/contact_phone.dart';
import '../../../seller/domain/entities/seller_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/edit/address_section.dart';
import '../widgets/edit/contact_person_section.dart';
import '../widgets/edit/contact_phones_editor.dart';
import '../widgets/edit/username_field.dart';
import '../widgets/edit/working_hours_editor.dart';

/// Storefront-only edit profile.
///
/// Account credentials (email / phone / password) live on
/// `AccountSettingsScreen` — keeping them off this page makes the privacy
/// boundary explicit: every field rendered here ends up on the public
/// storefront. Buyers see just the top section (avatar, username, name,
/// language); sellers also see the storefront sections.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _websiteController;
  late final TextEditingController _instagramController;
  late final TextEditingController _telegramController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _facebookController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _contactPersonNameController;
  late final TextEditingController _contactPersonRoleController;
  String? _language;
  List<ContactPhone> _contactPhones = const [];
  Map<String, WorkingHours> _workingHours = const {};

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
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _websiteController = TextEditingController();
    _instagramController = TextEditingController();
    _telegramController = TextEditingController();
    _youtubeController = TextEditingController();
    _facebookController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _districtController = TextEditingController();
    _contactPersonNameController = TextEditingController();
    _contactPersonRoleController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _telegramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _contactPersonNameController.dispose();
    _contactPersonRoleController.dispose();
    super.dispose();
  }

  void _hydrate(ProfileState state) {
    if (_initialized || state.profile == null) return;
    final profile = state.profile!;
    _fullNameController.text = profile.fullName;
    _usernameController.text = profile.username ?? '';
    _language = profile.language;

    final seller = state.sellerProfile;
    if (seller != null) {
      _bioController.text = seller.description ?? '';
      _websiteController.text = seller.website ?? '';
      _instagramController.text = seller.instagram ?? '';
      _telegramController.text = seller.telegram ?? '';
      _youtubeController.text = seller.youtube ?? '';
      _facebookController.text = seller.facebook ?? '';
      _addressController.text = seller.address ?? '';
      _cityController.text = seller.city ?? '';
      _districtController.text = seller.district ?? '';
      _contactPersonNameController.text = seller.contactPersonName ?? '';
      _contactPersonRoleController.text = seller.contactPersonRole ?? '';
      // Default to seller.username for storefront-handle field — falls back to
      // the user-level handle so the user can still edit one slot.
      if (_usernameController.text.isEmpty && seller.username != null) {
        _usernameController.text = seller.username!;
      }
      _contactPhones = List.of(seller.contactPhones);
      _workingHours = Map.of(seller.workingHours);
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ProfileStatus.loaded && _initialized) {
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
              content: Text(state.failure?.message ?? 'common.error'.tr()),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.profile != curr.profile ||
          prev.sellerProfile != curr.sellerProfile,
      builder: (context, state) {
        _hydrate(state);
        final profile = state.profile;
        final seller = state.sellerProfile;
        final isUpdating = state.isUpdating;

        return Scaffold(
          backgroundColor: AppColors.surfaceOf(context),
          appBar: AppBar(
            title: Text(
              'profile.edit_screen.title'.tr(),
              style: AppTypography.titleMedium(context).copyWith(
                fontWeight: AppTypography.bold,
              ),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.surfaceOf(context),
            actions: [
              TextButton(
                onPressed: isUpdating || profile == null
                    ? null
                    : () => _onSave(profile, seller),
                child: Text(
                  'profile.edit_screen.save_button'.tr(),
                  style: AppTypography.titleSmall(context).copyWith(
                    color: isUpdating
                        ? AppColors.textTertiaryOf(context)
                        : AppColors.primaryOf(context),
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: profile == null
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: AppSpacing.md),
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
                        const SizedBox(height: AppSpacing.lg),
                        const _SectionDivider(),
                        UsernameField(
                          controller: _usernameController,
                          currentUsername: profile.username,
                        ),
                        const _RowDivider(),
                        _FieldRow(
                          label: 'profile.edit_screen.full_name_label'.tr(),
                          controller: _fullNameController,
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
                        const _RowDivider(),
                        _LanguageRow(
                          value: _language ?? profile.language,
                          onChanged: (lang) {
                            setState(() => _language = lang);
                          },
                        ),
                        if (seller != null) ...[
                          const _SectionDivider(),
                          _SectionHeader(
                            label: 'profile.edit_screen.business_section_title'
                                .tr(),
                          ),
                          _FieldRow(
                            label: 'profile.edit_screen.bio_label'.tr(),
                            controller: _bioController,
                            hint: 'profile.edit_screen.bio_hint'.tr(),
                            maxLines: 3,
                            textInputAction: TextInputAction.next,
                          ),
                          const _RowDivider(),
                          _FieldRow(
                            label: 'profile.edit_screen.website_label'.tr(),
                            controller: _websiteController,
                            hint: 'profile.edit_screen.website_hint'.tr(),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                          ),
                          const _SectionDivider(),
                          _SectionHeader(
                            label: 'profile.edit_screen.address_section_title'
                                .tr(),
                          ),
                          AddressSection(
                            addressController: _addressController,
                            cityController: _cityController,
                            districtController: _districtController,
                          ),
                          const _SectionDivider(),
                          _SectionHeader(
                            label:
                                'profile.edit_screen.contact_person_section_title'
                                    .tr(),
                          ),
                          ContactPersonSection(
                            nameController: _contactPersonNameController,
                            roleController: _contactPersonRoleController,
                          ),
                          const _SectionDivider(),
                          _SectionHeader(
                            label:
                                'profile.edit_screen.contact_phones_section_title'
                                    .tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            child: ContactPhonesEditor(
                              phones: _contactPhones,
                              onChanged: (next) =>
                                  setState(() => _contactPhones = next),
                            ),
                          ),
                          const _SectionDivider(),
                          _SectionHeader(
                            label:
                                'profile.edit_screen.working_hours_section_title'
                                    .tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            child: WorkingHoursEditor(
                              hours: _workingHours,
                              onChanged: (next) =>
                                  setState(() => _workingHours = next),
                            ),
                          ),
                          const _SectionDivider(),
                          _SectionHeader(
                            label: 'profile.edit_screen.section_social'.tr(),
                          ),
                          _SocialFieldRow(
                            icon: Icons.camera_alt_rounded,
                            iconColor: const Color(0xFFE1306C),
                            label: 'profile.edit_screen.instagram_label'.tr(),
                            hint: 'profile.edit_screen.social_hint_handle'.tr(),
                            controller: _instagramController,
                            textInputAction: TextInputAction.next,
                          ),
                          const _RowDivider(),
                          _SocialFieldRow(
                            icon: Icons.send_rounded,
                            iconColor: const Color(0xFF229ED9),
                            label: 'profile.edit_screen.telegram_label'.tr(),
                            hint: 'profile.edit_screen.social_hint_handle'.tr(),
                            controller: _telegramController,
                            textInputAction: TextInputAction.next,
                          ),
                          const _RowDivider(),
                          _SocialFieldRow(
                            icon: Icons.play_arrow_rounded,
                            iconColor: const Color(0xFFFF0000),
                            label: 'profile.edit_screen.youtube_label'.tr(),
                            hint: 'profile.edit_screen.social_hint_url'.tr(),
                            controller: _youtubeController,
                            textInputAction: TextInputAction.next,
                          ),
                          const _RowDivider(),
                          _SocialFieldRow(
                            icon: Icons.facebook_rounded,
                            iconColor: const Color(0xFF1877F2),
                            label: 'profile.edit_screen.facebook_label'.tr(),
                            hint: 'profile.edit_screen.social_hint_handle'.tr(),
                            controller: _facebookController,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _onSave(UserProfile profile, SellerProfile? seller) {
    if (!_formKey.currentState!.validate()) return;

    final newName = _fullNameController.text.trim();
    final rawUsername = _usernameController.text.trim();
    final newUsername = rawUsername.isEmpty ? null : rawUsername;
    final newLanguage = _language ?? profile.language;

    final userHasChanges = newName != profile.fullName ||
        newUsername != profile.username ||
        newLanguage != profile.language;

    final dispatched = <bool>[];

    if (userHasChanges) {
      context.read<ProfileBloc>().add(
            ProfileUpdateRequested(
              fullName: newName != profile.fullName ? newName : null,
              username:
                  newUsername != profile.username ? (newUsername ?? '') : null,
              language:
                  newLanguage != profile.language ? newLanguage : null,
            ),
          );
      if (newLanguage != profile.language) {
        context.setLocale(Locale(newLanguage));
      }
      dispatched.add(true);
    }

    if (seller != null) {
      String? diff(String current, String previous) {
        if (current == previous) return null;
        return current; // empty string clears the field, non-empty sets it
      }

      final descriptionDiff =
          diff(_bioController.text.trim(), seller.description ?? '');
      final websiteDiff =
          diff(_websiteController.text.trim(), seller.website ?? '');
      final instagramDiff =
          diff(_instagramController.text.trim(), seller.instagram ?? '');
      final telegramDiff =
          diff(_telegramController.text.trim(), seller.telegram ?? '');
      final youtubeDiff =
          diff(_youtubeController.text.trim(), seller.youtube ?? '');
      final facebookDiff =
          diff(_facebookController.text.trim(), seller.facebook ?? '');
      final addressDiff =
          diff(_addressController.text.trim(), seller.address ?? '');
      final cityDiff = diff(_cityController.text.trim(), seller.city ?? '');
      final districtDiff =
          diff(_districtController.text.trim(), seller.district ?? '');
      final personNameDiff = diff(
          _contactPersonNameController.text.trim(),
          seller.contactPersonName ?? '');
      final personRoleDiff = diff(
          _contactPersonRoleController.text.trim(),
          seller.contactPersonRole ?? '');

      // Lists/maps: forward only if the user actually mutated the structure.
      final phonesDiff = _phonesChanged(seller.contactPhones, _contactPhones)
          ? _contactPhones
          : null;
      final hoursDiff = _hoursChanged(seller.workingHours, _workingHours)
          ? _workingHours
          : null;

      // Username on seller_profiles tracks the user-level handle when the
      // user types one. Send it under the same change check so a single edit
      // updates both rows.
      final sellerUsernameDiff =
          newUsername != seller.username ? (newUsername ?? '') : null;

      final sellerHasChanges = descriptionDiff != null ||
          websiteDiff != null ||
          instagramDiff != null ||
          telegramDiff != null ||
          youtubeDiff != null ||
          facebookDiff != null ||
          addressDiff != null ||
          cityDiff != null ||
          districtDiff != null ||
          personNameDiff != null ||
          personRoleDiff != null ||
          phonesDiff != null ||
          hoursDiff != null ||
          sellerUsernameDiff != null;

      if (sellerHasChanges) {
        context.read<ProfileBloc>().add(
              ProfileSellerInfoUpdateRequested(
                username: sellerUsernameDiff,
                description: descriptionDiff,
                website: websiteDiff,
                instagram: instagramDiff,
                telegram: telegramDiff,
                youtube: youtubeDiff,
                facebook: facebookDiff,
                address: addressDiff,
                city: cityDiff,
                district: districtDiff,
                contactPersonName: personNameDiff,
                contactPersonRole: personRoleDiff,
                contactPhones: phonesDiff,
                workingHours: hoursDiff,
              ),
            );
        dispatched.add(true);
      }
    }

    if (dispatched.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.edit_screen.no_changes'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _phonesChanged(List<ContactPhone> a, List<ContactPhone> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }

  bool _hoursChanged(
      Map<String, WorkingHours> a, Map<String, WorkingHours> b) {
    if (a.length != b.length) return true;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return true;
    }
    return false;
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: isUpdating ? null : () => _pickSource(context),
            child: Text(
              'profile.edit_screen.avatar_change'.tr(),
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.primaryOf(context),
                fontWeight: AppTypography.semiBold,
              ),
            ),
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

/// IG-style row: label on the left (fixed width), value/text-field on the
/// right (fills remaining space). Used for `Name`, `Bio`, `Website`.
class _FieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final int? maxLines;

  const _FieldRow({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                label,
                style: AppTypography.bodyLarge(context).copyWith(
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              validator: validator,
              maxLines: maxLines ?? 1,
              style: AppTypography.bodyLarge(context),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyLarge(context).copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                errorStyle: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Social-account row — adds a coloured network icon to the left of the
/// field for at-a-glance scannability.
class _SocialFieldRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputAction? textInputAction;

  const _SocialFieldRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hint,
    required this.controller,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium(context).copyWith(
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              textInputAction: textInputAction,
              style: AppTypography.bodyLarge(context),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyLarge(context).copyWith(
                  color: AppColors.textTertiaryOf(context),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Language row — same dimensions as a normal field row but renders three
/// language pills as the value.
class _LanguageRow extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LanguageRow({required this.value, required this.onChanged});

  static const _options = ['uz', 'ru', 'en'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              'profile.edit_screen.language_label'.tr(),
              style: AppTypography.bodyLarge(context).copyWith(
                fontWeight: AppTypography.medium,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: _options.map((code) {
                final isSelected = code == value;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Material(
                    color: isSelected
                        ? AppColors.primaryOf(context)
                        : AppColors.surfaceContainerOf(context),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => onChanged(code),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section heading used to group seller-only fields.
class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmallStyle.copyWith(
          color: AppColors.textTertiaryOf(context),
          fontWeight: AppTypography.semiBold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Heavier divider between top-level sections (e.g. Account → Seller).
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: AppColors.surfaceContainerOf(context),
    );
  }
}

/// Lightweight divider between rows within the same section.
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md + 92),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: AppColors.dividerOf(context),
      ),
    );
  }
}
