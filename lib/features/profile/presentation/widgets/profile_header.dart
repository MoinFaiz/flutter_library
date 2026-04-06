import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Header widget showing user avatar and basic information
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isLoading;
  final VoidCallback? onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.isLoading = false,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              GestureDetector(
                onTap: isLoading ? null : onAvatarTap,
                child: Builder(
                  builder: (context) {
                    final avatarRadius = ResponsiveUtils.getResponsiveAvatarRadius(context);
                    return Container(
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: AppDimensions.spaceXs - 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: avatarRadius,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        backgroundImage: profile.avatarUrl != null
                            ? CachedNetworkImageProvider(profile.avatarUrl!)
                            : null,
                        child: profile.avatarUrl == null
                            ? Text(
                            profile.initials,
                            style: TextStyle(
                              fontSize: AppTypography.fontSize2Xl,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                      ),
                    );
                  },
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.5),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                ),
              if (!isLoading && onAvatarTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: AppDimensions.dividerThick,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: AppDimensions.iconXs,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Name
          Text(
            profile.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Email with verification status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: AppDimensions.iconXs,
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: AppDimensions.spaceXs),
              Flexible(
                child: Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (profile.isEmailVerified) ...[
                const SizedBox(width: AppDimensions.spaceXs),
                Icon(
                  Icons.verified,
                  size: AppDimensions.iconXs,
                  color: AppColors.success,
                ),
              ],
            ],
          ),
          
          // Phone number if available
          if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: AppDimensions.iconXs,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: AppDimensions.spaceXs),
                Text(
                  profile.phoneNumber!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                if (profile.isPhoneVerified) ...[
                  const SizedBox(width: AppDimensions.spaceXs),
                  Icon(
                    Icons.verified,
                    size: AppDimensions.iconXs,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
