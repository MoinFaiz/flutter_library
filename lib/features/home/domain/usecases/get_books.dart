import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';

class GetBooksUseCase {
  final BookRepository repository;

  GetBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call({int page = 1, int limit = 20}) async {
    return await repository.getBooks(page: page, limit: limit);
  }
}

class SearchBooksUseCase {
  final BookRepository repository;

  SearchBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call(String query) async {
    return await repository.searchBooks(query);
  }
}
