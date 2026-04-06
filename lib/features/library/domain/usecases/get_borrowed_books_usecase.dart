import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/library/domain/repositories/library_repository.dart';

/// Use case for getting borrowed books
class GetBorrowedBooksUseCase {
  final LibraryRepository repository;

  GetBorrowedBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call({
    int page = 1,
    int limit = 20, // Default to match repository interface
  }) async {
    return await repository.getBorrowedBooks(page: page, limit: limit);
  }
}

/// Use case for getting all borrowed books
class GetAllBorrowedBooksUseCase {
  final LibraryRepository repository;

  GetAllBorrowedBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getAllBorrowedBooks();
  }
}
