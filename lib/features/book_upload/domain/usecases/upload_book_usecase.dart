import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for uploading a new book
class UploadBookUseCase {
  final BookUploadRepository repository;

  UploadBookUseCase({required this.repository});

  Future<Either<Failure, Book>> call(BookUploadForm form) async {
    // Validate form
    if (!form.isValid) {
      return const Left(ValidationFailure('Please fill in all required fields'));
    }
    
    // Check if copies are valid
    if (form.copies.isEmpty) {
      return const Left(ValidationFailure('Please add at least one copy'));
    }
    
    final invalidCopies = form.copies.where((copy) => !copy.isValid);
    if (invalidCopies.isNotEmpty) {
      return const Left(ValidationFailure('Please complete all copy details'));
    }
    
    return await repository.uploadBook(form);
  }
}
