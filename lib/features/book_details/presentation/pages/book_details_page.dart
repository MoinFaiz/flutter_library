import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_state.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_state.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_event.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_details_app_bar.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_details_body.dart';

/// Book details page showing comprehensive book information
class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool _hasInitializedDependentLoading = false;

  @override
  void initState() {
    super.initState();
    // Load only book details initially for fast loading
    context.read<BookDetailsBloc>().add(LoadBookDetails(widget.book.id));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger independent loading of reviews and rental status after basic book details
    // This is called after the widget is fully built and context is safe to use
    if (!_hasInitializedDependentLoading) {
      _hasInitializedDependentLoading = true;
      context.read<ReviewsBloc>().add(LoadReviewsEvent(widget.book.id));
      context.read<RentalStatusBloc>().add(LoadRentalStatus(widget.book.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookDetailsBloc, BookDetailsState>(
            listener: _handleBookDetailsListener,
          ),
          BlocListener<ReviewsBloc, ReviewsState>(
            listener: _handleReviewsListener,
          ),
          BlocListener<RentalStatusBloc, RentalStatusState>(
            listener: _handleRentalStatusListener,
          ),
        ],
        child: BlocBuilder<BookDetailsBloc, BookDetailsState>(
          builder: _buildContent,
        ),
      ),
    );
  }

  void _handleBookDetailsListener(BuildContext context, BookDetailsState state) {
    if (state is BookDetailsLoaded && state.actionMessage != null) {
      _showSnackBar(context, state.actionMessage!);
    } else if (state is BookDetailsError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  void _handleReviewsListener(BuildContext context, ReviewsState state) {
    // Handle success messages
    if (state is ReviewSubmitted || 
        state is ReviewUpdated || 
        state is ReviewDeleted ||
        state is RatingSubmitted ||
        state is VoteSuccess ||
        state is ReviewReported) {
      String message = '';
      if (state is ReviewSubmitted) {
        message = 'Review submitted successfully';
      } else if (state is ReviewUpdated) {
        message = 'Review updated successfully';
      } else if (state is ReviewDeleted) {
        message = 'Review deleted successfully';
      } else if (state is RatingSubmitted) {
        message = 'Rating submitted successfully';
      } else if (state is VoteSuccess) {
        message = 'Vote recorded';
      } else if (state is ReviewReported) {
        message = 'Review reported successfully';
      }
      
      if (message.isNotEmpty) {
        _showSnackBar(context, message);
      }
    } else if (state is ReviewsError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  void _handleRentalStatusListener(BuildContext context, RentalStatusState state) {
    if (state is RentalStatusLoaded && state.actionMessage != null) {
      _showSnackBar(context, state.actionMessage!);
    } else if (state is RentalStatusError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  Widget _buildContent(BuildContext context, BookDetailsState state) {
    if (state is BookDetailsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state is BookDetailsError) {
      return _buildErrorView(context, state);
    }
    
    // Use loaded book data if available, otherwise fall back to initial book
    final book = state is BookDetailsLoaded ? state.book : widget.book;
    final isLoaded = state is BookDetailsLoaded;
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh all components independently
        context.read<BookDetailsBloc>().add(RefreshBookDetails(widget.book.id));
        context.read<ReviewsBloc>().add(LoadReviewsEvent(widget.book.id));
        context.read<RentalStatusBloc>().add(LoadRentalStatus(widget.book.id));
      },
      child: CustomScrollView(
        slivers: [
          BookDetailsAppBar(
            book: book,
            onBack: () => Navigator.of(context).pop(),
            onFavoriteToggle: () => _toggleFavorite(book.id),
          ),
          SliverToBoxAdapter(
            child: _buildBookDetailsBody(book, state, isLoaded),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, BookDetailsError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          Text(
            'Error loading book details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: AppDimensions.spaceSm),
          Text(
            state.message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          ElevatedButton(
            onPressed: () => _retryLoadBookDetails(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookDetailsBody(Book book, BookDetailsState state, bool isLoaded) {
    return BlocBuilder<ReviewsBloc, ReviewsState>(
      builder: (context, reviewsState) {
        return BlocBuilder<RentalStatusBloc, RentalStatusState>(
          builder: (context, rentalStatusState) {
            return BookDetailsBody(
              book: book,
              reviews: reviewsState is ReviewsLoaded ? reviewsState.reviews : null,
              rentalStatus: rentalStatusState is RentalStatusLoaded ? rentalStatusState.rentalStatus : null,
              isPerformingAction: rentalStatusState is RentalStatusLoading,
              isLoadingReviews: reviewsState is ReviewsLoading,
              isLoadingRentalStatus: rentalStatusState is RentalStatusLoading,
              reviewsError: reviewsState is ReviewsError ? reviewsState.message : null,
              rentalStatusError: rentalStatusState is RentalStatusError ? rentalStatusState.message : null,
              onRent: () => _performBookAction(RentBook(book.id)),
              onBuy: () => _performBookAction(BuyBook(book.id)),
              onReturn: () => _performBookAction(ReturnBook(book.id)),
              onRenew: () => _performBookAction(RenewBook(book.id)),
              onRemoveFromCart: () => _performBookAction(RemoveFromCart(book.id)),
              onAddReview: (reviewText, rating) => _submitReview(book.id, reviewText, rating),
              onLoadReviews: () => _loadReviews(book.id),
              onLoadRentalStatus: () => _loadRentalStatus(book.id),
            );
          },
        );
      },
    );
  }

  // Helper methods for cleaner code
  void _toggleFavorite(String bookId) {
    context.read<BookDetailsBloc>().add(ToggleFavorite(bookId));
  }

  void _performBookAction(RentalStatusEvent event) {
    context.read<RentalStatusBloc>().add(event);
  }

  void _submitReview(String bookId, String reviewText, double rating) {
    context.read<ReviewsBloc>().add(SubmitReviewEvent(
      bookId: bookId,
      reviewText: reviewText,
      rating: rating,
    ));
  }

  void _loadReviews(String bookId) {
    context.read<ReviewsBloc>().add(LoadReviewsEvent(bookId));
  }

  void _loadRentalStatus(String bookId) {
    context.read<RentalStatusBloc>().add(LoadRentalStatus(bookId));
  }

  void _retryLoadBookDetails() {
    context.read<BookDetailsBloc>().add(LoadBookDetails(widget.book.id));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
