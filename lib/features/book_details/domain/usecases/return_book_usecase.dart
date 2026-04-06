import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';

/// Use case for returning a rented book
class ReturnBookUseCase {
  final BookOperationsRepository repository;

  ReturnBookUseCase({required this.repository});

  Future<Either<Failure, Book>> call(String bookId) async {
    return await repository.returnBook(bookId);
  }
}
