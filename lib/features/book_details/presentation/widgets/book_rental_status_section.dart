import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

/// Widget displaying rental status information
class BookRentalStatusSection extends StatefulWidget {
  final Book book;
  final RentalStatus? rentalStatus;
  final bool isLoading;
  final String? error;
  final VoidCallback? onLoadRentalStatus;

  const BookRentalStatusSection({
    super.key,
    required this.book,
    this.rentalStatus,
    this.isLoading = false,
    this.error,
    this.onLoadRentalStatus,
  });

  @override
  State<BookRentalStatusSection> createState() => _BookRentalStatusSectionState();
}

class _BookRentalStatusSectionState extends State<BookRentalStatusSection> {
  bool _hasTriggeredLoad = false;

  void _triggerLoadIfNeeded() {
    if (!_hasTriggeredLoad && widget.rentalStatus == null && widget.onLoadRentalStatus != null) {
      _hasTriggeredLoad = true;
      // Trigger load with a small delay to ensure widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onLoadRentalStatus!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger load when widget is built
    _triggerLoadIfNeeded();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rental Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: AppDimensions.spaceMd),
          
          _buildRentalStatusContent(),
        ],
      ),
    );
  }

  Widget _buildRentalStatusContent() {
    // Handle error state
    if (widget.error != null) {
      return _buildErrorWidget();
    }
    
    // Handle loading state
    if (widget.isLoading) {
      return _buildLoadingWidget();
    }
    
    // Handle not loaded state
    if (widget.rentalStatus == null) {
      return _buildNotLoadedWidget();
    }
    
    // Handle loaded state
    if (!_hasRentalStatus()) {
      return const SizedBox.shrink();
    }
    
    return _buildRentalStatusCard(context);
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: AppDimensions.icon3Xl,
          ),
          SizedBox(height: AppDimensions.spaceSm),
          Text(
            'Failed to load rental status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: AppDimensions.spaceXs),
          Text(
            widget.error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          ElevatedButton(
            onPressed: widget.onLoadRentalStatus,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNotLoadedWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: AppDimensions.icon3Xl,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: AppDimensions.spaceSm),
          Text(
            'Load Rental Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDimensions.spaceXs),
          Text(
            'Check availability and rental information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          ElevatedButton(
            onPressed: widget.onLoadRentalStatus,
            child: const Text('Load Status'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRentalStatusCard(BuildContext context) {
    final status = _getRentalStatus();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: status.borderColor,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                status.icon,
                size: AppDimensions.iconLg,
                color: status.iconColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: status.textColor,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs),
                    Text(
                      status.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: status.textColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (status.showProgressBar) ...[
            SizedBox(height: AppDimensions.spaceMd),
            LinearProgressIndicator(
              value: status.progress,
              backgroundColor: status.textColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(status.progressColor),
            ),
            SizedBox(height: AppDimensions.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: status.textColor.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${(status.progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: status.textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  bool _hasRentalStatus() {
    return widget.rentalStatus != null && widget.rentalStatus!.isRented;
  }
  
  RentalStatusUI _getRentalStatus() {
    if (widget.rentalStatus == null) {
      return RentalStatusUI.notRented(context);
    }

    switch (widget.rentalStatus!.status) {
      case RentalStatusType.rented:
        return RentalStatusUI.active(context);
      case RentalStatusType.dueSoon:
        return RentalStatusUI.dueSoon(context);
      case RentalStatusType.overdue:
        return RentalStatusUI.overdue(context);
      default:
        return RentalStatusUI.notRented(context);
    }
  }
}

/// Class representing rental status UI information
class RentalStatusUI {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color progressColor;
  final bool showProgressBar;
  final double progress;
  
  RentalStatusUI({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.progressColor,
    this.showProgressBar = false,
    this.progress = 0.0,
  });
  
  factory RentalStatusUI.active(BuildContext context) {
    return RentalStatusUI(
      title: 'Currently Rented',
      subtitle: 'Due: March 15, 2024',
      icon: Icons.schedule,
      backgroundColor: AppColors.success.withValues(alpha: 0.1),
      borderColor: AppColors.success.withValues(alpha: 0.3),
      iconColor: AppColors.success,
      textColor: AppColors.success,
      progressColor: AppColors.success,
      showProgressBar: true,
      progress: 0.6,
    );
  }
  
  factory RentalStatusUI.dueSoon(BuildContext context) {
    return RentalStatusUI(
      title: 'Due Soon',
      subtitle: 'Due: Tomorrow (March 12, 2024)',
      icon: Icons.warning,
      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
      borderColor: AppColors.warning.withValues(alpha: 0.3),
      iconColor: AppColors.warning,
      textColor: AppColors.warning,
      progressColor: AppColors.warning,
      showProgressBar: true,
      progress: 0.9,
    );
  }
  
  factory RentalStatusUI.overdue(BuildContext context) {
    return RentalStatusUI(
      title: 'Overdue',
      subtitle: 'Was due: March 10, 2024',
      icon: Icons.error,
      backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
      borderColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
      iconColor: Theme.of(context).colorScheme.error,
      textColor: Theme.of(context).colorScheme.error,
      progressColor: Theme.of(context).colorScheme.error,
      showProgressBar: true,
      progress: 1.0,
    );
  }
  
  factory RentalStatusUI.notRented(BuildContext context) {
    return RentalStatusUI(
      title: 'Available',
      subtitle: 'Ready to rent',
      icon: Icons.check_circle,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      iconColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      progressColor: Theme.of(context).colorScheme.primary,
    );
  }
}
