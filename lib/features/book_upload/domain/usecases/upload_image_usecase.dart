import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for uploading image
class UploadImageUseCase {
  final BookUploadRepository repository;

  UploadImageUseCase({required this.repository});

  Future<Either<Failure, String>> call(String filePath) async {
    if (filePath.trim().isEmpty) {
      return const Left(ValidationFailure('Please select an image'));
    }
    
    return await repository.uploadImage(filePath);
  }
}
