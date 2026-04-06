# Usage Examples for Refactored Components

## Overview
This document provides examples of how to use the new reusable components that were created during the code refactoring process.

## Import Pattern
```dart
// Single import for all commonly used components
import 'package:flutter_library/app_exports.dart';

// Or specific imports
import 'package:flutter_library/shared/widgets/book_widgets.dart';
import 'package:flutter_library/shared/widgets/common_displays.dart';
```

## 1. Book Display Components

### BookCard (Grid Display)
```dart
BookCard(
  book: book,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookDetailsPage(book: book),
    ),
  ),
  onFavoriteToggle: () => context.read<HomeBloc>().add(
    ToggleFavorite(book.id),
  ),
  showFavoriteButton: true,
)
```

### BookListItem (List Display)
```dart
BookListItem(
  book: book,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookDetailsPage(book: book),
    ),
  ),
  onFavoriteToggle: () => context.read<HomeBloc>().add(
    ToggleFavorite(book.id),
  ),
)
```

## 2. Individual Book Components

### BookCoverImage
```dart
BookCoverImage(
  imageUrl: book.imageUrl,
  width: 120,
  height: 180,
  fit: BoxFit.cover,
)
```

### RatingDisplay
```dart
RatingDisplay(
  rating: book.rating,
  iconSize: 20,
  textStyle: Theme.of(context).textTheme.bodyLarge,
)
```

### FavoriteButton
```dart
FavoriteButton(
  isFavorite: book.isFavorite,
  onPressed: () => toggleFavorite(book.id),
  iconSize: 28,
  showBackground: true,
)
```

### PriceDisplay
```dart
PriceDisplay(
  price: book.price,
  discountPrice: book.discountPrice,
  currency: '\$',
)
```

## 3. Common UI Components

### Error Display
```dart
ErrorDisplay(
  message: 'Failed to load books',
  actionText: 'Retry',
  onRetry: () => context.read<HomeBloc>().add(LoadBooks()),
  icon: Icons.error_outline,
)
```

### Loading Display
```dart
LoadingDisplay(
  message: 'Loading your books...',
)
```

### Empty Display
```dart
EmptyDisplay(
  title: 'No books found',
  subtitle: 'Try adjusting your search criteria',
  icon: Icons.search_off,
  actionText: 'Browse All Books',
  onAction: () => context.read<HomeBloc>().add(ClearSearch()),
)
```

### Search Bar
```dart
SearchBar(
  hintText: 'Search books...',
  onChanged: (query) => UIUtils.debounce(
    'search',
    const Duration(milliseconds: 500),
    () => context.read<HomeBloc>().add(SearchBooks(query)),
  ),
  onClear: () => context.read<HomeBloc>().add(ClearSearch()),
)
```

### Standard App Bar
```dart
// Use Flutter's standard AppBar for consistency
AppBar(
  title: const Text('Page Title'),
  actions: [
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () => showSearch(),
    ),
    IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => showMenu(),
    ),
  ],
)
```

## 4. BLoC Usage with Base Classes

### Using Base BLoC Helpers
```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> with BlocResultHandler<HomeState> {
  Future<void> _onLoadBooks(LoadBooks event, Emitter<HomeState> emit) async {
    await executeWithLoading(
      () => getBooks(),
      emit,
      HomeLoading(),
      (books) => HomeLoaded(books: books),
      (error) => HomeError(error),
    );
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<HomeState> emit) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      final result = await toggleFavoriteUseCase(event.bookId);
      
      handleResult(
        result,
        (updatedBook) {
          // Handle success
          final updatedBooks = currentState.books.map((book) {
            return book.id == event.bookId ? updatedBook : book;
          }).toList();
          
          emit(currentState.copyWithState(books: updatedBooks));
        },
        (error) => emit(HomeError(error)),
      );
    }
  }
}
```

## 5. Repository Usage with Helpers

### Using Repository Helpers
```dart
@override
Future<Either<Failure, List<Book>>> getBooks() async {
  return await RepositoryHelper.handleCachedFetch<Book>(
    () => localDataSource.isCacheValid(),
    () async {
      final cached = await localDataSource.getCachedBooks();
      return await _applyFavoriteStatus(cached);
    },
    () async {
      final remote = await remoteDataSource.getBooks();
      return await _applyFavoriteStatus(remote);
    },
    (books) => localDataSource.cacheBooks(books.cast()),
  );
}
```

## 6. Error Handling Usage

### Using Error Handler
```dart
// In repositories
@override
Future<Either<Failure, List<Book>>> searchBooks(String query) async {
  return await ErrorHandler.safeExecute(() async {
    final remoteBooks = await remoteDataSource.searchBooks(query);
    return await _applyFavoriteStatus(remoteBooks);
  });
}

// In UI for user-friendly messages
void _showError(String errorMessage) {
  UIUtils.showErrorSnackBar(
    context,
    errorMessage,
    actionLabel: 'Retry',
    onActionPressed: () => _retryOperation(),
  );
}
```

## 7. UI Utilities Usage

### Responsive Design
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: UIUtils.getGridCrossAxisCount(context),
    childAspectRatio: AppConstants.gridAspectRatio,
    crossAxisSpacing: AppConstants.gridSpacing,
    mainAxisSpacing: AppConstants.gridSpacing,
  ),
  padding: UIUtils.getResponsivePadding(context),
  itemBuilder: (context, index) => BookCard(book: books[index]),
)
```

### Debounced Search
```dart
SearchBar(
  onChanged: (query) => UIUtils.debounce(
    'book_search',
    const Duration(milliseconds: 300),
    () => _performSearch(query),
  ),
)
```

### Dialog Helpers
```dart
// Loading dialog
UIUtils.showLoadingDialog(context, message: 'Updating favorites...');
await updateFavorites();
UIUtils.hideLoadingDialog(context);

// Confirmation dialog
final confirmed = await UIUtils.showConfirmationDialog(
  context,
  title: 'Remove from Favorites',
  content: 'Are you sure you want to remove this book from favorites?',
);

if (confirmed == true) {
  // Proceed with removal
}
```

## 8. Theme Usage

### Using Theme Extension
```dart
@override
Widget build(BuildContext context) {
  final appTheme = context.appTheme;
  
  return Container(
    decoration: BoxDecoration(
      color: appTheme.bookCardBackground,
      borderRadius: appTheme.cardBorderRadius,
      boxShadow: [
        BoxShadow(
          color: appTheme.bookCardShadow ?? Colors.black26,
          blurRadius: appTheme.bookCardElevation ?? 2,
        ),
      ],
    ),
    child: child,
  );
}
```

## 9. Complete Page Example

### Books Grid Page
```dart
class BooksGridPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () => _switchToListView(),
          ),
        ],
      ),
      body: RefreshableContent(
        onRefresh: () async {
          context.read<HomeBloc>().add(RefreshBooks());
        },
        child: Column(
          children: [
            SearchBar(
              onChanged: (query) => UIUtils.debounce(
                'search',
                const Duration(milliseconds: 300),
                () => context.read<HomeBloc>().add(SearchBooks(query)),
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const LoadingDisplay(
                      message: 'Loading books...',
                    );
                  } else if (state is HomeError) {
                    return ErrorDisplay(
                      message: state.message,
                      onRetry: () => context.read<HomeBloc>().add(LoadBooks()),
                    );
                  } else if (state is HomeLoaded) {
                    if (state.books.isEmpty) {
                      return const EmptyDisplay(
                        title: 'No books found',
                        subtitle: 'Try searching for something else',
                        icon: Icons.search_off,
                      );
                    }
                    
                    return GridView.builder(
                      padding: UIUtils.getResponsivePadding(context),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: UIUtils.getGridCrossAxisCount(context),
                        childAspectRatio: AppConstants.gridAspectRatio,
                        crossAxisSpacing: AppConstants.gridSpacing,
                        mainAxisSpacing: AppConstants.gridSpacing,
                      ),
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        return BookCard(
                          book: book,
                          onTap: () => _navigateToBookDetails(book),
                          onFavoriteToggle: () => context.read<HomeBloc>().add(
                            ToggleFavorite(book.id),
                          ),
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Enhanced UI Components with Multiple Images and Genre Display

### BookImageCarousel
Displays multiple book images in a carousel format with indicators and image counter.

```dart
// For books with multiple images
BookImageCarousel(
  imageUrls: book.imageUrls,
  width: double.infinity,
  height: 300,
  showIndicators: true,
)

// Automatically falls back to single image if only one URL
BookImageCarousel(
  imageUrls: ['single_image_url'],
  width: 200,
  height: 300,
)
```

### BookGenreDisplay
Shows book genres as comma-separated text or as chips.

```dart
// As comma-separated text (for cards/lists)
BookGenreDisplay(
  genres: book.genres,
  maxGenres: 2,  // Shows first 2 genres with "..." if more
)

// As chips (for detailed views)
BookGenreDisplay(
  genres: book.genres,
  showAsChips: true,
)
```

### Enhanced BookCard
Now supports carousel for multiple images and displays genres.

```dart
BookCard(
  book: book,
  onTap: () => Navigator.push(...),
  onFavoriteToggle: () => bloc.add(ToggleFavorite(book.id)),
  showFavoriteButton: true,
)
```

### Enhanced BookListItem
Updated to show genres below author name.

```dart
BookListItem(
  book: book,
  onTap: () => Navigator.push(...),
  onFavoriteToggle: () => bloc.add(ToggleFavorite(book.id)),
)
```

### New BookDetailCard
Comprehensive detail view with large carousel and chip-style genres.

```dart
BookDetailCard(
  book: book,
  onFavoriteToggle: () => bloc.add(ToggleFavorite(book.id)),
  showFavoriteButton: true,
)
```

### Key Features:
- **Automatic carousel**: Shows carousel for multiple images, single image for one URL
- **Image indicators**: Dots and counter (1/3) for navigation
- **Genre display**: Comma-separated for compact views, chips for detailed views
- **Responsive design**: Adapts to available space
- **Pricing display**: Shows both rent and sale prices when available
- **Availability status**: Visual indicators for book availability

## Enhanced Image Handling with Default Placeholders

### BookCoverImage
Enhanced to handle loading timeouts and empty URLs with smart fallbacks.

```dart
BookCoverImage(
  imageUrl: book.primaryImageUrl,
  width: 200,
  height: 300,
  loadingTimeout: Duration(seconds: 8), // Custom timeout
  // Automatically shows DefaultBookPlaceholder for:
  // - Empty imageUrl
  // - Loading timeout
  // - Network errors
)
```

### Default Placeholders
Two specialized placeholder widgets for better UX:

```dart
// For empty/error states
DefaultBookPlaceholder(
  width: 200,
  height: 300,
  backgroundColor: Colors.grey[100],
  iconColor: Colors.grey[600],
)

// For loading states
BookImageLoadingPlaceholder(
  width: 200,
  height: 300,
  backgroundColor: Colors.grey[50],
)
```

### BookImageCarousel
Enhanced to handle empty image arrays gracefully:

```dart
// Automatically handles:
// - Empty arrays → Shows DefaultBookPlaceholder
// - Single image → Shows BookCoverImage
// - Multiple images → Shows carousel with indicators

BookImageCarousel(
  imageUrls: book.imageUrls, // Can be empty or contain URLs
  width: double.infinity,
  height: 300,
  showIndicators: true,
)
```

### Book Entity
New convenience getter for image checking:

```dart
book.hasAnyImages  // true if imageUrls.isNotEmpty
book.hasMultipleImages  // true if imageUrls.length > 1
book.primaryImageUrl  // first URL or empty string
```

### Smart Loading Strategy
The enhanced image components implement:

1. **Empty URL Detection**: Shows default placeholder immediately
2. **Loading Timeout**: 10-second default timeout with fallback
3. **Error Handling**: Network errors show default placeholder
4. **Loading States**: Custom loading indicator while images load
5. **Graceful Degradation**: Always provides meaningful fallback content

### Key Features:
- **No external assets required**: Uses Flutter icons and widgets
- **Configurable timeouts**: Adjust loading patience per use case
- **Theme-aware**: Automatically adapts to light/dark themes
- **Responsive design**: Scales appropriately for different sizes
- **Memory efficient**: Proper disposal of timers and controllers

## Benefits of This Approach

1. **Consistency**: All book displays use the same components
2. **Maintainability**: Changes to book display logic happen in one place
3. **Reusability**: Components can be used across different pages
4. **Testability**: Each component can be tested independently
5. **Performance**: Reduced code duplication means smaller bundle size
6. **Developer Experience**: Less boilerplate code to write
