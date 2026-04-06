import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_upload_form_model.dart';

/// Remote data source for book upload operations
abstract class BookUploadRemoteDataSource {
  /// Search for books by ISBN or title
  Future<List<BookModel>> searchBooks(String query);
  
  /// Get book by ISBN
  Future<BookModel?> getBookByIsbn(String isbn);
  
  /// Upload a new book with copies
  Future<BookModel> uploadBook(BookUploadFormModel form);
  
  /// Update an existing book
  Future<BookModel> updateBook(BookUploadFormModel form);
  
  /// Upload a copy of an existing book
  Future<BookCopyModel> uploadCopy(BookCopyModel copy);
  
  /// Update an existing copy
  Future<BookCopyModel> updateCopy(BookCopyModel copy);
  
  /// Delete a copy
  Future<void> deleteCopy(String copyId, String reason);
  
  /// Delete a book (owner only)
  Future<void> deleteBook(String bookId, String reason);
  
  /// Get books uploaded by current user
  Future<List<BookModel>> getUserBooks();
  
  /// Upload image and return URL
  Future<String> uploadImage(String filePath);
  
  /// Get available genres
  Future<List<String>> getGenres();
  
  /// Get available languages
  Future<List<String>> getLanguages();
}
