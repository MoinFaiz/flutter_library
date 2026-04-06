import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Card showing profile completion status and progress
class ProfileCompletionCard extends StatelessWidget {
  final UserProfile profile;

  const ProfileCompletionCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage = profile.completionPercentage;
    final isComplete = profile.isProfileComplete;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.account_circle_outlined,
                color: isComplete
                    ? AppColors.success
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(
                  isComplete
                      ? 'Profile Complete'
                      : 'Complete Your Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${(completionPercentage * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isComplete
                      ? AppColors.success
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          // Progress bar
          LinearProgressIndicator(
            value: completionPercentage,
            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete
                  ? AppColors.success
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          
          if (!isComplete) ...[
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Complete your profile to get better book recommendations and connect with other readers.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
