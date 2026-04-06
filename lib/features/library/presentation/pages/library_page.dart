import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_icon_button_with_badge.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_event.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';
import 'package:flutter_library/features/library/presentation/pages/full_book_list_page.dart';
import 'package:flutter_library/features/library/presentation/widgets/horizontal_book_list.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Library page showing user's personal collection and activity
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final NavigationService _navigationService = sl<NavigationService>();

  @override
  void initState() {
    super.initState();
    // Load both borrowed and uploaded books
    context.read<LibraryBloc>().add(const LoadBorrowedBooks());
    context.read<LibraryBloc>().add(const LoadUploadedBooks());
  }

  void _onBorrowedBookTap(Book book) {
    // Navigate to book details for borrowed books
    _navigationService.navigateTo(AppRoutes.bookDetails, arguments: book);
  }

  void _onUploadedBookTap(Book book) {
    // Navigate to book upload page for editing uploaded books
    _navigationService.navigateTo(AppRoutes.addBook, arguments: book);
  }

  void _onBorrowedMoreTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FullBookListPage(
          title: AppConstants.borrowedBooksTitle,
          listType: BookListType.borrowed,
        ),
      ),
    );
  }

  void _onUploadedMoreTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FullBookListPage(
          title: AppConstants.myUploadedBooksTitle,
          listType: BookListType.uploaded,
        ),
      ),
    );
  }

  void _navigateToFavorites() {
    _navigationService.navigateTo(AppRoutes.favorites);
  }

  Future<void> _onRefresh() async {
    context.read<LibraryBloc>().add(const RefreshLibrary());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: _navigateToFavorites,
            tooltip: 'Favorites',
          ),
          const CartIconButtonWithBadge(),
        ],
        elevation: AppDimensions.elevationXs,
        shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.05),
        toolbarHeight: AppDimensions.appBarHeight,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, state) {
            if (state is LibraryLoading) {
              return _buildLoadingState();
            }

            if (state is LibraryError) {
              return _buildErrorState(state.message);
            }

            if (state is LibraryLoaded) {
              return _buildLoadedState(state);
            }

            return _buildInitialState();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.defaultPadding),
          Text(AppConstants.loadingLibraryMessage),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDimensions.icon3Xl + AppDimensions.spaceLg,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text(
              AppConstants.errorLoadingLibraryTitle,
              style: TextStyle(
                fontSize: AppTypography.fontSizeXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.fontSizeMd,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton.icon(
              onPressed: () {
                context.read<LibraryBloc>().add(const LoadBorrowedBooks());
                context.read<LibraryBloc>().add(const LoadUploadedBooks());
              },
              icon: const Icon(Icons.refresh),
              label: const Text(AppConstants.tryAgainButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(LibraryLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          // Borrowed Books section
          HorizontalBookList(
            title: AppConstants.borrowedBooksTitle,
            books: state.borrowedBooks,
            isLoading: false,
            onMoreTapped: state.borrowedBooks.length >= 5 ? _onBorrowedMoreTap : null,
            onBookTapped: _onBorrowedBookTap,
            showMoreButton: true,
          ),

          // Uploaded Books section  
          HorizontalBookList(
            title: AppConstants.myUploadedBooksTitle,
            books: state.uploadedBooks,
            isLoading: false,
            onMoreTapped: state.uploadedBooks.length >= 5 ? _onUploadedMoreTap : null,
            onBookTapped: _onUploadedBookTap,
            showMoreButton: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.smallPadding),
          
          // Borrowed Books section - loading
          const HorizontalBookList(
            title: AppConstants.borrowedBooksTitle,
            books: [],
            isLoading: true,
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Uploaded Books section - loading
          const HorizontalBookList(
            title: AppConstants.myUploadedBooksTitle,
            books: [],
            isLoading: true,
          ),

          const SizedBox(height: AppConstants.largePadding),
        ],
      ),
    );
  }
}
