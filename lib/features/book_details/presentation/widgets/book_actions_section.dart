import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

/// Widget displaying action buttons for the book
class BookActionsSection extends StatelessWidget {
  final Book book;
  final RentalStatus? rentalStatus;
  final bool isPerformingAction;
  final VoidCallback? onRent;
  final VoidCallback? onBuy;
  final VoidCallback? onReturn;
  final VoidCallback? onRenew;

  const BookActionsSection({
    super.key,
    required this.book,
    this.rentalStatus,
    this.isPerformingAction = false,
    this.onRent,
    this.onBuy,
    this.onReturn,
    this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: AppDimensions.spaceMd),
          
          _buildActionButtons(context),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    final actions = _getAvailableActions(context);
    
    if (actions.isEmpty) {
      return _buildEmptyState(context);
    }
    
    final primaryActions = actions.where((a) => a.isPrimary).toList();
    final secondaryActions = actions.where((a) => !a.isPrimary).toList();
    
    return Column(
      children: [
        if (primaryActions.isNotEmpty) _buildPrimaryActions(context, primaryActions),
        if (secondaryActions.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spaceSm + AppDimensions.spaceXs),
          _buildSecondaryActions(context, secondaryActions),
        ],
      ],
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final isLoading = rentalStatus == null;
    final message = isLoading 
        ? 'Loading rental status...'
        : 'No actions available for this book';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrimaryActions(BuildContext context, List<BookAction> actions) {
    return Row(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        final isLast = index == actions.length - 1;
        
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: _buildActionButton(context, action, true),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildSecondaryActions(BuildContext context, List<BookAction> actions) {
    return Column(
      children: actions.map((action) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildActionButton(context, action, false),
      )).toList(),
    );
  }
  
  Widget _buildActionButton(BuildContext context, BookAction action, bool isPrimary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: action.onTap,
        icon: Icon(action.icon),
        label: Text(action.label),
        style: _getButtonStyle(context, action, isPrimary),
      ),
    );
  }
  
  ButtonStyle _getButtonStyle(BuildContext context, BookAction action, bool isPrimary) {
    final theme = Theme.of(context);
    
    return ElevatedButton.styleFrom(
      backgroundColor: _getButtonBackgroundColor(theme, action, isPrimary),
      foregroundColor: _getButtonForegroundColor(theme, action, isPrimary),
      side: isPrimary ? null : BorderSide(
        color: action.borderColor ?? theme.colorScheme.outline,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }
  
  Color _getButtonBackgroundColor(ThemeData theme, BookAction action, bool isPrimary) {
    if (action.backgroundColor != null) return action.backgroundColor!;
    return isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface;
  }
  
  Color _getButtonForegroundColor(ThemeData theme, BookAction action, bool isPrimary) {
    if (action.textColor != null) return action.textColor!;
    return isPrimary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
  }
  
  List<BookAction> _getAvailableActions(BuildContext context) {
    if (rentalStatus == null) return [];
    
    return switch (rentalStatus!.status) {
      RentalStatusType.available => _getAvailableStatusActions(),
      RentalStatusType.rented => _getRentedStatusActions(context),
      RentalStatusType.dueSoon => _getDueSoonStatusActions(context),
      RentalStatusType.overdue => _getOverdueStatusActions(context),
      RentalStatusType.purchased => [],
      RentalStatusType.unavailable => [],
      RentalStatusType.inCart => _getInCartStatusActions(context),
    };
  }
  
  List<BookAction> _getAvailableStatusActions() {
    final actions = <BookAction>[];
    
    if (book.isAvailableForRent && onRent != null) {
      actions.add(_createRentAction());
    }
    
    if (book.isAvailableForSale && onBuy != null) {
      actions.add(_createBuyAction());
    }
    
    return actions;
  }
  
  List<BookAction> _getRentedStatusActions(BuildContext context) {
    final actions = <BookAction>[];
    
    if (onReturn != null) {
      actions.add(_createReturnAction(context, AppColors.success));
    }
    
    if (rentalStatus!.canRenew && onRenew != null) {
      actions.add(_createRenewAction(context, Theme.of(context).colorScheme.primary));
    }
    
    return actions;
  }
  
  List<BookAction> _getDueSoonStatusActions(BuildContext context) {
    final actions = <BookAction>[];
    
    if (onReturn != null) {
      actions.add(_createReturnAction(context, AppColors.warning));
    }
    
    if (rentalStatus!.canRenew && onRenew != null) {
      actions.add(_createRenewAction(context, Theme.of(context).colorScheme.primary));
    }
    
    return actions;
  }
  
  List<BookAction> _getOverdueStatusActions(BuildContext context) {
    final actions = <BookAction>[];
    
    if (onReturn != null) {
      final errorColor = Theme.of(context).colorScheme.error;
      actions.add(BookAction(
        label: 'Return Book (Overdue)',
        icon: Icons.error,
        onTap: onReturn!,
        isPrimary: false,
        backgroundColor: errorColor.withValues(alpha: 0.1),
        textColor: errorColor,
        borderColor: errorColor.withValues(alpha: 0.3),
      ));
    }
    
    return actions;
  }
  
  List<BookAction> _getInCartStatusActions(BuildContext context) {
    final actions = <BookAction>[];
    
    if (onReturn != null) {
      final errorColor = Theme.of(context).colorScheme.error;
      actions.add(BookAction(
        label: 'Remove from Cart',
        icon: Icons.remove_shopping_cart,
        onTap: onReturn!, // Using onReturn as onRemoveFromCart equivalent
        isPrimary: false,
        backgroundColor: errorColor.withValues(alpha: 0.1),
        textColor: errorColor,
        borderColor: errorColor.withValues(alpha: 0.3),
      ));
    }
    
    return actions;
  }
  
  BookAction _createRentAction() {
    return BookAction(
      label: 'Rent Book',
      icon: Icons.schedule,
      onTap: onRent!,
      isPrimary: true,
    );
  }
  
  BookAction _createBuyAction() {
    return BookAction(
      label: 'Buy Book',
      icon: Icons.shopping_cart,
      onTap: onBuy!,
      isPrimary: true,
    );
  }
  
  BookAction _createReturnAction(BuildContext context, Color baseColor) {
    return BookAction(
      label: 'Return Book',
      icon: Icons.keyboard_return,
      onTap: onReturn!,
      isPrimary: false,
      backgroundColor: baseColor.withValues(alpha: 0.1),
      textColor: baseColor,
      borderColor: baseColor.withValues(alpha: 0.3),
    );
  }
  
  BookAction _createRenewAction(BuildContext context, Color baseColor) {
    return BookAction(
      label: 'Renew Rental',
      icon: Icons.refresh,
      onTap: onRenew!,
      isPrimary: false,
      backgroundColor: baseColor.withValues(alpha: 0.1),
      textColor: baseColor,
      borderColor: baseColor.withValues(alpha: 0.3),
    );
  }
}

/// Class representing a book action
class BookAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  
  BookAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });
}
