import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

/// Repository interface for library operations
abstract class LibraryRepository {
  /// Get borrowed books with pagination
  Future<Either<Failure, List<Book>>> getBorrowedBooks({
    int page = 1, 
    int limit = 20
  });
  
  /// Get uploaded books (user's own books) with pagination
  Future<Either<Failure, List<Book>>> getUploadedBooks({
    int page = 1, 
    int limit = 20
  });
  
  /// Get all borrowed books for the full list page
  Future<Either<Failure, List<Book>>> getAllBorrowedBooks();
  
  /// Get all uploaded books for the full list page
  Future<Either<Failure, List<Book>>> getAllUploadedBooks();
}
