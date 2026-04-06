import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';

class SearchBooksUseCase {
  final BookRepository bookRepository;

  SearchBooksUseCase({required this.bookRepository});

  Future<Either<Failure, List<Book>>> call(String query) {
    return bookRepository.searchBooks(query);
  }
}
