import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for updating a book copy
class UpdateCopyUseCase {
  final BookUploadRepository repository;

  UpdateCopyUseCase({required this.repository});

  Future<Either<Failure, BookCopy>> call(BookCopy copy) async {
    // Validate copy
    if (copy.id == null || copy.id!.isEmpty) {
      return const Left(ValidationFailure('Copy ID is required for update'));
    }
    
    if (!copy.isValid) {
      return const Left(ValidationFailure('Please complete all copy details'));
    }
    
    if (copy.imageUrls.isEmpty) {
      return const Left(ValidationFailure('Please add at least one image'));
    }
    
    if (!copy.isAvailable) {
      return const Left(ValidationFailure('Please select availability type'));
    }
    
    return await repository.updateCopy(copy);
  }
}
