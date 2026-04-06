import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_icon_button_with_badge.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_library/injection/injection_container.dart';
import 'package:flutter_library/shared/widgets/book_grid_widget.dart';
import '../bloc/favorites_bloc.dart';

/// Favorites page showing user's favorite books with pagination
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final NavigationService _navigationService = sl<NavigationService>();
  
  @override
  void initState() {
    super.initState();
    // Load initial favorites
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  void _onBookTap(Book book) {
    _navigationService.navigateTo(AppRoutes.bookDetails, arguments: book);
  }

  void _onFavoriteToggle(Book book) {
    context.read<FavoritesBloc>().add(ToggleFavorite(book.id));
  }

  Future<void> _onRefresh() async {
    final completer = Completer<void>();
    
    // Listen for state changes to know when refresh is complete
    final subscription = context.read<FavoritesBloc>().stream.listen((newState) {
      if (newState is FavoritesLoaded || newState is FavoritesError) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    context.read<FavoritesBloc>().add(RefreshFavorites());
    
    try {
      await completer.future;
    } finally {
      subscription.cancel();
    }
  }

  void _onLoadMore() {
    context.read<FavoritesBloc>().add(LoadMoreFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontSize: AppTypography.fontSizeLg),
        ),
        actions: [
          const CartIconButtonWithBadge(),
        ],
        elevation: AppDimensions.elevationXs,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
        toolbarHeight: AppDimensions.appBarHeight,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          List<Book> books = [];
          bool isLoading = false;
          bool isRefreshing = false;
          bool isLoadingMore = false;
          bool hasMore = true;
          String? errorMessage;

          if (state is FavoritesLoading) {
            isLoading = true;
          } else if (state is FavoritesLoaded) {
            books = state.favoriteBooks;
            isLoadingMore = state.isLoadingMore;
            hasMore = state.hasMore;
          } else if (state is FavoritesError) {
            errorMessage = state.message;
          }

          return BookGridWidget(
            books: books,
            isLoading: isLoading,
            isRefreshing: isRefreshing,
            isLoadingMore: isLoadingMore,
            hasMore: hasMore,
            errorMessage: errorMessage,
            onRefresh: _onRefresh,
            onLoadMore: _onLoadMore,
            onBookTap: _onBookTap,
            onFavoriteToggle: _onFavoriteToggle,
            emptyStateTitle: 'No favorites yet',
            emptyStateSubtitle: 'Books you love will appear here.\nStart exploring and add some favorites!',
            emptyStateIcon: Icons.favorite_outline,
            useExtendedCard: true, // Use extended card with pricing info
          );
        },
      ),
    );
  }
}
