import 'package:flutter_library/features/books/data/models/book_model.dart';

/// Remote data source for library operations
abstract class LibraryRemoteDataSource {
  /// Get borrowed books with pagination
  Future<List<BookModel>> getBorrowedBooks({int page = 1, int limit = 20});
  
  /// Get uploaded books with pagination
  Future<List<BookModel>> getUploadedBooks({int page = 1, int limit = 20});
}
