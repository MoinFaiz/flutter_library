import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for updating an existing book
class UpdateBookUseCase {
  final BookUploadRepository repository;

  UpdateBookUseCase({required this.repository});

  Future<Either<Failure, Book>> call(BookUploadForm form) async {
    // Validate form
    if (!form.isValid) {
      return const Left(ValidationFailure('Please fill in all required fields'));
    }
    
    // Ensure we have a book ID for update
    if (form.id == null || form.id!.isEmpty) {
      return const Left(ValidationFailure('Book ID is required for update'));
    }
    
    return await repository.updateBook(form);
  }
}
