import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/library/domain/repositories/library_repository.dart';

/// Use case for getting uploaded books
class GetUploadedBooksUseCase {
  final LibraryRepository repository;

  GetUploadedBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call({
    int page = 1,
    int limit = 20, // Default to match repository interface
  }) async {
    return await repository.getUploadedBooks(page: page, limit: limit);
  }
}

/// Use case for getting all uploaded books
class GetAllUploadedBooksUseCase {
  final LibraryRepository repository;

  GetAllUploadedBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getAllUploadedBooks();
  }
}
