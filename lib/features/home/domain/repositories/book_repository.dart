import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks({int page = 1, int limit = 20});
  Future<Either<Failure, List<Book>>> searchBooks(String query);
  Future<Either<Failure, Book?>> getBookById(String bookId);
  
  // Cache management
  Future<Either<Failure, void>> invalidateCache();
  Future<Either<Failure, bool>> isCacheValid();
}
