import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';

/// Use case for getting favorite books by combining BookRepository and FavoritesRepository
class GetFavoriteBooksUseCase {
  final BookRepository bookRepository;
  final FavoritesRepository favoritesRepository;

  GetFavoriteBooksUseCase({
    required this.bookRepository,
    required this.favoritesRepository,
  });

  Future<Either<Failure, List<Book>>> call({int page = 1, int limit = 20}) async {
    try {
      // Get favorite book IDs
      final favoritesResult = await favoritesRepository.getFavoriteBookIds();
      
      return favoritesResult.fold(
        (failure) => Left(failure),
        (favoriteIds) async {
          if (favoriteIds.isEmpty) {
            return const Right([]);
          }
          
          // For pagination, we need to slice the favorite IDs
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          
          if (startIndex >= favoriteIds.length) {
            return const Right([]); // No more favorites
          }
          
          final paginatedIds = favoriteIds.sublist(
            startIndex,
            endIndex > favoriteIds.length ? favoriteIds.length : endIndex,
          );
          
          // Get book details for the paginated favorite IDs
          final List<Book> favoriteBooks = [];
          
          for (final bookId in paginatedIds) {
            final bookResult = await bookRepository.getBookById(bookId);
            
            bookResult.fold(
              (failure) {
                // Skip books that can't be fetched, don't fail the entire operation
              },
              (book) {
                if (book != null) {
                  // Books in the favorites list are shown as favorites
                  favoriteBooks.add(book.copyWith(isFavorite: true));
                }
              },
            );
          }
          
          return Right(favoriteBooks);
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Failed to get favorite books: ${e.toString()}'));
    }
  }
}
