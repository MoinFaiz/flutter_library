import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for deleting a book copy
class DeleteCopyUseCase {
  final BookUploadRepository repository;

  DeleteCopyUseCase({required this.repository});

  Future<Either<Failure, void>> call(String copyId, String reason) async {
    if (copyId.trim().isEmpty) {
      return const Left(ValidationFailure('Copy ID is required'));
    }
    
    return await repository.deleteCopy(copyId, reason);
  }
}
