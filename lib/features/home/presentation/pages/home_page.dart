import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_icon_button_with_badge.dart';
import 'package:flutter_library/shared/widgets/book_grid_widget.dart';
import 'package:flutter_library/injection/injection_container.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Home page showing books available for rent/sale with search, favorites, and lazy loading
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final NavigationService _navigationService = sl<NavigationService>();

  @override
  void initState() {
    super.initState();
    // Load initial books
    context.read<HomeBloc>().add(LoadBooks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<HomeBloc>().add(ClearSearch());
    } else {
      context.read<HomeBloc>().add(SearchBooks(query));
    }
  }

  void _navigateToFavorites() async {
    await _navigationService.navigateTo(AppRoutes.favorites);
    if (mounted) {
      context.read<HomeBloc>().add(SyncFavoriteIds());
    }
  }

  void _onBookTap(Book book) {
    _navigationService.navigateTo(AppRoutes.bookDetails, arguments: book);
  }

  void _onFavoriteToggle(Book book) {
    context.read<HomeBloc>().add(ToggleFavorite(book.id));
  }

  void _onLoadMore() {
    context.read<HomeBloc>().add(LoadMoreBooks());
  }

  Future<void> _onRefresh() async {
    final completer = Completer<void>();
    
    // Listen for state changes to know when refresh is complete
    final subscription = context.read<HomeBloc>().stream.listen((newState) {
      if (newState is HomeLoaded || newState is HomeError) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    context.read<HomeBloc>().add(RefreshBooks());
    
    try {
      await completer.future;
    } finally {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search header with cart icon
            _buildSearchHeader(),
            // Books grid with pull-to-refresh
            Expanded(
              child: _buildBooksGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _searchController,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          child: _buildSearchBar(context, value.text),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, String queryText) {
    return SearchBar(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hintText: 'Search books, authors, genres...',
      leading: const Icon(Icons.search),
      trailing: [
        // Clear button (only show when there's text)
        if (queryText.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
              _searchFocusNode.unfocus();
            },
            tooltip: 'Clear search',
          ),
        // Favorites button
        IconButton(
          icon: const Icon(Icons.favorite_outline),
          onPressed: _navigateToFavorites,
          tooltip: 'Favorites',
        ),
        // Cart button
        const CartIconButtonWithBadge(),
      ],
      onChanged: _onSearchChanged,
      backgroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      elevation: WidgetStateProperty.all(2),
    );
  }



  Widget _buildBooksGrid() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        List<Book> books = [];
        bool isLoading = false;
        bool isRefreshing = false;
        bool isLoadingMore = false;
        bool hasMore = true;
        String? errorMessage;

        if (state is HomeLoading) {
          isLoading = true;
        } else if (state is HomeLoaded) {
          books = state.books;
          isLoadingMore = state.isLoadingMore;
          hasMore = state.hasMore;
        } else if (state is HomeRefreshing) {
          books = state.data;
          isRefreshing = true;
        } else if (state is HomeSearching) {
          books = state.data;
          isRefreshing = true; // Show as refreshing during search
        } else if (state is HomeError) {
          errorMessage = state.message;
        }

        return BookGridWidget(
          books: books,
          isLoading: isLoading,
          isRefreshing: isRefreshing,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore && !_isSearching(state), // Don't paginate during search
          errorMessage: errorMessage,
          onRefresh: _onRefresh,
          onLoadMore: _onLoadMore,
          onBookTap: _onBookTap,
          onFavoriteToggle: _onFavoriteToggle,
          emptyStateTitle: _searchController.text.isNotEmpty ? 'No books found' : 'No books available',
          emptyStateSubtitle: _searchController.text.isNotEmpty 
              ? 'Try adjusting your search terms'
              : 'Pull down to refresh and discover books',
          emptyStateIcon: Icons.library_books_outlined,
          useExtendedCard: true, // Use extended card with pricing info
        );
      },
    );
  }

  bool _isSearching(HomeState state) {
    return state is HomeSearching || 
           (state is HomeLoaded && state.isSearching);
  }
}
