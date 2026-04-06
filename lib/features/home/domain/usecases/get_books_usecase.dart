import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';

class GetBooksUseCase {
  final BookRepository bookRepository;

  GetBooksUseCase({required this.bookRepository});

  Future<Either<Failure, List<Book>>> call({int page = 1, int limit = 20}) {
    return bookRepository.getBooks(page: page, limit: limit);
  }
}
