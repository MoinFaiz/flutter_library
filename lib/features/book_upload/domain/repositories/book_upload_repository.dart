import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';

/// Repository interface for book upload operations
abstract class BookUploadRepository {
  /// Search for books by ISBN or title
  Future<Either<Failure, List<Book>>> searchBooks(String query);
  
  /// Get book by ISBN
  Future<Either<Failure, Book?>> getBookByIsbn(String isbn);
  
  /// Upload a new book with copies
  Future<Either<Failure, Book>> uploadBook(BookUploadForm form);
  
  /// Update an existing book
  Future<Either<Failure, Book>> updateBook(BookUploadForm form);
  
  /// Upload a copy of an existing book
  Future<Either<Failure, BookCopy>> uploadCopy(BookCopy copy);
  
  /// Update an existing copy
  Future<Either<Failure, BookCopy>> updateCopy(BookCopy copy);
  
  /// Delete a copy
  Future<Either<Failure, void>> deleteCopy(String copyId, String reason);
  
  /// Delete a book (owner only)
  Future<Either<Failure, void>> deleteBook(String bookId, String reason);
  
  /// Get books uploaded by current user
  Future<Either<Failure, List<Book>>> getUserBooks();
  
  /// Upload image and return URL
  Future<Either<Failure, String>> uploadImage(String filePath);
  
  /// Get available genres
  Future<Either<Failure, List<String>>> getGenres();
  
  /// Get available languages
  Future<Either<Failure, List<String>>> getLanguages();
}
