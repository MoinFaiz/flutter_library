import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/error_handler.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/home/data/datasources/book_local_datasource.dart';
import 'package:flutter_library/features/home/data/datasources/book_remote_datasource.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Book>>> getBooks({int page = 1, int limit = 20}) async {
    return await ErrorHandler.safeExecute(() async {
      // Only check cache for first page
      if (page == 1) {
        final isCacheValid = await localDataSource.isCacheValid();
        
        if (isCacheValid) {
          // Return cached books for first page if cache is valid
          try {
            return (await localDataSource.getCachedBooks()).map((m) => m.toEntity()).toList();
          } catch (e) {
            // If cache fails, fetch from remote
          }
        }
      }
      
      // Fetch from remote
      final remoteBooks = await remoteDataSource.getBooks(page: page, limit: limit);
      
      // Cache first page for offline access
      if (page == 1) {
        await localDataSource.cacheBooks(remoteBooks);
      }
      
      return remoteBooks.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<Book>>> searchBooks(String query) async {
    return await ErrorHandler.safeExecute(() async {
      final models = await remoteDataSource.searchBooks(query);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, Book?>> getBookById(String bookId) async {
    return await ErrorHandler.safeExecute(() async {
      final model = await remoteDataSource.getBookById(bookId);
      return model?.toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> invalidateCache() async {
    return await ErrorHandler.safeExecute(() async {
      await localDataSource.invalidateCache();
    });
  }

  @override
  Future<Either<Failure, bool>> isCacheValid() async {
    return await ErrorHandler.safeExecute(() async {
      return await localDataSource.isCacheValid();
    });
  }

}
