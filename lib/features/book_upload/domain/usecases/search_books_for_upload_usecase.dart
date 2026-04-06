import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for searching books by ISBN or title during the book upload flow.
class SearchBooksForUploadUseCase {
  final BookUploadRepository repository;

  SearchBooksForUploadUseCase({required this.repository});

  Future<Either<Failure, List<Book>>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchBooks(query.trim());
  }
}
