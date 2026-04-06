import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/core/utils/helpers/ui_utils.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_icon_button_with_badge.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_library/features/profile/presentation/widgets/profile_header.dart';
import 'package:flutter_library/features/profile/presentation/widgets/profile_form.dart';
import 'package:flutter_library/features/profile/presentation/widgets/profile_completion_card.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Profile page for managing user profile information
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool Function()? _validateForm;
  final NavigationService _navigationService = sl<NavigationService>();

  void _navigateToFavorites() {
    _navigationService.navigateTo(AppRoutes.favorites);
  }

  @override
  void initState() {
    super.initState();
    // Load profile when page opens
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: AppTypography.fontSizeLg),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save Changes',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: _navigateToFavorites,
            tooltip: 'Favorites',
          ),
          const CartIconButtonWithBadge(),
        ],
        elevation: AppDimensions.elevationXs,
        shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.05),
        toolbarHeight: AppDimensions.appBarHeight,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state.successMessage != null) {
            UIUtils.showSuccessSnackBar(context, state.successMessage!);
          } else if (state is ProfileError) {
            UIUtils.showErrorSnackBar(context, state.message);
          } else if (state is EmailVerificationSent) {
            UIUtils.showSuccessSnackBar(context, 'Verification email sent successfully');
          } else if (state is PhoneVerificationSent) {
            UIUtils.showSuccessSnackBar(context, 'Verification code sent to ${state.phoneNumber}');
          } else if (state is PhoneVerified) {
            UIUtils.showSuccessSnackBar(context, 'Phone number verified successfully');
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProfileError && state.profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppDimensions.avatarXl,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Text(
                      'Failed to load profile',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(const LoadProfile());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = _getProfileFromState(state);
            if (profile == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final isLoading = state is ProfileUpdating || state is AvatarUpdating;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(const LoadProfile());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with avatar and basic info
                    ProfileHeader(
                      profile: profile,
                      isLoading: isLoading,
                      onAvatarTap: _showAvatarOptions,
                    ),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Profile completion card
                    ProfileCompletionCard(profile: profile),
                    
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Profile form
                    ProfileForm(
                      profile: profile,
                      isLoading: isLoading,
                      onProfileChanged: _onProfileChanged,
                      onSendEmailVerification: _sendEmailVerification,
                      onSendPhoneVerification: _sendPhoneVerification,
                      onFormValidatorSet: (validator) {
                        _validateForm = validator;
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Extract profile from current state
  UserProfile? _getProfileFromState(ProfileState state) {
    if (state is ProfileLoaded) return state.profile;
    if (state is ProfileUpdating) return state.profile;
    if (state is AvatarUpdating) return state.profile;
    if (state is EmailVerificationSent) return state.profile;
    if (state is PhoneVerificationSent) return state.profile;
    if (state is PhoneVerified) return state.profile;
    if (state is ProfileError) return state.profile;
    return null;
  }

  /// Handle profile changes
  void _onProfileChanged(UserProfile updatedProfile) {
    // Profile changes are handled automatically by the form
    // This callback can be used for real-time validation or other purposes
  }

  /// Save profile changes
  void _saveProfile() {
    // Validate form first
    if (_validateForm?.call() != true) {
      UIUtils.showErrorSnackBar(context, 'Please fix the errors in the form');
      return;
    }

    final currentState = context.read<ProfileBloc>().state;
    final profile = _getProfileFromState(currentState);
    
    if (profile != null) {
      context.read<ProfileBloc>().add(UpdateProfile(profile));
    }
  }

  /// Show avatar options (camera, gallery, remove)
  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Picture',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _updateAvatar('camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _updateAvatar('gallery');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Remove Photo',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteAvatar();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Update avatar from camera or gallery
  void _updateAvatar(String source) {
    // Mock image path - in real implementation, use image_picker
    final mockImagePath = source == 'camera' 
        ? '/camera/image_${DateTime.now().millisecondsSinceEpoch}.jpg'
        : '/gallery/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    context.read<ProfileBloc>().add(UpdateAvatar(mockImagePath));
  }

  /// Delete user avatar
  void _deleteAvatar() {
    context.read<ProfileBloc>().add(const DeleteAvatar());
  }

  /// Send email verification
  void _sendEmailVerification() {
    context.read<ProfileBloc>().add(const SendEmailVerification());
  }

  /// Send phone verification
  void _sendPhoneVerification(String phoneNumber) {
    context.read<ProfileBloc>().add(SendPhoneVerification(phoneNumber));
  }
}
