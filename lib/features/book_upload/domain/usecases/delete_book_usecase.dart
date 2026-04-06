import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for deleting a book (book owner only)
class DeleteBookUseCase {
  final BookUploadRepository repository;

  DeleteBookUseCase({required this.repository});

  Future<Either<Failure, void>> call(String bookId, String reason) async {
    if (bookId.trim().isEmpty) {
      return const Left(ValidationFailure('Book ID is required'));
    }
    
    return await repository.deleteBook(bookId, reason);
  }
}
