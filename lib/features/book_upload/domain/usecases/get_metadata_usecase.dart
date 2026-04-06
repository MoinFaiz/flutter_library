import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for getting available genres
class GetGenresUseCase {
  final BookUploadRepository repository;

  GetGenresUseCase({required this.repository});

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getGenres();
  }
}

/// Use case for getting available languages
class GetLanguagesUseCase {
  final BookUploadRepository repository;

  GetLanguagesUseCase({required this.repository});

  Future<Either<Failure, List<String>>> call() async {
    return await repository.getLanguages();
  }
}
