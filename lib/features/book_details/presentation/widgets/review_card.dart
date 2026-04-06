import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/core/utils/extensions/date_extensions.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Widget displaying a single review with voting and action capabilities
class ReviewCard extends StatelessWidget {
  final Review review;
  final String? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onVoteHelpful;
  final VoidCallback? onVoteUnhelpful;
  final VoidCallback? onReport;
  final bool showActions;

  const ReviewCard({
    super.key,
    required this.review,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
    this.onVoteHelpful,
    this.onVoteUnhelpful,
    this.onReport,
    this.showActions = true,
  });

  bool get _isOwnReview => review.userId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationXs,
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, base: 12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
            _buildReviewContent(context),
            if (showActions) ...[
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
              _buildReviewActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHeader(BuildContext context) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: ResponsiveUtils.getResponsiveAvatarRadius(context),
          backgroundImage: review.userAvatarUrl != null
              ? CachedNetworkImageProvider(review.userAvatarUrl!)
              : null,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: review.userAvatarUrl == null
              ? Text(
                  review.userName[0].toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                )
              : null,
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
        
        // User name and rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (review.isEdited) ...[
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
                    Text(
                      '(edited)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
              Row(
                children: [
                  RatingDisplay(
                    rating: review.rating,
                    iconSize: AppConstants.ratingSize,
                  ),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
                  Text(
                    review.createdAt.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // More options menu (for own reviews)
        if (_isOwnReview && showActions)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: AppDimensions.iconSm,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Edit Review'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: AppDimensions.iconSm,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    const Text('Delete Review'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReviewContent(BuildContext context) {
    return Text(
      review.reviewText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
    );
  }

  Widget _buildReviewActions(BuildContext context) {
    return Row(
      children: [
        // Helpful voting
        _buildVoteButton(
          context: context,
          icon: Icons.thumb_up,
          label: review.helpfulCount.toString(),
          isActive: review.currentUserVote == 'helpful',
          onTap: onVoteHelpful,
          isDisabled: _isOwnReview,
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 16)),
        
        // Unhelpful voting
        _buildVoteButton(
          context: context,
          icon: Icons.thumb_down,
          label: review.unhelpfulCount.toString(),
          isActive: review.currentUserVote == 'unhelpful',
          onTap: onVoteUnhelpful,
          isDisabled: _isOwnReview,
        ),
        
        const Spacer(),
        
        // Report button (only for other users' reviews)
        if (!_isOwnReview && onReport != null)
          TextButton.icon(
            onPressed: onReport,
            icon: Icon(
              Icons.flag_outlined,
              size: AppDimensions.iconXs,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
            label: Text(
              'Report',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                fontSize: AppTypography.fontSizeXs,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  Widget _buildVoteButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final effectiveOnTap = isDisabled ? null : onTap;
    final color = isDisabled
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
        : isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: effectiveOnTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? icon : Icons.thumb_up_outlined,
              size: AppDimensions.iconXs,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppTypography.fontSizeSm,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
