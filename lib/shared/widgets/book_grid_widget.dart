import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/shared/widgets/book_card.dart';
import 'package:flutter_library/shared/widgets/extended_book_card.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

/// Reusable grid widget for displaying books with pagination, pull-to-refresh, and lazy loading
class BookGridWidget extends StatefulWidget {
  final List<Book> books;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Function(Book) onBookTap;
  final Function(Book) onFavoriteToggle;
  final String emptyStateTitle;
  final String emptyStateSubtitle;
  final IconData emptyStateIcon;
  final bool useExtendedCard; // New parameter to choose card type

  const BookGridWidget({
    super.key,
    required this.books,
    required this.isLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
    this.errorMessage,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onBookTap,
    required this.onFavoriteToggle,
    required this.emptyStateTitle,
    required this.emptyStateSubtitle,
    required this.emptyStateIcon,
    this.useExtendedCard = false, // Default to basic card
  });

  @override
  State<BookGridWidget> createState() => _BookGridWidgetState();
}

class _BookGridWidgetState extends State<BookGridWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we've scrolled to near the bottom
    final position = _scrollController.position;
    
    // Use a percentage-based threshold for better responsiveness across devices
    final threshold = position.maxScrollExtent * 0.8; // Trigger at 80% scroll
    
    if (position.pixels >= threshold) {
      // Only load more if we have more data and not already loading
      if (widget.hasMore && !widget.isLoadingMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle initial loading state
    if (widget.isLoading) {
      return _buildLoadingGrid();
    }

    // Handle error state
    if (widget.errorMessage != null) {
      return _buildErrorState(widget.errorMessage!);
    }

    // Handle empty state
    if (widget.books.isEmpty && !widget.isRefreshing) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: Stack(
        children: [
          GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.xsPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: widget.useExtendedCard ? 0.55 : 0.75, // More vertical space for extended card
              crossAxisSpacing: AppConstants.xsPadding,
              mainAxisSpacing: AppConstants.xsPadding,
            ),
            itemCount: widget.books.length + (widget.isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= widget.books.length) {
                return _buildLoadingCard();
              }

              final book = widget.books[index];
              
              // Use extended card or basic card based on parameter
              if (widget.useExtendedCard) {
                return ExtendedBookCard(
                  book: book,
                  onTap: () => widget.onBookTap(book),
                  onFavoriteToggle: () => widget.onFavoriteToggle(book),
                  showFavoriteButton: true,
                );
              }
              
              return BookCard(
                book: book,
                onTap: () => widget.onBookTap(book),
                onFavoriteToggle: () => widget.onFavoriteToggle(book),
                showFavoriteButton: true,
              );
            },
          ),
          
          // Show loading overlay for refresh
          if (widget.isRefreshing)
            _buildLoadingOverlay(message: 'Refreshing...'),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay({required String message}) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.smallPadding,
        mainAxisSpacing: AppConstants.smallPadding,
      ),
      itemCount: 6, // Show 6 loading cards
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(AppDimensions.spaceSm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceSm),
                child: Column(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceSm),
                    Container(
                      height: 12,
                      width: double.infinity * 0.7,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.emptyStateIcon,
                size: AppDimensions.avatar2Xl,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                widget.emptyStateTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                widget.emptyStateSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppDimensions.avatar2Xl,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: () => widget.onRefresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
