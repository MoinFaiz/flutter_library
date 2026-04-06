import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/injection/injection_container.dart';
import 'package:flutter_library/shared/widgets/book_grid_widget.dart';

/// Full book list page for showing all borrowed or uploaded books
class FullBookListPage extends StatefulWidget {
  final String title;
  final BookListType listType;

  const FullBookListPage({
    super.key,
    required this.title,
    required this.listType,
  });

  @override
  State<FullBookListPage> createState() => _FullBookListPageState();
}

class _FullBookListPageState extends State<FullBookListPage> {
  final NavigationService _navigationService = sl<NavigationService>();
  List<Book> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      late final Either<Failure, List<Book>> result;
      
      if (widget.listType == BookListType.borrowed) {
        final useCase = sl<GetAllBorrowedBooksUseCase>();
        result = await useCase();
      } else {
        final useCase = sl<GetAllUploadedBooksUseCase>();
        result = await useCase();
      }

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (books) {
          setState(() {
            _books = books;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${AppConstants.unexpectedErrorMessage}: $e';
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadBooks();
  }

  void _onBookTap(Book book) {
    if (widget.listType == BookListType.borrowed) {
      // For borrowed books, navigate to book details
      _navigationService.navigateTo(AppRoutes.bookDetails, arguments: book);
    } else {
      // For uploaded books, navigate to book upload page for editing
      _navigationService.navigateTo(AppRoutes.addBook, arguments: book);
    }
  }

  void _onFavoriteToggle(Book book) {
    // This will be handled by favorites bloc when integration is complete
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          book.isFavorite 
              ? AppConstants.removedFromFavoritesMessage
              : AppConstants.addedToFavoritesMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BookGridWidget(
        books: _books,
        isLoading: _isLoading,
        isRefreshing: false,
        isLoadingMore: false,
        hasMore: false,
        errorMessage: _errorMessage,
        onRefresh: _onRefresh,
        onLoadMore: () {}, // Not needed for this simple implementation
        onBookTap: _onBookTap,
        onFavoriteToggle: _onFavoriteToggle,
        emptyStateTitle: widget.listType == BookListType.borrowed 
            ? AppConstants.noBorrowedBooksTitle
            : AppConstants.noUploadedBooksTitle,
        emptyStateSubtitle: widget.listType == BookListType.borrowed 
            ? AppConstants.noBorrowedBooksSubtitle
            : AppConstants.noUploadedBooksSubtitle,
        emptyStateIcon: widget.listType == BookListType.borrowed 
            ? Icons.book_outlined 
            : Icons.upload_outlined,
      ),
    );
  }
}

/// Enum to distinguish between borrowed and uploaded books
enum BookListType {
  borrowed,
  uploaded,
}
